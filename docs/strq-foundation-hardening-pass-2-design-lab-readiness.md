# STRQ Foundation Hardening Pass 2 — Design Lab Primitive Readiness

## 1. Executive summary

The Design System Lab is the controlled proving ground for STRQ primitives. It is the best current place to validate the dark neutral foundation, row density, component states, icon rendering, and semantic color restraint before production migration expands.

Production adoption is still minimal and mainly limited to `ProfileView.controlsSection`, where `STRQSectionHeader`, `STRQListItem`, `STRQIcon`, `STRQIconView`, `STRQIconContainer`, and `STRQColors` are already exercised through the Notifications and Tools row cluster.

This pass determines which primitives can be used in the next low-risk production migration. The likely next production target remains Profile, not Dashboard, Onboarding, Paywall, Train, Coach, Progress, or Active Workout.

No production Swift changes are made. No Debug Lab Swift changes are made in this pass.

Main conclusion: row, section-header, icon, and icon-container primitives are the safest continuation path. Buttons, cards, surfaces, chips, badges, metrics, and progress primitives are useful but still need target-specific Rork simulator QA before production adoption. Form, modal, bottom-sheet, navigation, tab, and schedule primitives remain DEBUG-proven or planning-only for now.

## 2. Scope and non-goals

This is a documentation-only readiness pass.

Non-goals:

- This is not a production UI migration.
- This is not a full Figma parity task.
- This is not a font-bundling task.
- This is not an asset import task.
- This is not an orange mass-replacement task.
- This is not a Paywall, Onboarding, Dashboard, Train, Coach, Progress, or Active Workout implementation task.
- This is not a Design System Lab code patch.

This pass inspects local docs and Swift code only. It does not change app behavior, navigation, persistence, RevenueCat, onboarding, active workout, plan generation, progression, HealthKit, Watch, Widget, Live Activity, analytics, localization, assets, or fonts.

## 3. Design System Lab route and DEBUG status

Static inspection confirms `ProfileView` still links to `STRQDesignSystemPreviewView` from the Profile controls section.

Findings:

- `ios/STRQ/Views/ProfileView.swift` includes a `NavigationLink` labeled `Design System Lab` inside `#if DEBUG`.
- `controlsSectionShowsDesignSystemLab` returns `true` only under `#if DEBUG`, so the preceding row divider behavior also changes safely between DEBUG and Release.
- `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift` wraps the entire preview view in `#if DEBUG`.
- Release builds should avoid compiling/showing the route because both the route call site and the preview type are DEBUG-gated.

Caveats:

- The DEBUG row label itself still uses the older `controlRowContent("Design System Lab", icon: "paintpalette.fill", color: STRQBrand.steel)` helper rather than `STRQListItem`. That is acceptable for the current route because it is DEBUG-only, but it should not be treated as production proof for SF Symbol or row styling.
- The lab is a visual proving ground, not a production adoption guarantee.

## 4. Design System Lab visible coverage

| Category | Coverage status | Evidence from static inspection | Notes |
|---|---|---|---|
| Foundation tokens | visible in Lab | `TokenParitySection` | Core color, spacing, radii, shadow, and role samples are visible. |
| Typography | visible in Lab | `TypographySection` | Includes fallback status and several role samples. |
| Colors | visible in Lab | `TokenMiniSwatch`, `TokenSwatch` | Neutral, selected, success, warning, danger, and warm accent are shown. |
| Gradients | partially visible | Buttons, tab center action, progress overlay | No dedicated gradient inventory section; warm gradients are not presented as default CTA identity. |
| Spacing | visible in Lab | spacing/radii token blocks | Good foundation sample, but not exhaustive layout QA. |
| Radii | visible in Lab | token blocks, cards, buttons, surfaces | Representative component radii are visible. |
| Shadows/effects | visible in Lab | `ShadowTokenSample`, selected/card effects | Useful but still needs screenshot QA for restraint on device. |
| Buttons | visible in Lab | `ButtonsSection` | Primary, secondary, destructive, disabled, loading, ghost, compact, icon-only. |
| Icon buttons | visible in Lab | `ButtonsSection`, `STRQNavigationBar` sample | Primary, neutral, selected, ghost, destructive, disabled. |
| Chips | visible in Lab | `ComponentsSection` | Neutral, selected, success, warning, danger, disabled, compact. |
| Badges | visible in Lab | `ComponentsSection` | Count, status, achievement, selected tone. |
| Surfaces | visible in Lab | `ColorSurfacesSection`, `CardsMetricSection` | Inset surface shown directly; cards use surface internally. |
| Cards | visible in Lab | `CardsMetricSection` | Standard, elevated, selected, compact, hero. |
| Metric cards | visible in Lab | `CardsMetricSection` | Standard and compact metrics with icon, unit, delta, detail, progress. |
| Progress bars | visible in Lab | `ProgressSection` | Neutral, success, warning, danger, compact. |
| Progress rings | visible in Lab | `ProgressSection` | Score and compact rings with semantic tones. |
| Progress rows | not visible | `STRQProgressRow` appears only in utility DEBUG previews | This is the clearest Lab coverage gap. |
| List items | visible in Lab | `ListScheduleSection` | Selected, avatar, trailing value/icon, disabled, compact row examples. |
| Section headers | visible in Lab | `ListScheduleSection` | Header plus action. |
| Search fields | visible in Lab | `ComponentsSection` | Active and disabled search. |
| Input fields | visible in Lab | `ComponentsSection` | Helper and error state examples. |
| Toggle rows | visible in Lab | `ComponentsSection` | Active binding and disabled compact row. |
| Modal surfaces | visible in Lab | `ComponentsSection` | Surface only, not presentation behavior. |
| Bottom sheet surfaces | visible in Lab | `ComponentsSection` | Surface only, not detents or interactive dismissal. |
| Avatars | visible in Lab | `ComponentsSection` | Initials, selected tint, icon placeholder. |
| Rating stars | visible in Lab | `ComponentsSection` | Display-only star ratings. |
| Empty states | visible in Lab | `ComponentsSection` | Empty card with optional action. |
| Schedule rows/cards | visible in Lab | `ListScheduleSection` | Selected, completed, compact, card grouping. |
| Tab bar/container examples | visible in Lab | `ListScheduleSection` | Container, items, center action, background modifier. |
| Icon examples | visible in Lab | `IconsSection` | Semantic samples and all 60 `STRQIcon.allCases`. |

## 5. Primitive coverage map

| Primitive | Defined only | Represented in DEBUG Lab | Used in production | Used in Profile controlsSection | Not visibly represented | Requires follow-up inspection |
|---|---:|---:|---:|---:|---:|---:|
| `STRQColors` | no | yes | yes | yes | no | yes, contrast/on-device |
| `STRQGradients` | no | partial | no direct targeted use | no | partial | yes, gradient inventory |
| `STRQTypography` | no | yes | limited/indirect | indirect through rows | no | yes, font/runtime QA |
| `STRQSpacing` | no | yes | limited/indirect | indirect through rows | no | yes, small-device density |
| `STRQRadii` | no | yes | limited/indirect | indirect through rows | no | yes, surface density |
| `STRQEffects` | no | yes | limited/indirect | indirect through rows | no | yes, shadows/focus |
| `STRQIcon` | no | yes | yes | yes | no | yes, broader SF Symbol map |
| `STRQIconView` | no | yes | indirect | yes, through `STRQListItem` | no | yes, asset fallback QA |
| `STRQIconContainer` | no | yes | indirect | yes, through `STRQListItem` | no | yes, icon alignment |
| `STRQSurface` | no | yes | no direct targeted use | no | no | yes, production surface hierarchy |
| `STRQCard` | no | yes | no direct targeted use | no | no | yes, card density |
| `STRQButton` | no | yes | no direct targeted use | no | no | yes, CTA state mapping |
| `STRQIconButton` | no | yes | no direct targeted use | no | no | yes, target actions |
| `STRQChip` | no | yes | no direct targeted use | no | no | yes, interactive states |
| `STRQBadge` | no | yes | no direct targeted use | no | no | yes, semantic/reward rules |
| `STRQMetricCard` | no | yes | no direct targeted use | no | no | yes, display-only data QA |
| `STRQProgressBar` | no | yes | no direct targeted use | no | no | yes, semantic mapping |
| `STRQProgressRing` | no | yes | no direct targeted use | no | no | yes, score semantics |
| `STRQProgressRow` | yes | no | no direct targeted use | no | yes | yes, add Lab sample later |
| `STRQListItem` | no | yes | yes | yes | no | yes, broader row variants |
| `STRQSectionHeader` | no | yes | yes | yes | no | yes, header hierarchy |
| `STRQSearchField` | no | yes | no direct targeted use | no | no | yes, keyboard/search behavior |
| `STRQInputField` | no | yes | no direct targeted use | no | no | yes, form behavior |
| `STRQToggleRow` | no | yes | no direct targeted use | no | no | yes, bindings/scheduling |
| `STRQModalSurface` | no | yes | no direct targeted use | no | no | yes, presentation behavior |
| `STRQBottomSheetSurface` | no | yes | no direct targeted use | no | no | yes, detents/dismissal |
| `STRQNavigationBar` | no | yes | no direct targeted use | no | no | yes, screen-level nav approval |
| `STRQAvatar` | no | yes | no direct targeted use | no | no | yes, image/avatar targets |
| `STRQRatingStars` | no | yes | no direct targeted use | no | no | yes, product need |
| `STRQEmptyStateCard` | no | yes | no direct targeted use | no | no | yes, action preservation |
| `STRQTabBarContainer` | no | yes | no | no | no | yes, root navigation pass |
| `STRQTabBarItem` | no | yes | no | no | no | yes, root navigation pass |
| `STRQTabBarBackground` | no | yes | no | no | no | yes, root navigation pass |
| `STRQScheduleRow` | no | yes | no direct targeted use | no | no | yes, schedule behavior |
| `STRQScheduleCard` | no | yes | no direct targeted use | no | no | yes, schedule behavior |

## 6. Primitive readiness matrix

| Primitive | Current evidence | Production usage found | Readiness rating | Visual risk | Behavior risk | First safe production target | Required QA | Owner approval required | Notes |
|---|---|---|---|---|---|---|---|---|---|
| `STRQColors` | Neutral, warm, and semantic tokens visible in Lab | Profile controls via row cluster colors | Ready with caveats | Medium | Low | Profile rows | Rork contrast and orange-dominance check | No for Profile rows | Warm aliases must remain optional, not default identity. |
| `STRQGradients` | Primary action, progress overlay, and warm gradients exist | No direct targeted production use from new system | Not enough evidence | Medium/High | Low | None yet | Dedicated gradient/state inventory | Yes for CTA contexts | Warm gradients exist as compatibility tokens and should not become default CTA treatment. |
| `STRQTypography` | Lab shows fallback status and roles | Indirect through Profile row primitives | Ready with caveats | Medium | Low | Profile rows | Rork text clipping; Work Sans status check | No for row continuation | Exact Work Sans fidelity remains pending. |
| `STRQSpacing` | Lab token blocks and primitive dimensions | Indirect through Profile controls | Ready with caveats | Low/Medium | Low | Profile rows | Small/large iPhone density QA | No | Safe inside existing row primitives. |
| `STRQRadii` | Lab token blocks and component samples | Indirect through Profile controls | Ready with caveats | Low/Medium | Low | Profile rows/cards | Card/list radius QA | No | Avoid nested card stacks. |
| `STRQEffects` | Shadows, selected glow, glass tokens visible | Indirect through Profile controls | Ready with caveats | Medium | Low | Profile group wrappers later | Rork shadow/restraint QA | No unless protected target | Focus and selected effect rules are not fully mapped. |
| `STRQIcon` | 60 enum cases and 60 matching icon asset folders found | Profile controls uses enum icons | Ready with caveats | Medium | Low | Profile controls icon consistency | Icon grid and missing-glyph QA | No for Profile controls | Broader SF Symbol replacement remains blocked by mapping. |
| `STRQIconView` | Lab icon grid and semantic samples | Indirect through `STRQListItem` | Ready with caveats | Medium | Low | Profile controls | Asset rendering and fallback QA | No | Fallback glyph exists but should not appear in shipping UI. |
| `STRQIconContainer` | Lab rows/cards/avatar-adjacent icon samples | Indirect through `STRQListItem` | Ready for narrow production use | Low/Medium | Low | Profile controls/non-danger rows | Alignment and tap-target QA | No | Safest through row/list primitives. |
| `STRQSurface` | Direct Lab inset surface and card internals | No direct targeted production use | DEBUG-only / needs Rork QA | Medium | Low | Profile group wrapper later | Surface hierarchy screenshot QA | Target-specific | Useful shell, but not yet production-proven directly. |
| `STRQCard` | All main variants visible in Lab | No direct targeted production use | DEBUG-only / needs Rork QA | Medium | Low | Profile display card or low-risk empty state | Card density/nesting QA | Target-specific | Keep display-only at first. |
| `STRQButton` | Lab shows primary/secondary/destructive/disabled/loading/ghost/compact/icon | No direct targeted production use | Ready with caveats | Medium/High | Medium/High | Non-critical Profile action only after CTA map | Button state and closure preservation QA | Yes for protected CTAs | Not ready to replace `STRQPrimaryCTA` broadly. |
| `STRQIconButton` | Lab shows primary/neutral/selected/ghost/destructive/disabled | No direct targeted production use | Ready with caveats | Medium | Medium | Non-critical Profile affordance | Action/accessibility QA | Target-specific | Safe only where actions are simple and preserved. |
| `STRQChip` | Lab shows neutral/selected/success/warning/danger/disabled/compact | No direct targeted production use | Ready with caveats | Medium | Medium if interactive | Profile passive chips | Selected/unselected and semantic QA | Target-specific | ExerciseLibrary filters need behavior audit first. |
| `STRQBadge` | Lab shows count/status/achievement tones | No direct targeted production use | Ready with caveats | Medium | Low | Profile status badge or passive label | Semantic/reward QA | Target-specific | Dashboard/Progress badges need stricter state map. |
| `STRQMetricCard` | Lab shows metric variants, delta, progress, compact | No direct targeted production use | DEBUG-only / needs Rork QA | Medium | Medium | Later display-only metric module | Data clipping and semantic color QA | Yes for Dashboard/Progress | Must not touch calculations. |
| `STRQProgressBar` | Lab shows neutral/success/warning/danger/compact | No direct targeted production use | DEBUG-only / needs Rork QA | Medium | Medium | Later display-only metric | Semantic tone QA | Target-specific | Do not use for onboarding/readiness/active workout yet. |
| `STRQProgressRing` | Lab shows score/compact semantic rings | No direct targeted production use | DEBUG-only / needs Rork QA | Medium | Medium | Later display-only score | Ring label and score semantic QA | Target-specific | Not ready for readiness or active workout. |
| `STRQProgressRow` | Defined and in utility DEBUG preview, absent from Lab route | No direct targeted production use | Not enough evidence | Medium | Medium | None yet | Add Lab sample and screenshot QA | Target-specific later | Clear follow-up gap. |
| `STRQListItem` | Lab coverage plus Profile controls production use | Profile controlsSection | Ready for narrow production use | Low | Low/Medium | Profile controls completion | Rork Profile controls QA | No if actions/copy unchanged | Best first production primitive. |
| `STRQSectionHeader` | Lab coverage plus Profile controls production use | Profile controlsSection | Ready for narrow production use | Low | Low | Profile controls completion | Rork Profile hierarchy QA | No if copy unchanged | Safe continuation primitive. |
| `STRQSearchField` | Lab active/disabled/error-adjacent behavior | No direct targeted production use | DEBUG-only / needs Rork QA | Medium | Medium | ExerciseLibrary planning only | Keyboard, clear, submit QA | Yes before implementation | Search semantics must be preserved exactly. |
| `STRQInputField` | Lab helper/error/secure-capable primitive | No direct targeted production use | DEBUG-only / needs Rork QA | Medium | Medium/High | Form planning only | Keyboard, validation, persistence QA | Yes before implementation | Not ready for onboarding/nutrition/sleep. |
| `STRQToggleRow` | Lab active and disabled compact examples | No direct targeted production use | Ready with caveats | Medium | Medium/High | NotificationSettings planning; Profile simple toggles later | Binding/action preservation QA | Yes for notification/HealthKit | Only safe when existing bindings/actions are preserved exactly. |
| `STRQModalSurface` | Lab decorative modal shell | No direct targeted production use | DEBUG-only / needs Rork QA | Medium | Medium/High | None early | Presentation, dismissal, keyboard, scroll QA | Yes | Surface only; not a sheet behavior replacement. |
| `STRQBottomSheetSurface` | Lab decorative bottom sheet shell | No direct targeted production use | DEBUG-only / needs Rork QA | Medium | Medium/High | None early | Detents, dismissal, overflow QA | Yes | Protected production sheets should wait. |
| `STRQNavigationBar` | Lab top-bar sample | No direct targeted production use | DEBUG-only / needs Rork QA | Medium | High | None early | Navigation stack QA | Yes | Root/screen navigation is protected. |
| `STRQAvatar` | Lab initials, tint, icon placeholder | No direct targeted production use | Ready with caveats | Low/Medium | Low | Profile display-only avatar later | Image/initial clipping QA | Target-specific | Safe only for display. |
| `STRQRatingStars` | Lab display-only examples | No direct targeted production use | Not enough evidence | Low | Low | None | Product need and half-state QA | Yes if feature scoped | No current production need. |
| `STRQEmptyStateCard` | Lab empty state with optional action | No direct targeted production use | Ready with caveats | Medium | Medium if action used | Low-risk empty state later | Empty/action preservation QA | Target-specific | Action uses `STRQButton`, so CTA caveats apply. |
| `STRQTabBarContainer` | Lab isolated tab shell | No production use | Not ready | High | High | None | Root navigation QA only | Yes | `ContentView` remains protected. |
| `STRQTabBarItem` | Lab selected/unselected items | No production use | Not ready | High | High | None | Root navigation QA only | Yes | Not for early migration. |
| `STRQTabBarBackground` | Lab standalone modifier sample | No production use | Not ready | High | High | None | Root navigation QA only | Yes | Not for early migration. |
| `STRQScheduleRow` | Lab selected/completed/compact rows | No direct targeted production use | DEBUG-only / needs Rork QA | Medium | Medium/High | Schedule planning only | Schedule data/overflow QA | Yes | Display-only later; no schedule mutation. |
| `STRQScheduleCard` | Lab grouped schedule card | No direct targeted production use | DEBUG-only / needs Rork QA | Medium | Medium/High | Schedule planning only | Row list and empty-state QA | Yes | Not ready for Train schedule behavior. |

## 7. Button and CTA readiness

`STRQButton` supports `primary`, `secondary`, `ghost`, `destructive`, `compact`, and `icon` variants. The Lab visibly shows primary with leading and trailing icon, secondary, destructive, disabled primary, loading secondary, ghost, compact, and icon-only examples.

`STRQIconButton` supports `primary`, `secondary`, `neutral`, `selected`, `ghost`, and `destructive`, plus regular/compact sizes and disabled state. The Lab visibly shows these states.

Safe for limited use:

- `STRQButton.secondary`, `STRQButton.ghost`, and `STRQButton.compact` are candidates for non-critical Profile actions only after Rork screenshot QA and exact action preservation.
- `STRQIconButton.neutral`, `STRQIconButton.ghost`, and `STRQIconButton.selected` are candidates for non-critical utility affordances if accessibility labels and actions remain exact.
- `STRQButton.destructive` should not replace native destructive alerts or protected destructive flows yet.

Not proven enough:

- Pressed/focus state appearance is not explicitly captured in static Lab evidence.
- `STRQButton` has no selected variant.
- Loading is represented as a placeholder bar, but production async behavior, disabled timing, and progress messaging are not mapped.
- Button replacement has not been proven in production CTAs.

Neutral/white/graphite-first support exists: `STRQButton.primary` uses `STRQColors.actionSurface` and `STRQColors.actionText`, while secondary and ghost variants stay graphite/neutral. This aligns with the desired direction better than orange-gradient CTA defaults.

Warm/orange default risk inside `STRQDesignSystem` is contained but still present as token debt: `STRQGradients.orangeCTA`, `STRQGradients.progressOrange`, `STRQEffects.orangeGlow`, warm accent colors, and chip tone `.orange` exist. They are not used by `STRQButton.primary`, so `STRQButton` itself is not orange-default.

`STRQButton` should not replace `STRQPrimaryCTA` yet. A production CTA migration is blocked until CTA state mapping is documented for default, pressed, disabled, loading, destructive, selected/focus where applicable, analytics preservation, and protected flow ownership.

Before touching Onboarding, Paywall, Active Workout, Today, Coach, or Train CTAs, validate:

- Exact target CTA and replacement primitive.
- State mapping for default, disabled, loading, destructive, pressed, and any selected/focus behavior.
- Preservation of closures, async tasks, analytics, navigation, and data writes.
- Rork screenshots for all relevant states.
- Owner approval for protected flows.

## 8. Accent and semantic-state readiness

Warm/orange accents appear in `STRQDesignSystem` as:

- Primitive orange scale in `STRQColors`.
- `warmAccent` aliases and backwards-compatible orange aliases.
- `STRQGradients.orangeCTA`, `orangeGlow`, and `progressOrange`.
- `STRQEffects.orangeGlow`.
- `STRQComponentStyle.Tone.orange`.
- `STRQChip.Tone.orange`, plus `brand`/`brandSoft` compatibility tones.

They appear as optional state/token inventory, not as the default `STRQButton.primary` CTA. This is directionally correct, but the token names still require discipline so future passes do not treat orange as STRQ's default action identity.

Clearly represented in the Lab:

- Selected: cards, list rows, chips, icon buttons, schedule row, tab item.
- Success: chips, badges, progress, metric delta, icons, completed schedule row.
- Warning: chips, badges, progress, rating example, compact metric.
- Destructive/danger: button, icon button, chip, badge, progress, icon sample.
- Disabled: button, icon button, chip, search, toggle, list row.

Underdefined or missing:

- Focus state.
- Recovery/readiness as distinct semantic families beyond examples using success/neutral.
- Nutrition and sleep semantic color mapping.
- Reward versus warning separation beyond a selected achievement badge.
- Progress tone rules for chart/data contexts.
- Interactive selected/unselected semantics for filter chips.

Accent rules are safe enough for Profile row/list/icon continuation, but not safe enough for broad production migration, CTA replacement, Dashboard/Progress badge normalization, or form-heavy recovery/nutrition/sleep passes.

## 9. Surface/card/list/header readiness

Surface hierarchy is directionally clear: base/card/elevated/inset/selected surfaces are defined, with restrained borders and low shadows. The Lab shows card variants and one direct inset `STRQSurface`.

Card density is still a production risk. The primitives look useful in isolation, but broad use could create nested-card clutter if they are dropped into existing Forge/local card stacks. Any production card pass should replace a contained shell rather than wrap an old card inside a new card.

List row density is the strongest evidence. `STRQListItem` has real Profile production use, a compact/disabled/selected Lab sample, icon/avatar/trailing/chevron support, and clear dividers. Tap target suitability still needs Rork QA on small iPhone, but Profile controls are the safest continuation.

Section header hierarchy is safe for narrow continuation. `STRQSectionHeader` is already used in Profile controls and shown with a trailing action in the Lab.

Icon container alignment is good inside `STRQListItem` and Lab samples. It should remain the preferred path for Profile row icon consistency.

Safest for the next Profile pass:

- `STRQListItem`
- `STRQSectionHeader`
- `STRQIcon`
- `STRQIconView`
- `STRQIconContainer`
- `STRQColors` neutral roles

Use `STRQSurface` or `STRQCard` only if the exact Profile group wrapper is scoped and screenshots prove the hierarchy does not become heavier.

## 10. Chip/badge readiness

`STRQChip` is visually well represented for passive status and compact labels. It has neutral, selected, success, warning, danger, disabled, and compact examples.

Passive use is safer than interactive use:

- Passive Profile focus/status chips are plausible after Rork QA.
- Interactive ExerciseLibrary filters are not ready until selected/unselected behavior, clear-all semantics, filter persistence, and empty search states are audited.

`STRQBadge` is visually represented for count, status, achievement, and selected tone. It is safer for small passive status labels than for Dashboard/Progress reward systems, where semantic meaning and data interpretation matter more.

Semantic color risk remains:

- `.orange` exists and must stay non-default.
- Achievement/reward state is not fully differentiated from selected state.
- Dashboard/Progress badges need explicit reward/progress/readiness rules before use.

First safe production target: passive Profile label or status use only, not ExerciseLibrary filters and not Dashboard/Progress badges yet.

## 11. Progress/metric readiness

`STRQMetricCard`, `STRQProgressBar`, and `STRQProgressRing` are display-only safe in isolation after Rork screenshot QA. They must not touch calculations, derived values, chart semantics, readiness writes, workout state, or analytics.

The Lab shows:

- Metric cards with value, unit, label, detail, delta, progress, and compact size.
- Progress bars in neutral, success, warning, danger, and compact form.
- Progress rings in score and compact variants.

`STRQProgressRow` is defined but not visible in the Lab route. That prevents treating it as Lab-proven.

Not ready for Dashboard or Progress broadly:

- Dashboard/Today is behavior-coupled with start/resume, readiness, logs, weekly state, and analytics.
- Progress uses derived metrics and charts that need exact semantic preservation.
- Color semantics for progress/recovery/readiness/reward are not fully documented.

First safe display-only target, after Profile row continuation: one owner-selected metric card or passive progress module with all values read-only and unchanged. This should be a planning prompt before implementation.

## 12. Form/input readiness

`STRQSearchField` and `STRQInputField` are DEBUG-proven but not production-ready. The Lab shows search text, disabled search, helper input, and error input. Static evidence does not prove keyboard behavior, focus states, submit behavior, validation timing, secure entry, or persistence.

`STRQToggleRow` is stronger visually, but behavior risk is higher than its visual footprint. It wraps a binding and therefore can affect scheduling, HealthKit, reminder state, or profile settings if wired incorrectly.

Binding/action preservation risks:

- Search must preserve filtering semantics and clear behavior.
- Inputs must preserve validation, persistence, keyboard behavior, and disabled/error timing.
- Toggles must preserve bindings, side effects, permission prompts, scheduling calls, HealthKit calls, and analytics.

Safest target:

- Planning-only for NotificationSettings.
- Later implementation only with owner approval and an exact map of existing bindings/actions.

Not ready for production:

- Onboarding forms.
- Readiness.
- SleepLog.
- NutritionSettings.
- Any form that writes training/profile state.

## 13. Modal/bottom-sheet readiness

`STRQModalSurface` and `STRQBottomSheetSurface` are decorative shells. The Lab proves the visual surface only; it does not prove presentation, detents, scroll overflow, keyboard avoidance, focus, dismissal, background taps, or action preservation.

Production sheet migration should wait because current sheets often mutate plans, workouts, schedules, nutrition, sleep, weight, purchases, or settings.

Protected sheets that must not be touched early include:

- Active Workout sheets and live workout controls.
- Paywall purchase/restore surfaces.
- Onboarding and Plan Reveal handoff.
- Training schedule/edit/swap sheets.
- Readiness, sleep, nutrition, and weight write flows.
- Account, restore, reset, and destructive confirmations.

Required Rork QA for any later sheet pass:

- Open/close behavior.
- Detents and safe area.
- Keyboard states.
- Scrolling/overflow.
- Disabled/loading/destructive actions.
- Tap targets.
- Copy and localization fit.
- Preservation of every closure, binding, async task, and analytics call.

## 14. Icon readiness

`STRQIcon` currently defines 60 cases, and static asset inspection found 60 matching `STRQIcon*.imageset` folders. The Lab renders `STRQIcon.allCases` in the icon grid and also includes semantic success/warning/danger icon samples.

Available icon groups include:

- Root tabs: home, coach, train, progress, profile.
- Settings/tools: settings, bell, search, edit, trash, more, info, warning, lock.
- Health/recovery: recovery, sleep, heart, heartbeat, moon, soreness, stress, water, nutrition.
- Training: barbell, gym, muscle, fullBody, rest, reps, sets, target, play, pause, stop, skip.
- Progress/reward: chartLine, chartBar, trendUp, trendDown, trophy, medal, fire, percentage, activityRing, star.
- Navigation/actions: plus, close, chevrons, arrows, repeatAction, swap, checklist, check, checkCircle.

Obvious gaps for broad production replacement:

- Profile/account/subscription-specific symbols are not fully mapped.
- Notification settings and permission states may need more specific icons.
- Tools/diagnostics/debug icons still rely on SF Symbols in places.
- Exercise/media/anatomy icons are not a full replacement for production visuals.

SF Symbols may remain temporarily. Mass icon replacement is blocked until each target has an approved icon map and fallback QA.

First safe icon-consistency target: Profile controlsSection and adjacent non-danger row clusters, with no subscription/account/danger changes unless explicitly scoped.

## 15. Schedule/tab/navigation readiness

`STRQScheduleRow` and `STRQScheduleCard` are useful display primitives but not production-ready for Train or schedule editing. The Lab shows selected, completed, compact, and grouped rows, but schedule behavior in production is coupled to plan state, workout start, edit sheets, and weekly structure.

`STRQTabBarContainer`, `STRQTabBarItem`, and `STRQTabBarBackground` are not production-ready. They are isolated visual examples only. Root tab/navigation work touches `ContentView` behavior and should remain protected.

`STRQNavigationBar` is also DEBUG-proven only. It may be useful for a later contained top-bar pass, but it should not replace root or screen navigation without explicit approval.

Required owner approval:

- Any root tab bar change.
- Any `ContentView` navigation change.
- Any schedule primitive use in Train/Today that affects workout start/resume, editing, weekly schedule, or plan state.

Schedule primitives can be used later in low-risk display contexts only after a planning pass names the exact read-only module.

## 16. Typography and Work Sans status

Work Sans is not bundled. Static file search found no `.ttf`, `.otf`, `.woff`, or `.woff2` font files under `ios/STRQ`.

Runtime font registration support exists:

- `STRQFontRegistrar.registerBundledFonts()` is documented and referenced from app startup.
- `STRQDesignSystem.workSansFontFilesBundled` checks for bundled font files.
- `STRQTypography` probes Work Sans names and falls back to system fonts.
- The Lab shows `STRQTypography.fontStatusText`, which reports fallback status when Work Sans is absent.

Typography is ready for narrow production continuation through existing row primitives, but exact typography fidelity is not ready. Font work remains blocked pending an owner-approved licensing/assets pass.

Do not expose, upload, paste, or share font files. Do not bundle Work Sans in a UI migration prompt.

## 17. Production adoption recommendations

| Rank | Primitive(s) | Target file | Target section | Reason | Risk | Allowed scope | Forbidden scope | Owner approval required | Rork QA checklist |
|---:|---|---|---|---|---|---|---|---|---|
| 1 | `STRQListItem`, `STRQSectionHeader`, `STRQIcon`, `STRQIconContainer`, `STRQColors` | `ios/STRQ/Views/ProfileView.swift` | `controlsSection` completion / icon consistency | Already partially production-proven | Low/Medium | Row/icon/list consistency only; preserve actions | Subscription, account, restore logic, reset/danger, paywall, localization changes | No if exact and behavior unchanged | Profile root, Notifications tap, Restore flow availability, Regenerate dialog, DEBUG Lab route, text clipping |
| 2 | `STRQListItem`, `STRQSectionHeader`, possibly passive `STRQBadge` | `ios/STRQ/Views/ProfileView.swift` | Profile non-danger row cluster | Profile is lowest-risk production surface | Medium | One non-danger, non-account cluster | Danger Zone, iCloud/account, subscription/paywall, reset, analytics changes | Target-specific | Profile root, all row taps, long labels, small/large iPhone |
| 3 | `STRQToggleRow`, `STRQListItem`, `STRQSectionHeader` | Docs first; later `NotificationSettingsView.swift` | NotificationSettings planning only | Good visual fit, behavior-sensitive | Medium/High | Planning doc only | Scheduling, permission requests, HealthKit, Settings URL behavior | Yes before implementation | Permission states, toggles, time/day pickers, HealthKit available/unavailable |
| 4 | `STRQMetricCard`, `STRQProgressBar`, `STRQBadge`, `STRQCard` | Docs first; later `DashboardView.swift` | Dashboard display-only module planning only | High visual value but coupled | High | Owner-selected read-only module planning | Start/resume CTAs, readiness, logs, weekly state, analytics | Yes | Today with/without workout, selected module only, adjacent CTAs unchanged |
| 5 | `STRQChip`, `STRQBadge`, `STRQListItem`, `STRQCard` | Docs first; later `ExerciseLibraryView.swift` | ExerciseLibrary filter/card planning only | Good component reuse candidate | Medium/High | Choose filter or card shell, not both | Exercise IDs, search semantics, favorites, detail route | Yes | Search, filters, clear all, favorites, open detail, empty search |
| 6 | `STRQMetricCard`, `STRQProgressBar`, `STRQBadge`, `STRQCard` | Docs first; later `ProgressAnalyticsView.swift` | Progress metric-card planning only | Display-only potential | Medium/High | One read-only metric/card cluster | Calculations, charts, history routes, derived data | Yes | Early/mature states, history link, selected module, no clipping |
| 7 | `STRQProgressRow`, button focus/selected samples, gradient samples if approved | `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift` | Design System Lab patch only | Lab misses `STRQProgressRow` and does not prove all states | Low for DEBUG, medium for QA | DEBUG-only samples; no production Swift | Production screens, assets, fonts, source-screen copying | No for DEBUG-only; yes if fonts/assets enter scope | Full Lab top/middle/bottom screenshots and component sections |

Do not recommend or start ActiveWorkout, Paywall implementation, Onboarding implementation, PlanReveal implementation, broad Train migration, broad Coach migration, or root navigation/tab migration from this pass.

## 18. Blockers and caveats

- Work Sans is not bundled.
- Production adoption is limited and mainly Profile controlsSection.
- DEBUG-only evidence is not enough for broad production use.
- CTA state mapping is not fully proven for production.
- Selected/focus/semantic state mapping may be incomplete.
- Orange/warm accent debt remains as optional token inventory and production legacy usage.
- No broad icon mapping exists for SF Symbol replacement.
- No asset/anatomy pass is scoped.
- Windows cannot run `xcodebuild` or iOS simulator validation here.
- Rork QA is required after UI changes.
- Protected flows require owner approval.
- Modal, bottom-sheet, navigation, tab, schedule, search/input, metric/progress, and CTA primitives need target-specific QA.
- Production sheets, active workout, paywall, onboarding, plan generation, progression, HealthKit, Watch, Widget, Live Activity, RevenueCat, persistence, analytics, and localization remain protected.

## 19. Rork simulator QA checklist for Design Lab

Owner checklist:

- Open Profile.
- Open Design System Lab in DEBUG.
- Capture top, middle, and bottom of the Lab.
- Capture buttons section.
- Capture list/card/surface section.
- Capture chips/badges section.
- Capture progress/metric section.
- Capture form/input/toggle section.
- Capture modal/bottom-sheet samples if visible.
- Capture schedule/tab/icon samples if visible.
- Check text clipping.
- Check contrast.
- Check tap targets.
- Check disabled/loading/destructive states if visible.
- Check whether anything still feels orange-dominant.
- Check small and large iPhone if possible.

For a future Lab patch, include a screenshot confirming `STRQProgressRow` appears in the Lab route.

## 20. Recommended next prompt

Recommended next prompt: A. Design System Lab patch prompt.

Why this is the correct next move: the Lab is strong enough to validate row/list/icon direction, but it is missing at least one named primitive from this readiness pass: `STRQProgressRow`. Button focus/selected production mapping is also not fully proven. A small DEBUG-only Lab patch can close the concrete sample gap without touching production behavior, then Rork screenshots can confirm whether Profile row/icon/list continuation is safe.

Prompt:

```text
Work in repo: C:\Users\maxwa\Documents\GitHub\rork-strq

Create a DEBUG-only Design System Lab coverage patch. Do not modify production screens or app behavior. In ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift only, add missing visible samples for STRQProgressRow and any clearly missing button/state samples needed for primitive QA. Do not change STRQDesignSystem.swift, assets, fonts, localization, RevenueCat, ViewModels, Services, Models, Watch, Widget, Live Activity, STRQApp.swift, ContentView.swift, project files, or tests. Keep orange as an optional accent only, not the default CTA identity. After the patch, update docs/migration-progress-log.md with one concise entry and report the required Rork simulator screenshot checklist for the Lab.
```
