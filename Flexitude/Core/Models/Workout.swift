import Foundation

struct Workout: Identifiable, Codable {
    let id: UUID
    let userId: String
    let title: String
    let description: String
    let durationMinutes: Int
    let difficulty: String
    let exercises: [Exercise]
    let dateCreated: Date
    let imageName: String?
    
    init(userId: String, title: String, description: String, durationMinutes: Int, difficulty: String, exercises: [Exercise], imageName: String) {
        self.id = UUID()
        self.userId = userId
        self.title = title
        self.description = description
        self.durationMinutes = durationMinutes
        self.difficulty = difficulty
        self.exercises = exercises
        self.dateCreated = Date()
        self.imageName = imageName
    }
}

struct Exercise: Identifiable, Codable {
    let id: UUID
    let name: String
    let reps: Int
    let sets: Int
    let restSeconds: Int
    
    init(name: String, reps: Int, sets: Int, restSeconds: Int) {
        self.id = UUID()
        self.name = name
        self.reps = reps
        self.sets = sets
        self.restSeconds = restSeconds
    }
}
