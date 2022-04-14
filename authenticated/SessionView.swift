//what you see when you log into the app (calendar)

import Amplify
import SwiftUI

struct SessionView: View{

    @EnvironmentObject var sessionManager: SessionManager
    let user: AuthUser
    @State var currentDate: Date = Date()
    
    var body: some View{
        ScrollView(.vertical, showsIndicators: false){
            VStack(spacing: 20){
                Text("\(user.username)")
                //Custom date picker
                CustomDatePicker(currentDate: $currentDate)
            }
            .padding(.vertical)
        }
        //Safe area view
        
        .safeAreaInset(edge: .bottom){
            HStack{
                Button{
                } label: {
                    Text("Add Task")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color( "DarkGreyBlue"), in: Capsule())
                        .foregroundColor(.white)
                }

                Button{
                } label: {
                    Text("Add Reminder")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color( "LightGrey"), in: Capsule())
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .background(.ultraThinMaterial)
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
