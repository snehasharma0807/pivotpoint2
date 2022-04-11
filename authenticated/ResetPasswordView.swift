//allows you to reset your password. enter your username to get a verification code

import SwiftUI

struct ResetPasswordView: View{
    let resetPasswordError: String
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var error: SessionManager
    
    @State var username = ""
    
    var body: some View{
        VStack{
            Spacer()
            if (!resetPasswordError.isEmpty){
                Text(resetPasswordError)
                    .bold()
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
            }

            Spacer()
            Text("Enter your username here. If you don't remember it, please make a new account.").header()
            TextField("Username", text: $username).pretty()
            Button("Confirm your username.", action: {
                sessionManager.resetPassword(username: username)
            }).pretty()
            
            Spacer()
            Button("Back to home", action: {
                sessionManager.showLogin(error: "")
            })
        }
        .padding()
    }
}


struct ResetPasswordView_Previews: PreviewProvider{
    static var previews: some View{
        ResetPasswordView(resetPasswordError: "")
    }
}
