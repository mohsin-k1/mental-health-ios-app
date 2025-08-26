//
//  SettingsView.swift
//  Coursework2
//
//  Created by Mohsin Mazhar on 17/02/2025.
//

import SwiftUI
import UserNotifications
import FirebaseAuth

struct SettingsView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme // Detects current color scheme
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false // Stores dark mode preference
    @State private var isNotificationAuthorized = false
    @State private var isLoggedOut = false // Track the logout state
    
    // Add environment variable to manage navigation
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                // Dark Mode Toggle
                Toggle(isOn: $isDarkMode) {
                    Text("Dark Mode")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                
                // Notification Permission Button
                Button(action: handleNotificationPermission) {
                    Text(isNotificationAuthorized ? "Enable Notification" : "Enable Notifications")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(width: 320, height: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.black, lineWidth: 3))
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                }
                .padding()
                
                // Logout Button
                Button(action: logout) {
                    Text("Logout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 320, height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                }
                .padding()
                
                // NavigationLink to move to login screen when logged out
                NavigationLink("", destination: ContentView(), isActive: $isLoggedOut)
                    .hidden()
                
                Spacer()
            }
            .navigationTitle("Settings")
            .background(
                Group {
                    if colorScheme == .dark {
                        Color.black.edgesIgnoringSafeArea(.all) // Dark mode background
                    } else {
                        LinearGradient(gradient: Gradient(colors: [Color.purple, Color.pink]), startPoint: .top, endPoint: .bottom)
                            .edgesIgnoringSafeArea(.all) // Dark mode background
                    }
                }
            )
        }
        .onAppear {
            checkNotificationPermission()
        }
    }
    
    // Logout Function
    func logout() {
        if let user = Auth.auth().currentUser {
            print("User is signed in: \(user.email ?? "No email")")
            do {
                try Auth.auth().signOut()
                print("User logged out")
                self.isLoggedOut = true // Trigger navigation to login screen
            } catch let signOutError as NSError {
                print("Error signing out: %@", signOutError)
            }
        } else {
            print("No user is signed in")
        }
    }
    
    // Checks if the user has granted notification permissions
    func checkNotificationPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                isNotificationAuthorized = settings.authorizationStatus == .authorized
            }
        }
    }
    
    // Handles notification permissions and scheduling
    func handleNotificationPermission() {
        if isNotificationAuthorized {
            scheduleNotification()
        } else {
            requestNotificationPermission()
        }
    }

    // Requests permission for notifications
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            DispatchQueue.main.async {
                if success {
                    isNotificationAuthorized = true
                    scheduleNotification()
                } else {
                    print("Notification permission denied. Please enable it in Settings.")
                    openSettings()
                }
            }
        }
    }
    
    // Schedules a reminder notification every 3 hours
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "MOODWELL"
        content.body = "This is a reminder to use the app."
        
        // Trigger every 3 hours (3 * 60 * 60 seconds)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3 * 60 * 60, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully!")
            }
        }
    }

    // Opens the device settings to manually enable notifications
    func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

#Preview {
    SettingsView()
}
