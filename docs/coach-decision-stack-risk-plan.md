# Coach Decision Stack Risk Plan

## 1. Executive summary

`decisionStack` is the established-user "why and what next" area under the accepted CoachTab hero. It is where the screen should translate from a metric surface into an actionable coaching explanation.

The stack should explain why today matters and what the user should do next: one primary recommendation, one or two supporting signals, and a quiet path into deeper signals. It should make CoachTab feel like an intelligent coach, not a list of generic cards.

This area is action-adjacent and should not be broadly redesigned first. It touches workout handoff, readiness check-in routing, More Signals sheet routing, expandable action cards, CoachingPreferences density/emphasis filtering, and optional lift-tracker logic.

This pass makes no Swift changes. It creates only this planning document and a concise migration-log entry.

Future implementation should start with the safest display-only candidate. Do not begin with `primaryMoveCard`, `coachPrimaryCTA`, More Signals action cards, workout handoff, readiness submission, or lift/progression logic.

Figma note: @Figma was not used in this pass. The plan is grounded in the existing STRQ docs, the current Swift implementation, and broad pattern categories only: coach recommendation cards, decision stacks, AI insight surfaces, primary decision plus supporting signal layouts, warning/watch modules, momentum modules, expandable insight lists, premium dark dashboards, and compact command/feed hybrids.

## 2. Current implementation inventory

Target file:

- `ios/STRQ/Views/CoachTabView.swift`

Established branch context:

- In `CoachTabView.body`, early-stage users see `earlyStateCard` and optional `calibrationChecklist`.
- Established users can see optional `ComebackCard`, then `decisionStack`.
- `decisionStack` is therefore the established-user reasoning surface directly beneath the accepted authority hero and any comeback guidance.

`private var decisionStack`:

- Renders only inside `if let briefing = vm.dailyBriefing`.
- Reads `vm.profile.coachingPreferences.density`.
- Reads `density.sideSignalsLimit`.
- Reads `vm.profile.coachingPreferences.emphasis`.
- Computes `showWatch = briefing.watch != nil && sideLimit >= 1`.
- Computes `showMomentum = briefing.momentum != nil && sideLimit >= (showWatch ? 2 : 1) && emphasis != .simplicity`.
- Always renders `primaryMoveCard(briefing.primary)` when the briefing exists.
- Renders `watchCard(watch)` only when `showWatch` is true.
- Renders `momentumCard(momentum)` only when `showMomentum` is true.
- Renders the More Signals row only when `briefing.moreSignalsCount > 0 && density != .focused`.
- Tapping the More Signals row sets `showMoreSignals = true`.
- Renders `liftTrackerSection` only when `vm.coachingConfidence >= .moderate`.
- Uses the same `appeared` and Reduce Motion aware opacity/offset animation pattern as nearby CoachTab modules.

`primaryMoveCard(_:)`:

- Input: `DailyBriefing.Primary`.
- Tint source: `ForgeTheme.color(for: primary.colorName)`.
- Current visual shell: local Forge/grouped card with a tinted marker, uppercase `COACH RECOMMENDS`, primary icon, title, detail, CTA helper, optional since-last bridge, tinted gradient background, border, and shadow.
- Renders `coachPrimaryCTA(primary)`.
- Reads `vm.dailyBriefing?.sinceLast` and, when present, renders a success-colored result bridge using `STRQPalette.success` and `STRQPalette.successSoft`.
- No direct analytics are tracked in this helper.

`coachPrimaryCTA(_:)`:

- Uses `ForgePrimaryButton`, which currently uses `STRQBrand.accentGradient`, black foreground text, and `STRQPalette.energyAccent` shadowing through Forge.
- Switches on `DailyBriefing.Primary.kind`.
- `.checkInBeforeTraining`: renders `Check in`; tap sets `showReadinessCheckIn = true`.
- `.startFirstSession`: if `vm.todaysWorkout ?? vm.nextWorkout` exists, renders `Start Workout 1`; tap calls `vm.prepareWorkoutHandoff(day:)`.
- `.resumeWorkout`: if `vm.todaysWorkout` exists, renders `Resume Workout`; tap calls `vm.prepareWorkoutHandoff(day:)`.
- `.trainToday`: if `vm.todaysWorkout` exists, renders `Start Workout`; tap calls `vm.prepareWorkoutHandoff(day:)`.
- `.recoverToday`: if `vm.todaysWorkout` exists, renders `Start Light Workout`; tap calls `vm.prepareWorkoutHandoff(day:)`.
- Default/other primary kinds render `EmptyView()`.
- `DailyBriefing.Primary.ctaTitle` exists in the data model, but this helper currently uses switch-specific button titles instead of rendering `primary.ctaTitle` directly.

`watchCard(_:)`:

- Input: `DailyBriefing.Watch`.
- Tint source: `ForgeTheme.color(for: watch.colorName)`.
- Current visual shell: compact grouped card with `WATCH` label, left color marker, icon well, title, and a details toggle.
- Tapping Details toggles `showWatchDetails` using a Reduce Motion aware animation.
- When expanded, it renders `watch.detail` inline with a combined opacity/top-move transition.
- No analytics are tracked for details expand/collapse.

`momentumCard(_:)`:

- Input: `DailyBriefing.Momentum`.
- Current visual shell: compact grouped HStack card.
- Uses `STRQPalette.success` and `STRQPalette.successSoft`.
- Renders icon, uppercase `MOMENTUM`, and `momentum.title`.
- No tap target, route, model call, or analytics are present.

`moreSignalsLabel(_:)`:

- Returns localized singular/plural copy based on `briefing.moreSignalsCount`.
- The row itself uses a generic list icon, caption typography, grouped-card background, `STRQBrand.steel`, and a chevron.
- Tapping opens the More Signals sheet by setting `showMoreSignals = true`.

`liftTrackerSection`:

- Evaluated only after `vm.coachingConfidence >= .moderate`.
- Reads `vm.stalledExercises.prefix(2)` and `vm.progressingExercises.prefix(2)`.
- Renders nothing if both prefixes are empty.
- Uses `ForgeSectionHeader(title: "Lift Tracker")`.
- Renders stalled rows first, then progressing rows.

`liftRow`:

- Reads `vm.library.exercise(byId: state.exerciseId)`.
- Shows exercise name or the raw exercise id fallback.
- For stalled rows, uses `state.plateauStatus.icon`, `state.plateauStatus.displayName`, and `state.recommendedStrategy.displayName`.
- For progressing rows, uses `arrow.up.right`, localized `Progressing`, and optional `state.suggestedNextWeight`.
- Color semantics:
  - stalled and regressing: `STRQPalette.danger`
  - stalled and not regressing: `STRQPalette.warning`
  - progressing: `STRQPalette.success`

Daily briefing source and fields:

- `vm.dailyBriefing` is assigned by `DailyStateCoordinator.refreshBriefing()`.
- `DailyStateCoordinator` builds `DailyBriefingInput` from plan/onboarding/active-workout state, today's workout, next workout, readiness, pain/restriction, effective recovery, streak, weekly completion, last-session verdict, top insight, top momentum, missing weight/sleep days, total insights/recommendations, hour, early-stage state, tone, and emphasis.
- `DailyBriefingEngine.build(_:)` returns `briefing.primary`, `briefing.watch`, `briefing.momentum`, `briefing.sinceLast`, `briefing.restPrep`, and `briefing.moreSignalsCount`.
- `briefing.primary` comes from `resolvePrimary(_:)` and can be `.checkInBeforeTraining`, `.startFirstSession`, `.resumeWorkout`, `.trainToday`, `.recoverToday`, `.recoveryDay`, `.prepNextSession`, `.logBodyWeight`, or declared default kinds such as `.logCompletion`.
- `briefing.watch` comes from top high/medium insight unless the primary is already `.recoverToday`.
- `briefing.momentum` comes from top positive insight, a streak signal, or a weekly target hit signal.
- `briefing.moreSignalsCount` is computed from total insights plus recommendations minus the one watch signal when present.

CoachingPreferences:

- `vm.profile.coachingPreferences.density` can be `.focused`, `.standard`, or `.detailed`.
- `density.sideSignalsLimit` returns `0` for focused, `2` for standard, and `4` for detailed.
- `vm.profile.coachingPreferences.emphasis` can be `.performance`, `.physique`, `.recovery`, `.consistency`, or `.simplicity`.
- `emphasis != .simplicity` is required for `momentumCard` visibility in `decisionStack`.
- `DailyBriefingEngine` also receives emphasis and tone, and `.simplicity` can trim primary detail to one sentence.

Confidence and lift tracking:

- `vm.coachingConfidence` is computed from recent completed workouts, readiness check-ins, sleep logs, weeks trained, and weight logs.
- `decisionStack` only considers lift tracking when `vm.coachingConfidence >= .moderate`.
- `liftTrackerSection` still requires stalled or progressing exercise state before anything appears.

Routes and local state:

- `showReadinessCheckIn` opens `ReadinessCheckInView(vm: vm) { readiness in vm.submitReadiness(readiness) }`.
- `showMoreSignals` opens `NavigationStack { MoreSignalsSheet(vm: vm) }` with large detent, visible drag indicator, and scroll presentation interaction.
- `showWatchDetails` is local inline expansion state.

More Signals sheet:

- `MoreSignalsSheet` reads `vm.highPriorityInsights.dropFirst()` and `vm.recommendations.dropFirst(vm.highPriorityInsights.isEmpty ? 1 : 0)`.
- Secondary insights render as `ExpandableInsightCard`.
- Secondary recommendations render as `ExpandableRecommendationCard`.
- Expand/collapse state is local to `MoreSignalsSheet` through `expandedInsightIds` and `expandedRecIds`.
- Those expandable cards can apply plan changes through `vm.applyVolumeReduction`, `vm.applyExerciseSwap`, `vm.applyLighterSession`, `vm.applyWeekRegeneration`, `vm.applyDeloadWeek`, and `vm.undoAdjustment`.

Analytics:

- `decisionStack`, `primaryMoveCard`, `coachPrimaryCTA`, `watchCard`, `momentumCard`, and the More Signals row do not track direct analytics today.
- Opening More Signals does not track an event today.
- Watch details expand/collapse does not track an event today.
- Readiness submission analytics live downstream in `vm.submitReadiness(_:)`.
- More Signals action analytics live downstream in `AppViewModel` action methods and undo methods.
- Existing CoachTab analytics elsewhere, such as `.coach_viewed`, comeback events, coaching memory bridge tracking, and downstream action analytics, must not be changed by a visual pass.

## 3. State/behavior map

| State | What is visible | Tappable/actionable | Protected call/state | Visual risk |
|---|---|---:|---|---|
| No `dailyBriefing` | No `decisionStack`; established users continue to later modules such as phase outlook, memory, and Weekly Check-In if their gates allow them | No decision-stack actions | `if let briefing = vm.dailyBriefing` | Medium. Empty reasoning area can look like missing intelligence if later visual work assumes a card is always present. |
| `dailyBriefing` exists | `primaryMoveCard` always appears; side cards, More Signals, and lift tracker follow their gates | Depends on primary kind, More Signals availability, watch details, and lift rows | `vm.dailyBriefing`; `briefing.primary`; density/emphasis/confidence gates | High. This is the main established-user coaching hierarchy. |
| Primary only | Primary recommendation appears; no watch, no momentum, no More Signals unless count/gates allow; lift tracker may still appear if confident and populated | CTA may be actionable depending on primary kind | `primaryMoveCard(briefing.primary)`; side gates false | High. Primary card must feel intentional, not lonely or overpromised. |
| Primary + watch | Primary and watch appear; momentum absent | Primary CTA may act; watch Details toggles | `briefing.watch != nil && sideLimit >= 1`; `showWatchDetails` | High. Watch should support the decision without becoming a competing alert. |
| Primary + momentum | Primary and momentum appear; watch absent | Primary CTA may act; momentum is display-only | `briefing.momentum != nil`; `sideLimit >= 1`; `emphasis != .simplicity` | Medium. Momentum should not feel like a generic success badge. |
| Primary + watch + momentum | Primary, watch, and momentum appear in order | Primary CTA may act; watch Details toggles; momentum display-only | `showWatch`; `showMomentum`; `sideLimit >= 2` when watch is present | High. The stack can start reading as equal cards unless visual hierarchy is deliberate. |
| More signals available | More Signals row appears only outside focused density; label reflects count | Yes. Tap sets `showMoreSignals = true` and opens a sheet with expandable action cards | `briefing.moreSignalsCount > 0 && density != .focused`; `showMoreSignals` | High. The row looks quiet, but the sheet contains plan-changing recommendation actions. |
| Focused density | Side-signal limit is `0`; watch and momentum hidden; More Signals hidden even when count exists; lift tracker can still appear if confidence allows | Primary CTA and lift tracker display only; no More Signals row | `density.sideSignalsLimit == 0`; `density != .focused` check fails for More Signals | Medium/High. Focused users should see less noise without feeling that STRQ lost context. |
| Standard density | Side-signal limit is `2`; watch and momentum can both appear; More Signals can appear when count exists | Primary CTA, watch Details, More Signals as gated | `density.sideSignalsLimit == 2` | Medium. This is the default coaching explanation density. |
| Detailed density | Side-signal limit is `4`; current stack still only has watch and momentum as side cards, with More Signals as the deeper doorway | Primary CTA, watch Details, More Signals as gated | `density.sideSignalsLimit == 4` | Medium. Detailed should feel richer, but not like a feed or marketplace. |
| Emphasis simplicity | Momentum is suppressed; primary detail may also be shortened by `DailyBriefingEngine` | Primary CTA and watch Details can remain | `emphasis != .simplicity`; `DailyBriefingEngine.applyToneAndEmphasis` | High. Simplicity must preserve the single clear call without hiding critical risk. |
| Watch details collapsed | Watch title and Details control appear; `watch.detail` hidden | Details button toggles | `showWatchDetails == false` | Medium. Collapsed state must still show enough caution signal. |
| Watch details expanded | Watch title, Details control, and up to four lines of `watch.detail` appear | Details button toggles closed | `showWatchDetails == true`; Reduce Motion aware animation | High. Expanded copy can crowd the stack and change perceived urgency. |
| Coaching confidence below moderate | `liftTrackerSection` is skipped entirely | No lift-tracker action | `vm.coachingConfidence >= .moderate` gate fails | High. Showing lift analysis too early would damage trust. |
| Coaching confidence moderate or higher | `liftTrackerSection` is evaluated; rows appear only if stalled/progressing prefixes are nonempty | Rows are display-only | `vm.coachingConfidence >= .moderate`; stalled/progressing arrays | Medium/High. The section must feel signal-backed, not overconfident. |
| Stalled exercises visible | Up to two stalled rows appear with plateau status and strategy | Display-only | `vm.stalledExercises.prefix(2)`; `liftRow(isStalled: true)` | High. Warning/danger semantics can over-alarm or mislead progression interpretation. |
| Progressing exercises visible | Up to two progressing rows appear with optional next weight | Display-only | `vm.progressingExercises.prefix(2)`; `liftRow(isStalled: false)` | Medium. Success semantics should support confidence without becoming celebration noise. |
| Primary kind `.checkInBeforeTraining` | Primary card with `Check in` button | Yes. Opens readiness sheet | `showReadinessCheckIn = true` | High. This must remain readiness routing, not workout start. |
| Primary kind `.startFirstSession` | Primary card with `Start Workout 1` if today's or next workout exists | Yes. Calls workout handoff | `vm.todaysWorkout ?? vm.nextWorkout`; `vm.prepareWorkoutHandoff(day:)` | High. First workout entry is a protected activation/handoff path. |
| Primary kind `.resumeWorkout` | Primary card with `Resume Workout` if today's workout exists | Yes. Calls workout handoff; active workout special case lives in `prepareWorkoutHandoff` | `vm.todaysWorkout`; `vm.prepareWorkoutHandoff(day:)` | High. Resume must not start a duplicate session or bypass active-workout behavior. |
| Primary kind `.trainToday` | Primary card with `Start Workout` if today's workout exists | Yes. Calls workout handoff | `vm.todaysWorkout`; `vm.prepareWorkoutHandoff(day:)` | High. This is the main training handoff. |
| Primary kind `.recoverToday` | Primary card with `Start Light Workout` if today's workout exists | Yes. Calls workout handoff | `vm.todaysWorkout`; title/icon branch inside `coachPrimaryCTA` | High. Visuals must not make recovery look like a normal hard-training CTA. |
| Primary kind default/other | Primary card appears but `coachPrimaryCTA` returns `EmptyView()` | No primary CTA from this helper | `default: EmptyView()` for `.recoveryDay`, `.prepNextSession`, `.logBodyWeight`, `.logCompletion`, and any future unhandled kind | Medium/High. Card must still read as coaching guidance even when the data model has a `ctaTitle` but the view renders no CTA. |

## 4. Protected behavior map

| UI/action | Protected call/state | Trigger | Risk if changed | Must preserve | Notes |
|---|---|---|---|---|---|
| Decision stack existence | `if let briefing = vm.dailyBriefing` | Established branch render | Stack could show stale/empty recommendations or crash on missing briefing | Yes | Do not invent placeholder decision content in a visual pass. |
| Daily briefing source | `vm.dailyBriefing` from `DailyStateCoordinator.refreshBriefing()` and `DailyBriefingEngine.build(_:)` | Daily state refresh | Coach reasoning could disconnect from real readiness, plan, insight, and preference inputs | Yes | Do not bypass coordinator/engine paths. |
| Density side-signal logic | `density.sideSignalsLimit`; `showWatch`; `showMomentum` | `decisionStack` render | CoachingPreferences density stops controlling CoachTab complexity | Yes | Focused = 0, standard = 2, detailed = 4. |
| Simplicity emphasis suppression | `emphasis != .simplicity` | Momentum gate | Simplicity users get extra support signals they explicitly opted away from | Yes | Engine-level simplicity detail trimming is separate and also protected. |
| More Signals visibility | `briefing.moreSignalsCount > 0 && density != .focused` | `decisionStack` render | Focused users could see deeper signal doorway, or detailed/standard users could lose it | Yes | Keep count and density behavior unchanged. |
| More Signals route | `showMoreSignals = true` | Tap More Signals row | More Signals sheet could stop opening or gain new side effects | Yes | No analytics are currently tracked for this tap. |
| More Signals sheet destination | `NavigationStack { MoreSignalsSheet(vm: vm) }` | `showMoreSignals` sheet presentation | Expandable insights/recommendations could lose context or routes | Yes | Do not redesign sheet in the same pass as the row. |
| More Signals action behavior | `ExpandableInsightCard` and `ExpandableRecommendationCard` call AppViewModel action/undo methods | User expands and applies recommendations in sheet | Plan/progression mutations, undo, and analytics could regress | Yes | Never combine decision-stack shell work with MoreSignalsSheet action-card redesign. |
| Watch details expand/collapse | `showWatchDetails.toggle()` inside Reduce Motion aware animation | Tap Details in `watchCard` | Detail text can get stuck, lose accessibility timing, or become a sheet/route by accident | Yes | No analytics currently tracked. |
| Primary card CTA switch | `switch primary.kind` in `coachPrimaryCTA` | `primaryMoveCard` render | Wrong action could appear for a daily recommendation | Yes | Do not replace with generic `primary.ctaTitle` button without behavior planning. |
| Check-in CTA route | `.checkInBeforeTraining` sets `showReadinessCheckIn = true` | Tap primary Check in | Readiness check-in could be bypassed or converted into workout start | Yes | Sheet submission remains `vm.submitReadiness(readiness)`. |
| Workout handoff calls | `vm.prepareWorkoutHandoff(day:)` | Tap start/resume/train/recover CTA | Active workout resume and pre-workout handoff could break | Yes | `prepareWorkoutHandoff` handles active workout by unminimizing instead of opening a new handoff. |
| Recover title/icon logic | `.recoverToday` uses `heart.circle.fill` and `Start Light Workout`; `.trainToday` uses `bolt.fill` and `Start Workout` | Render train/recover CTA | Recovery recommendation can look like normal training or vice versa | Yes | Visual pass must keep title and branch behavior. |
| First-session fallback day | `.startFirstSession` uses `vm.todaysWorkout ?? vm.nextWorkout` | Render first-session CTA | First workout can disappear when today's workout is nil but next workout exists | Yes | Preserve fallback. |
| Default primary kinds | `default: EmptyView()` | Render other primary kinds | New generic CTA could route incorrectly for rest/prep/log states | Yes | Planning can flag the gap, not change it. |
| Lift tracker visibility | `vm.coachingConfidence >= .moderate`; nonempty stalled/progressing prefixes | `decisionStack` render | Low-signal users could see overconfident lift analysis | Yes | Confidence gate is trust-critical. |
| Stalled/progressing row semantics | regressing stalled = danger; other stalled = warning; progressing = success | `liftRow` render | Progression state could be misread | Yes | These colors are behavior-adjacent because they explain training state. |
| No decision-stack analytics changes | No direct analytics for primary CTA, watch details, More Signals row, or momentum | Taps/renders in stack | Analytics stream could gain unexpected events or lose downstream attribution | Yes | Keep absence of analytics where absence exists. |
| Existing analytics elsewhere | `.coach_viewed`, comeback events, memory bridge event, readiness logged, coach actions, undo, weekly review action events | Screen appear, comeback, sheets/actions | Existing funnels and event contracts could regress | Yes | Do not alter unrelated events while styling stack. |
| Copy/localization | Existing `L10n.tr` and `L10n.format` strings | Render/actions | Owner copy/localization changes sneak into visual work | Yes | No copy changes in first shell pass. |
| `ForgeTheme.color(for:)` on primary/watch | `ForgeTheme.color(for: primary.colorName)` and `ForgeTheme.color(for: watch.colorName)` | Card render | Semantic color names could change across modules unexpectedly | Yes for first pass | Color debt can be planned, but not mass-replaced here. |

## 5. Current visual diagnosis

`primaryMoveCard` still looks like a Forge/local card. It uses a conventional tinted stripe, icon well, grouped surface, gradient tint, border, and shadow. The information is useful, but the card does not yet feel like the coach's strongest reasoning moment.

`coachPrimaryCTA` still uses `ForgePrimaryButton` and the old orange/accent-gradient treatment. Because the CTA can open readiness or workout handoff, it is visually tempting but behaviorally unsafe as a first target.

`watchCard` and `momentumCard` look simpler and older than the accepted authority hero, early-state card, calibration checklist, and passive early-stage Weekly Check-In shell. They read as small grouped cards beneath a more premium hero rather than as a coherent coaching explanation.

The More Signals row is still generic. It looks like a quiet list doorway, but the destination contains expandable cards with plan-changing recommendation actions. The row should stay visually quiet, but it needs a clearer product role than "list row with chevron."

There is a real risk of making the whole stack too uniform. If primary, watch, momentum, More Signals, and lift tracker all become the same card shape, the screen will feel like a feed instead of a coach explaining its call.

The stack should read as a coaching explanation hierarchy:

1. Primary decision.
2. Watch signal.
3. Momentum/supporting signal.
4. More Signals.

Current warning/watch states can become heavy red or orange blocks because `watch.colorName` flows through `ForgeTheme.color(for:)`, where orange maps to `STRQPalette.energyAccent` rather than the calmer warning treatment used in some newer surfaces.

Momentum green is useful and semantically meaningful, but it can feel generic. It should support the coach's reasoning, not become a celebration card or streak/reward module.

## 6. Product goal for decisionStack

Define `decisionStack` as the coach's reasoning layer.

It should communicate:

- one primary recommendation
- supporting signals that make the recommendation feel earned
- a clear "why today" explanation
- a preference-aware surface shaped by CoachingPreferences
- a calm path into deeper signal detail
- a sense that STRQ is interpreting the user's training state, not just listing metrics

It is not:

- a feed
- a generic list
- a collection of equal cards
- an action marketplace
- a notification/settings row cluster
- a broad dashboard of every available signal

The ideal relationship:

- `primaryMoveCard` = the main decision
- `watchCard` = the caution/monitor signal
- `momentumCard` = the positive support signal
- More Signals = a compact deeper-evidence doorway
- `liftTrackerSection` = confidence-gated training evidence, not always-on decoration

## 7. What must not change

Protect:

- `vm.dailyBriefing` source and refresh path
- `DailyStateCoordinator`
- `DailyBriefingEngine`
- `briefing.primary`, `briefing.watch`, `briefing.momentum`, and `briefing.moreSignalsCount`
- density filtering through `vm.profile.coachingPreferences.density.sideSignalsLimit`
- focused density hiding side signals and More Signals
- simplicity emphasis suppressing momentum
- primary CTA switch behavior
- `.checkInBeforeTraining` route to readiness sheet
- readiness sheet route and `vm.submitReadiness(readiness)`
- workout handoff behavior through `vm.prepareWorkoutHandoff(day:)`
- active workout/progression flows
- `recoverToday` / `Start Light Workout` title and icon branch
- More Signals sheet route
- More Signals expandable recommendation/action behavior
- More Signals local expansion state
- Watch details toggle state and Reduce Motion aware animation
- lift tracker confidence condition
- stalled/progressing row conditions and color semantics
- analytics behavior, including existing gaps where no analytics currently exist
- copy/localization
- `AppViewModel`
- models, services, persistence, and analytics files
- `STRQDesignSystem.swift`, `STRQPalette.swift`, `ForgeTheme.swift`
- assets, fonts, RevenueCat/store files, Watch, Widget, Live Activity, project files, and tests

Do not change:

- workout start/resume/handoff behavior
- readiness submission
- More Signals recommendation application
- undo behavior
- progression/lift state calculation
- active workout behavior
- coaching preferences persistence or refresh behavior
- daily briefing generation

## 8. Visual redesign direction

Preserve hierarchy. The primary card should remain largest and most important. Watch and momentum should become supporting signal modules, not equal CTAs. More Signals should become a quiet expandable gateway, not a new action banner.

Use dark/carbon command-stack language, not settings rows. Profile and NotificationSettings row patterns are useful elsewhere, but CoachTab needs a reasoning surface with stronger hierarchy and less row sameness.

Use distinct but related shapes:

- primary = decision card
- watch = caution/monitor signal
- momentum = positive support signal
- more signals = compact doorway

Do not copy `earlyStateCard` or `calibrationChecklist`. Those modules solve calibration and early-stage trust. The decision stack solves established-user reasoning.

Do not use broad orange CTA styling by default. Orange/accent-gradient debt should be isolated and planned, especially around `coachPrimaryCTA`, not mass-replaced casually.

Avoid global color changes. Keep color work local to the chosen shell unless a separate color semantics pass is approved.

The first implementation should be display-only. Start with `momentumCard` or `watchCard`, not `primaryMoveCard` or `coachPrimaryCTA`. `momentumCard` is the safest first shell candidate because it has no tap target, route, model call, or expansion state.

## 9. Color and semantic accent policy

The primary card tint currently follows `ForgeTheme.color(for: primary.colorName)` and may be orange. Do not change this yet without a broader primary decision and CTA plan.

`watchCard` can use semantic warning/danger, but it should avoid becoming an alarming red slab. Watch is a monitor signal, not always an emergency.

`momentumCard` can use success green, but it should feel like a support signal, not a celebration. Keep success color localized to icon/accent and avoid reward/streak excess.

More Signals should be neutral/steel or quiet coach-blue/navy. It should not be CTA-orange, Pro violet, or a high-energy gradient.

Do not use Pro violet.

Do not reuse Notification colors blindly. Notification Coach Blue and reminder-specific colors have their own product meanings; decisionStack needs coach reasoning semantics.

Use color to clarify meaning, not decoration. The stack should be readable first through hierarchy, labels, and structure, with color as semantic reinforcement.

## 10. State coverage requirements

Any future implementation must cover:

- dailyBriefing present
- dailyBriefing absent
- all primary kinds reachable in test:
  - `.checkInBeforeTraining`
  - `.startFirstSession`
  - `.resumeWorkout`
  - `.trainToday`
  - `.recoverToday`
  - default/other kinds such as `.recoveryDay`, `.prepNextSession`, `.logBodyWeight`, `.logCompletion`
- watch present
- watch absent
- watch details collapsed
- watch details expanded
- momentum present
- momentum absent
- focused density
- standard density
- detailed density
- simplicity emphasis
- non-simplicity emphasis
- More Signals visible
- More Signals hidden by count
- More Signals hidden by focused density
- More Signals sheet opens
- More Signals sheet expandable insight cards expand/collapse
- More Signals sheet expandable recommendation cards expand/collapse
- no accidental recommendation/action application during visual QA unless owner approves disposable data
- coachingConfidence below moderate
- coachingConfidence moderate or higher
- lift tracker visible with stalled rows
- lift tracker visible with progressing rows
- lift tracker hidden with no stalled/progressing rows
- small iPhone layout
- large iPhone layout
- Reduce Motion on for watch details and entrance timing if possible
- Reduce Motion off
- no accidental plan-changing actions during visual QA

Rork QA is required after any Swift implementation. This docs-only pass does not complete Rork QA.

## 11. Risk rating

| Risk area | Rating | Reason |
|---|---:|---|
| Behavior risk | High | The stack contains readiness routing, workout handoff, More Signals sheet routing, watch expansion state, preference filtering, and confidence-gated lift analysis. |
| Workout/progression risk | High | Primary CTAs call `prepareWorkoutHandoff`, More Signals actions can mutate plans, and lift tracker semantics explain progression state. |
| Product trust risk | High | This area explains why STRQ is making a call; wrong hierarchy or overconfident visuals can damage the coach relationship. |
| Visual risk | Medium/High | The current area visibly lags behind accepted CoachTab hero/early modules, but broad unification would flatten the coaching hierarchy. |
| Owner approval need | High | Any Swift implementation should be owner-approved with exact state scope and Rork screenshots. |

Overall risk:

- Low for this docs-only pass.
- Low/Medium for a pure display-only `momentumCard` shell pass.
- Medium/High for `watchCard` because of expansion state and warning semantics.
- High for `primaryMoveCard`, `coachPrimaryCTA`, MoreSignalsSheet, workout handoff, readiness submission, or lift/progression logic.

## 12. Recommended implementation phases

1. Plan completed.
2. Choose one display-only candidate.
3. Implement one shell-only pass.
4. Rork QA.
5. Plan action-adjacent card.
6. Only later consider `primaryMoveCard`.
7. Only later consider `coachPrimaryCTA`.
8. Never combine decisionStack + MoreSignalsSheet redesign.

## 13. Exactly one recommended next implementation prompt

Chosen option: B. `momentumCard` display-only shell pass.

Reason: `momentumCard` is the safest useful implementation target in this decision-stack slice. It is display-only, has no tap target, no sheet route, no workout handoff, no readiness route, no expansion state, no analytics, and no plan/progression mutation. A shell pass here can establish the supporting-signal visual language before touching `watchCard` warning semantics or any primary/action behavior.

Use this exact prompt next:

```text
Work in repo: C:\Users\maxwa\Documents\GitHub\rork-strq

Goal:
Implement only a display-only visual shell refresh for CoachTab `momentumCard` so the established-user decision stack starts to read as a coaching explanation hierarchy. Preserve all behavior, copy, state sources, density/emphasis filtering, sheet routes, analytics behavior, and model/view-model/service logic. Do not touch primary recommendations, watch details, More Signals, lift tracker, workout handoff, or readiness routing.

Exact target file:
- ios/STRQ/Views/CoachTabView.swift

Exact target section/helper:
- `private func momentumCard(_ momentum: DailyBriefing.Momentum) -> some View`
- You may read `private var decisionStack` only to preserve visibility behavior.
- Do not edit `primaryMoveCard`, `coachPrimaryCTA`, `watchCard`, `moreSignalsLabel`, `liftTrackerSection`, `liftRow`, `MoreSignalsSheet`, `authorityHero`, `earlyStateCard`, `calibrationChecklist`, or `weeklyCheckInRow`.

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
- Preserve `if let briefing = vm.dailyBriefing` behavior.
- Preserve `primaryMoveCard(briefing.primary)` as the first decision-stack item.
- Preserve density side-signal logic exactly:
  - `density = vm.profile.coachingPreferences.density`
  - `sideLimit = density.sideSignalsLimit`
  - `showWatch = briefing.watch != nil && sideLimit >= 1`
  - `showMomentum = briefing.momentum != nil && sideLimit >= (showWatch ? 2 : 1) && emphasis != .simplicity`
- Preserve simplicity emphasis suppressing momentum.
- Preserve `momentumCard` as display-only: no Button, no tap gesture, no sheet, no route, no analytics, no model call.
- Preserve `momentum.icon` and `momentum.title`.
- Preserve existing copy/localization.
- Preserve `watchCard` and `showWatchDetails` behavior.
- Preserve More Signals visibility and `showMoreSignals = true`.
- Preserve `coachPrimaryCTA` switch behavior.
- Preserve readiness sheet route.
- Preserve all workout handoff calls.
- Preserve lift tracker visibility and row color semantics.
- Do not add, remove, or reroute analytics.
- Do not change AppViewModel, DailyStateCoordinator, DailyBriefingEngine, models, services, persistence, progression, active workout, or More Signals action behavior.

Visual objective:
- Make `momentumCard` feel like a positive supporting signal inside a coach decision stack.
- It should be related to the primary/watch surfaces but not identical.
- Keep it visually subordinate to `primaryMoveCard`.
- Use premium dark/carbon command-stack language, not a settings row.
- Use success green as a localized semantic accent, not a celebration slab.
- Avoid orange CTA gradients, Pro violet, copied Notification colors, reward styling, and generic feed-card sameness.
- Do not copy `earlyStateCard` or `calibrationChecklist`.
- Do not change global tokens or shared palette/theme files.

Verification commands:
- git status --short --branch
- git diff --name-only
- git diff -- ios/STRQ/Views/CoachTabView.swift docs/migration-progress-log.md
- git diff --name-only -- ios/STRQ/ViewModels ios/STRQ/Services ios/STRQ/Models ios/STRQ/Utilities/STRQDesignSystem.swift ios/STRQ/Utilities/STRQPalette.swift ios/STRQ/Utilities/ForgeTheme.swift ios/STRQ/Views/ReadinessCheckInView.swift ios/STRQ/Views/WeeklyCheckInView.swift ios/STRQ/Localizable.xcstrings ios/STRQWidget ios/STRQWatch
- rg -n "private var decisionStack|momentumCard|showMomentum|sideSignalsLimit|emphasis != \\.simplicity|showMoreSignals|showWatchDetails|coachPrimaryCTA|prepareWorkoutHandoff|showReadinessCheckIn|liftTrackerSection" ios/STRQ/Views/CoachTabView.swift
- rg -n "CoachTab Momentum|momentumCard|decision stack|Rork|display-only" docs/migration-progress-log.md

Rork QA checklist:
- Established user with primary + momentum and no watch, if reachable.
- Established user with primary + watch + momentum.
- Momentum hidden when `briefing.momentum == nil`.
- Momentum hidden for focused density.
- Momentum hidden for simplicity emphasis.
- Momentum visible for standard/detailed density when side-signal logic allows it.
- Primary card remains visually dominant.
- Watch card, if present, remains unchanged.
- More Signals row still opens the sheet when visible.
- No workout handoff is triggered by momentum.
- No readiness sheet is triggered by momentum.
- No analytics event is emitted by momentum.
- Small iPhone layout has no clipping or overlap.
- Large iPhone layout keeps momentum supportive, not equal to primary.
- No orange CTA gradient, Pro violet, copied Notification color, or reward styling appears.

Push command after successful verification:
git status --short --branch
git add ios/STRQ/Views/CoachTabView.swift docs/migration-progress-log.md
git commit -m "polish coach momentum signal shell"
git push
```

This is the only recommended next implementation prompt in this report.

## 14. Rork QA checklist

- [ ] `dailyBriefing` absent: no decision stack appears and later CoachTab modules still render according to their own gates.
- [ ] `dailyBriefing` present: primary recommendation appears.
- [ ] Primary only state.
- [ ] Primary + watch state.
- [ ] Primary + momentum state.
- [ ] Primary + watch + momentum state.
- [ ] Focused density hides watch, momentum, and More Signals.
- [ ] Standard density can show watch and momentum when data exists.
- [ ] Detailed density can show watch and momentum and the More Signals doorway when data exists.
- [ ] Simplicity emphasis suppresses momentum.
- [ ] Watch details collapsed.
- [ ] Watch details expanded.
- [ ] Watch details respects Reduce Motion if testable.
- [ ] More Signals visible when count exists and density is not focused.
- [ ] More Signals hidden when count is zero.
- [ ] More Signals hidden in focused density.
- [ ] More Signals sheet opens.
- [ ] More Signals expandable insight cards expand/collapse.
- [ ] More Signals expandable recommendation cards expand/collapse.
- [ ] Do not apply More Signals plan-changing actions unless owner approves disposable/safe data.
- [ ] Coaching confidence below moderate hides lift tracker.
- [ ] Coaching confidence moderate or high evaluates lift tracker.
- [ ] Lift tracker visible with stalled exercises.
- [ ] Lift tracker visible with progressing exercises.
- [ ] Lift tracker hidden when no stalled/progressing rows exist.
- [ ] Stalled/regressing row uses danger semantics.
- [ ] Stalled/non-regressing row uses warning semantics.
- [ ] Progressing row uses success semantics.
- [ ] `.checkInBeforeTraining` primary opens readiness sheet.
- [ ] `.startFirstSession` primary calls workout handoff.
- [ ] `.resumeWorkout` primary calls workout handoff.
- [ ] `.trainToday` primary calls workout handoff.
- [ ] `.recoverToday` primary shows `Start Light Workout` and calls workout handoff.
- [ ] Default/other primary kinds do not gain a new CTA.
- [ ] Small iPhone layout has no clipping, text collision, or overlarge card treatment.
- [ ] Large iPhone layout preserves hierarchy and does not feel like equal feed cards.
- [ ] No accidental workout/progression/readiness/More Signals action during visual QA.
- [ ] No analytics changes.
- [ ] No copy/localization changes.
- [ ] No global palette/theme/design-system changes.
- [ ] Rork QA is required after any Swift implementation; it is not completed by this docs-only pass.
