
//
//  AuthenticatedApp.swift
//  authenticated
//
//  Created by Sneha Sharma on 3/15/22.
//
import Amplify
import AmplifyPlugins
import SwiftUI
import UserNotifications
import AWSPinpoint
import os


@main


struct AuthenticatedApp: App{
    
    @ObservedObject var sessionManager = SessionManager()
    @StateObject var notificationCenter = NotificationCenter()

    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    init(){
        configureAmplify()
        sessionManager.getCurrentAuthUser()
        registerForPushNotifications()
    }
    

    
    var body: some Scene{
        WindowGroup{
            switch sessionManager.authState{
            case .login(let error):
                LoginView(error: error)
                    .environmentObject(sessionManager)
            case .signUp(let error):
                SignUpView(error: error)
                    .environmentObject(sessionManager)
            case .confirmCode(let username):
                ConfirmationView(username: username)
                    .environmentObject(sessionManager)
            case .calendar(let user):
                CalendarView(user: user)
                    .environmentObject(sessionManager)
            case .resetPassword(let resetPasswordError):
                ResetPasswordView(resetPasswordError: resetPasswordError)
                    .environmentObject(sessionManager)
            case .confirmResetPassword(let confirmResetPasswordError):
                ConfirmResetPasswordView(confirmResetPasswordError: confirmResetPasswordError)
                    .environmentObject(sessionManager)
            case .signUpForEvent(let error):
                SignUpForEventView(error: error)
                    .environmentObject(sessionManager)
            case .calendarView:
                CalendarView(user: "user" as! AuthUser)
                    .environmentObject(sessionManager)
            case .addEvent(let error):
                AddEventView(errorMessage: error)
                    .environmentObject(sessionManager)
            case .loadingView:
                LoadingView()
                    .environmentObject(sessionManager)
            case .usersListView:
                UsersListView()
                    .environmentObject(sessionManager)
            case .updateProfileInformationView:
                UpdateProfileInformationView()
                    .environmentObject(sessionManager)
            case .addProfileInformationView:
                AddProfileInformationView()
                    .environmentObject(sessionManager)
            case .userProfileInformationView:
                UserProfileInformationView()
                    .environmentObject(sessionManager)
            case .viewScheduledOutingsView:
                ViewScheduledOutingsView()
                    .environmentObject(sessionManager)
            case .seeEventDetailsAfterSigningUp:
                SignUpForEventView(alreadyScheduled: true)
                    .environmentObject(sessionManager)
            case .seeUsersInEachOutingView(let clickedOnOuting):
                SeeUsersInEachOutingView(clickedOnOuting: clickedOnOuting)
                    .environmentObject(sessionManager)
            }

        }
    }
    

    private func configureAmplify(){
        do{

            
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            let datastorePlugin = AWSDataStorePlugin(modelRegistration: AmplifyModels())
            try Amplify.add(plugin: datastorePlugin)
            let apiPlugin = AWSAPIPlugin(modelRegistration: AmplifyModels())
            try Amplify.add(plugin: apiPlugin)
            try Amplify.configure()
            
            print("Amplify configured successfully")
        } catch{
            print("could not initialize successfully", error)
        }
    }
    func registerForPushNotifications() {
        UNUserNotificationCenter.current()
          .requestAuthorization(
            options: [.alert, .sound, .badge]) { [self] granted, result in
                print("Permission granted: \(granted)")
                switch result {
                case .none:
                    print("successfully given permission")
                case .some(let error):
                    print(error.localizedDescription)
                }
                guard granted else { return }
                self.getNotificationSettings()
          }
    }
    func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
          guard settings.authorizationStatus == .authorized else { return }
          DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
          }

      }
    }




}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    //No callback in simulator -- must use device to get valid push token
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(deviceToken)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
}

class NotificationCenter: NSObject, ObservableObject {
    @Published var dumbData: UNNotificationResponse?
    
    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
}

extension NotificationCenter: UNUserNotificationCenterDelegate  {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound, .badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        dumbData = response
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, openSettingsFor notification: UNNotification?) { }
}

class LocalNotification: ObservableObject {
    init() {
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (allowed, error) in
            //This callback does not trigger on main loop be careful
            if allowed {
                os_log(.debug, "Allowed")
            } else {
                os_log(.debug, "Error")
            }
        }
    }
}

extension UIApplicationDelegate {
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("Successfully registered for notifications!")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
}
