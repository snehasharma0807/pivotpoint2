//
//  AddEventView.swift
//  authenticated
//
//  Created by Sneha Sharma on 5/8/22.
//

import SwiftUI


struct AddEventView: View{
    @EnvironmentObject var sessionManager: SessionManager
    var body: some View{
        VStack{
            Text("Hello!")
            Button{
                sessionManager.changeAuthStateToCalendar()
            } label:{
                Text("Go back to the calendar")
            }
        }
    }
}
