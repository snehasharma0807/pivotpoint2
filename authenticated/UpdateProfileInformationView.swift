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
        Text("Update Profile Information")
            .bold()
            .foregroundColor(Color("BlueGray"))
            .font(.system(size: 35))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
//
        HStack {
            TextField("Full Name: \(sessionManager.currentUserModel.fullName)", text: $fullName)
                .foregroundColor(Color("BlueGray"))
                .textContentType(.name)
                .submitLabel(.done)
            Button {
                sessionManager.changeFullName(user: sessionManager.currentUserModel, newName: fullName)
            } label: {
                Text("Update")
            }

        }
        .padding(.horizontal, 30)

        Divider()
            .background(Color("BlueGray"))
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
        
//
        HStack {
            TextField("Phone Number: \(sessionManager.currentUserModel.phoneNumber)", text: $phoneNumber)
                .foregroundColor(Color("BlueGray"))
                .textContentType(.telephoneNumber)
                .keyboardType(.phonePad)
                .submitLabel(.done)
            Button {
                sessionManager.changePhoneNumber(user: sessionManager.currentUserModel, phonenumber: phoneNumber)
            } label: {
                Text("Update")
            }

        }
        .padding(.horizontal, 30)

        Divider()
            .background(Color("BlueGray"))
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
//
            
        HStack {
            TextField("Address: \(sessionManager.currentUserModel.address)", text: $address)
                .foregroundColor(Color("BlueGray"))
                .textContentType(.fullStreetAddress)
                .submitLabel(.done)
            Button {
                sessionManager.changeAddress(user: sessionManager.currentUserModel, address: address)
                
            } label: {
                Text("Update")
            }

        }
        .padding(.horizontal, 30)

        Divider()
            .background(Color("BlueGray"))
            .padding(.horizontal, 30)
            .padding(.bottom, 20)


        
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

struct InputBoxForUpdating: View {
    @State var backgroundWords: String
    @Binding var bindingText: String
    var function: () -> Void
    
    var body: some View {
        HStack {
            TextField(backgroundWords, text: $bindingText)
                .foregroundColor(Color("BlueGray"))
            Button {
                function()
            } label: {
                Text("Update")
            }

        }
        .padding(.horizontal, 30)


        Divider()
            .background(Color("BlueGray"))
            .padding(.horizontal, 30)
            .padding(.bottom, 20)
    }
    
}
