//
//  Model.swift
//  BirthdayTracker
//
//  Created by Даниил Иваньков on 19.12.2024.
//

import Foundation
import SwiftData

@Model
class Person: Identifiable {
    var id: UUID
    var name: String
    var surname: String
    var birthday: Date
    
    init(name: String, surname: String, birthday: Date) {
        self.id = UUID()
        self.name = name
        self.surname = surname
        self.birthday = birthday
    }
}

