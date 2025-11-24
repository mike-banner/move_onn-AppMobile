import SwiftUI

struct ContentView: View {
    @StateObject var workoutVM = WorkoutViewModel()

    var body: some View {
        NavigationView {
            ZStack {
                // Camera Background
                if workoutVM.isWorkoutActive {
                    PoseDetectorView(viewModel: workoutVM)
                        .edgesIgnoringSafeArea(.all)
                } else {
                    Color.black.edgesIgnoringSafeArea(.all)
                }
                
                // Overlay UI
                VStack(spacing: 20) {
                    if workoutVM.isWorkoutActive {
                        // Active Workout UI
                        VStack {
                            Text("\(workoutVM.currentReps)")
                                .font(.system(size: 100, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                            
                            Text("POMPES")
                                .font(.title)
                                .foregroundColor(.white)
                                .bold()
                            
                            Text(formatDuration(workoutVM.workoutDuration))
                                .font(.title2)
                                .foregroundColor(.yellow)
                                .padding(.top, 5)
                        }
                        .padding(.top, 50)
                        
                        Spacer()
                        
                        Button(action: {
                            workoutVM.endWorkout()
                        }) {
                            Text("TERMINER")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(15)
                                .padding(.horizontal, 40)
                                .padding(.bottom, 40)
                        }
                    } else {
                        // Idle UI
                        VStack(spacing: 30) {
                            Text("Pushup Counter")
                                .font(.largeTitle)
                                .bold()
                                .foregroundColor(.white)
                            
                            Text("Prêt à transpirer ?")
                                .font(.title3)
                                .foregroundColor(.gray)
                            
                            Button(action: {
                                workoutVM.startWorkout()
                            }) {
                                Text("COMMENCER LA SÉANCE")
                                    .font(.headline)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(15)
                                    .padding(.horizontal, 40)
                            }
                            
                            NavigationLink(destination: WorkoutView()) {
                                Text("Voir l'historique")
                                    .foregroundColor(.blue)
                                    .padding()
                            }
                        }
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
