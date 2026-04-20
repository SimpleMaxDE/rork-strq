import Foundation

nonisolated protocol AnalyticsProvider: Sendable {
    func track(event: String, properties: [String: String])
    func identify(userId: String?, traits: [String: String])
}

nonisolated struct ConsoleAnalyticsProvider: AnalyticsProvider {
    func track(event: String, properties: [String: String]) {
        #if DEBUG
        if properties.isEmpty {
            print("[Analytics] \(event)")
        } else {
            let props = properties.map { "\($0.key)=\($0.value)" }.sorted().joined(separator: ", ")
            print("[Analytics] \(event) { \(props) }")
        }
        #endif
    }

    func identify(userId: String?, traits: [String: String]) {
        #if DEBUG
        print("[Analytics] identify user=\(userId ?? "anon") traits=\(traits)")
        #endif
    }
}

nonisolated struct NoopAnalyticsProvider: AnalyticsProvider {
    func track(event: String, properties: [String: String]) {}
    func identify(userId: String?, traits: [String: String]) {}
}

@MainActor
final class Analytics {
    static let shared = Analytics()

    private let provider: AnalyticsProvider
    private(set) var isConfigured: Bool
    private var hasLoggedAppOpened = false

    private init() {
        #if DEBUG
        self.provider = ConsoleAnalyticsProvider()
        self.isConfigured = true
        #else
        self.provider = NoopAnalyticsProvider()
        self.isConfigured = false
        #endif
    }

    func track(_ event: AnalyticsEvent, _ properties: [String: String] = [:]) {
        var merged = properties
        merged["env"] = environmentTag
        provider.track(event: event.rawValue, properties: merged)
    }

    func identify(userId: String? = nil, traits: [String: String] = [:]) {
        provider.identify(userId: userId, traits: traits)
    }

    func appOpened(isFirstLaunch: Bool) {
        guard !hasLoggedAppOpened else {
            track(.app_became_active)
            return
        }
        hasLoggedAppOpened = true
        track(.app_opened)
        if isFirstLaunch {
            track(.first_launch)
        }
    }

    private var environmentTag: String {
        #if DEBUG
        return "debug"
        #else
        return isConfigured ? "prod" : "noop"
        #endif
    }
}

nonisolated enum AnalyticsEvent: String {
    // App lifecycle
    case app_opened
    case first_launch
    case app_became_active

    // Onboarding
    case onboarding_started
    case onboarding_step_completed
    case onboarding_completed
    case plan_generation_started
    case plan_generation_completed
    case plan_reveal_viewed
    case plan_reveal_started_training

    // Training
    case today_viewed
    case train_viewed
    case workout_review_started
    case workout_started
    case set_logged
    case workout_completed
    case workout_abandoned
    case active_workout_restored

    // Retention / Activation (first-week)
    case first_session_started
    case first_session_completed
    case second_session_started
    case second_session_completed
    case third_session_completed
    case week_one_target_hit
    case activation_roadmap_viewed
    case activation_step_unlocked
    case rest_day_guidance_viewed

    // Retention / Comeback (Phase 22)
    case comeback_card_viewed
    case comeback_cta_tapped
    case comeback_ease_applied
    case lapse_tier_entered

    // Coach
    case coach_viewed
    case coach_action_applied
    case coach_action_undone
    case weekly_review_opened
    case weekly_review_action_applied

    // Logging
    case readiness_logged
    case weight_logged
    case sleep_logged
    case nutrition_logged

    // Schedule
    case workout_moved
    case workout_skipped
    case workout_unskipped
    case auto_schedule_used
    case plan_edited

    // Subscription
    case paywall_viewed
    case package_selected
    case purchase_started
    case purchase_completed
    case purchase_failed
    case restore_started
    case restore_completed
    case restore_failed
    case subscription_active_viewed
    case manage_subscription_opened

    // Progress
    case progress_viewed
    case profile_viewed

    // Persistence
    case persistence_loaded
    case persistence_reset
    case persistence_load_failed

    // Account
    case account_signed_in
    case account_signed_out
    case account_sign_in_failed
    case cloud_sync_uploaded
    case cloud_sync_restored
    case cloud_sync_failed
}
