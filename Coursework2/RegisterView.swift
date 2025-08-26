//
//  RegisterView.swift
//  Coursework2
//
//  Created by Mohsin Mazhar on 28/01/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct RegisterView: View {
    // Variables to store user input and application state
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var errorMessage = ""
    @State private var isRegistered = false
    @State private var isLoading = false // Track loading state
    @AppStorage("moodHistory") private var moodHistoryData: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("MOODWELL")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 70)
                
                Spacer()
                // If registration is in progress, show a loading spinner
                if isLoading {
                    ProgressView() // Circular loading indicator
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                        .padding()
                    Text("Please wait...") // Informing the user to wait
                        .font(.headline)
                        .foregroundColor(.gray)
                } else {
                    Text("Create a New Account:")
                    
                    // Email input field
                    TextField("Email", text: $email)
                        .padding()
                        .autocapitalization(.none)
                        .frame(width: 320, height: 50)
                        .cornerRadius(10)
                        .background(Color.black.opacity(0.05))
                    
                    // Password input field
                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 320, height: 50)
                        .cornerRadius(10)
                        .background(Color.black.opacity(0.05))
                    
                    // Confirm Password input field
                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .frame(width: 320, height: 50)
                        .cornerRadius(10)
                        .background(Color.black.opacity(0.05))
                    
                    // Displays an error message if inputs are empty
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    Button(action: { register() }) {
                        Text("Sign Up")
                    }
                    .foregroundColor(.white)
                    .frame(width: 320, height: 50)
                    .background(Color.pink)
                    .cornerRadius(10)
                }
                
                Spacer()
            }
            .padding()
            // Navigate to HomeView after successful registration
            .navigationDestination(isPresented: $isRegistered) {
                HomeView()
            }
        }
    }
    
    func register() {
        errorMessage = ""
        isLoading = true // Start loading animation
        
        // Validate password length and ensure it contains a number
        guard password.count >= 8, password.rangeOfCharacter(from: .decimalDigits) != nil else {
            errorMessage = "Password must be at least 8 characters long and include a number."
            isLoading = false
            return
        }
        
        // Ensure password and confirm password match
        guard password == confirmPassword else {
            errorMessage = "Passwords do not match."
            isLoading = false // Stop loading animation
            return
        }
        
        // Use Firebase Authentication to create a new user with email and password
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            DispatchQueue.main.async {
                isLoading = false // Stop loading animation
                
                if let error = error {
                    errorMessage = error.localizedDescription
                } else if let userID = result?.user.uid {
                    // Store the user ID and mood history data in UserDefaults
                    UserDefaults.standard.set(userID, forKey: "currentUserID")
                    UserDefaults.standard.set("", forKey: "moodHistory_\(userID)")
                    isRegistered = true // Set registration as successful
                }
            }
        }
    }
}

#Preview {
    RegisterView()
}
