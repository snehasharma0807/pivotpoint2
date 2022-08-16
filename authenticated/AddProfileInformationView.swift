//
//  AddProfileInformationView.swift
//  authenticated
//
//  Created by Sneha Sharma on 8/9/22.
//

import SwiftUI
import Amplify


struct AddProfileInformationView: View {
    @EnvironmentObject var sessionManager: SessionManager
    
    @State var fullName: String = ""
    @State var phoneNumber: String = ""
    @State var address: String = ""
    @State var programType: String = ""
    @State var errorMessage: String = ""
    
    var body: some View {
        Text(errorMessage)
            .bold()
            .foregroundColor(.red)
            .multilineTextAlignment(.center)
        
        Text("Thanks for signing up! Please add your profile information here.")
            .bold()
            .foregroundColor(Color("BlueGray"))
            .font(.system(size: 30))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
        
        InputBox(backgroundWords: "Full Name...", bindingText: $fullName)
        InputBox(backgroundWords: "Phone Number...", bindingText: $phoneNumber)
        InputBox(backgroundWords: "Address...", bindingText: $address)

        
        Button {
            let username = sessionManager.currentUser
            print(username)
            if ((fullName == "") || (phoneNumber == "") || (address == "")) {
                errorMessage = "Please enter all fields."
            } else {
                sessionManager.saveUserProfileInformation(username: username, fullname: fullName, phoneNumber: phoneNumber, address: address)
                sessionManager.changeAuthStateToLogin(error: "")
            }
        } label: {
            Text("Save Information")
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
