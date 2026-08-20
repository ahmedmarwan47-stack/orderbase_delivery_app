import SwiftUI

/// The app's design tokens, restated for the widget extension.
///
/// The extension is a separate binary — it cannot see `lib/theme/colors.dart`
/// or the Flutter asset bundle, so these are hand-mirrored. Every value here
/// has a named twin in `lib/theme/colors.dart`; keep them in step.
enum OB {

    // MARK: - Colors (see lib/theme/colors.dart)

    /// #E72B29 — AppColors.brand
    static let brand = Color(red: 0.906, green: 0.169, blue: 0.161)
    /// #F0B75A — AppColors.walletAmberOnDark (cash figure on a dark surface)
    static let amber = Color(red: 0.941, green: 0.718, blue: 0.353)
    /// #16A34A — AppColors.greenAccent
    static let green = Color(red: 0.086, green: 0.639, blue: 0.290)
    /// #A3A29E — AppColors.mutedOnDark
    static let muted = Color(red: 0.639, green: 0.635, blue: 0.620)
    /// #1A1919 — AppColors.textPrimary
    static let ink = Color(red: 0.102, green: 0.098, blue: 0.098)
    /// #6B6B73 — AppColors.textSecondary
    static let secondary = Color(red: 0.420, green: 0.420, blue: 0.451)
    /// #7E6E65 — AppColors.textMuted
    static let warmMuted = Color(red: 0.494, green: 0.431, blue: 0.396)
    /// #F6F5F3 — AppColors.background
    static let paper = Color(red: 0.965, green: 0.961, blue: 0.953)
    /// #F1F0ED — AppColors.surfaceSubtle
    static let subtle = Color(red: 0.945, green: 0.941, blue: 0.929)
    /// #E6E5E2 — AppColors.borderDefault
    static let hairline = Color(red: 0.902, green: 0.898, blue: 0.886)

    // MARK: - Type

    /// PostScript names of the bundled faces. If the .ttf files were not added
    /// to this target, `Font.custom` quietly falls back to the system font —
    /// the island still renders, just not in the brand face.
    static let regular = "NotoKufiArabic-Regular"
    static let semibold = "NotoKufiArabic-SemiBold"
    static let bold = "NotoKufiArabic-Bold"

    static func font(_ size: CGFloat, _ face: String = OB.regular) -> Font {
        .custom(face, size: size)
    }

    // MARK: - Formatting

    /// Thousands-grouped, Western digits — matching `formatThousands` in
    /// lib/data/order.dart and the digits the app displays everywhere.
    static func money(_ value: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = ","
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: NSNumber(value: value)) ?? "\(value)"
    }

    static func stopLabel(_ current: Int, _ total: Int) -> String {
        "المحطة \(current) من \(total)"
    }

    static func stopCounter(_ current: Int, _ total: Int) -> String {
        "\(current)/\(total)"
    }
}
