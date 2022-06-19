//enter a verification code to confirm your email and account
import SwiftUI

struct ConfirmationView: View{
    
    @EnvironmentObject var sessionManager: SessionManager

    
    @State var confirmationCode = ""
    
    let username: String
    
    var body: some View{
        VStack{
            Spacer()
            Text("Hey there, \(username)! Just one last step. Check your email for a confirmation code!")
                .bold()
                .foregroundColor(Color("BlueGray"))
                .font(.system(size: 30))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            TextField("Confirmation code...", text: $confirmationCode)
                .foregroundColor(Color("BlueGray"))
                .padding(.horizontal, 30).padding(.top, 20)
                .offset(y: 50)
                .padding(.bottom, 50)
            Divider()
                .background(Color("BlueGray"))
                .padding(.horizontal, 30)
            Button {
                sessionManager.confirm(username: username, code: confirmationCode)
            } label: {
                Text("Confirm")
                    .padding(.horizontal, 100)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(Color("BlueGray"))
                    .shadow(color: .gray, radius: 5, x: 4, y: 4)
                    .offset(y: 20)
                    .padding(.bottom, 20)
            }
            Button {
                sessionManager.changeAuthStateToLogin(error: "")
            } label: {
                Text("Go to home")
                    .padding(.horizontal, 100)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(Color("BlueGray"))
                    .shadow(color: .gray, radius: 5, x: 4, y: 4)
                    .offset(y: 20)
                    .padding(.bottom, 20)
            }
         Spacer()
        }
    }
}

struct ConfirmationView_Previews: PreviewProvider{
    static var previews: some View{
        ConfirmationView(username: "sneha slays")
    }
}
