//
//  SeeUsersInEachOutingView.swift
//  authenticated
//
//  Created by Sneha Sharma on 8/30/22.
//

import Foundation
import SwiftUI
import Amplify

struct SeeUsersInEachOutingView: View {
    var clickedOnOuting: Outing
    @EnvironmentObject var sessionManager: SessionManager
    var body: some View {
        VStack {
            Text("\(clickedOnOuting.title)")
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
            
            if (clickedOnOuting.startDate == clickedOnOuting.endDate) {
                //same date
                Text("**Date:** \(clickedOnOuting.startDate.iso8601FormattedString(format: .short))")
                    .foregroundColor(Color("BlueGray"))
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                Text("**Start Time:** \(clickedOnOuting.startTime.iso8601FormattedString(format: .short))")
                    .foregroundColor(Color("BlueGray"))
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                Text("**End Time:** \(clickedOnOuting.endTime.iso8601FormattedString(format: .short))")
                    .foregroundColor(Color("BlueGray"))
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            } else {
                //not same date
                Text("**Starts on:** \(clickedOnOuting.startDate.iso8601FormattedString(format: .short)) at \(clickedOnOuting.startTime.iso8601FormattedString(format: .short))")
                    .foregroundColor(Color("BlueGray"))
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                Text("**Ends on:** \(clickedOnOuting.endDate.iso8601FormattedString(format: .short)) at \(clickedOnOuting.endTime.iso8601FormattedString(format: .short))")
                    .foregroundColor(Color("BlueGray"))
                    .font(.system(size: 20))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }
            if sessionManager.idsForUsersInAnOutingList.count == 0 {
                Spacer()
                Text("No users have signed up for this outing yet.")
                    .italic()
                    .bold()
                    .foregroundColor(Color("BlueGray"))
                    .padding(.horizontal, 20)
                    .font(.system(size: 15))
            } else {
                Text("Clients: ")
                    .bold()
                    .foregroundColor(Color("BlueGray"))
                    .padding(.horizontal, 20)
                    .font(.system(size: 15))
                
                List(sessionManager.idsForUsersInAnOutingList, id: \.self) { id in
                    ListRow(username: sessionManager.usersInAnOutingList[id].fullName, userType: sessionManager.usersInAnOutingList[id].address, phoneNumber: sessionManager.usersInAnOutingList[id].phoneNumber)
                }
                .frame(height: 200, alignment: .center)
                    .padding()
            }
            if sessionManager.idsForUsersInWaitingList.count != 0 {
                Text("Clients on the Waiting List: ")
                    .bold()
                    .foregroundColor(Color(red: 0.302, green: 0.008, blue: 0.008))
                    .padding(.horizontal, 20)
                    .font(.system(size: 15))
                List(sessionManager.idsForUsersInWaitingList, id: \.self) { id in
                    ListRow(username: sessionManager.usersInWaitingList[id].fullName, userType: "", phoneNumber: sessionManager.usersInWaitingList[id].phoneNumber)
                }
            } else {
                Text("There are no users on the waiting list.")
                    .foregroundColor(.red)
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
        
        

        }
        
        Spacer()

    }
}
