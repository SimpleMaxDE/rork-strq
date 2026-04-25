import Foundation

nonisolated enum L10n {
    static func tr(_ key: String, comment: String = "") -> String {
        NSLocalizedString(key, comment: comment)
    }

    static func format(_ key: String, _ arguments: CVarArg..., comment: String = "") -> String {
        String(format: NSLocalizedString(key, comment: comment), locale: Locale.current, arguments: arguments)
    }
}
