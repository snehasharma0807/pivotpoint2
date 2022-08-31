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
    @State var outingProgramType: String = ""
    @State var maxNumClients: Int = 0
    @State var listOfInstructors: [String] = []
    @State var didClick: Bool = false
    
    var errorMessage: String
    
    

    
    var body: some View{
        
        ScrollView {
            Spacer()
            Text("Add an Outing")
                .bold()
                .foregroundColor(Color("BlueGray"))
                .font(.system(size: 35))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
            
            
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


                Text("Instructor[s]...")
                    .foregroundColor(Color("BlueGray"))
                    .padding(.horizontal, 30)
                    .multilineTextAlignment(.center)
                
                List(sessionManager.idsForUsersList, id: \.self) { id in
                    if sessionManager.userDetailsList[id].userType == UserGroup.employee {
                        HStack {
                            Image(systemName: didClick ? "checkmark.square.fill" : "square")
                                .foregroundColor(didClick ? Color(UIColor.systemBlue) : Color.secondary)
                                .onTapGesture {
                                    self.didClick.toggle()

                                    
                                    if self.didClick == true {
                                        listOfInstructors.append(sessionManager.userDetailsList[id].username)
                                    } else {
                                        var id = 0
                                        for instructor in listOfInstructors {
                                            if (instructor == sessionManager.userDetailsList[id].username) {
                                                listOfInstructors.remove(at: id)
                                            }
                                            id += 1
                                        }
                                    }

                                    print(listOfInstructors)

                                }
                            ListRow(username: sessionManager.userDetailsList[id].username, userType: sessionManager.userDetailsList[id].userType?.rawValue ?? "CLIENT", phoneNumber: sessionManager.userDetailsList[id].phoneNumber)
                                .listRowBackground(didClick ? Color(red: 0.839, green: 0.839, blue: 0.839) : Color(red: 0.565, green: 0.612, blue: 0.69))
                            
                        }
                        
                    }

                }.frame(height: 200, alignment: .center)
                    .padding()
                
                }


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
                
                

                
            Button {
                
                if (outingTitle == "") || (outingLocation == "") || (outingDescription == "") || (listOfInstructors == []) {
                    sessionManager.changeAuthStateToAddEvent(error: "Please input all information.")
                } else {
                    sessionManager.saveOuting(title: outingTitle, description: outingDescription, location: outingLocation, startDate: outingStartDate, startTime: outingStartTime, endDate: outingEndDate, endTime: outingEndTime, instructors: listOfInstructors, programType: outingProgramType, maxNumClients: maxNumClients)
                    sessionManager.changeAuthStateToLoading()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        sessionManager.changeAuthStateToCalendar()
                    }
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

            
        Spacer()

    
    
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



//what i'm working on right now:
///
///when you click a list item, it turns a different color + appends to a list
///if you click it again, this stops

//problem that im having:
///
///how to set the ui to do this
