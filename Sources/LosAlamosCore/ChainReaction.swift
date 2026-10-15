import Foundation

/// A generic branching-process lesson, with no apparatus or material parameters.
///
/// The values represent expected populations across many imagined experiments.
/// Individual neutron counts are integers; an expectation can be fractional.
public struct ChainReaction: Equatable, Sendable {
    public static let reproductionFactorRange = 0.5...1.5
    public static let generationRange = 0...12

    public let reproductionFactor: Double

    public init(reproductionFactor: Double) {
        let finiteFactor = reproductionFactor.isFinite ? reproductionFactor : 1
        self.reproductionFactor = min(
            max(finiteFactor, Self.reproductionFactorRange.lowerBound),
            Self.reproductionFactorRange.upperBound
        )
    }

    public var regime: ReactionRegime {
        if reproductionFactor < 1 { return .subcritical }
        if reproductionFactor > 1 { return .supercritical }
        return .critical
    }

    /// Starts with one abstract particle at generation zero: E[N_g] = k^g.
    public func population(at generation: Int) -> Double {
        let boundedGeneration = min(max(generation, 0), Self.generationRange.upperBound)
        return pow(reproductionFactor, Double(boundedGeneration))
    }

    /// Includes the initial particle at generation zero.
    public func cumulativePopulation(through generation: Int) -> Double {
        let boundedGeneration = min(max(generation, 0), Self.generationRange.upperBound)
        return (0...boundedGeneration).reduce(0) { total, current in
            total + population(at: current)
        }
    }
}

public enum ReactionRegime: String, CaseIterable, Identifiable, Sendable {
    case subcritical
    case critical
    case supercritical

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .subcritical: "Fading chain"
        case .critical: "Steady expectation"
        case .supercritical: "Growing chain"
        }
    }

    public var explanation: String {
        switch self {
        case .subcritical:
            "k < 1: each generation has a smaller expected population. Individual branching runs can vary."
        case .critical:
            "k = 1: the expected population stays constant. That does not guarantee any individual chain survives."
        case .supercritical:
            "k > 1: the expected population grows in this abstract model. Real systems have additional limits."
        }
    }
}
