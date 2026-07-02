import SwiftUI

// MARK: - Header

struct HeaderBar: View {
    let exerciseCount: Int
    let onAddTapped: () -> Void

    var body: some View {
        HStack(alignment: .center) {
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color.neonGreen.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Image(systemName: "dumbbell.fill")
                        .font(.body.weight(.bold))
                        .foregroundStyle(Color.neonGreen)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("NEXT_SET")
                        .font(.headline.weight(.black))
                        .tracking(1.5)
                        .foregroundStyle(.white)
                    Text("\(exerciseCount) exercise\(exerciseCount == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(Color.mutedText)
                }
            }

            Spacer()

            Button(action: onAddTapped) {
                Image(systemName: "plus")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.black)
                    .frame(width: 44, height: 44)
                    .background(Color.neonGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Add exercise")
        }
    }
}

// MARK: - Metric Summary Row

struct MetricSummaryRow: View {
    let completedSets: Int
    let totalSets: Int
    let targetWeight: Double
    let volume: Double

    var body: some View {
        HStack(spacing: AppTheme.itemSpacing) {
            MetricCard(
                icon: "checkmark.circle.fill",
                value: "\(completedSets)/\(totalSets)",
                label: "sets"
            )
            MetricCard(
                icon: "scalemass.fill",
                value: formattedWeight(targetWeight),
                label: "kg target"
            )
            MetricCard(
                icon: "flame.fill",
                value: formattedVolume(volume),
                label: "volume"
            )
        }
    }

    private func formattedWeight(_ value: Double) -> String {
        value.truncatingRemainder(dividingBy: 1) == 0
            ? String(format: "%.0f", value)
            : String(format: "%.1f", value)
    }

    private func formattedVolume(_ value: Double) -> String {
        if value >= 1000 {
            return String(format: "%.1fk", value / 1000)
        }
        return String(format: "%.0f", value)
    }
}

struct MetricCard: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.neonGreen.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.neonGreen)
            }

            Text(value)
                .font(AppFont.metric(22))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(Color.mutedText)
                .textCase(.lowercase)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .floatingCard(cornerRadius: AppTheme.cornerRadiusSmall)
    }
}

// MARK: - Exercise Hero Card

struct ExerciseHeroCard: View {
    let exerciseName: String
    let lastWorkoutSummary: String
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                StatusPill(text: "Active", icon: "bolt.fill", accent: true)
                Spacer()
                Text("\(Int(progress * 100))%")
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundStyle(Color.neonGreen)
            }

            Text(exerciseName.uppercased())
                .font(AppFont.hero(36))
                .foregroundStyle(.white)
                .lineLimit(2)
                .minimumScaleFactor(0.75)

            HStack(spacing: 8) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.mutedText)
                Text("Last week: \(lastWorkoutSummary)")
                    .font(.subheadline)
                    .foregroundStyle(Color.mutedText)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 6)
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [Color.neonGreenDim, Color.neonGreen],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 6)
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: progress)
                }
            }
            .frame(height: 6)
        }
        .padding(AppTheme.cardPadding)
        .floatingCard(elevated: true)
    }
}

// MARK: - Target Banner

struct TargetBanner: View {
    let targetText: String

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color.neonGreen.opacity(0.15))
                    .frame(width: 44, height: 44)
                Text("🎯")
                    .font(.title3)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("TARGET TODAY")
                    .font(.caption.weight(.bold))
                    .tracking(1.2)
                    .foregroundStyle(Color.neonGreen)

                Text(targetText)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppTheme.cardPadding)
        .background(
            LinearGradient(
                colors: [Color.neonGreen.opacity(0.08), Color.black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .floatingCard()
        .neonBorder()
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
        HStack(spacing: 14) {
            VStack(spacing: 4) {
                Text("\(set.setNumber)")
                    .font(AppFont.metric(24))
                    .foregroundStyle(set.isCompleted ? Color.neonGreen : Color.white.opacity(0.3))
                Text("set")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.mutedText)
            }
            .frame(width: 44)

            HStack(spacing: 10) {
                BorderedInputField(
                    title: "kg",
                    text: $weightText,
                    keyboardType: .decimalPad,
                    large: true
                ) { newValue in
                    if let weight = Double(newValue.replacingOccurrences(of: ",", with: ".")) {
                        onWeightChange(weight)
                    }
                }

                BorderedInputField(
                    title: "reps",
                    text: $repsText,
                    keyboardType: .numberPad,
                    large: true
                ) { newValue in
                    if let reps = Int(newValue) {
                        onRepsChange(reps)
                    }
                }
            }

            CheckmarkButton(isCompleted: set.isCompleted, action: onToggle)
        }
        .padding(16)
        .background(set.isCompleted ? Color.neonGreen.opacity(0.06) : Color.cardGrey)
        .floatingCard(cornerRadius: AppTheme.cornerRadiusSmall)
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.cornerRadiusSmall, style: .continuous)
                .stroke(
                    set.isCompleted ? Color.neonGreen.opacity(0.4) : Color.clear,
                    lineWidth: 1
                )
        )
        .onAppear {
            weightText = formattedWeight(set.weight)
            repsText = "\(set.reps)"
        }
        .onChange(of: set.weight) { _, newValue in
            let formatted = formattedWeight(newValue)
            if weightText != formatted { weightText = formatted }
        }
        .onChange(of: set.reps) { _, newValue in
            let formatted = "\(newValue)"
            if repsText != formatted { repsText = formatted }
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
    var large: Bool = false
    let onCommit: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(Color.mutedText)
                .textCase(.uppercase)

            TextField("0", text: $text)
                .keyboardType(keyboardType)
                .multilineTextAlignment(.center)
                .font(large ? AppFont.metric(22) : .body.monospacedDigit().weight(.semibold))
                .foregroundStyle(.white)
                .padding(.vertical, large ? 12 : 8)
                .padding(.horizontal, 8)
                .background(Color.black.opacity(0.5))
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(Color.white.opacity(0.12), lineWidth: AppTheme.borderWidth)
                )
                .onSubmit { onCommit(text) }
                .onChange(of: text) { _, newValue in onCommit(newValue) }
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
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(isCompleted ? Color.neonGreen : Color.clear)
                    .frame(width: 52, height: 52)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .stroke(
                                isCompleted ? Color.neonGreen : Color.white.opacity(0.2),
                                lineWidth: AppTheme.borderWidth
                            )
                    )

                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(.black)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Image(systemName: "checkmark")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.white.opacity(0.2))
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.spring(response: 0.35, dampingFraction: 0.65), value: isCompleted)
        .sensoryFeedback(.impact(weight: .medium), trigger: isCompleted)
        .accessibilityLabel(isCompleted ? "Set completed" : "Mark set complete")
    }
}

// MARK: - Rest Timer Overlay

struct RestTimerOverlay: View {
    let timeText: String
    let progress: Double
    let onAddTime: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                HStack {
                    StatusPill(text: "Resting", icon: "timer", accent: false)
                    Spacer()
                    Button(action: onDismiss) {
                        Image(systemName: "xmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(Color.mutedText)
                            .frame(width: 32, height: 32)
                            .background(Color.white.opacity(0.08))
                            .clipShape(Circle())
                    }
                    .buttonStyle(.plain)
                }

                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 6)
                        .frame(width: 160, height: 160)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            Color.neonGreen,
                            style: StrokeStyle(lineWidth: 6, lineCap: .round)
                        )
                        .frame(width: 160, height: 160)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.3), value: progress)

                    Text(timeText)
                        .font(AppFont.display(44))
                        .foregroundStyle(.white)
                }

                HStack(spacing: 16) {
                    Button(action: onAddTime) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus")
                                .font(.caption.weight(.bold))
                            Text("30s")
                                .font(.subheadline.weight(.bold).monospacedDigit())
                        }
                        .foregroundStyle(.black)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(Color.neonGreen)
                        .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)

                    Button(action: onDismiss) {
                        Text("Skip Rest")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(Color.mutedText)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .overlay(
                                Capsule()
                                    .stroke(Color.white.opacity(0.15), lineWidth: AppTheme.borderWidth)
                            )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(24)
            .background(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                    .fill(Color.cardGrey)
                    .shadow(color: Color.neonGreen.opacity(0.15), radius: 30, y: -10)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.cornerRadiusLarge, style: .continuous)
                    .stroke(Color.neonGreen.opacity(0.25), lineWidth: 1)
            )
            .padding(.horizontal, AppTheme.horizontalPadding)
            .padding(.bottom, 8)
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
}

// MARK: - Exercise Picker

struct ExercisePickerRow: View {
    let exercises: [Exercise]
    let activeExerciseID: UUID?
    let onSelect: (Exercise) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(exercises, id: \.id) { exercise in
                let isActive = activeExerciseID == exercise.id
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                        onSelect(exercise)
                    }
                } label: {
                    Text(exercise.name)
                        .font(.caption.weight(.bold))
                        .lineLimit(1)
                        .foregroundStyle(isActive ? .black : Color.mutedText)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                        .background(isActive ? Color.neonGreen : Color.clear)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.cardGrey)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.08), lineWidth: AppTheme.borderWidth)
        )
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

    let onSave: (String, String, String, Int, Double, Int) -> Void

    var body: some View {
        NavigationStack {
            ZStack {
                AmbientBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 8) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(Color.neonGreen)
                            Text("New Exercise")
                                .font(AppFont.hero(28))
                                .foregroundStyle(.white)
                            Text("Build your progressive overload target")
                                .font(.subheadline)
                                .foregroundStyle(Color.mutedText)
                        }
                        .padding(.top, 8)

                        VStack(spacing: 14) {
                            SheetField(title: "Exercise Name", placeholder: "Bench Press", text: $name)
                            SheetField(title: "Target Goal", placeholder: "92.5 kg for 8 reps", text: $targetGoal)
                            SheetField(title: "Last Workout", placeholder: "90 kg x 8, 8, 7", text: $lastSummary)
                        }

                        HStack(spacing: 12) {
                            SheetField(title: "Weight (kg)", placeholder: "60", text: $defaultWeight, keyboard: .decimalPad)
                            SheetField(title: "Reps", placeholder: "8", text: $defaultReps, keyboard: .numberPad)
                        }

                        VStack(alignment: .leading, spacing: 10) {
                            Text("NUMBER OF SETS")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(Color.mutedText)
                                .tracking(1)

                            HStack(spacing: 10) {
                                ForEach([3, 4], id: \.self) { count in
                                    Button {
                                        setCount = count
                                    } label: {
                                        Text("\(count) sets")
                                            .font(.subheadline.weight(.bold))
                                            .foregroundStyle(setCount == count ? .black : .white)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(setCount == count ? Color.neonGreen : Color.cardGrey)
                                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 14, style: .continuous)
                                                    .stroke(Color.white.opacity(0.1), lineWidth: AppTheme.borderWidth)
                                            )
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }

                        Button {
                            let weight = Double(defaultWeight.replacingOccurrences(of: ",", with: ".")) ?? 0
                            let reps = Int(defaultReps) ?? 0
                            onSave(name, targetGoal, lastSummary, setCount, weight, reps)
                            dismiss()
                        } label: {
                            Text("Create Exercise")
                                .font(.headline.weight(.bold))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(Color.neonGreen)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                        .buttonStyle(.plain)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .opacity(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.4 : 1)
                    }
                    .padding(AppTheme.horizontalPadding)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.mutedText)
                }
            }
        }
        .presentationDetents([.large])
        .presentationBackground(Color.black)
    }
}

struct SheetField: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    var keyboard: UIKeyboardType = .default

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .foregroundStyle(Color.mutedText)
                .tracking(0.8)

            TextField(placeholder, text: $text)
                .keyboardType(keyboard)
                .font(.body.weight(.medium))
                .foregroundStyle(.white)
                .padding(16)
                .background(Color.cardGrey)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: AppTheme.borderWidth)
                )
        }
    }
}

// MARK: - Empty State

struct EmptyStateView: View {
    let onAddTapped: () -> Void

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            ZStack {
                Circle()
                    .fill(Color.neonGreen.opacity(0.08))
                    .frame(width: 120, height: 120)
                Image(systemName: "dumbbell.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.neonGreen)
            }

            VStack(spacing: 10) {
                Text("Start Your\nProgression")
                    .font(AppFont.hero(32))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)

                Text("Track sets, hit targets, and overload\nwithout friction.")
                    .font(.subheadline)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(Color.mutedText)
            }

            Button(action: onAddTapped) {
                HStack(spacing: 8) {
                    Image(systemName: "plus")
                        .font(.body.weight(.bold))
                    Text("Add First Exercise")
                        .font(.headline.weight(.bold))
                }
                .foregroundStyle(.black)
                .padding(.horizontal, 28)
                .padding(.vertical, 16)
                .background(Color.neonGreen)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(AppTheme.horizontalPadding)
    }
}
