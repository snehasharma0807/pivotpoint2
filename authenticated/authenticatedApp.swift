////
////  AuthenticatedApp.swift
////  authenticated
////
////  Created by Sneha Sharma on 3/15/22.
////
//import Amplify
//import AmplifyPlugins
//import SwiftUI
//@main
//
//
//struct AuthenticaterApp: App{
//
//    @ObservedObject var sessionManager = SessionManager()
//
//    init(){
//        configureAmplify()
//        sessionManager.getCurrentAuthUser()
//    }
//
//
//    var body: some Scene{
//        WindowGroup{
//            switch sessionManager.authState{
//            case .login(let error):
//                LoginView(error: error)
//                    .environmentObject(sessionManager)
//            case .signUp:
//                SignUpView()
//                    .environmentObject(sessionManager)
//            case .confirmCode(let username):
//                ConfirmationView(username: username)
//                    .environmentObject(sessionManager)
//            case .session(let user):
//                SessionView(user: user)
//                    .environmentObject(sessionManager)
//            case .resetPassword(let resetPasswordError):
//                ResetPasswordView(resetPasswordError: resetPasswordError)
//                    .environmentObject(sessionManager)
//            case .confirmResetPassword(let confirmResetPasswordError):
//                ConfirmResetPasswordView(confirmResetPasswordError: confirmResetPasswordError)
//                    .environmentObject(sessionManager)
//            case .signUpForEvent:
//                SignUpForEventView()
//                    .environmentObject(sessionManager)
//        }
//    }
//
//
//    private func configureAmplify(){
//        do{
//            try Amplify.add(plugin: AWSCognitoAuthPlugin())
//            try Amplify.configure()
//            print("Amplify configured successfully")
//        } catch{
//            print("could not initialize successfully", error)
//        }
//    }
//    }
//}

//
//  AuthenticatedApp.swift
//  authenticated
//
//  Created by Sneha Sharma on 3/15/22.
//
import Amplify
import AmplifyPlugins
import SwiftUI
@main


struct AuthenticaterApp: App{
    
    @ObservedObject var sessionManager = SessionManager()
    
    init(){
        configureAmplify()
        sessionManager.getCurrentAuthUser()
    }

    
    var body: some Scene{
        WindowGroup{
            switch sessionManager.authState{
            case .login(let error):
                LoginView(error: error)
                    .environmentObject(sessionManager)
            case .signUp:
                SignUpView()
                    .environmentObject(sessionManager)
            case .confirmCode(let username):
                ConfirmationView(username: username)
                    .environmentObject(sessionManager)
            case .session(let user):
                SessionView(user: user)
                    .environmentObject(sessionManager)
            case .resetPassword(let resetPasswordError):
                ResetPasswordView(resetPasswordError: resetPasswordError)
                    .environmentObject(sessionManager)
            case .confirmResetPassword(let confirmResetPasswordError):
                ConfirmResetPasswordView(confirmResetPasswordError: confirmResetPasswordError)
                    .environmentObject(sessionManager)
            case .signUpForEvent:
                SignUpForEventView()
                    .environmentObject(sessionManager)
            case .sessionView:
                SessionView(user: "user" as! AuthUser)
                    .environmentObject(sessionManager)
            }

        }
    }
    

    private func configureAmplify(){
        do{
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            print("Amplify configured successfully")
        } catch{
            print("could not initialize successfully", error)
        }
    }

}
