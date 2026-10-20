import SwiftUI

enum AppTheme {
    static let ink = Color(red: 0.08, green: 0.16, blue: 0.22)
    static let ocean = Color(red: 0.05, green: 0.45, blue: 0.52)
    static let seafoam = Color(red: 0.55, green: 0.82, blue: 0.78)
    static let sand = Color(red: 0.96, green: 0.94, blue: 0.90)
    static let mist = Color(red: 0.90, green: 0.93, blue: 0.94)

    static var background: some View {
        LinearGradient(
            colors: [
                Color(red: 0.93, green: 0.96, blue: 0.97),
                Color(red: 0.86, green: 0.92, blue: 0.93),
                Color(red: 0.78, green: 0.88, blue: 0.90)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

struct BrandMark: View {
    var compact: Bool = false

    var body: some View {
        HStack(spacing: compact ? 8 : 12) {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [AppTheme.ocean, AppTheme.seafoam],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: compact ? 28 : 40, height: compact ? 28 : 40)
                .overlay {
                    Text("S")
                        .font(.system(size: compact ? 14 : 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

            VStack(alignment: .leading, spacing: 2) {
                Text("Students")
                    .font(.system(size: compact ? 20 : 28, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
                if !compact {
                    Text("Demo App companion")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(AppTheme.ocean.opacity(0.85))
                }
            }
        }
    }
}
