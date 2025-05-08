import SwiftUI

struct CreateWorkoutView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: WorkoutViewModel

    @State private var title = ""
    @State private var description = ""
    @State private var duration = 30
    @State private var difficulty = "Beginner"
    
    @State private var exercises: [Exercise] = []
    @State private var newExerciseName = ""
    @State private var newExerciseReps = ""
    @State private var newExerciseSets = ""
    @State private var newExerciseRest = ""

    let difficultyLevels = ["Beginner", "Intermediate", "Advanced"]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    Text("Create New Workout")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top)
                    
                    Group {
                        TextField("Workout Title", text: $title)
                        TextField("Description", text: $description)
                        TextField("Duration (minutes)", value: $duration, formatter: NumberFormatter())
                        Picker("Difficulty", selection: $difficulty) {
                            ForEach(difficultyLevels, id: \.self) { level in
                                Text(level)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Exercises")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ForEach(exercises) { exercise in
                            VStack(alignment: .leading) {
                                Text(exercise.name)
                                    .font(.headline)
                                Text("Sets: \(exercise.sets), Reps: \(exercise.reps), Rest: \(exercise.restSeconds)s")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        Group {
                            TextField("Exercise Name", text: $newExerciseName)
                            TextField("Reps", text: $newExerciseReps)
                                .keyboardType(.numberPad)
                            TextField("Sets", text: $newExerciseSets)
                                .keyboardType(.numberPad)
                            TextField("Rest (seconds)", text: $newExerciseRest)
                                .keyboardType(.numberPad)
                        }
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button(action: addExercise) {
                            Text("Add Exercise")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .padding(.top)
                    }
                    .padding(.horizontal)
                    
                    Button(action: saveWorkout) {
                        Text("Save Workout")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func addExercise() {
        guard
            !newExerciseName.isEmpty,
            let reps = Int(newExerciseReps),
            let sets = Int(newExerciseSets),
            let rest = Int(newExerciseRest)
        else {
            return
        }

        let exercise = Exercise(name: newExerciseName, reps: reps, sets: sets, restSeconds: rest)
        exercises.append(exercise)
        newExerciseName = ""
        newExerciseReps = ""
        newExerciseSets = ""
        newExerciseRest = ""
    }

    private func saveWorkout() {
        let workout = Workout(
            userId: viewModel.userId,
            title: title,
            description: description,
            durationMinutes: duration,
            difficulty: difficulty,
            exercises: exercises,
            imageName: "run",
        )
        viewModel.addWorkout(workout)
        dismiss()
    }
}
