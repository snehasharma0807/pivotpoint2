//
//  CalendarView.swift
//  authenticated
//
//  Created by Sneha Sharma on 4/13/22.
//

//what you see when you log into the app (calendar)

import Amplify
import SwiftUI


struct CalendarView: View{

    @EnvironmentObject var sessionManager: SessionManager
    let user: AuthUser
    @State var currentDate: Date = Date()
    
    var body: some View{
        ScrollView(.vertical, showsIndicators: false){
            VStack(spacing: 20){
                HStack{
                    Image(systemName:  "person.crop.circle")
                        .resizable()
                        .frame(width: 40, height: 40)
                    Text("Welcome \(user.username)!")
                        .fontWeight(.semibold)
                        .font(.title)
                        .foregroundColor(Color("BlueGray"))

                }
                //Custom date picker
                CustomDatePicker(currentDate: $currentDate)
                    .refreshable {
                        sessionManager.queryOutings()
                    }
            }
            .padding(.vertical)
        }
        //Safe area view
        
        .safeAreaInset(edge: .bottom){
            ScrollView(.horizontal){
                HStack{

                    Button{
                        sessionManager.signOut()
                    } label: {
                        Text("Log out")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color( "BlueGray"), in: Rectangle())
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 5, x: 4, y: 4)
                            .foregroundColor(.white)
                    }
                    Button {
                        sessionManager.changeAuthStateToUpdateProfileInformation()
                    } label: {
                        Text("Profile Information")
                            .fontWeight(.bold)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color( "BlueGray"), in: Rectangle())
                            .cornerRadius(5)
                            .shadow(color: .gray, radius: 5, x: 4, y: 4)
                            .foregroundColor(.white)
                    }

                    if (sessionManager.currentUserModel?.userType == UserGroup.admin){
                        Button{
                            sessionManager.changeAuthStateToAddEvent(error: "")
                        } label: {
                            Text("Add Outing")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color( "BlueGray"), in: Rectangle())
                                .cornerRadius(5)
                                .shadow(color: .gray, radius: 5, x: 4, y: 4)
                                .foregroundColor(.white)
                        }
                        

                        Button {
                            sessionManager.changeAuthStateToUsersList()
                        } label: {
                            Text("View Users")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color( "BlueGray"), in: Rectangle())
                                .cornerRadius(5)
                                .shadow(color: .gray, radius: 5, x: 4, y: 4)
                                .foregroundColor(.white)
                        }
                        
                        
                    }


                    if(sessionManager.currentUserModel?.userType == UserGroup.employee) {
                        Button {
                            
                        } label: {
                            Text("View My Outings")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color( "BlueGray"), in: Rectangle())
                                .cornerRadius(5)
                                .shadow(color: .gray, radius: 5, x: 4, y: 4)
                                .foregroundColor(.white)
                        }

                    }
                    if(sessionManager.currentUserModel?.userType == UserGroup.client) {
                        Button {
                            sessionManager.changeAuthStateToViewScheduledOutingsView()
                        } label: {
                            Text("View Scheduled Outings")
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color( "BlueGray"), in: Rectangle())
                                .cornerRadius(5)
                                .shadow(color: .gray, radius: 5, x: 4, y: 4)
                                .foregroundColor(.white)
                        }

                    }
                    

                    
                }

                }
                .padding(.bottom, 10)
                .padding(.horizontal)
                .padding(.top, 10)
                .background(.ultraThinMaterial)
            
            }
        }

}
