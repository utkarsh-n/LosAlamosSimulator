import SwiftUI

enum MetroTheme {
    static let background = Color(red: 0.025, green: 0.042, blue: 0.058)
    static let panel = Color(red: 0.045, green: 0.070, blue: 0.087)
    static let cyan = Color(red: 0.34, green: 0.93, blue: 0.96)
    static let amber = Color(red: 1, green: 0.74, blue: 0.37)
    static let violet = Color(red: 0.76, green: 0.57, blue: 1)
    static let text = Color(red: 0.91, green: 0.95, blue: 0.97)
    static let muted = Color(red: 0.60, green: 0.69, blue: 0.73)
}

struct MetroBackground: View {
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    var body: some View {
        ZStack {
            MetroTheme.background
            if !reduceTransparency {
                RadialGradient(colors: [MetroTheme.cyan.opacity(0.06), .clear],
                               center: .topTrailing, startRadius: 0, endRadius: 600)
            }
            Canvas { context, size in
                var grid = Path()
                for x in stride(from: 0.0, through: size.width, by: 28) {
                    grid.move(to: CGPoint(x: x, y: 0)); grid.addLine(to: CGPoint(x: x, y: size.height))
                }
                for y in stride(from: 0.0, through: size.height, by: 28) {
                    grid.move(to: CGPoint(x: 0, y: y)); grid.addLine(to: CGPoint(x: size.width, y: y))
                }
                context.stroke(grid, with: .color(.white.opacity(0.024)), lineWidth: 0.5)
            }
        }
        .ignoresSafeArea().allowsHitTesting(false).accessibilityHidden(true)
    }
}

struct LabHeader: View {
    let kicker: String
    let title: String
    let subtitle: String
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(kicker.uppercased())
                .font(.system(.caption, design: .monospaced)).tracking(2)
                .foregroundStyle(MetroTheme.cyan)
            Text(title).font(.system(.largeTitle, design: .rounded, weight: .semibold))
                .foregroundStyle(MetroTheme.text)
            Text(subtitle).font(.subheadline).foregroundStyle(MetroTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct InstrumentPanel<Content: View>: View {
    let title: String
    let eyebrow: String?
    let accent: Color
    let content: Content
    @Environment(\.colorSchemeContrast) private var contrast

    init(title: String, eyebrow: String? = nil, accent: Color = MetroTheme.cyan,
         @ViewBuilder content: () -> Content) {
        self.title = title; self.eyebrow = eyebrow; self.accent = accent; self.content = content()
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 5) {
                if let eyebrow {
                    Text(eyebrow.uppercased()).font(.system(.caption2, design: .monospaced))
                        .tracking(1.5).foregroundStyle(accent)
                }
                Text(title).font(.system(.headline, design: .rounded))
                    .foregroundStyle(MetroTheme.text)
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(MetroTheme.panel, in: .rect(cornerRadius: 22))
        .overlay {
            RoundedRectangle(cornerRadius: 22)
                .stroke(.white.opacity(contrast == .increased ? 0.25 : 0.10), lineWidth: 1)
                .allowsHitTesting(false)
        }
    }
}

struct MetricReadout: View {
    let label: String
    let value: String
    let unit: String
    var accent: Color = MetroTheme.cyan
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label.uppercased()).font(.system(.caption2, design: .monospaced))
                .foregroundStyle(MetroTheme.muted)
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value).font(.system(.title2, design: .rounded, weight: .medium)).monospacedDigit()
                Text(unit).font(.system(.caption, design: .monospaced))
            }.foregroundStyle(accent)
        }.frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(label).accessibilityValue("\(value) \(unit)")
    }
}

struct GlassAction: View {
    let title: String
    let symbol: String
    var accent: Color = MetroTheme.cyan
    var action: () -> Void
    var body: some View {
        Button(action: action) {
            Label(title, systemImage: symbol)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
                .foregroundStyle(accent)
                .frame(maxWidth: .infinity, minHeight: 48)
                .contentShape(.rect)
                .glassEffect(.regular.tint(accent.opacity(0.08)).interactive(), in: .capsule)
        }.buttonStyle(.plain)
            .instrumentControlOwnsTouches(identifier: title)
    }
}

struct ModelNote: View {
    let text: String
    var body: some View {
        Label {
            Text(text).font(.caption).fixedSize(horizontal: false, vertical: true)
        } icon: { Image(systemName: "scale.3d") }
            .foregroundStyle(MetroTheme.muted)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
