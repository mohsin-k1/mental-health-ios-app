//
//  HomeView.swift
//  Coursework2
//
//  Created by Mohsin Mazhar on 30/01/2025.
//

import SwiftUI

struct HomeView: View {
    init() {
        // Customize the appearance of the Tab Bar for iOS 15+
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .clear  // Make the background transparent (or customize as needed)
        appearance.stackedLayoutAppearance.selected.iconColor = .white  // Set selected icon color to white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]  // Set selected title color to white
        appearance.stackedLayoutAppearance.normal.iconColor = .white  // Set unselected icon color to white
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]  // Set unselected title color to white

        // Apply the custom appearance to the tab bar
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
    
    var body: some View {
        NavigationView {
            TabView {  // TabView is a container that allows you to switch between multiple views by selecting tabs (Bottom Nav)
                MainView()
                    .tabItem {
                        Image(systemName: "house.fill") // Icon for the Home tab
                        Text("Home")
                    }
                
                GoalView()
                    .tabItem {
                        Image(systemName: "target") // Icon for the Goal tab
                        Text("Goal")
                    }
                
                ActivityView()
                    .tabItem {
                        Image(systemName: "chart.bar.fill") // Icon for the Insight tab
                        Text("Activity")
                    }
                
                SettingsView()
                    .tabItem {
                        Image(systemName: "gearshape.fill") // Icon for the Settings tab
                        Text("Settings")
                    }
            }
            .navigationBarBackButtonHidden(true)
        }
    }
}

#Preview {
    HomeView()
}
