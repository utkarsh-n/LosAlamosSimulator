import Foundation

/// A fixed-duration visual narrative, not a calibrated explosion model.
///
/// Every envelope is dimensionless and intentionally illustrative. Values never
/// represent physical radii, temperatures, pressures, fallout, or damage.
public enum TrinityModel {
    public static let duration: Double = 30

    public static func frame(at time: Double) -> TrinityFrame {
        let boundedTime = time.isFinite ? min(max(time, 0), duration) : 0
        let flash = smoothstep(0, 0.08, boundedTime)
            * (1 - smoothstep(0.12, 1.25, boundedTime))
        let fireball = smoothstep(0.08, 4.5, boundedTime)
            * (1 - 0.7 * smoothstep(5, 18, boundedTime))
        let cloud = smoothstep(2, 22, boundedTime)
        let shockwave = smoothstep(0.12, 12, boundedTime)

        return TrinityFrame(
            time: boundedTime,
            flash: flash,
            fireball: fireball,
            cloud: cloud,
            shockwave: shockwave,
            stage: stage(at: boundedTime)
        )
    }

    private static func smoothstep(_ start: Double, _ end: Double, _ time: Double) -> Double {
        let progress = min(max((time - start) / (end - start), 0), 1)
        return progress * progress * (3 - 2 * progress)
    }

    private static func stage(at time: Double) -> TrinityStage {
        switch time {
        case ..<0.05: .beforeFlash
        case ..<1.25: .flash
        case ..<5: .fireball
        case ..<18: .risingCloud
        default: .settledCloud
        }
    }
}

public struct TrinityFrame: Equatable, Sendable {
    public let time: Double
    public let flash: Double
    public let fireball: Double
    public let cloud: Double
    public let shockwave: Double
    public let stage: TrinityStage

    public init(
        time: Double, flash: Double, fireball: Double,
        cloud: Double, shockwave: Double, stage: TrinityStage
    ) {
        self.time = time
        self.flash = flash
        self.fireball = fireball
        self.cloud = cloud
        self.shockwave = shockwave
        self.stage = stage
    }
}

public enum TrinityStage: String, CaseIterable, Identifiable, Sendable {
    case beforeFlash
    case flash
    case fireball
    case risingCloud
    case settledCloud

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .beforeFlash: "Before the flash"
        case .flash: "Light arrives"
        case .fireball: "Hot gas expands"
        case .risingCloud: "A cloud rises"
        case .settledCloud: "The cloud develops"
        }
    }

    public var detail: String {
        switch self {
        case .beforeFlash:
            "This fixed historical scene begins at the Trinity test. Scrub forward to explore a simplified visual sequence."
        case .flash:
            "Radiation carries energy away. The bright envelope here is a visual cue, not a measurement of brightness or exposure."
        case .fireball:
            "Rapidly heated material and surrounding air expand. This drawing has no calibrated temperature or distance scale."
        case .risingCloud:
            "Buoyant hot air rises and entrains surrounding air. The cloud shape is illustrative; it is not a weather or fallout calculation."
        case .settledCloud:
            "The rising cloud continues to evolve. These thirty seconds are an illustration and do not reproduce measured cloud dimensions."
        }
    }
}
