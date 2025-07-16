//
//  AddBirthdayScreen.swift
//  BirthdayTracker
//
//  Created by Даниил Иваньков on 19.12.2024.
//

import SwiftUI
import NotificationCenter

struct AddBirthdayScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var name: String = ""
    @State var surname: String = ""
    @State var dateOfBirth: Date = Date.now
    
    let dateRange: ClosedRange<Date> = {
        let calendar = Calendar.current
        let startComponents = DateComponents(year: 1900, month: 1, day: 1)
        let endComponents = DateComponents(
            year: calendar.component(.year, from: .now),
            month: calendar.component(.month, from: .now),
            day: calendar.component(.day, from: .now))
        return calendar.date(from:startComponents)!
            ...
            calendar.date(from:endComponents)!
    }()
    
    
    let onClose: () -> Void
    
    var body: some View {
        NavigationStack {
            ScrollView {
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Введите имя")
                        .padding(.top, 20)
                    TextField("Имя", text: $name)

                    Text("Введите фамилию")
                    TextField("Фамилия", text: $surname)
                    
                    Text("Введите дату рождения")
                    DatePicker(selection: $dateOfBirth, in: dateRange, displayedComponents: .date, label: {})
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .center)
                    
                }
            }
            .scrollDismissesKeyboard(.immediately)
            .textFieldStyle(.roundedBorder)
            .toolbar {
                
                ToolbarItem(placement: .principal) {
                    Text("  Добавить\n день рождения")
                        .frame(maxWidth: .infinity, alignment: .center)
                        .multilineTextAlignment(.center)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Закрыть", action: onClose)
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Сохранить") {
                        let person = Person(name: name, surname: surname, birthday: dateOfBirth)
                        modelContext.insert(person)
                        
                        addNotifications(person: person)
                                                
                        do {
                            try modelContext.save()
                            presentationMode.wrappedValue.dismiss()
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                    
                }
            }
            .toolbarTitleDisplayMode(.inline)
            
        }
        .padding()
        .ignoresSafeArea(.container)
    }
    
    private func addNotifications(person: Person) {
        let message = "Cегодня \(name) \(surname) празднует день рожджения!"
        let content = UNMutableNotificationContent()
        content.body = message
        content.sound = .default
        var dateComponents = Calendar.current.dateComponents([.month, .day], from: person.birthday)
        dateComponents.hour = 12
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let identifier = person.id.uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        
        center.add(request)

    }
}


#Preview {
    AddBirthdayScreen(onClose: {})
}
