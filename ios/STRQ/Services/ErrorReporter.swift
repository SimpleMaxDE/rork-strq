import Foundation

nonisolated protocol ErrorReportingProvider: Sendable {
    func report(error: Error, context: [String: String])
    func reportMessage(_ message: String, level: ErrorReportLevel, context: [String: String])
    func addBreadcrumb(_ message: String, category: String, data: [String: String])
}

nonisolated enum ErrorReportLevel: String, Sendable {
    case debug
    case info
    case warning
    case error
}

nonisolated struct ConsoleErrorReporter: ErrorReportingProvider {
    func report(error: Error, context: [String: String]) {
        #if DEBUG
        print("[ErrorReporter] error=\(error) context=\(context)")
        #endif
    }

    func reportMessage(_ message: String, level: ErrorReportLevel, context: [String: String]) {
        #if DEBUG
        print("[ErrorReporter][\(level.rawValue)] \(message) \(context)")
        #endif
    }

    func addBreadcrumb(_ message: String, category: String, data: [String: String]) {
        #if DEBUG
        print("[Breadcrumb][\(category)] \(message) \(data)")
        #endif
    }
}

nonisolated struct NoopErrorReporter: ErrorReportingProvider {
    func report(error: Error, context: [String: String]) {}
    func reportMessage(_ message: String, level: ErrorReportLevel, context: [String: String]) {}
    func addBreadcrumb(_ message: String, category: String, data: [String: String]) {}
}

@MainActor
final class ErrorReporter {
    static let shared = ErrorReporter()

    private let provider: ErrorReportingProvider
    private(set) var isConfigured: Bool
    private var breadcrumbs: [(date: Date, category: String, message: String)] = []
    private let maxBreadcrumbs = 40

    private init() {
        #if DEBUG
        self.provider = ConsoleErrorReporter()
        self.isConfigured = true
        #else
        self.provider = NoopErrorReporter()
        self.isConfigured = false
        #endif
    }

    func report(_ error: Error, context: [String: String] = [:]) {
        provider.report(error: error, context: context)
    }

    func reportMessage(_ message: String, level: ErrorReportLevel = .warning, context: [String: String] = [:]) {
        provider.reportMessage(message, level: level, context: context)
    }

    func breadcrumb(_ message: String, category: String = "app", data: [String: String] = [:]) {
        breadcrumbs.append((Date(), category, message))
        if breadcrumbs.count > maxBreadcrumbs {
            breadcrumbs.removeFirst(breadcrumbs.count - maxBreadcrumbs)
        }
        provider.addBreadcrumb(message, category: category, data: data)
    }

    var recentBreadcrumbs: [String] {
        breadcrumbs.suffix(20).map { "[\($0.category)] \($0.message)" }
    }
}
