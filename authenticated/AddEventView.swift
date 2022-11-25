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
    @State var outingPrograms: [String] = []
    @State var maxNumClients: Int = 0
    @State var listOfInstructors: [String] = []
    @State var didClick: Bool = false
    @State var didClick2: Bool = false
    let clickNum = 0
    
    
    @State var isChecked:Bool = false
    func toggle(){isChecked = !isChecked}


    
    var errorMessage: String
    
    let listOfPrograms = ["Buncombe County Veterans Treatment Court", "Buncombe County Adult Drug Court", "Buncombe County Family Drug Court", "ABCCM Veterans Restoration Quarters", "ABCCM Transformation Village", "Department of Juvenile Justice", "PIVOTPoint Program - Single Track", "PIVOTPoint Program - Family Track", "Other"]
    
    

    
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
                            Image(systemName: self.listOfInstructors.contains(sessionManager.userDetailsList[id].username) ?  "checkmark.square.fill" : "square")
                                .onTapGesture {
                                    self.didClick.toggle()
                                    if self.didClick == true {
                                        listOfInstructors.append(sessionManager.userDetailsList[id].username)
                                        
                                    } else {
                                        var id1 = 0
                                        for instructor in listOfInstructors {
                                            if (instructor == sessionManager.userDetailsList[id].username) {
                                                listOfInstructors.remove(at: id1)
                                            }
                                            id1 += 1
                                        }
                                        
                                    }
                                    print(listOfInstructors)
                                }
                            Text(sessionManager.userDetailsList[id].username)
                                .foregroundColor(Color("BlueGray"))
                                .multilineTextAlignment(.center)
                        }
                    }
                }.frame(height: 200, alignment: .center)
                    .padding()
            }
            
            
            Text("Program[s]...")
                .foregroundColor(Color("BlueGray"))
                .padding(.horizontal, 30)
                .multilineTextAlignment(.center)
            
            
            
            Form {
                List {
                    ForEach(listOfPrograms, id: \.self) { program in
                        Button {
                            withAnimation {
                                if self.outingPrograms.contains(program) {
                                    self.outingPrograms.removeAll(where: { $0 == program})
                                    print(self.outingPrograms)
                                } else {
                                    self.outingPrograms.append(program)
                                    print(self.outingPrograms)
                                    
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: self.outingPrograms.contains(program) ?  "checkmark.square.fill" : "square")
                                Text(program)
                                    .foregroundColor(Color("BlueGray"))
                                    .multilineTextAlignment(.center)
                            }.foregroundColor(.primary)
                        }
                        
                    }
                }
            }
            .frame(height: 200, alignment: .center)
            .padding()
            
            HStack {
                Text("Max Number of Clients")
                    .foregroundColor(Color("BlueGray"))
                    .padding(.horizontal, 30)
                
                Picker("Max Number of Clients", selection: $maxNumClients) {
                    ForEach(2 ..< 101) {
                        Text("\($0 - 1) people")
                    }
                }
                .padding(5)
                .overlay(Capsule(style: .circular)
                    .stroke(Color("BlueGray")))
            }
            
            
            
            
            Button {
                print(maxNumClients + 1)
                if (outingTitle == "") || (outingLocation == "") || (outingDescription == "") || (listOfInstructors == []) {
                    sessionManager.changeAuthStateToAddEvent(error: "Please input all information.")
                } else {
                    sessionManager.saveOuting(title: outingTitle, description: outingDescription, location: outingLocation, startDate: outingStartDate, startTime: outingStartTime, endDate: outingEndDate, endTime: outingEndTime, instructors: listOfInstructors, programType: outingPrograms, maxNumClients: maxNumClients + 1)
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

struct CheckList: View {
    var didClick2: Bool
    var listToAppendTo: [String]
    var program: String
    var originalList: [String]
    

    var body: some View {
        HStack {
            Image(systemName: didClick2 ? "checkmark.square.fill" : "square")
                .foregroundColor(didClick2 ? Color(UIColor.systemBlue) : Color.secondary)
            ListRow(username: program, userType: "", phoneNumber: "")
                .listRowBackground(didClick2 ? Color(red: 0.839, green: 0.839, blue: 0.839) : Color(red: 0.565, green: 0.612, blue: 0.69))
            
        }
    }
}
