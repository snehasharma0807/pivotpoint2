//
//  AddEventView.swift
//  authenticated
//
//  Created by Sneha Sharma on 5/8/22.
//

import SwiftUI


struct AddEventView: View{
    @EnvironmentObject var sessionManager: SessionManager
    
    @State var outingTitle: String = ""
    @State var outingStartDate = Date()
    @State var outingStartTime = Date()
    @State var outingEndDate = Date()
    @State var outingEndTime = Date()
    @State var outingLocation: String = ""
    @State var outingDescription: String = ""
    @State var instructorsString: String = ""
    @State var instructorsList: [String] = []
    @State var outingProgramType: String = ""
    @State var maxNumClients: Int = 0
    
    var errorMessage: String
    
    func stringToList(string: String) {
        instructorsList = string.components(separatedBy: ", ")
    }
    

    
    var body: some View{
        
        ScrollView {
            Spacer()
            Text("Add an Outing")
                .bold()
                .foregroundColor(Color("BlueGray"))
                .font(.system(size: 35))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            Text("Note: While inputting the instructors' usernames, please format it as: Instructor1, Instructor2, etc...")
                .foregroundColor(Color("BlueGray"))
                .font(.system(size: 20))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 20)
            
            if errorMessage != "" {
                Text("\(errorMessage)")
                    .bold()
                    .foregroundColor(.red)
                    .padding()
            }
            
            
            Group {
                InputField(backgroundText: "Outing Title...", bindingText: $outingTitle)
                
                Group {
                    DatePicker("Start Date", selection: $outingStartDate, displayedComponents: [.date])
                        .datePickerStyle(.automatic)
                        .foregroundColor(Color("BlueGray"))
                        .padding(.horizontal, 30)
                    Divider()
                        .background(Color("BlueGray"))
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                    
                    DatePicker("Start Time", selection: $outingStartTime, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.automatic)
                        .foregroundColor(Color("BlueGray"))
                        .padding(.horizontal, 30)
                    Divider()
                        .background(Color("BlueGray"))
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                    
                    DatePicker("End Date", selection: $outingEndDate, displayedComponents: [.date])
                        .datePickerStyle(.automatic)
                        .foregroundColor(Color("BlueGray"))
                        .padding(.horizontal, 30)
                    Divider()
                        .background(Color("BlueGray"))
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                    
                    DatePicker("End Time", selection: $outingEndTime, displayedComponents: [.hourAndMinute])
                        .datePickerStyle(.automatic)
                        .foregroundColor(Color("BlueGray"))
                        .padding(.horizontal, 30)
                    Divider()
                        .background(Color("BlueGray"))
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)
                }
                
                
                InputField(backgroundText: "Outing Location...", bindingText: $outingLocation)
                
                ZStack {
                    TextEditor(text: self.$outingDescription)
                        .foregroundColor(Color("BlueGray"))
                        .padding(.horizontal, 30)
                    
                    if outingDescription == "" {
                        HStack {
                            Text("Outing Description...")
                                .foregroundColor(Color(red: 0.773, green: 0.773, blue: 0.78))
                            Spacer()
                        }
                        .padding(.horizontal, 30)

                            
                    }
                    
                }

                

                Divider()
                    .background(Color("BlueGray"))
                    .padding(.horizontal, 30)
                    .padding(.bottom, 20)


                InputField(backgroundText: "Instructor[s]...", bindingText: $instructorsString)

                InputField(backgroundText: "Program Type...", bindingText: $outingProgramType)

                HStack {
                    Text("Max Number of Clients")
                        .foregroundColor(Color("BlueGray"))
                        .padding(.horizontal, 30)
                    
                    Picker("Max Number of Clients", selection: $maxNumClients) {
                        ForEach(1...100, id: \.self) { number in
                            Text("\(number)")
                                .foregroundColor(.white)
                        }
                    }
                        .padding(5)
                        .overlay(Capsule(style: .circular)
                            .stroke(Color("BlueGray")))
                        

    
                }
                

                
                

            }
            
            Button {
                //change string to list
                stringToList(string: instructorsString)
                print(instructorsString)
                print(instructorsList)
                sessionManager.saveOuting(title: outingTitle, description: outingDescription, location: outingLocation, startDate: outingStartDate, startTime: outingStartTime, endDate: outingEndDate, endTime: outingEndTime, instructors: instructorsList, programType: outingProgramType, maxNumClients: maxNumClients)
                sessionManager.changeAuthStateToLoading()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    sessionManager.changeAuthStateToCalendar()
                }
                                
            } label: {
                Text("Save")
                    .padding(.horizontal, 100)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(Color("BlueGray"))
                    .shadow(color: .gray, radius: 5, x: 4, y: 4)
                    .offset(y: 20)
                    .padding(.bottom, 20)
            }
            
            Button {
                sessionManager.changeAuthStateToCalendar()
                                
            } label: {
                Text("Go to Home")
                    .padding(.horizontal, 100)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(Color("BlueGray"))
                    .shadow(color: .gray, radius: 5, x: 4, y: 4)
                    .offset(y: 20)
                    .padding(.bottom, 20)

            }
            
        }
    }
}


struct InputField: View {
    var backgroundText: String
    var bindingText: Binding<String>
    var body: some View {
        TextField("\(backgroundText)", text: bindingText)
            .foregroundColor(Color("BlueGray"))
            .padding(.horizontal, 30)
        Divider()
            .background(Color("BlueGray"))
            .padding(.horizontal, 30)
            .padding(.bottom, 20)

    }
}
