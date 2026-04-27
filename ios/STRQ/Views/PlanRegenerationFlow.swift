import SwiftUI

private struct PlanRegenerationFlowModifier: ViewModifier {
    let vm: AppViewModel
    @Binding var isPresented: Bool
    let onRegenerated: () -> Void

    @State private var showOnboardingRestartConfirm: Bool = false
    @State private var showRegeneratedSuccess: Bool = false
    @State private var showActiveWorkoutWarning: Bool = false

    func body(content: Content) -> some View {
        content
            .confirmationDialog(
                L10n.tr("regeneratePlan.dialog.title", fallback: "Regenerate plan?"),
                isPresented: $isPresented,
                titleVisibility: .visible
            ) {
                Button(L10n.tr("regeneratePlan.currentProfile", fallback: "Regenerate with current settings")) {
                    regenerateWithCurrentProfile()
                }
                Button(L10n.tr("regeneratePlan.restartOnboarding", fallback: "Redo onboarding")) {
                    showOnboardingRestartConfirm = true
                }
                Button(L10n.tr("Cancel"), role: .cancel) {
                    Analytics.shared.track(.regenerate_plan_cancelled)
                }
            } message: {
                Text(L10n.tr(
                    "regeneratePlan.dialog.message",
                    fallback: "STRQ will rebuild your training plan. Your current plan will be replaced. Logged workouts and progress stay preserved."
                ))
            }
            .confirmationDialog(
                L10n.tr("regeneratePlan.onboarding.title", fallback: "Restart onboarding?"),
                isPresented: $showOnboardingRestartConfirm,
                titleVisibility: .visible
            ) {
                Button(L10n.tr("regeneratePlan.onboarding.start", fallback: "Start onboarding"), role: .destructive) {
                    restartOnboarding()
                }
                Button(L10n.tr("Cancel"), role: .cancel) {
                    Analytics.shared.track(.regenerate_plan_cancelled)
                }
            } message: {
                Text(L10n.tr(
                    "regeneratePlan.onboarding.message",
                    fallback: "You will update your setup. Your current plan will be replaced. Logged workouts and progress stay preserved."
                ))
            }
            .alert(
                L10n.tr("regeneratePlan.success", fallback: "New plan created"),
                isPresented: $showRegeneratedSuccess
            ) {
                Button(L10n.tr("OK")) {
                    onRegenerated()
                }
            }
            .alert(
                L10n.tr("regeneratePlan.activeWorkout.title", fallback: "Workout in progress"),
                isPresented: $showActiveWorkoutWarning
            ) {
                Button(L10n.tr("OK"), role: .cancel) {}
            } message: {
                Text(L10n.tr(
                    "regeneratePlan.activeWorkout.message",
                    fallback: "A workout is still in progress. Finish or discard it before rebuilding your plan."
                ))
            }
    }

    private func regenerateWithCurrentProfile() {
        Analytics.shared.track(.regenerate_plan_current_profile_confirmed)
        guard vm.regeneratePlanFromCurrentProfile() else {
            showActiveWorkoutWarning = true
            return
        }
        showRegeneratedSuccess = true
    }

    private func restartOnboarding() {
        Analytics.shared.track(.regenerate_plan_onboarding_restart_confirmed)
        guard vm.restartOnboardingPreservingHistory() else {
            showActiveWorkoutWarning = true
            return
        }
    }
}

extension View {
    func planRegenerationFlow(
        vm: AppViewModel,
        isPresented: Binding<Bool>,
        onRegenerated: @escaping () -> Void = {}
    ) -> some View {
        modifier(PlanRegenerationFlowModifier(
            vm: vm,
            isPresented: isPresented,
            onRegenerated: onRegenerated
        ))
    }
}
