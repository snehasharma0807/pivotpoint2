import SwiftUI

//gray and white color scheme
struct Pretty: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.largeTitle)
            .foregroundColor(Color(red: 0.2824, green: 0.5255, blue: 0.6275))
            .padding()
            .background(.white)
        
    }
}
extension View {
    func pretty() -> some View { modifier(Pretty()) }
}


//dark blue header
struct Header: ViewModifier{
    func body(content: Content) -> some View{
        content
            .font(.headline)
            .foregroundColor(Color(red: 0.2824, green: 0.5255, blue: 0.6275))
            .multilineTextAlignment(.center)
            .font(.system(size: 40))
    }
}

extension View{
    func header () -> some View { modifier(Header())}
}

//calendar code for ui

struct CalendarUI: ViewModifier{
    func body(content: Content) -> some View{
        content
            .hidden()
            .padding()
            .background(Color(red: 0.2824, green: 0.5255, blue: 0.6275))
            .clipShape(Circle())
            .padding(.vertical, 4)
            .frame(width: 45, height: 45, alignment: .center)
    }
}

extension View{
    func calendarUI () -> some View { modifier(CalendarUI())}
}
