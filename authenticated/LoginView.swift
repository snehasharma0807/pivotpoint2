import SwiftUI

struct LoginView: View{
    
    @EnvironmentObject var sessionManager: SessionManager
    let error : String
    @State var username = ""
    @State var password = ""
    

    
    var body: some View{
        VStack{
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 300, height: 300)
            TextField("Username...", text: $username)
                .foregroundColor(Color("BlueGray"))
                .padding(.horizontal, 30).padding(.top, 20)
                .offset(y: 50)
                .padding(.bottom, 50)
            Divider()
                .background(Color("BlueGray"))
                .padding(.horizontal, 30)
            SecureInputView("Password", text: $password)
                .foregroundColor(Color("BlueGray"))
                .padding(.horizontal, 30).padding(.top, 22)
            Divider()
                .background(Color("BlueGray"))
                .padding(.horizontal, 30)
            Button {
                sessionManager.login(username: username, password: password)
            } label: {
                Text("Login")
                    .padding(.horizontal, 100)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(Color("BlueGray"))
                    .shadow(color: .gray, radius: 5, x: 4, y: 4)
                    .offset(y: 20)
                    .padding(.bottom, 20)
            }
            Button {
                sessionManager.changeAuthStateToResetPassword(resetPasswordError: "")
            } label: {
                Text("Forgot Password?")
                    .foregroundColor(Color("BlueGray"))
                    .font(.system(size: 15))
            }
            Spacer()
            HStack{
                Text("Don't have an account?  ")
                    .font(.system(size: 15))
                Button {
                    sessionManager.changeAuthStateToSignUp()
                } label: {
                    Text("Sign up here.")
                        .bold()
                        .foregroundColor(Color("BlueGray"))
                        .font(.system(size: 15))
                }

            }


            Spacer()

        }
        .padding(.vertical, 30)
    }
}

struct LoginView_Previews: PreviewProvider{
    static var previews: some View{
        LoginView(error: "")
    }
}

struct SecureInputView: View {
    
    @Binding private var text: String
    @State private var isSecured: Bool = true
    private var title: String
    
    init(_ title: String, text: Binding<String>) {
        self.title = title
        self._text = text
    }
    
    var body: some View {
        ZStack(alignment: .trailing) {
            Group {
                if isSecured {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
            }.padding(.trailing, 32)

            Button(action: {
                isSecured.toggle()
            }) {
                Image(systemName: self.isSecured ? "eye.slash" : "eye")
                    .accentColor(.gray)
            }
        }
    }
}
