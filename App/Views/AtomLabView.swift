import SwiftUI
import LosAlamosCore

struct AtomLabView: View {
    @State private var step = 0
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var stage: FissionStage { FissionStage.allCases[step] }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                LabHeader(
                    kicker: "THE ATOMIC SCALE",
                    title: "One nucleus. One event.",
                    subtitle: "Scrub through the idea of fission, from neutron capture to fragment motion."
                )

                InstrumentPanel(title: "Fission sequence", eyebrow: "CONCEPTUAL MODEL", accent: MetroTheme.cyan) {
                    VStack(spacing: 20) {
                        HStack(alignment: .firstTextBaseline) {
                            Text(stage.title)
                                .font(.title2.weight(.semibold))
                                .foregroundStyle(MetroTheme.text)
                            Spacer(minLength: 8)
                            Text("\(step + 1) / 5")
                                .font(.callout.monospaced())
                                .monospacedDigit()
                                .foregroundStyle(MetroTheme.cyan)
                        }

                        stageControls

                        FissionDiagram(progress: Double(step))
                            .frame(height: 246)
                            .background(MetroTheme.background, in: RoundedRectangle(cornerRadius: 18))
                            .overlay {
                                RoundedRectangle(cornerRadius: 18)
                                    .strokeBorder(MetroTheme.muted.opacity(0.2), lineWidth: 1)
                            }
                            .accessibilityElement(children: .ignore)
                            .accessibilityLabel("Fission diagram")
                            .accessibilityValue(stage.diagramDescription)

                        diagramLegend

                        Text(stage.explanation)
                            .font(.body)
                            .foregroundStyle(MetroTheme.text)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)

                        Text("SCHEMATIC · NOT TO SCALE · TIME IS NOT MODELED")
                            .font(.caption.monospaced())
                            .foregroundStyle(MetroTheme.muted)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                InstrumentPanel(title: "A small mass difference", eyebrow: "ENERGY PER FISSION", accent: MetroTheme.amber) {
                    VStack(alignment: .leading, spacing: 20) {
                        MetricReadout(
                            label: "TYPICAL RELEASE",
                            value: "≈ " + FissionEnergy.energyPerEventMeV.formatted(.number.precision(.fractionLength(0))),
                            unit: "MeV / event",
                            accent: MetroTheme.amber
                        )
                        .accessibilityValue("Approximately \(FissionEnergy.energyPerEventMeV.formatted(.number.precision(.fractionLength(0)))) megaelectronvolts per fission event")
                        Divider().overlay(MetroTheme.muted.opacity(0.2))
                        MetricReadout(
                            label: "IN JOULES",
                            value: scientific(FissionEnergy.energyPerEventJoules),
                            unit: "J / event",
                            accent: MetroTheme.amber
                        )
                        .accessibilityValue(spokenScientific(FissionEnergy.energyPerEventJoules) + " joules per fission event")
                        Text("E = Δm c²")
                            .font(.title3.monospaced())
                            .foregroundStyle(MetroTheme.text)
                            .accessibilityLabel("Energy equals the rest mass difference times the speed of light squared.")
                        MetricReadout(
                            label: "MASS EQUIVALENT OF THAT ENERGY",
                            value: scientific(FissionEnergy.massEquivalentPerEventKg),
                            unit: "kg / event",
                            accent: MetroTheme.violet
                        )
                        .accessibilityValue(spokenScientific(FissionEnergy.massEquivalentPerEventKg) + " kilograms per fission event")
                        Text("The products have slightly less rest mass than the initial system. The difference appears as released energy; total mass–energy is conserved.")
                            .font(.body)
                            .foregroundStyle(MetroTheme.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                InstrumentPanel(title: "Why a nucleus can split", eyebrow: "BINDING ENERGY", accent: MetroTheme.cyan) {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("A nucleus contains positively charged protons and neutral neutrons. Protons repel one another electrically; a short-range nuclear attraction binds nearby protons and neutrons together. Binding energy is the energy needed to separate them all.")
                        Text("When a very heavy nucleus splits, its fragments can be more tightly bound per nucleon (proton or neutron). The products can have lower total rest energy than the initial system. That difference is released as motion and radiation.")
                    }.font(.body).foregroundStyle(MetroTheme.text)
                        .fixedSize(horizontal: false, vertical: true)
                }

                InstrumentPanel(title: "Where the energy goes", eyebrow: "FOLLOW THE PRODUCTS", accent: MetroTheme.violet) {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Mostly fragment motion", systemImage: "arrow.left.and.right")
                            .font(.headline)
                            .foregroundStyle(MetroTheme.violet)
                        Text("Most of the released energy becomes kinetic energy of the two fragments. As they slow in surrounding matter, that energy becomes heat.")
                        Text("Smaller portions are carried by emitted neutrons, gamma rays, and subsequent radioactive decay. Some decay energy leaves with neutrinos rather than heating nearby matter.")
                        Text("This diagram uses a generic heavy nucleus. Dots, fragment sizes, neutron counts, paths, and stage durations are illustrative. It does not predict an individual event.")
                            .foregroundStyle(MetroTheme.muted)
                    }
                    .font(.body)
                    .foregroundStyle(MetroTheme.text)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 24)
            .frame(maxWidth: 600)
            .frame(maxWidth: .infinity)
        }
        .background(MetroTheme.background)
        .sensoryFeedback(.selection, trigger: step)
    }

    private var stageControls: some View {
        VStack(spacing: 14) {
            Slider(value: stepBinding, in: 0...4, step: 1)
                .tint(MetroTheme.cyan)
                .instrumentControlOwnsTouches(identifier: "atom-stage-slider")
                .accessibilityLabel("Fission stage")
                .accessibilityValue("\(stage.title), stage \(step + 1) of 5")
                .accessibilityHint("Adjust to move through the five conceptual stages.")

            HStack(spacing: 12) {
                Button {
                    selectStep(step - 1)
                } label: {
                    Label("Previous", systemImage: "arrow.left")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.glass)
                .instrumentControlOwnsTouches(identifier: "atom-previous-stage")
                .disabled(step == 0)
                .accessibilityLabel("Previous fission stage")

                Button {
                    selectStep(step + 1)
                } label: {
                    Label("Next", systemImage: "arrow.right")
                        .frame(maxWidth: .infinity, minHeight: 44)
                }
                .buttonStyle(.glass)
                .tint(MetroTheme.cyan)
                .instrumentControlOwnsTouches(identifier: "atom-next-stage")
                .disabled(step == 4)
                .accessibilityLabel("Next fission stage")
            }
            .font(.subheadline.weight(.semibold))
        }
    }

    private var diagramLegend: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 16) { legendEntries }
            VStack(alignment: .leading, spacing: 10) { legendEntries }
        }
        .font(.caption)
        .foregroundStyle(MetroTheme.muted)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var legendEntries: some View {
        Label {
            Text("Nuclear matter")
        } icon: {
            Image(systemName: "circle.hexagongrid.fill").foregroundStyle(MetroTheme.cyan)
        }
        Label {
            Text("Neutron")
        } icon: {
            Image(systemName: "circle.fill").foregroundStyle(MetroTheme.amber)
        }
        Label {
            Text("Energy / motion")
        } icon: {
            Image(systemName: "arrow.right").foregroundStyle(MetroTheme.violet)
        }
    }

    private var stepBinding: Binding<Double> {
        Binding(
            get: { Double(step) },
            set: { selectStep(Int($0.rounded())) }
        )
    }

    private func selectStep(_ newValue: Int) {
        let clamped = min(4, max(0, newValue))
        if reduceMotion {
            step = clamped
        } else {
            withAnimation(.easeInOut(duration: 0.35)) { step = clamped }
        }
    }

    private func scientific(_ value: Double) -> String {
        let exponent = Int(floor(log10(value)))
        let mantissa = value / pow(10, Double(exponent))
        let superscripts: [Character: String] = ["-": "⁻", "0": "⁰", "1": "¹", "2": "²", "3": "³", "4": "⁴", "5": "⁵", "6": "⁶", "7": "⁷", "8": "⁸", "9": "⁹"]
        let power = String(exponent).map { superscripts[$0] ?? String($0) }.joined()
        return "≈ " + mantissa.formatted(.number.precision(.fractionLength(1))) + " × 10" + power
    }

    private func spokenScientific(_ value: Double) -> String {
        let exponent = Int(floor(log10(value)))
        let mantissa = value / pow(10, Double(exponent))
        return "Approximately \(mantissa.formatted(.number.precision(.fractionLength(1)))) times ten to the power of \(exponent)"
    }
}

private enum FissionStage: Int, CaseIterable {
    case approach, capture, deform, split, recoil

    var title: String {
        switch self {
        case .approach: "Approach"
        case .capture: "Capture"
        case .deform: "Deform"
        case .split: "Split"
        case .recoil: "Recoil"
        }
    }

    var explanation: String {
        switch self {
        case .approach:
            "A neutron approaches a heavy nucleus. Neutrons carry no electric charge, so they do not face the electric repulsion that a positively charged particle would."
        case .capture:
            "The nucleus can capture the neutron and become excited. Capture does not guarantee fission: other outcomes are possible. Here we follow one event that does fission."
        case .deform:
            "The excited nucleus changes shape. The short-range nuclear attraction competes with the electric repulsion among its protons. This picture exaggerates the deformation so it is visible."
        case .split:
            "The nucleus divides into two fragments, releasing neutrons and energy. The fragments and emitted particles vary from event to event; this is one schematic illustration."
        case .recoil:
            "The fragments move apart, carrying most of the energy. Emitted neutrons can interact with other nuclei, connecting this single event to the idea of a chain reaction."
        }
    }

    var diagramDescription: String {
        switch self {
        case .approach: "One neutron at the left approaches a compact heavy nucleus at the center."
        case .capture: "The incoming neutron has entered the heavy nucleus."
        case .deform: "The excited nucleus stretches into an elongated shape."
        case .split: "Two nuclear fragments separate and illustrative emitted neutrons begin to leave."
        case .recoil: "The two fragments have moved farther apart, with outward motion arrows and emitted neutrons."
        }
    }
}

private struct FissionDiagram: View, Animatable {
    nonisolated var progress: Double

    nonisolated var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }

    // Decorative nucleon positions have no relationship to a particular isotope.
    private static let dots: [CGPoint] = [
        .init(x: -0.64, y: -0.2), .init(x: -0.52, y: 0.2),
        .init(x: -0.37, y: -0.51), .init(x: -0.34, y: -0.05), .init(x: -0.28, y: 0.55),
        .init(x: -0.15, y: -0.32), .init(x: -0.08, y: 0.24), .init(x: -0.02, y: -0.65),
        .init(x: 0.13, y: 0.61), .init(x: 0.13, y: -0.06),
        .init(x: 0.29, y: -0.43), .init(x: 0.35, y: 0.26),
        .init(x: 0.5, y: -0.05), .init(x: 0.56, y: 0.41), .init(x: 0.65, y: -0.32)
    ]

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width * 0.5, y: size.height * 0.49)
            let radius = min(size.width * 0.19, size.height * 0.26)
            let deformation = bounded(progress - 1)
            let split = bounded(progress - 2)
            let recoil = bounded(progress - 3)
            let separation = radius * (split * 0.76 + recoil * 0.96)

            drawGrid(context: &context, size: size)

            if split < 1 {
                let nucleus = CGRect(
                    x: center.x - radius * (1 + deformation * 0.35),
                    y: center.y - radius * (1 - deformation * 0.12),
                    width: radius * 2 * (1 + deformation * 0.35),
                    height: radius * 2 * (1 - deformation * 0.12)
                )
                let path = Path(ellipseIn: nucleus)
                context.fill(path, with: .color(MetroTheme.cyan.opacity(0.08 * (1 - split))))
                context.stroke(path, with: .color(MetroTheme.cyan.opacity(0.55 * (1 - split))), lineWidth: 1.2)
            }

            for side in [-1.0, 1.0] {
                let fragmentCenter = CGPoint(x: center.x + side * separation, y: center.y)
                let fragment = Path(ellipseIn: CGRect(
                    x: fragmentCenter.x - radius * 0.63,
                    y: fragmentCenter.y - radius * 0.83,
                    width: radius * 1.26,
                    height: radius * 1.66
                ))
                context.fill(fragment, with: .color(MetroTheme.cyan.opacity(0.065 * split)))
                context.stroke(fragment, with: .color(MetroTheme.cyan.opacity(0.6 * split)), lineWidth: 1.2)
            }

            for (index, point) in Self.dots.enumerated() {
                let side = point.x < 0 ? -1.0 : 1.0
                let clusteredX = point.x - side * split * 0.24
                let x = center.x + clusteredX * radius * (1 + deformation * 0.3 * (1 - split)) + side * separation
                let y = center.y + point.y * radius
                let dotRadius = radius * (index.isMultiple(of: 3) ? 0.13 : 0.115)
                let dot = Path(ellipseIn: CGRect(x: x - dotRadius, y: y - dotRadius, width: dotRadius * 2, height: dotRadius * 2))
                context.fill(dot, with: .color(MetroTheme.cyan.opacity(index.isMultiple(of: 2) ? 0.82 : 0.5)))
                context.stroke(dot, with: .color(MetroTheme.cyan.opacity(0.7)), lineWidth: 0.6)
            }

            if progress < 1.3 {
                let capture = bounded(progress)
                let neutron = CGPoint(x: size.width * 0.1 + (center.x - size.width * 0.1) * capture, y: center.y)
                drawNeutron(at: neutron, radius: 5, opacity: 1 - bounded((progress - 1) / 0.3), context: &context)
                if capture < 0.95 {
                    drawArrow(from: CGPoint(x: neutron.x - 27, y: neutron.y), to: CGPoint(x: neutron.x - 10, y: neutron.y), color: MetroTheme.amber.opacity(0.65), context: &context)
                }
            }

            if split > 0 {
                let emitted = split * 0.45 + recoil * 0.55
                for angle in [-1.12, 0.55, 2.34] {
                    let distance = radius * (0.65 + emitted * 1.78)
                    let neutron = CGPoint(x: center.x + cos(angle) * distance, y: center.y + sin(angle) * distance)
                    let trailStart = CGPoint(x: neutron.x - cos(angle) * 18 * emitted, y: neutron.y - sin(angle) * 18 * emitted)
                    var trail = Path()
                    trail.move(to: trailStart)
                    trail.addLine(to: neutron)
                    context.stroke(trail, with: .color(MetroTheme.amber.opacity(0.5 * split)), style: StrokeStyle(lineWidth: 1.2, dash: [3, 3]))
                    drawNeutron(at: neutron, radius: 4.2, opacity: split, context: &context)
                }
                for side in [-1.0, 1.0] {
                    let from = CGPoint(x: center.x + side * (separation + radius * 0.45), y: center.y + radius * 1.12)
                    let to = CGPoint(x: from.x + side * radius * (0.28 + recoil * 0.46), y: from.y)
                    drawArrow(from: from, to: to, color: MetroTheme.violet.opacity(split * 0.9), context: &context)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func bounded(_ value: Double) -> Double { min(1, max(0, value)) }

    private func drawGrid(context: inout GraphicsContext, size: CGSize) {
        var grid = Path()
        for x in stride(from: 12.0, through: size.width, by: 24) {
            grid.move(to: CGPoint(x: x, y: 0))
            grid.addLine(to: CGPoint(x: x, y: size.height))
        }
        for y in stride(from: 12.0, through: size.height, by: 24) {
            grid.move(to: CGPoint(x: 0, y: y))
            grid.addLine(to: CGPoint(x: size.width, y: y))
        }
        context.stroke(grid, with: .color(MetroTheme.muted.opacity(0.075)), lineWidth: 0.5)
    }

    private func drawNeutron(at point: CGPoint, radius: Double, opacity: Double, context: inout GraphicsContext) {
        let neutron = Path(ellipseIn: CGRect(x: point.x - radius, y: point.y - radius, width: radius * 2, height: radius * 2))
        context.fill(neutron, with: .color(MetroTheme.amber.opacity(opacity)))
        let ring = Path(ellipseIn: CGRect(x: point.x - radius - 3, y: point.y - radius - 3, width: (radius + 3) * 2, height: (radius + 3) * 2))
        context.stroke(ring, with: .color(MetroTheme.amber.opacity(0.3 * opacity)), lineWidth: 0.7)
    }

    private func drawArrow(from start: CGPoint, to end: CGPoint, color: Color, context: inout GraphicsContext) {
        let direction = atan2(end.y - start.y, end.x - start.x)
        var arrow = Path()
        arrow.move(to: start)
        arrow.addLine(to: end)
        arrow.move(to: CGPoint(x: end.x - cos(direction - .pi / 6) * 6, y: end.y - sin(direction - .pi / 6) * 6))
        arrow.addLine(to: end)
        arrow.addLine(to: CGPoint(x: end.x - cos(direction + .pi / 6) * 6, y: end.y - sin(direction + .pi / 6) * 6))
        context.stroke(arrow, with: .color(color), style: StrokeStyle(lineWidth: 1.5, lineCap: .round, lineJoin: .round))
    }
}
