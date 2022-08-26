//
//  ViewScheduledOutingsView.swift
//  authenticated
//
//  Created by Sneha Sharma on 8/25/22.
//

import Amplify
import SwiftUI


struct ViewScheduledOutingsView: View {
    @EnvironmentObject var sessionManager: SessionManager
    var title: String = ""
    var date: String = ""
    var time: String = ""
    @State var isUpcoming = true
    
    var body: some View {
        Text("View Scheduled Outings")
            .bold()
            .foregroundColor(Color("BlueGray"))
            .font(.system(size: 35))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.bottom, 10)
            .padding(.top, 20)
        
        
        if isUpcoming == true {
            HStack {
                Button {
                    isUpcoming = true
                } label: {
                    Text("Upcoming")
                        .underline()
                        .bold()
                        .foregroundColor(Color("BlueGray"))
                        .font(.system(size: 25))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                Button {
                    isUpcoming = false
                } label: {
                    Text("Past")
                        .foregroundColor(Color("BlueGray"))
                        .font(.system(size: 25))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                }
            }

            if sessionManager.idsForUpcomingOutingsList.isEmpty {
                let randList = [""]
                List(randList, id: \.self) { id in
                    Text("You have no upcoming outings.")
                }
            } else {
                List(sessionManager.idsForUpcomingOutingsList, id: \.self) { id in
                    Button {
                        sessionManager.clickedOnOuting = sessionManager.upcomingOutings[id]
                        sessionManager.changeAuthStateToEventDetails()
                    } label: {
                        OutingsRow(title: sessionManager.upcomingOutings[id].title, date: sessionManager.upcomingOutings[id].startDate.iso8601FormattedString(format: .short), time: sessionManager.upcomingOutings[id].startTime.iso8601FormattedString(format: .short))
                    }

                }
            }
            
            
            
        } else {
            HStack {
                Button {
                    isUpcoming = true
                } label: {
                    Text("Upcoming")

                        .foregroundColor(Color("BlueGray"))
                        .font(.system(size: 25))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                Button {
                    isUpcoming = false
                } label: {
                    Text("Past")
                        .underline()
                        .bold()
                        .foregroundColor(Color("BlueGray"))
                        .font(.system(size: 25))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                }
            }

            if sessionManager.idsForPastOutingsList.isEmpty {
                let randList = [""]
                List(randList, id: \.self) { id in
                    Text("You have no upcoming outings.")
                }
                
            } else {
                List(sessionManager.idsForPastOutingsList, id: \.self) { id in
                    Button {
                        sessionManager.clickedOnOuting = sessionManager.pastOutings[id]
                        sessionManager.changeAuthStateToCalendar()
                    } label: {
                        OutingsRow(title: sessionManager.pastOutings[id].title, date: sessionManager.pastOutings[id].startDate.iso8601FormattedString(format: .short), time: sessionManager.pastOutings[id].startTime.iso8601FormattedString(format: .short))
                    }

                }
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
                .padding(.bottom, 10)
        }
        Spacer()






        
    }
}

struct ViewScheduledOutingsView_Previews: PreviewProvider{
    static var previews: some View{
        ViewScheduledOutingsView()
    }
}

struct OutingsRow: View {
    let title: String
    let date: String
    let time: String
    
    var body: some View {
        Button {
            
        } label: {
            
            HStack {
                VStack {
                    Text(title)
                        .bold()
                        .font(.system(size: 20))
                        .foregroundColor(Color("BlueGray"))
                    Text(date)
                        .font(.system(size: 15))
                        .foregroundColor(Color("BlueGray"))
                }
                .padding(15)
                Spacer()
                Text(time)
                    .font(.system(size: 20))
                    .foregroundColor(Color("BlueGray"))
            }.padding(.horizontal, 30)
        }

    }
}

