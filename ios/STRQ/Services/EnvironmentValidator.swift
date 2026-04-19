import Foundation
#if canImport(UIKit)
import UIKit
#endif

/// Central, one-shot validation of production-critical configuration.
///
/// Catches missing keys, malformed URLs, and misconfigured integrations
/// at launch so they surface as a clear log line instead of silent
/// misbehavior deep inside a flow. Never crashes — only reports.
@MainActor
enum EnvironmentValidator {
    struct Report {
        var issues: [String] = []
        var warnings: [String] = []
        var isClean: Bool { issues.isEmpty && warnings.isEmpty }
    }

    static func validate() -> Report {
        var report = Report()

        // RevenueCat — at least one key must be present in release.
        #if !DEBUG
        if Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY.isEmpty {
            report.issues.append("RevenueCat iOS API key missing")
        }
        #else
        if Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY.isEmpty && Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY.isEmpty {
            report.warnings.append("RevenueCat not configured — subscriptions will no-op")
        }
        #endif

        // Legal/support URLs — must parse, use http(s) or mailto, and have a host.
        // A malformed release override would otherwise silently 404 from Profile.
        for (label, url) in [
            ("privacy", STRQLinks.privacy),
            ("terms", STRQLinks.terms),
            ("support", STRQLinks.support)
        ] {
            let scheme = url.scheme?.lowercased() ?? ""
            let validScheme = ["https", "http", "mailto"].contains(scheme)
            let hasTarget = !(url.host?.isEmpty ?? true) || scheme == "mailto"
            if !validScheme || !hasTarget {
                report.issues.append("\(label) URL invalid: \(url.absoluteString)")
            }
        }

        // iCloud — informational, not an error. Restore/upload gracefully no-op.
        if FileManager.default.ubiquityIdentityToken == nil {
            report.warnings.append("iCloud unavailable — cloud sync will remain idle")
        }

        // Bundle identity — required for RevenueCat / StoreKit / WatchConnectivity
        // to wire correctly. Missing in unusual test harnesses only.
        if (Bundle.main.bundleIdentifier ?? "").isEmpty {
            report.warnings.append("Bundle identifier missing — integrations may misbehave")
        }

        // Low power mode — not a failure, but useful breadcrumb for launch telemetry
        // so slow-feeling sessions can be explained after the fact.
        #if canImport(UIKit)
        if ProcessInfo.processInfo.isLowPowerModeEnabled {
            report.warnings.append("Low Power Mode enabled")
        }
        #endif

        return report
    }

    static func validateAndLog() {
        let report = validate()
        for issue in report.issues {
            ErrorReporter.shared.reportMessage(issue, level: .warning, context: ["area": "env"])
            ErrorReporter.shared.breadcrumb("Env issue: \(issue)", category: "env")
        }
        for warning in report.warnings {
            ErrorReporter.shared.breadcrumb("Env warning: \(warning)", category: "env")
        }
        if report.isClean {
            ErrorReporter.shared.breadcrumb("Env validated clean", category: "env")
        }
    }
}
