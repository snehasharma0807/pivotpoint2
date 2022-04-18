import SwiftUI

struct LoginView: View{
    
    @EnvironmentObject var sessionManager: SessionManager
    let error : String
    @State var username = ""
    @State var password = ""
    

    
    var body: some View{
        VStack{
            Spacer()
            Image("logo")
                .resizable()
                .aspectRatio(contentMode: .fit)
            Spacer()
            
            Text(error)
                .bold()
                .foregroundColor(.red)
                
            TextField("Username", text: $username).pretty()
            SecureField("Password", text: $password).pretty()
            Button("Login", action: {
                sessionManager.login(username: username, password: password)
            }).pretty()
            Spacer()
            Button("Don't remember your password? Reset it here.", action: {sessionManager.changeAuthStateToResetPassword(resetPasswordError: "")})
            Button("Don't have an account? Sign up.", action: {
                sessionManager.changeAuthStateToSignUp()
            })

        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider{
    static var previews: some View{
        LoginView(error: "")
    }
}
