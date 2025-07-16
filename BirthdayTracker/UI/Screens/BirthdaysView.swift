//
//  BirthdaysView.swift
//  BirthdayTracker
//
//  Created by Даниил Иваньков on 19.12.2024.
//
import Foundation
import SwiftData
import SwiftUI
import UserNotifications

struct BirthdaysView: View {
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        
        VStack {
            PersonListingView()
        }
        .navigationTitle("Дни рождения")
        
        .padding()
    }
    

}



private struct PersonView: View {
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ru_RU")
        formatter.dateFormat = "d MMMM yyyy"

        return formatter
    }()
    let person: Person
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("\(person.name) \(person.surname)")
                .font(Font.system(size: 22))
                .fontWeight(.bold)
                .font(.headline)
            if isBirthdayToday() {
                Text("\(person.birthday, formatter: dateFormatter) 🎂")
                Text("Поздравьте с днем рождения!")
                    .fontWeight(.semibold)
            } else {
                Text("\(person.birthday, formatter: dateFormatter)")
            }
        }
    }
    
    private func isBirthdayToday() -> Bool {
        let calendar = Calendar.current
        let today = calendar.date(from: DateComponents(month: calendar.component(.month, from: Date.now), day: calendar.component(.day, from: Date.now)))
        let birthday = calendar.date(from: DateComponents(month: calendar.component(.month, from: person.birthday), day: calendar.component(.day, from: person.birthday)))

        
        return today == birthday
    }
}

struct PersonListingView: View {
    @Environment(\.modelContext) var modelContext
    @Query var person: [Person]
    @State var sortOption: SortingOption = .idSort
    
    
    var filteredPerson: [Person] {
        let filteredPerson = person
        return filteredPerson.sort(on: sortOption)
    }
    
    var body: some View {
        HStack {
            if person.isEmpty {
                Text("Нажмите на + для добавления дня рождения")
            } else {
                List {
                    ForEach(filteredPerson) { person in
                        PersonView(person: person)
                            .swipeActions {
                                Button("Удалить", role: .destructive) {
                                    deletePerson(person)
                                }
                            }
                    }
                    
                }
                .listStyle(.plain)
                .toolbar(content: {
                    
                    ToolbarItem(placement: .topBarLeading) {
                        
                        
                        Menu("Сортировка", systemImage: "arrow.up.arrow.down") {
                            
                            Picker("Сортировка", selection: $sortOption) {
                                Text("\(SortingOption.idSort.rawValue)")
                                    .tag(SortingOption.idSort)
                                
                                Text("\(SortingOption.surnameSort.rawValue)")
                                    .tag(SortingOption.surnameSort)
                                
                                Text("\(SortingOption.closeToNow.rawValue)")
                                    .tag(SortingOption.closeToNow)
                            }
                            .pickerStyle(.inline)
                        }
                    }
                    
                })
            }
        }
    }
    
    func deletePerson(_ person: Person) {
        modelContext.delete(person)
        
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [person.id.uuidString])
    }
}

enum SortingOption: String, CaseIterable {
    case idSort = "Сначала новые"
    case surnameSort = "По фамилии"
    case closeToNow = "Ближайшее др"
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Person.self, configurations: config)
    
    for i in 1..<10 {
        let person = Person(
            name: "Name \(i)",
            surname: "Surname \(i)",
            birthday: Date(timeIntervalSinceNow: Double(-86400 * i))
        )
        container.mainContext.insert(person)
    }
    
    return BirthdaysView()

    
}


private extension [Person] {
    
    func sort(on option: SortingOption) -> [Person] {
        switch option {
        case .idSort:
            return self.sorted { $0.id < $1.id }
        case .surnameSort:
            return self.sorted { $0.surname < $1.surname }
        case .closeToNow:
            let today = Date()
            let calendar = Calendar.current
            
            return self.sorted {
                let distance1 = cyclicDayDifference(from: $0.birthday, to: today, calendar: calendar)
                let distance2 = cyclicDayDifference(from: $1.birthday, to: today, calendar: calendar)
                return distance1 < distance2
            }
        }
    }
    //Sort by closest Day
    func cyclicDayDifference(from date: Date, to today: Date, calendar: Calendar) -> Int {
        
        let referenceYear = calendar.component(.year, from: today)
        
        let referenceToday = calendar.date(from: DateComponents(year: referenceYear, month: calendar.component(.month, from: today), day: calendar.component(.day, from: today)))!
        let targetDate = calendar.date(from: DateComponents(year: referenceYear, month: calendar.component(.month, from: date), day: calendar.component(.day, from: date)))!
        
        
        if calendar.compare(targetDate, to: referenceToday, toGranularity: .day) == .orderedAscending {
            let adjustedDate = calendar.date(byAdding: .year, value: 1, to: targetDate)!
            return Int(adjustedDate.timeIntervalSince(referenceToday))
        } else {
            return Int(targetDate.timeIntervalSince(referenceToday))
        }
    }


}
