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
    @AppStorage("hasAcceptedTerms") private var hasAcceptedTerms = false

    var body: some Scene {
        WindowGroup {
            if hasAcceptedTerms {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(CookingSessionManager.shared)
            } else {
                OnboardingView(hasAcceptedTerms: $hasAcceptedTerms)
            }
        }
    }
}
