//
//  CashFlowApp.swift
//  CashFlow W WatchKit Extension
//
//  Created by Seyed Parsa Neshaei on 5/18/22.
//

import SwiftUI

@main
struct CashFlowApp: App {
    let persistenceController = PersistenceController.shared
    
    @SceneBuilder var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }

        WKNotificationScene(controller: NotificationController.self, category: "myCategory")
    }
}
