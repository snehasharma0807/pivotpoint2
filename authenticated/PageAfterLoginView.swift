//
//  PageAfterLoginView.swift
//  authenticated
//
//  Created by Sneha Sharma on 6/28/22.
//

import SwiftUI


struct PageAfterLoginView: View{
    @EnvironmentObject var sessionManager: SessionManager
    var body: some View {
            VStack(spacing: 10) {
                HStack{
                    Spacer()
                    Button {
                        sessionManager.changeAuthStateToCalendar()
                    } label: {
                        Image(systemName: "minus.circle")
                            .resizable()
                            .frame(width: 30, height: 30, alignment: .topTrailing)
                            .foregroundColor(Color(.black))
                    }
                }.padding(.horizontal)
                Spacer()
                Text("Welcome!")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Spacer()
            }.background(Image("trees").opacity(0.30))
    }
}
