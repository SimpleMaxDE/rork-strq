import SwiftUI
import Charts

struct WeeklyCheckInView: View {
    let vm: AppViewModel
    let review: WeeklyReview
    @Environment(\.dismiss) private var dismiss
    @State private var appeared: Bool = false
    @State private var selectedAction: ReviewAction?
    @State private var showConfirmation: Bool = false
    @State private var currentPage: Int = 0

    private struct WeeklyTargetDisplay {
        let primary: String
        let secondary: String
    }

    private func weeklyTargetDisplay(completed rawCompleted: Int, target rawTarget: Int) -> WeeklyTargetDisplay {
        let completed = max(0, rawCompleted)
        guard rawTarget > 0 else {
            return WeeklyTargetDisplay(primary: "\(completed)", secondary: L10n.tr("Workouts"))
        }

        let target = rawTarget
        let primary = "\(min(completed, target))/\(target)"

        if completed > target {
            return WeeklyTargetDisplay(primary: primary, secondary: L10n.format("+%d zusätzlich", completed - target))
        }

        if completed == target {
            return WeeklyTargetDisplay(primary: primary, secondary: L10n.tr("weeklyReview.targetReached", fallback: "Wochenziel erreicht"))
        }

        return WeeklyTargetDisplay(primary: primary, secondary: L10n.tr("Workouts"))
    }

    private let pages = ["summary", "highlights", "coach"]
    private var reportBackground: Color { Color(red: 0.010, green: 0.013, blue: 0.018) }
    private var reportNavy: Color { Color(red: 0.045, green: 0.075, blue: 0.125) }
    private var reportSteel: Color { Color(red: 0.340, green: 0.455, blue: 0.575) }
    private var reportInk: Color { Color(red: 0.610, green: 0.725, blue: 0.840) }
    private var reportLine: Color { Color.white.opacity(0.085) }
    private var reportSurface: LinearGradient {
        LinearGradient(
            colors: [
                STRQPalette.surfaceRaised,
                STRQPalette.surfaceBase,
                reportNavy.opacity(0.72)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                pageIndicator
                    .padding(.top, 8)

                TabView(selection: $currentPage) {
                    reviewPage {
                        summaryPage
                    }
                    .tag(0)

                    reviewPage {
                        highlightsPage
                    }
                    .tag(1)

                    reviewPage {
                        coachPage
                    }
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(reportBackground)
            .navigationTitle(weeklyReviewText("weeklyReview.title", fallback: "Wochenrückblick"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundStyle(reportInk.opacity(0.42))
                    }
                }
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) { appeared = true }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .presentationContentInteraction(.scrolls)
    }

    private func reviewPage<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ScrollView(.vertical) {
            content()
                .padding(.bottom, 24)
        }
        .scrollIndicators(.hidden)
        .background(reportBackground)
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(pages.indices, id: \.self) { index in
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .fill(currentPage == index ? reportInk : Color.white.opacity(0.14))
                    .frame(width: currentPage == index ? 30 : 9, height: 5)
                    .overlay(
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .strokeBorder(Color.white.opacity(currentPage == index ? 0.14 : 0.04), lineWidth: 1)
                    )
                    .animation(.snappy(duration: 0.25), value: currentPage)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.035), in: Capsule())
        .overlay(
            Capsule()
                .strokeBorder(reportLine, lineWidth: 1)
        )
        .padding(.bottom, 8)
    }

    // MARK: - Summary Page

    private var summaryPage: some View {
        VStack(spacing: 14) {
            weekHeader
            completionRing
            keyStatsGrid
            volumeComparisonCard
            muscleBalanceCard
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
    }

    private var weekHeader: some View {
        VStack(alignment: .leading, spacing: 10) {
            let formatter = DateFormatter()
            let _ = formatter.dateFormat = "MMM d"
            HStack(spacing: 8) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(reportInk)
                    .frame(width: 26, height: 26)
                    .background(reportInk.opacity(0.10), in: .rect(cornerRadius: 8))
                Text("\(formatter.string(from: review.weekStartDate)) – \(formatter.string(from: review.weekEndDate))")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(STRQPalette.textSecondary)
                Spacer(minLength: 0)
            }

            Text(weeklyReviewText("weeklyReview.title", fallback: "Wochenrückblick"))
                .font(.system(.title, design: .rounded, weight: .bold))
                .foregroundStyle(STRQPalette.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.top, 12)
        .padding(16)
        .background(reportSurface, in: .rect(cornerRadius: 18))
        .overlay(alignment: .topLeading) {
            LinearGradient(
                colors: [reportInk.opacity(0.30), Color.clear],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
            .padding(.horizontal, 16)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(reportLine, lineWidth: 1)
        )
    }

    private var completionRing: some View {
        let completion = Double(review.summary.completedWorkouts) / Double(max(1, review.summary.plannedWorkouts))
        let ringColor: Color = completion >= 1.0 ? STRQPalette.success : completion >= 0.75 ? reportInk : STRQPalette.warning
        let display = weeklyTargetDisplay(completed: review.summary.completedWorkouts, target: review.summary.plannedWorkouts)

        return HStack(alignment: .center, spacing: 18) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [ringColor.opacity(0.16), Color.white.opacity(0.025), Color.clear],
                            center: .center,
                            startRadius: 18,
                            endRadius: 78
                        )
                    )
                    .frame(width: 148, height: 148)

                Circle()
                    .stroke(Color.white.opacity(0.065), lineWidth: 12)
                    .frame(width: 124, height: 124)

                Circle()
                    .trim(from: 0, to: appeared ? min(completion, 1.0) : 0)
                    .stroke(
                        AngularGradient(
                            colors: [ringColor, ringColor.opacity(0.6), ringColor],
                            center: .center
                        ),
                        style: StrokeStyle(lineWidth: 12, lineCap: .round)
                    )
                    .frame(width: 124, height: 124)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeOut(duration: 1.0).delay(0.3), value: appeared)

                VStack(spacing: 3) {
                    Text(display.primary)
                        .font(.system(size: 28, weight: .heavy, design: .rounded).monospacedDigit())
                        .foregroundStyle(STRQPalette.textPrimary)
                    Text(display.secondary)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(STRQPalette.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.72)
                }
            }
            .frame(width: 148, height: 148)

            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: "checkmark.seal.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(ringColor)
                    .frame(width: 28, height: 28)
                    .background(ringColor.opacity(0.12), in: .rect(cornerRadius: 8))

                Text(display.primary)
                    .font(.system(.title2, design: .rounded, weight: .bold).monospacedDigit())
                    .foregroundStyle(STRQPalette.textPrimary)
                Text(display.secondary)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(STRQPalette.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.72)

                if review.summary.streakDays > 0 {
                    HStack(spacing: 6) {
                        Image(systemName: "flame.fill")
                            .font(.caption)
                            .foregroundStyle(reportInk)
                        Text(streakLabel(review.summary.streakDays))
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(reportInk)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(reportInk.opacity(0.095), in: Capsule())
                    .overlay(
                        Capsule()
                            .strokeBorder(reportInk.opacity(0.14), lineWidth: 1)
                    )
                }
            }

            Spacer(minLength: 0)
        }
        .padding(16)
        .background(reportSurface, in: .rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(reportLine, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.18), radius: 14, y: 6)
    }

    private var keyStatsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            statTile(
                value: formatVolume(review.summary.totalVolume),
                label: weeklyReviewText("weeklyReview.stat.totalVolume", fallback: "Gesamtvolumen"),
                icon: "scalemass.fill",
                color: reportInk,
                trend: volumeTrend
            )
            statTile(
                value: "\(review.summary.totalSets)",
                label: weeklyReviewText("weeklyReview.stat.totalSets", fallback: "Sätze gesamt"),
                icon: "checkmark.circle.fill",
                color: reportSteel,
                trend: nil
            )
            statTile(
                value: "\(review.summary.averageDuration)m",
                label: weeklyReviewText("weeklyReview.stat.avgDuration", fallback: "Ø Dauer"),
                icon: "clock.fill",
                color: reportSteel,
                trend: nil
            )
            statTile(
                value: recoveryTrendLabel(review.summary.recoveryTrend),
                label: weeklyReviewText("weeklyReview.recovery.label", fallback: "Erholung"),
                icon: review.summary.recoveryTrend.icon,
                color: recoveryColor(review.summary.recoveryTrend),
                trend: nil
            )
        }
    }

    private var volumeTrend: String? {
        guard review.summary.previousWeekVolume > 0 else { return nil }
        let change = (review.summary.totalVolume - review.summary.previousWeekVolume) / review.summary.previousWeekVolume * 100
        if abs(change) < 3 { return nil }
        return change > 0 ? "+\(Int(change))%" : "\(Int(change))%"
    }

    private func statTile(value: String, label: String, icon: String, color: Color, trend: String?) -> some View {
        VStack(alignment: .leading, spacing: 11) {
            HStack(alignment: .center) {
                Image(systemName: icon)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(color)
                    .frame(width: 26, height: 26)
                    .background(color.opacity(0.11), in: .rect(cornerRadius: 8))
                Spacer()
                if let trend {
                    Text(trend)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundStyle(trend.hasPrefix("+") ? STRQPalette.success : STRQPalette.danger)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(
                            (trend.hasPrefix("+") ? STRQPalette.success : STRQPalette.danger).opacity(0.15),
                            in: Capsule()
                        )
                }
            }
            Text(value)
                .font(.system(.title3, design: .rounded, weight: .bold))
                .foregroundStyle(STRQPalette.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2.weight(.medium))
                .foregroundStyle(STRQPalette.textSecondary)
        }
        .padding(14)
        .frame(minHeight: 106, alignment: .topLeading)
        .background(Color.white.opacity(0.045), in: .rect(cornerRadius: 14))
        .overlay(alignment: .topLeading) {
            Rectangle()
                .fill(color.opacity(0.30))
                .frame(height: 1)
                .padding(.horizontal, 12)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(color.opacity(0.12), lineWidth: 1)
        )
    }

    private var volumeComparisonCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Image(systemName: "chart.bar.fill")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(reportInk)
                    .frame(width: 28, height: 28)
                    .background(reportInk.opacity(0.10), in: .rect(cornerRadius: 8))
                Text(weeklyReviewText("weeklyReview.volumeComparison", fallback: "Volumenvergleich"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(STRQPalette.textPrimary)
                Spacer()
                Text(weeklyReviewText("weeklyReview.vsLastWeek", fallback: "vs. Vorwoche"))
                    .font(.caption2)
                    .foregroundStyle(STRQPalette.textSecondary)
            }

            HStack(spacing: 16) {
                volumeBar(label: weeklyReviewText("weeklyReview.lastWeek", fallback: "Vorwoche"), value: review.summary.previousWeekVolume, maxValue: max(review.summary.totalVolume, review.summary.previousWeekVolume), color: Color.white.opacity(0.28))
                volumeBar(label: weeklyReviewText("weeklyReview.thisWeek", fallback: "Diese Woche"), value: review.summary.totalVolume, maxValue: max(review.summary.totalVolume, review.summary.previousWeekVolume), color: reportInk)
            }
            .frame(height: 98)
        }
        .padding(16)
        .background(Color.white.opacity(0.045), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(reportLine, lineWidth: 1)
        )
    }

    private func volumeBar(label: String, value: Double, maxValue: Double, color: Color) -> some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                VStack {
                    Spacer()
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.gradient)
                        .frame(height: maxValue > 0 ? geo.size.height * CGFloat(value / maxValue) : 0)
                        .overlay(alignment: .top) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(Color.white.opacity(0.22))
                                .frame(height: 1)
                                .padding(.horizontal, 5)
                        }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.white.opacity(0.035), in: .rect(cornerRadius: 8))
            }

            Text(formatVolume(value))
                .font(.caption2.weight(.bold).monospacedDigit())
                .foregroundStyle(STRQPalette.textPrimary)

            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(STRQPalette.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var muscleBalanceCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center) {
                Image(systemName: "scope")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(reportInk)
                    .frame(width: 28, height: 28)
                    .background(reportInk.opacity(0.10), in: .rect(cornerRadius: 8))
                Text(L10n.tr("Muscle Balance"))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(STRQPalette.textPrimary)
                Spacer()
                let score = Int(review.summary.muscleBalanceScore * 100)
                Text("\(score)%")
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundStyle(score >= 80 ? STRQPalette.success : score >= 60 ? reportInk : STRQPalette.warning)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background((score >= 80 ? STRQPalette.success : score >= 60 ? reportInk : STRQPalette.warning).opacity(0.10), in: Capsule())
            }

            if let ul = review.summary.upperLowerRatio {
                balanceBar(first: ul.upper, second: ul.lower, firstColor: Color.white.opacity(0.66), secondColor: reportInk.opacity(0.74))

                HStack {
                    Label("\(weeklyReviewText("weeklyReview.upper", fallback: "Oberkörper")) \(Int(ul.upper * 100))%", systemImage: "arrow.up")
                        .font(.caption2)
                        .foregroundStyle(.white)
                    Spacer()
                    Label("\(weeklyReviewText("weeklyReview.lower", fallback: "Unterkörper")) \(Int(ul.lower * 100))%", systemImage: "arrow.down")
                        .font(.caption2)
                        .foregroundStyle(STRQBrand.steel)
                }
            }

            if let pp = review.summary.pushPullRatio {
                HStack {
                    Label("Push \(Int(pp.push * 100))%", systemImage: "hand.point.right.fill")
                        .font(.caption2)
                        .foregroundStyle(reportInk)
                    Spacer()
                    Label("Pull \(Int(pp.pull * 100))%", systemImage: "hand.point.left.fill")
                        .font(.caption2)
                        .foregroundStyle(STRQBrand.slate)
                }
                balanceBar(first: pp.push, second: pp.pull, firstColor: reportInk.opacity(0.74), secondColor: STRQBrand.slate.opacity(0.78))
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.040), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(reportLine, lineWidth: 1)
        )
    }

    // MARK: - Highlights Page

    private var highlightsPage: some View {
        VStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles.rectangle.stack")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(reportInk)
                        .frame(width: 26, height: 26)
                        .background(reportInk.opacity(0.10), in: .rect(cornerRadius: 8))
                    Text(weeklyReviewText("weeklyReview.highlights", fallback: "Signale"))
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(STRQPalette.textPrimary)
                    Spacer(minLength: 0)
                }
                Text(weeklyReviewText("weeklyReview.highlightsSubtitle", fallback: "Was gut lief und was Aufmerksamkeit braucht"))
                    .font(.subheadline)
                    .foregroundStyle(STRQPalette.textSecondary)
            }
            .padding(.top, 12)
            .padding(16)
            .background(reportSurface, in: .rect(cornerRadius: 18))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(reportLine, lineWidth: 1)
            )

            if !review.wins.isEmpty {
                winsSection
            }
            if !review.areasToImprove.isEmpty {
                areasSection
            }

            if let bw = review.summary.bodyweightChange {
                bodyweightCard(change: bw)
            }

            if review.summary.personalRecordsCount > 0 {
                prCelebrationCard
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }

    private var winsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Label(weeklyReviewText("weeklyReview.wins", fallback: "Stark"), systemImage: "star.fill")
                    .font(.headline)
                    .foregroundStyle(STRQPalette.success)
                Spacer(minLength: 0)
            }

            ForEach(review.wins) { win in
                highlightRow(win)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.040), in: .rect(cornerRadius: 16))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(STRQPalette.success.opacity(0.58))
                .frame(width: 3)
                .padding(.vertical, 14)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(STRQPalette.success.opacity(0.13), lineWidth: 1)
        }
    }

    private var areasSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Label(weeklyReviewText("weeklyReview.areas", fallback: "Im Blick behalten"), systemImage: "arrow.up.right")
                    .font(.headline)
                    .foregroundStyle(STRQPalette.warning)
                Spacer(minLength: 0)
            }

            ForEach(review.areasToImprove) { area in
                highlightRow(area)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.036), in: .rect(cornerRadius: 16))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(STRQPalette.warning.opacity(0.44))
                .frame(width: 3)
                .padding(.vertical, 14)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(STRQPalette.warning.opacity(0.12), lineWidth: 1)
        }
    }

    private func highlightRow(_ item: ReviewHighlight) -> some View {
        let color = highlightColor(item.color)

        return HStack(alignment: .top, spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(color.opacity(0.13))
                    .frame(width: 32, height: 32)
                Image(systemName: item.icon)
                    .font(.caption)
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(displayHighlightTitle(item))
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(STRQPalette.textPrimary)
                Text(displayHighlightDetail(item))
                    .font(.caption)
                    .foregroundStyle(STRQPalette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .background(Color.white.opacity(0.034), in: .rect(cornerRadius: 12))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color.opacity(0.42))
                .frame(width: 2)
                .padding(.vertical, 10)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .strokeBorder(color.opacity(0.10), lineWidth: 1)
        )
    }

    private func bodyweightCard(change: Double) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(STRQBrand.steel.opacity(0.12))
                    .frame(width: 44, height: 44)
                Image(systemName: change > 0 ? "arrow.up" : change < 0 ? "arrow.down" : "equal")
                    .font(.body.weight(.semibold))
                    .foregroundStyle(STRQBrand.steel)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(weeklyReviewText("weeklyReview.bodyweightTrend", fallback: "Gewichtstrend"))
                    .font(.subheadline.weight(.semibold))
                Text("\(change > 0 ? "+" : "")\(String(format: "%.1f", change))kg \(weeklyReviewText("weeklyReview.vsLastWeek", fallback: "vs. Vorwoche"))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.05), in: .rect(cornerRadius: 16))
    }

    private var prCelebrationCard: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        LinearGradient(
                            colors: [.yellow, STRQBrand.steel],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                Image(systemName: "trophy.fill")
                    .font(.body)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                let prLabel = review.summary.personalRecordsCount == 1
                    ? L10n.format("%d neuer PR", review.summary.personalRecordsCount)
                    : L10n.format("%d neue PRs", review.summary.personalRecordsCount)
                Text(prLabel)
                    .font(.subheadline.weight(.bold))
                Text(weeklyReviewText("weeklyReview.prCelebrationDetail", fallback: "Neue Bestleistung gespeichert."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(16)
        .background(STRQPalette.warning.opacity(0.06), in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(STRQPalette.warning.opacity(0.12), lineWidth: 1)
        }
    }

    // MARK: - Coach Page

    private var coachPage: some View {
        VStack(spacing: 14) {
            coachConclusionSection
            actionsSection
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 40)
    }

    private var coachConclusionSection: some View {
        let tone = review.coachConclusion.tone
        let color = conclusionColor(tone)

        return VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(color.opacity(0.13))
                    Image(systemName: tone.icon)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(color)
                }
                .frame(width: 54, height: 54)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(color.opacity(0.18), lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 7) {
                    Text(weeklyReviewText("weeklyReview.coachTake", fallback: "Coach-Einschätzung"))
                        .font(.caption.weight(.bold))
                        .foregroundStyle(color)
                        .tracking(0.5)

                    Text(displayConclusionHeadline(review.coachConclusion))
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(STRQPalette.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            Text(displayConclusionMessage(review.coachConclusion))
                .font(.subheadline)
                .foregroundStyle(STRQPalette.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .background(reportSurface, in: .rect(cornerRadius: 20))
        .overlay(alignment: .leading) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color.opacity(0.50))
                .frame(width: 3)
                .padding(.vertical, 18)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 20)
                .stroke(color.opacity(0.14), lineWidth: 1)
        }
    }

    private var actionsSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.branch")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(reportInk)
                    .frame(width: 28, height: 28)
                    .background(reportInk.opacity(0.10), in: .rect(cornerRadius: 8))
                Text(weeklyReviewText("weeklyReview.nextSteps", fallback: "Nächste Schritte"))
                    .font(.headline)
                    .foregroundStyle(STRQPalette.textPrimary)
                Spacer(minLength: 0)
            }

            ForEach(review.suggestedActions) { action in
                actionRow(action)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.034), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .strokeBorder(reportLine, lineWidth: 1)
        )
    }

    private func actionRow(_ action: ReviewAction) -> some View {
        let isPrimary = action.isPrimary
        let actionAccent = isPrimary ? reportInk : Color.white.opacity(0.62)

        return Button {
            selectedAction = action
            showConfirmation = true
        } label: {
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(isPrimary ? reportInk.opacity(0.13) : Color.white.opacity(0.060))
                    Image(systemName: action.icon)
                        .font(.body.weight(.semibold))
                        .foregroundStyle(actionAccent)
                }
                .frame(width: 42, height: 42)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(actionAccent.opacity(isPrimary ? 0.18 : 0.10), lineWidth: 1)
                )

                VStack(alignment: .leading, spacing: 3) {
                    Text(displayActionLabel(action))
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(STRQPalette.textPrimary)
                    Text(displayActionDescription(action))
                        .font(.caption)
                        .foregroundStyle(STRQPalette.textSecondary)
                        .lineLimit(2)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 0)

                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(actionAccent.opacity(0.72))
                    .frame(width: 24, height: 24)
                    .background(Color.white.opacity(0.035), in: Circle())
            }
            .padding(14)
            .background(
                isPrimary ? reportInk.opacity(0.060) : Color.white.opacity(0.032),
                in: .rect(cornerRadius: 14)
            )
            .overlay(alignment: .leading) {
                if isPrimary {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(reportInk.opacity(0.62))
                        .frame(width: 3)
                        .padding(.vertical, 12)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(actionAccent.opacity(isPrimary ? 0.16 : 0.08), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(flexibility: .soft, intensity: 0.4), trigger: showConfirmation)
        .confirmationDialog(
            L10n.format(
                "weeklyReview.applyDialogTitle",
                fallback: "Anwenden: %@",
                selectedAction.map(displayActionLabel) ?? ""
            ),
            isPresented: $showConfirmation,
            titleVisibility: .visible
        ) {
            if let selected = selectedAction {
                Button(displayActionLabel(selected)) {
                    withAnimation(.snappy(duration: 0.3)) {
                        vm.applyReviewAction(selected)
                    }
                }
                Button(L10n.tr("Cancel"), role: .cancel) {}
            }
        } message: {
            if let selected = selectedAction {
                Text(displayActionDescription(selected))
            }
        }
    }

    // MARK: - Helpers

    private func weeklyReviewText(_ key: String, fallback: String) -> String {
        let localized = L10n.tr(key, fallback: fallback)
        return localized == key ? fallback : localized
    }

    private func isText(_ value: String, _ parts: String...) -> Bool {
        value == parts.joined()
    }

    private func containsText(_ value: String, _ parts: String...) -> Bool {
        value.contains(parts.joined())
    }

    private func targetReachedHighlightDetail() -> String {
        let completed = max(0, review.summary.completedWorkouts)
        let target = review.summary.plannedWorkouts
        guard target > 0 else { return "Ziel erreicht." }
        guard completed > target else { return "Ziel erreicht." }
        return "Ziel erreicht. +\(completed - target) zusätzlich, \(completed) gesamt."
    }

    private func displayHighlightTitle(_ item: ReviewHighlight) -> String {
        let title = item.title

        if isText(title, "More ", "Than Planned") { return "Mehr als geplant" }
        if isText(title, "Weekly ", "Target Reached") { return "Wochenziel erreicht" }
        if isText(title, "Strong ", "Week") { return "Starke Woche" }
        if isText(title, "Volume ", "Increased") { return "Volumen gestiegen" }
        if isText(title, "Volume ", "Spike") { return "Volumen stark gestiegen" }
        if isText(title, "Volume ", "Drop") { return "Volumen gesunken" }
        if isText(title, "Recovery ", "Low") { return "Erholung niedrig" }
        if isText(title, "Recovery ", "Declining") { return "Erholung sinkt" }
        if isText(title, "Recovery ", "Stable") { return "Erholung stabil" }
        if isText(title, "Recovery ", "Improving") { return "Erholung steigt" }
        if isText(title, "Focus ", "Muscles On Track") { return "Fokusmuskeln im Plan" }
        if isText(title, "Push-", "Heavy Balance") { return "Push dominiert" }
        if isText(title, "Pull-", "Heavy Balance") { return "Pull dominiert" }

        if title.hasSuffix("-Day Streak"), let firstPart = title.split(separator: "-").first, let days = Int(firstPart) {
            return streakLabel(days)
        }

        if containsText(title, "Personal ", "Record") {
            return review.summary.personalRecordsCount == 1
                ? "1 neuer PR"
                : "\(review.summary.personalRecordsCount) neue PRs"
        }

        if containsText(title, "Missed ", "Workout") {
            let missed = max(0, review.summary.plannedWorkouts - review.summary.completedWorkouts)
            return missed == 1 ? "1 Einheit offen" : "\(missed) Einheiten offen"
        }

        if containsText(title, "Volume ", "Low") {
            let muscleName = title
                .replacingOccurrences(of: " Volume Low", with: "")
                .replacingOccurrences(of: "Volume Low", with: "")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            let localizedMuscle = MuscleGroup.localizedDisplayName(forDisplayName: muscleName)
            return localizedMuscle.isEmpty ? "Volumen niedrig" : "\(localizedMuscle): Volumen niedrig"
        }

        if title.hasSuffix(" Volumen niedrig"), !title.hasSuffix(": Volumen niedrig") {
            let muscleName = String(title.dropLast(" Volumen niedrig".count))
            return "\(muscleName): Volumen niedrig"
        }

        return title
    }

    private func displayHighlightDetail(_ item: ReviewHighlight) -> String {
        let title = item.title
        let detail = item.detail

        if isText(title, "More ", "Than Planned") || isText(title, "Weekly ", "Target Reached") {
            return targetReachedHighlightDetail()
        }

        if isText(title, "Strong ", "Week") {
            return "\(review.summary.completedWorkouts)/\(review.summary.plannedWorkouts) Einheiten abgeschlossen. Der Rhythmus passt."
        }

        if containsText(title, "Personal ", "Record") || title == "1 neuer PR" || title.hasSuffix("neue PRs") {
            return "Neue Bestleistung gespeichert."
        }

        if title.hasSuffix("-Day Streak") {
            return "Konstanz sichtbar. Halte den Rhythmus."
        }

        if isText(title, "Recovery ", "Stable") {
            return "Belastung und Erholung wirken im Rahmen."
        }

        if isText(title, "Recovery ", "Improving") {
            return "Das Erholungssignal verbessert sich."
        }

        if containsText(title, "Recovery") || containsText(detail, "fatigue") || containsText(detail, "Your ", "body") {
            return "Erholung war niedrig. Nächste Woche ruhiger planen."
        }

        if containsText(detail, "You hit") || containsText(detail, "planned ", "workouts") {
            return targetReachedHighlightDetail()
        }

        if containsText(detail, "current ", "training load") {
            return "Belastung und Erholung wirken im Rahmen."
        }

        if containsText(detail, "Progressive ", "overload") {
            return "Gesamtvolumen liegt über der Vorwoche."
        }

        if containsText(detail, "Sharp ", "increases") || containsText(detail, "Volume ", "jumped") {
            return "Volumen stark gestiegen. Nächste Woche dosiert halten."
        }

        if containsText(detail, "Volume ", "decreased") {
            return "Volumen unter der Vorwoche. Prüfe, ob das geplant war."
        }

        if containsText(detail, "Try ", "to stay consistent") {
            return "\(review.summary.completedWorkouts)/\(review.summary.plannedWorkouts) geplante Einheiten abgeschlossen."
        }

        if containsText(detail, "Prioritize ", "it next") {
            return "Nächste Woche gezielt ruhiger ausgleichen."
        }

        if containsText(detail, "shoulder ", "health") {
            return "Etwas mehr Pull einplanen."
        }

        if containsText(detail, "pressing ", "movements") {
            return "Etwas mehr Push einplanen."
        }

        return detail
    }

    private func displayConclusionHeadline(_ conclusion: CoachConclusion) -> String {
        if conclusion.tone == .urgent { return "Erholung braucht Fokus" }
        if isText(conclusion.headline, "Good ", "Work, But Watch Fatigue") { return "Starke Arbeit, Erholung im Blick" }
        if isText(conclusion.headline, "Target ", "Reached") { return "Wochenziel erreicht" }
        if isText(conclusion.headline, "Outstanding ", "Week") { return "Sehr starke Woche" }
        if isText(conclusion.headline, "Solid ", "Week Overall") { return "Solide Woche" }
        if isText(conclusion.headline, "Let's ", "Get Back on Track") { return "Rhythmus wieder aufnehmen" }
        if isText(conclusion.headline, "Keep ", "Building") { return "Weiter aufbauen" }
        return conclusion.headline
    }

    private func displayConclusionMessage(_ conclusion: CoachConclusion) -> String {
        if conclusion.tone == .urgent {
            return "Die Belastung war hoch. Plane die nächste Woche ruhiger."
        }

        let message = conclusion.message
        if containsText(message, "fatigue") || containsText(message, "recovery ", "is trending down") {
            return "Erholung war niedrig. Nächste Woche ruhiger planen."
        }
        if containsText(message, "All ", "sessions completed") {
            return "Alle Einheiten abgeschlossen. Konstanz sichtbar."
        }
        if containsText(message, "Your ", "plan is working") || containsText(message, "current ", "plan") {
            return "Aktuelle Struktur beibehalten."
        }
        if containsText(message, "room ", "for improvement") {
            return "Solide Basis mit Luft nach oben. Nächste Woche zählt ein konstanterer Trainingsrhythmus."
        }
        if containsText(message, "lighter ", "than planned") {
            return "Diese Woche war leichter als geplant. Nächste Woche zählt zuerst der Einstieg."
        }
        return message
    }

    private func displayActionLabel(_ action: ReviewAction) -> String {
        switch action.type {
        case .deloadWeek: return "Deload-Woche starten"
        case .regenerateWeek: return "Nächste Woche neu planen"
        case .reduceVolume: return "Volumen senken"
        case .keepAsIs: return "Woche beibehalten"
        case .rebalancePlan: return "Verteilung anpassen"
        case .increaseFrequency: return "Frequenz anpassen"
        }
    }

    private func displayActionDescription(_ action: ReviewAction) -> String {
        switch action.type {
        case .deloadWeek:
            return "Volumen und Intensität bewusst reduzieren."
        case .regenerateWeek:
            return "Woche neu aufbauen, damit Balance und Erholung besser zusammenpassen."
        case .reduceVolume:
            return "Nebenübungen etwas reduzieren und Hauptübungen stabil halten."
        case .keepAsIs:
            if review.summary.plannedWorkouts > 0 && review.summary.completedWorkouts > review.summary.plannedWorkouts {
                return "Ziel erreicht. +\(review.summary.completedWorkouts - review.summary.plannedWorkouts) zusätzlich, \(review.summary.completedWorkouts) gesamt."
            }
            return "Aktuelle Struktur beibehalten."
        case .rebalancePlan:
            return "Übungsauswahl und Volumen ruhiger zwischen Muskelgruppen verteilen."
        case .increaseFrequency:
            return "Plan an deine echte Verfügbarkeit anpassen."
        }
    }

    private func streakLabel(_ days: Int) -> String {
        days == 1
            ? L10n.format("%d Tag am Stück", days)
            : L10n.format("%d Tage am Stück", days)
    }

    private func recoveryTrendLabel(_ trend: RecoveryTrend) -> String {
        switch trend {
        case .improving: return L10n.tr("weeklyReview.recovery.improving", fallback: "Steigend")
        case .stable: return L10n.tr("weeklyReview.recovery.stable", fallback: "Stabil")
        case .declining: return L10n.tr("weeklyReview.recovery.declining", fallback: "Sinkend")
        case .critical: return L10n.tr("weeklyReview.recovery.low", fallback: "Niedrig")
        }
    }

    private func balanceBar(first: Double, second: Double, firstColor: Color, secondColor: Color) -> some View {
        let safeFirst = max(0, first)
        let safeSecond = max(0, second)
        let total = max(0.01, safeFirst + safeSecond)

        return GeometryReader { geo in
            let availableWidth = max(0, geo.size.width - 2)
            HStack(spacing: 2) {
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(firstColor)
                    .frame(width: availableWidth * CGFloat(safeFirst / total))
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .fill(secondColor)
                    .frame(width: availableWidth * CGFloat(safeSecond / total))
            }
            .frame(maxHeight: .infinity)
            .background(Color.white.opacity(0.035), in: .rect(cornerRadius: 5))
        }
        .frame(height: 10)
    }

    private func formatVolume(_ v: Double) -> String {
        if v >= 1000 {
            return String(format: "%.1fk", v / 1000)
        }
        return String(format: "%.0f", v)
    }

    private func highlightColor(_ name: String) -> Color {
        switch name {
        case "green": return STRQPalette.success
        case "yellow": return STRQPalette.warning
        case "orange": return STRQPalette.warning
        case "red": return STRQPalette.danger
        case "blue": return STRQPalette.info
        case "purple": return STRQBrand.slate
        case "gold": return STRQPalette.gold
        default: return STRQBrand.steel
        }
    }

    private func recoveryColor(_ trend: RecoveryTrend) -> Color {
        switch trend {
        case .improving: return STRQPalette.success
        case .stable: return STRQBrand.steel
        case .declining: return STRQPalette.warning
        case .critical: return STRQPalette.danger
        }
    }

    private func conclusionColor(_ tone: ConclusionTone) -> Color {
        switch tone {
        case .positive: return STRQPalette.success
        case .encouraging: return STRQBrand.steel
        case .cautious: return STRQPalette.warning
        case .urgent: return STRQPalette.danger
        }
    }

    private func recoveryTrendColor(_ trend: RecoveryTrend) -> Color {
        switch trend {
        case .improving: return STRQPalette.success
        case .stable: return STRQBrand.steel
        case .declining: return STRQPalette.warning
        case .critical: return STRQPalette.danger
        }
    }
}
