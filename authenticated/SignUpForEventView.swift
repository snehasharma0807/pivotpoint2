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


    var body: some View{
        VStack{
            Text("\(eventName)")
                .bold()
                .foregroundColor(Color("BlueGray"))
                .font(.system(size: 35))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.bottom, 30)
                .padding(.top, 35)
            
            Text("\(eventDetails)")
                .italic()
                .foregroundColor(Color("BlueGray"))
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.bottom, 35)
            Text("**Date:** \(eventDate)")
                .foregroundColor(Color("BlueGray"))
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            Text("**Time:** \(eventTime)")
                .foregroundColor(Color("BlueGray"))
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            Text("**Location:** \(eventLocation)")
                .foregroundColor(Color("BlueGray"))
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            Text("**Instructor:** \(eventInstructor)")
                .foregroundColor(Color("BlueGray"))
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.bottom, 35)
            Button {
                //code for signup confirmation screen here
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

