//enter a verification code to confirm your email and account
import SwiftUI

struct ConfirmationView: View{
    
    @EnvironmentObject var sessionManager: SessionManager

    
    @State var confirmationCode = ""
    
    let username: String
    
    var body: some View{
        VStack{
            Text("Username: \(username)")
            TextField("Confirmation Code", text: $confirmationCode).pretty()
            Button("Confirm", action: {
                sessionManager.confirm(username: username, code: confirmationCode)
            }).pretty()
            Button("Go to home", action: {
                sessionManager.changeAuthStateToLogin(error: "")
            }).pretty()
        }
        .padding()
    }
}

struct ConfirmationView_Previews: PreviewProvider{
    static var previews: some View{
        ConfirmationView(username: "kilo loco")
    }
}
