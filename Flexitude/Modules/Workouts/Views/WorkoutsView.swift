import SwiftUI

struct WorkoutsView: View {
    @ObservedObject var authViewModel: AuthViewModel
    @StateObject private var viewModel: WorkoutViewModel
    
    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
        _viewModel = StateObject(wrappedValue: WorkoutViewModel(userId: authViewModel.currentUser?.username ?? ""))
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text("Your Workouts")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 40)
                    .padding(.horizontal)

                if viewModel.workouts.isEmpty {
                    Spacer()
                    VStack {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                        
                        Text("No workouts yet.")
                            .font(.headline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    List {
                        ForEach(viewModel.workouts) { workout in
                            NavigationLink(destination: WorkoutDetailView(workout: workout)) {
                                VStack(alignment: .leading) {
                                    Text(workout.title)
                                        .font(.headline)
                                    Text("\(workout.durationMinutes) min • \(workout.difficulty)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                .padding(.vertical, 5)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }

                Spacer()
                
                Button(action: {
                    viewModel.showCreateWorkout = true
                }) {
                    Text("Create New Workout")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)
                .sheet(isPresented: $viewModel.showCreateWorkout) {
                    CreateWorkoutView(viewModel: viewModel)
                }
            }
            .navigationBarHidden(true)
        }
    }
}
