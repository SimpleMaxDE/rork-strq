import XCTest

@MainActor
final class STRQCoreFlowSnapshotTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        configureLaunchArguments()
    }

    func testCoreFlowSnapshot() throws {
        try XCTSkipUnless(
            FileManager.default.fileExists(atPath: "/tmp/strq_capture_core_flow_enabled"),
            "Core flow snapshots are opt-in. Run scripts/qa/capture_strq_core_flow.sh."
        )

        app.launch()
        waitForAny([app.buttons["strq.today.start-workout"], app.staticTexts["Today"]], timeout: 12)
        snapshot("01-today-top")

        app.swipeUp()
        settle()
        snapshot("02-today-mid")

        tap(app.buttons["strq.tab.progress"], named: "Progress tab")
        settle()
        snapshot("13-progress-top")

        app.swipeUp()
        settle()
        snapshot("14-progress-evidence")

        tap(app.buttons["strq.tab.today"], named: "Today tab")
        app.swipeDown()
        settle()
        tap(app.buttons["strq.today.start-workout"], named: "Today start workout")

        waitFor(app.buttons["strq.handoff.start"], timeout: 8)
        snapshot("03-pre-workout-handoff-top")

        app.swipeUp()
        settle()
        snapshot("04-pre-workout-handoff-lower")

        tap(app.buttons["strq.handoff.exercise.0"], named: "First handoff exercise")
        waitForAny([app.navigationBars["Exercise Details"], app.buttons["Done"]], timeout: 8)
        snapshot("05-exercise-prescription-sheet")
        dismissCurrentSheet()

        bringIntoView(app.buttons["strq.handoff.cancel"], bySwiping: .down)
        tap(app.buttons["strq.handoff.cancel"], named: "Handoff cancel")
        waitForAny([app.buttons["strq.today.start-workout"], app.staticTexts["Today"], app.buttons["strq.tab.today"]], timeout: 8)
        snapshot("06-today-after-cancel")

        if !app.buttons["strq.today.start-workout"].waitForExistence(timeout: 2) {
            relaunchFixture()
        }
        tap(app.buttons["strq.today.start-workout"], named: "Today start workout after cancel")
        waitFor(app.buttons["strq.handoff.start"], timeout: 8)
        tap(app.buttons["strq.handoff.start"], named: "Handoff start")
        waitFor(app.buttons["strq.active-workout.log-set"], timeout: 10)
        snapshot("07-active-workout-before-set")

        let exerciseGuideButton = app.buttons.matching(identifier: "Exercise Guide").firstMatch
        if exerciseGuideButton.waitForExistence(timeout: 2) {
            tap(exerciseGuideButton, named: "Exercise Guide")
            app.swipeUp()
            settle()
            snapshot("08-exercise-detail-anatomy")
            dismissCurrentSheet()
        }

        tap(app.buttons["strq.active-workout.weight-value"], named: "Weight value")
        waitForAny([app.textFields["strq.active-workout.numeric-input"], app.navigationBars["Edit Weight"]], timeout: 8)
        snapshot("09-active-workout-numeric-edit")
        dismissCurrentSheet()

        setCurrentRepsForLogging()
        tap(app.buttons["strq.active-workout.log-set"], named: "Log first set")
        if app.buttons["strq.active-workout.rest-continue"].waitForExistence(timeout: 2) {
            snapshot("10-rest-overlay")
            tap(app.buttons["strq.active-workout.rest-continue"], named: "Continue after rest")
        }
        waitFor(app.buttons["strq.active-workout.log-set"], timeout: 8)
        snapshot("11-active-workout-after-one-set")

        tap(app.buttons["strq.active-workout.log-set"], named: "Log second set")
        if app.buttons["strq.active-workout.rest-continue"].waitForExistence(timeout: 2) {
            tap(app.buttons["strq.active-workout.rest-continue"], named: "Continue after second rest")
        }
        waitFor(app.buttons["strq.active-workout.log-set"], timeout: 8)
        app.swipeUp()
        settle()
        snapshot("12-active-workout-set-history-two-sets")
    }

    private func relaunchFixture() {
        app.terminate()
        app = XCUIApplication()
        configureLaunchArguments()
        app.launch()
        waitForAny([app.buttons["strq.today.start-workout"], app.staticTexts["Today"]], timeout: 12)
    }

    private func configureLaunchArguments() {
        app.launchArguments = [
            "-STRQUIFixture", "coreFlow",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US"
        ]
    }

    private func snapshot(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    private func tap(_ element: XCUIElement, named name: String, timeout: TimeInterval = 8) {
        waitFor(element, timeout: timeout)
        if element.isHittable {
            element.tap()
        } else {
            XCTContext.runActivity(named: "Force tap \(name)") { _ in
                element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
            }
        }
        settle()
    }

    private func waitFor(_ element: XCUIElement, timeout: TimeInterval) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "Timed out waiting for \(element)")
    }

    private func waitForAny(_ elements: [XCUIElement], timeout: TimeInterval) {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if elements.contains(where: { $0.exists }) { return }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        XCTFail("Timed out waiting for one of \(elements)")
    }

    private enum SwipeDirection {
        case up
        case down
    }

    private func bringIntoView(_ element: XCUIElement, bySwiping direction: SwipeDirection, attempts: Int = 4) {
        for _ in 0..<attempts where element.exists && !element.isHittable {
            switch direction {
            case .up:
                app.swipeUp()
            case .down:
                app.swipeDown()
            }
            settle()
        }
    }

    private func setCurrentRepsForLogging() {
        tap(app.buttons["strq.active-workout.reps-value"], named: "Reps value")
        let numericInput = app.textFields["strq.active-workout.numeric-input"]
        waitFor(numericInput, timeout: 8)
        numericInput.tap()
        numericInput.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 4))
        numericInput.typeText("8")
        tap(app.buttons.matching(identifier: "Save").firstMatch, named: "Save reps")
        waitFor(app.buttons["strq.active-workout.log-set"], timeout: 8)
    }

    private func dismissCurrentSheet() {
        if app.buttons["Done"].waitForExistence(timeout: 1) {
            app.buttons["Done"].tap()
        } else if app.buttons["Cancel"].waitForExistence(timeout: 1) {
            app.buttons["Cancel"].tap()
        } else {
            app.swipeDown()
        }
        settle()
    }

    private func settle() {
        RunLoop.current.run(until: Date().addingTimeInterval(0.45))
    }
}
