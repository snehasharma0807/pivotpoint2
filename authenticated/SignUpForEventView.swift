//
//  SignUpForEventView.swift
//  authenticated
//
//  Created by Sneha Sharma on 4/12/22.
//

import Foundation
import SwiftUI
import Amplify

struct SignUpForEventView: View{
    @EnvironmentObject var sessionManager: SessionManager
    @State var eventName: String = ""
    @State var eventDetails: String = ""
    @State var eventDate: String = ""
    @State var eventTime: String = ""
    @State var eventLocation: String = ""
    @State var eventInstructor: String = ""
    @State private var showingAlert = false
    var error: String
    
    var alreadyScheduled = false
    
    init(alreadyScheduled: Bool) {
        self.alreadyScheduled = alreadyScheduled
        error = ""

    }
    init () {
        error = ""
    }
    init(error: String) {
        self.error = error
    }


    var body: some View{

        VStack{
            Group {
                if (error != ""){
                    Text(error)
                        .bold()
                        .foregroundColor(.red)
                } else{
                    Text("")
                }
                
                Text("\(sessionManager.clickedOnOuting.title)")
                    .bold()
                    .foregroundColor(Color("BlueGray"))
                    .font(.system(size: 35))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 30)
                    .padding(.top, 35)
                
                if (sessionManager.clickedOnOuting.programType.count == 1) {
                    Text("Program: \(sessionManager.clickedOnOuting.programType.first ?? "")")
                        .foregroundColor(Color("BlueGray"))
                        .font(.system(size: 15))
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    Text("Programs: \(sessionManager.clickedOnOuting.programType.joined(separator: ", "))")
                        .foregroundColor(Color("BlueGray"))
                        .font(.system(size: 15))
                        .multilineTextAlignment(.center)
                        .padding()
                }
                
                Text("\(sessionManager.clickedOnOuting.description)")
                    .italic()
                    .foregroundColor(Color("BlueGray"))
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 35)
                
                if (sessionManager.clickedOnOuting.startDate == sessionManager.clickedOnOuting.endDate) {
                    //same date
                    Text("**Date:** \(sessionManager.clickedOnOuting.startDate.iso8601FormattedString(format: .short))")
                        .foregroundColor(Color("BlueGray"))
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    Text("**Start Time:** \(sessionManager.clickedOnOuting.startTime.iso8601FormattedString(format: .short))")
                        .foregroundColor(Color("BlueGray"))
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    Text("**End Time:** \(sessionManager.clickedOnOuting.endTime.iso8601FormattedString(format: .short))")
                        .foregroundColor(Color("BlueGray"))
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                } else if (sessionManager.clickedOnOuting.startDate != sessionManager.clickedOnOuting.endDate){
                    //not same date
                    Text("**Starts on:** \(sessionManager.clickedOnOuting.startDate.iso8601FormattedString(format: .short)) at \(sessionManager.clickedOnOuting.startTime.iso8601FormattedString(format: .short))")
                        .foregroundColor(Color("BlueGray"))
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    Text("**Ends on:** \(sessionManager.clickedOnOuting.endDate.iso8601FormattedString(format: .short)) at \(sessionManager.clickedOnOuting.endTime.iso8601FormattedString(format: .short))")
                        .foregroundColor(Color("BlueGray"))
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                

                Text("**Location:** \(sessionManager.clickedOnOuting.location)")
                    .foregroundColor(Color("BlueGray"))
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                if sessionManager.clickedOnOuting.instructors.count == 1 {
                    Text("**Instructor:** \(sessionManager.clickedOnOuting.instructors.joined(separator: ", "))")
                        .foregroundColor(Color("BlueGray"))
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 35)
                } else {
                    Text("**Instructors:** \(sessionManager.clickedOnOuting.instructors.joined(separator: ", "))")
                        .foregroundColor(Color("BlueGray"))
                        .font(.system(size: 20))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 35)
                }
            }
            
            
            if ((sessionManager.clickedOnOuting.numClients)-(sessionManager.usersInAnOutingList.count) < 0) {
                Text("0/\(sessionManager.clickedOnOuting.numClients) Spaces Available")
                    .foregroundColor(Color("BlueGray"))
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 35)
            } else {
                Text("\((sessionManager.clickedOnOuting.numClients)-(sessionManager.usersInAnOutingList.count))/\(sessionManager.clickedOnOuting.numClients) Spaces Available")
                    .foregroundColor(Color("BlueGray"))
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 35)
            }
            
            if sessionManager.currentUserModel.userType == UserGroup.admin {
                Button {
                    showingAlert = true
                } label: {
                    Text("Delete this Event.")
                        .padding(.horizontal, 100)
                        .padding(.vertical, 10)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .shadow(color: .gray, radius: 5, x: 4, y: 4)
                        .offset(y: 20)
                        .padding(.bottom, 20)
                }
                .alert("Are you sure that you want to delete this event. This cannot be undone.", isPresented: $showingAlert, actions: {
                    Button("Yes, I'm sure.", role: .destructive) {
                        sessionManager.deleteOuting(outing: sessionManager.clickedOnOuting)
                        sessionManager.changeAuthStateToCalendar()
                    }; Button("Nevermind!", role: .cancel) {}})
            } else {
                if alreadyScheduled == false {
                    if ((sessionManager.clickedOnOuting.numClients)-(sessionManager.usersInAnOutingList.count) != 0) {
                        Button {
                            showingAlert = true
                        } label: {
                            Text("Sign Up")
                                .padding(.horizontal, 100)
                                .padding(.vertical, 10)
                                .foregroundColor(.white)
                                .background(Color("BlueGray"))
                                .shadow(color: .gray, radius: 5, x: 4, y: 4)
                                .offset(y: 20)
                                .padding(.bottom, 20)
                        }
                        .alert("Are you sure that you want to sign up for this event?", isPresented: $showingAlert, actions: {
                            Button("Yes, I'm sure.", role: .cancel) {
                                sessionManager.signUpForOuting(outing: sessionManager.clickedOnOuting, userDetails: sessionManager.currentUserModel, waitingList: false)
                                sessionManager.changeAuthStateToCalendar()
                            }; Button("Nevermind!", role: .destructive) {}})
                    } else {
                        Button {
                            showingAlert = true
                        } label: {
                            Text("Join Waiting List")
                                .padding(.horizontal, 100)
                                .padding(.vertical, 10)
                                .foregroundColor(.white)
                                .background(Color("BlueGray"))
                                .shadow(color: .gray, radius: 5, x: 4, y: 4)
                                .offset(y: 20)
                                .padding(.bottom, 20)
                        }
                        .alert("Are you sure that you want to join the waiting list?", isPresented: $showingAlert, actions: {
                            Button("Yes, I'm sure.", role: .cancel) {
                                sessionManager.signUpForOuting(outing: sessionManager.clickedOnOuting, userDetails: sessionManager.currentUserModel, waitingList: true)
                                sessionManager.changeAuthStateToCalendar()
                            }; Button("Nevermind!", role: .destructive) {}})
                    }

                } else {
                    Button {
                        showingAlert = true
                    } label: {
                        Text("Leave Event")
                            .padding(.horizontal, 100)
                            .padding(.vertical, 10)
                            .foregroundColor(.white)
                            .background(Color.red)
                            .shadow(color: .gray, radius: 5, x: 4, y: 4)
                            .offset(y: 20)
                            .padding(.bottom, 20)
                    }
                    .alert("Are you sure that you want to leave this event?. This cannot be undone.", isPresented: $showingAlert, actions: {
                        Button("Yes, I'm sure.", role: .destructive) {
                            sessionManager.userLeavesOuting(user: sessionManager.currentUserModel, outing: sessionManager.clickedOnOuting)
                            sessionManager.changeAuthStateToCalendar()
                        }; Button("Nevermind!", role: .cancel) {}})
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
        }.padding()

    }
}
