//
//  MomentApp.swift
//  Moment
//
//  Created by Jessica mini on 2026/3/6.
//

import SwiftUI
import SwiftData

@main
struct MomentApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            MoodRecord.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
