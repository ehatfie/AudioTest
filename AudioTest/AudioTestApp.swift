//
//  AudioTestApp.swift
//  AudioTest
//
//  Created by Erik Hatfield on 5/4/21.
//

import SwiftUI

@main
struct AudioTestApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
