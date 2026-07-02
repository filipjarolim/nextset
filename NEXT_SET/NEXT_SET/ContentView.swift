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
            AmbientBackground()

            if let exercise = viewModel.activeExercise {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppTheme.sectionSpacing) {
                        HeaderBar(exerciseCount: exercises.count) {
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

                        MetricSummaryRow(
                            completedSets: viewModel.completedSetsCount(for: exercise),
                            totalSets: viewModel.totalSetsCount(for: exercise),
                            targetWeight: viewModel.targetWeight(from: exercise),
                            volume: viewModel.sessionVolume(for: exercise)
                        )

                        ExerciseHeroCard(
                            exerciseName: exercise.name,
                            lastWorkoutSummary: exercise.lastWorkoutSummary,
                            progress: sessionProgress(for: exercise)
                        )

                        TargetBanner(targetText: exercise.targetGoalString)

                        ProgressChartView(
                            points: viewModel.chartPoints(for: exercise),
                            maxReps: viewModel.maxReps(for: exercise)
                        )

                        SectionHeader(
                            title: "Today's Sets",
                            trailing: "\(viewModel.completedSetsCount(for: exercise)) of \(viewModel.totalSetsCount(for: exercise)) done"
                        )

                        VStack(spacing: 10) {
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

                        Spacer(minLength: viewModel.isRestTimerVisible ? 280 : 40)
                    }
                    .padding(AppTheme.horizontalPadding)
                    .padding(.top, 8)
                }
            } else {
                VStack(spacing: 0) {
                    HeaderBar(exerciseCount: 0) {
                        handleAddTapped()
                    }
                    .padding(.horizontal, AppTheme.horizontalPadding)
                    .padding(.top, 8)

                    EmptyStateView {
                        handleAddTapped()
                    }
                }
            }

            if viewModel.isRestTimerVisible {
                RestTimerOverlay(
                    timeText: viewModel.formattedRestTime,
                    progress: viewModel.restProgress,
                    onAddTime: { viewModel.addRestTime(30) },
                    onDismiss: { viewModel.dismissRestTimer() }
                )
                .animation(.spring(response: 0.45, dampingFraction: 0.85), value: viewModel.isRestTimerVisible)
            }

            if viewModel.restTimerFlash {
                Color.neonGreen.opacity(0.15)
                    .ignoresSafeArea()
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }

            if subscriptionManager.showPaywall {
                PaywallView(
                    onUnlock: { subscriptionManager.triggerPurchase() },
                    onDismiss: { subscriptionManager.dismissPaywall() }
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
        guard subscriptionManager.requestAddExercise(currentCount: exercises.count) else { return }
        showAddExerciseSheet = true
    }

    private func sortedSets(for exercise: Exercise) -> [WorkoutSet] {
        exercise.sets.sorted { $0.setNumber < $1.setNumber }
    }

    private func sessionProgress(for exercise: Exercise) -> Double {
        let total = viewModel.totalSetsCount(for: exercise)
        guard total > 0 else { return 0 }
        return Double(viewModel.completedSetsCount(for: exercise)) / Double(total)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Exercise.self, WorkoutSet.self], inMemory: true)
}
