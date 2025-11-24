import Foundation

struct Workout: Identifiable, Codable {
    var id: UUID = UUID()
    var userId: UUID
    var startedAt: Date
    var endedAt: Date?
    var device: String
    var totalReps: Int
    var totalDurationSeconds: Int
}
