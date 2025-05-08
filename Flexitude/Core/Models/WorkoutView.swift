import Foundation

class WorkoutViewModel: ObservableObject {
    @Published var workouts: [Workout] = []
    @Published var showCreateWorkout = false

    let userId: String

    init(userId: String) {
        self.userId = userId
        loadSampleData()
    }

    func addWorkout(_ workout: Workout) {
        workouts.append(workout)
    }

    func loadSampleData() {
        workouts = [
            Workout(
                userId: userId,
                title: "Morning Yoga",
                description: "A calming yoga session to start your day.",
                durationMinutes: 20,
                difficulty: "Beginner",
                exercises: [Exercise(name: "Sun Salutation", reps: 5, sets: 2, restSeconds: 30)],
                imageName: "yoga"
            ),
            Workout(
                userId: userId,
                title: "Calisthenics Intro",
                description: "Bodyweight training for all levels.",
                durationMinutes: 30,
                difficulty: "Intermediate",
                exercises: [Exercise(name: "Pull-ups", reps: 8, sets: 3, restSeconds: 60)],
                imageName: "cali"
            ),
            Workout(
                userId: userId,
                title: "Upper Body Blast",
                description: "Build strength in chest, shoulders, and arms.",
                durationMinutes: 40,
                difficulty: "Intermediate",
                exercises: [Exercise(name: "Push-ups", reps: 12, sets: 4, restSeconds: 60)],
                imageName: "push"
            ),
            Workout(
                userId: userId,
                title: "Leg Day",
                description: "Squats, lunges, and presses to grow your lower body.",
                durationMinutes: 45,
                difficulty: "Advanced",
                exercises: [Exercise(name: "Squats", reps: 10, sets: 4, restSeconds: 90)],
                imageName: "deadlift"
            ),
            Workout(
                userId: userId,
                title: "Core Strength",
                description: "A tight and toned core routine.",
                durationMinutes: 25,
                difficulty: "Intermediate",
                exercises: [Exercise(name: "Plank", reps: 1, sets: 3, restSeconds: 60)],
                imageName: "abs"
            ),
            Workout(
                userId: userId,
                title: "Full Body Burn",
                description: "An intense circuit hitting all major muscle groups.",
                durationMinutes: 35,
                difficulty: "Intermediate",
                exercises: [Exercise(name: "Jump Squats", reps: 12, sets: 3, restSeconds: 45)],
                imageName: "deadlift"
            ),
            Workout(
                userId: userId,
                title: "Morning Stretch",
                description: "Loosen up with this full-body stretch.",
                durationMinutes: 15,
                difficulty: "Beginner",
                exercises: [Exercise(name: "Neck Rolls", reps: 5, sets: 2, restSeconds: 15)],
                imageName: "running"
            ),
            Workout(
                userId: userId,
                title: "Cardio Blast",
                description: "Get your heart rate up with sprints and jumps.",
                durationMinutes: 30,
                difficulty: "Intermediate",
                exercises: [Exercise(name: "Jumping Jacks", reps: 30, sets: 3, restSeconds: 30)],
                imageName: "running"
            ),
            Workout(
                userId: userId,
                title: "Strength Training",
                description: "Build muscle with compound lifts.",
                durationMinutes: 50,
                difficulty: "Advanced",
                exercises: [Exercise(name: "Deadlift", reps: 5, sets: 5, restSeconds: 120)],
                imageName: "cali2"
            ),
            Workout(
                userId: userId,
                title: "Pilates Flow",
                description: "Strengthen and elongate muscles through flow.",
                durationMinutes: 30,
                difficulty: "Beginner",
                exercises: [Exercise(name: "Leg Circles", reps: 10, sets: 3, restSeconds: 20)],
                imageName: "abs"
            )
        ]
    }
}
