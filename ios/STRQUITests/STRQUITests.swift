//
//  STRQUITests.swift
//  STRQUITests
//
//  Created by Rork on April 13, 2026.
//

import XCTest

final class STRQUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it's important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    @MainActor
    func testExample() throws {
        throw XCTSkip("Placeholder UI test. Use STRQCoreFlowSnapshotTests for flow snapshots.")
    }

    @MainActor
    func testLaunchPerformance() throws {
        try XCTSkipUnless(
            ProcessInfo.processInfo.environment["STRQ_RUN_UI_PERFORMANCE_TEST"] == "1",
            "Launch performance UI test is opt-in."
        )

        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
