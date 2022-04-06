////what you see when you log into the app
//
//import Amplify
//import SwiftUI
//import ElegantCalendar
//
//struct SessionView: View{
//
//    @EnvironmentObject var sessionManager: SessionManager
////    @Environment(\.calendar) var calendar
////    private var year: DateInterval{
////        calendar.dateInterval(of: .year, for: Date())!
////    }
////    let user: AuthUser
////
////    var body: some View{
////        VStack{
////            Spacer()
////            Text("Welcome \(user.username)!!")
////                .font(.largeTitle)
////                .multilineTextAlignment(.center)
////            CalendarView(interval: year){ date in
////                Text("30")
////                    .calendarUI()
////                    .overlay(
////                        Text(String(self.calendar.component(.day, from: date)))
////                    )
////            }
////            Button("Sign Out", action: sessionManager.signOut)
////            Spacer()
////            padding(12)
////        }
////    }
////}
////
////
////
////struct SessionView_Previews: PreviewProvider{
////    private struct DummyUser: AuthUser{
////        let userId: String = "1"
////        let username: String = "dummy"
////    }
////
////    static var previews: some View{
////        SessionView(user: DummyUser())
////    }
////}
////
////fileprivate extension DateFormatter {
////    static var month: DateFormatter {
////        let formatter = DateFormatter()
////        formatter.dateFormat = "MMMM"
////        return formatter
////    }
////
////    static var monthAndYear: DateFormatter {
////        let formatter = DateFormatter()
////        formatter.dateFormat = "MMMM yyyy"
////        return formatter
////    }
////}
////
////fileprivate extension Calendar {
////    func generateDates(
////        inside interval: DateInterval,
////        matching components: DateComponents
////    ) -> [Date] {
////        var dates: [Date] = []
////        dates.append(interval.start)
////
////        enumerateDates(
////            startingAfter: interval.start,
////            matching: components,
////            matchingPolicy: .nextTime
////        ) { date, _, stop in
////            if let date = date {
////                if date < interval.end {
////                    dates.append(date)
////                } else {
////                    stop = true
////                }
////            }
////        }
////
////        return dates
////    }
////}
////extension Date {
////    func monthAsString() -> String {
////            let df = DateFormatter()
////            df.setLocalizedDateFormatFromTemplate("MMM")
////            return df.string(from: self)
////    }
////}
////
////struct WeekView<DateView>: View where DateView: View {
////    @Environment(\.calendar) var calendar
////
////    let week: Date
////    let content: (Date) -> DateView
////
////    init(week: Date, @ViewBuilder content: @escaping (Date) -> DateView) {
////        self.week = week
////        self.content = content
////    }
////
////    private var days: [Date] {
////        guard
////            let weekInterval = calendar.dateInterval(of: .weekOfYear, for: week)
////            else { return [] }
////        return calendar.generateDates(
////            inside: weekInterval,
////            matching: DateComponents(hour: 0, minute: 0, second: 0)
////        )
////    }
////
////    var body: some View {
////        HStack {
////            ForEach(days, id: \.self) { date in
////                HStack {
////                    if self.calendar.isDate(self.week, equalTo: date, toGranularity: .month) {
////                        self.content(date)
////                    } else {
////                        self.content(date).hidden()
////                    }
////                }
////            }
////        }
////    }
////}
////
////struct MonthView<DateView>: View where DateView: View {
////    @Environment(\.calendar) var calendar
////
////
////    let month: Date
////    let showHeader: Bool
////    let content: (Date) -> DateView
////
////    init(
////        month: Date,
////        showHeader: Bool = true,
////        @ViewBuilder content: @escaping (Date) -> DateView
////    ) {
////        self.month = month
////        self.content = content
////        self.showHeader = showHeader
////    }
////
////    private var weeks: [Date] {
////        guard
////            let monthInterval = calendar.dateInterval(of: .month, for: month)
////            else { return [] }
////        return calendar.generateDates(
////            inside: monthInterval,
////            matching: DateComponents(hour: 0, minute: 0, second: 0, weekday: calendar.firstWeekday)
////        )
////    }
////
////    private var header: some View {
////        let component = calendar.component(.month, from: month)
////        let formatter = component == 1 ? DateFormatter.monthAndYear : .month
////        return Text(formatter.string(from: month))
////            .font(.title)
////            .padding()
////    }
////
////    var body: some View {
////        VStack {
////            if showHeader {
////                header
////            }
////
////            ForEach(weeks, id: \.self) { week in
////                WeekView(week: week, content: self.content)
////                    .foregroundColor(.white)
////
////            }
////        }
////    }
////}
////
////struct CalendarView<DateView>: View where DateView: View {
////    @Environment(\.calendar) var calendar
////    let date = Date()
////    let interval: DateInterval
////    let content: (Date) -> DateView
////
////    init(interval: DateInterval, @ViewBuilder content: @escaping (Date) -> DateView) {
////        self.interval = interval
////        self.content = content
////    }
////
////    private var months: [Date] {
////        calendar.generateDates(
////            inside: interval,
////            matching: DateComponents(day: 1, hour: 0, minute: 0, second: 0)
////        )
////    }
////
////    var body: some View {
////        ScrollView(.vertical, showsIndicators: false) {
////            VStack {
////                ForEach(months, id: \.self) {month in
////                    MonthView(month: month, content: self.content)
////                }
////            }
////        }
////    }
////}

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
