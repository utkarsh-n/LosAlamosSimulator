/// Textbook-scale energy accounting for a generic fission event.
///
/// 200 MeV is an approximate teaching value. The actual release and its partition
/// among fragments, neutrons, radiation and later decay depend on the reaction.
public enum FissionEnergy {
    public static let energyPerEventMeV: Double = 200
    /// The electronvolt-to-joule conversion follows the exact SI elementary charge.
    public static let joulesPerMeV: Double = 1.602176634e-13
    public static let speedOfLightMetresPerSecond: Double = 299_792_458
    public static let energyPerEventJoules: Double = energyPerEventMeV * joulesPerMeV
    /// Equivalent mass difference, rather than the mass of a nucleus or apparatus.
    public static let massEquivalentPerEventKg: Double = energyPerEventJoules
        / (speedOfLightMetresPerSecond * speedOfLightMetresPerSecond)

    public static func joules(eventCount: Double) -> Double {
        guard eventCount.isFinite, eventCount >= 0 else { return 0 }
        return eventCount * energyPerEventJoules
    }
}
