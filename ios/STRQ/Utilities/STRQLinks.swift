import Foundation

/// Centralized production URLs for legal + support.
/// Sourced from public env vars when available so we don't ship
/// hardcoded brand strings that can't be updated without a release.
enum STRQLinks {
    // Hardcoded fallbacks that are known-valid at compile time. Used if an
    // env override is set but malformed — never force-unwrap user-controlled
    // strings at runtime, or a bad release config would crash the Profile tab.
    private static let privacyFallback = URL(string: "https://rork.com/privacy")!
    private static let termsFallback = URL(string: "https://rork.com/terms")!
    private static let supportFallback = URL(string: "mailto:support@rork.com")!

    static var privacy: URL {
        url(for: "EXPO_PUBLIC_PRIVACY_URL", fallback: privacyFallback)
    }

    static var terms: URL {
        url(for: "EXPO_PUBLIC_TERMS_URL", fallback: termsFallback)
    }

    static var support: URL {
        url(for: "EXPO_PUBLIC_SUPPORT_URL", fallback: supportFallback)
    }

    private static func url(for key: String, fallback: URL) -> URL {
        let value = (Config.allValues[key] ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !value.isEmpty, let parsed = URL(string: value) else { return fallback }
        return parsed
    }
}
