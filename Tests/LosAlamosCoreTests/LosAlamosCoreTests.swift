import XCTest
@testable import LosAlamosCore

final class LosAlamosCoreTests: XCTestCase {
    func testEveryChainStartsWithOne() {
        for factor in stride(from: 0.5, through: 1.5, by: 0.05) {
            let chain = ChainReaction(reproductionFactor: factor)
            XCTAssertEqual(chain.population(at: 0), 1)
            XCTAssertEqual(chain.cumulativePopulation(through: 0), 1)
        }
    }

    func testExpectedPopulationHasCorrectDirectionAndRegime() {
        for factor in [0.5, 0.9, 1.0, 1.1, 1.5] {
            let chain = ChainReaction(reproductionFactor: factor)
            for generation in 1...12 {
                let previous = chain.population(at: generation - 1)
                let current = chain.population(at: generation)
                if factor < 1 { XCTAssertLessThan(current, previous) }
                if factor == 1 { XCTAssertEqual(current, previous) }
                if factor > 1 { XCTAssertGreaterThan(current, previous) }
            }
            XCTAssertEqual(chain.regime, factor < 1 ? .subcritical : factor > 1 ? .supercritical : .critical)
        }
    }

    func testCriticalExpectationDoesNotInventGrowth() {
        let chain = ChainReaction(reproductionFactor: 1)
        XCTAssertEqual(chain.population(at: 12), 1)
        XCTAssertEqual(chain.cumulativePopulation(through: 12), 13)
    }

    func testCumulativePopulationAddsEachNewGeneration() {
        for factor in [0.5, 1.0, 1.5] {
            let chain = ChainReaction(reproductionFactor: factor)
            for generation in 1...12 {
                XCTAssertEqual(
                    chain.cumulativePopulation(through: generation) - chain.cumulativePopulation(through: generation - 1),
                    chain.population(at: generation),
                    accuracy: 1e-12
                )
            }
        }
    }

    func testPedagogicalInputBoundsAndNonfiniteFactors() {
        XCTAssertEqual(ChainReaction(reproductionFactor: -100).reproductionFactor, 0.5)
        XCTAssertEqual(ChainReaction(reproductionFactor: 100).reproductionFactor, 1.5)
        for invalid in [Double.nan, .infinity, -.infinity] {
            let chain = ChainReaction(reproductionFactor: invalid)
            XCTAssertEqual(chain.reproductionFactor, 1)
            XCTAssertTrue(chain.population(at: 12).isFinite)
        }
        let chain = ChainReaction(reproductionFactor: 1.5)
        XCTAssertEqual(chain.population(at: Int.min), 1)
        XCTAssertEqual(chain.population(at: Int.max), chain.population(at: 12))
        XCTAssertEqual(chain.cumulativePopulation(through: Int.min), 1)
        XCTAssertEqual(chain.cumulativePopulation(through: Int.max), chain.cumulativePopulation(through: 12))
    }

    func testFractionalValuesAreExpectations() {
        XCTAssertEqual(ChainReaction(reproductionFactor: 0.5).population(at: 3), 0.125)
        XCTAssertTrue(ReactionRegime.critical.explanation.contains("individual"))
    }

    func testEnergyAccountingAndMassEnergyRelation() {
        XCTAssertEqual(FissionEnergy.energyPerEventMeV, 200)
        XCTAssertEqual(FissionEnergy.energyPerEventJoules, 3.204353268e-11, accuracy: 1e-24)
        XCTAssertEqual(
            FissionEnergy.massEquivalentPerEventKg * FissionEnergy.speedOfLightMetresPerSecond * FissionEnergy.speedOfLightMetresPerSecond,
            FissionEnergy.energyPerEventJoules,
            accuracy: 1e-24
        )
        XCTAssertEqual(FissionEnergy.joules(eventCount: 2), 2 * FissionEnergy.joules(eventCount: 1))
        XCTAssertEqual(FissionEnergy.joules(eventCount: 0), 0)
        XCTAssertTrue(FissionEnergy.joules(eventCount: Double.greatestFiniteMagnitude).isFinite)
    }

    func testInvalidEnergyInputsCannotProduceNonfiniteReadouts() {
        for invalid in [-1.0, .nan, .infinity, -.infinity] {
            XCTAssertEqual(FissionEnergy.joules(eventCount: invalid), 0)
        }
    }

    func testAllVisualEnvelopesRemainDimensionlessAndBounded() {
        for time in stride(from: 0.0, through: TrinityModel.duration, by: 0.01) {
            let frame = TrinityModel.frame(at: time)
            for value in [frame.flash, frame.fireball, frame.cloud, frame.shockwave] {
                XCTAssertTrue(value.isFinite)
                XCTAssertGreaterThanOrEqual(value, 0)
                XCTAssertLessThanOrEqual(value, 1)
            }
        }
    }

    func testVisualTimeBoundsAndNonfiniteInputs() {
        XCTAssertEqual(TrinityModel.frame(at: -1), TrinityModel.frame(at: 0))
        XCTAssertEqual(TrinityModel.frame(at: 100), TrinityModel.frame(at: TrinityModel.duration))
        for invalid in [Double.nan, .infinity, -.infinity] {
            XCTAssertEqual(TrinityModel.frame(at: invalid), TrinityModel.frame(at: 0))
        }
    }

    func testVisualSequenceBeginsQuietlyAndFlashFades() {
        let start = TrinityModel.frame(at: 0)
        XCTAssertEqual(start.stage, .beforeFlash)
        XCTAssertEqual(start.flash, 0)
        XCTAssertEqual(start.fireball, 0)
        XCTAssertEqual(start.cloud, 0)
        XCTAssertEqual(start.shockwave, 0)
        XCTAssertGreaterThan(TrinityModel.frame(at: 0.1).flash, 0.9)
        XCTAssertEqual(TrinityModel.frame(at: 2).flash, 0)
        XCTAssertEqual(TrinityModel.frame(at: TrinityModel.duration).stage, .settledCloud)
    }

    func testVisualProgressAndStageDescriptionsHaveTeachingContent() {
        var previousCloud = 0.0
        var previousShockwave = 0.0
        for time in stride(from: 0.0, through: TrinityModel.duration, by: 0.1) {
            let frame = TrinityModel.frame(at: time)
            XCTAssertGreaterThanOrEqual(frame.cloud, previousCloud)
            XCTAssertGreaterThanOrEqual(frame.shockwave, previousShockwave)
            previousCloud = frame.cloud
            previousShockwave = frame.shockwave
        }
        for stage in TrinityStage.allCases {
            XCTAssertFalse(stage.title.isEmpty)
            XCTAssertGreaterThan(stage.detail.count, 30)
        }
    }
}
