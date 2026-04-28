import SwiftUI

#if DEBUG
private let showsSandowHomeStaticCloneDebugRoute = true
#endif

struct ContentView: View {
    @Bindable var vm: AppViewModel
    var store: StoreViewModel
    @State private var selectedTab: Int = 0
    @State private var presentedDeepLinkSheet: DeepLinkSheet?
    private let notificationDeepLinkCenter: NotificationDeepLinkCenter = .shared

    var body: some View {
        Group {
            if !vm.hasCompletedOnboarding {
                switch vm.onboardingPhase {
                case .form:
                    OnboardingView(vm: vm)
                case .generating:
                    PlanGenerationView(profile: vm.profile) {
                        vm.finishPlanGeneration()
                    }
                case .reveal:
                    if let plan = vm.currentPlan {
                        PlanRevealView(
                            plan: plan,
                            profile: vm.profile,
                            planQuality: vm.planQuality,
                            onStart: {
                                vm.completeOnboarding()
                                if let day = vm.todaysWorkout ?? vm.nextWorkout {
                                    vm.prepareWorkoutHandoff(day: day)
                                }
                            },
                            impacts: vm.onboardingImpactSummary()
                        )
                    }
                }
            } else if (vm.activeWorkout != nil && !vm.workoutMinimized) || vm.completedWorkoutHandoff != nil {
                ActiveWorkoutView(vm: vm) {
                    withAnimation(.snappy(duration: 0.25)) {
                        selectedTab = 0
                    }
                    vm.refreshDailyState()
                    vm.completedWorkoutHandoff = nil
                }
            } else if vm.showPreWorkoutHandoff, let day = vm.handoffDay {
                PreWorkoutHandoffView(
                    vm: vm,
                    day: day,
                    onStart: { vm.confirmStartWorkout() },
                    onCancel: { vm.cancelHandoff() }
                )
            } else {
                TabView(selection: $selectedTab) {
                    Tab(value: 0) {
                        NavigationStack {
                            #if DEBUG
                            if showsSandowHomeStaticCloneDebugRoute {
                                SandowHomeStaticCloneView()
                            } else {
                                DashboardView(vm: vm)
                            }
                            #else
                            DashboardView(vm: vm)
                            #endif
                        }
                    }
                    Tab(value: 1) {
                        NavigationStack {
                            CoachTabView(vm: vm)
                        }
                    }
                    Tab(value: 2) {
                        NavigationStack {
                            TrainingPlanView(vm: vm)
                        }
                    }
                    Tab(value: 3) {
                        NavigationStack {
                            ProgressAnalyticsView(vm: vm)
                        }
                    }
                    Tab(value: 4) {
                        NavigationStack {
                            ProfileView(vm: vm, store: store)
                        }
                    }
                }
                .tabViewStyle(.sidebarAdaptable)
                .tint(.white)
                .preferredColorScheme(.dark)
                .toolbar(.hidden, for: .tabBar)
                .safeAreaInset(edge: .bottom, spacing: 0) {
                    #if DEBUG
                    if !(showsSandowHomeStaticCloneDebugRoute && selectedTab == 0) {
                        STRQTabBar(selectedTab: $selectedTab, hasWorkoutToday: vm.todaysWorkout != nil)
                    }
                    #else
                    STRQTabBar(selectedTab: $selectedTab, hasWorkoutToday: vm.todaysWorkout != nil)
                    #endif
                }
            }
        }
        .task {
            handlePendingNotificationRoute()
        }
        .onChange(of: notificationDeepLinkCenter.pendingRoute) { _, _ in
            handlePendingNotificationRoute()
        }
        .onChange(of: vm.todayTabRequestID) { _, _ in
            withAnimation(.snappy(duration: 0.25)) {
                selectedTab = 0
            }
        }
        .sheet(item: $presentedDeepLinkSheet) { sheet in
            switch sheet {
            case .readinessCheckIn:
                ReadinessCheckInView(vm: vm) { readiness in
                    vm.submitReadiness(readiness)
                }
            case .sleepLog:
                NavigationStack {
                    SleepLogView(vm: vm)
                }
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
            }
        }
    }

    private func handlePendingNotificationRoute() {
        guard let route = notificationDeepLinkCenter.consume() else { return }

        switch route {
        case .resumeWorkout:
            withAnimation(.snappy(duration: 0.25)) {
                selectedTab = 0
            }
            if vm.activeWorkout != nil {
                vm.workoutMinimized = false
            } else if let day = vm.todaysWorkout ?? vm.nextWorkout {
                vm.prepareWorkoutHandoff(day: day)
            }
        case .readinessCheckIn:
            presentedDeepLinkSheet = .readinessCheckIn
        case .sleepLog:
            presentedDeepLinkSheet = .sleepLog
        }
    }

    private enum DeepLinkSheet: String, Identifiable {
        case readinessCheckIn
        case sleepLog

        var id: String { rawValue }
    }
}

struct STRQTabBar: View {
    @Binding var selectedTab: Int
    let hasWorkoutToday: Bool

    private let items: [(icon: String, labelKey: LocalizedStringKey, index: Int)] = [
        ("house.fill", "Today", 0),
        ("brain.head.profile.fill", "Coach", 1),
        ("bolt.fill", "Train", 2),
        ("chart.line.uptrend.xyaxis", "Progress", 3),
        ("person.fill", "Profile", 4),
    ]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(items, id: \.index) { item in
                if item.index == 2 {
                    centerTrainTab(item)
                } else {
                    regularTab(item)
                }
            }
        }
        .padding(.horizontal, 10)
        .padding(.top, 9)
        .padding(.bottom, 5)
        .background {
            STRQPalette.sandowBackground
                .ignoresSafeArea()
                .overlay(alignment: .top) {
                    Rectangle()
                        .fill(STRQPalette.sandowBorder)
                        .frame(height: 1)
                }
                .shadow(color: Color.black.opacity(0.38), radius: 18, y: -8)
        }
    }

    private func regularTab(_ item: (icon: String, labelKey: LocalizedStringKey, index: Int)) -> some View {
        let isSelected = selectedTab == item.index

        return Button {
            withAnimation(.snappy(duration: 0.2)) { selectedTab = item.index }
        } label: {
            VStack(spacing: 5) {
                Capsule()
                    .fill(isSelected ? STRQPalette.sandowOrange : Color.clear)
                    .frame(width: 24, height: 3)
                Image(systemName: item.icon)
                    .font(.system(size: 18, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? STRQPalette.sandowOrange : STRQPalette.textMuted)
                Text(item.labelKey)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? STRQPalette.sandowOrange : STRQPalette.textMuted)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 50)
        }
        .sensoryFeedback(.selection, trigger: selectedTab)
    }

    private func centerTrainTab(_ item: (icon: String, labelKey: LocalizedStringKey, index: Int)) -> some View {
        let isSelected = selectedTab == item.index

        return Button {
            withAnimation(.snappy(duration: 0.2)) { selectedTab = item.index }
        } label: {
            VStack(spacing: 4) {
                ZStack {
                    Circle()
                        .fill(
                            isSelected
                                ? AnyShapeStyle(STRQPalette.sandowOrange)
                                : AnyShapeStyle(Color.white)
                        )
                        .frame(width: 56, height: 56)
                        .overlay(
                            Circle()
                                .strokeBorder(hasWorkoutToday ? STRQPalette.sandowOrange.opacity(0.72) : Color.white.opacity(0.16), lineWidth: 2)
                        )
                        .shadow(color: isSelected ? STRQPalette.sandowOrange.opacity(0.28) : Color.black.opacity(0.28), radius: 14, y: 6)

                    if isSelected {
                        Circle()
                            .fill(STRQPalette.sandowOrange.opacity(0.18))
                            .frame(width: 60, height: 60)
                            .blur(radius: 12)
                    }

                    Image(systemName: item.icon)
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(isSelected ? Color.white : Color.black)
                }
                .offset(y: -10)

                Text(item.labelKey)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundStyle(isSelected ? STRQPalette.sandowOrange : STRQPalette.textMuted)
                    .offset(y: -7)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 58)
        }
        .sensoryFeedback(.impact(flexibility: .rigid, intensity: 0.4), trigger: selectedTab)
    }
}
