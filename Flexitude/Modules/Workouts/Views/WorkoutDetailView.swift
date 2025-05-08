import SwiftUI

struct WorkoutDetailView: View {
    let workout: Workout

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

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Workout")
        .navigationBarTitleDisplayMode(.inline)
    }
}

