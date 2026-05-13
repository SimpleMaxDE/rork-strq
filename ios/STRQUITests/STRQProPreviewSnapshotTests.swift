import XCTest

@MainActor
final class STRQProPreviewSnapshotTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        configureLaunchArguments()
    }

    func testProPreviewSnapshot() throws {
        try XCTSkipUnless(
            FileManager.default.fileExists(atPath: "/tmp/strq_capture_pro_preview_enabled"),
            "STRQ Pro Preview snapshots are opt-in. Run scripts/qa/capture_strq_pro_preview.sh."
        )

        app.launch()
        openProfile()

        waitFor(app.buttons["strq.profile.pro-preview-card"], timeout: 8)
        snapshot("01-profile-pro-card")

        tap(app.buttons["strq.profile.pro-preview-card"], named: "Profile Pro preview card")
        waitForLabel(containing: "STRQ PRO PREVIEW", timeout: 8)
        assertTopPreviewCopy()
        assertNoLivePurchaseUI()
        snapshot("02-pro-preview-top")

        app.swipeUp()
        settle(0.7)
        assertNoLivePurchaseUI()
        snapshot("03-pro-preview-lower")

        bringRestoreIntoView()
        assertNoLivePurchaseUI()
        snapshot("04-pro-preview-footer-restore")

        tap(app.buttons["strq.pro-preview.close"], named: "Close Pro Preview")
        waitFor(app.buttons["strq.profile.pro-preview-card"], timeout: 8)
        snapshot("05-profile-after-dismiss")
    }

    func testProPreviewSmallPhoneSnapshot() throws {
        try XCTSkipUnless(
            FileManager.default.fileExists(atPath: "/tmp/strq_capture_pro_preview_enabled"),
            "STRQ Pro Preview snapshots are opt-in. Run scripts/qa/capture_strq_pro_preview.sh."
        )

        app.launch()
        openProfile()
        tap(app.buttons["strq.profile.pro-preview-card"], named: "Profile Pro preview card on small iPhone")
        waitForLabel(containing: "STRQ PRO PREVIEW", timeout: 8)
        assertTopPreviewCopy()
        assertNoLivePurchaseUI()
        snapshot("06-small-iphone-pro-preview-top")
    }

    private func configureLaunchArguments() {
        app.launchArguments = [
            "-STRQUIFixture", "coreFlow",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US"
        ]
    }

    private func openProfile() {
        waitFor(app.buttons["strq.tab.profile"], timeout: 12)
        tap(app.buttons["strq.tab.profile"], named: "Profile tab")
        waitForLabel(containing: "Profile", timeout: 8)
    }

    private func bringRestoreIntoView() {
        let restoreButton = app.buttons["strq.pro-preview.restore"]
        for _ in 0..<5 where !restoreButton.exists || !restoreButton.isHittable {
            app.swipeUp()
            settle(0.55)
        }
        waitFor(restoreButton, timeout: 4)
    }

    private func assertTopPreviewCopy(file: StaticString = #filePath, line: UInt = #line) {
        let joinedLabels = currentLabels().joined(separator: " ")
        for required in [
            "No purchase is available in this build.",
            "Training Map evidence"
        ] {
            XCTAssertTrue(
                joinedLabels.localizedCaseInsensitiveContains(required),
                "Expected Pro Preview copy to contain '\(required)'. Current labels: \(joinedLabels)",
                file: file,
                line: line
            )
        }
    }

    private func assertNoLivePurchaseUI(file: StaticString = #filePath, line: UInt = #line) {
        let joinedLabels = currentLabels().joined(separator: " ").lowercased()
        let forbiddenTerms = [
            "subscribe",
            "start free trial",
            "limited time",
            "discount",
            "monthly",
            "annual",
            "$"
        ]

        for term in forbiddenTerms {
            XCTAssertFalse(
                joinedLabels.contains(term),
                "Unexpected live purchase UI term '\(term)' found. Current labels: \(joinedLabels)",
                file: file,
                line: line
            )
        }
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

    private func waitForLabel(containing text: String, timeout: TimeInterval, file: StaticString = #filePath, line: UInt = #line) {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if currentLabels().contains(where: { $0.localizedCaseInsensitiveContains(text) }) { return }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        XCTFail("Timed out waiting for visible text containing '\(text)'. Current labels: \(currentLabels().joined(separator: " | "))", file: file, line: line)
    }

    private func currentLabels() -> [String] {
        let elements = app.staticTexts.allElementsBoundByIndex
            + app.buttons.allElementsBoundByIndex
            + app.textFields.allElementsBoundByIndex
            + app.secureTextFields.allElementsBoundByIndex
        return elements
            .map(\.label)
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }

    private func settle(_ seconds: TimeInterval = 0.45) {
        RunLoop.current.run(until: Date().addingTimeInterval(seconds))
    }
}
