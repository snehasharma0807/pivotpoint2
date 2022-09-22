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
import AWSCognitoIdentityProvider
import ClientRuntime
import AWSClientRuntime
import AWSDynamoDB




enum AuthState{
    case signUp(error: String)
    case login(error: String)
    case confirmCode(username: String)
    case calendar(user: AuthUser)
    case resetPassword(resetPasswordError: String)
    case confirmResetPassword(confirmResetPasswordError: String)
    case signUpForEvent(error: String)
    case calendarView(user: AuthUser)
    case addEvent(error: String)
    case loadingView
    case usersListView
    case updateProfileInformationView(user: AuthUser)
    case addProfileInformationView
    case userProfileInformationView
    case viewScheduledOutingsView
    case seeEventDetailsAfterSigningUp
    case seeUsersInEachOutingView(clickedOnOuting: Outing)
}


final class SessionManager: ObservableObject{
    var isLoading: Bool = false
    var currentUser: String = ""
    @Published var currentUserModel: UserDetails? = nil
    var idsForUsersList: [Int] = []
    var usersSubscription: AnyCancellable?
    var outingsSubscription: AnyCancellable?
    var userOutingSubscription: AnyCancellable?
    @Published var userDetailsList: [UserDetails] = []
    var clickedOnUserDetails: UserDetails = UserDetails(username: "", fullName: "", address: "", phoneNumber: "", userType: UserGroup.client)
    @Published var outingsList: [Outing] = []
    var taskMetaDataList: [TaskMetaData] = []
    var clickedOnOuting: Outing = Outing(title: "", description: "", location: "", startDate: Temporal.Date.now(), startTime: Temporal.Time.now(), endDate: Temporal.Date.now(), endTime: Temporal.Time.now(), numClients: 1)
    var stringInstructors = ""
    @Published var upcomingOutings: [Outing] = []
    @Published var idsForUpcomingOutingsList: [Int] = []
    @Published var pastOutings: [Outing] = []
    @Published var idsForPastOutingsList: [Int] = []
    @Published var usersInAnOutingList: [UserDetails] = []
    @Published var idsForUsersInAnOutingList: [Int] = []
    
    @Published var authState: AuthState = .login(error: "")
    
    func getCurrentAuthUser(){
        if Amplify.Auth.getCurrentUser() != nil{
            Amplify.DataStore.clear() {
                switch $0 {
                case .success:
                    print("cleared")
                case .failure(let error):
                    print(error)
                }
            }
            queryOutings()
            returnCurrentUserModel(username: Amplify.Auth.getCurrentUser()?.username ?? "")
            print(currentUserModel?.userType ?? "")
            currentUser = "\(Amplify.Auth.getCurrentUser()?.username ?? "")"
            if currentUserModel?.userType == UserGroup.employee {
                letEmployeeViewTheirOutings(instructorUsername: Amplify.Auth.getCurrentUser()!.username)
            }
            self.authState = .loadingView
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.authState = .calendar(user: Amplify.Auth.getCurrentUser()!)
            }
        } else {
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
    func changeAuthStateToEventDetails(error: String){
        findUsersInAnOuting(outing: clickedOnOuting)
        authState = .signUpForEvent(error: error)
    }
    func changeAuthStateToCalendar(){
        if let user = Amplify.Auth.getCurrentUser(){
            outingsList = []
            queryOutings()
            authState = .loadingView
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.authState = .calendar(user: user)

            }
        } else {
            authState = .login(error: "")
        }
    }
    func changeAuthStateToAddEvent(error: String){
        queryUserProfileInformation()
        authState = .addEvent(error: error)
    }
    func changeAuthStateToLoading(){
        authState = .loadingView
    }
    func changeAuthStateToUsersList(){
        queryUserProfileInformation()
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
    func changeAuthStateToUserProfileInformationView() {
        authState = .userProfileInformationView
    }
    func changeAuthStateToViewScheduledOutingsView() {
        outingsList = []
        viewUserOutings(user: currentUserModel!)
        print(pastOutings)
        print(idsForPastOutingsList)
        letEmployeeViewTheirOutings(instructorUsername: currentUserModel!.username)
        authState = .viewScheduledOutingsView
    }
    
    func changeAuthStateToSeeEventDetailsAfterSigningUp() {
        authState = .seeEventDetailsAfterSigningUp
    }
    
    func changeAuthStateToSeeUsersInEachOutingView(clickedOnOuting: Outing) {
        findUsersInAnOuting(outing: clickedOnOuting)
        authState = .seeUsersInEachOutingView(clickedOnOuting: clickedOnOuting)
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
                    self?.returnCurrentUserModel(username: username)
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

    

    
    func startFakeNetworkCall() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isLoading = false
        }
    }
    
    func saveUserProfileInformation(username: String, fullname: String, phoneNumber: String, address: String) {
        let detailsToSave = UserDetails(username: username, fullName: fullname, address: address, phoneNumber: phoneNumber, userType: UserGroup.client)
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
            .receive(on: DispatchQueue.main)
            .sink { completed in
                switch completed {
                case .finished:
                    print("finished")
                    
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { querySnapshot in
                for user in querySnapshot.items {
                    print(user.username)
                    if user.username == username {
                        self.currentUserModel = user
                    }
                }
            }
    }
    
    func queryUserProfileInformation () {
        idsForUsersList = []
        userDetailsList = []
        
        self.usersSubscription = Amplify.DataStore.observeQuery(
                    for: UserDetails.self,
                    sort: .ascending(UserDetails.keys.id)
                )
            .receive(on: DispatchQueue.main)
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

                    idsForUsersList.append(id)

                    userDetailsList.append(user)
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
    
    func updateUserProfileInformation(username: String, changeUserType: UserGroup) {
        let u = UserDetails.keys
        self.usersSubscription = Amplify.DataStore.observeQuery(for: UserDetails.self, where: u.username == username)
            .sink { completed in
                switch completed {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { querySnapshot in
                if querySnapshot.items.count > 1 {
                    self.changeAuthStateToLoading()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.changeAuthStateToCalendar()
                    }
                } else {
                    var detailsToUpdate = querySnapshot.items[0]
                    detailsToUpdate.userType = changeUserType
                    Amplify.DataStore.save(detailsToUpdate) { result in
                        switch result {
                        case .success:
                            print("successfully updated!")
                        case .failure(let error):
                            print("error saving: \(error.localizedDescription)")
                        }
                    }
                }
            }
    }
    
    func deleteUser(username: String) {
        let u = UserDetails.keys
        self.usersSubscription = Amplify.DataStore.observeQuery(for: UserDetails.self, where: u.username == username)
            .sink { completed in
                switch completed {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("Error \(error)")
                }
            } receiveValue: { querySnapshot in
                if querySnapshot.items.count > 1 {
                    self.changeAuthStateToLogin(error: "An error occurred. Please try again.")
                } else {
                    let userToDelete = querySnapshot.items[0]
                    Amplify.DataStore.delete(userToDelete) {
                        switch $0 {
                        case .success():
                            self.deleteUserFromCognito(username: username)
                        case .failure(let error):
                            print("error deleting user: \(error.localizedDescription)")
                        }
                    }
                }
            }
    }
    
    func deleteUserFromCognito(username: String) {
        Task { @MainActor in
            do {
                let cognitoIdentityClient = try CognitoIdentityProviderClient(region: "us-west-2")
                let cognitoInputCall = AdminDeleteUserInput(userPoolId: "us-west-2_cQe5CmJ7z", username: username)
                
                _ = try await cognitoIdentityClient.adminDeleteUser(input: cognitoInputCall)
                print("successfully deleted user from cognito!")
            } catch {
                print(error)
            }
        }

    }
    
    func saveOuting(title: String, description: String, location: String, startDate: Date, startTime: Date, endDate: Date, endTime: Date, instructors: [String], programType: [String], maxNumClients: Int) {
        
        if (title == "") || (description == "") || (location == "") || instructors.isEmpty || programType.isEmpty {
            self.changeAuthStateToAddEvent(error: "Error saving outing. Make sure that you input all information.")
        }
        
        
        let sD = Temporal.Date.init(startDate)
        let sT = Temporal.Time.init(startTime)
        let eD = Temporal.Date.init(endDate)
        let eT = Temporal.Time.init(endTime)
        
        let outingToSave = Outing(title: title, description: description, location: location, startDate: sD, startTime: sT, endDate: eD, endTime: eT, instructors: instructors, numClients: maxNumClients, programType: programType)
        
        _ = Amplify.DataStore.save(outingToSave)
            .sink {
                if case let .failure(error) = $0 {
                    print("Error saving outing: \(error)")
                    self.changeAuthStateToAddEvent(error: "Error saving outing. Make sure that you input all information correctly.")
                }
            }
            receiveValue: {
                print("saved outing: \($0)")
            }
    }
    
    func subscribeToOutings() {
        usersSubscription = Amplify.DataStore.publisher(for: Outing.self)
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
    
    
    func queryOutings() {
        self.outingsList = []
        self.outingsSubscription = Amplify.DataStore.observeQuery(for: Outing.self)
            .receive(on: DispatchQueue.main)
            .sink { completed in
                switch completed {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { [self] querySnapshot in
                for outing in querySnapshot.items {
                    outingsList.append(outing)
                }
                print(outingsList.count)
                for outing in outingsList {
                    var listOfOutingsInOneDay: [MyTask] = []
                    let currentDate = outing.startDate.foundationDate
                    
                    for secondOuting in outingsList {
                        if secondOuting.startDate.foundationDate == currentDate {
                            listOfOutingsInOneDay.append(MyTask(title: secondOuting.title, time: secondOuting.startTime.foundationDate, outingModel: secondOuting))
                        }
                    }
                    taskMetaDataList.append(TaskMetaData(task: listOfOutingsInOneDay, taskDate: currentDate))
                }
                
            }
        
    }
    
    func signUpForOuting(outing: Outing, userDetails: UserDetails) {
        let saveUserToOuting = OutingUserDetails(outing: outing, userdetails: userDetails)
        
        userOutingSubscription = Amplify.DataStore.observeQuery(for: Outing.self, where: Outing.keys.title.eq(outing.title))
            .sink { completed in
                switch completed {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("Error \(error)")
                }
            } receiveValue: { querySnapshot in
                if querySnapshot.items.count == 1 {
                    self.findUsersInAnOuting(outing: outing)
                    print(self.usersInAnOutingList)
                    print(self.usersInAnOutingList.count)
                    print(outing.numClients)
                    if self.usersInAnOutingList.count <  outing.numClients {
                        Amplify.DataStore.save(saveUserToOuting) { result in
                            switch result {
                            case .success(let userOuting):
                                print("\(userOuting.userdetails.username) saved to \(userOuting.outing.title)!")
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    } else {
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            self.changeAuthStateToEventDetails(error: "You cannot sign up for this event anymore.")

                        }
                    }
                } else {
                    self.changeAuthStateToLogin(error: "An error occurred.")
                }
            }
    }
    
    func subscribeToUserOutings() {
        userOutingSubscription = Amplify.DataStore.publisher(for: OutingUserDetails.self)
            .sink {
                if case let .failure(error) = $0 {
                    print(error)
                }
            } receiveValue: { changes in
                print("received mutation: \(changes)")
            }
    }
    
    func viewUserOutings(user: UserDetails) {
        
        self.userOutingSubscription = Amplify.DataStore.observeQuery(for: OutingUserDetails.self)
            .receive(on: DispatchQueue.main)
            .sink { completed in
                switch completed {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print(error)
                }
            } receiveValue: { querySnapshot in
                var id1 = 0
                var id2 = 0
                self.idsForPastOutingsList = []
                self.idsForUpcomingOutingsList = []
                self.pastOutings = []
                self.upcomingOutings = []
                
                for result in querySnapshot.items {
                    if (result.userdetails.username == user.username) {
                        if result.outing.startDate.foundationDate >= Date.now {
                            print("upcoming: \(result.outing)")
                            self.upcomingOutings.append(result.outing)
                            self.idsForUpcomingOutingsList.append(id1)
                            id1 += 1
                        } else {
                            self.pastOutings.append(result.outing)
                            print("past: \(result.outing)")
                            self.idsForPastOutingsList.append(id2)
                            id2 += 1
                        }
                    }
                }
            }
        print("past outings: \(self.pastOutings.count)")

    }
    
    func letEmployeeViewTheirOutings(instructorUsername: String) {
        self.idsForPastOutingsList = []
        self.idsForUpcomingOutingsList = []
        self.pastOutings = []
        self.upcomingOutings = []
        
        outingsSubscription = Amplify.DataStore.observeQuery(for: Outing.self)
            .receive(on: DispatchQueue.main)
            .sink { completed in
                switch completed {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("Error \(error)")
                }
            } receiveValue: { querySnapshot in
                var id1 = 0
                var id2 = 0
                for result in querySnapshot.items {
                    let instructors = result.instructors
                    for instructor in instructors {
                        if instructor == instructorUsername {
                            if result.startDate.foundationDate >= Date.now {
                                self.upcomingOutings.append(result)
                                self.idsForUpcomingOutingsList.append(id1)
                                id1 += 1
                            } else {
                                self.pastOutings.append(result)
                                self.idsForPastOutingsList.append(id2)
                                id2 += 1
                            }
                        }
                    }
                }
                print(self.pastOutings.count)
            }
    }
    
    func findUsersInAnOuting(outing: Outing) {
        
        userOutingSubscription = Amplify.DataStore.observeQuery(for: OutingUserDetails.self)
            .receive(on: DispatchQueue.main)
            .sink { completed in
                switch completed {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("Error \(error)")
                }
            } receiveValue: { [self] querySnapshot in
                usersInAnOutingList = []
                idsForUsersInAnOutingList = []
                for result in querySnapshot.items {
                   var  id1 = 0
                    if outing.id == result.outing.id {
                        usersInAnOutingList.append(result.userdetails)
                        idsForUsersInAnOutingList.append(id1)
                        id1 += 1
                    }
                }
            }
    }
    
    func addProgramToUser(programNames: [String], user: UserDetails) {
        let keys = UserDetails.keys
        usersSubscription = Amplify.DataStore.observeQuery(for: UserDetails.self, where: keys.username.contains(user.username))
            .receive(on: DispatchQueue.main)
            .sink { completed in
                switch completed {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("Error \(error)")
                }
            } receiveValue: { [self] querySnapshot in
                if querySnapshot.items.count == 1 {
                    var userToUpdate = querySnapshot.items.first
                    userToUpdate?.programType = []
                    userToUpdate?.programType.append(contentsOf: programNames)
                    
                    if userToUpdate != nil {
                        Amplify.DataStore.save(userToUpdate!) { result in
                            switch result {
                            case .success:
                                print("\(userToUpdate!.username) is part of \(String(describing: userToUpdate?.programType))!")
                            case .failure(let error):
                                print(error.localizedDescription)
                            }
                        }
                    }

                } else {
                    changeAuthStateToLogin(error: "An error occurred.")
                }
            }

    }
    
    
}
//
//type Outing @model @auth(rules: [{allow: public}]) {
//  id: ID!
//  title: String!
//  description: String!
//  location: String!
//  startDate: AWSDate!
//  startTime: AWSTime!
//  endDate: AWSDate!
//  endTime: AWSTime!
//  instructors: [String!]!
//  numClients: Int!
//  programType: [String!]!
//  OutingUserDetails: [OutingUserDetails] @connection(keyName: "byOuting", fields: ["id"])
//}
//
//enum UserGroup {
//  ADMIN
//  EMPLOYEE
//  CLIENT
//}
//
//type UserDetails @model @auth(rules: [{allow: public}]) {
//  id: ID!
//  username: String!
//  fullName: String!
//  address: String!
//  programType: [String!]!
//  phoneNumber: String!
//  userType: UserGroup
//  outings: [OutingUserDetails] @connection(keyName: "byUserDetails", fields: ["id"])
//}
//
//type OutingUserDetails @model(queries: null) @key(name: "byOuting", fields: ["outingID", "userdetailsID"]) @key(name: "byUserDetails", fields: ["userdetailsID", "outingID"]) @auth(rules: [{allow: public}]) {
//  id: ID!
//  outingID: ID!
//  userdetailsID: ID!
//  outing: Outing! @connection(fields: ["outingID"])
//  userdetails: UserDetails! @connection(fields: ["userdetailsID"])
//}
