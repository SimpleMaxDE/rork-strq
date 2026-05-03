# STRQ Foundation Hardening Pass 1

## 1. Executive Summary

STRQ has a functional app and a stronger DEBUG Design System Lab, but production UI still mixes old and new systems. The app already has strong product structure; the foundation problem is visual ambiguity, not missing product logic.

The main goal of this pass is to reduce ambiguity before more Swift changes. CTA, accent, surface, card, list, section-header, chip, badge, and progress usage needs a stricter policy before production migration expands.

CTA/accent policy must be hardened before touching Onboarding, Today, Coach, Train, Paywall, or Active Workout. Those areas contain protected behavior, high-action density, or revenue/first-run implications.

Profile remains the safest early production surface because one row cluster already uses `STRQSectionHeader`, `STRQListItem`, `STRQIcon`, and `STRQColors` without touching core training behavior.

This pass makes no Swift changes.

## 2. Current Foundation Problem

Production still uses multiple visual systems at once: `STRQPalette`, `STRQBrand`, `ForgeTheme`, `ForgeSurface`, `ForgeSectionHeader`, `STRQMetricTile`, `STRQBadgeChip`, `STRQPrimaryCTA`, local row/card/chip helpers, direct SwiftUI controls, SF Symbols, and limited `STRQDesignSystem` adoption.

Old Forge helpers and local helpers create inconsistency because each screen makes its own choices for surface depth, accent usage, row density, chip tone, CTA treatment, and section headers.

Orange and warm accent treatment appear too broadly. They appear as primary CTAs, selected states, progress bars, onboarding choices, paywall badges, active-workout actions, daily-priority cues, and training-day markers. Existing usage should be treated as inventory and migration debt, not as proof that orange is STRQ's primary brand color.

`STRQDesignSystem` exists and is broad, but production adoption is not broad. Current production use is mainly the `ProfileView.controlsSection` row cluster. The DEBUG lab shows a more STRQ-owned foundation, but it is not final production proof.

Future work must replace one bounded visual cluster at a time. Adding a new wrapper on top of Forge and local helpers would deepen the inconsistency; each implementation pass should remove or contain one visual cluster.

## 3. CTA System Inventory

Targeted search covered the requested utility files and production screens. Broader app-wide button behavior outside those targets requires follow-up inspection.

| CTA/button system | File path | Production or DEBUG-only | Likely visual style | Where found | Behavior risk | Disposition | Owner approval before changing |
|---|---|---|---|---|---|---|---|
| `STRQButton` | `ios/STRQ/Utilities/STRQDesignSystem.swift` | Mostly DEBUG-only; used inside `STRQEmptyStateCard` and previews | Neutral/white primary, graphite secondary, ghost, destructive, compact, icon-only, disabled, loading placeholder | DEBUG lab buttons and internal preview examples; no targeted production screen uses it directly | Medium, because migration must preserve closures, disabled/loading state, accessibility, and sizing | Keep; validate in Design System Lab before production CTA migration | No for DEBUG/lab QA; yes for protected screens |
| `STRQIconButton` | `ios/STRQ/Utilities/STRQDesignSystem.swift` | DEBUG-only in targeted files | Neutral/white icon button with selected/destructive variants | DEBUG lab | Medium | Keep; use only in low-risk rows after icon mapping is approved | Depends on target |
| `STRQPrimaryCTA` | `ios/STRQ/Utilities/ForgeTheme.swift` | Production | 54pt orange/warm gradient, black text, glossy top overlay, warm shadow | `DashboardView` daily check-in, body-weight log, start first session, resume workout, training-day CTA | High, because it can start/resume workout, open readiness, or open logs | Keep temporarily; do not expand; later replace or wrap only after CTA policy is approved | Yes for Today/start/resume contexts |
| `ForgePrimaryButton` | `ios/STRQ/Utilities/ForgeTheme.swift` | Production | Orange/warm gradient, black text, 54pt height | `CoachTabView.coachPrimaryCTA`; `TrainingPlanView.trainStartBar` | High, because it starts workouts or readiness flow | Keep temporarily; avoid new use; migrate only in exact, owner-approved CTA pass | Yes for Coach/Train actions |
| `ForgeSecondaryButton` | `ios/STRQ/Utilities/ForgeTheme.swift` | Defined; no targeted production usage found | Steel gradient secondary button | Definition only in targeted search | Low if unused; requires follow-up inspection if used outside targets | Avoid new use; keep until Forge retirement plan | No if unused; yes if replacing in protected flow |
| Direct SwiftUI `Button` with local warm gradient | `OnboardingView.swift`, `PlanRevealView.swift`, `ActiveWorkoutView.swift`, `STRQPaywallView.swift`, `ReadinessCheckInView.swift`, `NutritionLogView.swift`, `SleepLogView.swift`, `ProfileView.swift` | Production | Per-screen CTAs, usually `STRQBrand.accentGradient`, black or white text | Onboarding navigation, Plan Reveal start, active workout finish/log/next/rest, Paywall purchase/done/retry, Readiness continue/done, Nutrition/Sleep saves, Profile Pro entry | High in protected flows; medium in Profile/nutrition/sleep | Keep temporarily; inventory only; do not mass-replace | Yes for Onboarding, Plan Reveal, Active Workout, Paywall, Readiness; target-specific elsewhere |
| SwiftUI `Button` with `role: .destructive` | `ProfileView.swift`, `TrainingPlanView.swift`, `ActiveWorkoutView.swift` | Production | Native destructive alert/menu treatment | Reset data, sign out, cloud restore confirm, discard workout, remove/restore training actions | Highest where data/workout changes occur | Keep; do not restyle in early passes | Yes |
| SwiftUI `.buttonStyle(.borderedProminent)` / `.buttonStyle(.bordered)` | `NotificationSettingsView.swift` | Production | Native iOS button style, steel tint for enable button | Notification authorization enable/settings buttons | Medium/High because permission and Settings routing are protected | Keep; plan row/toggle styling separately | Yes before implementation |
| `.buttonStyle(.strqPressable)` | `ios/STRQ/Utilities/STRQInteraction.swift` and many views | Production interaction style | Subtle scale/dim pressed behavior | Profile, Dashboard, Coach, Onboarding, Active Workout, Exercise Library, sheets | Low visual risk; behavior neutral | Keep as interaction style; not a CTA identity | No if unchanged |
| `.buttonStyle(.strqStepper)` | `ios/STRQ/Utilities/STRQInteraction.swift`, `ActiveWorkoutView.swift` | Production | Tactile scale/dim for stepper controls | Active workout load/reps steppers | High because live workout editing | Keep; no early styling changes | Yes |
| `.buttonStyle(.plain)` | Multiple targeted screens | Production | Native/plain row taps without default button chrome | Profile links, Coach rows, Train exercise rows, Active Workout rows, Plan Reveal, Paywall details | Varies by target | Keep until row/list target is exact | Target-specific |
| `SignInWithAppleButton` | `ProfileView.swift` | Production system control | Apple sign-in white button | iCloud/account sign-in | High account behavior risk | Keep untouched | Yes |

CTA inventory conclusion: the safest near-term CTA primitive is `STRQButton`, but it is not yet production-proven. Orange-gradient production CTAs should remain temporarily, not expanded, until the neutral/graphite-first policy is validated in the lab and approved for each protected screen.

## 4. Orange/Accent Usage Inventory

Targeted search found no `Color.orange` or `systemOrange` in the requested production targets. Warm/orange usage mainly enters through `STRQBrand.accentGradient`, `STRQPalette.energyAccent`, `STRQPalette.energyAccentGradient`, and `STRQColors` orange/warm aliases.

| File/path | Context | Role | Current assessment | Protected behavior touched | Recommended next action |
|---|---|---|---|---|---|
| `ios/STRQ/Utilities/STRQDesignSystem.swift` | Orange 50-950 tokens, warm aliases, `orangeCTA`, `orangeGlow`, `progressOrange`, chip tone `.orange` | Foundation token compatibility | Acceptable as optional token inventory, questionable if treated as default brand/action | No direct behavior | Keep; document as optional warm accent, not default CTA |
| `ios/STRQ/Utilities/STRQPalette.swift` | `energyAccent`, `energyAccentSoft`, `energyAccentGradient` | Legacy warm production accent | Migration debt if used broadly as primary identity | No direct behavior | Keep temporarily; do not expand |
| `ios/STRQ/Utilities/ForgeTheme.swift` | `STRQBrand.accentGradient`, `STRQPrimaryCTA`, `ForgePrimaryButton`, `STRQBadgeChip.variant.accent`, `STRQMetricTile.tint` default | CTA, badge, metric, surface fallback | Questionable as broad default | No direct behavior in utility, but consumed by protected screens | Keep temporarily; migrate by bounded component passes |
| `ProfileView.swift` | Pro upsell icon uses `STRQBrand.accentGradient`; rest of Profile uses steel/success/warning/red and one STRQ row cluster | Subscription entry accent and status colors | Questionable but contained; Profile remains safest target outside subscription/account/danger | Paywall entry, restore, reset, account, nutrition toggles | Inspect visually; do not change subscription/account/danger in early pass |
| `DashboardView.swift` | `STRQPrimaryCTA`, priority pill, early-stage hint, training week today marker, energy accent progress, `STRQBadgeChip.variant.accent` | CTA, selected/current day, progress, badge | Migration debt because orange appears across Today modules | Start/resume workout, readiness, logs, weekly state | Owner decision required before CTA change; display-only module selection first |
| `CoachTabView.swift` | `ForgePrimaryButton`, accent gradient chips/markers, success/warning progression rows | CTA, decoration, progress/coach signal | CTA usage is migration debt; semantic success/warning mostly acceptable | Readiness, start/resume workout, coach actions/sheets | Keep CTAs; migrate only after policy and owner approval |
| `TrainingPlanView.swift` | Orange top strip on workout card, `ForgePrimaryButton` Review & Start, warning/success role colors | CTA, card accent, role/semantic state | CTA and accent strip are debt; warm-up warning is likely acceptable | Start workout, plan edit/schedule/swap/remove | Do not change early; display-only planning only |
| `OnboardingView.swift` | Accent progress bar, primary navigation CTA, selected cards/options | CTA, selected state, progress | High-priority migration debt, but protected | Onboarding profile inputs and plan generation | Owner approval required; no implementation in early passes |
| `PlanRevealView.swift` | Sticky Start Workout 1 CTA uses accent gradient | First-workout CTA | Migration debt but high first-run risk | Completes onboarding and starts handoff | Owner approval required; no early implementation |
| `ActiveWorkoutView.swift` | Finish/log set/next/rest CTAs, undo, notes save, rest progress warning, set quality colors | Active workout CTAs, progress, selected quality, warning | Highest-risk debt; some warning/success semantics are valid | Live workout mutation, persistence, rest, HealthKit, Watch/Live Activity side effects | Keep untouched; dedicated later pass only |
| `STRQPaywallView.swift` | Purchase button, Done, Try Again, savings/package badges use accent gradient; Pro status uses success | Paywall CTA and reward/badge | Revenue-sensitive migration debt | RevenueCat package selection, purchase, restore, entitlement | Owner approval required; planning only |
| `ReadinessCheckInView.swift` | Progress bar, motivation selected state, bottom CTA, result CTA use accent gradient; readiness states use success/warning/danger | Progress, CTA, selected, semantic state | CTA/progress accent debt; readiness semantics need QA | Daily readiness writes and coach response | Owner approval required before implementation |
| `NotificationSettingsView.swift` | Steel tint plus `.mint`, `.blue`, `.purple`, `.pink` section icons | Section accents, system buttons, toggles | Questionable because local color semantics are not mapped to STRQ tokens | Notification scheduling, HealthKit auth/sync | Plan only; exact semantic map required |
| `ExerciseLibraryView.swift` | Selected chips use steel; `"orange"` maps to steel; direct `.green`, `.yellow`, `.red`, `.blue`, `.purple` in status/difficulty | Filters, badges, selected state | Orange is partly neutralized; direct system colors are policy debt | Exercise identity, filters, favorites, progression badges | Inspect visually; plan filter/chip migration later |
| `ProgressAnalyticsView.swift` | Many `.green`, `.yellow`, `.red`, `STRQPalette.success/warning`, chart series and badge colors | Charts, progress, reward, semantic state | Semantic intent is mostly valid; direct system colors need policy normalization | Progress calculations, history, charts | Owner selects one display-only module later |
| `NutritionLogView.swift` | Log Nutrition CTA uses accent gradient; macros use blue/green/purple; `"orange"` maps to steel | CTA, nutrition category colors | CTA debt; semantic colors require nutrition policy | Nutrition persistence and targets | Migrate later after form/input policy |
| `SleepLogView.swift` | Save CTA uses accent gradient; sleep impact uses green/yellow/red | CTA and sleep/recovery semantics | CTA debt; sleep semantics need STRQ mapping | Sleep persistence/recovery state | Migrate later after form/input policy |

This is not a mass replacement recommendation. Warm/orange usage should be reduced only through small, owner-approved migrations with visual QA.

## 5. Surface/Card/List/Header Inventory

| Component/helper | File path | Production or DEBUG-only | Current role | Likely replacement primitive | Migration risk | Good early target |
|---|---|---|---|---|---|---|
| `STRQSurface` | `ios/STRQ/Utilities/STRQDesignSystem.swift` | DEBUG/lab and internal primitive | Card/elevated/inset/selected surface shell | Itself | Medium until production QA | Yes, inside Profile or lab QA first |
| `STRQCard` | `ios/STRQ/Utilities/STRQDesignSystem.swift` | DEBUG/lab and internal primitive | Standard/elevated/selected/compact/hero card | Itself | Medium | Yes after row cluster proof |
| `STRQListItem` | `ios/STRQ/Utilities/STRQDesignSystem.swift`, `ProfileView.swift` | Production in Profile controls; DEBUG elsewhere | List row with icon/avatar/trailing/chevron/divider/selected/disabled | Itself | Low in Profile, medium elsewhere | Yes |
| `STRQSectionHeader` | `ios/STRQ/Utilities/STRQDesignSystem.swift`, `ProfileView.swift` | Production in Profile controls; DEBUG elsewhere | Section title with optional trailing content | Itself | Low | Yes |
| `STRQMetricCard` | `ios/STRQ/Utilities/STRQDesignSystem.swift` | DEBUG-only in targeted screens | Future metric card with progress/delta | Itself | Medium | Later display-only Dashboard/Progress module |
| `ForgeSurface` | `ios/STRQ/Utilities/ForgeTheme.swift`, `DashboardView.swift` | Production | Main Today module shell with accent borders and gradients | `STRQSurface` or `STRQCard` plus screen wrapper | Medium/High because Today is behavior-coupled | Not first; select one display-only module later |
| `ForgeCard` | `ios/STRQ/Utilities/ForgeTheme.swift` | Defined; less visible in key targeted screens | Older card wrapper with optional accent strip | `STRQCard` | Requires follow-up inspection | Not first |
| `ForgeSectionHeader` | `ForgeTheme.swift`, `ProfileView.swift`, `CoachTabView.swift`, `ProgressAnalyticsView.swift`, `WeightQuickLogSheet.swift` | Production | Older uppercase section header with steel accent | `STRQSectionHeader` | Low in display sections, higher in protected flows | Profile only first |
| `STRQSectionTitle` | `ForgeTheme.swift`, `DashboardView.swift` | Production | Older section title with 3px accent bar | `STRQSectionHeader` or local display wrapper | Medium because Today modules are coupled | Not first |
| `STRQMetricTile` | `ForgeTheme.swift`, `DashboardView.swift` | Production | Compact metric tile with optional progress | `STRQMetricCard` | Medium because tiles carry dynamic data | Later display-only module |
| Local grouped surfaces | `ProfileView.swift`, `NotificationSettingsView.swift`, `ExerciseLibraryView.swift`, `ReadinessCheckInView.swift`, `STRQPaywallView.swift`, `OnboardingView.swift` | Production | System grouped backgrounds and local rounded rectangles | `STRQSurface`, `STRQCard`, `STRQListItem`, `STRQToggleRow` depending role | Varies | Profile/Notification planning only |
| Local row helpers | `ProfileView.swift`, `NotificationSettingsView.swift`, `TrainingPlanView.swift`, `ExerciseLibraryView.swift`, `ActiveWorkoutView.swift`, other screens require follow-up inspection | Production | Screen-specific rows and tap targets | `STRQListItem`, `STRQToggleRow`, or dedicated row wrapper | Varies; high in training/workout | Profile row cluster only first |
| Local card helpers | `TrainingPlanView.swift`, `ExerciseLibraryView.swift`, `ProgressAnalyticsView.swift`, `ReadinessCheckInView.swift`, `STRQPaywallView.swift`, `ActiveWorkoutView.swift` | Production | Screen-specific display/action cards | `STRQCard`, `STRQMetricCard`, later dedicated wrappers | Medium/High | Display-only modules after Profile |
| Local section helpers | `NotificationSettingsView.sectionHeader`, `TrainingPlanView.roleSectionHeader`, `ExerciseLibraryView` pinned headers, `ProgressAnalyticsView` helpers | Production | Section labels, icon headers, pinned list headers | `STRQSectionHeader` plus domain wrappers | Medium | Notification planning; Profile first |
| `GroupedListStyle` / `.listStyle` | `SessionEditorSheet.swift` found in broad search | Production | System list style in editor sheet | Requires follow-up inspection | High because editor mutates plan | No |

## 6. Chip/Badge/Progress Inventory

| Component/helper | File path | Current role | Semantic risk | Visual risk | Likely future primitive | Owner approval required |
|---|---|---|---|---|---|---|
| `STRQChip` | `STRQDesignSystem.swift`, DEBUG lab | Neutral/selected/success/warning/danger/disabled chips | Low/Medium; `.orange` tone exists and must stay non-default | Low after lab QA | Itself | No for DEBUG; target-specific for production |
| `STRQBadge` | `STRQDesignSystem.swift`, DEBUG lab | Count/status/achievement badge | Low/Medium; achievement tone needs reward policy | Low after lab QA | Itself | Target-specific |
| `STRQBadgeChip` | `ForgeTheme.swift`, `DashboardView.swift` | Production badge/chip helper, including `.accent` | Medium because `.accent` means warm/orange | Medium | `STRQBadge` or `STRQChip` | Yes for Dashboard/Today |
| `ForgeChip` | `ForgeTheme.swift`, `ProfileView.swift` | Focus muscle chips in Profile training setup | Low behavior risk | Medium visual inconsistency | `STRQChip` | No if Profile non-danger only and copy/actions unchanged |
| Local chips | `ProfileView.swift`, `ExerciseLibraryView.swift`, `TrainingPlanView.swift`, `ReadinessCheckInView.swift`, `ProgressAnalyticsView.swift`, `STRQPaywallView.swift`, `ActiveWorkoutView.swift` | Filters, status, difficulty, package badges, set deltas | Medium; direct system colors and warm accents are mixed | Medium/High in protected flows | `STRQChip`, `STRQBadge`, domain wrappers | Target-specific; yes for protected flows |
| `STRQProgressBar` | `STRQDesignSystem.swift`, DEBUG lab and internal `STRQMetricCard` | Neutral/success/warning/danger progress bar | Low if semantic tone is mapped | Low after lab QA | Itself | Target-specific |
| `STRQProgressRing` | `STRQDesignSystem.swift`, DEBUG lab | Score/activity/compact ring | Medium; score tone must be semantic | Medium until production QA | Itself | Target-specific |
| `STRQProgressRow` | `STRQDesignSystem.swift`, DEBUG lab | Label/value/progress row | Medium | Medium | Itself | Target-specific |
| `STRQMetricTile` custom progress | `ForgeTheme.swift`, `DashboardView.swift` | Production tile progress | Medium because tint may be warm by default | Medium | `STRQMetricCard` + `STRQProgressBar` | Yes for Dashboard |
| Onboarding progress | `OnboardingView.swift` | Step progress bar with warm gradient | High because first-run flow | Medium | `STRQProgressBar` after onboarding policy | Yes |
| Readiness progress/result ring | `ReadinessCheckInView.swift` | Step progress, readiness score/result dial | Medium/High because writes daily state | Medium | `STRQProgressBar` / `STRQProgressRing` after form policy | Yes |
| Active workout progress/rest rings | `ActiveWorkoutView.swift` | Workout completion strip, rest countdown, set status | High because live workout state | High | Dedicated active-workout progress wrapper later | Yes |
| Exercise Library filters/badges | `ExerciseLibraryView.swift` | Selected filters, progression/difficulty/favorite badges | Medium because filters affect discovery | Medium | `STRQChip`, `STRQBadge` | Yes before implementation |
| Progress analytics charts/badges | `ProgressAnalyticsView.swift` | PR/reward chips, chart series, metric deltas | Medium because derived data must remain exact | Medium | `STRQBadge`, `STRQMetricCard`, chart wrapper later | Yes to choose cluster |
| Paywall package badges/loading | `STRQPaywallView.swift` | Savings/trial badges, purchase `ProgressView`, disabled CTA | High revenue semantics | High | Dedicated paywall plan card later | Yes |

## 7. Production Styling Debt Map

| Area / screen | Current styling systems | Main visual debt | Protected logic risk | Early migration suitability | Recommended next action |
|---|---|---|---|---|---|
| Profile | `STRQSectionHeader`/`STRQListItem` in controls; Forge headers; local rows/cards; `STRQBrand`; `STRQPalette`; SF Symbols | Mixed old/new sections; Pro/account/danger rows visually separate from STRQ row cluster | Medium; account, restore, paywall, reset are sensitive | High only for non-danger, non-account row clusters | Finish controlsSection, then one non-danger row cluster |
| NotificationSettings | Local section headers, native buttons, system grouped rows, steel/system accent colors | Good row/toggle candidate but local styling and ad hoc semantic colors | Medium/High; scheduling, permission, HealthKit | Planning yes; implementation only with approval | Create exact row/toggle implementation prompt after Profile |
| Dashboard / Today | `ForgeSurface`, `STRQPrimaryCTA`, `STRQMetricTile`, `STRQBadgeChip`, `STRQPalette`, local cards | Heavy warm CTA/accent usage and mixed metric/surface patterns | High; workout start/resume, readiness, logs, analytics | Low early; one display-only module later | Owner selects one display-only module after foundation QA |
| Coach | `ForgePrimaryButton`, Forge headers, local cards, semantic colors, SF Symbols | Coach action/card language not yet premium or unified | High; coach actions and recommendations | Low early | Plan only; do not change action cards |
| Train | Local workout card, `ForgePrimaryButton`, local role rows, warm strip | High action density; start CTA and plan rows are visually bespoke | High; plan mutation/start/schedule/edit | Low early | Later display-only wrapper planning only |
| ExerciseLibrary | Local search/filter chips, local cards, `ExerciseThumbnail`, direct system colors | Chips/cards are good candidates but behavior and identity must remain exact | Medium/High; filters, favorites, exercise IDs | Medium after Profile | Plan filter chip cluster with exact selected-state policy |
| ExerciseDetail | Local section/card helpers, media/anatomy-related visuals, progression reads | Anatomy/media opportunity is not scoped; many local helpers | Medium/High | Low early | Defer; no anatomy/media import in this pass |
| Progress | Local analytics cards/charts, many Forge headers, celebration badges, direct colors | High visual density and direct system color use | Medium/High; calculations/history | Medium after Profile/Dashboard metric proof | Plan one display-only metric/card cluster |
| Onboarding | Local cards/options, warm progress, warm primary CTA | Orange-heavy first-run identity; form primitives not hardened | High; profile inputs and plan generation | Not early | Owner-approved planning only |
| PlanReveal | Local sticky start CTA, plan quality displays | Warm first-workout CTA and first-run handoff risk | High | Not early | Owner-approved planning only |
| ActiveWorkout | Local full-screen system, custom CTAs/progress/steppers/rest sheets | Highest action density; visual changes can affect live logging confidence | Highest | Not ready | Dedicated later pass only |
| STRQPaywall | Local paywall cards/buttons, warm purchase/done/retry CTAs, `ProgressView` | Revenue-sensitive CTA and package selection styling | High | Not ready | Planning only with RevenueCat preservation checklist |
| NutritionSettings | Requires follow-up inspection | Likely local form/input and nutrition semantic colors | Medium | Not first | Inspect before any implementation |
| SleepLog / Sleep & Recovery | Local input/cards, warm save CTA, green/yellow/red sleep impact | Form and semantic color mapping not hardened | Medium | Later | Plan after form/input primitive QA |
| ReadinessCheckIn | Local segmented controls, warm progress/CTA, semantic readiness ring | CTA/selected/progress debt; writes daily state | Medium/High | Not early | Dedicated form/semantic pass later |

## 8. Proposed STRQ CTA Policy v1

This is a first production policy draft, not final brand law.

| CTA variant | Intended visual direction | Allowed accent use | Forbidden visual choices | Protected behavior notes | Owner approval required | First safe test area |
|---|---|---|---|---|---|---|
| Primary | Neutral/white/graphite-first; calm, precise, high contrast | Warm/orange only if exact state and screen are approved | Orange as default primary CTA; glossy warm gradient by default | Preserve closures, analytics, copy, navigation, disabled/loading, accessibility | No for low-risk Profile; yes for protected screens | DEBUG Lab, then Profile non-critical action |
| Secondary | Graphite/control-surface with subtle border | None by default; steel/neutral only | Competing warm gradients or equal weight to primary | Preserve all route/sheet/action behavior | Target-specific | Profile controls or settings rows |
| Tertiary / text | Text or ghost treatment; low visual weight | None by default | Filled capsule pretending to be CTA | Preserve link/button semantics and tap target | Target-specific | Profile legal/tools rows |
| Destructive | Deliberate danger/red semantics, usually native destructive or danger surface | Orange not allowed | Warm motivational color for dangerous actions | Reset, discard, sign out, remove, restore must remain exact | Yes | None in early production |
| Disabled | Lower opacity, muted text, no ambiguous accent | No | Disabled warm CTA that still looks tappable | Preserve `.disabled`, loading guards, and validation | Target-specific | DEBUG Lab |
| Loading | Same variant footprint with visible progress/placeholder; no layout jump | No new accent unless variant already approved | Changing copy/state timing or disabling purchase/start safeguards | Preserve `isLoading`, `store.isPurchasing`, validation, async task entry | Yes for Paywall; target-specific elsewhere | DEBUG Lab only |
| Selected | Selection is state, not CTA; use surface/border/contrast first | Controlled semantic accent only if selection meaning requires it | Default selected state as orange | Preserve selection bindings | Target-specific | ExerciseLibrary planning later |
| Floating / bottom CTA | Reserved for persistent screen actions; neutral primary unless approved | Warm/orange only for approved high-energy flow | Bottom warm CTA everywhere | Preserve safe area, scroll visibility, closures | Yes if Today/Train/Onboarding/Workout/Paywall | Profile none; DEBUG only |
| Active Workout CTA | Do not change in early passes | Requires dedicated active workout policy | Any early restyling of finish/log/next/rest CTAs | Preserve set logging, rest, finish, undo, notes, navigation | Yes | Not ready |
| Paywall CTA | Do not change in early passes | Requires owner-approved revenue treatment | Changing purchase hierarchy, package selection, restore, copy | Preserve `store.purchase`, `store.restore`, selection, loading/error/pro states | Yes | Planning only |
| Onboarding CTA | Do not change in early passes | Requires owner-approved first-run treatment | Changing setup flow, labels, disabled rules, handoff | Preserve profile bindings, phase order, plan generation, completion | Yes | Planning only |

Policy rules:

- Orange is not default primary CTA.
- Primary should be neutral/white/graphite-first unless explicitly approved.
- Do not change Active Workout, Paywall, or Onboarding CTA treatment in early passes.
- CTA changes must preserve action closures, analytics, disabled/loading state, copy, bindings, and navigation.

## 9. Proposed STRQ Accent/Semantic Color Policy v1

This is a first policy draft for implementation prompts and visual QA. It should be refined with owner screenshots and Design System Lab validation.

| State | Desired STRQ direction | Orange allowed | Visual QA needed | Owner approval required | Screens affected |
|---|---|---|---|---|---|
| Primary accent | Neutral/white/graphite-first product identity | No by default | Lab CTA, Profile row/action tests | Yes if warm/orange is proposed | All |
| Selected | Surface, border, contrast, and icon emphasis before color | Rarely; only if exact product meaning is approved | Exercise filters, onboarding cards, schedule/day chips | Yes for protected screens | Onboarding, ExerciseLibrary, Train, ActiveWorkout |
| Focus | Subtle white/graphite focus ring or accessible state | No | Lab focus/keyboard/accessibility if scoped | Target-specific | Inputs, buttons, rows |
| Success | Calm green/lime only for on-track/progressing/approved/completed | No | Contrast and overuse checks | No unless protected behavior touched | Dashboard, Coach, Train, Progress, Profile, ActiveWorkout |
| Warning | Amber/caution for monitor/mixed/moderate states | Warm amber allowed; not CTA orange | Distinguish from reward and selected | Target-specific | Readiness, Train, Progress, ExerciseDetail |
| Destructive | Danger/rose/red, unmistakable and restrained | No | Alert/menu/button states | Yes for destructive flows | Profile, ActiveWorkout, Train |
| Readiness/recovery | Score-based semantic mapping with calm status treatment | Not as default; use amber/red/green semantics | Readiness score/ring/card QA | Yes before implementation | Dashboard, Coach, ReadinessCheckIn, Progress |
| Sleep | Recovery semantic scale; avoid playful colors | No | Sleep duration/quality states | Target-specific | Dashboard, SleepLog, Progress |
| Nutrition | Goal/adherence semantics; avoid random macro palette dominance | No by default | Nutrition target/log cards | Target-specific | NutritionLog, NutritionSettings, Dashboard, Progress |
| Progress/PR/reward | Earned, calm gold/success/neutral; no noisy gamification | Rare; owner-approved only | PR, streak, completion, celebration states | Yes for reward system changes | Progress, WorkoutCompletion, Dashboard |
| Chart series | Limited semantic palette with labels/legends; not color-only | No as default | Contrast, color distinction, legend clarity | Yes to choose chart module | Progress, Dashboard |
| Disabled | Muted graphite/gray; visually inactive | No | Tap target and readability | Target-specific | All |
| Informational | Steel/blue-gray, secondary text, restrained icon | No | Coach/info cards and settings | Target-specific | Profile, Coach, Notifications |

## 10. Proposed STRQ Surface/Card/List Policy v1

Surface hierarchy:

- App background: carbon/black base; should recede and not compete with content.
- Base surface: standard content group, quiet border, minimal shadow.
- Raised surface: important display module, still restrained; use sparingly.
- Selected surface: contrast/border first, not automatic orange.
- Modal surface: elevated, clear border, stable padding, no extra decorative layers.

Card density rules:

- Cards should improve scanning, not create a stack of decorative boxes.
- Use compact cards for rows or repeated metrics.
- Use elevated/hero cards only for one lead module per surface.
- Avoid nested-card clutter. If a row group sits inside a card, inner rows should usually be flat or divided, not full cards.

List row density rules:

- Use `STRQListItem` for settings/list rows with icon, title, optional subtitle, trailing value/icon, chevron, divider, selected, disabled, or compact states.
- Use `STRQToggleRow` for setting rows where the toggle binding is the core action.
- Preserve original tap area and row order when migrating.

Section header rules:

- Use `STRQSectionHeader` for production row/card groups where a simple title and optional trailing action is enough.
- Avoid local accent strips unless the prompt defines their semantic meaning.
- Section headers should not become louder than the content they organize.

Icon container rules:

- Use `STRQIconContainer` inside STRQ rows/cards.
- Do not replace SF Symbols with `STRQIcon` unless the prompt gives an exact mapping.
- Icon tint must follow semantic state, not decoration.

Divider/border rules:

- Prefer one subtle border around a group, or row dividers inside a group, not both at high contrast.
- Selected borders should be visible but calm.
- Destructive borders use danger only when the action or state is destructive.

Shadow/effect restraint:

- Keep shadows low and functional.
- Avoid warm glows as default emphasis.
- Use glow only for selected/focus/reward when explicitly scoped.

When to use each primitive:

- Use `STRQListItem` for repeated settings, tools, route rows, and simple list actions.
- Use `STRQCard` for a self-contained display module or grouped content.
- Use `STRQSurface` when a screen needs custom composition with an approved background/border/radius.
- Use `STRQMetricCard` for display-only numeric modules after metric mapping is approved.

Local helpers may remain temporarily when they sit in protected screens, are tied to complex behavior, or have no approved primitive mapping. They should not be copied into new screens.

## 11. Primitive Readiness Matrix

| Primitive | Readiness | Current evidence | Production usage found | Risk | Recommended next validation | First safe production target |
|---|---|---|---|---|---|---|
| `STRQColors` | Ready with caveats | Token set exists; neutral/warm/semantic colors documented | Profile controls via `STRQColors`; broad production still uses `STRQPalette` | Medium because warm aliases can be misread as brand law | Lab swatches and contrast review | Profile controls/non-danger rows |
| `STRQTypography` | Ready with caveats | Runtime tokens and Work Sans fallback logic exist | Production adoption not broad | Medium because Work Sans files are not bundled | Lab typography QA and fallback confirmation | Profile row text only |
| `STRQSpacing` | Ready with caveats | Core app and component spacing tokens exist | Through Profile controls/ListItem | Low/Medium | Lab density review on small/large devices | Profile rows |
| `STRQRadii` | Ready with caveats | Component radius roles exist | Through Profile controls/ListItem | Low/Medium | Lab card/list QA | Profile rows/cards |
| `STRQEffects` | Ready with caveats | Borders, shadows, focus/glass tokens exist | Indirect in Profile controls/ListItem | Medium because exact elevation is not fully production-proven | Lab surface/effect QA | Profile group surface |
| `STRQIcon` | Ready with caveats | Enum and asset-backed icons exist | Profile controls uses `STRQIcon` values | Medium because mapping is incomplete for SF Symbols | Icon grid QA and exact mapping list | Profile controls only |
| `STRQIconView` | Ready with caveats | Asset rendering and fallback glyph exist | Indirect in `STRQListItem` | Medium | Icon grid QA | Profile controls |
| `STRQIconContainer` | Ready with caveats | sm/md/lg/xl container exists | Indirect in `STRQListItem` | Low/Medium | Lab row/icon QA | Profile controls/non-danger rows |
| `STRQSurface` | Ready with caveats | Variants and borders exist; DEBUG lab coverage | No direct production use in targeted screens | Medium | Lab surface/card QA | Profile group wrapper later |
| `STRQCard` | Ready with caveats | Standard/elevated/selected/compact/hero variants | No targeted production use | Medium | Lab card density QA | Profile or display-only module |
| `STRQButton` | Ready with caveats | Neutral CTA API, disabled/loading/icon variants | No targeted production use | Medium/High for protected CTAs | Lab button state QA | Non-critical Profile action only |
| `STRQIconButton` | Ready with caveats | Primary/secondary/selected/ghost/destructive states | No targeted production use | Medium | Lab icon-button QA | Non-critical Profile affordance |
| `STRQChip` | Ready with caveats | Neutral/selected/semantic/disabled tones; DEBUG lab | No targeted production use | Medium because `.orange` exists | Lab chip QA and accent policy check | Profile focus chips or ExerciseLibrary planning |
| `STRQBadge` | Ready with caveats | Small/status/count/achievement variants | No targeted production use | Medium for achievement semantics | Lab badge QA | Profile/status badges |
| `STRQMetricCard` | Ready with caveats | Metric, delta, progress, compact variants | No targeted production use | Medium because data layout must not change | Lab metric QA; then display-only module selection | Dashboard or Progress later |
| `STRQProgressBar` | Ready with caveats | Semantic tones, label/value, accessibility | No targeted production use except internal metric card | Medium | Lab progress QA | Display-only metric later |
| `STRQProgressRing` | Ready with caveats | Compact/score/activity variants | No targeted production use | Medium | Lab ring QA | Progress/readiness display later |
| `STRQProgressRow` | Ready with caveats | Label/value/detail/progress row | No targeted production use | Medium | Lab row/progress QA | Display-only metric later |
| `STRQListItem` | Ready for production | DEBUG lab and Profile controls production use | `ProfileView.controlsSection` | Low in Profile, medium elsewhere | Rork Profile controls QA | Profile controls completion |
| `STRQSectionHeader` | Ready for production | DEBUG lab and Profile controls production use | `ProfileView.controlsSection` | Low | Rork Profile controls QA | Profile controls completion |
| `STRQSearchField` | DEBUG-only / needs QA | Binding/clear/disabled/error states exist | No targeted production use | Medium because search behavior matters | Lab input/search QA | ExerciseLibrary later, after behavior audit |
| `STRQInputField` | DEBUG-only / needs QA | Title/helper/secure/disabled/error states exist | No targeted production use | Medium/High because forms write data | Lab form QA | Later form pass |
| `STRQToggleRow` | Ready with caveats | Binding, disabled, compact states exist | No targeted production use | Medium because bindings/scheduling matter | Lab toggle QA | NotificationSettings after approval |
| `STRQModalSurface` | DEBUG-only / needs QA | Surface only; no presentation behavior | No targeted production use | Medium | Lab modal QA | Later sheet/modal shell |
| `STRQBottomSheetSurface` | DEBUG-only / needs QA | Surface only; no detent/presentation behavior | No targeted production use | Medium | Lab sheet QA | Later sheet pass |
| `STRQNavigationBar` | DEBUG-only / needs QA | Top bar primitive exists | No production use; root navigation protected | High | Lab nav QA only | Not early |
| `STRQAvatar` | Ready with caveats | Initials/image/icon placeholder sizes | No targeted production use | Low/Medium | Lab avatar QA | Profile display later |
| `STRQRatingStars` | Not enough evidence | Display-only rating primitive | No targeted production use | Low but no current product target | Lab only if rating feature appears | None |
| `STRQEmptyStateCard` | Ready with caveats | Optional action support via `STRQButton` | No targeted production use | Medium if action changes | Lab empty-state QA | Low-risk empty state later |
| `STRQTabBarContainer` | DEBUG-only / needs QA | Isolated tab shell | No production use; `ContentView` protected | High | Lab only | Not early |
| `STRQTabBarItem` | DEBUG-only / needs QA | Selected/unselected item | No production use; navigation protected | High | Lab only | Not early |
| `STRQTabBarBackground` | DEBUG-only / needs QA | Modifier exists | No production use; navigation protected | High | Lab only | Not early |
| `STRQScheduleRow` | Ready with caveats | Date/status/selected/completed states | No targeted production use | Medium/High because schedule behavior matters | Lab schedule QA | Later schedule planning |
| `STRQScheduleCard` | Ready with caveats | Card of schedule rows | No targeted production use | Medium/High | Lab schedule-card QA | Later schedule planning |

## 12. Migration Blocking Issues

- Unclear CTA mapping from current orange-gradient CTAs to neutral/graphite-first variants.
- Work Sans is not bundled; do not change runtime font behavior in this pass.
- Orange currently appears too broadly for CTA, selected, progress, and reward-like states.
- Production still mixes Forge, STRQPalette, STRQBrand, local helpers, and minimal STRQDesignSystem adoption.
- Active Workout is too risky for early visual migration.
- Paywall is revenue-sensitive and requires owner-approved strategy.
- Onboarding is tied to profile capture, plan generation, and first-workout handoff.
- Anatomy/media work is not scoped and should not be imported in this pass.
- Approved icon mapping is not broad enough to replace SF Symbols.
- No macOS `xcodebuild` or iOS simulator validation is available from this Windows environment.
- Rork screenshot QA is required after any future UI implementation change.
- Notification and HealthKit settings are behavior-sensitive.
- Progress/chart modules need exact semantic color and data preservation rules.
- Plan generation, progression, persistence, RevenueCat, Watch, Widget, Live Activity, and HealthKit remain protected.

## 13. Safe Next Production Candidates

| Rank | Candidate | Target file | Target section | Allowed primitives | Forbidden areas | Behavior preservation list | Owner approval | Rork QA checklist |
|---:|---|---|---|---|---|---|---|---|
| 1 | Design System Lab primitive readiness QA | `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift` and docs only if scoped | Buttons, chips, badges, surfaces, cards, lists, progress | All lab primitives only | Production screens, fonts, assets | DEBUG route remains visible; no production behavior | No for DEBUG/docs; yes if fonts/assets enter scope | Lab token/foundation, buttons, chips, cards, metrics/progress, list/schedule, icon grid |
| 2 | Profile controlsSection completion / icon consistency | `ios/STRQ/Views/ProfileView.swift` | `controlsSection` only | `STRQListItem`, `STRQSectionHeader`, `STRQIcon`, `STRQIconContainer`, `STRQColors` | Subscription, account, sync/restore, danger, paywall, reset | Notifications navigation, restore purchases action, regenerate plan analytics/dialog, DEBUG lab route | No if exact scope and no copy/action change | Profile root, Notifications tap, Restore state, Regenerate dialog, DEBUG route |
| 3 | Profile non-danger row cluster | `ios/STRQ/Views/ProfileView.swift` | One non-danger, non-account row cluster | `STRQListItem`, `STRQSectionHeader`, `STRQBadge`, `STRQChip`, `STRQIconContainer` | Danger, account/iCloud, subscription/paywall, restore, reset | Navigation links, toggles, sheets, analytics, localization | Yes if subscription/account/sync included; otherwise likely no | Profile root, target rows tap, protected sections unchanged |
| 4 | NotificationSettings planning only | Docs first; later `ios/STRQ/Views/NotificationSettingsView.swift` if approved | Row/toggle plan | `STRQToggleRow`, `STRQSectionHeader`, `STRQListItem` after approval | Notification scheduling changes, permission request logic, HealthKit behavior | All bindings, `vm.rescheduleSmartReminders()`, DatePicker/Picker values, Settings URL, HealthKit calls | Yes before implementation | Permission states, toggles, time/day pickers, HealthKit available/unavailable |
| 5 | Dashboard display-only module selection | Docs first; later `ios/STRQ/Views/DashboardView.swift` if approved | One owner-selected metric/display module | `STRQMetricCard`, `STRQCard`, `STRQProgressBar`, `STRQBadge` | Start/resume CTAs, readiness submit, logs, weekly review generation | Data values, analytics, sheets, dynamic early/mature states | Yes | Today root with/without workout, selected module, adjacent CTA unchanged |
| 6 | ExerciseLibrary filter/card planning | Docs first; later `ios/STRQ/Views/ExerciseLibraryView.swift` if approved | Filter chips or card shell, not both | `STRQChip`, `STRQBadge`, `STRQListItem`, `STRQCard` | Exercise IDs, search semantics, favorites, detail route | Search text, selected filters, clear all, favorite toggle, selected exercise route | Yes | Search, filters, clear, favorite, open detail, empty search |
| 7 | Progress metric-card planning | Docs first; later `ios/STRQ/Views/ProgressAnalyticsView.swift` if approved | One display-only metric/card cluster | `STRQMetricCard`, `STRQCard`, `STRQBadge`, `STRQProgressBar` | Charts/calculations/history route changes | Derived values, `ProgressRoute.history`, PR/history data | Yes | Progress early/mature states, history link, selected module, no clipping |
| 8 | Profile focus muscle chip cleanup | `ios/STRQ/Views/ProfileView.swift` | Training setup focus chips only | `STRQChip` | Training setup data, plan regeneration, onboarding restart | Displayed focus muscles and order | No if exact display-only scope | Profile Training Setup, long muscle names, no protected row changes |

## 14. Areas Explicitly Not Ready

- `ActiveWorkoutView`
- `STRQPaywallView` implementation
- `OnboardingView` implementation
- PlanReveal implementation
- Coach action cards
- TrainingPlan broad migration
- `SessionEditorSheet`
- ExerciseDetail anatomy/media
- Watch/Widget/Live Activity
- RevenueCat/store logic
- HealthKit
- persistence
- progression / plan generation
- RevenueCat/store files
- account/iCloud restore/sign-out/reset flows unless explicitly scoped
- notification scheduling and deep-link changes
- asset, font, anatomy, coach/person/demo image imports

## 15. Future Codex Implementation Rules

Future implementation prompts must be stricter than previous UI prompts:

- Scope one file or one tiny module.
- Name the exact function/section to change.
- List exact allowed primitives.
- List forbidden files and protected directories.
- List exact action closures, bindings, navigation routes, analytics calls, disabled/loading states, and sheet/alert behavior to preserve.
- Allow no copy changes unless explicitly approved.
- Allow no localization edits unless explicitly approved.
- Allow no assets or fonts unless explicitly approved.
- Allow no icon replacement unless an exact SF Symbol to `STRQIcon` mapping is provided.
- Allow no orange/default CTA changes unless exact policy mapping is provided.
- Include a Rork QA checklist with specific screens/states.
- Include protected diff checks.
- Include a report-back format that names files changed, protected files untouched, verification results, Rork QA status, and owner approval gates.
- Require "requires follow-up inspection" for anything not verified from repo/docs.
- Never recommend broad screen rewrites, Figma screen copying, mass orange replacement, or protected-flow changes.

## 16. Recommended Next Prompt After This Pass

Recommended next prompt:

```text
Foundation Hardening Pass 2: Design System Lab primitive readiness QA.

Work in repo: C:\Users\maxwa\Documents\GitHub\rork-strq

Goal:
Validate the DEBUG Design System Lab primitives against the Foundation Hardening Pass 1 policies for CTA, accent, surface/card/list, chip/badge, and progress usage. This is a DEBUG/docs QA pass only unless explicitly scoped otherwise.

Allowed edits:
- docs-only QA report, and optionally `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift` only if the prompt explicitly approves DEBUG lab adjustments.

Do not edit:
- production Swift screens
- assets, fonts, localization
- ContentView, STRQApp, ViewModels, Services, Models
- Paywall, Onboarding, Active Workout, Train, Coach actions, Watch, Widget, Live Activity

Must verify:
- `STRQButton` primary/secondary/ghost/destructive/disabled/loading/icon states
- chip/badge tones without orange as default selected/CTA identity
- surface/card/list density and no nested-card clutter
- progress neutral/success/warning/danger readability
- Work Sans fallback status
- Rork/simulator screenshots if DEBUG UI changes are made

Report back:
- primitive readiness updates
- any blockers before Profile controlsSection completion
- whether Profile controlsSection can be the next production micro-migration
```

Why this comes next: this audit found that production policy is clearer, but `STRQButton`, progress, chips/badges, cards, and many surfaces are still mostly lab-proven rather than production-proven. A lab QA pass reduces risk before the first new production migration and avoids using Profile as the place to discover primitive-state problems.
