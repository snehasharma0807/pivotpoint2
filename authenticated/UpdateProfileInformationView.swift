//
//  UpdateProfileInformationView.swift
//  authenticated
//
//  Created by Sneha Sharma on 8/9/22.
//

import SwiftUI
import Amplify


struct UpdateProfileInformationView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    @State var fullName: String = ""
    @State var phoneNumber: String = ""
    @State var address: String = ""
    @State var programType: String = ""
    
    var body: some View {
        Text("Profile Information")
            .bold()
            .foregroundColor(Color("BlueGray"))
            .font(.system(size: 35))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
        
        InputBox(backgroundWords: "Full Name...", bindingText: $fullName)
        InputBox(backgroundWords: "Phone Number...", bindingText: $phoneNumber)
        InputBox(backgroundWords: "Address...", bindingText: $address)

        
        Button {
            print("\(sessionManager.currentUserModel.fullName ?? "")")
        } label: {
            Text("Update Information")
                .padding(.horizontal, 100)
                .padding(.vertical, 10)
                .foregroundColor(.white)
                .background(Color("BlueGray"))
                .shadow(color: .gray, radius: 5, x: 4, y: 4)
                .offset(y: 20)
                .padding(.bottom, 20)
        }
        Button {
            sessionManager.queryUserProfileInformation()
        } label: {
            Text("Query User Information")
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

struct InputBox: View {
    @State var backgroundWords: String
    @Binding var bindingText: String
    
    var body: some View {
        TextField(backgroundWords, text: $bindingText)
            .foregroundColor(Color("BlueGray"))
            .padding(.horizontal, 30)
        Divider()
            .background(Color("BlueGray"))
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
    }
    
}

