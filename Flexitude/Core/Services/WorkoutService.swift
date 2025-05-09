//
//  WorkoutService.swift
//  Flexitude
//
//  Created by Michael White on 10/5/2025.
//

import Foundation

class WorkoutService {
    private let workoutsKey = "savedWorkouts"
    
    func saveWorkout(_ workout: Workout) {
        var workouts = getAllWorkouts()
        workouts.append(workout)
        saveAllWorkouts(workouts)
    }
    
    func getAllWorkouts() -> [Workout] {
        guard let data = UserDefaults.standard.data(forKey: workoutsKey) else {
            return []
        }
        return (try? JSONDecoder().decode([Workout].self , from: data)) ?? []
    }
    
    func getWorkouts(for userId: String) -> [Workout] {
        getAllWorkouts()
            .filter { $0.userId == userId }
            .sorted { $0.dateCreated > $1.dateCreated}
    }
    
    private func saveAllWorkouts(_ workouts: [Workout]) {
        if let data = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(data, forKey: workoutsKey)
        }
    }
}
