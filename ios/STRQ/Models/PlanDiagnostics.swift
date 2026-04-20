import Foundation

// Generator QA diagnostics.
//
// These types describe the output of a scenario-based plan-generation run.
// They are internal — not rendered to end users. The QA harness produces a
// `PlanQAReport` so generator changes can be checked systematically instead
// of eyeballed.

nonisolated enum PlanWarningSeverity: Int, Sendable, Comparable, Codable {
    case info = 0
    case warning = 1
    case critical = 2

    static func < (lhs: Self, rhs: Self) -> Bool { lhs.rawValue < rhs.rawValue }

    var label: String {
        switch self {
        case .info: "Info"
        case .warning: "Warning"
        case .critical: "Critical"
        }
    }
}

nonisolated struct PlanWarning: Sendable, Identifiable {
    let id: String
    let severity: PlanWarningSeverity
    let message: String

    init(id: String = UUID().uuidString, severity: PlanWarningSeverity, message: String) {
        self.id = id
        self.severity = severity
        self.message = message
    }
}

nonisolated struct PlanDayDiagnostic: Sendable, Identifiable {
    let id: String
    let dayName: String
    let focusMuscles: [MuscleGroup]
    let exerciseCount: Int
    let totalSets: Int
    let anchorCount: Int
    let secondaryCount: Int
    let accessoryCount: Int
    let isolationCount: Int
    let importedCount: Int
    let dominantPatterns: [String]
    let sameMuscleOverload: [MuscleGroup]
    let estimatedMinutes: Int
    let warnings: [PlanWarning]
}

nonisolated struct PlanScenarioDiagnostic: Sendable, Identifiable {
    let id: String
    let label: String
    let splitName: String
    let profileSummary: String
    let totalExercises: Int
    let totalSets: Int
    let importedRatio: Double // 0...1
    let weeklyVolume: [MuscleGroup: Int]
    let days: [PlanDayDiagnostic]
    let warnings: [PlanWarning]

    var maxSeverity: PlanWarningSeverity {
        let all = warnings + days.flatMap(\.warnings)
        return all.map(\.severity).max() ?? .info
    }

    var totalWarnings: Int {
        warnings.count + days.reduce(0) { $0 + $1.warnings.count }
    }
}

nonisolated struct PlanQAReport: Sendable {
    let scenarios: [PlanScenarioDiagnostic]
    let generatedAt: Date

    var totalScenarios: Int { scenarios.count }

    var scenariosWithCritical: Int {
        scenarios.filter { $0.maxSeverity == .critical }.count
    }

    var scenariosWithWarnings: Int {
        scenarios.filter { $0.totalWarnings > 0 }.count
    }

    var totalWarnings: Int {
        scenarios.reduce(0) { $0 + $1.totalWarnings }
    }
}
