//
//  SwiftUILearningApp.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/9/12.
//

import SwiftUI
import SwiftData

@main
struct SwiftUILearningApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
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
            JPFMapView()
        }
        .modelContainer(sharedModelContainer)
    }
}
