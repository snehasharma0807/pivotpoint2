//
//  LoadingView.swift
//  authenticated
//
//  Created by Sneha Sharma on 7/13/22.
//

import SwiftUI

struct LoadingView: View {
    @State private var isLoading = false
    @EnvironmentObject var sessionManager: SessionManager
    var body: some View {
        ZStack{
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Color("BlueGray")))
                .scaleEffect(3)
            if isLoading{
                ZStack{
                    Color(.systemBackground)
                }
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(3)
            }

        }
        .onAppear{
            sessionManager.startFakeNetworkCall()
        }
        
        
    }
    


}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
