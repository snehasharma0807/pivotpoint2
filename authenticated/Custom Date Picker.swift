//
//  Custom Date Picker.swift
//  CalendarApp
//
//  Created by Sneha Sharma on 4/10/22.
//

import SwiftUI

struct CustomDatePicker: View{
    
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
                }
            }
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
                Text("\(value.day)")
                    .font(.title3.bold())
            }
        }
        .padding(.vertical, 8)
        .frame(height: 60, alignment: .top)
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



//struct CustomeDatePicker_Preview: PreviewProvider{
//    static var previews: some View{
//        SessionView(user: AuthUser)
//    }
//}


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
