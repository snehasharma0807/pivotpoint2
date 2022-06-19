//allows you to reset your password. enter your username to get a verification code

import SwiftUI

struct ResetPasswordView: View{
    let resetPasswordError: String
    @EnvironmentObject var sessionManager: SessionManager
    @EnvironmentObject var error: SessionManager
    
    @State var username = ""
    
    var body: some View{
        Text("Enter your username to recieve instructions on how to reset your password.")
            .bold()
            .foregroundColor(Color("BlueGray"))
            .font(.system(size: 30))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
        TextField("Username...", text: $username)
            .foregroundColor(Color("BlueGray"))
            .padding(.horizontal, 30).padding(.top, 20)
            .offset(y: 50)
            .padding(.bottom, 50)
        Divider()
            .background(Color("BlueGray"))
            .padding(.horizontal, 30)
        Button {
            sessionManager.resetPassword(username: username)
        } label: {
            Text("Next")
                .padding(.horizontal, 100)
                .padding(.vertical, 10)
                .foregroundColor(.white)
                .background(Color("BlueGray"))
                .shadow(color: .gray, radius: 5, x: 4, y: 4)
                .offset(y: 20)
                .padding(.bottom, 20)
        }
        HStack{
            Text("Don't have an account?    ")
                .font(.system(size: 15))
            Button {
                sessionManager.changeAuthStateToSignUp(error: "")
            } label: {
                Text("Sign up here.")
                    .bold()
                    .foregroundColor(Color("BlueGray"))
                    .font(.system(size: 15))
            }

        }
    }
}


struct ResetPasswordView_Previews: PreviewProvider{
    static var previews: some View{
        ResetPasswordView(resetPasswordError: "")
    }
}
