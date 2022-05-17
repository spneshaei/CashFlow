//
//  CashFlowApp.swift
//  Shared
//
//  Created by Seyed Parsa Neshaei on 5/17/22.
//

import SwiftUI

@main
struct CashFlowApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
