//
//  SessionManager.swift
//  authenticated
//
//  Created by Sneha Sharma on 3/15/22.
//


import Amplify
import AmplifyPlugins
import Combine
import Foundation
import AWSPluginsCore
import AWSCognitoIdentity
import AWSCognitoIdentityProvider
import ClientRuntime
import AWSClientRuntime




enum AuthState{
    case signUp(error: String)
    case login(error: String)
    case confirmCode(username: String)
    case calendar(user: AuthUser)
    case resetPassword(resetPasswordError: String)
    case confirmResetPassword(confirmResetPasswordError: String)
    case signUpForEvent
    case calendarView(user: AuthUser)
    case addEvent
    case loadingView
    case usersListView
    case updateProfileInformationView(user: AuthUser)
    case addProfileInformationView
}


final class SessionManager: ObservableObject{
    var isAdmin: Bool = false
    var cognitoGroups: Array<String> = []
    var isEmployee: Bool = false
    var isLoading: Bool = false
    var currentUser: String = ""
    var currentUserModel: UserDetails? = nil
    var idsForUsersList: [Int] = []
    var usersList: [String] = []
    var userPhoneNumberList: [String] = []
    var usersSubscription: AnyCancellable?

    



    
    @Published var authState: AuthState = .login(error: "")
    func getCurrentAuthUser(){
        if Amplify.Auth.getCurrentUser() != nil{
            isAdmin = false
            cognitoGroups = []
            self.listGroups()
            _ = self.isUserAdmin()
            _ = self.isUserEmployee()
            self.authState = .loadingView
            currentUser = "\(Amplify.Auth.getCurrentUser()?.username ?? "")"
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.authState = .calendar(user: Amplify.Auth.getCurrentUser()!)
            }
        } else {
            isAdmin = false
            cognitoGroups = []
            authState = .login(error: "")
            print("authstate has changed to login")
            
        }
    }
    func changeAuthStateToSignUp(error: String){
        authState = .signUp(error: error)
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
    func changeAuthStateToCalendar(){
        if let user = Amplify.Auth.getCurrentUser(){
            authState = .calendar(user: user)
        } else {
            authState = .login(error: "")
        }
    }
    func changeAuthStateToAddEvent(){
        authState = .addEvent
    }
    func changeAuthStateToLoading(){
        authState = .loadingView
    }
    func changeAuthStateToUsersList(){
        queryUserProfileInformation()
        print(usersList)
        authState = .usersListView
    }
    func changeAuthStateToUpdateProfileInformation() {
        if let user = Amplify.Auth.getCurrentUser(){
            authState = .updateProfileInformationView(user: user)
        }
    }
    func changeAuthStateToAddProfileInformation() {
        authState = .addProfileInformationView
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
                var the_error: String = ""
                print("Error: ", error.errorDescription)
                if (error.errorDescription == "Username is required to signUp"){
                    the_error = "Username is required to sign up."
                } else if (error.errorDescription == "Password is required to signUp"){
                    the_error = "Password is required to sign up."
                } else if (error.errorDescription == "Password did not conform with policy: Password not long enough"){
                    the_error = "Password is not long enough."
                } else if(error.errorDescription == "Invalid email address format."){
                    the_error = "Make sure your email is correct!"
                } else if(error.errorDescription != ""){
                    the_error = "Try again"
                }else{
                    the_error = ""
                }
                DispatchQueue.main.async {
                    self?.changeAuthStateToSignUp(error: the_error)
                }
            }
            
        }
    }
    
    func confirm(username: String, code: String){
        currentUser = username
        _ = Amplify.Auth.confirmSignUp(for: username, confirmationCode: code
        ){ [weak self] result in
            
            switch result{
            case .success(let confirmResult):
                print(confirmResult)
                if confirmResult.isSignupComplete{
                    DispatchQueue.main.async {
                        self?.changeAuthStateToAddProfileInformation()
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
                    Amplify.DataStore.clear()
                    self?.listGroups()
                    self?.getCurrentAuthUser()
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
                Amplify.DataStore.clear()
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
    
    func listGroups(){
        Amplify.Auth.fetchAuthSession() { result in
            do {
                let session = try result.get()
                        if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
//                            print(try cognitoTokenProvider.getCognitoTokens().get().accessToken)
                            let tokens = try cognitoTokenProvider.getCognitoTokens().get()
//                            print("Id token - \(tokens.idToken) ")
                            let tokenClaims = try AWSAuthService().getTokenClaims(tokenString: tokens.idToken).get()
//                            print("Token Claims: \(tokenClaims)")
                            if let groups = (tokenClaims["cognito:groups"] as? NSArray) as Array?{
                                var _ : Set<String> = []
                                for group in groups {
                                    print("Cognito group: \(group)")
                                    if group as! String == "admin"{
                                        self.isAdmin = true
                                    } else{
                                        self.isAdmin = false
                                    }
                                    if group as! String == "employee"{
                                        self.isEmployee = true
                                    } else {
                                        self.isEmployee = false
                                    }
                                    self.cognitoGroups.append(group as! String)
                                }
                             }
                        }
                print("did this run?")
                print("Is the user an admin? \(self.isAdmin)")
                print("List of the user's groups: \(self.cognitoGroups)")
                    } catch {
                        print("Fetch auth session failed with error - \(error)")
                    }
            }
    }
    
    func isUserAdmin() -> Bool {
        print(self.isAdmin)
        return self.isAdmin
    }
    func isUserEmployee() -> Bool {
        print(self.isEmployee)
        return self.isEmployee
    }
    

    
    func startFakeNetworkCall() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isLoading = false
        }
    }
    
    func saveUserProfileInformation(username: String, fullname: String, phoneNumber: String, address: String) {
        let detailsToSave = UserDetails(username: username, fullName: fullname, address: address, phoneNumber: phoneNumber)
        Amplify.DataStore.save(detailsToSave) { result in
            switch result {
            case .success(let user):
                print("\(user.username) details saved")
            case .failure(let error):
                print(error)
            }
        }

    }
    

    
    
    //used in updateUserProfileInformation()
    func returnCurrentUserModel (username: String) {
        self.usersSubscription = Amplify.DataStore.observeQuery(for: UserDetails.self)
            .sink { completed in
                switch completed {
                case .finished:
                    print("finished")
                    
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { querySnapshot in
                print("Snapshot item live count: \(querySnapshot.items.count), inSynced: \(querySnapshot.isSynced)")
                for user in querySnapshot.items {
                    if user.username == username {
                        self.currentUserModel = user
                    }
                }
            }
    }
    
    func queryUserProfileInformation () {
        usersList = []
        idsForUsersList = []
        userPhoneNumberList = []
        
        self.usersSubscription = Amplify.DataStore.observeQuery(
                    for: UserDetails.self
                )
            .sink { completed in
                switch completed {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("Error \(error)")
                }
            } receiveValue: { [self] querySnapshot in
                print("[Snapshot] item count: \(querySnapshot.items.count), isSynced: \(querySnapshot.isSynced)")
                var id = 0
                for user in querySnapshot.items {
                    usersList.append(user.fullName)
                    userPhoneNumberList.append(user.phoneNumber)
                    idsForUsersList.append(id)
                    id += 1
                    print(user.username)
                }
            }
    }
    
    func subscribeToUsers() {
        usersSubscription = Amplify.DataStore.publisher(for: UserDetails.self)
        .sink {
                 if case let .failure(error) = $0 {
                     print("Subscription received error - \(error.localizedDescription)")
                 }
             }
             receiveValue: { changes in
                 // handle incoming changes
                 print("Subscription received mutation: \(changes)")
             }
    }
    func testing () async {
        do {
            let cognitoIdentityClient = try CognitoIdentityProviderClient(region: "us-west-2")
            let user = Amplify.Auth.getCurrentUser()?.username
            let cognitoInputCall = AdminListUserAuthEventsInput(maxResults: 1000, userPoolId: "us-west-2_cQe5CmJ7z", username: user)
            let result = try await cognitoIdentityClient.adminListUserAuthEvents(input: cognitoInputCall)
            print("result: \(result.self)")
        } catch {
            print(error)
        }
    }
    
    func addUserToUserGroup() async {
        do {
            let cognitoClient = try CognitoIdentityProviderClient(region: "us-west-2")
            let cognitoInputCall = AdminAddUserToGroupInput(groupName: "admin", userPoolId: "us-west-2_cQe5CmJ7z", username: "Anotheruser")
            
            let result = try await cognitoClient.adminAddUserToGroup(input: cognitoInputCall)
            print("succeeded")
            print(result.self)
        } catch {
            print(error)
        }
    }
}
