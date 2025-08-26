//
//  ActivityView.swift
//  Coursework2
//
//  Created by Mohsin Mazhar on 03/03/2025.
//

import SwiftUI

struct ActivityView: View {
    @State private var moodHistory: [String] = []
    @Environment(\.colorScheme) var colorScheme  // Detects dark mode

    var body: some View {
        NavigationView {
            ZStack {
                backgroundView  // Dark mode optimized background
                
                VStack {
                    Text("Mood History")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()
                    
                    if moodHistory.isEmpty {
                        Text("No mood history recorded.")
                            .foregroundColor(.white)
                            .padding()
                    } else {
                        List {
                            ForEach(Array(moodHistory.enumerated().reversed()), id: \.element) { index, entry in
                                Text(entry)
                                    .foregroundColor(colorScheme == .dark ? .white : .black)
                            }
                            .onDelete(perform: deleteMood)
                        }
                        .listStyle(InsetGroupedListStyle())
                        .background(Color.clear) // Keeps list transparent
                    }
                    
                    Spacer() // Ensures content fills screen
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity) // Expands VStack to full size
            }
            .navigationTitle("Activity")
            .onAppear {
                ensureUserID()
                loadMoodHistory()
            }
        }
    }
    
    // Background View for Dark Mode Support
    private var backgroundView: some View {
        Group {
            if colorScheme == .dark {
                Color.black.edgesIgnoringSafeArea(.all)
            } else {
                LinearGradient(gradient: Gradient(colors: [Color.purple, Color.pink]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
    
    // Ensures a user ID is available, setting a default if necessary
    private func ensureUserID() {
        if UserDefaults.standard.string(forKey: "currentUserID") == nil {
            UserDefaults.standard.set("testUser123", forKey: "currentUserID")
            print("Set default user ID")
        }
    }
    
    // Loads the mood history from UserDefaults
    private func loadMoodHistory() {
        guard let userID = UserDefaults.standard.string(forKey: "currentUserID") else {
            print("User ID not found")
            return
        }
        let key = "moodHistory_\(userID)"
        if let storedData = UserDefaults.standard.string(forKey: key) {
            DispatchQueue.main.async {
                self.moodHistory = storedData.components(separatedBy: "|").filter { !$0.isEmpty }
            }
            print("Loaded mood history: \(self.moodHistory)")
        } else {
            print("No mood history found for key: \(key)")
        }
    }
    
    // Deletes a mood entry from the history and updates UserDefaults
    private func deleteMood(at offsets: IndexSet) {
        guard let userID = UserDefaults.standard.string(forKey: "currentUserID") else {
            print("User ID not found")
            return
        }
        
        // Convert offsets for reversed order
        let adjustedOffsets = offsets.map { moodHistory.count - 1 - $0 }

        var updatedHistory = moodHistory
        updatedHistory.remove(atOffsets: IndexSet(adjustedOffsets))

        let key = "moodHistory_\(userID)"
        UserDefaults.standard.set(updatedHistory.joined(separator: "|"), forKey: key)
        
        DispatchQueue.main.async {
            self.moodHistory = updatedHistory
        }
    }
}

#Preview {
    ActivityView()
}
