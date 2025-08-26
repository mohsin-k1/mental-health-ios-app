//
//  GoalView.swift
//  Coursework2
//
//  Created by Mohsin Mazhar on 22/02/2025.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

// Goal Model
struct Goal: Identifiable, Codable {
    let id: String // Firestore document ID
    var title: String
    var duration: String
    var completed: Bool
    var userId: String // Stores the ID of the user who created the goal

    // Initializer with default values
    init(id: String = UUID().uuidString, title: String, duration: String, userId: String, completed: Bool = false) {
        self.id = id
        self.title = title
        self.duration = duration
        self.completed = completed
        self.userId = userId
    }
}

// Goal Manager
class GoalManager: ObservableObject {
    @Published var goals: [Goal] = [] // Stores the list of goals
    private var db = Firestore.firestore() // Reference to Firestore database
    private var userId: String // Stores the authenticated user's ID


    init() {
        self.userId = Auth.auth().currentUser?.uid ?? "" // Fetch the current user's ID
        self.fetchGoals() // Load goals from Firestore when initialized
    }

    // Add a new goal
    func addGoal(title: String, duration: String) {
        let newGoal = Goal(title: title, duration: duration, userId: userId)
        let goalRef = db.collection("goals").document(newGoal.id)
        
        do {
            try goalRef.setData(from: newGoal) // Save the goal in Firestore
            goals.append(newGoal) // Add the goal to the local list
        } catch {
            print("Error adding goal: \(error.localizedDescription)")
        }
    }

    // Toggle completion status
    func toggleCompletion(goalId: String) {
        if let index = goals.firstIndex(where: { $0.id == goalId }) {
            goals[index].completed.toggle()
            updateGoalCompletion(goalId: goalId, completed: goals[index].completed)
        }
    }

    // Delete a goal
    func deleteGoal(at offsets: IndexSet) {
        for index in offsets {
            let goal = goals[index]
            deleteGoalFromFirestore(goalId: goal.id)
            goals.remove(at: index)
        }
    }

    // Fetch goals from Firestore
    private func fetchGoals() {
        db.collection("goals")
            .whereField("userId", isEqualTo: userId)
            .getDocuments { [weak self] querySnapshot, error in
                if let error = error {
                    print("Error fetching goals: \(error.localizedDescription)")
                    return
                }

                self?.goals = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Goal.self)
                } ?? []
            }
    }

    // Update goal completion in Firestore
    private func updateGoalCompletion(goalId: String, completed: Bool) {
        let goalRef = db.collection("goals").document(goalId)
        goalRef.updateData(["completed": completed])
    }

    // Delete goal from Firestore
    private func deleteGoalFromFirestore(goalId: String) {
        let goalRef = db.collection("goals").document(goalId)
        goalRef.delete { error in
            if let error = error {
                print("Error deleting goal: \(error.localizedDescription)")
            }
        }
    }
}

struct GoalView: View {
    @StateObject private var goalManager = GoalManager() // Instance of GoalManager
    @State private var goalTitle = "" // Stores user input for goal title
    @State private var selectedDuration = "30 minutes" // Stores selected duration by deafualt it is set to 30 mins
    @Environment(\.colorScheme) var colorScheme  // Detects light/dark mode
    
    // Duration options for dropdown
    let minuteOptions = ["5 minutes", "10 minutes", "15 minutes", "20 minutes", "30 minutes", "45 minutes"]
    let hourOptions = ["1 hour", "1.5 hours", "2 hours", "3 hours", "4 hours"]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Goal Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 40)
                
                // Goal Input Form
                VStack(spacing: 10) {
                    ZStack(alignment: .leading) {
                        if goalTitle.isEmpty {
                            Text("Enter Goal Title")
                                .foregroundColor(.white)
                                .padding(.leading, 10)
                        }
                        
                        TextField("", text: $goalTitle)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(10)
                            .foregroundColor(.black)
                            .font(.system(size: 18, weight: .medium))
                    }
                    
                    // Duration Dropdown
                    HStack {
                        Text("Duration: ")
                            .foregroundColor(.white)
                            .font(.system(size: 18))
                        
                        Menu {
                            // Minutes Section
                            Section(header: Text("Minutes")) {
                                ForEach(minuteOptions, id: \.self) { duration in
                                    Button(duration) {
                                        selectedDuration = duration
                                    }
                                }
                            }
                            // Hours Section
                            Section(header: Text("Hours")) {
                                ForEach(hourOptions, id: \.self) { duration in
                                    Button(duration) {
                                        selectedDuration = duration
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedDuration)
                                    .foregroundColor(.white)
                                    .padding(10)
                                Image(systemName: "chevron.down")
                                    .foregroundColor(.white)
                            }
                            .background(Color.black.opacity(0.05))
                            .cornerRadius(10)
                        }
                    }
                    
                    // Add Goal Button
                    Button(action: {
                        if !goalTitle.isEmpty {
                            goalManager.addGoal(title: goalTitle, duration: selectedDuration)
                            goalTitle = ""
                        }
                    }) {
                        Text("Add Goal")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]), startPoint: .leading, endPoint: .trailing)
                            )
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }
                    .disabled(goalTitle.isEmpty)
                    .opacity(goalTitle.isEmpty ? 0.6 : 1.0)
                }
                .padding()
                .background(Color.white.opacity(0.1))
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding(.horizontal)
                
                // List of Goals
                List {
                    ForEach(goalManager.goals) { goal in
                        HStack {
                            Button(action: {
                                goalManager.toggleCompletion(goalId: goal.id)
                            }) {
                                Image(systemName: goal.completed ? "checkmark.square.fill" : "square")
                                    .foregroundColor(goal.completed ? .green : .white)
                                    .font(.title2)
                            }
                            
                            // Display goal details
                            VStack(alignment: .leading) {
                                Text(goal.title)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .strikethrough(goal.completed, color: .gray)
                                Text(goal.duration)
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(
                            LinearGradient(gradient: Gradient(colors: [Color.pink, Color.purple]),
                                           startPoint: .leading,
                                           endPoint: .trailing)
                        )
                        .cornerRadius(10)
                        .shadow(radius: 2)
                    }
                    .onDelete(perform: goalManager.deleteGoal) // Swipe to delete
                }
                .scrollContentBackground(.hidden)
                .background(Color.clear)
                .padding(.horizontal)
            }
            .padding()
            .background(backgroundView) // Background styling
            .navigationTitle("Goals")
        }
    }

    // Background View for Dark Mode
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
}

#Preview {
    GoalView()
}
