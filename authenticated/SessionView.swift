//what you see when you log into the app

import Amplify
import SwiftUI

struct SessionView: View{

    @EnvironmentObject var sessionManager: SessionManager


    let user: AuthUser

    var body: some View{
        VStack{
            Spacer()
            Text("Welcome \(user.username)!!")
                .font(.largeTitle)
                .multilineTextAlignment(.center)
            Spacer()
            Button("Sign Out", action: sessionManager.signOut)
        }
    }
}

struct SessionView_Previews: PreviewProvider{
    private struct DummyUser: AuthUser{
        let userId: String = "2"
        let username: String = "dummy-add"
    }

    static var previews: some View{
        SessionView(user: DummyUser())
    }
}
