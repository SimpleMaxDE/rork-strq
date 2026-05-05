# Coach Authority Hero Risk Plan

## 1. Executive summary

`authorityHero` is the top decision surface of CoachTab. It is the first place the user sees readiness/recovery score, coach status, daily priority, phase, week count, and the readiness Check in action.

It should become STRQ's daily coach command center, not a generic metric card. The goal is one clear state plus one clear next decision, backed by readiness and phase context.

This surface is behavior-sensitive and should not be implemented without state mapping. The hero is visually compact, but it connects to score calculation, semantic recovery color, headline priority, phase state, check-in visibility, sheet routing, Reduce Motion behavior, and appearance timing.

This pass makes no Swift changes. It creates only a planning document and a migration-log entry.

Future implementation should be shell-only and preserve Check in behavior exactly. It should not redesign `ReadinessCheckInView`, `primaryMoveCard`, `coachPrimaryCTA`, workout handoff, daily briefing logic, or any model/view-model/service path in the same pass.

Figma note: @Figma was not used in this pass. No specific file or node was provided, and the plan can be grounded safely in the existing STRQ docs plus broad pattern categories only: intelligent coach hero, readiness/state dashboard, training command center, recovery score module, premium dark hero cards, asymmetrical status modules, decision-first layouts, calm CTA/status composition, and ring/dial alternatives.

## 2. Current implementation inventory

Target file:

- `ios/STRQ/Views/CoachTabView.swift`

Target helper:

- `private var authorityHero`

Inputs and local derivations:

- `score = vm.effectiveRecoveryScore`
- `color = ForgeTheme.recoveryColor(for: score)`
- `phase = vm.currentPhase`
- `status = vm.readinessBasedRecoveryStatus`
- `headline`
- `vm.trainingPhaseState.weeksInPhase`
- `vm.hasCheckedInToday`
- `showReadinessCheckIn`
- `appeared`
- `reduceMotion`

Headline priority:

1. `vm.dailyBriefing?.primary.title`
2. `vm.earlyStateGuidance?.headline`
3. `vm.nextBestAction?.title`
4. fallback: `You're on plan. Stay the course.`

Score and status behavior:

- The ring, number, and status all read the effective recovery/readiness state through `vm.effectiveRecoveryScore` and `vm.readinessBasedRecoveryStatus`.
- `effectiveRecoveryScore` averages `recoveryScore` with today's readiness score when `todaysReadiness` exists; otherwise it returns `recoveryScore`.
- `readinessBasedRecoveryStatus` maps the effective score to:
  - `85...`: `Peak Readiness`
  - `70..<85`: `Well Prepared`
  - `55..<70`: `Moderate`
  - `40..<55`: `Low Energy`
  - default: `Rest Needed`

Recovery/readiness ring:

- Base ring: white stroke at `0.06` opacity.
- Progress ring: `Circle().trim(from: 0, to: appeared ? CGFloat(score) / 100 : 0)`.
- Ring color: `ForgeTheme.recoveryColor(for: score)`, which currently delegates to `STRQPalette.recovery(for:)`.
- Recovery color thresholds from `STRQPalette.recovery(for:)`:
  - `80...`: success green
  - `60..<80`: warning amber
  - default: danger red
- Ring rotates `-90` degrees.
- Ring trim animates with Reduce Motion aware timing: `0.12s` when Reduce Motion is on, otherwise `1.0s` with `0.15s` delay.

Numeric score:

- Uses `STRQCountUpText(value: Double(score), duration: 0.75)`.
- `STRQCountUpText` has its own Reduce Motion handling. With Reduce Motion on, it displays the final value instead of counting up.
- Font is rounded, heavy, monospaced digit.

Phase and week context:

- Phase chip uses `phase.icon` and `phase.displayName`.
- Phase chip foreground is `STRQBrand.steel`.
- Phase chip background is `STRQBrand.steel.opacity(0.12)`.
- Week count uses `L10n.format("Week %d", vm.trainingPhaseState.weeksInPhase)`.

Conditional Check in button:

- Visible only when `!vm.hasCheckedInToday`.
- The action is exactly `showReadinessCheckIn = true`.
- The sheet route is declared at top level:
  - `.sheet(isPresented: $showReadinessCheckIn) { ReadinessCheckInView(vm: vm) { readiness in vm.submitReadiness(readiness) } }`
- Current button visual uses the `heart.text.clipboard` SF Symbol, `Check in` copy, black foreground, and `STRQBrand.accentGradient` in a capsule.

Appearance and Reduce Motion:

- `appeared` is set on `onAppear` using `withAnimation(reduceMotion ? .easeOut(duration: 0.12) : .easeOut(duration: 0.5))`.
- The hero applies `.opacity(appeared ? 1 : 0)` and `.offset(y: appeared ? 0 : 10)`.
- The ring trim has a separate Reduce Motion aware animation.
- `STRQCountUpText` has internal Reduce Motion behavior.

Current hero shell:

- Padding: `16`.
- Background: local dark `LinearGradient(colors: [Color(white: 0.14), Color(white: 0.09)])`.
- Corner radius: `20`.
- Border: `Color.white.opacity(0.10)`.
- Top overlay stripe: `STRQBrand.accentGradient`, height `2`, opacity `0.5`.
- Shadow: black opacity `0.2`, radius `14`, y `4`.

Current state/color dependencies:

- Score color depends on `ForgeTheme.recoveryColor(for:)`.
- Status copy depends on `vm.readinessBasedRecoveryStatus`.
- Headline depends on daily briefing, early-state guidance, next-best-action, or fallback.
- Phase chip depends on `vm.currentPhase`.
- Week count depends on `vm.trainingPhaseState.weeksInPhase`.
- Check in visibility depends on `!vm.hasCheckedInToday`.
- Check in route depends on `showReadinessCheckIn`.
- Animation depends on `appeared` and `reduceMotion`.
- Orange/accent debt comes from `STRQBrand.accentGradient` on the Check in chip and top stripe.

## 3. State/behavior map

| State | Visible headline source | Visible status | Check in appears | Color source | Behavior risk | Visual risk |
|---|---|---|---:|---|---|---|
| High readiness / peak readiness | `headline` priority order; often daily briefing if available | `Peak Readiness` at `85...`, `Well Prepared` at `70..<85` | Only if `!vm.hasCheckedInToday` | `ForgeTheme.recoveryColor(for: score)` -> success when `score >= 80` | Medium. High score should not imply a changed workout action from the hero alone. | High. Green must stay semantic to ring/score/status, not flood the whole command surface. |
| Medium readiness | `headline` priority order | `Moderate` at `55..<70` | Only if `!vm.hasCheckedInToday` | `ForgeTheme.recoveryColor(for:)` -> danger below 60, warning at 60-69 | Medium. Threshold mismatch between status and color can confuse if visuals overstate the state. | High. Needs calm caution without turning the hero into a warning banner. |
| Low readiness / rest needed | `headline` priority order; daily briefing may also recommend lighter/recovery behavior elsewhere | `Low Energy` at `40..<55`, `Rest Needed` below 40 | Only if `!vm.hasCheckedInToday` | `ForgeTheme.recoveryColor(for:)` -> danger below 60 | High. Low readiness is behavior-adjacent to training recommendations outside the hero. | High. Red/pink should clarify the ring/status only, not make the whole hero feel alarming or punitive. |
| Checked in today | `headline` priority order | Based on effective score that includes today's readiness | No | `ForgeTheme.recoveryColor(for:)` | High. Do not show the Check in route after the daily check-in condition is satisfied. | Medium. The hero must still feel actionable through the decision headline even without a button. |
| Not checked in today | `headline` priority order | Based on recovery score only if no `todaysReadiness` exists | Yes | `ForgeTheme.recoveryColor(for:)` | High. Button must continue to set `showReadinessCheckIn = true` only. | High. Current orange chip makes Check in too brand/CTA dominant for the command-center role. |
| Early-stage user | Daily briefing if present, otherwise `earlyStateGuidance?.headline`, then action/fallback | Based on effective recovery score | Based only on `!vm.hasCheckedInToday` | `ForgeTheme.recoveryColor(for:)` plus steel phase chip | Medium/High. Hero must not overpromise coaching intelligence before calibration. | High. Must coordinate with accepted `earlyStateCard` and `calibrationChecklist` without copying them. |
| Established user | Daily briefing usually leads when available | Based on effective recovery score | Based only on `!vm.hasCheckedInToday` | `ForgeTheme.recoveryColor(for:)` plus steel phase chip | Medium. Hero should stay aligned with daily briefing/decision stack. | Medium/High. It must feel like the top command module, not one more feed card above other cards. |
| `dailyBriefing` exists | `vm.dailyBriefing?.primary.title` | Based on effective recovery score | Based only on `!vm.hasCheckedInToday` | `ForgeTheme.recoveryColor(for:)` | High. This is the highest-priority headline and can reflect active workout, train, recover, prep, or rest paths. | High. The layout must make the decision headline feel primary without turning into `primaryMoveCard`. |
| `earlyStateGuidance` exists | Used only when no `dailyBriefing`; `vm.earlyStateGuidance?.headline` | Based on effective recovery score | Based only on `!vm.hasCheckedInToday` | `ForgeTheme.recoveryColor(for:)` | Medium. Early-state copy must not be shadowed by a new visual hierarchy that implies full maturity. | Medium/High. Hero must complement the early-state card, not duplicate calibration visuals. |
| `nextBestAction` fallback exists | Used only when no daily briefing and no early-state guidance; `vm.nextBestAction?.title` | Based on effective recovery score | Based only on `!vm.hasCheckedInToday` | `ForgeTheme.recoveryColor(for:)` | Medium. Older progression action fallback must remain available when briefing/guidance are absent. | Medium. Visual shell must handle shorter/older action titles without feeling broken. |
| No briefing/guidance/action fallback | `You're on plan. Stay the course.` | Based on effective recovery score | Based only on `!vm.hasCheckedInToday` | `ForgeTheme.recoveryColor(for:)` | Low/Medium. Fallback must remain stable and localized through existing call. | Medium. Empty-signal state should still feel intentional, not like a blank metric card. |
| Reduce Motion off | Same headline priority | Same status | Same visibility | Same color source | Medium. Entrance, ring trim, and count-up timing should remain natural and not block state reading. | Medium. Animation should feel premium, not gamified. |
| Reduce Motion on | Same headline priority | Same status | Same visibility | Same color source | High. Reduced animation timing and count-up suppression must remain respected. | Medium. The hero must still communicate state without relying on motion. |

## 4. Protected behavior map

| UI/action | Protected call/state | Trigger | Risk if changed | Must preserve | Notes |
|---|---|---|---|---|---|
| Recovery/readiness score | `vm.effectiveRecoveryScore` | Hero render | Score could stop reflecting today's readiness when present, or could use the wrong recovery source | Yes | Do not recalculate in the view. |
| Recovery/readiness color | `ForgeTheme.recoveryColor(for: score)` | Hero render | Semantic score/ring colors can drift from existing STRQ recovery mapping | Yes | Keep initially unless a separate readiness color tuning pass is approved. |
| Current phase | `vm.currentPhase` | Hero render | Phase chip could show stale or wrong training block context | Yes | Reads `trainingPhaseState.currentPhase`. |
| Readiness status | `vm.readinessBasedRecoveryStatus` | Hero render | Status copy could become inconsistent with score thresholds | Yes | Preserve exact view-model source. |
| Headline priority 1 | `vm.dailyBriefing?.primary.title` | `headline` computed property | Daily coach decision can lose priority | Yes | Highest priority. |
| Headline priority 2 | `vm.earlyStateGuidance?.headline` | `headline` computed property | Early-stage calibration headline can disappear when briefing is absent | Yes | Only used after daily briefing fallback. |
| Headline priority 3 | `vm.nextBestAction?.title` | `headline` computed property | Older progression fallback can be lost | Yes | Keep order below early-state guidance. |
| Headline fallback | `L10n.tr("You're on plan. Stay the course.")` | No briefing/guidance/action | Empty state could become unlocalized or misleading | Yes | No copy/localization changes in shell pass. |
| Week count | `vm.trainingPhaseState.weeksInPhase` | Hero render | User could see wrong phase duration | Yes | Preserve current `L10n.format("Week %d", ...)`. |
| Check in visibility | `!vm.hasCheckedInToday` | Hero render | User could check in multiple times or lose daily check-in access | Yes | Do not change condition. |
| Check in action | `showReadinessCheckIn = true` | Tap hero Check in | Readiness sheet route could break or action could gain unintended side effects | Yes | No analytics addition in this hero pass. |
| Readiness sheet destination | `ReadinessCheckInView(vm: vm) { vm.submitReadiness(readiness) }` | `showReadinessCheckIn` sheet presentation | Check-in submission, persistence, analytics, or daily-state refresh could change | Yes | Do not edit `ReadinessCheckInView` or `AppViewModel`. |
| Recovery ring trim | `.trim(from: 0, to: appeared ? CGFloat(score) / 100 : 0)` | `appeared` changes | Ring could show wrong progress or animate from the wrong value | Yes | Preserve score/100 mapping. |
| Recovery ring animation | Reduce Motion aware `.animation(..., value: appeared)` | `appeared` changes | Motion accessibility or visual timing can regress | Yes | Shell pass may restyle the ring, but not alter meaning/timing. |
| Numeric count-up | `STRQCountUpText(value: Double(score), duration: 0.75)` | Hero render and score updates | Numeric animation accessibility and display contract can regress | Yes | Preserve component and value. |
| Reduce Motion behavior | `reduceMotion` environment plus `STRQCountUpText` internal handling | On appear and ring/count-up display | Accessibility regression | Yes | Do not replace with motion-only state communication. |
| Appearance opacity/offset | `.opacity(appeared ? 1 : 0)`, `.offset(y: appeared ? 0 : 10)` | `appeared` changes | Hero can pop, shift, or desync from adjacent CoachTab modules | Yes | Visual shell can adjust style, not behavior. |
| No analytics changes | No hero-specific analytics currently on Check in | Hero appears/tap | Analytics stream changes unexpectedly | Yes | Preserve existing `coach_viewed` on screen appear and readiness logging in submit path. |

## 5. Current visual diagnosis

The authority hero still uses orange/accent-gradient styling in two high-visibility places: the top stripe and the Check in chip. Those accents read as old STRQ energy/accent debt rather than Coach authority.

It feels older than the accepted `earlyStateCard`, `calibrationChecklist`, and passive early-stage Weekly Check-In shell. The newer modules are calmer and more intentional; the hero still reads like an older Forge/local metric card.

The current structure is useful, but the composition is a standard metric card plus CTA: ring on the left, status/headline on the right, phase/week row below, and a small action chip. That is legible, but it does not yet feel like the intelligent daily coach command center.

Orange is doing too much identity work. Because readiness already has semantic color through the ring/status, the orange stripe and orange chip create a second competing color story. In low-readiness states, that can be especially confusing because red/pink semantic state and orange CTA energy compete.

The ring is useful and should probably stay. It gives the score an immediate, compact shape. The surrounding shell, hierarchy, and action treatment need stronger STRQ daily-coach identity.

The hero should not become a Profile card, Notification row, or generic dashboard metric. Profile and NotificationSettings use STRQ foundation well, but CoachTab needs a different product role: decision-first intelligence, not settings/status sameness.

The hero must stay understandable in all readiness states. High readiness should not turn the whole card green. Low readiness should not make the whole card feel like a danger alert. Not checked in should show Check in clearly without making the old orange chip the hero identity.

## 6. Product goal for authorityHero

Define authorityHero as STRQ's daily coach command center.

It should communicate:

- one clear state
- one clear next decision
- readiness awareness
- phase awareness
- calm confidence
- trusted coaching judgment
- a sense that STRQ is interpreting the day, not just displaying a metric

It should not communicate:

- a gamified score badge
- a generic metric card
- a feed card
- a CTA banner
- a static profile metric
- an orange energy promo
- a notification/settings row with different text

Ideal hierarchy:

1. Score/state: the user's current readiness/recovery condition.
2. Decision headline: what STRQ thinks matters now.
3. Phase context/action: training block, week count, and optional Check in.

## 7. What must not change

Protect:

- score calculation source: `vm.effectiveRecoveryScore`
- readiness/recovery color source: `ForgeTheme.recoveryColor(for:)`, unless separately approved
- headline priority:
  - `vm.dailyBriefing?.primary.title`
  - `vm.earlyStateGuidance?.headline`
  - `vm.nextBestAction?.title`
  - fallback
- phase value: `vm.currentPhase`
- phase icon/display name source
- week value: `vm.trainingPhaseState.weeksInPhase`
- Check in visibility condition: `!vm.hasCheckedInToday`
- Check in action: `showReadinessCheckIn = true`
- readiness sheet route
- readiness submit path: `vm.submitReadiness(readiness)`
- Reduce Motion behavior
- recovery ring score mapping and animation meaning
- `STRQCountUpText` count-up behavior
- appeared opacity/offset behavior
- analytics elsewhere
- copy/localization
- `AppViewModel`
- `DailyStateCoordinator`
- `DailyBriefingEngine`
- workout handoff/progression flows
- `primaryMoveCard`
- `coachPrimaryCTA`
- `ReadinessCheckInView`

## 8. Visual redesign direction

Recommended direction:

- Create a distinct command-center composition, not a copied card pattern.
- Preserve the recovery ring, but allow a shell-only pass to reposition or refine the visual relationship between ring, state, headline, phase, and Check in.
- Replace the orange top stripe with a semantic readiness/coach-state accent or a neutral shell treatment.
- Make Check in secondary/actionable without old orange CTA styling.
- Strengthen hierarchy: score/state -> decision headline -> phase context/action.
- Use a dark premium surface with subtle depth and clear structure.
- Use shape/form sparingly and purposefully.
- Consider asymmetry or a layered state area if it improves command-center identity without changing behavior.
- Avoid a broad redesign of `decisionStack`, `primaryMoveCard`, or `coachPrimaryCTA` in the same pass.
- Keep the hero understandable when the Check in button is absent.
- Keep score color localized to score/ring/status instead of coloring the whole hero.

Potential composition moves for a future shell-only pass:

- Keep the ring as a left or top-left state instrument, but give the headline a stronger decision lane.
- Move phase/week into a quieter context rail.
- Treat Check in as a compact secondary control, visually tied to readiness/self-check rather than orange brand energy.
- Replace the top stripe with a hairline, corner glow, state capsule, or no stripe if the ring already provides enough state color.
- Use neutral carbon/graphite layers and restrained steel borders to make the module feel authoritative.

## 9. Color and semantic accent policy

Readiness score color can stay semantic through `ForgeTheme.recoveryColor(for:)` initially.

Orange should not be the default hero identity. Existing `STRQBrand.accentGradient` usage in the top stripe and Check in chip should be treated as migration debt for this hero.

If readiness is high, green is semantic only for the score/ring/status. It should not flood the whole card or imply celebration.

If readiness is low/rest-needed, red/pink is semantic only for the score/ring/status. It should not turn the whole hero into a danger banner unless a separate product decision approves that behavior.

Hero shell should use neutral/coach carbon: deep surface, graphite structure, steel border, and controlled light.

The Check in action should likely use readiness teal or neutral coach steel, not orange. It must remain visibly actionable, but it should read as a calm self-check, not an energy CTA.

Do not use Pro violet.

Do not use Streak bronze.

Do not use Notification Coach Blue blindly. Notification Coach Blue exists for reminders; the hero can share a broad intelligence family only if intentionally aligned and visually distinct enough for CoachTab.

Avoid making the hero too colorful when score is already colored. The ring/status already carries semantic state.

## 10. State coverage requirements

Future implementation must cover:

- score 90/high
- score 48/low energy
- score 32/rest needed
- score 14/rest recommended if reachable
- checked in today
- not checked in today
- dailyBriefing headline
- earlyStateGuidance headline
- nextBestAction headline
- fallback headline
- phase build
- phase push if reachable
- phase fatigueManagement/recovery if reachable
- phase deload if reachable
- phase rebalance if reachable
- visible week count
- small iPhone layout
- large iPhone layout
- Reduce Motion on
- Reduce Motion off
- tap Check in opens readiness sheet
- Check in hidden after checked-in state
- no accidental workout handoff changes
- no `primaryMoveCard` visual/behavior changes
- no `ReadinessCheckInView` changes

Rork QA should capture screenshots for the main score bands and both Check in visibility states. Static inspection cannot prove hierarchy, clipping, perceived color dominance, or whether the hero reads as a daily coach command center.

## 11. Risk rating

| Risk area | Rating | Reason |
|---|---:|---|
| Behavior risk | Medium/High | The hero has one direct action, sheet routing, score/status state, headline priority, and motion behavior. A shell-only pass is manageable, but accidental action/source changes would be serious. |
| Readiness/training-flow risk | Medium/High | The hero reflects readiness state that can influence user trust in workout decisions, even though workout handoff lives elsewhere. |
| Product trust risk | High | The top CoachTab surface frames STRQ's daily judgment. Wrong hierarchy or color semantics can overstate confidence or urgency. |
| Visual risk | High | It is the largest visible design break in CoachTab and still carries orange/accent-gradient debt. |
| Owner approval need | High | Any Swift implementation should be owner-approved with exact scope and Rork screenshots. |

Overall risk:

- Low for this docs-only pass.
- Medium/High for an authorityHero shell-only implementation.
- High if implementation touches action logic, copy, daily briefing, readiness submission, `primaryMoveCard`, or `ReadinessCheckInView`.

## 12. Recommended implementation phases

1. Plan completed.
2. `authorityHero` shell-only pass preserving structure/action.
3. Rork QA across high/medium/low readiness.
4. Check-in button visual refinement if still needed.
5. Readiness color tuning only if screenshots show issue.
6. Later `primaryMoveCard` / `coachPrimaryCTA` planning.
7. Never combine hero + `ReadinessCheckInView` redesign.

## 13. Exactly one recommended next implementation prompt

Chosen option: A. authorityHero shell-only visual pass preserving behavior.

Reason: `authorityHero` is now the largest visible CoachTab design break, and the behavior mapping is sufficiently clear for one tightly scoped shell-only Swift pass. Starting with the whole hero shell is more useful than a Check-in chip or ring-only pass because the design problem is the relationship between state, decision, phase, and action. The pass must not touch `ReadinessCheckInView`, `primaryMoveCard`, `coachPrimaryCTA`, daily briefing logic, or any model/service path.

Use this exact prompt next:

```text
Work in repo: C:\Users\maxwa\Documents\GitHub\rork-strq

Goal:
Implement only a shell-only visual refresh for CoachTab `authorityHero` so it reads as STRQ's daily coach command center. Preserve all behavior, copy, state sources, sheet routing, Reduce Motion behavior, count-up behavior, analytics behavior, and model/view-model/service logic.

Exact target file:
- ios/STRQ/Views/CoachTabView.swift

Exact target section/helper:
- `private var authorityHero`
- `private var headline` may be read but must not be changed unless required only to preserve existing behavior
- Do not edit `decisionStack`, `primaryMoveCard`, `coachPrimaryCTA`, `weeklyCheckInRow`, `earlyStateCard`, or `calibrationChecklist`

Allowed edits:
- ios/STRQ/Views/CoachTabView.swift
- docs/migration-progress-log.md

Forbidden edits:
- Any other Swift file
- ios/STRQ/Views/ReadinessCheckInView.swift
- ios/STRQ/Views/WeeklyCheckInView.swift
- ios/STRQ/ViewModels/AppViewModel.swift
- DailyStateCoordinator
- DailyBriefingEngine
- Models
- Services
- Persistence
- Analytics files
- STRQDesignSystem.swift
- STRQPalette.swift
- ForgeTheme.swift
- Assets.xcassets
- Localizable.xcstrings
- RevenueCat/store files
- Watch files
- Widget files
- Live Activity files
- project.pbxproj
- tests
- fonts

Behavior preservation list:
- Preserve `score = vm.effectiveRecoveryScore`.
- Preserve `color = ForgeTheme.recoveryColor(for: score)`.
- Preserve `phase = vm.currentPhase`.
- Preserve `status = vm.readinessBasedRecoveryStatus`.
- Preserve headline priority exactly:
  1. `vm.dailyBriefing?.primary.title`
  2. `vm.earlyStateGuidance?.headline`
  3. `vm.nextBestAction?.title`
  4. fallback `You're on plan. Stay the course.`
- Preserve `vm.trainingPhaseState.weeksInPhase` and existing `Week %d` copy.
- Preserve Check in visibility: `if !vm.hasCheckedInToday`.
- Preserve Check in action exactly: `showReadinessCheckIn = true`.
- Preserve the existing readiness sheet route and `ReadinessCheckInView(vm: vm) { vm.submitReadiness(readiness) }`.
- Preserve recovery ring trim mapping: `CGFloat(score) / 100`.
- Preserve ring animation meaning and Reduce Motion timing.
- Preserve `STRQCountUpText(value: Double(score), duration: 0.75)`.
- Preserve appeared opacity/offset behavior.
- Do not add, remove, or reroute analytics.
- Do not change copy/localization.
- Do not change workout handoff, progression, daily briefing, early-state, weekly check-in, More Signals, comeback, or coaching history behavior.

Visual objective:
- Make `authorityHero` feel like STRQ's intelligent daily coach command center.
- Preserve the recovery/readiness ring, but refine its surrounding composition if useful.
- Replace the old orange/accent-gradient top stripe and old orange Check in chip treatment.
- Use a premium neutral/coach carbon shell with subtle depth.
- Keep readiness color semantic and localized to score/ring/status.
- Make Check in secondary/actionable, likely readiness teal or neutral coach steel rather than orange.
- Strengthen hierarchy: score/state -> decision headline -> phase context/action.
- Avoid Profile, NotificationSettings, generic dashboard, feed-card, gamified, Pro-violet, Streak-bronze, and broad orange CTA treatments.
- Do not redesign `ReadinessCheckInView`, `primaryMoveCard`, `coachPrimaryCTA`, `decisionStack`, or the rest of CoachTab in this pass.

Verification commands:
- git status --short --branch
- git diff --name-only
- git diff -- ios/STRQ/Views/CoachTabView.swift docs/migration-progress-log.md
- git diff --name-only -- ios/STRQ/ViewModels ios/STRQ/Services ios/STRQ/Models ios/STRQ/Utilities/STRQDesignSystem.swift ios/STRQ/Utilities/STRQPalette.swift ios/STRQ/Utilities/ForgeTheme.swift ios/STRQ/Views/ReadinessCheckInView.swift ios/STRQ/Views/WeeklyCheckInView.swift ios/STRQ/Localizable.xcstrings ios/STRQWidget ios/STRQWatch
- rg -n "private var authorityHero|private var headline|effectiveRecoveryScore|ForgeTheme.recoveryColor|currentPhase|readinessBasedRecoveryStatus|STRQCountUpText|trainingPhaseState\.weeksInPhase|hasCheckedInToday|showReadinessCheckIn|accentGradient|appeared|reduceMotion|dailyBriefing|earlyStateGuidance|nextBestAction" ios/STRQ/Views/CoachTabView.swift
- rg -n "ReadinessCheckInView|submitReadiness|showReadinessCheckIn|readinessBasedRecoveryStatus|effectiveRecoveryScore|DailyBriefing|DailyStateCoordinator|DailyBriefingEngine" ios/STRQ
- rg -n "Coach Authority Hero|authorityHero|Rork|Check in|readiness|command center" docs/migration-progress-log.md

Rork QA checklist:
- Score 90/high state renders as calm high readiness.
- Score 48/low energy state renders as caution without alarm.
- Score 32/rest needed state renders clearly without making the whole hero a danger banner.
- Score 14/rest recommended state if reachable.
- Checked-in state hides the hero Check in action.
- Not-checked-in state shows the hero Check in action.
- Tap hero Check in opens `ReadinessCheckInView`.
- Dismissing readiness sheet returns to CoachTab.
- Submitting readiness still updates score/status through existing behavior.
- Daily briefing headline state.
- Early-state guidance headline state.
- Next-best-action headline state.
- Fallback headline state.
- Build phase/week count state.
- Deload or fatigue-management phase if reachable.
- Small iPhone layout has no clipping or overlap.
- Large iPhone layout preserves command-center hierarchy.
- Reduce Motion on.
- Reduce Motion off.
- No accidental workout handoff changes.
- No `primaryMoveCard` or `coachPrimaryCTA` changes.
- No `ReadinessCheckInView` visual or behavior changes.
- No orange top stripe, Pro violet, Streak bronze, or generic notification/settings treatment.

Push command after successful verification:
git status --short --branch
git add ios/STRQ/Views/CoachTabView.swift docs/migration-progress-log.md
git commit -m "polish coach authority hero shell"
git push
```

This is the only recommended next implementation prompt in this report.

## 14. Rork QA checklist

- [ ] Score 90/high readiness.
- [ ] Score 48/low energy.
- [ ] Score 32/rest needed.
- [ ] Score 14/rest recommended if reachable.
- [ ] Checked in today: Check in action hidden.
- [ ] Not checked in today: Check in action visible.
- [ ] Tap hero Check in opens readiness sheet.
- [ ] Dismiss readiness sheet returns to CoachTab.
- [ ] Submit readiness updates score/status through existing behavior.
- [ ] Daily briefing headline is shown when `vm.dailyBriefing` exists.
- [ ] Early-state guidance headline is shown when no daily briefing exists and guidance exists.
- [ ] Next-best-action headline is shown when briefing/guidance are absent and action exists.
- [ ] Fallback headline appears when briefing/guidance/action are absent.
- [ ] Build phase chip and week count.
- [ ] Push phase chip if reachable.
- [ ] Fatigue-management/recovery phase chip if reachable.
- [ ] Deload phase chip if reachable.
- [ ] Rebalance phase chip if reachable.
- [ ] Early-stage user with accepted early-state card below hero.
- [ ] Established user with decision stack below hero.
- [ ] Small iPhone layout has no clipping, overlap, or awkward wrapping.
- [ ] Large iPhone layout keeps the hero authoritative without oversized decoration.
- [ ] Reduce Motion on.
- [ ] Reduce Motion off.
- [ ] No accidental workout handoff changes.
- [ ] No `primaryMoveCard` changes.
- [ ] No `coachPrimaryCTA` changes.
- [ ] No `ReadinessCheckInView` redesign.
- [ ] No copy/localization changes.
- [ ] No analytics changes.
- [ ] No orange top stripe or old orange Check in chip dominance.
- [ ] No Pro violet.
- [ ] No Streak bronze.
- [ ] No blind Notification Coach Blue reuse.
- [ ] Rork QA is required after any Swift implementation; it is not completed by this docs-only pass.
