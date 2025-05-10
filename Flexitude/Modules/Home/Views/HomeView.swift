//
//  HomeView.swift
//  Flexitude
//
//  Created by Jack McCowan on 5/5/2025.
//

import SwiftUI

struct HomeView: View {
    @ObservedObject var viewModel: AuthViewModel
    @State private var recentWorkouts: [Workout] = []
    @State private var showMessage = false
    
    private let workoutService = WorkoutService()

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                // Welcome message
                if showMessage {
                    Text("Welcome back, \(viewModel.currentUser?.firstName ?? "")!")
                        .font(.system(size: 30, weight: .bold))
                        .frame(maxWidth: .infinity)
                        .transition(.opacity)
                        .padding(.top)
                }

                Text("Recent Workouts")
                    .font(.title3)
                    .fontWeight(.medium)
                
                if recentWorkouts.isEmpty {
                    Text("You haven't completed any workouts yet.")
                        .foregroundColor(.gray)
                } else {
                    // Workout Cards
                    TabView {
                        ForEach(Array(recentWorkouts.prefix(3).enumerated()), id: \.element.id) { index, workout in
                            VStack(alignment: .leading, spacing: 12) {
                                if let imageName = workout.imageName {
                                    Image(imageName)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(height: 150)
                                        .cornerRadius(12)
                                }

                                VStack(alignment: .leading, spacing: 4) {
                                    Text(workout.title)
                                        .font(.headline)
                                        .fontWeight(.bold)

                                    Text("\(workout.durationMinutes) mins • \(workout.difficulty)")
                                        .font(.subheadline)
                                }
                                .padding(.horizontal)
                                .padding(.bottom, 40)
                            }
                            .background(Color(.gray.opacity(0.5)))
                            .cornerRadius(16)
                            .frame(width: UIScreen.main.bounds.width * 0.8)
                            .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .frame(height: 250)
                }
                Spacer()
            }
            .padding(.horizontal)
            .navigationTitle("Home")
            .onAppear {
                withAnimation(.easeIn(duration: 0.5)) {
                    showMessage = true
                }
                
                // Will use this code once we can add workouts
                // if let userId = viewModel.currentUser?.id.uuidString {
                //    recentWorkouts = workoutService.getWorkouts(for: userId)
                // }
                
                // Add samle workouts for now
                guard let user = viewModel.currentUser else { return }
                let userId = user.id.uuidString

                let existing = workoutService.getWorkouts(for: userId)
                if existing.isEmpty {
                    let sampleSource = WorkoutViewModel(userId: userId)
                    for workout in sampleSource.workouts {
                        workoutService.saveWorkout(workout)
                    }
                }

                recentWorkouts = workoutService.getWorkouts(for: userId)
            }
        }
    }
}

#Preview {
    HomeView(viewModel: AuthViewModel())
}
