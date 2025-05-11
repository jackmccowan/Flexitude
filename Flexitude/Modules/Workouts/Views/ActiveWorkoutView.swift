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
            Text(workout.title)
                .font(.largeTitle)
                .bold()
            
            Text("Difficulty: \(workout.difficulty)")
                .font(.subheadline)
                .foregroundColor(.gray)
            
            // Progress Circle with Time Remaining
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.3), lineWidth: 30)
                    .frame(width: 200, height: 200)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: progress)
                    .frame(width: 200, height: 200)
                
                Text(formattedTime)
                    .font(.system(size: 48, weight: .semibold, design: .monospaced))
            }
            .padding(.top)
        
            // Controls (Pause/Resume and Stop)
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
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Exercises")
                    .font(.headline)
                
                ForEach(workout.exercises) { exercise in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(exercise.name)
                            .fontWeight(.semibold)
                        
                        Text("Sets: \(exercise.sets), Reps: \(exercise.reps), Rest: \(exercise.restSeconds)s")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
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
                timerRunning = false
            }
        }
    }
}

#Preview {
    let previewWorkout = Workout(
        userId: "preview",
        title: "Core Strength",
        description: "A tight and toned core routine.",
        durationMinutes: 1,
        difficulty: "Intermediate",
        exercises: [Exercise(name: "Plank", reps: 1, sets: 3, restSeconds: 60)],
        imageName: "abs"
    )
    
    ActiveWorkoutView(workout: previewWorkout)
}

