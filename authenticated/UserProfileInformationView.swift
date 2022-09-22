//
//  UserProfileInformationView.swift
//  authenticated
//
//  Created by Sneha Sharma on 8/17/22.
//

import Foundation
import SwiftUI
import Amplify

struct UserProfileInformationView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @State private var showingAlert = false


    var body: some View {
        VStack {
            
            UserDisplay(fullname: sessionManager.clickedOnUserDetails.fullName , username: sessionManager.clickedOnUserDetails.username , userType: sessionManager.clickedOnUserDetails.userType?.rawValue ?? "CLIENT" , phoneNumber: sessionManager.clickedOnUserDetails.phoneNumber , address: sessionManager.clickedOnUserDetails.address , programType: sessionManager.clickedOnUserDetails.programType )
            
            if (sessionManager.clickedOnUserDetails.userType == UserGroup.client) {
                
            }
            
            Button {
                sessionManager.changeAuthStateToUsersList()
            } label: {
                Text("Go Back")
                    .padding(.horizontal, 100)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(Color("BlueGray"))
                    .shadow(color: .gray, radius: 5, x: 4, y: 4)
                    .offset(y: 20)
                    .padding(.bottom, 20)
            }
            
            Button {
                showingAlert = true
            } label: {
                Text("Delete User")
                    .padding(.horizontal, 100)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(Color(red: 0.729, green: 0, blue: 0.086)) // #ba0016
                    .shadow(color: .gray, radius: 5, x: 4, y: 4)
                    .offset(y: 20)
                    .padding(.bottom, 20)
            }
            .alert("Are you sure that you want to delete \(sessionManager.clickedOnUserDetails.fullName)?", isPresented: $showingAlert, actions: {
                Button("Yes, I'm sure.", role: .destructive) {
                    sessionManager.deleteUser(username: sessionManager.clickedOnUserDetails.username)
                    sessionManager.changeAuthStateToCalendar()
                }}, message: {
                    Text("This cannot be undone.")
                })
            


        }
    }
}

struct UserDisplay: View {
    @EnvironmentObject var sessionManager: SessionManager

    let fullname: String
    let username: String
    let userType: String
    let phoneNumber: String
    let address: String
    let programType: [String]
    
    
    var body: some View {
        Text("View Information for \(fullname)")
            .bold()
            .foregroundColor(Color("BlueGray"))
            .font(.system(size: 35))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.bottom, 30)
        
        GroupBox {
            DisclosureGroup {
                Button {
                    sessionManager.updateUserProfileInformation(username: sessionManager.clickedOnUserDetails.username, changeUserType: UserGroup.admin)
                    sessionManager.changeAuthStateToCalendar()
                    print("updated to admin")
                } label: {
                    Text("Update to Admin")
                        .bold()
                        .foregroundColor(Color("GreyGreen"))
                        .font(.system(size: 20))
            //            .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.top, 10)
                }

                Button {
                    sessionManager.updateUserProfileInformation(username: sessionManager.clickedOnUserDetails.username, changeUserType: UserGroup.employee)
                    sessionManager.changeAuthStateToCalendar()
                    print("updated to employee")
                } label: {
                    Text("Update to Employee")
                        .bold()
                        .foregroundColor(Color("GreyGreen"))
                        .font(.system(size: 20))
            //            .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
//                        .padding(.bottom, 20)
                }

                Button {
                    sessionManager.updateUserProfileInformation(username: sessionManager.clickedOnUserDetails.username, changeUserType: UserGroup.client)
                    sessionManager.changeAuthStateToCalendar()
                    print("updated to employee")
                } label: {
                    Text("Update to Client")
                        .bold()
                        .foregroundColor(Color("GreyGreen"))
                        .font(.system(size: 20))
            //            .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
//                        .padding(.bottom, 20)
                }
            } label: {
                Text("User Type: \(userType.pascalCased()) (Click to change)")
                    .foregroundColor(Color("BlueGray"))
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
//                    .padding(.horizontal, 20)
            }
            
        }
        
        
        
        

        
        Text("Username: \(username)")
            .foregroundColor(Color("BlueGray"))
            .font(.system(size: 20))
//            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        Text("Full name: \(fullname)")
            .foregroundColor(Color("BlueGray"))
            .font(.system(size: 20))
//            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        Text("Address: \(address)")
            .foregroundColor(Color("BlueGray"))
            .font(.system(size: 20))
//            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
        Text("Phone Number: \(phoneNumber)")
            .foregroundColor(Color("BlueGray"))
            .font(.system(size: 20))
//            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)

        
    }
}
