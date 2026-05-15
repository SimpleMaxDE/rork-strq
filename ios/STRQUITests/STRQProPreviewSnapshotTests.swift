import XCTest

@MainActor
final class STRQProPreviewSnapshotTests: XCTestCase {
    private var app: XCUIApplication!
    private let purchaseMarkerPath = "/tmp/strq_d1_purchase_called"
    private let proPreviewCardIdentifier = "strq.profile.subscription"

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
    }

    func testProPreviewSnapshot() throws {
        try runProPreviewSnapshot(
            locale: .english,
            screenshotNames: .englishPreview
        )
    }

    func testGermanProPreviewSnapshot() throws {
        try runProPreviewSnapshot(
            locale: .german,
            screenshotNames: .germanPreview
        )
    }

    func testProPreviewSmallPhoneSnapshot() throws {
        try runSmallPhoneProPreviewSnapshot(
            locale: .english,
            screenshotName: "06-small-iphone-pro-preview-top",
            tapName: "Profile Pro preview card on small iPhone"
        )
    }

    func testGermanProPreviewSmallPhoneSnapshot() throws {
        try runSmallPhoneProPreviewSnapshot(
            locale: .german,
            screenshotName: "14-de-small-iphone-pro-preview-top",
            tapName: "Profile Pro preview card on small iPhone in German"
        )
    }

    func testPackagePreviewShowsLiveMetadataWithoutPurchasing() throws {
        try runPackagePreviewSnapshot(
            locale: .english,
            screenshotName: "07-package-preview-live-metadata",
            tapName: "Profile Pro package preview card"
        )
    }

    func testGermanPackagePreviewShowsLiveMetadataWithoutPurchasing() throws {
        try runPackagePreviewSnapshot(
            locale: .german,
            screenshotName: "15-de-package-preview-live-metadata",
            tapName: "Profile Pro package preview card in German"
        )
    }

    func testPackagePreviewSmallPhoneSnapshot() throws {
        try runPackagePreviewSnapshot(
            locale: .english,
            screenshotName: "08-small-iphone-package-preview-top",
            tapName: "Profile Pro package preview card on small iPhone"
        )
    }

    func testGermanPackagePreviewSmallPhoneSnapshot() throws {
        try runPackagePreviewSnapshot(
            locale: .german,
            screenshotName: "16-de-small-iphone-package-preview-top",
            tapName: "Profile Pro package preview card on small iPhone in German"
        )
    }

    private func runProPreviewSnapshot(locale: SnapshotLocale, screenshotNames: PreviewScreenshotNames) throws {
        try XCTSkipUnless(
            FileManager.default.fileExists(atPath: "/tmp/strq_capture_pro_preview_enabled"),
            "STRQ Pro Preview snapshots are opt-in. Run scripts/qa/capture_strq_pro_preview.sh."
        )

        configureLaunchArguments(locale: locale)
        app.launch()
        openProfile(locale: locale)

        waitFor(proPreviewCard, timeout: 8)
        assertProfileCardCopy(locale: locale)
        snapshot(screenshotNames.profileCard)

        tap(proPreviewCard, named: "Profile Pro preview card in \(locale.slug)")
        waitForLabel(containing: locale.previewTitle, timeout: 8)
        assertTopPreviewCopy(locale: locale)
        assertNoLivePurchaseUI(locale: locale)
        snapshot(screenshotNames.previewTop)

        app.swipeUp()
        settle(0.7)
        assertLowerPreviewCopy(locale: locale)
        assertNoLivePurchaseUI(locale: locale)
        snapshot(screenshotNames.previewLower)

        bringRestoreIntoView()
        assertRestoreFooterCopy(locale: locale)
        assertNoLivePurchaseUI(locale: locale)
        snapshot(screenshotNames.previewFooterRestore)

        tap(app.buttons["strq.pro-preview.close"], named: "Close Pro Preview")
        waitFor(proPreviewCard, timeout: 8)
        snapshot(screenshotNames.profileAfterDismiss)
    }

    private func runSmallPhoneProPreviewSnapshot(locale: SnapshotLocale, screenshotName: String, tapName: String) throws {
        try XCTSkipUnless(
            FileManager.default.fileExists(atPath: "/tmp/strq_capture_pro_preview_enabled"),
            "STRQ Pro Preview snapshots are opt-in. Run scripts/qa/capture_strq_pro_preview.sh."
        )

        configureLaunchArguments(locale: locale)
        app.launch()
        openProfile(locale: locale)
        tap(proPreviewCard, named: tapName)
        waitForLabel(containing: locale.previewTitle, timeout: 8)
        assertTopPreviewCopy(locale: locale)
        assertNoLivePurchaseUI(locale: locale)
        snapshot(screenshotName)
    }

    private func runPackagePreviewSnapshot(locale: SnapshotLocale, screenshotName: String, tapName: String) throws {
        try XCTSkipUnless(
            FileManager.default.fileExists(atPath: "/tmp/strq_capture_pro_preview_enabled"),
            "STRQ Pro Preview snapshots are opt-in. Run scripts/qa/capture_strq_pro_preview.sh."
        )

        try? FileManager.default.removeItem(atPath: purchaseMarkerPath)
        configureLaunchArguments(locale: locale)
        app.launchArguments += ["-STRQSubscriptionFixture", "packagePreview"]
        app.launch()
        openProfile(locale: locale)

        tap(proPreviewCard, named: tapName)
        waitForLabel(containing: locale.yearlyTitle, timeout: 8)
        assertLivePackageMetadata(locale: locale)
        assertPrimaryCTADoesNotPurchase()
        snapshot(screenshotName)
    }

    private var proPreviewCard: XCUIElement {
        app.buttons[proPreviewCardIdentifier]
    }

    private func configureLaunchArguments(locale: SnapshotLocale) {
        app.launchArguments = [
            "-STRQUIFixture", "coreFlow",
            "-AppleLanguages", "(\(locale.languageCode))",
            "-AppleLocale", locale.appleLocale
        ]
    }

    private func openProfile(locale: SnapshotLocale) {
        waitFor(app.buttons["strq.tab.profile"], timeout: 12)
        tap(app.buttons["strq.tab.profile"], named: "Profile tab")
        waitForLabel(containing: locale.profileTitle, timeout: 8)
    }

    private func bringRestoreIntoView() {
        let restoreButton = app.buttons["strq.pro-preview.restore"]
        for _ in 0..<5 where !restoreButton.exists || !restoreButton.isHittable {
            app.swipeUp()
            settle(0.55)
        }
        waitFor(restoreButton, timeout: 4)
    }

    private func assertProfileCardCopy(locale: SnapshotLocale, file: StaticString = #filePath, line: UInt = #line) {
        let joinedLabels = currentLabels().joined(separator: " ")
        for required in locale.profileCardRequiredCopy {
            XCTAssertTrue(
                joinedLabels.localizedCaseInsensitiveContains(required),
                "Expected Profile Pro card copy to contain '\(required)'. Current labels: \(joinedLabels)",
                file: file,
                line: line
            )
        }
    }

    private func assertTopPreviewCopy(locale: SnapshotLocale, file: StaticString = #filePath, line: UInt = #line) {
        let joinedLabels = currentLabels().joined(separator: " ")
        for required in locale.topPreviewRequiredCopy {
            XCTAssertTrue(
                joinedLabels.localizedCaseInsensitiveContains(required),
                "Expected Pro Preview copy to contain '\(required)'. Current labels: \(joinedLabels)",
                file: file,
                line: line
            )
        }
    }

    private func assertLowerPreviewCopy(locale: SnapshotLocale, file: StaticString = #filePath, line: UInt = #line) {
        let joinedLabels = currentLabels().joined(separator: " ")
        let visible = locale.lowerPreviewRequiredCopy.contains { required in
            joinedLabels.localizedCaseInsensitiveContains(required)
        }
        XCTAssertTrue(
            visible,
            "Expected lower Pro Preview copy to contain one of '\(locale.lowerPreviewRequiredCopy.joined(separator: "', '"))'. Current labels: \(joinedLabels)",
            file: file,
            line: line
        )
    }

    private func assertRestoreFooterCopy(locale: SnapshotLocale, file: StaticString = #filePath, line: UInt = #line) {
        let joinedLabels = currentLabels().joined(separator: " ")
        XCTAssertTrue(
            joinedLabels.localizedCaseInsensitiveContains(locale.restorePurchasesTitle),
            "Expected restore/footer copy to contain '\(locale.restorePurchasesTitle)'. Current labels: \(joinedLabels)",
            file: file,
            line: line
        )
    }

    private func assertNoLivePurchaseUI(locale: SnapshotLocale, file: StaticString = #filePath, line: UInt = #line) {
        let joinedLabels = currentLabels().joined(separator: " ").lowercased()

        for term in locale.previewForbiddenLivePurchaseTerms {
            XCTAssertFalse(
                joinedLabels.contains(term),
                "Unexpected live purchase UI term '\(term)' found. Current labels: \(joinedLabels)",
                file: file,
                line: line
            )
        }
    }

    private func assertLivePackageMetadata(locale: SnapshotLocale, file: StaticString = #filePath, line: UInt = #line) {
        let joinedLabels = currentLabels().joined(separator: " ")
        for required in locale.packageRequiredCopy {
            XCTAssertTrue(
                joinedLabels.localizedCaseInsensitiveContains(required),
                "Expected package preview to contain '\(required)'. Current labels: \(joinedLabels)",
                file: file,
                line: line
            )
        }

        for forbidden in locale.packageForbiddenActiveCTAs {
            XCTAssertFalse(
                joinedLabels.localizedCaseInsensitiveContains(forbidden),
                "Unexpected active purchase CTA '\(forbidden)' found. Current labels: \(joinedLabels)",
                file: file,
                line: line
            )
        }
    }

    private func assertPrimaryCTADoesNotPurchase(file: StaticString = #filePath, line: UInt = #line) {
        let cta = app.buttons["strq.pro-preview.purchase-disabled"]
        waitFor(cta, timeout: 4)
        XCTAssertFalse(cta.isEnabled, "D1 primary CTA must remain disabled/internal.", file: file, line: line)

        cta.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        settle(0.8)

        XCTAssertFalse(
            FileManager.default.fileExists(atPath: purchaseMarkerPath),
            "Tapping the D1 primary CTA called StoreViewModel.purchase(package:).",
            file: file,
            line: line
        )
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

private struct PreviewScreenshotNames {
    let profileCard: String
    let previewTop: String
    let previewLower: String
    let previewFooterRestore: String
    let profileAfterDismiss: String

    static let englishPreview = PreviewScreenshotNames(
        profileCard: "01-profile-pro-card",
        previewTop: "02-pro-preview-top",
        previewLower: "03-pro-preview-lower",
        previewFooterRestore: "04-pro-preview-footer-restore",
        profileAfterDismiss: "05-profile-after-dismiss"
    )

    static let germanPreview = PreviewScreenshotNames(
        profileCard: "09-de-profile-pro-card",
        previewTop: "10-de-pro-preview-top",
        previewLower: "11-de-pro-preview-lower",
        previewFooterRestore: "12-de-pro-preview-footer-restore",
        profileAfterDismiss: "13-de-profile-after-dismiss"
    )
}

private enum SnapshotLocale {
    case english
    case german

    var slug: String {
        switch self {
        case .english: "English"
        case .german: "German"
        }
    }

    var languageCode: String {
        switch self {
        case .english: "en"
        case .german: "de"
        }
    }

    var appleLocale: String {
        switch self {
        case .english: "en_US"
        case .german: "de_DE"
        }
    }

    var profileTitle: String {
        switch self {
        case .english: "Profile"
        case .german: "Profil"
        }
    }

    var previewTitle: String {
        switch self {
        case .english: "STRQ PRO PREVIEW"
        case .german: "STRQ PRO VORSCHAU"
        }
    }

    var yearlyTitle: String {
        switch self {
        case .english: "Yearly"
        case .german: "Jährlich"
        }
    }

    var restorePurchasesTitle: String {
        switch self {
        case .english: "Restore Purchases"
        case .german: "Käufe wiederherstellen"
        }
    }

    var profileCardRequiredCopy: [String] {
        switch self {
        case .english:
            ["STRQ Pro", "Deeper coaching"]
        case .german:
            ["STRQ Pro", "Tieferes Coaching"]
        }
    }

    var topPreviewRequiredCopy: [String] {
        switch self {
        case .english:
            ["No purchase is available in this build.", "Training Map evidence"]
        case .german:
            ["In diesem Build ist kein Kauf verfügbar.", "Training Map-Hinweise"]
        }
    }

    var lowerPreviewRequiredCopy: [String] {
        switch self {
        case .english:
            ["Free activation", "Adaptive plan evolution", "Weekly coach review"]
        case .german:
            ["Kostenloser Start", "Adaptive Planentwicklung", "Coach-Wochenrückblick"]
        }
    }

    var previewForbiddenLivePurchaseTerms: [String] {
        switch self {
        case .english:
            ["subscribe", "start free trial", "limited time", "discount", "monthly", "annual", "$"]
        case .german:
            ["abonnieren", "testversion starten", "nur für kurze zeit", "rabatt", "monatlich", "jährlich", "$", "€"]
        }
    }

    var packageRequiredCopy: [String] {
        switch self {
        case .english:
            [
                "Yearly",
                "Monthly",
                "$59.99/year",
                "$8.99/month",
                "$5.00/mo",
                "7 days free trial",
                "Restore Purchases",
                "Terms",
                "Privacy",
                "Payment is charged to your Apple ID",
                "Manage or cancel in App Store settings",
                "Purchases not enabled in this build",
                "Free activation",
                "First plan free",
                "First workout free",
                "Basic Progress free"
            ]
        case .german:
            [
                "Jährlich",
                "Monatlich",
                "$59.99/Jahr",
                "$8.99/Monat",
                "$5.00/Mon.",
                "7 Tage kostenlos testen",
                "Käufe wiederherstellen",
                "Nutzungsbedingungen",
                "Datenschutz",
                "Die Zahlung wird bei Bestätigung deiner Apple ID belastet",
                "Verwalten oder kündigen kannst du in den App Store-Einstellungen",
                "Käufe sind in diesem Build nicht aktiviert",
                "Kostenloser Start",
                "Erster Plan kostenlos",
                "Erstes Workout kostenlos",
                "Basis-Fortschritt kostenlos"
            ]
        }
    }

    var packageForbiddenActiveCTAs: [String] {
        switch self {
        case .english:
            ["Subscribe", "Start Trial", "Start Free Trial", "Continue with STRQ Pro"]
        case .german:
            ["Abonnieren", "Testversion starten", "Mit STRQ Pro fortfahren"]
        }
    }
}
