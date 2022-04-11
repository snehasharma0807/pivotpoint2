//
//  SessionManager.swift
//  authenticated
//
//  Created by Sneha Sharma on 3/15/22.
//

import Amplify
import Combine
import Foundation
enum AuthState{
    case signUp
    case login(error: String)
    case confirmCode(username: String)
    case session(user: AuthUser)
    case resetPassword(resetPasswordError: String)
    case confirmResetPassword(confirmResetPasswordError: String)
}
final class SessionManager: ObservableObject{
    @Published var authState: AuthState = .login(error: "")
    func getCurrentAuthUser(){
        if let user = Amplify.Auth.getCurrentUser(){
            authState = .session(user: user)
        } else {
            authState = .login(error: "")
        }
    }
    func showSignup(){
        authState = .signUp
    }
    func showLogin(error: String){
        authState = .login(error: error)
    }
    func showResetPassword(resetPasswordError: String){
        authState = .resetPassword(resetPasswordError: resetPasswordError)
    }
    func showConfirmResetPassword(confirmResetPasswordError: String){
        authState = .confirmResetPassword(confirmResetPasswordError: confirmResetPasswordError)
    }

    
    func signUp(username: String, email: String, password: String){
        let attributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: attributes)
        
        _ = Amplify.Auth.signUp(
            username: username,
            password: password,
            options: options
        ){ [weak self] result in
            
            switch result{
            case .success(let signUpResult):
                print("Sign up result: ", signUpResult)
                
                switch signUpResult.nextStep{
                case .done:
                    print("Finished sign up")
                case .confirmUser(let details, _):
                    print(details ?? "no details")
                    
                    DispatchQueue.main.async{
                        self?.authState = .confirmCode(username: username)
                    }
                }
                
            case .failure(let error):
                print("Sign up error", error)
            }
            
        }
    }
    
    func confirm(username: String, code: String){
        _ = Amplify.Auth.confirmSignUp(for: username, confirmationCode: code
        ){ [weak self] result in
            
            switch result{
            case .success(let confirmResult):
                print(confirmResult)
                if confirmResult.isSignupComplete{
                    DispatchQueue.main.async {
                        self?.showLogin(error: "")
                    }
                }
            case .failure(let error):
                print("failed to confirm code:", error)
            }
        }
    }
    
    func login(username: String, password: String) {
        _ = Amplify.Auth.signIn(
            username: username,
            password: password
        ) {[weak self] result in
            
            switch result{
            case .success(let signInResult):
                print(signInResult)
                if signInResult.isSignedIn{
                    DispatchQueue.main.async {
                        self?.getCurrentAuthUser()
                    }
                }
                
            case .failure(let error):
                var the_error: String = ""
                print("Error: " , error.errorDescription)
                if error.errorDescription == "Username is required to signIn"{
                    the_error = "Username is required to sign in"
                } else{
                    the_error = error.errorDescription
                }
                    DispatchQueue.main.async {
                        self?.showLogin(error: the_error)
                    }
            }
        }
    }
    
    func signOut(){
        _ = Amplify.Auth.signOut{ [weak self] result in
            switch result{
            case .success:
                DispatchQueue.main.async {
                    self?.getCurrentAuthUser()
                }
            case .failure(let error):
                print("Sign out error: ", error)
            }
        }
    }
    
    func resetPassword(username: String) {
        _ = Amplify.Auth.resetPassword(for: username){[weak self] result in
            switch result{
            case .success(let resetResult):
                print(resetResult)
                switch resetResult.nextStep {
                case .confirmResetPasswordWithCode(let deliveryDetails, let info):
                    print("Confirm reset password with code send to - \(deliveryDetails) \(String(describing: info) )")
                    self?.showConfirmResetPassword(confirmResetPasswordError: "")

                case .done:
                    DispatchQueue.main.async {
                        self?.showLogin(error: "")
                    }

                }
            case .failure(let resetPasswordError):
                var the_error: String = ""
                print("Error: " , resetPasswordError.errorDescription)
                if resetPasswordError.errorDescription == "username is required to resetPassword"{
                    the_error = "Username is required to reset your password"
                } else if resetPasswordError.errorDescription == "Username/client id combination not found."{
                    the_error = "Username not found"
                } else{
                    the_error = resetPasswordError.errorDescription
                }
                DispatchQueue.main.async {
                    self?.showResetPassword(resetPasswordError: the_error)
                }
            }
            
        }
        
    }
func confirmResetPassword(
        username: String,
        newPassword: String,
        confirmationCode: String
    ) {
        Amplify.Auth.confirmResetPassword(
            for: username,
            with: newPassword,
            confirmationCode: confirmationCode
        ){[weak self] result in
            
            switch result{
            case .success(let confirmResult):
                print(confirmResult)
                print("Password reset confirmed.")
                DispatchQueue.main.async {
                    self?.showLogin(error: "")
                }
            case .failure(let authError):
                print("Password reset failed with error \(authError)")
                var the_error:String = ""
                the_error=authError.errorDescription
                switch the_error{
                case "Username/client id combination not found.":
                    the_error = "Username not found"
                case "username is required to confirmResetPassword":
                    the_error = "Please input your username, password, and confirmation code"
                case "newPassword is required to confirmResetPassword":
                    the_error = "Please input your username, password, and confirmation code"
                case "confirmationCode is required to confirmResetPassword":
                    the_error = "Please input your username, password, and confirmation code"
                case "Password does not conform to policy: Password not long enough":
                    the_error = "Please input a password that is longer than eight characters"
                default:
                    the_error = ""
                }

                DispatchQueue.main.async {
                    self?.showConfirmResetPassword(confirmResetPasswordError: the_error)
                }
            }
//            if case let .failure(authError) = result{
//                print("Reset password failed with error \(authError)")
//                return
//            }
//        recieveValue: do {
//            print("Password reset confirmed.")
//            DispatchQueue.main.async {
//                self?.showLogin(error: "")
//            }
//        }
            
        }
    }

}
