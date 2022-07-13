//
//  AddEventView.swift
//  authenticated
//
//  Created by Sneha Sharma on 5/8/22.
//

import SwiftUI


struct AddEventView: View{
    @EnvironmentObject var sessionManager: SessionManager
    @State var eventName: String
    @State var eventDetails: String
    @State var eventDate: Date
    @State var eventTime: Date
    @State var eventLocation: String
    @State var eventInstructor: String
    var body: some View{
        VStack{
            Text("Add an Outing")
                .bold()
                .foregroundColor(Color("BlueGray"))
                .font(.system(size: 35))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            Group{
                VStack{
                    TextField("Event Name...", text: $eventName)
                        .foregroundColor(Color("BlueGray"))
                        .padding(.horizontal, 30)
                    Divider()
                        .background(Color("BlueGray"))
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                    TextField("Details...", text: $eventDetails)
                        .foregroundColor(Color("BlueGray"))
                        .padding(.horizontal, 30)
                    Divider()
                        .background(Color("BlueGray"))
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                    DatePicker(
                        "Date",
                        selection: $eventDate,
                        displayedComponents: [.date]
                    )
                        .foregroundColor(Color("BlueGray"))
                        .padding(.horizontal, 30)
                }


            }
            
            DatePicker(
                "Time",
                selection: $eventTime,
                displayedComponents: [.hourAndMinute]
            )
                .foregroundColor(Color("BlueGray"))
                .padding(.horizontal, 30)
            
            TextField("Location...", text: $eventLocation)
                .foregroundColor(Color("BlueGray"))
                .padding(.horizontal, 30)
                .padding(.top, 20)
            Divider()
                .background(Color("BlueGray"))
                .padding(.horizontal, 30)
                .padding(.bottom, 20)
            
            TextField("Instructor...", text: $eventInstructor)
                .foregroundColor(Color("BlueGray"))
                .padding(.horizontal, 30)
            Divider()
                .background(Color("BlueGray"))
                .padding(.horizontal, 30)
                .padding(.bottom, 20)

            Button {
                print("name: \(eventName)")
                print("date: \(eventDate)")
                print("time: \(eventTime)")
                print("location: \(eventLocation)")
                print("instructor: \(eventInstructor)")
            } label: {
                Text("Add Outing")
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
        }
    }
}
