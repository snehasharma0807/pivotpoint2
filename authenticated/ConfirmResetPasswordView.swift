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
            Text("Check your email for a verification code.")
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
                .submitLabel(.done)
            Divider()
                .background(Color("BlueGray"))
                .padding(.horizontal, 30)
            TextField("Verification code...", text: $confirmationCode)
                .foregroundColor(Color("BlueGray"))
                .padding(.horizontal, 30).padding(.top, 20)
                .offset(y: 25)
                .padding(.bottom, 25)
                .submitLabel(.done)
                .textContentType(.oneTimeCode)
                .keyboardType(.numberPad)
            Divider()
                .background(Color("BlueGray"))
                .padding(.horizontal, 30)
            SecureInputView("New password...", text: $newPassword)
                .foregroundColor(Color("BlueGray"))
                .padding(.horizontal, 30).padding(.top, 20)
                .offset(y: 25)
                .padding(.bottom, 25)
                .submitLabel(.done)

            Divider()
                .background(Color("BlueGray"))
                .padding(.horizontal, 30)
            Button {
                sessionManager.confirmResetPassword(username: username, newPassword: newPassword, confirmationCode: confirmationCode)
            } label: {
                Text("Reset Password")
                    .padding(.horizontal, 100)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(Color("BlueGray"))
                    .shadow(color: .gray, radius: 5, x: 4, y: 4)
                    .offset(y: 20)
                    .padding(.bottom, 20)
            }
            HStack{
                Text("Remember your password now?    ")
                    .font(.system(size: 15))
                Button {
                    sessionManager.changeAuthStateToLogin(error: "")
                } label: {
                    Text("Log in here.")
                        .bold()
                        .foregroundColor(Color("BlueGray"))
                        .font(.system(size: 15))
                }
                
            }
        }
    }
}


struct ConfirmResetPasswordView_Previews: PreviewProvider{
    static var previews: some View{
        ConfirmResetPasswordView(confirmResetPasswordError: "")
    }
}
