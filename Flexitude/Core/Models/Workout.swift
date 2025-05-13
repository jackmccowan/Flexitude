import Foundation

struct Workout: Identifiable, Codable {
    var id: UUID
    var userId: String
    var title: String
    var description: String
    var durationMinutes: Int
    var difficulty: String
    var exercises: [Exercise]
    var dateCreated: Date
    var imageName: String?
    
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
