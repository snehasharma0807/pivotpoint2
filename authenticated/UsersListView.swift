//
//  UsersListView.swift
//  authenticated
//
//  Created by Sneha Sharma on 8/2/22.
//

import Foundation
import SwiftUI
import Amplify


struct UsersListView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    var body: some View {
        VStack {
            Text("Users")
                .bold()
                .foregroundColor(Color("BlueGray"))
                .font(.system(size: 35))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            

            if sessionManager.idsForUsersList.count == 1 {
                Button {
                    sessionManager.clickedOnUserDetails = UserDetails(username: sessionManager.userDetailsList.first!.username, fullName: sessionManager.userDetailsList.first!.fullName, address: sessionManager.userDetailsList.first!.address, programType: sessionManager.userDetailsList.first!.programType, phoneNumber: sessionManager.userDetailsList.first!.phoneNumber, userType: sessionManager.userDetailsList.first!.userType)
                    print(sessionManager.clickedOnUserDetails.programType)
                    sessionManager.changeAuthStateToUserProfileInformationView()
                } label: {
                    HStack {
                        VStack {
                            Text(sessionManager.userDetailsList.first!.username)
                                .font(.system(size: 20))
                                .foregroundColor(Color("BlueGray"))
                                .padding()
                            Text(sessionManager.userDetailsList.first!.phoneNumber)
                                .font(.system(size: 15))
                                .foregroundColor(Color("BlueGray"))
                        }
                        Spacer()
                        Text(sessionManager.userDetailsList.first!.username)
                            .font(.system(size: 20))
                            .foregroundColor(Color("BlueGray"))
                    }.padding(5)
                }
            } else {
                List(sessionManager.idsForUsersList, id: \.self) { id in
                    Button {
                        sessionManager.clickedOnUserDetails = UserDetails(username: sessionManager.userDetailsList[id].username, fullName: sessionManager.userDetailsList[id].fullName, address: sessionManager.userDetailsList[id].address, programType: sessionManager.userDetailsList[id].programType, phoneNumber: sessionManager.userDetailsList[id].phoneNumber, userType: sessionManager.userDetailsList[id].userType)
                        print(sessionManager.clickedOnUserDetails)
                        sessionManager.changeAuthStateToUserProfileInformationView()
                    } label: {
                        ListRow(username: sessionManager.userDetailsList[id].username, userType: sessionManager.userDetailsList[id].userType.rawValue, phoneNumber: sessionManager.userDetailsList[id].phoneNumber)
                    }

                }.refreshable {
                    sessionManager.queryUserProfileInformation()
                }
            }

            
            Button {
                sessionManager.changeAuthStateToCalendar()
            } label: {
                Text("Go to Home")
                    .padding(.horizontal, 100)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(Color("BlueGray"))
                    .shadow(color: .gray, radius: 5, x: 4, y: 4)
                    .offset(y: 20)
                    .padding(.bottom, 20)
            }
            Spacer()
        }
    }
}


struct ListRow: View {
    let username: String
    let userType: String
    let phoneNumber: String
    
    var body: some View {
        
        HStack {
            VStack {
                Text(username)
                    .font(.system(size: 20))
                    .foregroundColor(Color("BlueGray"))
                Spacer()
                Text(phoneNumber)
                    .font(.system(size: 15))
                    .foregroundColor(Color("BlueGray"))
            }
            Spacer()
            Text(userType)
                .font(.system(size: 20))
                .foregroundColor(Color("BlueGray"))
        }.padding(5)
    }
}
