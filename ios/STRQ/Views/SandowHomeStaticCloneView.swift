import SwiftUI

struct SandowHomeStaticCloneView: View {
    private static let frameWidth: CGFloat = 375
    private let cardWidth: CGFloat = 343

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                header
                healthMetricsSection
                activitySection
                workoutSection
                coachSection
                nutritionSection
                supportCard
                sleepSection
                aiCoachSection
                newsSection
                feedbackSection
                staticTabBar
            }
            .frame(maxWidth: Self.frameWidth)
            .frame(maxWidth: .infinity)
        }
        .background(SandowColors.background.ignoresSafeArea())
        .toolbar(.hidden, for: .navigationBar)
        .preferredColorScheme(.dark)
    }

    private var header: some View {
        VStack(spacing: 0) {
            statusBar
                .frame(height: 44)

            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text("Wed, Jun 25")
                            .font(SandowTypography.bodyRegular)
                            .foregroundStyle(SandowColors.cloneInk)

                        SandowChip(label: "1", icon: .train, tone: .brandSoft, size: .compact)
                    }

                    Text("Hello, Makise!")
                        .font(SandowTypography.title)
                        .foregroundStyle(SandowColors.cloneInk)
                        .lineLimit(1)
                }

                Spacer(minLength: 8)

                SandowIconContainer(icon: .search, size: .lg, tint: SandowColors.cloneInk, background: .white)
                    .clipShape(Circle())

                ZStack(alignment: .bottomTrailing) {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(sandowCloneHex: 0xFDE68A), Color(sandowCloneHex: 0xFB923C)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 40, height: 40)
                        .overlay {
                            Text("M")
                                .font(SandowTypography.body.weight(.bold))
                                .foregroundStyle(SandowColors.cloneInk)
                        }

                    Circle()
                        .fill(SandowColors.success)
                        .frame(width: 10, height: 10)
                        .overlay(Circle().strokeBorder(.white, lineWidth: 1.5))
                }
            }
            .padding(16)
            .frame(height: 90)

            scoreSummaryCard
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
        }
        .background(
            LinearGradient(
                colors: [
                    SandowColors.background,
                    SandowColors.orangePrimary.opacity(0.92),
                    SandowColors.orangePrimary
                ],
                startPoint: .top,
                endPoint: .bottom
            ),
            in: UnevenRoundedRectangle(
                topLeadingRadius: 0,
                bottomLeadingRadius: 32,
                bottomTrailingRadius: 32,
                topTrailingRadius: 0,
                style: .continuous
            )
        )
    }

    private var statusBar: some View {
        HStack {
            Text("9:41")
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(.white)

            Spacer()

            HStack(spacing: 4) {
                Capsule()
                    .fill(.white)
                    .frame(width: 16, height: 7)
                Capsule()
                    .strokeBorder(.white, lineWidth: 1)
                    .frame(width: 22, height: 10)
                    .overlay(alignment: .leading) {
                        Capsule()
                            .fill(.white)
                            .frame(width: 15, height: 6)
                            .padding(.leading, 2)
                    }
                Rectangle()
                    .fill(.white)
                    .frame(width: 2, height: 5)
                    .clipShape(.rect(cornerRadius: 1))
            }
        }
        .padding(.horizontal, 32)
        .padding(.top, 10)
    }

    private var scoreSummaryCard: some View {
        SandowSurface(
            padding: 16,
            radius: 24,
            background: .white,
            border: Color(sandowCloneHex: 0xE4E4E7)
        ) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color(sandowCloneHex: 0xFFF7ED))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(SandowColors.orangePrimary, lineWidth: 1)
                        )
                        .shadow(color: SandowColors.orangePrimary.opacity(0.20), radius: 8, y: 4)

                    Text("88")
                        .font(Font.custom(SandowTypography.fontFamily, size: 30).weight(.bold))
                        .foregroundStyle(SandowColors.orangePrimary)
                }
                .frame(width: 64, height: 64)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Wellness Score")
                        .font(SandowTypography.body.weight(.bold))
                        .foregroundStyle(SandowColors.cloneInk)

                    HStack(spacing: 8) {
                        scoreMeta(icon: .recovery, text: "Healthy")
                        Dot(color: Color(sandowCloneHex: 0xE4E4E7), size: 4)
                        scoreMeta(icon: .check, text: "plus User")
                    }
                }

                Spacer(minLength: 0)
                ChevronRight()
                    .stroke(SandowColors.cloneInk, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                    .frame(width: 24, height: 24)
            }
            .frame(height: 64)
        }
    }

    private func scoreMeta(icon: SandowIconAsset, text: String) -> some View {
        HStack(spacing: 4) {
            Image(icon.rawValue)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(SandowColors.cloneInk)
                .frame(width: 20, height: 20)

            Text(text)
                .font(SandowTypography.bodyRegular)
                .foregroundStyle(SandowColors.cloneInk)
                .lineLimit(1)
        }
    }

    private var healthMetricsSection: some View {
        section(title: "Health Metrics") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    metricCard(value: "121", unit: "bpm", label: "Heart Rate", icon: .recovery, tint: SandowColors.danger)
                    metricCard(value: "120/80", unit: "mmHg", label: "Blood Pressure", icon: .progress, tint: SandowColors.blue)
                    metricCard(value: "65.8", unit: "kg", label: "Weight", icon: .train, tint: SandowColors.success)
                }
                .padding(.horizontal, 16)
            }

            carouselIndicator
                .padding(.top, 16)
                .padding(.bottom, 8)
        }
    }

    private func metricCard(value: String, unit: String, label: String, icon: SandowIconAsset, tint: Color) -> some View {
        SandowMetricCard(
            value: value,
            label: label,
            icon: icon,
            unit: unit,
            tint: tint,
            valueFont: SandowTypography.metricCompactNumber,
            iconBackground: .clear,
            minHeight: 108
        )
        .frame(width: 160, height: 140)
    }

    private var carouselIndicator: some View {
        HStack(spacing: 4) {
            SandowProgressBar(value: 1, height: 8, tint: SandowColors.surfaceTertiary).frame(width: 16)
            SandowProgressBar(value: 1, height: 8, tint: SandowColors.orangePrimary).frame(width: 32)
            SandowProgressBar(value: 1, height: 8, tint: SandowColors.surfaceTertiary).frame(width: 16)
            SandowProgressBar(value: 1, height: 8, tint: SandowColors.surfaceTertiary).frame(width: 16)
        }
        .frame(maxWidth: .infinity)
    }

    private var activitySection: some View {
        section(title: "Activity") {
            SandowCard {
                VStack(spacing: 20) {
                    HStack(spacing: 12) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Very Active")
                                .font(SandowTypography.title.weight(.bold))
                                .foregroundStyle(SandowColors.textPrimary)

                            Text("You need 3 more activities .")
                                .font(SandowTypography.bodyRegular)
                                .foregroundStyle(SandowColors.textSecondary)
                        }

                        Spacer()

                        CircularProgressRing(progress: 0.40, size: 64, lineWidth: 6, tint: SandowColors.orangePrimary) {
                            Text("2/5")
                                .font(SandowTypography.caption.weight(.bold))
                                .foregroundStyle(SandowColors.textPrimary)
                        }
                    }

                    VStack(spacing: 16) {
                        activityRow(title: "Jogging", subtitle: "Jun 12, 10:00 AM - 13:30 AM", icon: .train, minutes: "25", kcal: "125", distance: "1.2", score: "+3")
                        activityRow(title: "Walking", subtitle: "Jun 12, 10:00 AM - 13:30 AM", icon: .recovery, minutes: "13", kcal: "85", distance: "0.8", score: "+2")
                    }

                    divider

                    sandowTextAction("Log Activity")
                }
            }
            .frame(width: cardWidth)
            .padding(.horizontal, 16)
        }
    }

    private func activityRow(
        title: String,
        subtitle: String,
        icon: SandowIconAsset,
        minutes: String,
        kcal: String,
        distance: String,
        score: String
    ) -> some View {
        HStack(alignment: .top, spacing: 12) {
            SandowIconContainer(icon: icon, size: .lg, tint: SandowColors.textPrimary, background: .clear)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(SandowTypography.body.weight(.semibold))
                            .foregroundStyle(SandowColors.textPrimary)

                        Text(subtitle)
                            .font(SandowTypography.bodyRegular)
                            .foregroundStyle(SandowColors.textSecondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.72)
                    }

                    Spacer(minLength: 6)

                    ChevronRight()
                        .stroke(SandowColors.textMuted, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                        .frame(width: 24, height: 24)
                }

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .leading, spacing: 8) {
                    activityMetric(icon: .calendar, value: minutes, unit: "min")
                    activityMetric(icon: .train, value: kcal, unit: "kcal")
                    activityMetric(icon: .progress, value: distance, unit: "km")
                    activityMetric(icon: .check, value: score, unit: "score")
                }
            }
        }
    }

    private func activityMetric(icon: SandowIconAsset, value: String, unit: String) -> some View {
        HStack(spacing: 4) {
            Image(icon.rawValue)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(SandowColors.textSecondary)
                .frame(width: 20, height: 20)

            Text(value)
                .font(SandowTypography.body.weight(.semibold))
                .foregroundStyle(SandowColors.textPrimary)

            Text(unit)
                .font(SandowTypography.captionRegular)
                .foregroundStyle(SandowColors.textSecondary)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.72)
    }

    private var workoutSection: some View {
        section(title: "Workouts") {
            ZStack(alignment: .bottomLeading) {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(sandowCloneHex: 0x3F3F46),
                                Color(sandowCloneHex: 0x18181B),
                                Color.black
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                abstractWorkoutTexture

                LinearGradient(
                    colors: [.clear, .black.opacity(0.95)],
                    startPoint: .center,
                    endPoint: .bottom
                )
                .clipShape(.rect(cornerRadius: 24))

                VStack {
                    HStack {
                        SandowChip(label: "Beginner", tone: .neutral, size: .compact)
                        Spacer()
                        ThreeDotMenu()
                    }
                    .padding(16)

                    Spacer()
                }

                VStack(alignment: .leading, spacing: 12) {
                    Text("Mindful Pilates 101")
                        .font(SandowTypography.title.weight(.bold))
                        .foregroundStyle(.white)

                    HStack(spacing: 12) {
                        Circle()
                            .fill(SandowColors.orangeDim)
                            .frame(width: 24, height: 24)
                            .overlay {
                                Text("CS")
                                    .font(.system(size: 8, weight: .bold))
                                    .foregroundStyle(.white)
                            }

                        Text("Coach Cheryl Sanders")
                            .font(SandowTypography.body)
                            .foregroundStyle(.white)
                    }

                    HStack(spacing: 12) {
                        workoutMeta(icon: .train, value: "332", label: "kcal")
                        workoutMeta(icon: .calendar, value: "25", label: "minutes")
                        workoutMeta(icon: .check, value: "+3", label: "score")
                    }
                }
                .padding(16)
            }
            .frame(width: cardWidth, height: 360)
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(SandowColors.borderMuted, lineWidth: 1)
            )
            .clipShape(.rect(cornerRadius: 24))
            .padding(.horizontal, 16)
        }
    }

    private var abstractWorkoutTexture: some View {
        ZStack {
            Circle()
                .stroke(.white.opacity(0.16), lineWidth: 28)
                .frame(width: 220, height: 220)
                .offset(x: 88, y: -88)

            Circle()
                .fill(SandowColors.orangePrimary.opacity(0.22))
                .frame(width: 110, height: 110)
                .blur(radius: 28)
                .offset(x: -90, y: -112)

            RoundedRectangle(cornerRadius: 42, style: .continuous)
                .stroke(.white.opacity(0.12), lineWidth: 10)
                .frame(width: 160, height: 220)
                .rotationEffect(.degrees(-18))
                .offset(x: 32, y: -12)
        }
        .allowsHitTesting(false)
    }

    private func workoutMeta(icon: SandowIconAsset, value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(icon.rawValue)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(SandowColors.orangePrimary)
                    .frame(width: 24, height: 24)

                Text(value)
                    .font(Font.custom(SandowTypography.fontFamily, size: 18).weight(.bold))
                    .foregroundStyle(.white)
            }

            Text(label)
                .font(SandowTypography.bodyRegular)
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var coachSection: some View {
        section(title: "Coach Appointment") {
            SandowSurface(padding: 0, radius: 24) {
                VStack(spacing: 0) {
                    VStack(spacing: 16) {
                        HStack(alignment: .top, spacing: 12) {
                            coachAvatar(initials: "AW")

                            VStack(alignment: .leading, spacing: 8) {
                                Text("Coach Azunyan U. Wu")
                                    .font(SandowTypography.body.weight(.bold))
                                    .foregroundStyle(SandowColors.textPrimary)

                                Text("Wed, Feb 7, 10:00 AM")
                                    .font(SandowTypography.bodyRegular)
                                    .foregroundStyle(SandowColors.textSecondary)

                                HStack(spacing: 8) {
                                    metadataChip(icon: .coach, text: "Cardio Expert")
                                    Dot(color: SandowColors.surfaceTertiary, size: 4)
                                    metadataChip(icon: .check, text: "4.5 (225)")
                                }

                                HStack(spacing: 4) {
                                    Dot(color: SandowColors.success, size: 8)
                                    Text("Available Remotely")
                                        .font(SandowTypography.body)
                                        .foregroundStyle(SandowColors.success)
                                }
                            }
                        }

                        HStack(spacing: 8) {
                            SandowButton(title: "Reschedule", hierarchy: .secondary, size: .compact) {}
                            SandowButton(title: "Cancel", hierarchy: .destructive, size: .compact) {}
                        }
                    }
                    .padding(16)

                    divider

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Upcoming Schedule")
                            .font(SandowTypography.body.weight(.semibold))
                            .foregroundStyle(SandowColors.textPrimary)

                        VStack(spacing: 0) {
                            scheduleRow(dayNumber: "1", dayName: "Mon", title: "Coach. Julia Gray", subtitle: "Upper Body")
                            scheduleRow(dayNumber: "2", dayName: "Tue", title: "Coach. Markus White", subtitle: "Lower Body")
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                }
            }
            .frame(width: cardWidth)
            .padding(.horizontal, 16)
        }
    }

    private func coachAvatar(initials: String) -> some View {
        ZStack(alignment: .bottomTrailing) {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [SandowColors.surfaceTertiary, SandowColors.orangeDim],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 48, height: 48)
                .overlay {
                    Text(initials)
                        .font(SandowTypography.caption.weight(.bold))
                        .foregroundStyle(.white)
                }

            Circle()
                .fill(SandowColors.orangePrimary)
                .frame(width: 20, height: 20)
                .overlay {
                    Image(SandowIconAsset.check.rawValue)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .foregroundStyle(.white)
                        .padding(4)
                }
        }
    }

    private func metadataChip(icon: SandowIconAsset, text: String) -> some View {
        HStack(spacing: 4) {
            Image(icon.rawValue)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .foregroundStyle(SandowColors.textSecondary)
                .frame(width: 20, height: 20)

            Text(text)
                .font(SandowTypography.bodyRegular)
                .foregroundStyle(SandowColors.textPrimary)
        }
        .lineLimit(1)
        .minimumScaleFactor(0.75)
    }

    private func scheduleRow(dayNumber: String, dayName: String, title: String, subtitle: String) -> some View {
        HStack(spacing: 12) {
            VStack(spacing: 0) {
                Text(dayNumber)
                    .font(Font.custom(SandowTypography.fontFamily, size: 16).weight(.semibold))
                    .foregroundStyle(SandowColors.textPrimary)

                Text(dayName)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(SandowColors.textSecondary)
            }
            .frame(width: 40, height: 44)
            .background(SandowColors.surfaceSecondary, in: .rect(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(SandowColors.borderMuted, lineWidth: 1)
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(SandowTypography.body.weight(.semibold))
                    .foregroundStyle(SandowColors.textPrimary)
                Text(subtitle)
                    .font(SandowTypography.bodyRegular)
                    .foregroundStyle(SandowColors.textSecondary)
            }

            Spacer()

            Text("30m")
                .font(SandowTypography.bodyRegular)
                .foregroundStyle(SandowColors.textSecondary)

            ChevronRight()
                .stroke(SandowColors.textMuted, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .frame(width: 24, height: 24)
        }
        .padding(.vertical, 8)
    }

    private var nutritionSection: some View {
        section(title: "Nutrition", showsSeeAll: false) {
            SandowSurface(padding: 16, radius: 24) {
                VStack(spacing: 16) {
                    HStack(spacing: 16) {
                        ZStack {
                            MultiSegmentRing(size: 132)

                            VStack(spacing: 0) {
                                Text("2,158c")
                                    .font(SandowTypography.largeValue)
                                    .foregroundStyle(SandowColors.textPrimary)
                                Text("remaining")
                                    .font(SandowTypography.bodyRegular)
                                    .foregroundStyle(SandowColors.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity)

                        VStack(spacing: 12) {
                            macroRow(label: "Protein", value: "845g", tint: SandowColors.orangePrimary, icon: .train, progress: 0.28)
                            macroRow(label: "Fat", value: "61g", tint: SandowColors.blue, icon: .recovery, progress: 0.72)
                            macroRow(label: "Carbs", value: "584g", tint: SandowColors.success, icon: .progress, progress: 0.96)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .frame(height: 148)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("You're On Track!")
                            .font(SandowTypography.cardTitle)
                            .foregroundStyle(SandowColors.textPrimary)

                        Text("Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt.")
                            .font(SandowTypography.bodyRegular)
                            .foregroundStyle(SandowColors.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    divider
                    sandowTextAction("See Nutrition Dashboard")
                }
            }
            .frame(width: cardWidth)
            .padding(.horizontal, 16)
        }
    }

    private func macroRow(label: String, value: String, tint: Color, icon: SandowIconAsset, progress: Double) -> some View {
        HStack(spacing: 8) {
            CircularProgressRing(progress: progress, size: 40, lineWidth: 4, tint: tint) {
                Image(icon.rawValue)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(tint)
                    .frame(width: 18, height: 18)
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(label)
                    .font(SandowTypography.captionRegular)
                    .foregroundStyle(SandowColors.textSecondary)
                Text(value)
                    .font(Font.custom(SandowTypography.fontFamily, size: 16).weight(.semibold))
                    .foregroundStyle(SandowColors.textPrimary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var supportCard: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Need help? Contact our support team or contact information.")
                    .font(SandowTypography.bodyRegular)
                    .foregroundStyle(.white)
                    .lineSpacing(2)
                    .fixedSize(horizontal: false, vertical: true)

                sandowTextAction("Chat Support")
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)

            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [SandowColors.orangeDim, SandowColors.surfaceSecondary],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 108, height: 112)
                    .rotationEffect(.degrees(-8))

                SandowIconContainer(icon: .coach, size: .xl, tint: SandowColors.orangePrimary, background: SandowColors.background.opacity(0.74))
            }
            .frame(width: 128)
        }
        .frame(width: cardWidth)
        .frame(minHeight: 130)
        .background(.black, in: .rect(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(SandowColors.borderMuted, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private var sleepSection: some View {
        section(title: "Sleep") {
            SandowSurface(padding: 16, radius: 24) {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("5h 25m")
                            .font(SandowTypography.title.weight(.bold))
                            .foregroundStyle(SandowColors.textPrimary)

                        Text("You had a positive sleep last night.")
                            .font(SandowTypography.bodyRegular)
                            .foregroundStyle(SandowColors.textSecondary)
                    }

                    HStack(spacing: 12) {
                        sleepTimeBlock(icon: .sleep, time: "11:00 PM", label: "Bedtime", placesIconTrailing: false)

                        ChevronRight()
                            .stroke(SandowColors.textSecondary, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                            .frame(width: 20, height: 20)

                        sleepTimeBlock(icon: .calendar, time: "06:21 AM", label: "Wake Up", placesIconTrailing: true)
                    }
                    .padding(12)
                    .frame(height: 64)
                    .background(SandowColors.surfacePrimary, in: .rect(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(SandowColors.borderMuted, lineWidth: 1)
                    )

                    VStack(spacing: 8) {
                        SandowProgressRow(label: "Awake", value: "41m", icon: nil, progress: 0.90, tint: SandowColors.orangePrimary, boxed: false)
                        SandowProgressRow(label: "REM", value: "1h 55m", icon: nil, progress: 0.78, tint: SandowColors.blue, boxed: false)
                        SandowProgressRow(label: "Deep", value: "59m", icon: nil, progress: 0.45, tint: SandowColors.success, boxed: false)
                        SandowProgressRow(label: "Wake Up", value: "1h 44m", icon: nil, progress: 0.10, tint: SandowColors.surfaceTertiary, boxed: false)
                    }
                }
            }
            .frame(width: cardWidth)
            .padding(.horizontal, 16)
        }
    }

    private func sleepTimeBlock(icon: SandowIconAsset, time: String, label: String, placesIconTrailing: Bool) -> some View {
        HStack(spacing: 12) {
            if !placesIconTrailing {
                SandowIconContainer(icon: icon, size: .lg, tint: SandowColors.blue, background: SandowColors.blueSoft)
            }

            VStack(alignment: placesIconTrailing ? .trailing : .leading, spacing: 0) {
                Text(time)
                    .font(SandowTypography.body.weight(.semibold))
                    .foregroundStyle(SandowColors.textPrimary)
                Text(label)
                    .font(SandowTypography.bodyRegular)
                    .foregroundStyle(SandowColors.textSecondary)
            }
            .frame(maxWidth: .infinity, alignment: placesIconTrailing ? .trailing : .leading)

            if placesIconTrailing {
                SandowIconContainer(icon: icon, size: .lg, tint: SandowColors.warning, background: SandowColors.warningSoft)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var aiCoachSection: some View {
        section(title: "Sandow AI Coach", showsSeeAll: false) {
            SandowSurface(padding: 16, radius: 24) {
                VStack(spacing: 16) {
                    HStack(alignment: .top, spacing: 8) {
                        SandowIconContainer(icon: .coach, size: .lg, tint: SandowColors.orangePrimary, background: SandowColors.orangeDim)
                            .clipShape(Circle())

                        VStack(alignment: .trailing, spacing: 4) {
                            Text("You are currenlty improving around 3.5% from last month? Would you like a few health tips and resources?")
                                .font(SandowTypography.bodyRegular)
                                .foregroundStyle(SandowColors.textPrimary)
                                .fixedSize(horizontal: false, vertical: true)

                            HStack(spacing: 4) {
                                Text("11:25")
                                    .font(SandowTypography.captionRegular)
                                    .foregroundStyle(SandowColors.textSecondary)

                                Image(SandowIconAsset.check.rawValue)
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .foregroundStyle(SandowColors.textSecondary)
                                    .frame(width: 16, height: 16)
                            }
                        }
                        .padding(12)
                        .background(SandowColors.surfacePrimary, in: .rect(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .strokeBorder(SandowColors.borderMuted, lineWidth: 1)
                        )
                    }

                    divider
                    sandowTextAction("See in detail")
                }
            }
            .frame(width: cardWidth)
            .padding(.horizontal, 16)
        }
    }

    private var newsSection: some View {
        section(title: "News & Resources") {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    articleCard(category: "Habit", author: "Billy Horse", views: "75,215", comments: "88")
                    articleCard(category: "Wellness", author: "Alenia M", views: "2,500", comments: "35")
                }
                .padding(.horizontal, 16)
            }
        }
    }

    private func articleCard(category: String, author: String, views: String, comments: String) -> some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                LinearGradient(
                    colors: [SandowColors.surfaceTertiary, SandowColors.surfacePrimary, SandowColors.orangeDim.opacity(0.45)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                Circle()
                    .stroke(.white.opacity(0.12), lineWidth: 16)
                    .frame(width: 148, height: 148)
                    .offset(x: 58, y: -24)

                HStack(alignment: .top) {
                    SandowChip(label: category, tone: .neutral, size: .compact)
                    Spacer()
                    ThreeDotMenu()
                }
                .padding(16)
            }
            .frame(height: 172)

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(SandowColors.surfaceTertiary)
                        .frame(width: 20, height: 20)
                        .overlay {
                            Text(String(author.prefix(1)))
                                .font(.system(size: 9, weight: .bold))
                                .foregroundStyle(SandowColors.textPrimary)
                        }

                    Text(author)
                    Dot(color: SandowColors.surfaceTertiary, size: 4)
                    Text("3m read")
                }
                .font(SandowTypography.captionRegular)
                .foregroundStyle(SandowColors.textSecondary)
                .lineLimit(1)
                .minimumScaleFactor(0.78)

                Text("Learn about cardio fitness & how it's measured")
                    .font(SandowTypography.cardTitle)
                    .foregroundStyle(SandowColors.textPrimary)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)

                HStack(spacing: 8) {
                    metadataChip(icon: .progress, text: views)
                    Dot(color: SandowColors.surfaceTertiary, size: 4)
                    metadataChip(icon: .coach, text: comments)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 279, height: 328)
        .background(SandowColors.cardSurface, in: .rect(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(SandowColors.borderMuted, lineWidth: 1)
        )
        .clipShape(.rect(cornerRadius: 24))
    }

    private var feedbackSection: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Thanks for the feedback! 🙏")
                    .font(SandowTypography.body.weight(.bold))
                    .foregroundStyle(SandowColors.textPrimary)
                    .frame(maxWidth: .infinity)

                Text("You rates us 4/5 stars. Thank you!")
                    .font(SandowTypography.bodyRegular)
                    .foregroundStyle(SandowColors.textSecondary)
                    .frame(maxWidth: .infinity)
            }
            .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                ForEach(0..<5, id: \.self) { index in
                    SandowStar()
                        .fill(index < 4 ? SandowColors.gold : SandowColors.surfaceTertiary)
                        .frame(width: 40, height: 40)
                }
            }
        }
        .padding(16)
        .frame(width: cardWidth)
        .background(SandowColors.warningSoft, in: .rect(cornerRadius: 24))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(SandowColors.warning, lineWidth: 1)
        )
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    private var staticTabBar: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                tabBarItem(title: "Home", icon: .home, isSelected: true, hasDot: false)
                tabBarItem(title: "sandow AI", icon: .coach, isSelected: false, hasDot: false)

                VStack(spacing: 0) {
                    Circle()
                        .fill(SandowColors.surfaceSecondary)
                        .frame(width: 56, height: 56)
                        .overlay {
                            Image(SandowIconAsset.train.rawValue)
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(.white)
                                .frame(width: 28, height: 28)
                        }
                        .shadow(color: Color.black.opacity(0.22), radius: 18, y: 8)
                }
                .frame(maxWidth: .infinity)
                .frame(minHeight: 64)

                tabBarItem(title: "Resources", icon: .progress, isSelected: false, hasDot: false)
                tabBarItem(title: "Profile", icon: .profile, isSelected: false, hasDot: true)
            }
            .frame(height: 68)

            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(SandowColors.surfaceSecondary)
                .frame(width: 134, height: 5)
                .padding(.top, 8)
                .padding(.bottom, 11)
        }
        .frame(width: Self.frameWidth)
        .sandowTabBarBackground()
    }

    private func tabBarItem(title: String, icon: SandowIconAsset, isSelected: Bool, hasDot: Bool) -> some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(isSelected ? SandowColors.orangePrimary : Color.clear)
                .frame(width: 32, height: 4)

            ZStack(alignment: .topTrailing) {
                SandowTabBarItem(title: title, icon: icon, isSelected: isSelected)

                if hasDot {
                    Circle()
                        .fill(SandowColors.danger)
                        .frame(width: 10, height: 10)
                        .offset(x: -20, y: 12)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }

    private func section<Content: View>(
        title: String,
        showsSeeAll: Bool = true,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            SandowSectionHeader(title) {
                if showsSeeAll {
                    Text("See All")
                        .font(SandowTypography.body.weight(.semibold))
                        .foregroundStyle(SandowColors.orangePrimary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)

            content()
                .padding(.top, 4)
        }
        .padding(.vertical, 8)
    }

    private var divider: some View {
        Rectangle()
            .fill(SandowColors.borderMuted)
            .frame(height: 1)
    }

    private func sandowTextAction(_ title: String) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(SandowTypography.body.weight(.semibold))
                .foregroundStyle(SandowColors.orangePrimary)
            ChevronRight()
                .stroke(SandowColors.orangePrimary, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                .frame(width: 18, height: 18)
        }
        .frame(maxWidth: .infinity)
    }
}

private struct Dot: View {
    let color: Color
    var size: CGFloat

    var body: some View {
        Circle()
            .fill(color)
            .frame(width: size, height: size)
    }
}

private struct ThreeDotMenu: View {
    var body: some View {
        VStack(spacing: 3) {
            Dot(color: SandowColors.textPrimary, size: 3)
            Dot(color: SandowColors.textPrimary, size: 3)
            Dot(color: SandowColors.textPrimary, size: 3)
        }
        .frame(width: 40, height: 40)
        .background(SandowColors.surfacePrimary.opacity(0.82), in: Circle())
        .overlay(Circle().strokeBorder(SandowColors.borderMuted, lineWidth: 1))
    }
}

private struct ChevronRight: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + rect.width * 0.38, y: rect.minY + rect.height * 0.24))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.64, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX + rect.width * 0.38, y: rect.minY + rect.height * 0.76))
        return path
    }
}

private struct CircularProgressRing<Content: View>: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    let tint: Color
    let content: Content

    init(
        progress: Double,
        size: CGFloat,
        lineWidth: CGFloat,
        tint: Color,
        @ViewBuilder content: () -> Content
    ) {
        self.progress = progress
        self.size = size
        self.lineWidth = lineWidth
        self.tint = tint
        self.content = content()
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(SandowColors.surfaceTertiary, lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: min(max(progress, 0), 1))
                .stroke(tint, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            content
        }
        .frame(width: size, height: size)
    }
}

private struct MultiSegmentRing: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(SandowColors.surfaceTertiary, lineWidth: 10)

            ringSegment(from: 0.00, to: 0.55, color: SandowColors.orangePrimary)
            ringSegment(from: 0.60, to: 0.78, color: SandowColors.blue)
            ringSegment(from: 0.82, to: 0.95, color: SandowColors.success)
        }
        .frame(width: size, height: size)
    }

    private func ringSegment(from start: Double, to end: Double, color: Color) -> some View {
        Circle()
            .trim(from: start, to: end)
            .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
            .rotationEffect(.degrees(-90))
    }
}

private struct SandowStar: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let points = 5
        let outerRadius = min(rect.width, rect.height) / 2
        let innerRadius = outerRadius * 0.45
        var path = Path()

        for index in 0..<(points * 2) {
            let angle = -CGFloat.pi / 2 + CGFloat(index) * CGFloat.pi / CGFloat(points)
            let radius = index.isMultiple(of: 2) ? outerRadius : innerRadius
            let point = CGPoint(
                x: center.x + cos(angle) * radius,
                y: center.y + sin(angle) * radius
            )

            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }

        path.closeSubpath()
        return path
    }
}

private extension Color {
    init(sandowCloneHex hex: UInt, opacity: Double = 1) {
        let red = Double((hex >> 16) & 0xFF) / 255
        let green = Double((hex >> 8) & 0xFF) / 255
        let blue = Double(hex & 0xFF) / 255
        self.init(red: red, green: green, blue: blue, opacity: opacity)
    }
}
