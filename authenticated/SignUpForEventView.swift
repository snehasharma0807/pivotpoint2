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
    @State var eventName: String = "Event Name"
    @State var eventDetails: String = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Donec massa sapien faucibus et molestie. Sit amet consectetur adipiscing elit."
    @State var eventDate: String = "August 23, 2022"
    @State var eventTime: String = "10:00-11:00"
    @State var eventLocation: String = "243 Argle St. Saint Joseph, MI 49085"
    @State var eventInstructor: String = "Event Name"
    @State private var showingAlert = false



    var body: some View{
        VStack{
            Text("\(sessionManager.clickedOnOuting.title)")
                .bold()
                .foregroundColor(Color("BlueGray"))
                .font(.system(size: 35))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .padding(.top, 35)
            
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
                Text("**Instructor:** \(sessionManager.stringInstructors)")
                    .foregroundColor(Color("BlueGray"))
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 35)
            } else {
                Text("**Instructors:** \(sessionManager.stringInstructors)")
                    .foregroundColor(Color("BlueGray"))
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 35)
            }
            

            
            
            

            Button {
                //code for signup confirmation screen here
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
                    
                }; Button("Nevermind!", role: .destructive) {}})

            
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
