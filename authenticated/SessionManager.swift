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
import AWSPinpointEmail
import AWSPinpoint
import UserNotifications




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
    @Published var currentUserModel: UserDetails = UserDetails(username: "", fullName: "", address: "", phoneNumber: "", userType: UserGroup.client)
    @Published var idsForUsersList: [Int] = []
    var usersSubscription: AnyCancellable?
    var outingsSubscription: AnyCancellable?
    var userOutingSubscription: AnyCancellable?
    @Published var userDetailsList: [UserDetails] = []
    var clickedOnUserDetails: UserDetails = UserDetails(username: "", fullName: "", address: "", programType: [], phoneNumber: "", userType: UserGroup.client)
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
            queryOutings(programList: self.currentUserModel.programType, currentUserGroup: self.currentUserModel.userType )
            returnCurrentUserModel(username: Amplify.Auth.getCurrentUser()?.username ?? "")
            print(currentUserModel.userType )
            currentUser = "\(Amplify.Auth.getCurrentUser()?.username ?? "")"
            if currentUserModel.userType == UserGroup.employee {
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
            authState = .loadingView
            queryOutings(programList: self.currentUserModel.programType, currentUserGroup: currentUserModel.userType)
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
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
        viewUserOutings(user: currentUserModel)
        print(upcomingOutings)
        print(pastOutings)
        print(pastOutings)
        print(idsForPastOutingsList)
        letEmployeeViewTheirOutings(instructorUsername: currentUserModel.username)
        authState = .viewScheduledOutingsView
    }
    
    func changeAuthStateToSeeEventDetailsAfterSigningUp() {
        authState = .seeEventDetailsAfterSigningUp
    }
    
    func changeAuthStateToSeeUsersInEachOutingView(clickedOnOuting: Outing) {
        findUsersInAnOuting(outing: clickedOnOuting)
        authState = .seeUsersInEachOutingView(clickedOnOuting: clickedOnOuting)
    }
    


    //sign up a new user
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
    
    //confirm the email
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
    
    //login
    func login(username: String, password: String) {
        _ = Amplify.Auth.signIn(
            username: username,
            password: password
        ) {[weak self] result in
            
            switch result{
            case .success(let signInResult):
                print(signInResult)
                if signInResult.isSignedIn{
                    _ = Amplify.DataStore.clear()
                    self?.getCurrentAuthUser()
                }
                
            case .failure(let error):
                var the_error: String = ""
                print("Error: " , error.errorDescription)
                if error.errorDescription == "Username is required to signIn"{
                    the_error = "Username is required to sign in"
                } else if error.errorDescription == "There is already a user which is signed in. Please log out the user before calling showSignIn." {
                    self?.signOut()
                    the_error = "Please try again."
                } else{
                    the_error = error.errorDescription
                }
                DispatchQueue.main.async{
                        self?.changeAuthStateToLogin(error: the_error)
                    }
            }
        }
    }
    
    //sign out
    func signOut(){
        _ = Amplify.Auth.signOut{ [weak self] result in
            switch result{
            case .success:
                _ = Amplify.DataStore.clear()
                DispatchQueue.main.async {
                    self?.getCurrentAuthUser()
                }
                print("user has been signed out")
            case .failure(let error):
                print("Sign out error: ", error)
            }
        }
    }
    
    //reset password
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
    
    //confirm that you wanna reset your password
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

    //set timer for the loadingview
    func startFakeNetworkCall() {
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isLoading = false
        }
    }
    
    //save information to user profile (username, fullname, phonenumber, etc.). sets default to usertype
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
    
    
    //used in updateUserGroup()
    //returns the current user's information
    func returnCurrentUserModel (username: String) {
        print("username: \(username)")
        self.usersSubscription = Amplify.DataStore.observeQuery(for: UserDetails.self, where: UserDetails.keys.username.eq(username))
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
                        print(user)
                        self.queryOutings(programList: user.programType, currentUserGroup: user.userType)
                    }
                }
            }
    }
    
    
    //querys ALL of the users' profile information (displayed on screen)
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
    
    
    //realtime updates
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
    
    //change the user's group
    func updateUserGroup(username: String, changeUserType: UserGroup) {
        let u = UserDetails.keys
        self.usersSubscription = Amplify.DataStore.observeQuery(for: UserDetails.self, where: u.username == username)
            .receive(on: DispatchQueue.main)
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
    
    //deletes a user's profile information
    func deleteUser(username: String) {
        let u = UserDetails.keys
        self.usersSubscription = Amplify.DataStore.observeQuery(for: UserDetails.self, where: u.username == username)
            .receive(on: DispatchQueue.main)
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
    
    //deletes a user from cognito
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
    
    
    //saves a new outing
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
    receiveValue: { [self] in
                print("saved outing: \($0)")
                for instructor in instructors {
                    sendNotificationToEmployeeInOuting(username: instructor, fullName: instructor, titleOfOuting: title, outingDate: sD)
                }
                
            }
    }
    
    //outings realtime updates
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
    
    //querying outings (and filtering them based on program IF you are a client)
    func queryOutings(programList: [String], currentUserGroup: UserGroup) {
        if currentUserGroup == UserGroup.client {
            let keys = Outing.keys.programType
            var predicateList: [QueryPredicate] = []
            print(programList)
            for program in programList {
                predicateList.append(keys.contains(program))
                print(program)
            }
            
            let x =  QueryPredicateGroup(type: .or, predicates: predicateList)
            self.outingsSubscription = Amplify.DataStore.observeQuery(for: Outing.self, where: x)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completed in
                    switch completed {
                    case .finished:
                        print("finished")
                    case .failure(let error):
                        print("ERROR ERROR ERROR" + error.errorDescription)
                    }
                }, receiveValue: { [self] querySnapshot in
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
                    self.authState = .loadingView
                        
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.authState = .calendar(user: Amplify.Auth.getCurrentUser()!)
                    }
                    
                })
        } else if ((currentUserGroup == UserGroup.admin) || (currentUserGroup == UserGroup.employee)){
            self.outingsSubscription = Amplify.DataStore.observeQuery(for: Outing.self)
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completed in
                    switch completed {
                    case .finished:
                        print("finished")
                    case .failure(let error):
                        print("ERROR ERROR ERROR" + error.errorDescription)
                    }
                }, receiveValue: { [self] querySnapshot in
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
                    self.authState = .loadingView
                        
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        self.authState = .calendar(user: Amplify.Auth.getCurrentUser()!)
                    }
                })
            
        }
        
    }
    
    //clients sign up for an outing
    func signUpForOuting(outing: Outing, userDetails: UserDetails, waitingList: Bool) {
        
        let saveUserToOuting = UserDetailsOuting(userdetails: userDetails, outing: outing, isOnWaitingList: waitingList)
        
        userOutingSubscription = Amplify.DataStore.observeQuery(for: Outing.self, where: Outing.keys.title.eq(outing.title))
            .receive(on: DispatchQueue.main)
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
                    Amplify.DataStore.save(saveUserToOuting) { [self] result in
                        switch result {
                        case .success(let userOuting):
                            print("\(userOuting.userdetails.username) saved to \(userOuting.outing.title)!")
                            sendConfirmationPushNotification(titleOfOuting: userOuting.outing.title)
                            addNotificationForEventReminder(username: userOuting.userdetails.username, fullName: userOuting.userdetails.fullName, titleOfOuting: userOuting.outing.title, outingDate: userOuting.outing.startDate)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                } else {
                    self.changeAuthStateToLogin(error: "An error occurred.")
                }
            }
    }
    
    func subscribeToUserOutings() {
        userOutingSubscription = Amplify.DataStore.publisher(for: UserDetailsOuting.self)
            .sink {
                if case let .failure(error) = $0 {
                    print(error)
                }
            } receiveValue: { changes in
                print("received mutation: \(changes)")
            }
    }
    
    //view outings in a user
    func viewUserOutings(user: UserDetails) {
        
        self.userOutingSubscription = Amplify.DataStore.observeQuery(for: UserDetailsOuting.self, where: UserDetailsOuting.keys.isOnWaitingList.eq(false))
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
                        print(result.outing.title)
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

    }
    
    //employees can view their outings
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
    
    //view users in an outing
    func findUsersInAnOuting(outing: Outing) {
        
        userOutingSubscription = Amplify.DataStore.observeQuery(for: UserDetailsOuting.self)
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
    
    
    //add a program to a user
    func addProgramToUser(user: UserDetails, programNames: [String]) {
        let u = UserDetails.keys
        self.usersSubscription = Amplify.DataStore.observeQuery(for: UserDetails.self, where: u.username == user.username)
            .receive(on: DispatchQueue.main)
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
                    if (querySnapshot.items.count != 0) {
                        var detailsToUpdate = querySnapshot.items[0]
                        detailsToUpdate.programType = []
                        detailsToUpdate.programType = programNames
                        Amplify.DataStore.save(detailsToUpdate) { result in
                            switch result {
                            case .success(let user):
                                print("successfully updated!")
                                print("added these programs: \(user.programType) to this user: \(user.username)")
                            case .failure(let error):
                                print("error saving: \(error.localizedDescription)")
                            }
                        }
                    }
                    
                }
            }
    }
    
    func userWaitingList(username: String) {
        userOutingSubscription = Amplify.DataStore.observeQuery(for: UserDetailsOuting.self, where: UserDetailsOuting.keys.isOnWaitingList.eq(true))
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completed in
                switch completed {
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("error in adding to the waiting list: \(error)")
                }
            }, receiveValue: { snapshot in
                for result in snapshot.items {
                    if result.userdetails.username == username {
                        print("\(result.userdetails.username) is on the waiting list for \(result.outing.title)")
                    }
                }
            })
    }
    
    func addNotificationForEventReminder(username: String, fullName: String, titleOfOuting: String, outingDate: Temporal.Date) {
        
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "\(titleOfOuting) is happening tomorrow!"
        content.body = "Hey \(fullName)! A reminder that you are scheduled to attend \(titleOfOuting) tomorrow! Click here to learn more."
        content.sound = UNNotificationSound.default

        // Setup trigger time
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let date = outingDate.foundationDate
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year
        let month = components.month
        let day = components.day! - 1
        
        
        var dateInfo = DateComponents()
        dateInfo.day = day //Put your day
        dateInfo.month = month //Put your month
        dateInfo.year = year // Put your year
        dateInfo.hour = 0 //Put your hour
        dateInfo.minute = 0 //Put your minutes
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)

        // Create request
        let uniqueID = "\(username).\(titleOfOuting)"
        let request = UNNotificationRequest(identifier: uniqueID, content: content, trigger: trigger)
        center.add(request) // Add the notification request
    }
    
    func sendNotificationToEmployeeInOuting(username: String, fullName: String, titleOfOuting: String, outingDate: Temporal.Date) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "\(titleOfOuting) is happening tomorrow!"
        content.body = "Hey \(fullName)! A reminder that you are leading \(titleOfOuting) tomorrow! Click here to learn more."
        content.sound = UNNotificationSound.default

        // Setup trigger time
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        let date = outingDate.foundationDate
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        let year = components.year
        let month = components.month
        let day = components.day
        
        
        var dateInfo = DateComponents()
        dateInfo.day = day //Put your day
        dateInfo.month = month //Put your month
        dateInfo.year = year // Put your year
        dateInfo.hour = 0 //Put your hour
        dateInfo.minute = 0 //Put your minutes
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateInfo, repeats: false)

        // Create request
        let uniqueID = "\(username).\(titleOfOuting)"
        let request = UNNotificationRequest(identifier: uniqueID, content: content, trigger: trigger)
        center.add(request) // Add the notification request
    }
    
    func sendConfirmationPushNotification(titleOfOuting: String) {
        let center = UNUserNotificationCenter.current()

        let content = UNMutableNotificationContent()
        content.title = "You have successfully signed up for \(titleOfOuting)"
        content.body = "Click here to learn more."
        content.sound = UNNotificationSound.default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest.init(identifier: "localNotificatoin", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}
