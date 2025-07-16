//
//  BirthdayTrackerApp.swift
//  BirthdayTracker
//
//  Created by Даниил Иваньков on 19.12.2024.
//

import SwiftUI
import SwiftData
import UserNotifications

@main
struct BirthdayTrackerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Person.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    let center = UNUserNotificationCenter.current()
    
    init() {
        registerForNotification()
    }
    
    var body: some Scene {
        WindowGroup {
            MainFlow()
        }
        .modelContainer(sharedModelContainer)
    }
    
    func registerForNotification() {
        //For device token and push notifications.
        UIApplication.shared.registerForRemoteNotifications()
        
        let center : UNUserNotificationCenter = UNUserNotificationCenter.current()
        //        center.delegate = self
        
        center.requestAuthorization(options: [.sound , .alert , .badge ], completionHandler: { (granted, error) in
            if ((error != nil)) { UIApplication.shared.registerForRemoteNotifications() }
            else {
                
            }
        })
    }
    
}

