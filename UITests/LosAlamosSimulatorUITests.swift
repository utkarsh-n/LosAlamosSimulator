import XCTest

final class LosAlamosSimulatorUITests: XCTestCase {
    @MainActor func testTrinityPlaybackAndReset() throws {
        let app = launchApp(arguments: ["--lab=0", "--time=9"])
        let timeline = app.sliders["trinityTimeline"]
        let playback = app.buttons["playTrinity"]

        try reveal(app.buttons["resetTrinity"], in: app)
        assertValue(timeline, equals: "9.0 illustrative seconds")
        app.buttons["resetTrinity"].tap()
        assertValue(timeline, equals: "0.0 illustrative seconds")
        assertLabel(app.staticTexts["trinityStage"], equals: "Before the flash")

        try reveal(playback, in: app)
        XCTAssertTrue(playback.isEnabled, "Playback must be available when Reduce Motion is off.")
        playback.tap()
        assertLabel(playback, equals: "Pause")
        assertEventually(NSPredicate(format: "value != %@", "0.0 illustrative seconds"), on: timeline,
                         message: "Playing should advance the timeline.")
        playback.tap()
        assertLabel(playback, equals: "Play")

        let pausedValue = try XCTUnwrap(timeline.value as? String)
        let changesWhilePaused = XCTNSPredicateExpectation(
            predicate: NSPredicate(format: "value != %@", pausedValue), object: timeline)
        changesWhilePaused.isInverted = true
        XCTAssertEqual(XCTWaiter.wait(for: [changesWhilePaused], timeout: 0.5), .completed,
                       "Pausing should keep the elapsed time fixed.")

        app.buttons["resetTrinity"].tap()
        assertValue(timeline, equals: "0.0 illustrative seconds")
        assertLabel(playback, equals: "Play")
    }

    @MainActor func testChainRegimesAndGenerationControl() throws {
        let app = launchApp(arguments: ["--lab=2", "--generation=6", "--k=1.2"])
        let factorValue = app.staticTexts["factorValue"]

        for (preset, expected) in [("Fades", "0.80"), ("Steady", "1.00"), ("Grows", "1.20")] {
            let button = app.buttons["regime\(preset)"]
            try reveal(button, in: app)
            button.tap()
            assertLabel(factorValue, equals: expected)
        }

        // Exercise UIKit's native stepper buttons: this must reach exactly k = 1
        // through four user actions, rather than by using the Steady preset.
        let decrement = app.steppers["factorStepper"].buttons["Decrement"]
        for expected in ["1.15", "1.10", "1.05", "1.00"] {
            try reveal(decrement, in: app)
            decrement.tap()
            assertLabel(factorValue, equals: expected)
        }
        assertValue(app.sliders["factorSlider"], equals: "1.00")

        let generation = app.steppers["generationStepper"]
        let increment = generation.buttons["Increment"]
        try reveal(increment, in: app)
        XCTAssertTrue(app.staticTexts["Generation 6"].exists)
        increment.tap()
        XCTAssertTrue(app.staticTexts["Generation 7"].waitForExistence(timeout: 3))
        generation.buttons["Decrement"].tap()
        XCTAssertTrue(app.staticTexts["Generation 6"].waitForExistence(timeout: 3))

        // At k = 1 the expected population stays level when generations change.
        assertValue(app.descendants(matching: .any)["expectedPopulation"].firstMatch, equals: "1.00 particles")
    }

    @MainActor func testFissionStagesAndBoundaryButtons() throws {
        let app = launchApp(arguments: ["--lab=1"])
        let next = app.buttons["Next fission stage"]
        let previous = app.buttons["Previous fission stage"]
        let slider = app.sliders["Fission stage"]
        let stages = ["Approach", "Capture", "Deform", "Split", "Recoil"]

        try reveal(next, in: app)
        assertValue(slider, equals: "Approach, stage 1 of 5")
        XCTAssertFalse(previous.isEnabled)
        XCTAssertTrue(next.isEnabled)

        for (index, stage) in stages.enumerated().dropFirst() {
            try reveal(next, in: app)
            next.tap()
            assertValue(slider, equals: "\(stage), stage \(index + 1) of 5")
            XCTAssertTrue(previous.isEnabled)
        }
        assertEventually(NSPredicate(format: "enabled == false"), on: next,
                         message: "Next must stop at the fifth stage.")

        for index in (0..<stages.count - 1).reversed() {
            try reveal(previous, in: app)
            previous.tap()
            assertValue(slider, equals: "\(stages[index]), stage \(index + 1) of 5")
            XCTAssertTrue(next.isEnabled)
        }
        assertEventually(NSPredicate(format: "enabled == false"), on: previous,
                         message: "Previous must stop at the first stage.")
    }

    @MainActor func testAllLearningSurfacesAreReachable() throws {
        let app = launchApp()
        XCTAssertTrue(app.staticTexts["A dawn that changed history."].waitForExistence(timeout: 10))

        for (tab, heading) in [
            ("Fission", "One nucleus. One event."),
            ("Chain", "One becomes many."),
            ("Field Notes", "Dawn at Trinity"),
            ("Trinity", "A dawn that changed history.")
        ] {
            let button = app.tabBars.buttons[tab]
            XCTAssertTrue(button.isHittable, "The \(tab) tab should remain accessible.")
            button.tap()
            XCTAssertTrue(app.staticTexts[heading].waitForExistence(timeout: 5),
                          "The \(tab) tab should show its own content.")
            XCTAssertTrue(button.isSelected)
        }

        // The persistent information button should reach Field Notes from each lab.
        for tab in ["Trinity", "Fission", "Chain"] {
            app.tabBars.buttons[tab].tap()
            let notes = app.buttons["fieldNotesButton"]
            XCTAssertTrue(notes.isHittable)
            notes.tap()
            XCTAssertTrue(app.staticTexts["Dawn at Trinity"].waitForExistence(timeout: 5))
            XCTAssertTrue(app.tabBars.buttons["Field Notes"].isSelected)
        }
    }

    @MainActor func testLargestDynamicTypeKeepsLabControlsReachable() throws {
        let app = launchApp(arguments: ["--lab=1", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryL"])
        let header = app.staticTexts["One nucleus. One event."]
        XCTAssertTrue(header.waitForExistence(timeout: 10))
        let defaultHeight = header.frame.height
        app.terminate()

        app.launchArguments = ["--lab=1", "-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        XCTAssertTrue(header.waitForExistence(timeout: 10))
        XCTAssertGreaterThan(header.frame.height, defaultHeight,
                             "The launch argument must actually apply the largest accessibility text size.")

        let next = app.buttons["Next fission stage"]
        try reveal(next, in: app)
        next.tap()
        assertValue(app.sliders["Fission stage"], equals: "Capture, stage 2 of 5")

        app.tabBars.buttons["Trinity"].tap()
        let reset = app.buttons["resetTrinity"]
        try reveal(reset, in: app)
        reset.tap()
        assertValue(app.sliders["trinityTimeline"], equals: "0.0 illustrative seconds")
        XCTAssertTrue(app.buttons["playTrinity"].isHittable)

        app.tabBars.buttons["Chain"].tap()
        let steady = app.buttons["regimeSteady"]
        try reveal(steady, in: app)
        steady.tap()
        assertLabel(app.staticTexts["factorValue"], equals: "1.00")
        let increment = app.steppers["generationStepper"].buttons["Increment"]
        try reveal(increment, in: app)
        increment.tap()
        XCTAssertTrue(app.staticTexts["Generation 1"].waitForExistence(timeout: 3))

        app.buttons["fieldNotesButton"].tap()
        try reveal(app.staticTexts["Dawn at Trinity"], in: app)
        XCTAssertTrue(app.tabBars.buttons["Field Notes"].isSelected)
    }

    @MainActor private func launchApp(arguments: [String] = []) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = arguments
        app.launch()
        return app
    }

    @MainActor private func reveal(_ element: XCUIElement, in app: XCUIApplication,
                                   maxSwipes: Int = 14,
                                   file: StaticString = #filePath, line: UInt = #line) throws {
        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 10), file: file, line: line)
        for attempt in 0...maxSwipes {
            if element.exists && element.isHittable { return }
            guard attempt < maxSwipes else { break }

            let targetIsAbove = element.exists && !element.frame.isEmpty
                && element.frame.midY < scrollView.frame.midY
            let startY = targetIsAbove ? 0.28 : 0.78
            let endY = targetIsAbove ? 0.78 : 0.28
            // Stay in the ScrollView's left padding: a gesture beginning inside
            // an instrument control intentionally belongs to that control.
            let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: startY))
            let end = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.02, dy: endY))
            start.press(forDuration: 0.02, thenDragTo: end)
        }
        XCTFail("Could not reveal \(element) after \(maxSwipes) scroll gestures.", file: file, line: line)
        throw InteractionFailure.unreachableElement
    }

    @MainActor private func assertLabel(_ element: XCUIElement, equals expected: String,
                                       file: StaticString = #filePath, line: UInt = #line) {
        assertEventually(NSPredicate(format: "label == %@", expected), on: element,
                         message: "Expected label: \(expected)", file: file, line: line)
    }

    @MainActor private func assertValue(_ element: XCUIElement, equals expected: String,
                                       file: StaticString = #filePath, line: UInt = #line) {
        assertEventually(NSPredicate(format: "value == %@", expected), on: element,
                         message: "Expected accessibility value: \(expected)", file: file, line: line)
    }

    @MainActor private func assertEventually(_ predicate: NSPredicate, on element: XCUIElement,
                                            message: String,
                                            file: StaticString = #filePath, line: UInt = #line) {
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        XCTAssertEqual(XCTWaiter.wait(for: [expectation], timeout: 3), .completed,
                       message, file: file, line: line)
    }

    private enum InteractionFailure: Error {
        case unreachableElement
    }
}
