//
//  Custom Date Picker.swift
//  CalendarApp
//
//  Created by Sneha Sharma on 4/10/22.
//

import SwiftUI

struct CustomDatePicker: View{
    @EnvironmentObject var sessionManager: SessionManager

    
    @Binding var currentDate: Date
    
    //month update on arrow click
    
    @State var currentMonth: Int = 0
    
    var body: some View{
        VStack(spacing: 35){
            
            //Days
            
            let days: [String] = ["Sun", "Mon", "Tues", "Wed", "Thu", "Fri", "Sat"]
            
            HStack(spacing: 20){
                VStack(alignment: .leading, spacing: 10){
                    
                    Text(extraDate()[0])
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Text(extraDate()[1])
                        .font(.title.bold())
                    
                }
                Spacer(minLength: 0)
                Button{
                    withAnimation{
                        currentMonth -= 1
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                }
                Button{
                    withAnimation{
                        currentMonth += 1
                    }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.title2)
                }
                
            }
            .padding(.horizontal)
            //Day view
            
            HStack(spacing: 0){
                ForEach(days, id: \.self){ day in
                    Text(day)
                        .font(.callout)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                }
            }
            
            //Dates
            //Lazy grid
            let columns = Array(repeating: GridItem(.flexible()), count: 7)
            
            LazyVGrid(columns: columns, spacing: 15) {
                ForEach(extractDate()){ value in
                    CardView(value: value)
                        .background(
                        Capsule()
                            .fill(Color("GreyGreen"))
                            .padding(.horizontal, 8)
                            .opacity(isSameDay(date1: value.date, date2: currentDate) ? 1:0)
                        )
                        .onTapGesture {
                            currentDate = value.date
                        }
                        
                }
            }
            VStack(spacing: 15){
               Text("Tasks")
                    .font(.title2.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 20)

                
                if let task = tasks.first(where: { task in
                    return isSameDay(date1: task.taskDate, date2: currentDate)
                }){
                    
                    ForEach(task.task){task in
                        VStack(alignment: .leading, spacing: 10) {
                            //for custom timing
                            Button {
                                sessionManager.changeAuthStateToEventDetails()
                            } label: {
                                Text(task.time
                                    .addingTimeInterval(CGFloat.random(in: 0...5000)), style: .time)
                                Text("  |  ")
                                Text(task.title)
                                    .font(.title2.bold())

                            }

                        }
                        .foregroundColor(.white)
                        .font(.title2.bold())
                        .padding(.vertical, 10)
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            Color("LightGrey")
                                .opacity(0.5)
                                .cornerRadius(10)
                        )
                    }
                    
                    
                } else{
                    Text("No event found")
                }
            }
            .padding()
        }
        .onChange(of: currentMonth) { newValue in
            //updating month
            currentDate = getCurrentMonth()
            
        }
    }
    
    @ViewBuilder
    func CardView(value: DateValue) -> some View{
        
        VStack{
            if value.day != -1{
                if let task = tasks.first(where: {task in
                    
                    return isSameDay(date1: task.taskDate, date2: value.date)
                }) {
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(isSameDay(date1: task.taskDate, date2: currentDate) ? .white : .primary)
                        .frame(maxWidth:  .infinity)

                    Spacer()
                    
                    Circle()
                        .fill(isSameDay(date1: task.taskDate, date2: currentDate) ? .white: Color("GreyGreen"))
                        .frame(width: 8, height: 8)
                } else{
                    Text("\(value.day)")
                        .font(.title3.bold())
                        .foregroundColor(isSameDay(date1: value.date, date2: currentDate) ? .white : .primary)
                        .frame(maxWidth:  .infinity)
                    
                    Spacer()
                }
            }
        }
        .padding(.vertical, 9)
        .frame(height: 60, alignment: .top)
    }
    
    //checking dates
    
    func isSameDay(date1: Date, date2: Date)->Bool{
        let calendar = Calendar.current
        
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    //extracting date and month for display
    
    func extraDate()-> [String]{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM"
        
        let date = formatter.string(from: currentDate)
        
        return date.components(separatedBy: " ")
    }

    
    func getCurrentMonth()-> Date{
        let calendar = Calendar.current

        guard let currentMonth = calendar.date(byAdding: .month, value: self.currentMonth, to: Date()) else{
            return Date()
        }
        return currentMonth
    }
    
    func extractDate() -> [DateValue]{
        //Getting current month date
        let calendar = Calendar.current
        
        let currentMonth = getCurrentMonth()
        
        var days = currentMonth.getAllDates().compactMap{date -> DateValue in
            
            //getting day
            
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        
        //adding offset days to get exact week
        let firstWeekday = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0..<firstWeekday - 1{
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        return days
        

    }
}



//Extending date to get current month date

extension Date{
    func getAllDates() -> [Date]{
        let calendar = Calendar.current
        
        //getting start date
        
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        
        let range = calendar.range(of: .day, in: .month, for: startDate)!
        
        //getting date
        return range.compactMap{day -> Date in
            return calendar.date(byAdding: .day, value: day - 1, to: startDate)!
        }
    }
}

struct DateValue: Identifiable{
    var id = UUID().uuidString
    var day: Int
    var date: Date
    
}

struct Task: Identifiable{
    var id = UUID().uuidString
    var title: String
    var time: Date = Date()
}

//total task meta view
struct TaskMetaData: Identifiable{
    var id = UUID().uuidString
    var task: [Task]
    var taskDate: Date
}

//sample date for testing
func getSampleDate(offset: Int)->Date{
    let calendar = Calendar.current
    let date = calendar.date(byAdding: .day, value: offset, to: Date())
    return date ?? Date()
}


//sample tasks
var tasks: [TaskMetaData] = [
    TaskMetaData(task: [
    
        Task(title: "Event 1"),
        Task(title: "Event 2"),
        Task(title: "Event 3")
             ], taskDate: getSampleDate(offset: 1)),
        TaskMetaData(task: [
             Task(title: "Event 4")
             ], taskDate: getSampleDate(offset: -3)),
        TaskMetaData(task: [
            Task(title: "Event 5")
            ], taskDate: getSampleDate(offset: -8))
]

func addTask(taskName: String, date: Date) -> (){
    
}


struct Previews_Custom_Date_Picker_Previews: PreviewProvider {
    static var previews: some View {
        Text("Hello, World!")
    }
}
