import Foundation
import SwiftData
import SwiftUI
import UIKit

@MainActor
final class WorkoutViewModel: ObservableObject {
    @Published private(set) var activeExercise: Exercise?
    @Published var restSecondsRemaining: Int = 0
    @Published var isRestTimerVisible: Bool = false
    @Published var restTimerFlash: Bool = false

    private var modelContext: ModelContext?
    private var restTimerTask: Task<Void, Never>?
    private let defaultRestDuration = 90

    var formattedRestTime: String {
        let minutes = restSecondsRemaining / 60
        let seconds = restSecondsRemaining % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        seedSampleDataIfNeeded()
        loadActiveExercise()
    }

    func loadActiveExercise() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<Exercise>(
            sortBy: [SortDescriptor(\.sortOrder, order: .forward)]
        )

        do {
            let exercises = try modelContext.fetch(descriptor)
            activeExercise = exercises.first
        } catch {
            activeExercise = nil
        }
    }

    func toggleSetCompletion(for set: WorkoutSet) {
        set.isCompleted.toggle()
        save()

        if set.isCompleted {
            startRestTimer()
        }
    }

    func updateWeight(for set: WorkoutSet, weight: Double) {
        set.weight = max(0, weight)
        save()
    }

    func updateReps(for set: WorkoutSet, reps: Int) {
        set.reps = max(0, reps)
        save()
    }

    func addExercise(
        name: String,
        targetGoal: String,
        lastSummary: String,
        setCount: Int,
        defaultWeight: Double,
        defaultReps: Int
    ) {
        guard let modelContext else { return }

        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmedName.isEmpty == false else { return }

        let descriptor = FetchDescriptor<Exercise>()
        let existingCount = (try? modelContext.fetchCount(descriptor)) ?? 0

        let sets = Exercise.makeDefaultSets(
            count: setCount,
            weight: defaultWeight,
            reps: defaultReps
        )

        let exercise = Exercise(
            name: trimmedName,
            targetGoalString: targetGoal.trimmingCharacters(in: .whitespacesAndNewlines),
            lastWorkoutSummary: lastSummary.trimmingCharacters(in: .whitespacesAndNewlines),
            sortOrder: existingCount,
            sets: sets
        )

        modelContext.insert(exercise)
        for workoutSet in sets {
            workoutSet.exercise = exercise
            modelContext.insert(workoutSet)
        }

        save()
        activeExercise = exercise
    }

    func selectExercise(_ exercise: Exercise) {
        activeExercise = exercise
    }

    func startRestTimer(duration: Int? = nil) {
        restTimerTask?.cancel()

        let seconds = duration ?? defaultRestDuration
        restSecondsRemaining = seconds
        isRestTimerVisible = true

        restTimerTask = Task { [weak self] in
            guard let self else { return }

            while !Task.isCancelled, self.restSecondsRemaining > 0 {
                try? await Task.sleep(for: .seconds(1))
                guard !Task.isCancelled else { return }
                self.restSecondsRemaining -= 1
            }

            guard !Task.isCancelled else { return }
            await self.handleRestTimerFinished()
        }
    }

    func addRestTime(_ seconds: Int = 30) {
        restSecondsRemaining += seconds
        if isRestTimerVisible == false {
            isRestTimerVisible = true
        }
    }

    func dismissRestTimer() {
        restTimerTask?.cancel()
        restTimerTask = nil
        isRestTimerVisible = false
        restSecondsRemaining = 0
    }

    private func handleRestTimerFinished() {
        triggerCompletionFeedback()
        withAnimation(.easeOut(duration: 0.35)) {
            isRestTimerVisible = false
            restSecondsRemaining = 0
        }
    }

    private func triggerCompletionFeedback() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)

        withAnimation(.easeInOut(duration: 0.15)) {
            restTimerFlash = true
        }

        Task {
            try? await Task.sleep(for: .milliseconds(250))
            withAnimation(.easeInOut(duration: 0.2)) {
                restTimerFlash = false
            }
        }
    }

    private func seedSampleDataIfNeeded() {
        guard let modelContext else { return }

        let descriptor = FetchDescriptor<Exercise>()
        let count = (try? modelContext.fetchCount(descriptor)) ?? 0
        guard count == 0 else { return }

        let samples = [
            Exercise.sampleBenchPress(sortOrder: 0),
            Exercise.sampleSquat(sortOrder: 1),
            Exercise.sampleDeadlift(sortOrder: 2)
        ]

        for exercise in samples {
            modelContext.insert(exercise)
            for workoutSet in exercise.sets {
                workoutSet.exercise = exercise
                modelContext.insert(workoutSet)
            }
        }

        save()
    }

    private func save() {
        guard let modelContext else { return }
        do {
            try modelContext.save()
        } catch {
            assertionFailure("Failed to save workout data: \(error.localizedDescription)")
        }
    }
}
