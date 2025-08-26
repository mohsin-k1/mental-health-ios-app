//
//  Coursework2App.swift
//  Coursework2
//
//  Created by Mohsin Mazhar on 28/01/2025.
//

import SwiftUI
import Firebase

@main
struct Coursework2App: App {
    init () {
        // Configures Firebase with default settings when the app is launched
        FirebaseApp.configure()
        // Initializes Firebase and makes sure it is set up properly for use within the app.

    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
