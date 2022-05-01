//
//  SessionManager.swift
//  authenticated
//
//  Created by Sneha Sharma on 3/15/22.
//

//import AWSCognitoIdentity
//import ClientRuntime
//import AWSClientRuntime

import Amplify
import AmplifyPlugins
import Combine
import Foundation
import AWSPluginsCore


enum AuthState{
    case signUp
    case login(error: String)
    case confirmCode(username: String)
    case calendar(user: AuthUser)
    case resetPassword(resetPasswordError: String)
    case confirmResetPassword(confirmResetPasswordError: String)
    case signUpForEvent
    case calendarView(user: AuthUser)
}
final class SessionManager: ObservableObject{
    @Published var authState: AuthState = .login(error: "")
    func getCurrentAuthUser(){
        if let user = Amplify.Auth.getCurrentUser(){
            authState = .calendar(user: user)
        } else {
            authState = .login(error: "")
            print("authstate has changed to login")
            
        }
    }
    func changeAuthStateToSignUp(){
        authState = .signUp
    }
    func changeAuthStateToLogin(error: String){
        authState = .login(error: error)
        print("authstate changed to login")
    }
    func changeAuthStateToResetPassword(resetPasswordError: String){
        authState = .resetPassword(resetPasswordError: resetPasswordError)
    }
    func changeAuthStateToConfirmResetPassword(confirmResetPasswordError: String){
        authState = .confirmResetPassword(confirmResetPasswordError: confirmResetPasswordError)
    }
    func changeAuthStateToEventDetails(){
        authState = .signUpForEvent
    }
    func changeAuthStateToSession(){
        if let user = Amplify.Auth.getCurrentUser(){
            authState = .calendar(user: user)
        } else {
            authState = .login(error: "")
        }
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
                        self?.changeAuthStateToLogin(error: "")
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
                    var t = Amplify.Auth.fetchAuthSession() { result in
                        do {
                            let session = try result.get()
                            // Get user sub or identity id
//                                    if let identityProvider = session as? AuthCognitoIdentityProvider {
//
//                                        let usersub = try identityProvider.getUserSub().get()
//                                        let identityId = try identityProvider.getIdentityId().get()
//
//                                        print("User sub - \(usersub) and identity id \(identityId)")
//                                    }
//
//                                    // Get aws credentials
//                                    if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
//                                        let credentials = try awsCredentialsProvider.getAWSCredentials().get()
//
//                                        print("Access key - \(credentials.accessKey) ")
//
//                                    }

                                    // Get cognito user pool token
                                    if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                                        print(try cognitoTokenProvider.getCognitoTokens().get().accessToken)
                                        let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                                        print("Id token - \(tokens.idToken) ")

                                        let tokenClaims = try AWSAuthService().getTokenClaims(tokenString: tokens.idToken).get()
                                        print("Token Claims: \(tokenClaims)")
                                        
                                        if let groups = (tokenClaims["cognito:groups"] as? NSArray) as Array?{
                                            var cognitoGroups : Set<String> = []
                                            for group in groups {
                                                print("Cognito group: \(group)")
                                                if let groupString = group as? String {
                                                    cognitoGroups.insert(groupString)
                                                }
                                            }
                                         }
                                    }
                                } catch {
                                    print("Fetch auth session failed with error - \(error)")
                                }
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
                        self?.changeAuthStateToLogin(error: the_error)
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
                print("user has been signed out")
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
                    self?.changeAuthStateToConfirmResetPassword(confirmResetPasswordError: "")

                case .done:
                    DispatchQueue.main.async {
                        self?.changeAuthStateToLogin(error: "")
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
                    self?.changeAuthStateToResetPassword(resetPasswordError: the_error)
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
                    self?.changeAuthStateToLogin(error: "")
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
                    self?.changeAuthStateToConfirmResetPassword(confirmResetPasswordError: the_error)
                }
            }

            
        }
    }
    
    
//    func getIdentityPoolID(name: String,
//                           completion: @escaping (String?) -> Void) throws {
//        var token: String? = nil
//        var poolID: String? = nil
//
//        repeat {
//            var error: Error?
//            let listPoolsInput = ListIdentityPoolsInput(maxResults: 25, nextToken: token)
//
//            cognitoIdentityClient.listIdentityPools(input: listPoolsInput) { (result) in
//                switch(result) {
//                case .success(let output):
//                    poolID = output.identityPools?
//                        .filter { $0.identityPoolName == name }
//                        .map { $0.identityPoolId }
//                        .first ?? nil
//                    token = output.nextToken
//                case .failure(let listError):
//                    error = listError
//                }
//            }
//
//            if error != nil {
//                throw(error!)
//            }
//        } while token != nil && poolID == nil
//
//        completion(poolID)
//    }
    
    
    
    
//    func checkAdmin(username: String) -> Bool{
//
//
//    if username == "ADMIN"{
//            print("this is an admin")
//            return true
//        } else{
//            print("this is not an admin")
//            return false
//        }
//
//        //        if username == rand{
////            return true
////        } else{
////            return false
////        }
//    }
}
