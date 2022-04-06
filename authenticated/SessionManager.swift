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
    case login
    case confirmCode(username: String)
    case session(user: AuthUser)
    case resetPassword
    case confirmResetPassword
}
final class SessionManager: ObservableObject{
    @Published var authState: AuthState = .login
    func getCurrentAuthUser(){
        if let user = Amplify.Auth.getCurrentUser(){
            authState = .session(user: user)
        } else {
            authState = .login
        }
    }
    func showSignup(){
        authState = .signUp
    }
    func showLogin(){
        authState = .login
    }
    func showResetPassword(){
        authState = .resetPassword
    }
    func showConfirmResetPassword(){
        authState = .confirmResetPassword
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
                        self?.showLogin()
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
                print("Login error: ", error)
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
                    self?.showConfirmResetPassword()

                case .done:
                    DispatchQueue.main.async {
                        self?.showLogin()
                    }

                }
            case .failure(let error):
                print("Reset password failed with error \(error)")
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
            if case let .failure(authError) = result{
                print("Reset password failed with error \(authError)")
                return
            }
        recieveValue: do {
            print("Password reset confirmed.")
            DispatchQueue.main.async {
                self?.showLogin()
            }
        }
            
        }
    }

}

