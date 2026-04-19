import Foundation

/// Centralized production URLs for legal + support.
/// Sourced from public env vars when available so we don't ship
/// hardcoded brand strings that can't be updated without a release.
enum STRQLinks {
    static var privacy: URL {
        URL(string: env("EXPO_PUBLIC_PRIVACY_URL", default: "https://rork.com/privacy"))!
    }

    static var terms: URL {
        URL(string: env("EXPO_PUBLIC_TERMS_URL", default: "https://rork.com/terms"))!
    }

    static var support: URL {
        URL(string: env("EXPO_PUBLIC_SUPPORT_URL", default: "mailto:support@rork.com"))!
    }

    private static func env(_ key: String, default fallback: String) -> String {
        let value = Config.allValues[key] ?? ""
        return value.isEmpty ? fallback : value
    }
}
