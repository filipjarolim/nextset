import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Exercise.sortOrder) private var exercises: [Exercise]

    @StateObject private var viewModel = WorkoutViewModel()
    @StateObject private var subscriptionManager = SubscriptionManager()

    @State private var showAddExerciseSheet = false

    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()

            if let exercise = viewModel.activeExercise {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HeaderBar {
                            handleAddTapped()
                        }

                        if exercises.count > 1 {
                            ExercisePickerRow(
                                exercises: exercises,
                                activeExerciseID: exercise.id
                            ) { selected in
                                viewModel.selectExercise(selected)
                            }
                        }

                        ExerciseFocusCard(
                            exerciseName: exercise.name,
                            lastWorkoutSummary: exercise.lastWorkoutSummary
                        )

                        TargetBanner(targetText: exercise.targetGoalString)

                        VStack(spacing: 12) {
                            ForEach(sortedSets(for: exercise), id: \.id) { set in
                                SetRowView(
                                    set: set,
                                    onToggle: {
                                        viewModel.toggleSetCompletion(for: set)
                                    },
                                    onWeightChange: { weight in
                                        viewModel.updateWeight(for: set, weight: weight)
                                    },
                                    onRepsChange: { reps in
                                        viewModel.updateReps(for: set, reps: reps)
                                    }
                                )
                            }
                        }

                        if viewModel.isRestTimerVisible {
                            RestTimerBanner(
                                timeText: viewModel.formattedRestTime,
                                onAddTime: {
                                    viewModel.addRestTime(30)
                                },
                                onDismiss: {
                                    viewModel.dismissRestTimer()
                                }
                            )
                            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: viewModel.isRestTimerVisible)
                        }

                        Spacer(minLength: 24)
                    }
                    .padding(AppTheme.horizontalPadding)
                }
            } else {
                VStack(spacing: 16) {
                    HeaderBar {
                        handleAddTapped()
                    }
                    .padding(.horizontal, AppTheme.horizontalPadding)

                    Spacer()

                    Text("No exercises yet")
                        .font(.headline)
                        .foregroundStyle(Color.white.opacity(0.5))

                    Button("Add your first exercise") {
                        handleAddTapped()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.neonGreen)
                    .clipShape(Capsule())

                    Spacer()
                }
            }

            if viewModel.restTimerFlash {
                Color.neonGreen.opacity(0.12)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
            }

            if subscriptionManager.showPaywall {
                PaywallView(
                    onUnlock: {
                        subscriptionManager.triggerPurchase()
                    },
                    onDismiss: {
                        subscriptionManager.dismissPaywall()
                    }
                )
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            viewModel.configure(modelContext: modelContext)
        }
        .sheet(isPresented: $showAddExerciseSheet) {
            AddExerciseSheet { name, target, summary, setCount, weight, reps in
                viewModel.addExercise(
                    name: name,
                    targetGoal: target,
                    lastSummary: summary,
                    setCount: setCount,
                    defaultWeight: weight,
                    defaultReps: reps
                )
            }
        }
    }

    private func handleAddTapped() {
        guard subscriptionManager.requestAddExercise(currentCount: exercises.count) else {
            return
        }
        showAddExerciseSheet = true
    }

    private func sortedSets(for exercise: Exercise) -> [WorkoutSet] {
        exercise.sets.sorted { $0.setNumber < $1.setNumber }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Exercise.self, WorkoutSet.self], inMemory: true)
}
