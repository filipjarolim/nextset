import SwiftUI

extension Color {
    static let neonGreen = Color(hex: "00FF66")
    static let neonGreenDim = Color(hex: "00CC52")
    static let cardGrey = Color(hex: "1C1C1E")
    static let cardGreyElevated = Color(hex: "2C2C2E")
    static let surfaceDark = Color(hex: "0A0A0A")
    static let mutedText = Color(hex: "8E8E93")

    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)

        let red = Double((value >> 16) & 0xFF) / 255
        let green = Double((value >> 8) & 0xFF) / 255
        let blue = Double(value & 0xFF) / 255

        self.init(red: red, green: green, blue: blue)
    }
}
