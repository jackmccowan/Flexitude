import Foundation
import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout
    @State private var isActiveWorkoutPresented = false

    var body: some View {
        ScrollView {
            if let imageName = workout.imageName {
                Image(imageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 120)
                    .clipped()
                    .cornerRadius(10)
            }
            VStack(alignment: .leading, spacing: 20) {
                Text(workout.title)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)

                HStack {
                    Text("Duration: \(workout.durationMinutes) min")
                    Spacer()
                    Text("Difficulty: \(workout.difficulty)")
                }
                .font(.subheadline)
                .foregroundColor(.gray)
                
                Text(workout.description)
                    .font(.body)

                Text("Exercises")
                    .font(.title2)
                    .fontWeight(.semibold)

                ForEach(workout.exercises) { exercise in
                    VStack(alignment: .leading) {
                        Text(exercise.name)
                            .font(.headline)
                        Text("Sets: \(exercise.sets) • Reps: \(exercise.reps) • Rest: \(exercise.restSeconds)s")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 4)
                }
                
                Button("Start Workout") {
                    isActiveWorkoutPresented = true
                }
                .buttonStyle(.borderedProminent)
                .frame(maxWidth: .infinity)
                .padding(.top)
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle("Workout")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isActiveWorkoutPresented) {
            ActiveWorkoutView(workout: workout)
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
    
    WorkoutDetailView(workout: previewWorkout)
}
