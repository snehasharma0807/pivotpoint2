//confirm that you wish to reset your password by inputting the verification code and your new password

import SwiftUI

struct ConfirmResetPasswordView: View{
    let confirmResetPasswordError: String
    @EnvironmentObject var sessionManager: SessionManager

    
    @State var username = ""
    @State var confirmationCode = ""
    @State var newPassword = ""
    
    var body: some View{
        VStack{
            Spacer()
            Text("Check your email for a confirmation code.").header()
            TextField("Username", text: $username).pretty()
            TextField("Password", text: $newPassword).pretty()
            SecureField("ConfirmationCode", text: $confirmationCode).pretty()
            Button("Confirm", action: {
                sessionManager.confirmResetPassword(username: username, newPassword: newPassword, confirmationCode: confirmationCode); print(newPassword)}).pretty()
            
            Spacer()
            Button("Already have an account? Log in.", action: {
                sessionManager.showLogin(error: "")
                
            })
        }
        .padding()
    }
}


struct ConfirmResetPasswordView_Previews: PreviewProvider{
    static var previews: some View{
        ConfirmResetPasswordView(confirmResetPasswordError: "")
    }
}
