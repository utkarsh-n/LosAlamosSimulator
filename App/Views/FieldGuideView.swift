import SwiftUI

struct FieldGuideView: View {
    @State private var selectedAnswers: [Int: Int] = [:]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("THE FIELD GUIDE")
                        .font(.caption.monospaced())
                        .tracking(2)
                        .foregroundStyle(MetroTheme.cyan)
                    Text("A nucleus. A chain.\nA changed world.")
                        .font(.system(.largeTitle, design: .rounded, weight: .semibold))
                        .foregroundStyle(MetroTheme.text)
                        .fixedSize(horizontal: false, vertical: true)
                    Text("Read the physics alongside the people and places it affected.")
                        .font(.subheadline)
                        .foregroundStyle(MetroTheme.muted)
                }
                .padding(.vertical, 8)

                historyChapter
                fissionChapter
                chainChapter
                aftermathChapter
                limitationsChapter
                knowledgeCheck

                Text("Independent educational app. Source links open the original institutions’ pages; they do not imply endorsement.")
                    .font(.caption)
                    .foregroundStyle(MetroTheme.muted)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.bottom, 24)
            }
            .frame(maxWidth: 640)
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .frame(maxWidth: .infinity)
        }
        .background(MetroTheme.background)
    }

    private var historyChapter: some View {
        InstrumentPanel(title: "Dawn at Trinity", eyebrow: "01 / HISTORICAL RECORD", accent: MetroTheme.amber) {
            VStack(alignment: .leading, spacing: 16) {
                fact("16 JUL 1945", detail: "5:29 a.m. • Mountain War Time", accent: MetroTheme.amber)
                paragraph("The first nuclear test took place in the Jornada del Muerto desert of New Mexico. Los Alamos was the research center; Trinity was a separate test site to the south.")
                paragraph("The flash, expanding hot gas and rising cloud marked an unprecedented release of nuclear energy. Heat fused material at the site into a glass called trinitite.")
                source("National Park Service · Trinity Site", url: "https://www.nps.gov/places/000/trinity-site.htm")

                Divider().overlay(MetroTheme.muted.opacity(0.25))
                Text("How much energy?")
                    .font(.headline)
                    .foregroundStyle(MetroTheme.text)
                fact("≈21 kt", detail: "Earlier DOE-released yield estimate", accent: MetroTheme.amber)
                fact("24.8 ± 2 kt", detail: "Selby and colleagues’ 2021 reassessment", accent: MetroTheme.violet)
                paragraph("A kiloton of TNT equivalent is an energy unit. These are historical estimates, not settings for this scene. The later study re-examined trinitite; its reported uncertainty should stay attached to the number.")
                source("Selby et al. · Original 2021 paper", url: "https://arxiv.org/abs/2103.06258")
            }
        }
    }

    private var fissionChapter: some View {
        InstrumentPanel(title: "Where the energy begins", eyebrow: "02 / INSIDE THE ATOM") {
            VStack(alignment: .leading, spacing: 16) {
                paragraph("Fission splits a heavy atomic nucleus into smaller nuclei. In neutron-induced fission, a nucleus absorbs a neutron, becomes excited and may split. Released neutrons can go on to cause other fissions.")
                Text("Nucleus → fragments + neutrons + energy")
                    .font(.callout.monospaced())
                    .foregroundStyle(MetroTheme.cyan)
                    .fixedSize(horizontal: false, vertical: true)
                paragraph("The products can have less total rest mass than the initial system. That mass difference appears as energy: E = Δm c². Much of the release becomes motion of the fragments, with other energy carried by particles, radiation and later radioactive decay.")
                fact("≈200 MeV", detail: "Representative energy per fission • million electronvolts", accent: MetroTheme.cyan)
                paragraph("This is a rounded teaching value. Exact release and energy accounting depend on the reaction and on which prompt and later contributions are included.")
                source("DOE Office of Science · Nuclear fission", url: "https://www.energy.gov/science/doe-explainsnuclear-fission")
                source("DOE · Nuclear fundamentals, pp. 12–13", url: "https://www.energy.gov/sites/prod/files/2013/10/f4/QSR-GeneralTechnicalBase.pdf")
            }
        }
    }

    private var chainChapter: some View {
        InstrumentPanel(title: "One event can lead to more", eyebrow: "03 / A BRANCHING LESSON", accent: MetroTheme.violet) {
            VStack(alignment: .leading, spacing: 16) {
                paragraph("Some released neutrons cause another fission. Others are absorbed without fission or leave the system. A chain reaction depends on how many events continue from one generation to the next.")
                Text("E[N_g] = N₀ × k^g")
                    .font(.title3.monospaced())
                    .foregroundStyle(MetroTheme.violet)
                    .accessibilityLabel("Expected population at generation g equals k to the power g, times the initial population.")
                paragraph("Here, k is an abstract reproduction factor and N₀ = 1. It describes the average population across imagined runs. A fractional expectation is an average, not part of a neutron.")
                regime("k < 1", name: "Fading", detail: "Expected population decreases.")
                regime("k = 1", name: "Steady", detail: "Expected population stays level.")
                regime("k > 1", name: "Growing", detail: "Expected population increases.")
                paragraph("An individual chain can still end. The lesson uses generations rather than real time and leaves out spatial transport, changing conditions and other limits of physical systems.")
                source("DOE · History of nuclear energy", url: "https://www.energy.gov/ne/history")
            }
        }
    }

    private var aftermathChapter: some View {
        InstrumentPanel(title: "People lived downwind", eyebrow: "04 / THE CONSEQUENCES", accent: MetroTheme.amber) {
            VStack(alignment: .leading, spacing: 16) {
                paragraph("Nearby communities were not warned in advance about the test or possible fallout. The surrounding region was inhabited: ranching families and communities lived beyond the test boundary.")
                paragraph("Radioactive material spread into the environment. Exposure could occur outside the body, through inhalation, or through contaminated food and water. New Mexico downwinders have described enduring health, emotional and financial consequences.")
                source("National Park Service · Trinity Test Downwinders", url: "https://www.nps.gov/articles/000/trinity-test-downwinders.htm")
                Divider().overlay(MetroTheme.muted.opacity(0.25))
                paragraph("The National Cancer Institute’s 2020 study reconstructed exposure and projected a range of excess cancer cases. Missing historical records and uncertainty in exposure estimates limit what can be concluded. Such projections cannot identify whether a particular person’s cancer was caused by Trinity.")
                source("National Cancer Institute · Community summary", url: "https://dceg.cancer.gov/research/how-we-study/exposure-assessment/trinity/community-summary")
            }
        }
    }

    private var limitationsChapter: some View {
        InstrumentPanel(title: "Reading this simulator", eyebrow: "05 / MODEL BOUNDARIES") {
            VStack(alignment: .leading, spacing: 16) {
                boundary("Trinity scene", detail: "A 30-second visual narrative. Shapes, brightness and motion are illustrative; the scene has no calibrated distance, temperature or pressure scale.")
                boundary("Chain lab", detail: "A generic expected branching population. Its controls do not describe the apparatus used at Trinity, and a generation is not a measured time interval.")
                boundary("Energy lab", detail: "Textbook energy accounting using approximately 200 MeV per event. It explains energy units rather than reconstructing the test.")
                paragraph("The app teaches nuclear physics and historical context. It does not calculate fallout, personal exposure or damage, and it does not reproduce weapon construction or operation.")
            }
        }
    }

    private var knowledgeCheck: some View {
        InstrumentPanel(title: "Check your understanding", eyebrow: "06 / THREE SMALL QUESTIONS", accent: MetroTheme.violet) {
            VStack(alignment: .leading, spacing: 24) {
                ForEach(GuideQuestion.questions) { question in
                    VStack(alignment: .leading, spacing: 12) {
                        Text(question.prompt)
                            .font(.headline)
                            .foregroundStyle(MetroTheme.text)
                            .fixedSize(horizontal: false, vertical: true)
                        ForEach(Array(question.answers.enumerated()), id: \.offset) { index, answer in
                            Button {
                                selectedAnswers[question.id] = index
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: selectedAnswers[question.id] == index ? "checkmark.circle.fill" : "circle")
                                        .foregroundStyle(selectedAnswers[question.id] == index ? MetroTheme.violet : MetroTheme.muted)
                                        .padding(.top, 2)
                                    Text(answer)
                                        .font(.subheadline)
                                        .foregroundStyle(MetroTheme.text)
                                        .fixedSize(horizontal: false, vertical: true)
                                    Spacer(minLength: 0)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                                .background(MetroTheme.background, in: RoundedRectangle(cornerRadius: 12))
                                .overlay {
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(selectedAnswers[question.id] == index ? MetroTheme.violet.opacity(0.7) : MetroTheme.muted.opacity(0.16), lineWidth: 1)
                                }
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(answer)
                            .accessibilityValue(selectedAnswers[question.id] == index ? "Selected" : "")
                        }
                        if let selection = selectedAnswers[question.id] {
                            VStack(alignment: .leading, spacing: 4) {
                                Label(selection == question.correctAnswer ? "Correct" : "Try another answer", systemImage: selection == question.correctAnswer ? "checkmark.circle" : "arrow.trianglehead.clockwise")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(selection == question.correctAnswer ? MetroTheme.cyan : MetroTheme.amber)
                                Text(question.explanation)
                                    .font(.subheadline)
                                    .foregroundStyle(MetroTheme.muted)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                            .accessibilityElement(children: .combine)
                        }
                    }
                }
            }
        }
    }

    private func paragraph(_ content: String) -> some View {
        Text(content)
            .font(.subheadline)
            .foregroundStyle(MetroTheme.muted)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func fact(_ value: String, detail: String, accent: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(.title2, design: .rounded, weight: .medium))
                .monospacedDigit()
                .foregroundStyle(accent)
            Text(detail)
                .font(.caption)
                .foregroundStyle(MetroTheme.muted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .accessibilityElement(children: .combine)
    }

    private func regime(_ value: String, name: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("\(value) · \(name)")
                .font(.callout.monospaced().weight(.semibold))
                .foregroundStyle(MetroTheme.violet)
            paragraph(detail)
        }
        .accessibilityElement(children: .combine)
    }

    private func boundary(_ name: String, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(name)
                .font(.headline)
                .foregroundStyle(MetroTheme.text)
            paragraph(detail)
        }
    }

    private func source(_ title: String, url: String) -> some View {
        Link(destination: URL(string: url)!) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(title)
                    .font(.caption.weight(.medium))
                    .fixedSize(horizontal: false, vertical: true)
                Image(systemName: "arrow.up.right")
                    .font(.caption)
            }
            .foregroundStyle(MetroTheme.cyan)
            .frame(minHeight: 44, alignment: .leading)
        }
        .accessibilityHint("Opens the original source in your browser")
    }
}

private struct GuideQuestion: Identifiable {
    let id: Int
    let prompt: String
    let answers: [String]
    let correctAnswer: Int
    let explanation: String

    static let questions = [
        GuideQuestion(id: 0, prompt: "What splits during nuclear fission?", answers: ["The atomic nucleus", "The electron cloud", "A water molecule"], correctAnswer: 0, explanation: "Fission produces smaller nuclei and other particles. It is a change in the nucleus."),
        GuideQuestion(id: 1, prompt: "In the chain lab, what does k = 1 mean?", answers: ["Every individual chain survives", "The expected population stays level", "No neutrons are released"], correctAnswer: 1, explanation: "The average stays level across imagined runs. Individual chains can end even when k = 1."),
        GuideQuestion(id: 2, prompt: "Can the Trinity scene predict a damage radius?", answers: ["Yes, from its drawn ring", "Yes, by changing playback speed", "No, its shapes have no physical scale"], correctAnswer: 2, explanation: "The scene shows a qualitative sequence. Its shapes and playback time are not a calibrated explosion model.")
    ]
}
