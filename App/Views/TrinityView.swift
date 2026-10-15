import SwiftUI
import LosAlamosCore

struct TrinityView: View {
    let isSelected: Bool
    @State private var time = TrinityModel.frame(at: LaunchOptions.time).time
    @State private var playing = false
    @State private var rate = 1.0
    @State private var restrainedLight = true
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .largeTitle) private var timeFontSize = 42.0

    private var frame: TrinityFrame { TrinityModel.frame(at: time) }
    private var scrub: Binding<Double> {
        Binding(get: { time }, set: { playing = false; time = $0 })
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                LabHeader(kicker: "01 / Historical observation", title: "A dawn that changed history.",
                          subtitle: "Trinity · New Mexico · 16 July 1945")

                VStack(spacing: 0) {
                    TrinityScene(frame: frame, restrainedLight: restrainedLight)
                        .frame(height: 270)
                    Group {
                        if typeSize.isAccessibilitySize {
                            VStack(alignment: .leading, spacing: 12) {
                                timeReadout
                                stageReadout
                            }.frame(maxWidth: .infinity, alignment: .leading)
                        } else {
                            HStack(alignment: .firstTextBaseline) {
                                timeReadout
                                Spacer(minLength: 8)
                                stageReadout.multilineTextAlignment(.trailing)
                            }
                        }
                    }.padding(16)
                }
                .background(MetroTheme.panel, in: .rect(cornerRadius: 28))
                .overlay {
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(LinearGradient(colors: [.white.opacity(0.30), .white.opacity(0.04), .white.opacity(0.12)],
                                               startPoint: .topLeading, endPoint: .bottomTrailing), lineWidth: 1)
                        .allowsHitTesting(false)
                }
                .accessibilityElement(children: .contain)

                timelineControls

                InstrumentPanel(title: frame.stage.title, eyebrow: "What you are seeing", accent: MetroTheme.amber) {
                    Text(frame.stage.detail).font(.subheadline).foregroundStyle(MetroTheme.text)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("The energy begins at the scale of a nucleus. The visible cloud comes later, as heated air rises and mixes with its surroundings.")
                        .font(.subheadline).foregroundStyle(MetroTheme.muted)
                }

                InstrumentPanel(title: "Read the sequence", eyebrow: "Jump to a phase") {
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 6) { phaseButtons }
                        VStack(spacing: 6) { phaseButtons }
                    }
                    ModelNote(text: "The desert, light, cloud, and ring are schematic. Animation timing is illustrative; sizes and brightness are not measured. No blast, radiation, or fallout prediction is made.")
                }

                InstrumentPanel(title: "Viewing comfort", eyebrow: "Display") {
                    Toggle("Restrained light", isOn: $restrainedLight).tint(MetroTheme.cyan)
                        .font(.subheadline).foregroundStyle(MetroTheme.text)
                    Text("Keeps the brief light effect dim and local to the instrument. Reduce Motion pauses playback; every phase remains available by scrubbing.")
                        .font(.caption).foregroundStyle(MetroTheme.muted)
                }
            }
            .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 28)
            .frame(maxWidth: 640).frame(maxWidth: .infinity)
        }
        .task(id: playing) { await playback() }
        .onChange(of: isSelected) { _, selected in if !selected { playing = false } }
        .onChange(of: scenePhase) { _, phase in if phase != .active { playing = false } }
        .onChange(of: reduceMotion) { _, reduced in if reduced { playing = false } }
        .sensoryFeedback(.selection, trigger: frame.stage)
    }

    private var timeReadout: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text("ILLUSTRATIVE ELAPSED TIME")
                .font(.system(.caption2, design: .monospaced)).tracking(1)
                .foregroundStyle(MetroTheme.muted)
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(String(format: "%04.1f", time))
                    .font(.system(size: timeFontSize, weight: .light, design: .rounded)).monospacedDigit()
                Text("s").font(.system(.callout, design: .monospaced))
            }.foregroundStyle(MetroTheme.text)
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Illustrative elapsed time")
        .accessibilityValue(String(format: "%.1f seconds", time))
        .accessibilityIdentifier("elapsedTime")
    }

    private var stageReadout: some View {
        Text(frame.stage.title)
            .font(.system(.headline, design: .serif)).italic()
            .foregroundStyle(MetroTheme.amber)
            .accessibilityIdentifier("trinityStage")
    }

    private var timelineControls: some View {
        VStack(spacing: 12) {
            Slider(value: scrub, in: 0...TrinityModel.duration, step: 0.1)
                .accessibilityLabel("Trinity timeline")
                .accessibilityValue(String(format: "%.1f illustrative seconds", time))
                .accessibilityIdentifier("trinityTimeline")
                .instrumentControlOwnsTouches(identifier: "timeline")
            HStack {
                Text("0 s"); Spacer(); Text("ILLUSTRATIVE SEQUENCE"); Spacer(); Text("30 s")
            }.font(.system(.caption2, design: .monospaced)).foregroundStyle(MetroTheme.muted)
            GlassEffectContainer(spacing: 12) {
                HStack(spacing: 12) {
                    GlassAction(title: "Reset", symbol: "arrow.counterclockwise") { playing = false; time = 0 }
                        .accessibilityIdentifier("resetTrinity")
                    GlassAction(title: playing ? "Pause" : (time >= 30 ? "Replay" : "Play"),
                                symbol: playing ? "pause.fill" : "play.fill", accent: MetroTheme.amber) {
                        if time >= TrinityModel.duration { time = 0 }
                        playing.toggle()
                    }.disabled(reduceMotion).accessibilityIdentifier("playTrinity")
                }
            }
            HStack {
                Stepper("Fine time", value: scrub, in: 0...TrinityModel.duration, step: 0.1)
                    .font(.caption).foregroundStyle(MetroTheme.muted)
                    .instrumentControlOwnsTouches(identifier: "fineTime")
                Menu {
                    ForEach([0.25, 0.5, 1.0, 2.0], id: \.self) { value in
                        Button("\(value.formatted())×") { rate = value }
                    }
                } label: {
                    Text("\(rate.formatted())×").font(.system(.subheadline, design: .monospaced))
                        .frame(minWidth: 60, minHeight: 44)
                }.accessibilityLabel("Playback speed").accessibilityValue("\(rate.formatted()) times")
            }
            if reduceMotion {
                Text("Reduce Motion is on. Use the timeline or phase buttons.")
                    .font(.caption).foregroundStyle(MetroTheme.muted)
            }
        }
    }

    private var phaseButtons: some View {
        ForEach(Array(zip(["Quiet", "Flash", "Fireball", "Rise", "Cloud"], [0.0, 0.1, 2.0, 9.0, 25.0])), id: \.0) { title, instant in
            Button(title) { playing = false; time = instant }
                .font(.system(.caption, design: .rounded, weight: .medium))
                .foregroundStyle(MetroTheme.cyan)
                .frame(maxWidth: .infinity, minHeight: 44)
                .background(MetroTheme.cyan.opacity(0.06), in: .rect(cornerRadius: 12))
                .buttonStyle(.plain)
                .accessibilityLabel("View \(title) phase")
                .accessibilityIdentifier("phase\(title)")
                .instrumentControlOwnsTouches(identifier: "phase\(title)")
        }
    }

    @MainActor private func playback() async {
        guard playing, isSelected, !reduceMotion, scenePhase == .active else { return }
        var last = ProcessInfo.processInfo.systemUptime
        while playing && !Task.isCancelled {
            do { try await Task.sleep(for: .milliseconds(33)) } catch { return }
            guard playing, !Task.isCancelled, isSelected, scenePhase == .active else { return }
            let now = ProcessInfo.processInfo.systemUptime
            time = min(TrinityModel.duration, time + min(now - last, 0.2) * rate)
            last = now
            if time >= TrinityModel.duration { playing = false }
        }
    }
}

struct TrinityScene: View {
    let frame: TrinityFrame
    let restrainedLight: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            Canvas { context, size in
                drawScene(context: &context, size: size)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("TRINITY / OBSERVATION 01").foregroundStyle(MetroTheme.cyan)
                Text("SCHEMATIC · NOT TO SCALE").foregroundStyle(MetroTheme.muted)
            }.font(.system(size: 10, weight: .medium, design: .monospaced))
                .tracking(1.2).padding(18)
            VStack {
                Spacer()
                HStack {
                    Label("Light → expansion → convection", systemImage: "arrow.right")
                    Spacer(minLength: 0)
                }.font(.system(size: 10, design: .monospaced))
                    .foregroundStyle(MetroTheme.muted).padding(16)
            }
        }
        .background(LinearGradient(colors: [Color(red: 0.03, green: 0.07, blue: 0.10), MetroTheme.background],
                                   startPoint: .top, endPoint: .bottom))
        .clipShape(.rect(cornerRadius: 28))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Trinity illustration")
        .accessibilityValue(frame.stage.title)
    }

    private func drawScene(context: inout GraphicsContext, size: CGSize) {
        let w = size.width, h = size.height
        let center = CGPoint(x: w * 0.5, y: h * 0.77)
        // All drawing dimensions are screen coordinates, never physical distances.
        var terrain = Path()
        terrain.move(to: CGPoint(x: 0, y: h * 0.69))
        for index in 0...40 {
            let x = w * CGFloat(index) / 40
            let y = h * (0.69 + 0.018 * sin(Double(index) * 0.57) + 0.012 * cos(Double(index) * 1.2))
            terrain.addLine(to: CGPoint(x: x, y: y))
        }
        terrain.addLine(to: CGPoint(x: w, y: h)); terrain.addLine(to: CGPoint(x: 0, y: h)); terrain.closeSubpath()
        context.fill(terrain, with: .linearGradient(Gradient(colors: [Color(red: 0.08, green: 0.095, blue: 0.10), .black]),
                                                   startPoint: CGPoint(x: 0, y: h * 0.69), endPoint: CGPoint(x: 0, y: h)))
        var grid = Path()
        for index in -8...8 {
            grid.move(to: CGPoint(x: w * 0.5 + CGFloat(index) * 14, y: h * 0.73))
            grid.addLine(to: CGPoint(x: w * 0.5 + CGFloat(index) * 75, y: h))
        }
        for index in 0...7 {
            let y = h * 0.73 + pow(CGFloat(index) / 7, 2) * h * 0.27
            grid.move(to: CGPoint(x: 0, y: y)); grid.addLine(to: CGPoint(x: w, y: y))
        }
        context.stroke(grid, with: .color(MetroTheme.cyan.opacity(0.09)), lineWidth: 0.5)
        for index in 0..<28 {
            let x = noise(index * 3) * w, y = (0.18 + noise(index * 3 + 1) * 0.39) * h
            context.fill(Path(ellipseIn: CGRect(x: x, y: y, width: 1.2, height: 1.2)), with: .color(.white.opacity(0.15)))
        }
        let flash = frame.flash * (restrainedLight ? 0.12 : 0.27)
        if flash > 0 {
            context.fill(Path(ellipseIn: CGRect(x: center.x - w * 0.35, y: center.y - h * 0.35, width: w * 0.7, height: h * 0.7)),
                         with: .radialGradient(Gradient(colors: [MetroTheme.amber.opacity(flash), .clear]),
                                               center: center, startRadius: 0, endRadius: w * 0.35))
        }
        if frame.time > 0 {
            let progress = CGFloat(frame.shockwave)
            let radius = w * (0.03 + 0.65 * progress)
            let ring = CGRect(x: center.x - radius, y: center.y - radius * 0.20, width: radius * 2, height: radius * 0.40)
            context.stroke(Path(ellipseIn: ring), with: .color(MetroTheme.cyan.opacity(0.65 * (1 - frame.shockwave))), lineWidth: 1.4)
            context.stroke(Path(ellipseIn: ring.insetBy(dx: 4, dy: 1)), with: .color(MetroTheme.cyan.opacity(0.12)), lineWidth: 3)
        }
        if frame.cloud > 0.005 { drawCloud(context: &context, size: size, center: center) }
        if frame.fireball > 0.01 {
            let radius = CGFloat(frame.fireball) * w * 0.19 + w * 0.014
            let origin = CGPoint(x: center.x, y: center.y - radius * 0.48)
            let opacity = max(0, 1 - frame.cloud * 4)
            context.fill(Path(ellipseIn: CGRect(x: origin.x - radius * 1.4, y: origin.y - radius * 1.4, width: radius * 2.8, height: radius * 2.8)),
                         with: .radialGradient(Gradient(colors: [MetroTheme.amber.opacity(0.22 * opacity), .clear]), center: origin, startRadius: 0, endRadius: radius * 1.4))
            context.fill(Path(ellipseIn: CGRect(x: origin.x - radius, y: origin.y - radius, width: radius * 2, height: radius * 2)),
                         with: .radialGradient(Gradient(colors: [Color(red: 1, green: 0.87, blue: 0.57).opacity(opacity), MetroTheme.amber.opacity(0.8 * opacity), Color(red: 0.7, green: 0.28, blue: 0.1).opacity(0.2 * opacity)]), center: origin, startRadius: 0, endRadius: radius))
            context.stroke(Path(ellipseIn: CGRect(x: origin.x - radius, y: origin.y - radius, width: radius * 2, height: radius * 2)), with: .color(MetroTheme.amber.opacity(0.35 * opacity)), lineWidth: 0.7)
        }
        if frame.time == 0 {
            var marker = Path()
            marker.move(to: CGPoint(x: center.x, y: center.y - 10)); marker.addLine(to: CGPoint(x: center.x - 5, y: center.y))
            marker.addLine(to: CGPoint(x: center.x + 5, y: center.y)); marker.closeSubpath()
            context.stroke(marker, with: .color(MetroTheme.amber), lineWidth: 1)
            context.stroke(Path(ellipseIn: CGRect(x: center.x - 22, y: center.y - 4, width: 44, height: 8)), with: .color(MetroTheme.amber.opacity(0.3)), lineWidth: 0.6)
        }
        // Fixed metal-like corner calibration stays independent of the changing illustration.
        var corners = Path()
        for x in [CGFloat(12), w - 12] {
            let inward: CGFloat = x < w / 2 ? 1 : -1
            corners.move(to: CGPoint(x: x, y: 62)); corners.addLine(to: CGPoint(x: x + inward * 10, y: 62))
            corners.move(to: CGPoint(x: x, y: 62)); corners.addLine(to: CGPoint(x: x, y: 76))
        }
        context.stroke(corners, with: .color(.white.opacity(0.22)), lineWidth: 0.7)
    }

    private func drawCloud(context: inout GraphicsContext, size: CGSize, center: CGPoint) {
        let growth = CGFloat(frame.cloud), w = size.width, h = size.height
        let top = center.y - h * (0.18 + 0.37 * growth)
        let capWidth = w * (0.16 + 0.28 * growth)
        let capHeight = h * (0.08 + 0.13 * growth)
        // Stable seeded puffs depict convection schematically; no fluid solver is claimed.
        for index in 0..<30 {
            let u = CGFloat(index) / 29
            let r = w * (0.018 + 0.026 * noise(index + 90)) * (0.5 + growth)
            let p = CGPoint(x: center.x + (noise(index + 130) - 0.5) * w * 0.065,
                            y: center.y - (center.y - top) * u)
            puff(context: &context, center: p, radius: r, warmth: 0.26 + 0.25 * (1 - u), opacity: frame.cloud)
        }
        for index in 0..<85 {
            let theta = noise(index + 250) * .pi * 2
            let distance = sqrt(noise(index + 320))
            let p = CGPoint(x: center.x + cos(theta) * distance * capWidth,
                            y: top + sin(theta) * distance * capHeight * 0.7 + capHeight * 0.2)
            let radius = w * (0.025 + noise(index + 410) * 0.038) * (0.6 + growth * 0.7)
            puff(context: &context, center: p, radius: radius, warmth: 0.18 + noise(index + 510) * 0.28, opacity: min(1, frame.cloud * 2))
        }
        var cap = Path()
        cap.addEllipse(in: CGRect(x: center.x - capWidth, y: top - capHeight * 0.55, width: capWidth * 2, height: capHeight * 1.4))
        context.stroke(cap, with: .color(MetroTheme.amber.opacity(0.13 * frame.cloud)), lineWidth: 0.6)
    }

    private func puff(context: inout GraphicsContext, center: CGPoint, radius: CGFloat, warmth: Double, opacity: Double) {
        let shade = Color(red: 0.16 + warmth * 0.55, green: 0.17 + warmth * 0.27, blue: 0.18 + warmth * 0.08)
        let rect = CGRect(x: center.x - radius, y: center.y - radius, width: radius * 2, height: radius * 2)
        context.fill(Path(ellipseIn: rect), with: .radialGradient(Gradient(colors: [shade.opacity(0.9 * opacity), shade.opacity(0.75 * opacity), Color(red: 0.07, green: 0.08, blue: 0.09).opacity(0.25 * opacity)]), center: CGPoint(x: center.x - radius * 0.3, y: center.y - radius * 0.35), startRadius: 0, endRadius: radius * 1.35))
        context.stroke(Path(ellipseIn: rect), with: .color(MetroTheme.amber.opacity(0.035 * opacity)), lineWidth: 0.5)
    }

    private func noise(_ seed: Int) -> CGFloat {
        let value = sin(Double(seed) * 12.9898 + 78.233) * 43758.5453
        return CGFloat(value - floor(value))
    }
}
