# CoachingPreferences Final QA Report

## 1. Executive summary

CoachingPreferences is close to a Stage QA freeze, but it should not be treated as release-final until Rork QA verifies every option group, the locked/unlocked Physique state, Profile entry/back navigation, and persistence/refresh behavior.

The current implementation now reads more like premium coach personalization than a generic settings editor. The hero establishes the concept, the option rows use calm selected states, the Profile entry still routes into `CoachingPreferencesView(vm: vm)`, and static inspection confirms the preference update methods still preserve the existing commit path.

This report is docs-only. It does not modify Swift, models, services, analytics, localization, assets, design-system files, project files, Watch, Widget, Live Activity, tests, or fonts.

## 2. Current implementation inventory

Navigation entry:

- `ProfileView.coachingStyleRow` reads `vm.profile.coachingPreferences`.
- The row presents `NavigationLink { CoachingPreferencesView(vm: vm) }`.
- The Profile row summary displays the current tone, emphasis, and density display names joined with ` · `.
- Automation is part of the detail screen and model, but is not currently included in the Profile row summary.

Screen structure:

- `CoachingPreferencesView` is a `ScrollView` with a vertical stack.
- Order: `heroCard`, Tone section, Focus / Emphasis section, Surface / Density section, Automation section, then `footerNote`.
- Navigation title is `Coaching Style`; large title mode is used.
- `onAppear` animates local `appeared` state.

Hero:

- `heroCard` reads `vm.profile.coachingPreferences`.
- It uses a `person.bust.fill` icon, `YOUR COACH, YOUR WAY` eyebrow, `summaryTitle`, explanatory body copy, and a compact `summaryLine(for:)`.
- `summaryTitle` is derived from current emphasis:
  - Performance -> `Performance-first coaching`
  - Physique -> `Physique-first coaching`
  - Recovery -> `Recovery-first coaching`
  - Consistency -> `Consistency-first coaching`
  - Simplicity -> `Just the next step`
- `summaryLine(for:)` joins tone, emphasis, density, and automation display names with ` · `.

Preference groups:

- Tone / Coach Voice:
  - Iterates over `CoachingTone.allCases`.
  - Options: Supportive, Balanced, Direct.
  - Each option calls `updateTone(_:)`.
- Focus / Emphasis:
  - Iterates over `CoachingEmphasis.allCases`.
  - Options: Performance, Physique, Recovery, Consistency, Simplicity.
  - Physique renders as `physiqueDisabledRow()` when `vm.profile.nutritionTrackingEnabled` is false.
  - Available options call `updateEmphasis(_:)`.
- Surface / Density:
  - Iterates over `CoachingDensity.allCases`.
  - Options: Focused, Standard, Detailed.
  - Each option calls `updateDensity(_:)`.
- Automation:
  - Iterates over `CoachingAutomation.allCases`.
  - Options: Manual, Guided, Adaptive.
  - Each option calls `updateAutomation(_:)`.

Rows and disabled state:

- `optionRow` is a `Button` using `buttonStyle(.strqPressable)`.
- Selected state uses `STRQColors.selectedSurface`, a stronger selected border, calmer icon/check colors, and `checkmark.circle`.
- Unselected state uses `STRQColors.cardSurface`, muted borders, and `circle`.
- `physiqueDisabledRow` is noninteractive, dimmed, and uses a trailing `lock.fill` with copy directing the user to enable physique tracking in Profile.
- No preference update path is attached to the locked Physique row.

Update and commit behavior:

- `updateTone`, `updateEmphasis`, `updateDensity`, and `updateAutomation` each copy `vm.profile.coachingPreferences`, guard against same-value no-ops, set one field, then call `commit(_:)`.
- `commit(_:)` assigns `vm.profile.coachingPreferences = prefs` inside `withAnimation(.snappy(duration: 0.2))`.
- `commit(_:)` then calls `vm.refreshCoachingInsights()` and `vm.refreshDailyState()`.
- `commit(_:)` tracks `Analytics.shared.track(.profile_viewed, ["tone": ..., "density": ..., "emphasis": ..., "automation": ...])`.
- Static inspection did not find an explicit `persist()` call in `CoachingPreferencesView.commit`; persistence should be verified by leaving and reopening the screen/app where feasible.

Model behavior:

- `CoachingPreferences` defaults to tone `.balanced`, density `.standard`, emphasis `.performance`, and automation `.guided`.
- `CoachingPreferences` decoding tolerates missing keys and falls back to the same defaults.
- `CoachingDensity.sideSignalsLimit` affects how many side signals are shown by coach surfaces.
- Current consumer references include `CoachTabView` and `DailyStateCoordinator`, so preference changes are behavior-adjacent even though this pass does not change those consumers.

Colors and accents currently used:

- Dark surface system: `STRQColors.cardSurface`, `selectedSurface`, `insetSurface`, `controlSurface`.
- Borders: `STRQColors.borderMuted`, `selectedBorder`.
- Text/icon colors: `primaryText`, `secondaryText`, `mutedText`, `iconPrimary`, `iconSecondary`, `iconMuted`.
- Section/footer accent: `STRQBrand.steel`.
- No default orange, green, or Pro-violet selected treatment is present in the current option-row implementation.

## 3. Protected behavior map

| UI/action | Protected call/state | Trigger | Risk if changed | Must preserve | Notes |
|---|---|---|---|---|---|
| Profile Coaching Style row | `NavigationLink { CoachingPreferencesView(vm: vm) }` | Tap Profile Coaching Style row | User could lose access to the destination or receive a detached view model | Yes | Keep shared `vm` route and Profile row position. |
| Profile row summary | `vm.profile.coachingPreferences` display names | Profile renders row | Profile could show stale/wrong preference values | Yes | Current row summarizes tone, emphasis, and density. |
| Hero summary title | `summaryTitle` from current emphasis | Detail screen renders | Hero could misrepresent current coaching priority | Yes | Uses current `vm.profile.coachingPreferences.emphasis`. |
| Hero summary line | `summaryLine(for:)` from current preferences | Detail screen renders | User may not see current tone/focus/surface/automation state | Yes | Joins all four preference display names. |
| Tone option | `updateTone(_:)` | Tap Supportive/Balanced/Direct | Wrong field could mutate or refresh path could be skipped | Yes | Guard same value before commit. |
| Focus option | `updateEmphasis(_:)` | Tap available emphasis option | Coach priority could change incorrectly or locked state could be bypassed | Yes | Physique is replaced by locked row when nutrition is off. |
| Surface option | `updateDensity(_:)` | Tap Focused/Standard/Detailed | Coach display density and downstream signal count could regress | Yes | Density has downstream behavior through model consumers. |
| Automation option | `updateAutomation(_:)` | Tap Manual/Guided/Adaptive | Adjustment-control preference could be wrong | Yes | Keep existing values and copy. |
| Same-value guard | `guard prefs.<field> != value else { return }` | Tap already-selected option | Duplicate analytics/refresh work and unnecessary state churn | Yes | Applies to all four update methods. |
| Commit assignment | `vm.profile.coachingPreferences = prefs` | Any real preference change | Preference would not update, Profile row would stay stale, and consumers would not react | Yes | Happens inside `withAnimation`. |
| Commit animation | `withAnimation(.snappy(duration: 0.2))` | Any real preference change | Selected-state transition could feel abrupt or change timing unexpectedly | Yes | Visual but part of current behavior feel. |
| Coaching refresh | `vm.refreshCoachingInsights()` | After commit assignment | Coach recommendations/insights may not reflect preference changes | Yes | Preserve call order after assignment. |
| Daily state refresh | `vm.refreshDailyState()` | After coaching refresh | Today/coach state may remain stale after preference changes | Yes | Preserve call order after coaching refresh. |
| Analytics | `Analytics.shared.track(.profile_viewed, properties)` | After refresh calls | Existing event stream changes unexpectedly | Yes | Event name may be imperfect, but should not be changed in QA. |
| Disabled Physique row | `emphasis == .physique && !vm.profile.nutritionTrackingEnabled` | Focus section render | User could select Physique without required tracking context | Yes | Locked row is noninteractive. |
| No Physique update when locked | `physiqueDisabledRow()` has no action | Tap/inspect locked row | Preference could mutate from an unavailable state | Yes | Rork should verify no tap effect if possible. |
| Footer note | `footerNote` explanatory copy | Bottom of screen renders | User may misunderstand surface-only nature of preferences | Yes | Copy/localization unchanged in this pass. |

## 4. Current visual diagnosis

The hero is premium enough for a Stage QA freeze candidate. It has a clear concept, calm dark surfaces, restrained icon treatment, and a useful current-state summary without returning to the earlier chip-heavy feel.

The option rows are clear. Titles, details, leading icons, and trailing selected indicators make the rows understandable without turning them into loud CTAs. The selected state is visible through surface, border, and checkmark, but it avoids orange, green-as-success, Pro-violet, or a gamified reward treatment.

The disabled Physique row is understandable because it is dimmed, locked, and has explicit unlock copy. It should still be QA'd in Rork because disabled rows can easily become too low-contrast on small screens.

The screen is somewhat long because it includes four full preference groups. That is acceptable for final QA because each group maps to a real model field. It should not be shortened by removing Automation or hiding density unless a separate product pass approves that change.

The screen aligns well with the accepted Profile and NotificationSettings direction: dark/carbon surfaces, compact but readable rows, restrained borders, native navigation, and semantic restraint. Color usage may be slightly conservative, but that is better than reintroducing the previous loud selected-state problem. Later global selected-state semantics can refine this without reopening the whole screen.

## 5. State coverage requirements

Required Rork and behavior coverage:

- All Tone options: Supportive, Balanced, Direct.
- All Focus options: Performance, Recovery, Consistency, Simplicity.
- Physique locked when nutrition tracking is off.
- Physique available and selectable when nutrition tracking is on.
- All Surface options: Focused, Standard, Detailed.
- All Automation options: Manual, Guided, Adaptive.
- Selected and unselected row states in every group.
- Small iPhone viewport.
- Large iPhone viewport.
- Navigation from Profile to CoachingPreferences and back.
- Persistence after leaving and reopening, if possible.
- Profile row summary updates after preference changes.
- No orange default selected treatment.

## 6. Known caveats / remaining debt

- Not release-final until Rork QA covers all option groups.
- Preference persistence and refresh behavior should be verified because `commit(_:)` updates preferences and refreshes state, but static inspection did not show an explicit `persist()` call in the view commit path.
- No broad copy/localization changes were made or should be made in this QA pass.
- Color and selected-state semantics may later be refined globally, especially if STRQ defines a shared selected-row policy.
- `Analytics.shared.track(.profile_viewed, ...)` may not be semantically perfect for a preference-change event, but it is existing behavior and should not be changed unless explicitly approved.
- The screen still uses some local section heading styling, including `STRQBrand.steel`; this is acceptable for now and lower risk than changing behavior-adjacent preference rows.
- macOS or CI `xcodebuild` validation remains required before shipping.

## 7. Release-readiness assessment

Classification: Stage QA likely close to acceptable if Rork verifies all states, but not release-final yet.

CoachingPreferences can probably be frozen after owner Rork QA confirms option selection, disabled/unlocked Physique behavior, Profile summary updates, navigation, persistence/refresh behavior, small/large layout, and no accidental loud selected-state colors.

It should not be called release-final until Rork QA and persistence/refresh checks are done.

## 8. Recommended Rork QA checklist

- [ ] Open CoachingPreferences from the Profile Coaching Style row.
- [ ] Inspect the hero for hierarchy, readability, and no chip clutter.
- [ ] Tap each Tone option.
- [ ] Tap each Focus option that is available.
- [ ] Verify Physique is locked when nutrition tracking is off.
- [ ] Enable nutrition tracking and verify Physique unlocks if the test state is safe.
- [ ] Tap Physique when unlocked if feasible.
- [ ] Tap each Surface option.
- [ ] Tap each Automation option.
- [ ] Leave the screen and return.
- [ ] Check that the Profile row summary updates.
- [ ] Check small iPhone viewport.
- [ ] Check large iPhone viewport.
- [ ] Confirm no orange, green, or Pro-violet accidental selected treatment.
- [ ] Check for no broken layout near the bottom/footer.
- [ ] Verify preference persistence after reopening if feasible.

## 9. Recommended next action

Chosen next action: A. freeze CoachingPreferences after Rork QA.

This is the only recommended next action in this report.

Reason: the current implementation is visually coherent and behaviorally scoped. Another polish pass before screenshots would risk churn in a screen that already meets the intended direction. The right move is to validate every state, then freeze it unless Rork QA finds a concrete defect.

## 10. Recommended next screen after CoachingPreferences

Chosen next screen: E. Coaching/CoachTab planning.

This is the only recommended next screen in this report.

Reason: CoachingPreferences directly affects coach presentation and daily state, so CoachTab is the most connected next planning surface. It should be planning-only first because CoachTab is behavior-heavy and touches coaching insights, readiness, recommendations, applied actions, and analytics.
