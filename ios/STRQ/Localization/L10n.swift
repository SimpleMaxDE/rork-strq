import Foundation

nonisolated enum L10n {
    static func tr(_ key: String, comment: String = "") -> String {
        NSLocalizedString(key, comment: comment)
    }

    static func tr(_ key: String, fallback: String, comment: String = "") -> String {
        Bundle.main.localizedString(forKey: key, value: fallback, table: nil)
    }

    static func format(_ key: String, _ arguments: CVarArg..., comment: String = "") -> String {
        String(format: tr(key, comment: comment), locale: Locale.current, arguments: arguments)
    }

    static func format(_ key: String, fallback: String, _ arguments: CVarArg..., comment: String = "") -> String {
        String(format: tr(key, fallback: fallback, comment: comment), locale: Locale.current, arguments: arguments)
    }

    static func countedNoun(
        _ count: Int,
        singularKey: String,
        pluralKey: String,
        singularFallback: String,
        pluralFallback: String
    ) -> String {
        tr(
            count == 1 ? singularKey : pluralKey,
            fallback: count == 1 ? singularFallback : pluralFallback
        )
    }

    static func countLabel(
        _ count: Int,
        singularKey: String,
        pluralKey: String,
        singularFallback: String,
        pluralFallback: String
    ) -> String {
        "\(count) \(countedNoun(count, singularKey: singularKey, pluralKey: pluralKey, singularFallback: singularFallback, pluralFallback: pluralFallback))"
    }
}
