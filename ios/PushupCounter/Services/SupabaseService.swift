import Foundation

class SupabaseService {
    static let shared = SupabaseService()
    
    // Mock storage
    private var mockWorkouts: [Workout] = []

    private init() {}

    func login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        // TODO: utiliser Supabase Swift SDK
        completion(true)
    }

    func fetchWorkouts(completion: @escaping ([Workout]) -> Void) {
        // Simulate network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            completion(self.mockWorkouts.sorted(by: { $0.startedAt > $1.startedAt }))
        }
    }

    func saveWorkout(workout: Workout, completion: @escaping (Bool) -> Void) {
        // Simulate network delay
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            self.mockWorkouts.append(workout)
            completion(true)
        }
    }
}
