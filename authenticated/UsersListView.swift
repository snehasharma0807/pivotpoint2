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
    @State private var searchText = ""
    
    
    var body: some View {
        VStack {
            Text("Users")
                .bold()
                .foregroundColor(Color("BlueGray"))
                .font(.system(size: 35))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            SearchBar(text: $searchText)
            
            Button {
                sessionManager.queryUserProfileInformation()
                print(sessionManager.usersList)
            } label: {
                Text("View Users")
            }

            if (sessionManager.usersList.isEmpty == false) {
                List(sessionManager.idsForUsersList, id: \.self) { id in
                    ListRow(username: sessionManager.usersList[id], group: "", phoneNumber: sessionManager.userPhoneNumberList[id])
                }
                .refreshable {
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
    let group: String
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
            Text(group)
                .font(.system(size: 20))
                .foregroundColor(Color("BlueGray"))
        }.padding(10)
    }
}

struct SearchBar: View {
    @Binding var text: String
 
    @State private var isEditing = false
 
    var body: some View {
        HStack {
 
            TextField("Search ...", text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .padding(.horizontal, 10)
                .onTapGesture {
                    self.isEditing = true
                }
 
            if isEditing {
                Button(action: {
                    self.isEditing = false
                    self.text = ""
 
                }) {
                    Text("Cancel")
                }
                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
                .animation(.default)

            }
        }
    }
}
