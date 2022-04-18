//sign up by inputting your desired username, email, and password
import SwiftUI

struct SignUpView: View{
    
    @EnvironmentObject var sessionManager: SessionManager

    
    @State var username = ""
    @State var email = ""
    @State var password = ""
    
    var body: some View{
        VStack{
            Spacer()
            Text("When setting your username, please remember to set your username as your official name (first AND last).")
                .foregroundColor(Color("DarkGreyBlue"))
                .fontWeight(.semibold)
                .font(.title2)
                .multilineTextAlignment(.center)

                
            Spacer()
            
            TextField("Username", text: $username).pretty()
            TextField("Email", text: $email).pretty()
            SecureField("Password", text: $password).pretty()
            Button("Sign Up", action: {
                sessionManager.signUp(
                    username: username,
                    email: email,
                    password: password
                )
            }).pretty()
            
            Spacer()
            Button("Already have an account? Log in.", action: {
                sessionManager.changeAuthStateToLogin(error: "")}
            )
        }
        .padding()
    }
}


struct SignUpView_Previews: PreviewProvider{
    static var previews: some View{
        SignUpView()
    }
}
