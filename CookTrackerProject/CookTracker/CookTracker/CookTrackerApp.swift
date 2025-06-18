//
//  CookTrackerApp.swift
//  CookTracker
//
//  Created by Tsubasa Kubota on 2025/06/15.
//

import SwiftUI

@main
struct CookTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(CookingSessionManager.shared)
        }
    }
}
