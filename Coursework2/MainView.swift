//
//  MainView.swift
//  Coursework2
//
//  Created by Mohsin Mazhar on 30/01/2025.
//

import SwiftUI
import UIKit

struct MainView: View {
    // State variables for camera and mood tracking
    @State private var isShowingCamera = false
    @State private var capturedImage: UIImage?
    @AppStorage("selectedMood") private var storedMood = ""
    @Environment(\.colorScheme) var colorScheme  // Detect dark mode

    // Mood categories
    let positiveMoods = ["Happy 😊", "Excited 🤩", "Grateful 🙏", "Loved ❤️", "Confident 💪", "Motivated 🚀", "Inspired ✨", "Hopeful 🌟"]
    let neutralMoods = ["Content 🙂", "Calm 🧘", "Curious 🤔", "Balanced ⚖️", "Indifferent 😐", "Pensive 🤨", "Uncertain 🤷‍♂️", "Bored 😑"]
    let negativeMoods = ["Sad 😢", "Lonely 😞", "Anxious 😰", "Stressed 😖", "Angry 😡", "Frustrated 😤", "Tired 😴", "Nervous 😬"]

    // Generates today's date
    var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: Date())
    }

    var body: some View {
        NavigationView {
            VStack {
                Text(todayString)
                    .font(.title)
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .padding(.top, 20)
                
                Spacer()
                // Mood selection prompt
                Text("How are you feeling today?")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.top, 10)
                
                moodDropdown  // Mood selection dropdown
                
                Spacer()
                
                selfieSection // Selfie capture section
                
                Spacer()
            }
            .padding()
            .background(backgroundView)
            .navigationTitle("Home")
        }
    }
    
    // Background adapts to dark mode
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

    // Mood Selection Dropdown
    private var moodDropdown: some View {
        Menu {
            moodSection(title: "Positive Emotions", moods: positiveMoods, color: .green)
            moodSection(title: "Neutral Emotions", moods: neutralMoods, color: .gray)
            moodSection(title: "Negative Emotions", moods: negativeMoods, color: .red)
        } label: {
            HStack {
                Text(storedMood.isEmpty ? "How are you feeling today?" : storedMood)
                    .font(.title3)
                    .foregroundColor(colorScheme == .dark ? .white : .black)
                Spacer()
                Image(systemName: "chevron.down")
                    .foregroundColor(colorScheme == .dark ? .white : .black)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.2))
            .cornerRadius(10)
            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white, lineWidth: 2))
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
        }
        .padding(.horizontal)
    }
    
    private func moodSection(title: String, moods: [String], color: Color) -> some View {
        Section(header: Text(title).foregroundColor(color)) {
            ForEach(moods, id: \.self) { mood in
                Button(action: { logMood(mood) }) {
                    Text(mood)
                        .padding()
                        .background(storedMood == mood ? color.opacity(0.3) : Color.clear)
                        .cornerRadius(10)
                        .foregroundColor(.primary)
                }
            }
        }
    }

    // Selfie Section
    private var selfieSection: some View {
        VStack {
            Text("Take a Selfie to Show Your Mood")
                .font(.headline)
                .foregroundColor(.white)
                .padding(.top, 20)
            
            // Display captured image or a placeholder message
            if let image = capturedImage {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 250)
                    .cornerRadius(10)
            } else {
                Text("No Image Captured")
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            // Camera button to capture an image
            Button(action: { isShowingCamera = true }) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 30))
                    .padding()
                    .background(Color.white.opacity(0.2))
                    .foregroundColor(.white)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 3))
                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
            }
            .padding()
            .sheet(isPresented: $isShowingCamera) {
                CameraView(capturedImage: $capturedImage)
            }
        }
    }

    // ✅ Function to log mood per user
    private func logMood(_ mood: String) {
        guard let userID = UserDefaults.standard.string(forKey: "currentUserID") else {
            print("User ID not found")
            return
        }

        storedMood = mood
        let key = "moodHistory_\(userID)"
        let timestamp = DateFormatter.localizedString(from: Date(), dateStyle: .short, timeStyle: .short)
        let newEntry = "\(timestamp) - \(mood)"

        var historyArray = UserDefaults.standard.string(forKey: key)?.components(separatedBy: "|") ?? []
        historyArray.append(newEntry)

        if historyArray.count > 10 {
            historyArray.removeFirst() // Keep only the last 10 entries
        }

        UserDefaults.standard.set(historyArray.joined(separator: "|"), forKey: key)
    }
}

// MARK: - CameraView (Handles Image Capture and Saves Locally)
struct CameraView: UIViewControllerRepresentable {
    @Binding var capturedImage: UIImage?

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera // Opens the device camera
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator Class (Handles Image Capture Events)
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView

        init(_ parent: CameraView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.capturedImage = image
                UIImageWriteToSavedPhotosAlbum(image, self, #selector(imageSaved(_:didFinishSavingWithError:contextInfo:)), nil)
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }

        // MARK: - Save Completion Handler
        @objc func imageSaved(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
            if let error = error {
                print("Error saving photo: \(error.localizedDescription)")
            } else {
                print("Photo saved successfully!")
            }
        }
    }
}

#Preview {
    MainView()
}
