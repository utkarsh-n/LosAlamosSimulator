import SwiftUI
import Charts
import LosAlamosCore

struct ChainReactionView: View {
    let isSelected: Bool
    @State private var factor = ChainReaction(reproductionFactor: LaunchOptions.factor).reproductionFactor
    @State private var generation = min(12, max(0, LaunchOptions.generation))
    @State private var playing = false
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.dynamicTypeSize) private var typeSize
    @ScaledMetric(relativeTo: .largeTitle) private var factorFontSize = 38.0

    private var model: ChainReaction { ChainReaction(reproductionFactor: factor) }
    private var selectedFactor: Binding<Double> {
        Binding(get: { factor }, set: {
            factor = ChainReaction(reproductionFactor: ($0 * 20).rounded() / 20).reproductionFactor
            playing = false
        })
    }
    private var selectedGeneration: Binding<Int> {
        Binding(get: { generation }, set: { generation = $0; playing = false })
    }
    private var accent: Color {
        factor < 1 ? MetroTheme.violet : (factor > 1 ? MetroTheme.amber : MetroTheme.cyan)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                LabHeader(kicker: "03 / A branching process", title: "One becomes many.",
                          subtitle: "Follow successive generations in a small, abstract chain reaction.")
                InstrumentPanel(title: model.regime.title, eyebrow: "Expected population", accent: accent) {
                    ViewThatFits(in: .horizontal) {
                        HStack(alignment: .top, spacing: 16) { populationReadouts }
                        VStack(alignment: .leading, spacing: 16) { populationReadouts }
                    }
                    populationChart
                    HStack {
                        Text("Generation").foregroundStyle(MetroTheme.muted)
                        Spacer()
                        Text("0 → 12").foregroundStyle(MetroTheme.muted)
                    }.font(.system(.caption, design: .monospaced))
                    Text(model.regime.explanation).font(.subheadline).foregroundStyle(MetroTheme.text)
                    generationTable
                }

                InstrumentPanel(title: "Explore the three regimes", eyebrow: "Average continuation factor k") {
                    factorReadout
                    Slider(value: selectedFactor, in: 0.5...1.5, step: 0.05)
                        .accessibilityLabel("Average continuation factor")
                        .accessibilityValue(String(format: "%.2f", factor))
                        .accessibilityIdentifier("factorSlider")
                        .instrumentControlOwnsTouches(identifier: "factorSlider")
                    Stepper("Fine adjustment · 0.05", value: selectedFactor, in: 0.5...1.5, step: 0.05)
                        .font(.caption).foregroundStyle(MetroTheme.muted)
                        .accessibilityIdentifier("factorStepper")
                        .instrumentControlOwnsTouches(identifier: "factorStepper")
                    ViewThatFits(in: .horizontal) {
                        HStack(spacing: 8) { presets }
                        VStack(spacing: 8) { presets }
                    }
                    Text("k is an abstract average: how many continuing particles one generation contributes to the next. Here it is chosen directly, rather than derived from a material or device.")
                        .font(.caption).foregroundStyle(MetroTheme.muted)
                }

                InstrumentPanel(title: "Walk through generations", eyebrow: "Discrete steps") {
                    Stepper(value: selectedGeneration, in: 0...12) {
                        Text("Generation \(generation)").font(.system(.headline, design: .rounded))
                            .foregroundStyle(MetroTheme.text).monospacedDigit()
                    }.accessibilityIdentifier("generationStepper")
                        .instrumentControlOwnsTouches(identifier: "generationStepper")
                    GlassEffectContainer(spacing: 12) {
                        HStack(spacing: 12) {
                            GlassAction(title: "Reset", symbol: "arrow.counterclockwise") { generation = 0; playing = false }
                                .accessibilityIdentifier("resetChain")
                            GlassAction(title: playing ? "Pause" : (generation == 12 ? "Replay" : "Play"),
                                        symbol: playing ? "pause.fill" : "play.fill", accent: accent) {
                                if generation == 12 { generation = 0 }
                                playing.toggle()
                            }.disabled(reduceMotion).accessibilityIdentifier("playChain")
                        }
                    }
                    if reduceMotion {
                        Text("Reduce Motion is on. Use the generation stepper.")
                            .font(.caption).foregroundStyle(MetroTheme.muted)
                    }
                }

                InstrumentPanel(title: "Why an average can be fractional", eyebrow: "The equation") {
                    Text("E[N₍g₎] = N₀ × kᵍ     N₀ = 1")
                        .font(.system(.callout, design: .monospaced)).foregroundStyle(MetroTheme.cyan)
                        .accessibilityLabel("Expected population at generation g equals the initial population times k to the power g. The initial population is one.")
                    Text("A real neutron is indivisible. A value such as 0.8 means an average over many repeated trials. Some chains die out; others continue. This graph shows the expectation, not one random outcome.")
                        .font(.subheadline).foregroundStyle(MetroTheme.text)
                    Text("In real systems, particles may escape or be absorbed without causing another fission. Feedback and changing conditions can end growth. Constant k omits those effects.")
                        .font(.subheadline).foregroundStyle(MetroTheme.muted)
                    ModelNote(text: "Generations are not seconds. The graph is a mathematical teaching model, with no geometry, material quantities, yield, or device behavior. Its vertical scale adapts to the chosen k.")
                }
            }
            .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 28)
            .frame(maxWidth: 640).frame(maxWidth: .infinity)
        }
        .task(id: playing) { await playback() }
        .onChange(of: isSelected) { _, selected in if !selected { playing = false } }
        .onChange(of: scenePhase) { _, phase in if phase != .active { playing = false } }
        .onChange(of: reduceMotion) { _, reduced in if reduced { playing = false } }
        .sensoryFeedback(.selection, trigger: generation)
        .sensoryFeedback(.selection, trigger: factor)
    }

    private var factorReadout: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(alignment: .firstTextBaseline) {
                Text("k =").font(.system(.title3, design: .serif)).italic()
                    .foregroundStyle(MetroTheme.muted)
                Text(String(format: "%.2f", factor))
                    .font(.system(size: factorFontSize, weight: .light, design: .rounded)).monospacedDigit()
                    .foregroundStyle(accent).accessibilityIdentifier("factorValue")
                if !typeSize.isAccessibilitySize {
                    Spacer()
                    factorRelation
                }
            }
            if typeSize.isAccessibilitySize { factorRelation }
        }
    }

    private var factorRelation: some View {
        Text(factor < 1 ? "k < 1" : (factor > 1 ? "k > 1" : "k = 1"))
            .font(.system(.caption, design: .monospaced)).foregroundStyle(accent)
            .accessibilityLabel(factor < 1 ? "Factor less than one" : (factor > 1 ? "Factor greater than one" : "Factor equals one"))
    }

    private var generationTable: some View {
        DisclosureGroup("Read all generations") {
            VStack(spacing: 10) {
                ForEach(0...12, id: \.self) { index in
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Generation \(index)").font(.caption).foregroundStyle(MetroTheme.muted)
                        Text("\(number(model.population(at: index))) expected particles")
                            .font(.system(.subheadline, design: .monospaced)).foregroundStyle(MetroTheme.text)
                            .fixedSize(horizontal: false, vertical: true)
                    }.frame(maxWidth: .infinity, alignment: .leading)
                        .accessibilityElement(children: .combine)
                    if index < 12 { Divider() }
                }
            }.padding(.top, 8)
        }.font(.subheadline).foregroundStyle(MetroTheme.cyan)
            .accessibilityIdentifier("generationTable")
    }

    private var populationReadouts: some View {
        Group {
            MetricReadout(label: "Generation", value: "\(generation)", unit: "g", accent: MetroTheme.text)
            MetricReadout(label: "Expectation", value: number(model.population(at: generation)), unit: "particles", accent: accent)
                .accessibilityIdentifier("expectedPopulation")
        }
    }

    private var populationChart: some View {
        Chart {
            ForEach(0...12, id: \.self) { index in
                BarMark(x: .value("Generation", index), y: .value("Expected particles", model.population(at: index)), width: .fixed(12))
                    .foregroundStyle(index <= generation ? accent : MetroTheme.muted.opacity(0.16))
                if index == generation {
                    PointMark(x: .value("Generation", index), y: .value("Expected particles", model.population(at: index)))
                        .foregroundStyle(MetroTheme.text).symbolSize(28)
                }
            }
            RuleMark(x: .value("Selected generation", generation))
                .foregroundStyle(MetroTheme.text.opacity(0.25)).lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 4]))
        }
        .chartXScale(domain: -0.5...12.5)
        .chartYScale(domain: 0...max(1.2, (0...12).map { model.population(at: $0) }.max()! * 1.18))
        .chartXAxis {
            AxisMarks(values: [0, 3, 6, 9, 12]) { _ in
                AxisGridLine().foregroundStyle(.white.opacity(0.07))
                AxisValueLabel().foregroundStyle(MetroTheme.muted)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading, values: .automatic(desiredCount: 4)) { _ in
                AxisGridLine().foregroundStyle(.white.opacity(0.07))
                AxisValueLabel().foregroundStyle(MetroTheme.muted)
            }
        }
        .frame(height: 210).padding(12)
        .background(MetroTheme.background, in: .rect(cornerRadius: 16))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Expected population by generation")
        .accessibilityValue("At generation \(generation), \(number(model.population(at: generation))) expected particles. The expectation \(factor < 1 ? "decreases" : (factor > 1 ? "increases" : "stays constant")) across generations.")
    }

    private var presets: some View {
        ForEach(Array(zip(["Fades", "Steady", "Grows"], [0.8, 1.0, 1.2])), id: \.0) { title, value in
            Button { playing = false; factor = value } label: {
                VStack(spacing: 4) {
                    Text(title).font(.system(.subheadline, design: .rounded, weight: .semibold))
                    Text(String(format: "k = %.1f", value)).font(.system(.caption2, design: .monospaced))
                }.frame(maxWidth: .infinity, minHeight: 52)
                    .foregroundStyle(abs(factor - value) < 0.001 ? MetroTheme.text : MetroTheme.muted)
                    .background(abs(factor - value) < 0.001 ? accent.opacity(0.12) : MetroTheme.background, in: .rect(cornerRadius: 14))
            }.buttonStyle(.plain).accessibilityIdentifier("regime\(title)")
                .accessibilityLabel("\(title), factor \(value.formatted())")
                .accessibilityValue(abs(factor - value) < 0.001 ? "Selected" : "")
                .accessibilityAddTraits(abs(factor - value) < 0.001 ? .isSelected : [])
                .instrumentControlOwnsTouches(identifier: "regime\(title)")
        }
    }

    private func number(_ value: Double) -> String {
        value.formatted(.number.precision(.significantDigits(3)))
    }

    @MainActor private func playback() async {
        guard playing, isSelected, !reduceMotion, scenePhase == .active else { return }
        while playing && generation < 12 && !Task.isCancelled {
            do { try await Task.sleep(for: .milliseconds(650)) } catch { return }
            guard playing, !Task.isCancelled, isSelected, scenePhase == .active,
                  !reduceMotion, generation < 12 else { return }
            generation += 1
        }
        if !Task.isCancelled { playing = false }
    }
}
