import Foundation
import Combine

class WorkoutViewModel: ObservableObject {
    @Published var currentReps: Int = 0
    @Published var isWorkoutActive: Bool = false
    @Published var workoutDuration: Int = 0
    
    private var timer: Timer?
    private var startDate: Date?
    
    func startWorkout() {
        currentReps = 0
        workoutDuration = 0
        isWorkoutActive = true
        startDate = Date()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.workoutDuration += 1
        }
    }

    func endWorkout() {
        guard isWorkoutActive, let start = startDate else { return }
        
        isWorkoutActive = false
        timer?.invalidate()
        timer = nil
        
        let workout = Workout(
            userId: UUID(), // Mock User ID
            startedAt: start,
            endedAt: Date(),
            device: "iPhone",
            totalReps: currentReps,
            totalDurationSeconds: workoutDuration
        )
        
        SupabaseService.shared.saveWorkout(workout: workout) { success in
            if success {
                print("Workout saved successfully")
            } else {
                print("Failed to save workout")
            }
        }
    }

    func incrementReps() {
        guard isWorkoutActive else { return }
        currentReps += 1
    }
}
