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

    func testOnboardingFlowSnapshot() throws {
        try XCTSkipUnless(
            FileManager.default.fileExists(atPath: "/tmp/strq_capture_onboarding_v2_enabled"),
            "Onboarding snapshots are opt-in. Run scripts/qa/capture_strq_onboarding_v2.sh."
        )

        configureOnboardingLaunchArguments()
        app.launch()
        waitFor(primaryCTA, timeout: 12)
        waitForLabel(containing: "STRQ", timeout: 8)
        settle(1.1)
        onboardingSnapshot("00-welcome")

        tapPrimary(named: "Get Started")
        waitForLabel(containing: "What should we call you?", timeout: 8)
        waitFor(app.textFields["strq.onboarding.name"], timeout: 8)
        assertCurrentLabelsContain(["Age", "Gender"])
        XCTAssertFalse(primaryCTA.isEnabled, "Name-only validation should keep the primary CTA disabled while the name is empty.")
        onboardingSnapshot("01-about-name-empty-or-validation")

        typeName("Max")
        XCTAssertTrue(primaryCTA.isEnabled, "Name-only validation should enable the primary CTA after a non-empty name.")
        onboardingSnapshot("02-about-name-filled")

        submitNameField()
        waitForLabel(containing: "Your body metrics", timeout: 8)
        assertCurrentLabelsContain(["Height", "Weight", "Target weight", "Body fat"])

        tapPrimary(named: "Continue from body")
        waitForLabel(containing: "What's your goal?", timeout: 8)
        assertCurrentLabelsContain(["Build Muscle", "Get Stronger", "Lose Fat", "General Fitness"])
        onboardingSnapshot("03-goal")

        tapPrimary(named: "Continue from goal")
        waitForLabel(containing: "How you train", timeout: 8)
        assertCurrentLabelsContain(["Experience level", "Training days / week", "Workout length", "Preferred split"])
        onboardingSnapshot("04-training")
        scrollDownForOnboardingQA()
        assertCurrentLabelsContain(["Workout length", "Preferred split"])
        onboardingSnapshot("04-training-lower")

        tapPrimary(named: "Continue from training")
        waitForLabel(containing: "Your training setup", timeout: 8)
        assertCurrentLabelsContain(["Where do you train?", "Full Gym", "Home Gym"])
        tapHomeGymIfNeeded()
        assertCurrentLabelsContain(["Available equipment", "Injuries or restrictions"])
        onboardingSnapshot("05-setup-equipment")
        scrollDownForOnboardingQA()
        assertCurrentLabelsContain(["Injuries or restrictions"])
        onboardingSnapshot("05-setup-equipment-lower")

        tapPrimary(named: "Continue from setup")
        waitForLabel(containing: "Muscle focus", timeout: 8)
        settle(2.5)
        onboardingSnapshot("06-focus")

        tapPrimary(named: "Continue from focus")
        waitForLabel(containing: "Lifestyle & recovery", timeout: 8)
        assertCurrentLabelsContain(["Sleep", "Stress", "Activity", "Recovery"])
        onboardingSnapshot("07-lifestyle-final-cta")
        scrollDownForOnboardingQA()
        assertCurrentLabelsContain(["Activity", "Recovery"])
        onboardingSnapshot("07-lifestyle-final-cta-lower")

        tapPrimary(named: "See My Plan")
        waitForLabel(containing: "Building Your Plan", timeout: 4)
        settle(0.25)
        onboardingSnapshot("08-generation")

        waitForLabel(containing: "Your Plan is Ready", timeout: 16)
        settle(0.8)
        onboardingSnapshot("09-reveal")
    }

    func testOnboardingSmallPhoneSnapshot() throws {
        try XCTSkipUnless(
            FileManager.default.fileExists(atPath: "/tmp/strq_capture_onboarding_v2_enabled"),
            "Onboarding snapshots are opt-in. Run scripts/qa/capture_strq_onboarding_v2.sh."
        )

        configureOnboardingLaunchArguments()
        app.launch()
        waitFor(primaryCTA, timeout: 12)
        waitForLabel(containing: "STRQ", timeout: 8)
        settle(1.1)
        onboardingSnapshot("10-small-iphone-welcome")

        tapPrimary(named: "Get Started on small iPhone")
        waitFor(app.textFields["strq.onboarding.name"], timeout: 8)
        typeName("Max")
        submitNameField()
        waitForLabel(containing: "Your body metrics", timeout: 8)
        tapPrimary(named: "Continue from body on small iPhone")
        waitForLabel(containing: "What's your goal?", timeout: 8)
        tapPrimary(named: "Continue from goal on small iPhone")
        waitForLabel(containing: "How you train", timeout: 8)
        assertCurrentLabelsContain(["Experience level", "Training days / week", "Workout length"])
        scrollDownForOnboardingQA()
        assertCurrentLabelsContain(["Training days / week", "Workout length"])
        onboardingSnapshot("11-small-iphone-dense-step")
    }

    func testOnboardingMatrixSnapshot() throws {
        try XCTSkipUnless(
            FileManager.default.fileExists(atPath: "/tmp/strq_capture_onboarding_v2_enabled"),
            "Onboarding snapshots are opt-in. Run scripts/qa/capture_strq_onboarding_v2.sh."
        )

        captureAboutMetricSheetFromFreshLaunch("strq.onboarding.metric.age", screenshotName: "matrix-about-age-sheet")
        captureBodyMetricSheetFromFreshLaunch("strq.onboarding.metric.height", screenshotName: "matrix-body-metric-height-sheet")
        captureBodyMetricSheetFromFreshLaunch("strq.onboarding.metric.weight", screenshotName: "matrix-body-metric-weight-sheet")
        captureBodyMetricSheetFromFreshLaunch("strq.onboarding.metric.targetWeight", screenshotName: "matrix-body-metric-target-weight-sheet")
        captureBodyMetricSheetFromFreshLaunch("strq.onboarding.metric.bodyFat", screenshotName: "matrix-body-metric-body-fat-sheet")

        relaunchOnboarding()
        tapPrimary(named: "Matrix get started")
        waitFor(app.textFields["strq.onboarding.name"], timeout: 8)
        fillOnboardingName()
        captureOptions(
            [
                "strq.onboarding.gender.male",
                "strq.onboarding.gender.female",
                "strq.onboarding.gender.other",
                "strq.onboarding.gender.prefernottosay"
            ],
            screenshotPrefix: "matrix-about-gender"
        )

        tapPrimary(named: "Matrix continue to body")
        waitForLabel(containing: "Your body metrics", timeout: 8)

        tapPrimary(named: "Matrix continue to goal")
        waitForLabel(containing: "What's your goal?", timeout: 8)
        captureOptions(
            [
                "strq.onboarding.goal.musclegain",
                "strq.onboarding.goal.strength",
                "strq.onboarding.goal.fatloss",
                "strq.onboarding.goal.generalfitness",
                "strq.onboarding.goal.endurance",
                "strq.onboarding.goal.flexibility",
                "strq.onboarding.goal.athleticperformance",
                "strq.onboarding.goal.rehabilitation"
            ],
            screenshotPrefix: "matrix-goal"
        )

        tapPrimary(named: "Matrix continue to training")
        waitForLabel(containing: "How you train", timeout: 8)
        captureOptions(
            [
                "strq.onboarding.trainingLevel.beginner",
                "strq.onboarding.trainingLevel.intermediate",
                "strq.onboarding.trainingLevel.advanced"
            ],
            screenshotPrefix: "matrix-training-level"
        )
        captureOptions(
            (1...6).map { "strq.onboarding.days.\($0)" },
            screenshotPrefix: "matrix-training-days"
        )
        scrollDownForOnboardingQA()
        captureOptions(
            [30, 45, 60, 75, 90, 120].map { "strq.onboarding.minutes.\($0)" },
            screenshotPrefix: "matrix-training-minutes"
        )
        captureOptions(
            [
                "strq.onboarding.split.automatic",
                "strq.onboarding.split.fullbody",
                "strq.onboarding.split.upperlower",
                "strq.onboarding.split.pushpulllegs",
                "strq.onboarding.split.bodypart",
                "strq.onboarding.split.musclegroup"
            ],
            screenshotPrefix: "matrix-training-split"
        )

        tapPrimary(named: "Matrix continue to setup")
        waitForLabel(containing: "Your training setup", timeout: 8)
        captureOptions(
            [
                "strq.onboarding.location.gym",
                "strq.onboarding.location.homegym",
                "strq.onboarding.location.homenoequipment"
            ],
            screenshotPrefix: "matrix-setup-location"
        )
        tapOnboardingControl("strq.onboarding.location.homegym", named: "Matrix home gym for equipment")
        captureOptions(
            [
                "strq.onboarding.equipment.dumbbell",
                "strq.onboarding.equipment.kettlebell",
                "strq.onboarding.equipment.resistanceband",
                "strq.onboarding.equipment.pullupbar",
                "strq.onboarding.equipment.bench",
                "strq.onboarding.equipment.stabilityball",
                "strq.onboarding.equipment.foamroller",
                "strq.onboarding.equipment.mat",
                "strq.onboarding.equipment.trx",
                "strq.onboarding.equipment.rings",
                "strq.onboarding.equipment.abwheel"
            ],
            screenshotPrefix: "matrix-setup-equipment",
            scrollBeforeMissing: true
        )
        captureOptions(
            [
                "strq.onboarding.injury.shoulder",
                "strq.onboarding.injury.knee",
                "strq.onboarding.injury.lower-back",
                "strq.onboarding.injury.wrist",
                "strq.onboarding.injury.neck",
                "strq.onboarding.injury.hip",
                "strq.onboarding.injury.ankle",
                "strq.onboarding.injury.elbow"
            ],
            screenshotPrefix: "matrix-setup-injury",
            scrollBeforeMissing: true
        )

        tapPrimary(named: "Matrix continue to focus")
        waitForLabel(containing: "Muscle focus", timeout: 8)
        settle(2.5)
        onboardingSnapshot("matrix-focus-default")

        tapPrimary(named: "Matrix continue to lifestyle")
        waitForLabel(containing: "Lifestyle & recovery", timeout: 8)
        captureOptions(
            [
                "strq.onboarding.sleep.poor",
                "strq.onboarding.sleep.fair",
                "strq.onboarding.sleep.good",
                "strq.onboarding.sleep.excellent"
            ],
            screenshotPrefix: "matrix-lifestyle-sleep"
        )
        captureOptions(
            [
                "strq.onboarding.stress.low",
                "strq.onboarding.stress.moderate",
                "strq.onboarding.stress.high",
                "strq.onboarding.stress.veryhigh"
            ],
            screenshotPrefix: "matrix-lifestyle-stress",
            scrollBeforeMissing: true
        )
        captureOptions(
            [
                "strq.onboarding.activity.sedentary",
                "strq.onboarding.activity.lightlyactive",
                "strq.onboarding.activity.moderatelyactive",
                "strq.onboarding.activity.veryactive",
                "strq.onboarding.activity.extremelyactive"
            ],
            screenshotPrefix: "matrix-lifestyle-activity",
            scrollBeforeMissing: true
        )
        captureOptions(
            [
                "strq.onboarding.recovery.low",
                "strq.onboarding.recovery.moderate",
                "strq.onboarding.recovery.high"
            ],
            screenshotPrefix: "matrix-lifestyle-recovery",
            scrollBeforeMissing: true
        )
    }

    private func relaunchFixture() {
        app.terminate()
        app = XCUIApplication()
        configureLaunchArguments()
        app.launch()
        waitForAny([app.buttons["strq.today.start-workout"], app.staticTexts["Today"]], timeout: 12)
    }

    private var primaryCTA: XCUIElement {
        app.buttons["strq.onboarding.primary"]
    }

    private func configureLaunchArguments() {
        app.launchArguments = [
            "-STRQUIFixture", "coreFlow",
            "-AppleLanguages", "(en)",
            "-AppleLocale", "en_US"
        ]
    }

    private func configureOnboardingLaunchArguments() {
        app.launchArguments = [
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

    private func onboardingSnapshot(_ name: String) {
        assertNoForbiddenPaywallCopy()
        snapshot(name)
    }

    private func tapPrimary(named name: String) {
        tap(primaryCTA, named: name)
    }

    private func typeName(_ name: String) {
        let nameField = app.textFields["strq.onboarding.name"]
        waitFor(nameField, timeout: 8)
        nameField.tap()
        nameField.typeText(name)
        settle()
    }

    private func submitNameField() {
        let nameField = app.textFields["strq.onboarding.name"]
        waitFor(nameField, timeout: 8)
        nameField.typeText(XCUIKeyboardKey.return.rawValue)
        settle()
    }

    private func tapHomeGymIfNeeded() {
        if labelExists(containing: "Available equipment") { return }

        let directButton = app.buttons["Home Gym"]
        if directButton.waitForExistence(timeout: 1) {
            tap(directButton, named: "Home Gym")
        } else {
            let nestedButton = app.buttons.containing(.staticText, identifier: "Home Gym").firstMatch
            tap(nestedButton, named: "Home Gym")
        }
        waitForLabel(containing: "Available equipment", timeout: 4)
    }

    private func relaunchOnboarding() {
        app.terminate()
        app = XCUIApplication()
        configureOnboardingLaunchArguments()
        app.launch()
        waitFor(primaryCTA, timeout: 12)
        waitForLabel(containing: "STRQ", timeout: 8)
    }

    private func fillOnboardingName() {
        if !primaryCTA.isEnabled {
            typeName("Max")
        }
        dismissKeyboardForOnboarding()
    }

    private func captureAboutMetricSheetFromFreshLaunch(_ identifier: String, screenshotName: String) {
        relaunchOnboarding()
        tapPrimary(named: "Metric sheet about launch")
        waitFor(app.textFields["strq.onboarding.name"], timeout: 8)
        fillOnboardingName()
        tapOnboardingControl(identifier, named: screenshotName)
        settle(0.4)
        onboardingSnapshot(screenshotName)
        app.terminate()
    }

    private func captureBodyMetricSheetFromFreshLaunch(_ identifier: String, screenshotName: String) {
        relaunchOnboarding()
        tapPrimary(named: "Metric sheet body launch")
        waitFor(app.textFields["strq.onboarding.name"], timeout: 8)
        fillOnboardingName()
        tapPrimary(named: "Metric sheet continue to body")
        waitForLabel(containing: "Your body metrics", timeout: 8)
        tapOnboardingControl(identifier, named: screenshotName)
        settle(0.4)
        onboardingSnapshot(screenshotName)
        app.terminate()
    }

    private func captureMetricSheet(_ identifier: String, screenshotName: String) {
        tapOnboardingControl(identifier, named: screenshotName)
        settle(0.4)
        onboardingSnapshot(screenshotName)
        dismissCurrentSheet()
        settle(0.4)
    }

    private func captureOptions(
        _ identifiers: [String],
        screenshotPrefix: String,
        scrollBeforeMissing: Bool = true
    ) {
        for identifier in identifiers {
            let suffix = identifier.components(separatedBy: ".").last ?? identifier
            tapOnboardingControl(identifier, named: suffix, scrollBeforeMissing: scrollBeforeMissing)
            onboardingSnapshot("\(screenshotPrefix)-\(suffix)")
        }
    }

    private func tapOnboardingControl(
        _ identifier: String,
        named name: String,
        scrollBeforeMissing: Bool = true,
        timeout: TimeInterval = 4
    ) {
        var element = app.buttons[identifier]
        if !element.waitForExistence(timeout: 0.7), let fallback = fallbackButton(for: identifier) {
            element = fallback
        }
        if (!element.exists || !element.isHittable), scrollBeforeMissing {
            bringOnboardingControlIntoView(element)
        }
        tap(element, named: name, timeout: timeout)
    }

    private func fallbackButton(for identifier: String) -> XCUIElement? {
        guard let label = fallbackLabel(for: identifier) else { return nil }
        let direct = app.buttons[label]
        if direct.exists { return direct }
        let nested = app.buttons.containing(.staticText, identifier: label).firstMatch
        return nested
    }

    private func fallbackLabel(for identifier: String) -> String? {
        [
            "strq.onboarding.gender.male": "Male",
            "strq.onboarding.gender.female": "Female",
            "strq.onboarding.gender.other": "Other",
            "strq.onboarding.gender.prefernottosay": "Prefer not to say",
            "strq.onboarding.goal.musclegain": "Build Muscle",
            "strq.onboarding.goal.strength": "Get Stronger",
            "strq.onboarding.goal.fatloss": "Lose Fat",
            "strq.onboarding.goal.generalfitness": "General Fitness",
            "strq.onboarding.goal.endurance": "Endurance",
            "strq.onboarding.goal.flexibility": "Flexibility",
            "strq.onboarding.goal.athleticperformance": "Athletic Performance",
            "strq.onboarding.goal.rehabilitation": "Rehabilitation",
            "strq.onboarding.trainingLevel.beginner": "Beginner",
            "strq.onboarding.trainingLevel.intermediate": "Intermediate",
            "strq.onboarding.trainingLevel.advanced": "Advanced",
            "strq.onboarding.split.automatic": "Let AI Decide",
            "strq.onboarding.split.fullbody": "Full Body",
            "strq.onboarding.split.upperlower": "Upper / Lower",
            "strq.onboarding.split.pushpulllegs": "Push / Pull / Legs",
            "strq.onboarding.split.bodypart": "Body Part Split",
            "strq.onboarding.split.musclegroup": "Muscle Group",
            "strq.onboarding.location.gym": "Full Gym",
            "strq.onboarding.location.homegym": "Home Gym",
            "strq.onboarding.location.homenoequipment": "Home (No Equipment)",
            "strq.onboarding.equipment.dumbbell": "Dumbbell",
            "strq.onboarding.equipment.kettlebell": "Kettlebell",
            "strq.onboarding.equipment.resistanceband": "Resistance Band",
            "strq.onboarding.equipment.pullupbar": "Pull-Up Bar",
            "strq.onboarding.equipment.bench": "Bench",
            "strq.onboarding.equipment.stabilityball": "Stability Ball",
            "strq.onboarding.equipment.foamroller": "Foam Roller",
            "strq.onboarding.equipment.mat": "Mat",
            "strq.onboarding.equipment.trx": "TRX",
            "strq.onboarding.equipment.rings": "Rings",
            "strq.onboarding.equipment.abwheel": "Ab Wheel",
            "strq.onboarding.injury.shoulder": "Shoulder",
            "strq.onboarding.injury.knee": "Knee",
            "strq.onboarding.injury.lower-back": "Lower Back",
            "strq.onboarding.injury.wrist": "Wrist",
            "strq.onboarding.injury.neck": "Neck",
            "strq.onboarding.injury.hip": "Hip",
            "strq.onboarding.injury.ankle": "Ankle",
            "strq.onboarding.injury.elbow": "Elbow",
            "strq.onboarding.sleep.poor": "Poor (< 5h)",
            "strq.onboarding.sleep.fair": "Fair (5-6h)",
            "strq.onboarding.sleep.good": "Good (7-8h)",
            "strq.onboarding.sleep.excellent": "Excellent (8+h)",
            "strq.onboarding.stress.low": "Low",
            "strq.onboarding.stress.moderate": "Moderate",
            "strq.onboarding.stress.high": "High",
            "strq.onboarding.stress.veryhigh": "Very High",
            "strq.onboarding.activity.sedentary": "Sedentary",
            "strq.onboarding.activity.lightlyactive": "Lightly Active",
            "strq.onboarding.activity.moderatelyactive": "Moderately Active",
            "strq.onboarding.activity.veryactive": "Very Active",
            "strq.onboarding.activity.extremelyactive": "Extremely Active",
            "strq.onboarding.recovery.low": "Low",
            "strq.onboarding.recovery.moderate": "Moderate",
            "strq.onboarding.recovery.high": "High"
        ][identifier]
    }

    private func bringOnboardingControlIntoView(_ element: XCUIElement, attempts: Int = 6) {
        for _ in 0..<attempts where !element.exists || !element.isHittable {
            app.swipeUp()
            settle(0.35)
        }
    }

    private func dismissKeyboardForOnboarding() {
        if app.keyboards.firstMatch.waitForExistence(timeout: 0.5) {
            app.swipeUp()
            settle(0.6)
        }
    }

    private func scrollDownForOnboardingQA() {
        app.swipeUp()
        settle(0.65)
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

    private func waitForLabel(containing text: String, timeout: TimeInterval, file: StaticString = #filePath, line: UInt = #line) {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if labelExists(containing: text) { return }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        XCTFail("Timed out waiting for visible text containing '\(text)'. Current labels: \(currentLabels().joined(separator: " | "))", file: file, line: line)
    }

    private func assertCurrentLabelsContain(_ texts: [String], file: StaticString = #filePath, line: UInt = #line) {
        for text in texts {
            XCTAssertTrue(labelExists(containing: text), "Expected current screen to contain '\(text)'. Current labels: \(currentLabels().joined(separator: " | "))", file: file, line: line)
        }
    }

    private func assertNoForbiddenPaywallCopy(file: StaticString = #filePath, line: UInt = #line) {
        let joinedLabels = currentLabels().joined(separator: " ").lowercased()
        let forbiddenTerms = [
            "subscribe",
            "subscription",
            "pricing",
            "paywall",
            "locked premium",
            "premium feature",
            "unlock premium",
            "revenuecat",
            "$"
        ]

        for term in forbiddenTerms {
            XCTAssertFalse(joinedLabels.contains(term), "Unexpected paywall/pricing copy found for term '\(term)'. Current labels: \(joinedLabels)", file: file, line: line)
        }
    }

    private func labelExists(containing text: String) -> Bool {
        currentLabels().contains { label in
            label.localizedCaseInsensitiveContains(text)
        }
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
        } else if app.buttons["Save"].waitForExistence(timeout: 1) {
            app.buttons["Save"].tap()
        } else {
            dragDownFromTop()
        }
        settle()
    }

    private func dragDownFromTop() {
        let start = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.18))
        let end = app.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.88))
        start.press(forDuration: 0.1, thenDragTo: end)
    }

    private func settle(_ seconds: TimeInterval = 0.45) {
        RunLoop.current.run(until: Date().addingTimeInterval(seconds))
    }
}
