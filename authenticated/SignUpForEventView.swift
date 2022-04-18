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
    

    var body: some View{
        Text("Hello!")
        Button {
            sessionManager.changeAuthStateToSession()
        } label: {
            Text("Go back to calendar")
        }

    }
}

