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
                L10n.tr("regeneratePlan.dialog.title", fallback: "Plan neu erstellen?"),
                isPresented: $isPresented,
                titleVisibility: .visible
            ) {
                Button(L10n.tr("regeneratePlan.currentProfile", fallback: "Mit aktuellen Angaben neu erstellen")) {
                    regenerateWithCurrentProfile()
                }
                Button(L10n.tr("regeneratePlan.restartOnboarding", fallback: "Onboarding erneut durchlaufen")) {
                    showOnboardingRestartConfirm = true
                }
                Button(L10n.tr("Cancel"), role: .cancel) {
                    Analytics.shared.track(.regenerate_plan_cancelled)
                }
            } message: {
                Text(L10n.tr(
                    "regeneratePlan.dialog.message",
                    fallback: "STRQ erstellt deinen Trainingsplan neu. Dein bisheriger Plan wird ersetzt. Geloggte Workouts und Fortschritt bleiben erhalten."
                ))
            }
            .confirmationDialog(
                L10n.tr("regeneratePlan.onboarding.title", fallback: "Onboarding neu starten?"),
                isPresented: $showOnboardingRestartConfirm,
                titleVisibility: .visible
            ) {
                Button(L10n.tr("regeneratePlan.onboarding.start", fallback: "Onboarding starten"), role: .destructive) {
                    restartOnboarding()
                }
                Button(L10n.tr("Cancel"), role: .cancel) {
                    Analytics.shared.track(.regenerate_plan_cancelled)
                }
            } message: {
                Text(L10n.tr(
                    "regeneratePlan.onboarding.message",
                    fallback: "Du passt deine Angaben neu an. Dein aktueller Plan wird ersetzt. Geloggte Workouts und Fortschritt bleiben erhalten."
                ))
            }
            .alert(
                L10n.tr("regeneratePlan.success", fallback: "Neuer Plan erstellt"),
                isPresented: $showRegeneratedSuccess
            ) {
                Button(L10n.tr("OK")) {
                    onRegenerated()
                }
            }
            .alert(
                L10n.tr("regeneratePlan.activeWorkout.title", fallback: "Workout läuft"),
                isPresented: $showActiveWorkoutWarning
            ) {
                Button(L10n.tr("OK"), role: .cancel) {}
            } message: {
                Text(L10n.tr(
                    "regeneratePlan.activeWorkout.message",
                    fallback: "Es läuft noch ein Workout. Beende oder verwirf es, bevor du deinen Plan neu erstellst."
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
