import SwiftUI

struct SessionChartPoint: Identifiable {
    let id: Int
    let setNumber: Int
    let reps: Int
    let isCompleted: Bool
}

struct ProgressChartView: View {
    let points: [SessionChartPoint]
    let maxReps: Int

    private var chartMax: CGFloat {
        CGFloat(max(maxReps, points.map(\.reps).max() ?? 1, 1))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Session Progress", trailing: "reps per set")

            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                let stepX = points.count > 1 ? width / CGFloat(points.count - 1) : width

                ZStack(alignment: .bottomLeading) {
                    chartGrid(height: height, width: width)

                    if points.count > 1 {
                        stepAreaPath(width: width, height: height, stepX: stepX)
                            .fill(
                                LinearGradient(
                                    colors: [Color.neonGreen.opacity(0.35), Color.neonGreen.opacity(0.02)],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )

                        stepLinePath(width: width, height: height, stepX: stepX)
                            .stroke(Color.neonGreen, style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))

                        ForEach(Array(points.enumerated()), id: \.element.id) { index, point in
                            let x = CGFloat(index) * stepX
                            let y = height - (CGFloat(point.reps) / chartMax) * (height - 20) - 10

                            Circle()
                                .fill(point.isCompleted ? Color.neonGreen : Color.cardGreyElevated)
                                .frame(width: 10, height: 10)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white.opacity(0.9), lineWidth: 2)
                                )
                                .position(x: x, y: y)

                            if point.isCompleted || index == points.count - 1 {
                                Text("\(point.reps)")
                                    .font(.caption2.weight(.bold).monospacedDigit())
                                    .foregroundStyle(point.isCompleted ? Color.black : Color.white)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(point.isCompleted ? Color.neonGreen : Color.cardGreyElevated)
                                    .clipShape(Capsule())
                                    .position(x: x, y: max(y - 22, 12))
                            }
                        }
                    }
                }
            }
            .frame(height: 140)

            HStack {
                ForEach(points) { point in
                    Text("S\(point.setNumber)")
                        .font(.caption2.weight(.medium).monospacedDigit())
                        .foregroundStyle(Color.mutedText)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(AppTheme.cardPadding)
        .floatingCard()
    }

    private func chartGrid(height: CGFloat, width: CGFloat) -> some View {
        Path { path in
            for i in 0 ... 3 {
                let y = height * CGFloat(i) / 3
                path.move(to: CGPoint(x: 0, y: y))
                path.addLine(to: CGPoint(x: width, y: y))
            }
        }
        .stroke(Color.white.opacity(0.05), lineWidth: 1)
    }

    private func stepLinePath(width: CGFloat, height: CGFloat, stepX: CGFloat) -> Path {
        Path { path in
            guard points.first != nil else { return }

            for (index, point) in points.enumerated() {
                let x = CGFloat(index) * stepX
                let y = height - (CGFloat(point.reps) / chartMax) * (height - 20) - 10
                if index == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
        }
    }

    private func stepAreaPath(width: CGFloat, height: CGFloat, stepX: CGFloat) -> Path {
        Path { path in
            guard points.first != nil else { return }

            let baseline = height - 2
            path.move(to: CGPoint(x: 0, y: baseline))

            for (index, point) in points.enumerated() {
                let x = CGFloat(index) * stepX
                let y = height - (CGFloat(point.reps) / chartMax) * (height - 20) - 10
                path.addLine(to: CGPoint(x: x, y: y))
            }

            path.addLine(to: CGPoint(x: CGFloat(points.count - 1) * stepX, y: baseline))
            path.closeSubpath()
        }
    }
}
