import SwiftUI

// MARK: - Design Tokens

enum AppTheme {
    static let horizontalPadding: CGFloat = 16
    static let borderWidth: CGFloat = 0.75
    static let cornerRadius: CGFloat = 10
}

// MARK: - Header

struct HeaderBar: View {
    let onAddTapped: () -> Void

    var body: some View {
        HStack {
            Text("NEXT_SET")
                .font(.title2.weight(.bold))
                .tracking(2)
                .foregroundStyle(.white)

            Spacer()

            Button(action: onAddTapped) {
                Image(systemName: "plus")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.white)
                    .frame(width: 36, height: 36)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                            .stroke(Color.white.opacity(0.35), lineWidth: AppTheme.borderWidth)
                    )
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add exercise")
        }
    }
}

// MARK: - Exercise Focus Card

struct ExerciseFocusCard: View {
    let exerciseName: String
    let lastWorkoutSummary: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(exerciseName.uppercased())
                .font(.system(size: 34, weight: .bold, design: .default))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text("Last week: \(lastWorkoutSummary)")
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.45))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.cardGrey)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(Color.white.opacity(0.12), lineWidth: AppTheme.borderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
}

// MARK: - Target Banner

struct TargetBanner: View {
    let targetText: String

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text("🎯")
                .font(.title3)

            Text("TARGET TODAY: \(targetText)")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.white)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(Color.black)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(Color.neonGreen, lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
    }
}

// MARK: - Set Row

struct SetRowView: View {
    let set: WorkoutSet
    let onToggle: () -> Void
    let onWeightChange: (Double) -> Void
    let onRepsChange: (Int) -> Void

    @State private var weightText: String = ""
    @State private var repsText: String = ""

    var body: some View {
        HStack(spacing: 12) {
            Text("Set \(set.setNumber)")
                .font(.subheadline)
                .foregroundStyle(Color.white.opacity(0.45))
                .frame(width: 52, alignment: .leading)

            BorderedInputField(
                title: "kg",
                text: $weightText,
                keyboardType: .decimalPad
            ) { newValue in
                if let weight = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                    onWeightChange(weight)
                }
            }

            BorderedInputField(
                title: "reps",
                text: $repsText,
                keyboardType: .numberPad
            ) { newValue in
                if let reps = Int(newValue) {
                    onRepsChange(reps)
                }
            }

            CheckmarkButton(isCompleted: set.isCompleted, action: onToggle)
        }
        .onAppear {
            weightText = formattedWeight(set.weight)
            repsText = "\(set.reps)"
        }
        .onChange(of: set.weight) { _, newValue in
            let formatted = formattedWeight(newValue)
            if weightText != formatted {
                weightText = formatted
            }
        }
        .onChange(of: set.reps) { _, newValue in
            let formatted = "\(newValue)"
            if repsText != formatted {
                repsText = formatted
            }
        }
    }

    private func formattedWeight(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }
}

struct BorderedInputField: View {
    let title: String
    @Binding var text: String
    let keyboardType: UIKeyboardType
    let onCommit: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption2)
                .foregroundStyle(Color.white.opacity(0.35))

            TextField("0", text: $text)
                .keyboardType(keyboardType)
                .multilineTextAlignment(.center)
                .font(.body.monospacedDigit().weight(.semibold))
                .foregroundStyle(.white)
                .padding(.vertical, 8)
                .padding(.horizontal, 6)
                .background(Color.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white.opacity(0.2), lineWidth: AppTheme.borderWidth)
                )
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onSubmit {
                    onCommit(text)
                }
                .onChange(of: text) { _, newValue in
                    onCommit(newValue)
                }
        }
        .frame(maxWidth: .infinity)
    }
}

struct CheckmarkButton: View {
    let isCompleted: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(isCompleted ? Color.neonGreen : Color.clear)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isCompleted ? Color.neonGreen : Color.white.opacity(0.25),
                                lineWidth: AppTheme.borderWidth
                            )
                    )

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.bold))
                        .foregroundStyle(.black)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .frame(width: 40, height: 40)
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isCompleted)
        .accessibilityLabel(isCompleted ? "Set completed" : "Mark set complete")
    }
}

// MARK: - Rest Timer

struct RestTimerBanner: View {
    let timeText: String
    let onAddTime: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Text("⏱️ REST TIMER: \(timeText)")
                .font(.subheadline.weight(.semibold).monospacedDigit())
                .foregroundStyle(Color.neonGreen)

            Spacer()

            Button("+30s", action: onAddTime)
                .font(.caption.weight(.bold).monospacedDigit())
                .foregroundStyle(.black)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.neonGreen)
                .clipShape(Capsule())

            Button(action: onDismiss) {
                Image(systemName: "xmark")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(Color.white.opacity(0.6))
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color.cardGrey)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadius)
                .stroke(Color.neonGreen.opacity(0.6), lineWidth: AppTheme.borderWidth)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.cornerRadius))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Add Exercise Sheet

struct AddExerciseSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var targetGoal: String = ""
    @State private var lastSummary: String = ""
    @State private var defaultWeight: String = "60"
    @State private var defaultReps: String = "8"
    @State private var setCount: Int = 4

    let onSave: (
        String,
        String,
        String,
        Int,
        Double,
        Int
    ) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                Form {
                    Section("Exercise") {
                        TextField("Name", text: $name)
                        TextField("Target goal", text: $targetGoal)
                        TextField("Last workout summary", text: $lastSummary)
                    }

                    Section("Defaults") {
                        TextField("Weight (kg)", text: $defaultWeight)
                            .keyboardType(.decimalPad)
                        TextField("Reps", text: $defaultReps)
                            .keyboardType(.numberPad)
                        Stepper("Sets: \(setCount)", value: $setCount, in: 3 ... 4)
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("New Exercise")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let weight = Double(defaultWeight.replacingOccurrences(of: ",", with: ".")) ?? 0
                        let reps = Int(defaultReps) ?? 0
                        onSave(name, targetGoal, lastSummary, setCount, weight, reps)
                        dismiss()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(Color.black)
    }
}

// MARK: - Exercise Picker

struct ExercisePickerRow: View {
    let exercises: [Exercise]
    let activeExerciseID: UUID?
    let onSelect: (Exercise) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(exercises, id: \.id) { exercise in
                    Button {
                        onSelect(exercise)
                    } label: {
                        Text(exercise.name)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(activeExerciseID == exercise.id ? .black : .white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(activeExerciseID == exercise.id ? Color.neonGreen : Color.cardGrey)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.white.opacity(0.15), lineWidth: AppTheme.borderWidth)
                            )
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
