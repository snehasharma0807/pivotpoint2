//sign up by inputting your desired username, email, and password
import SwiftUI
import Amplify
import AmplifyPlugins

struct SignUpView: View{
    
    @EnvironmentObject var sessionManager: SessionManager

    
    @State var username = ""
    @State var email = ""
    @State var password = ""
    let error: String
    
    var body: some View{
        VStack{
            if (error != ""){
                Text(error)
                    .bold()
                    .foregroundColor(.red)
            } else{
                Text("")
            }
            
            Image(systemName: "person.crop.square.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            TextField("Username...", text: $username)
                .foregroundColor(Color("BlueGray"))
                .padding(.horizontal, 30).padding(.top, 20)
                .offset(y: 50)
                .padding(.bottom, 50)
            Divider()
                .background(Color("BlueGray"))
                .padding(.horizontal, 30)
            TextField("Email...", text: $email)
                .foregroundColor(Color("BlueGray"))
                .padding(.horizontal, 30).padding(.top, 20)
                .offset(y: 25)
                .padding(.bottom, 25)
            Divider()
                .background(Color("BlueGray"))
                .padding(.horizontal, 30)
            SecureInputView("Password...", text: $password)
                .foregroundColor(Color("BlueGray"))
                .padding(.horizontal, 30).padding(.top, 20)
                .offset(y: 25)
                .padding(.bottom, 25)
            Divider()
                .background(Color("BlueGray"))
                .padding(.horizontal, 30)
            Button {
                sessionManager.signUp(username: username, email: email, password: password)
            } label: {
                Text("Sign up")
                    .padding(.horizontal, 100)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(Color("BlueGray"))
                    .shadow(color: .gray, radius: 5, x: 4, y: 4)
                    .offset(y: 20)
                    .padding(.bottom, 20)
            }
            HStack{
                Text("Already have an account?    ")
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
        .padding(.vertical, 30)

    }
}


struct SignUpView_Previews: PreviewProvider{
    static var previews: some View{
        SignUpView(error: "")
    }
}



