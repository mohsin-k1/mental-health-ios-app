//
//  LoginView.swift
//  Coursework2
//
//  Created by Mohsin Mazhar on 28/01/2025.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    // Variables to store user input and application state
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var isLoggedIn: Bool = false
    @State private var isLoading = false // Track loading state
    
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
                    Text("Enter Your Details to Sign In:")
                    
                    // Email input field
                    TextField("Email", text: $email)
                        .padding()
                        .autocapitalization(.none)
                        .frame(width: 320, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    
                    // Paasword input field
                    SecureField("Password", text: $password)
                        .padding()
                        .frame(width: 320, height: 50)
                        .background(Color.black.opacity(0.05))
                        .cornerRadius(10)
                    
                    // Displays an error message if inputs are empty
                    if !errorMessage.isEmpty {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, 5)
                    }
                    
                    Button(action: { login() }) {
                        Text("Sign In")
                            .foregroundColor(.white)
                            .frame(width: 320, height: 50)
                            .background(Color.pink)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }
                
                Spacer()
            }
            .padding()
            // Navigate to HomeView after successful login
            .navigationDestination(isPresented: $isLoggedIn) {
                HomeView()
            }
        }
    }
    
    func login() {
        errorMessage = ""
        isLoading = true // Start loading animation
        
        // Ensure that both email and password fields are not empty
        guard !email.isEmpty, !password.isEmpty else {
            errorMessage = "Please enter both email and password."
            isLoading = false
            return
        }
        
        // Authenticate user using Firebase
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            DispatchQueue.main.async {
                isLoading = false // Stop loading animation
                
                if let error = error {
                    errorMessage = error.localizedDescription
                } else if let userID = result?.user.uid {
                    // Store user ID in UserDefaults for future reference
                    UserDefaults.standard.set(userID, forKey: "currentUserID")
                    isLoggedIn = true
                }
            }
        }
    }
}

#Preview {
    LoginView()
}
