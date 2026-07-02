import Foundation
import SwiftData

@Model
final class Exercise {
    var id: UUID
    var name: String
    var targetGoalString: String
    var lastWorkoutSummary: String
    var sortOrder: Int
  @Relationship(deleteRule: .cascade, inverse: \WorkoutSet.exercise)
    var sets: [WorkoutSet]

    init(
        id: UUID = UUID(),
        name: String,
        targetGoalString: String,
        lastWorkoutSummary: String,
        sortOrder: Int = 0,
        sets: [WorkoutSet] = []
    ) {
        self.id = id
        self.name = name
        self.targetGoalString = targetGoalString
        self.lastWorkoutSummary = lastWorkoutSummary
        self.sortOrder = sortOrder
        self.sets = sets
    }
}

@Model
final class WorkoutSet {
    var id: UUID
    var setNumber: Int
    var weight: Double
    var reps: Int
    var isCompleted: Bool
    var exercise: Exercise?

    init(
        id: UUID = UUID(),
        setNumber: Int,
        weight: Double,
        reps: Int,
        isCompleted: Bool = false
    ) {
        self.id = id
        self.setNumber = setNumber
        self.weight = weight
        self.reps = reps
        self.isCompleted = isCompleted
    }
}

extension Exercise {
    static func makeDefaultSets(count: Int = 4, weight: Double, reps: Int) -> [WorkoutSet] {
        (1 ... count).map { index in
            WorkoutSet(setNumber: index, weight: weight, reps: reps)
        }
    }

    static func sampleBenchPress(sortOrder: Int = 0) -> Exercise {
        let sets = makeDefaultSets(count: 4, weight: 90, reps: 8)
        return Exercise(
            name: "Bench Press",
            targetGoalString: "92.5 kg for 8 reps (or 90 kg for 9 reps)",
            lastWorkoutSummary: "90 kg x 8, 8, 7",
            sortOrder: sortOrder,
            sets: sets
        )
    }

    static func sampleSquat(sortOrder: Int = 1) -> Exercise {
        let sets = makeDefaultSets(count: 4, weight: 100, reps: 5)
        return Exercise(
            name: "Squat",
            targetGoalString: "102.5 kg for 5 reps (or 100 kg for 6 reps)",
            lastWorkoutSummary: "100 kg x 5, 5, 4",
            sortOrder: sortOrder,
            sets: sets
        )
    }

    static func sampleDeadlift(sortOrder: Int = 2) -> Exercise {
        let sets = makeDefaultSets(count: 3, weight: 140, reps: 5)
        return Exercise(
            name: "Deadlift",
            targetGoalString: "142.5 kg for 5 reps (or 140 kg for 6 reps)",
            lastWorkoutSummary: "140 kg x 5, 5, 4",
            sortOrder: sortOrder,
            sets: sets
        )
    }
}
