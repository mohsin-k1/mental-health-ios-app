//
//  ContentView.swift
//  Coursework2
//
//  Created by Mohsin Mazhar on 28/01/2025.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack{
            VStack {
                Text("MOODWELL")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 70) // Creates space between the top and the text
                
                Spacer() // Pushes Content Up
                
                Text("Welcome to MOODWELL")
                    .font(.title2)
                    .fontWeight(.medium)
                    .padding(.horizontal, 40)
                    .padding(.bottom, 20)
                
                //SignUp Button
                NavigationLink(destination:RegisterView()) { // Creating a link within the button to take us to destination
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width:320, height: 50)
                        .background(Color.pink)
                        .cornerRadius(10)
                }
                
                //Login Button
                NavigationLink(destination:LoginView()) { // Creating a link within the button to take us to destination
                    Text("Login") 
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width:320, height: 50)
                        .background(Color.pink)
                        .cornerRadius(10)
                }
                
                Spacer() // Pushes Content Up
                
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
