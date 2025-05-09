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
    
    private let workoutService = WorkoutService()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // Welcome message
                    if let firstName = viewModel.currentUser?.firstName {
                        Text("Welcome back, \(firstName)!")
                            .font(.title2)
                            .fontWeight(.semibold)
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
                        VStack(spacing: 16) {
                            ForEach(recentWorkouts.prefix(3)) { workout in
                                VStack(alignment: .leading, spacing: 12) {
                                    if let imageName = workout.imageName {
                                        Image(imageName)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(height: 180)
                                            .clipped()
                                            .cornerRadius(12)
                                    }
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(workout.title)
                                            .font(.headline)
                                            .fontWeight(.bold)
                                        
                                        Text("\(workout.durationMinutes) mins • \(workout.difficulty)")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.horizontal)
                                    .padding(.bottom)
                                }
                                .background(Color(.systemGray6))
                                .cornerRadius(16)
                                .frame(width: UIScreen.main.bounds.width * 0.8)
                                .frame(maxWidth: .infinity)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Home")
            .onAppear {
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

