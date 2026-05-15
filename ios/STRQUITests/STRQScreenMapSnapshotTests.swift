import XCTest

@MainActor
final class STRQScreenMapSnapshotTests: XCTestCase {
    private let controlFile = "/tmp/strq_capture_screen_map_enabled"
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app?.terminate()
        app = nil
    }

    func testEnglishScreenMap() throws {
        try runScreenMap(locale: .english)
    }

    func testGermanScreenMap() throws {
        try runScreenMap(locale: .german)
    }

    private func runScreenMap(locale: ScreenMapLocale) throws {
        try XCTSkipUnless(
            FileManager.default.fileExists(atPath: controlFile),
            "Screen Map snapshots are opt-in. Run scripts/qa/capture_strq_screen_map.sh."
        )

        launch(locale: locale)
        let mapper = STRQScreenMapExporter(app: app, testCase: self, locale: locale)

        mapper.waitForAny([.id("strq.tab.today"), .label("Today"), .label("Heute")], timeout: 14, requiredName: "main tab shell")
        mapper.captureScrollableScreen("today", maxScrolls: 1)

        mapper.tap(id: "strq.tab.coach", name: "Coach tab")
        mapper.captureScrollableScreen("coach", maxScrolls: 1)

        mapper.tap(id: "strq.tab.train", name: "Train tab")
        mapper.captureScrollableScreen("train", maxScrolls: 1)
        mapper.scrollToTop()
        captureTrainMenuAndExerciseLibrary(mapper)

        relaunch(locale: locale)
        mapper.update(app: app)
        mapper.waitForAny([.id("strq.tab.progress"), .label("Progress")], timeout: 12, requiredName: "main tab shell after Train")
        mapper.tap(id: "strq.tab.progress", name: "Progress tab")
        mapper.captureScrollableScreen("progress", maxScrolls: 1)

        mapper.tap(id: "strq.tab.profile", name: "Profile tab")
        mapper.captureScrollableScreen("profile", maxScrolls: 2)
        mapper.scrollToTop()
        captureProPreview(mapper)

        mapper.attachManifest()
    }

    private func captureTrainMenuAndExerciseLibrary(_ mapper: STRQScreenMapExporter) {
        guard mapper.tap(id: "strq.train.menu", name: "Train options menu", optional: true) else {
            mapper.recordWarning("Train options menu was not hittable.")
            return
        }

        mapper.captureScreen("train-options-menu")

        let openedLibrary = mapper.tap(
            id: "strq.train.menu.exercise-library",
            labelFallbacks: ["Exercise Library", "Uebungsbibliothek", "Bibliothek"],
            name: "Exercise Library menu item",
            optional: true
        )

        guard openedLibrary else {
            mapper.recordWarning("Exercise Library menu item was not available after opening the Train menu.")
            return
        }

        mapper.waitForAny([.id("strq.exercise-library.search"), .label("Exercise Library")], timeout: 8, requiredName: "Exercise Library")
        mapper.captureScrollableScreen("exercise-library", maxScrolls: 1)
        mapper.scrollToTop()

        if mapper.tap(id: "strq.exercise-library.search", name: "Exercise Library search", optional: true) {
            mapper.typeText("squat")
            mapper.settle(0.7)
            mapper.captureScrollableScreen("exercise-library-search-squat", maxScrolls: 1)
        } else {
            mapper.recordWarning("Exercise Library search field was not hittable.")
        }
    }

    private func captureProPreview(_ mapper: STRQScreenMapExporter) {
        guard mapper.tap(id: "strq.profile.subscription", name: "STRQ Pro Preview card", optional: true) else {
            mapper.recordWarning("STRQ Pro Preview card was not available from Profile.")
            return
        }

        mapper.waitForAny([.id("strq.pro-preview.close"), .label("STRQ PRO PREVIEW")], timeout: 8, requiredName: "STRQ Pro Preview")
        mapper.captureScrollableScreen("profile-pro-preview", maxScrolls: 1)
        _ = mapper.tap(id: "strq.pro-preview.close", labelFallbacks: ["Close", "Schliessen"], name: "Close Pro Preview", optional: true)
    }

    private func launch(locale: ScreenMapLocale) {
        app = XCUIApplication()
        app.launchArguments = locale.launchArguments
        app.launch()
    }

    private func relaunch(locale: ScreenMapLocale) {
        app.terminate()
        launch(locale: locale)
    }
}

private enum ScreenMapLocale {
    case english
    case german

    var slug: String {
        switch self {
        case .english: return "en"
        case .german: return "de"
        }
    }

    var language: String {
        switch self {
        case .english: return "en"
        case .german: return "de"
        }
    }

    var appleLocale: String {
        switch self {
        case .english: return "en_US"
        case .german: return "de_DE"
        }
    }

    var launchArguments: [String] {
        [
            "-STRQUIFixture", "coreFlow",
            "-AppleLanguages", "(\(language))",
            "-AppleLocale", appleLocale
        ]
    }
}

private enum ScreenMapSelector {
    case id(String)
    case label(String)
}

private struct ScreenMapManifest: Encodable {
    let schemaVersion: Int
    let locale: String
    let appleLocale: String
    let generatedAt: String
    let launchArguments: [String]
    let safeInteractionRules: ScreenMapSafeRules
    var screens: [ScreenMapScreen]
    var warnings: [String]
}

private struct ScreenMapSafeRules: Encodable {
    let allowed: [String]
    let forbidden: [String]
}

private struct ScreenMapScreen: Encodable {
    let slug: String
    let screenshot: String
    let capturedAt: String
    let viewport: ScreenMapFrame
    let scrollIndex: Int
    let scrollPosition: String
    let scrollStopReason: String?
    let elements: [ScreenMapElement]
    let scrollableContainers: [ScreenMapElement]
    let missingIdentifierCandidates: [ScreenMapElement]
}

private struct ScreenMapElement: Encodable {
    let identifier: String
    let label: String
    let value: String
    let placeholder: String
    let type: String
    let frame: ScreenMapFrame
    let enabled: Bool
    let selected: Bool
    let hittable: Bool
    let visible: Bool
    let safeAction: String
}

private struct ScreenMapFrame: Encodable {
    let x: Double
    let y: Double
    let width: Double
    let height: Double

    init(_ frame: CGRect) {
        x = Self.clean(frame.minX)
        y = Self.clean(frame.minY)
        width = Self.clean(frame.width)
        height = Self.clean(frame.height)
    }

    private static func clean(_ value: CGFloat) -> Double {
        guard value.isFinite else { return 0 }
        return (Double(value) * 100).rounded() / 100
    }
}

@MainActor
private final class STRQScreenMapExporter {
    private var app: XCUIApplication
    private unowned let testCase: XCTestCase
    private let locale: ScreenMapLocale
    private var manifest: ScreenMapManifest
    private var screenshotIndex: Int = 0
    private let dateFormatter = ISO8601DateFormatter()

    init(app: XCUIApplication, testCase: XCTestCase, locale: ScreenMapLocale) {
        self.app = app
        self.testCase = testCase
        self.locale = locale
        self.manifest = ScreenMapManifest(
            schemaVersion: 1,
            locale: locale.slug,
            appleLocale: locale.appleLocale,
            generatedAt: dateFormatter.string(from: Date()),
            launchArguments: locale.launchArguments,
            safeInteractionRules: ScreenMapSafeRules(
                allowed: [
                    "tab navigation",
                    "scroll",
                    "search focus and text entry",
                    "non-destructive sheet or detail open",
                    "close",
                    "back",
                    "cancel",
                    "done",
                    "explicit harness target only"
                ],
                forbidden: [
                    "purchase",
                    "buy",
                    "subscribe",
                    "restore purchases",
                    "Käufe wiederherstellen",
                    "reset all data",
                    "Alle Daten zurücksetzen",
                    "regenerate plan",
                    "Plan neu erstellen",
                    "sign in with Apple",
                    "Mit Apple anmelden",
                    "sign out",
                    "delete",
                    "löschen",
                    "discard workout",
                    "verwerfen",
                    "finish workout",
                    "destructive confirmation"
                ]
            ),
            screens: [],
            warnings: []
        )
    }

    func update(app: XCUIApplication) {
        self.app = app
    }

    func captureScrollableScreen(_ slug: String, maxScrolls: Int) {
        var seenFingerprints = Set<String>()

        for scrollIndex in 0...maxScrolls {
            let elements = collectVisibleElements()
            let fingerprint = screenFingerprint(elements)
            let alreadySeen = seenFingerprints.contains(fingerprint)
            seenFingerprints.insert(fingerprint)

            let stopReason: String?
            if alreadySeen {
                stopReason = "repeated-fingerprint"
            } else if scrollIndex == maxScrolls {
                stopReason = "max-depth-reached"
            } else {
                stopReason = nil
            }

            captureScreen(
                slug,
                scrollIndex: scrollIndex,
                scrollPosition: scrollPosition(scrollIndex: scrollIndex, maxScrolls: maxScrolls, stopReason: stopReason),
                elements: elements,
                scrollStopReason: stopReason
            )

            if alreadySeen || scrollIndex == maxScrolls { return }

            app.swipeUp()
            settle(0.65)
        }
    }

    func captureScreen(_ slug: String) {
        captureScreen(slug, scrollIndex: 0, scrollPosition: "single", elements: collectVisibleElements(), scrollStopReason: nil)
    }

    func recordWarning(_ warning: String) {
        manifest.warnings.append(warning)
    }

    func attachManifest() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let data = try encoder.encode(manifest)
            let attachment = XCTAttachment(data: data, uniformTypeIdentifier: "public.json")
            attachment.name = "screen-map-\(locale.slug).json"
            attachment.lifetime = .keepAlways
            testCase.add(attachment)
        } catch {
            XCTFail("Failed to encode screen map manifest: \(error)")
        }
    }

    @discardableResult
    func tap(
        id: String,
        labelFallbacks: [String] = [],
        name: String,
        optional: Bool = false,
        timeout: TimeInterval = 6
    ) -> Bool {
        let candidates = [app.buttons[id], app.textFields[id], app.otherElements[id]]
            + labelFallbacks.map { app.buttons[$0] }

        for element in candidates {
            if element.waitForExistence(timeout: timeout / Double(max(candidates.count, 1))) {
                if tap(element, name: name) {
                    return true
                }
            }
        }

        if !optional {
            XCTFail("Missing required element: \(name) (\(id))")
        }
        return false
    }

    func typeText(_ text: String) {
        app.typeText(text)
    }

    func scrollToTop(attempts: Int = 3) {
        for _ in 0..<attempts {
            app.swipeDown()
            settle(0.35)
        }
    }

    func waitForAny(_ selectors: [ScreenMapSelector], timeout: TimeInterval, requiredName: String) {
        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if selectors.contains(where: { exists($0) }) { return }
            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        }
        XCTFail("Timed out waiting for \(requiredName). Current labels: \(collectVisibleElements().map(\.label).joined(separator: " | "))")
    }

    func settle(_ seconds: TimeInterval = 0.45) {
        RunLoop.current.run(until: Date().addingTimeInterval(seconds))
    }

    private func captureScreen(
        _ slug: String,
        scrollIndex: Int,
        scrollPosition: String,
        elements: [ScreenMapElement],
        scrollStopReason: String?
    ) {
        screenshotIndex += 1
        let screenshotName = "\(locale.slug)-\(String(format: "%02d", screenshotIndex))-\(slug)\(scrollIndex == 0 ? "" : "-scroll-\(scrollIndex)")"
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = screenshotName
        attachment.lifetime = .keepAlways
        testCase.add(attachment)

        let scrollables = elements.filter { ["ScrollView", "Table", "CollectionView"].contains($0.type) }
        let missingIDs = elements.filter { isMissingIdentifierCandidate($0, allElements: elements) }

        manifest.screens.append(
            ScreenMapScreen(
                slug: slug,
                screenshot: "screenshots/\(locale.slug)/\(String(format: "%02d", screenshotIndex))-\(slug)\(scrollIndex == 0 ? "" : "-scroll-\(scrollIndex)").png",
                capturedAt: dateFormatter.string(from: Date()),
                viewport: ScreenMapFrame(viewportFrame()),
                scrollIndex: scrollIndex,
                scrollPosition: scrollPosition,
                scrollStopReason: scrollStopReason,
                elements: elements,
                scrollableContainers: scrollables,
                missingIdentifierCandidates: missingIDs
            )
        )
    }

    private func tap(_ element: XCUIElement, name: String) -> Bool {
        let frame = finiteFrame(element.frame)
        guard isVisible(frame, in: viewportFrame()), hasValidTapPoint(frame, in: viewportFrame()) else {
            XCTContext.runActivity(named: "Skip offscreen tap \(name)") { _ in }
            return false
        }

        let type = elementTypeName(element.elementType)
        if safeAction(identifier: element.identifier, label: element.label, type: type, hittable: true) == "forbidden" {
            let label = element.label.isEmpty ? element.identifier : element.label
            recordWarning("Skipped forbidden tap target: \(name) (\(label)).")
            XCTContext.runActivity(named: "Skip forbidden tap \(name)") { _ in }
            return false
        }

        XCTContext.runActivity(named: "Coordinate tap \(name)") { _ in
            element.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5)).tap()
        }
        settle()
        return true
    }

    private func exists(_ selector: ScreenMapSelector) -> Bool {
        switch selector {
        case .id(let identifier):
            return app.descendants(matching: .any)[identifier].exists
        case .label(let label):
            return app.staticTexts[label].exists || app.buttons[label].exists || app.navigationBars[label].exists
        }
    }

    private func collectVisibleElements() -> [ScreenMapElement] {
        let querySpecs: [(query: XCUIElementQuery, limit: Int)] = [
            (app.buttons, 80),
            (app.staticTexts, 55),
            (app.textFields, 24),
            (app.secureTextFields, 8),
            (app.switches, 24),
            (app.sliders, 24),
            (app.links, 24),
            (app.navigationBars, 4),
            (app.scrollViews, 12),
            (app.tables, 8),
            (app.collectionViews, 8)
        ]

        let viewport = viewportFrame()
        var seen = Set<String>()
        var records: [ScreenMapElement] = []

        for spec in querySpecs {
            for element in spec.query.allElementsBoundByIndex.prefix(spec.limit) {
                let frame = finiteFrame(element.frame)
                guard isVisible(frame, in: viewport) else { continue }

                let type = elementTypeName(element.elementType)
                let record = makeRecord(for: element, viewport: viewport, type: type, frame: frame)

                let key = [
                    record.type,
                    record.identifier,
                    record.label,
                    String(record.frame.x),
                    String(record.frame.y),
                    String(record.frame.width),
                    String(record.frame.height)
                ].joined(separator: "|")

                guard !seen.contains(key) else { continue }
                seen.insert(key)
                records.append(record)
            }
        }

        return records.sorted {
            if $0.frame.y == $1.frame.y { return $0.frame.x < $1.frame.x }
            return $0.frame.y < $1.frame.y
        }
    }

    private func scrollPosition(scrollIndex: Int, maxScrolls: Int, stopReason: String?) -> String {
        if maxScrolls == 0 { return "single" }
        if scrollIndex == 0 { return "top" }
        if stopReason == "repeated-fingerprint" { return "bottom-or-repeat" }
        if scrollIndex == maxScrolls { return "max-depth" }
        return "middle"
    }

    private func makeRecord(
        for element: XCUIElement,
        viewport: CGRect,
        type: String,
        frame: CGRect
    ) -> ScreenMapElement {
        let interactiveTypes = ["Button", "TextField", "SecureTextField", "Switch", "Slider", "Link", "Menu", "MenuItem", "SearchField"]
        let isInteractive = interactiveTypes.contains(type)
        let statefulTypes = ["TextField", "SecureTextField", "Switch", "Slider", "SearchField"]
        let identifier = element.identifier
        let label = element.label
        let value = statefulTypes.contains(type) ? stringValue(element.value) : ""
        let placeholder = ["TextField", "SecureTextField", "SearchField"].contains(type) ? (element.placeholderValue ?? "") : ""
        let enabled = statefulTypes.contains(type) ? element.isEnabled : true
        let selected = ["Switch", "Slider"].contains(type) ? element.isSelected : false
        let hittable = isInteractive && enabled && hasValidTapPoint(frame, in: viewport)

        return ScreenMapElement(
            identifier: identifier,
            label: label,
            value: value,
            placeholder: placeholder,
            type: type,
            frame: ScreenMapFrame(frame),
            enabled: enabled,
            selected: selected,
            hittable: hittable,
            visible: true,
            safeAction: safeAction(identifier: identifier, label: label, type: type, hittable: hittable)
        )
    }

    private func viewportFrame() -> CGRect {
        let windowFrame = app.windows.firstMatch.frame
        if isFinite(windowFrame), !windowFrame.isEmpty { return windowFrame }
        let appFrame = app.frame
        if isFinite(appFrame), !appFrame.isEmpty { return appFrame }
        return CGRect(x: 0, y: 0, width: 430, height: 932)
    }

    private func finiteFrame(_ frame: CGRect) -> CGRect {
        guard isFinite(frame) else { return .zero }
        return frame
    }

    private func isFinite(_ frame: CGRect) -> Bool {
        frame.origin.x.isFinite
            && frame.origin.y.isFinite
            && frame.width.isFinite
            && frame.height.isFinite
    }

    private func isVisible(_ frame: CGRect, in viewport: CGRect) -> Bool {
        guard isFinite(frame), !frame.isEmpty else { return false }
        return frame.intersects(viewport.insetBy(dx: 0, dy: -4))
    }

    private func hasValidTapPoint(_ frame: CGRect, in viewport: CGRect) -> Bool {
        guard isFinite(frame), frame.width >= 4, frame.height >= 4 else { return false }
        let tapPoint = CGPoint(x: frame.midX, y: frame.midY)
        return viewport.insetBy(dx: 1, dy: 1).contains(tapPoint)
    }

    private func stringValue(_ value: Any?) -> String {
        guard let value else { return "" }
        if let string = value as? String { return string }
        return String(describing: value)
    }

    private func screenFingerprint(_ elements: [ScreenMapElement]) -> String {
        elements
            .filter { $0.visible }
            .map { "\($0.type):\($0.identifier):\($0.label):\($0.frame.y)" }
            .sorted()
            .joined(separator: "\n")
    }

    private func safeAction(identifier: String, label: String, type: String, hittable: Bool) -> String {
        guard hittable || ["Button", "TextField", "SecureTextField", "Switch", "Slider", "Link", "SearchField", "Menu", "MenuItem"].contains(type) else {
            return "none"
        }

        let text = normalizedForSafety("\(identifier) \(label)")
        let forbiddenTerms = [
            "purchase",
            "buy",
            "start purchase",
            "subscribe",
            "abonnieren",
            "kaufen",
            "kaufen starten",
            "restore",
            "restore purchases",
            "kaufe wiederherstellen",
            "kaeufe wiederherstellen",
            "reset",
            "reset all data",
            "alle daten zurucksetzen",
            "delete",
            "loschen",
            "sign out",
            "signout",
            "sign in with apple",
            "mit apple anmelden",
            "discard",
            "verwerfen",
            "finish workout",
            "regenerate",
            "regenerate plan",
            "plan neu erstellen",
            "destructive"
        ]

        if forbiddenTerms.contains(where: { text.contains($0) }) {
            return "forbidden"
        }

        let allowedTerms = [
            "strq.tab.",
            "search",
            "filter",
            "library",
            "detail",
            "preview",
            "close",
            "cancel",
            "done",
            "back",
            "menu"
        ]

        if allowedTerms.contains(where: { text.contains($0) }) {
            return "allowedTap"
        }

        return hittable ? "observeOnly" : "none"
    }

    private func normalizedForSafety(_ value: String) -> String {
        value
            .folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "en_US_POSIX"))
            .lowercased()
    }

    private func isMissingIdentifierCandidate(_ element: ScreenMapElement, allElements: [ScreenMapElement]) -> Bool {
        guard element.identifier.isEmpty, element.hittable else { return false }
        guard ["Button", "TextField", "SecureTextField", "Switch", "Slider", "Link", "SearchField", "Menu", "MenuItem"].contains(element.type) else {
            return false
        }

        if isSystemKeyboardCandidate(element) { return false }
        if element.label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           overlapsIdentifiedInteractiveElement(element, allElements: allElements) {
            return false
        }

        return true
    }

    private func isSystemKeyboardCandidate(_ element: ScreenMapElement) -> Bool {
        let text = normalizedForSafety("\(element.identifier) \(element.label)")
        let keyboardTerms = [
            "next keyboard",
            "nachste tastatur"
        ]
        return keyboardTerms.contains(where: { text.contains($0) })
    }

    private func overlapsIdentifiedInteractiveElement(_ element: ScreenMapElement, allElements: [ScreenMapElement]) -> Bool {
        allElements.contains { other in
            guard !other.identifier.isEmpty, other.hittable else { return false }
            guard ["Button", "TextField", "SecureTextField", "Switch", "Slider", "Link", "SearchField", "Menu", "MenuItem"].contains(other.type) else {
                return false
            }
            return overlapRatio(element.frame, other.frame) >= 0.35
        }
    }

    private func overlapRatio(_ lhs: ScreenMapFrame, _ rhs: ScreenMapFrame) -> Double {
        let left = max(lhs.x, rhs.x)
        let right = min(lhs.x + lhs.width, rhs.x + rhs.width)
        let top = max(lhs.y, rhs.y)
        let bottom = min(lhs.y + lhs.height, rhs.y + rhs.height)
        let width = max(0, right - left)
        let height = max(0, bottom - top)
        let intersection = width * height
        let smallerArea = max(1, min(lhs.width * lhs.height, rhs.width * rhs.height))
        return intersection / smallerArea
    }

    private func elementTypeName(_ type: XCUIElement.ElementType) -> String {
        switch type {
        case .any: return "Any"
        case .other: return "Other"
        case .alert: return "Alert"
        case .button: return "Button"
        case .navigationBar: return "NavigationBar"
        case .table: return "Table"
        case .collectionView: return "CollectionView"
        case .slider: return "Slider"
        case .switch: return "Switch"
        case .link: return "Link"
        case .image: return "Image"
        case .searchField: return "SearchField"
        case .scrollView: return "ScrollView"
        case .staticText: return "StaticText"
        case .textField: return "TextField"
        case .secureTextField: return "SecureTextField"
        case .menu: return "Menu"
        case .menuItem: return "MenuItem"
        case .cell: return "Cell"
        default: return String(describing: type)
        }
    }
}
