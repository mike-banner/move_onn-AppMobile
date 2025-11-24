import SwiftUI

struct WorkoutView: View {
    @State private var workouts: [Workout] = []
    
    var body: some View {
        List(workouts) { workout in
            HStack {
                VStack(alignment: .leading) {
                    Text("Séance du \(formattedDate(workout.startedAt))")
                        .font(.headline)
                    Text("Durée: \(formatDuration(workout.totalDurationSeconds))")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Text("\(workout.totalReps) reps")
                    .font(.title3)
                    .bold()
                    .foregroundColor(.blue)
            }
        }
        .navigationTitle("Historique")
        .onAppear {
            loadWorkouts()
        }
    }
    
    private func loadWorkouts() {
        SupabaseService.shared.fetchWorkouts { fetchedWorkouts in
            DispatchQueue.main.async {
                self.workouts = fetchedWorkouts
            }
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct WorkoutView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WorkoutView()
        }
    }
}
