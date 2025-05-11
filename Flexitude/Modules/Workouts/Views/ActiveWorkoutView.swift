//
//  ActiveWorkoutView.swift
//  Flexitude
//
//  Created by Matthew Shelton on 11/5/2025.
//

import SwiftUI

struct ActiveWorkoutView: View {
    let workout: Workout
    @Environment(\.dismiss) var dismiss
    @State private var timeRemaining: Int
    @State private var timerRunning: Bool = true
    
    private var totalDuration: Int {
        workout.durationMinutes * 60
    }
    
    var timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    private var formattedTime: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var progress: Double {
        1.0 - (Double(timeRemaining) / Double(totalDuration))
    }
    
    init(workout: Workout) {
        self.workout = workout
        _timeRemaining = State(initialValue: workout.durationMinutes * 60)
    }
    
    var body: some View {
        VStack(spacing: 30) {
            Text("Active Workout")
                .font(.largeTitle)
                .bold()
            
            Text(formattedTime)
                .font(.system(size: 48, weight: .semibold, design: .monospaced))
            
            HStack(spacing: 20) {
                Button(timerRunning ? "Pause" : "Resume") {
                    timerRunning.toggle()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Stop") {
                    dismiss()
                }
                .buttonStyle(.bordered)
                .tint(.red)
            }
            
            Spacer()
        }
        .padding()
        .onReceive(timer) { _ in
            guard timerRunning else {
                return
            }
            if timeRemaining > 0 {
                timeRemaining -= 1
            }
            else {
                timer.upstream.connect().cancel()
            }
        }
    }
}

#Preview {
    let previewWorkout = Workout(
        userId: "preview",
        title: "Core Strength",
        description: "A tight and toned core routine.",
        durationMinutes: 25,
        difficulty: "Intermediate",
        exercises: [Exercise(name: "Plank", reps: 1, sets: 3, restSeconds: 60)],
        imageName: "abs"
    )
    
    ActiveWorkoutView(workout: previewWorkout)
}

