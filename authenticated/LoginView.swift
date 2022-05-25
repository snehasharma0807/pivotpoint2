import SwiftUI

struct LoginView: View{
    
    @EnvironmentObject var sessionManager: SessionManager
    let error : String
    @State var username = ""
    @State var password = ""
    

    
    var body: some View{
        VStack{
            Group{
                Spacer()
                Image("logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                
                Spacer()

                Text(error)
                    .bold()
                    .foregroundColor(.red)

                    
                TextField("Username", text: $username).pretty()
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(red: 0.2824, green: 0.5255, blue: 0.6275), lineWidth: 1)
                        )
                SecureField("Password", text: $password).pretty()
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(Color(red: 0.2824, green: 0.5255, blue: 0.6275), lineWidth: 1)
                        )
                Button {
                    sessionManager.login(username: username, password: password)
                } label: {
                    Text("Login")
                        .font(.largeTitle)
                        .foregroundColor(Color(red: 0.2824, green: 0.5255, blue: 0.6275))
                        .padding()
                        .background(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color(red: 0.2824, green: 0.5255, blue: 0.6275), lineWidth: 1)
                            )
                }
                Spacer()
            }


            
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
