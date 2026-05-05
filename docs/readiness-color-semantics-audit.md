# Readiness Color Semantics Audit

## 1. Executive summary

Rork QA found a real semantic mismatch in the redesigned CoachTab authority hero: score `58` displays `Moderate`, but the ring/status color is danger-like pink/red. The issue is not the hero shell itself. It comes from two threshold systems disagreeing:

- `readinessBasedRecoveryStatus` says `55..<70` is `Moderate`.
- `ForgeTheme.recoveryColor(for:)` delegates to `STRQPalette.recovery(for:)`, which says every score below `60` is `danger`.

That makes `55...59` read as moderate in copy but emergency/caution in color. The `58` state is therefore visually harsher than the product meaning.

The recommended next path is **C. new dedicated readiness color resolver**, implemented first as a CoachTab authorityHero-only readiness resolver. Do not change `STRQPalette.recovery(for:)` globally yet. The global resolver is used by Dashboard, Progress, Profile, and Physique surfaces, while other readiness/recovery UI uses local parallel thresholds. A global color change would need broader Rork QA and would not automatically fix every local threshold.

## 2. Current status thresholds

CoachTab authorityHero status comes from `vm.readinessBasedRecoveryStatus` in `AppViewModel`.

`vm.effectiveRecoveryScore` is:

- `(recoveryScore + todaysReadiness.readinessScore) / 2` when today's readiness exists.
- `recoveryScore` when no readiness has been logged today.

Current authority/status labels:

| Score | Status |
|---:|---|
| `85...100` | `Peak Readiness` |
| `70..<85` | `Well Prepared` |
| `55..<70` | `Moderate` |
| `40..<55` | `Low Energy` |
| `0..<40` | `Rest Needed` |

Related model note: `DailyReadiness.readinessLabel` uses the same top three bands, but its lower-copy labels differ:

| Score | DailyReadiness label |
|---:|---|
| `85...100` | `Peak Readiness` |
| `70..<85` | `Well Prepared` |
| `55..<70` | `Moderate` |
| `40..<55` | `Low Readiness` |
| `0..<40` | `Rest Recommended` |

That model also exposes `readinessColorName` with thresholds closer to the desired traffic-light model: mint/green/yellow/orange/red by the same 85/70/55/40 breaks. It is separate from the CoachTab authorityHero color path.

## 3. Current color thresholds

CoachTab authorityHero currently derives:

- `let color = ForgeTheme.recoveryColor(for: score)`
- `ForgeTheme.recoveryColor(for:)` returns `STRQPalette.recovery(for: score)`

Current shared recovery color thresholds:

| Score | Color token | Visual meaning |
|---:|---|---|
| `80...100` | `STRQPalette.success` / `signalGreen` | green, good |
| `60..<80` | `STRQPalette.warning` / `warningAmber` | amber, caution/moderate |
| `0..<60` | `STRQPalette.danger` / `dangerRed` | pink-red, danger |

Token values inspected:

- `STRQPalette.success` = `signalGreen`, `Color(red: 0.290, green: 0.871, blue: 0.502)`
- `STRQPalette.warning` = `warningAmber`, `Color(red: 1.0, green: 0.722, blue: 0.290)`
- `STRQPalette.danger` = `dangerRed`, `Color(red: 1.0, green: 0.302, blue: 0.427)`

Important parallel mappings:

- `SleepLogView` uses local raw `.green/.yellow/.red` thresholds at `80/60`.
- `BodyWeightLogView` uses local raw `.green/.yellow/.red` thresholds at `80/60`.
- `PreWorkoutHandoffView` uses local `STRQPalette.success/warning/danger` thresholds at `80/60`.
- `ReadinessCheckInView` result uses `DailyReadiness.readinessColorName` through `ForgeTheme.color(for:)`, not `STRQPalette.recovery(for:)`.

## 4. Mismatch findings

| Score | Current status | Current color | Finding |
|---:|---|---|---|
| `90` | `Peak Readiness` | success green | Correct. High readiness reads good to train. |
| `58` | `Moderate` | danger pink/red | Mismatch. `58` is inside the `Moderate` status band but below the `60` color cutoff, so it inherits `STRQPalette.danger`. |
| `48` | `Low Energy` | danger pink/red | Broadly aligned, but this band should probably read as caution/warm danger rather than identical to rest-needed severity. |
| `32` / `28` / `17` | `Rest Needed` | danger pink/red | Correct direction. Very low readiness should be clear caution/rest-needed. |

Secondary mismatch:

- Scores `70..<80` display `Well Prepared` but use warning amber under the global recovery color resolver. Product direction says `Well Prepared` should feel success or muted green, not controlled/moderate.
- Scores `80..<85` display `Well Prepared` and use success green, so that sub-band already aligns visually.
- Scores `60..<70` display `Moderate` and use warning amber, which aligns with the desired traffic-light model.
- Scores `55..<60` display `Moderate` and use danger pink/red, which is the highest-priority defect from Rork QA.

Why `58 Moderate` appears pink/red:

1. CoachTab authorityHero asks `AppViewModel` for `readinessBasedRecoveryStatus`.
2. `AppViewModel` maps `58` to `Moderate` because `58` is in `55..<70`.
3. CoachTab authorityHero asks `ForgeTheme.recoveryColor(for: 58)`.
4. `ForgeTheme.recoveryColor` delegates to `STRQPalette.recovery(for: 58)`.
5. `STRQPalette.recovery(for:)` maps every score below `60` to `STRQPalette.danger`.
6. `STRQPalette.danger` is a pink-red danger color, so the ring, status dot, status text, and glow communicate stronger risk than the label.

## 5. Usage map

Direct shared recovery color usage:

| File | Usage | Risk if global thresholds change |
|---|---|---|
| `ios/STRQ/Views/CoachTabView.swift` | authorityHero ring/status color from `ForgeTheme.recoveryColor(for: vm.effectiveRecoveryScore)` | High visible impact; current Rork issue lives here. |
| `ios/STRQ/Views/DashboardView.swift` | Today hero accent from today's readiness score, readiness badge color, recovery metric tint | High; Today surface would change alongside CoachTab. |
| `ios/STRQ/Views/ProgressAnalyticsView.swift` | recovery signal pill color in early and established signal strips | Medium; analytics context may be okay, but needs visual QA. |
| `ios/STRQ/Views/ProfileView.swift` | fitness identity recovery metric color | Medium; Profile already has accepted shell direction and should not be changed accidentally. |
| `ios/STRQ/Views/PhysiqueVerdictCard.swift` | recovery metric tint through `STRQPalette.recovery(for:)` | Medium; physiology/nutrition interpretation may need its own semantics. |
| `ios/STRQ/Utilities/ForgeTheme.swift` | shared wrapper delegates to `STRQPalette.recovery(for:)` | High; changing it affects every `ForgeTheme.recoveryColor` caller. |
| `ios/STRQ/Utilities/STRQPalette.swift` | source shared recovery thresholds | High; global semantic foundation. |

Parallel visual recovery/readiness mappings:

| File | Mapping | Note |
|---|---|---|
| `ios/STRQ/Views/SleepLogView.swift` | local `.green/.yellow/.red` at `80/60` | Would not change if `STRQPalette.recovery` changes. |
| `ios/STRQ/Views/BodyWeightLogView.swift` | local `.green/.yellow/.red` at `80/60` | Would not change if `STRQPalette.recovery` changes. |
| `ios/STRQ/Views/PreWorkoutHandoffView.swift` | local success/warning/danger at `80/60` | Training handoff semantics should be audited separately before changes. |
| `ios/STRQ/Views/ReadinessCheckInView.swift` | `DailyReadiness.readinessColorName` via `ForgeTheme.color(for:)` | Uses 85/70/55/40 bands, but `orange` currently maps to energy accent. |

State/status usage:

| Symbol | Main usage |
|---|---|
| `readinessBasedRecoveryStatus` | CoachTab authorityHero status, SleepLogView status, ReminderWidgetCoordinator label. |
| `effectiveRecoveryScore` | CoachTab, Dashboard, Progress, Profile, physique/nutrition display, sleep/bodyweight display, daily briefing input, reminder widget, coaching/physique services. |
| `recoveryScore` | Core training, plan, progression, weekly review, coaching, and nutrition engines. Most occurrences are behavior inputs, not visual colors. |

## 6. Risk of global color changes

Changing `STRQPalette.recovery(for:)` globally is not safe as the immediate next implementation because:

- It would change CoachTab, Dashboard, ProgressAnalytics, Profile, and PhysiqueVerdict at once.
- It would not change local threshold implementations in SleepLogView, BodyWeightLogView, or PreWorkoutHandoffView.
- It could make previously accepted Profile or dashboard surfaces change visual semantics without targeted QA.
- It would mix two product questions: the immediate CoachTab hero defect and a broader app-wide recovery/readiness semantic system.
- Some service logic uses `recoveryScore` thresholds for behavior, but those are not color calls and should not be touched by a visual color fix.

The global mapping may ultimately need a product-level alignment pass, but the first fix should isolate the CoachTab authorityHero problem and validate the premium traffic-light model where the defect was observed.

## 7. Recommended color semantics

Recommended premium traffic-light semantics:

| Score | Status | Recommended color meaning | Suggested treatment |
|---:|---|---|---|
| `85...100` | `Peak Readiness` | success green | Clear green, localized to ring/status only. |
| `70..<85` | `Well Prepared` | success or muted green | Green family, less celebratory than peak if differentiated. Do not use amber. |
| `55..<70` | `Moderate` | warning amber | Controlled/caution state. Must not be pink/red. |
| `40..<55` | `Low Energy` | danger-warm or caution red | Lower-energy caution. Can be red-family, but should feel less final than rest-needed if feasible. |
| `0..<40` | `Rest Needed` | danger red/pink | Strong caution/rest-needed. Pink-red is acceptable here. |

Style guardrails:

- Keep the hero shell neutral/carbon.
- Keep semantic color localized to ring, status dot/text, and subtle glow.
- Do not fill the whole hero green, amber, or red.
- Do not use childish stoplight saturation.
- Use amber for moderate/control, not emergency red.
- Allow red/pink for low/rest-needed, especially below `40`.

## 8. Recommended next path

Recommended next path: **C. new dedicated readiness color resolver**.

Implement it first as a CoachTab authorityHero-specific resolver, not a global palette change. This gives the observed Rork issue a focused fix, lets `58 Moderate` become warning amber immediately, and avoids changing Dashboard, Progress, Profile, PhysiqueVerdict, SleepLog, BodyWeightLog, or PreWorkoutHandoff semantics before they are audited as a set.

Rejected options:

- A. local CoachTab authorityHero color mapping only: close, but an unnamed/ad hoc inline mapping would hide a product semantic rule inside view layout. A dedicated resolver is clearer and easier to QA.
- B. global `STRQPalette.recovery` threshold change: too broad for the immediate fix and would leave local 80/60 mappings unchanged elsewhere.
- D. no change: not acceptable because Rork already found `Moderate` reading as danger.

## 9. Suggested implementation prompt

```text
Goal:
Implement only a local CoachTab authorityHero readiness color semantics fix. Do not modify global palette/theme files or any app behavior.

Context:
Rork QA showed score 58 displays "Moderate" but uses danger-like pink/red because `readinessBasedRecoveryStatus` maps 55..<70 to Moderate while `STRQPalette.recovery(for:)` maps scores below 60 to danger. Moderate must read as controlled/amber, not danger.

Allowed edits:
- ios/STRQ/Views/CoachTabView.swift
- docs/migration-progress-log.md

Do not edit:
- STRQPalette.swift
- ForgeTheme.swift
- STRQDesignSystem.swift
- ReadinessCheckInView.swift
- DashboardView.swift
- ProfileView.swift
- ProgressAnalyticsView.swift
- PhysiqueVerdictCard.swift
- AppViewModel.swift
- Models
- Services
- Assets
- Localizable.xcstrings
- Widget/Watch/Live Activity
- project files
- tests

Implementation:
1. Inspect `private var authorityHero` and confirm it currently uses:
   - `score = vm.effectiveRecoveryScore`
   - `phase = vm.currentPhase`
   - `status = vm.readinessBasedRecoveryStatus`
   - Check in visibility/action unchanged
   - `STRQCountUpText(value: Double(score), duration: 0.75)`
   - ring trim `CGFloat(score) / 100`
   - Reduce Motion-aware animation
2. Add a dedicated CoachTab-only readiness color resolver in `CoachTabView.swift`, scoped near authorityHero, for hero visual color only.
3. Use the resolver for authorityHero ring/status color instead of `ForgeTheme.recoveryColor(for: score)`.
4. Preserve all score/status/phase/headline/week/check-in/action/sheet/analytics/model/service behavior.
5. Do not change status copy or thresholds.

Resolver semantics:
- `85...100`: `STRQPalette.success`
- `70..<85`: success or restrained muted green
- `55..<70`: `STRQPalette.warning`
- `40..<55`: warm caution red or restrained danger treatment
- `0..<40`: `STRQPalette.danger`

Acceptance:
- Score 58 / Moderate is amber/warning, not pink/red.
- Score 90 / Peak Readiness stays green.
- Score 48 / Low Energy remains caution/danger, visually distinct from Moderate if possible.
- Scores 32, 28, and 17 / Rest Needed remain red/pink danger.
- No global color resolver changes.
- No behavior changes.

Verification:
- git status --short --branch
- git diff --name-only
- git diff -- ios/STRQ/Views/CoachTabView.swift docs/migration-progress-log.md
- git diff --name-only -- ios/STRQ/Utilities ios/STRQ/ViewModels ios/STRQ/Services ios/STRQ/Models ios/STRQ/Views/ReadinessCheckInView.swift ios/STRQ/Views/DashboardView.swift ios/STRQ/Views/ProfileView.swift ios/STRQ/Views/ProgressAnalyticsView.swift ios/STRQWidget ios/STRQWatch
- rg -n "private var authorityHero|readinessBasedRecoveryStatus|effectiveRecoveryScore|STRQCountUpText|CGFloat\\(score\\) / 100|hasCheckedInToday|showReadinessCheckIn|ForgeTheme\\.recoveryColor|STRQPalette\\.recovery|STRQPalette\\.warning|STRQPalette\\.danger|STRQPalette\\.success" ios/STRQ/Views/CoachTabView.swift
- rg -n "STRQPalette\\.recovery|static func recovery|recoveryColor\\(for" ios/STRQ/Utilities ios/STRQ/Views

Rork QA:
- Capture CoachTab authorityHero at scores 90, 75, 58, 48, 32, 28, and 17.
- Capture checked-in and not-checked-in states.
- Confirm Moderate is amber/controlled and no longer danger-like.
- Confirm low/rest-needed states still read caution/rest-needed.
```

## 10. Rork QA checklist

- Score `90`: `Peak Readiness`, green, not celebratory or full-card green.
- Score `75`: `Well Prepared`, green/muted green, not amber.
- Score `58`: `Moderate`, amber/warning, not pink/red.
- Score `48`: `Low Energy`, caution/danger-warm, clearly lower than Moderate.
- Score `32`: `Rest Needed`, red/pink danger.
- Score `28`: `Rest Needed`, red/pink danger.
- Score `17`: `Rest Needed`, red/pink danger.
- Checked-in state: Check in action hidden; color semantics still clear.
- Not-checked-in state: Check in action visible; color semantics still clear.
- Small iPhone: ring/status/headline do not crowd or clip.
- Reduce Motion on: visual state remains readable without relying on animation.
- Dashboard/Profile/Progress/ReadinessCheckIn remain unchanged in this first fix.
