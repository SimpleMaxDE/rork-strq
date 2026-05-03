# Coaching Style Experience Redesign Plan

## 1. Executive summary

The current Coaching Style implementation is functional, but it is not visually or experientially strong enough for STRQ's premium coach positioning. The issue is not a simple Profile row bug. The row and destination screen both need a clearer product concept, stronger hierarchy, and a calmer premium structure so the feature feels like personal coach configuration rather than generic settings.

The next implementation should not become a broad app redesign. This plan intentionally keeps the scope to Coaching Style entry and `CoachingPreferencesView` experience design. It does not recommend touching onboarding, Today, Coach, Train, Progress, paywall, account, reset, active workout, plan generation, analytics, persistence, localization, Watch, Widget, or Live Activity behavior.

The first code pass after this plan should be one safe screen or section only. It should prove the new direction in one contained surface, preserve all existing data and behavior, and require Rork visual QA before the next pass.

## 2. Current UX diagnosis

The Profile row now uses STRQ tokens and is behaviorally safe, but it still reads as a compact settings row. It lists three technical preferences in small chips, so the user's first impression is "configured values" rather than "this is how my coach adapts to me."

The Coaching Style detail screen feels too much like a list of preferences. The current structure has a hero card followed by several form-like groups, but the hierarchy does not yet make the feature feel high value. The screen explains what each setting changes, but it does not strongly communicate why these choices matter for better training decisions.

The chips are too dense. The Profile row shows tone, emphasis, and density as three separate capsules; the detail hero shows four capsules. This creates visual noise and makes the feature feel technical. It also leaves little room for a richer user benefit statement.

Selected states currently rely too much on strong accent feedback. The detail option rows use a warm selected icon treatment and a green check/border combination. That creates activity, but not necessarily premium confidence. For Coaching Style, selected state should feel precise and intentional rather than loud.

The feature needs a clearer hierarchy around this idea: "your coach adapts how it talks, what it focuses on, and how much it adjusts." That concept should be visible in the Profile entry, reinforced in the hero, and carried through the option groups.

## 3. Product goal

Coaching Style should be treated as personal coach configuration. It is not a generic settings screen, not a raw preference editor, and not a place to show off every possible chip or option.

The feature should build trust by making STRQ feel intelligent, personal, and serious about strength training. The user should understand that these preferences shape the coaching surface: tone, training priority, level of guidance, and control. The result should feel like configuring a coach who knows how to communicate and intervene, not toggling app UI behavior.

This can become a future differentiator against established logging apps. Stronger apps can track workouts; STRQ should make training decisions feel clearer, more personal, and more trustworthy.

## 4. What should not change

- Do not change `vm.profile.coachingPreferences`.
- Do not change `CoachingPreferences` storage.
- Do not change preference enum values.
- Do not change selected preference behavior.
- Do not change display names unless a later copy/localization scope is approved.
- Do not change icons unless an exact mapping is approved.
- Do not change `CoachingPreferencesView(vm: vm)` navigation.
- Do not change the Profile row route or tap behavior.
- Do not change `updateTone`, `updateEmphasis`, `updateDensity`, `updateAutomation`, or `commit`.
- Do not change `vm.refreshCoachingInsights()` or `vm.refreshDailyState()` timing.
- Do not change analytics behavior.
- Do not edit `Localizable.xcstrings` in this planning pass.
- Do not edit models, view models, services, persistence, RevenueCat, account, reset, HealthKit, Watch, Widget, or Live Activity code.

## 5. Figma reference findings

Bounded read-only Figma inspection was performed against the requested file key and exact nodes. No Figma writes were made.

| Source inspected | Useful layout ideas | Card hierarchy ideas | Chip/list/badge ideas | What must not be copied | STRQ-owned mapping |
| --- | --- | --- | --- | --- | --- |
| Dark AI Fitness Coach, node `11605:86057` | The source group shows coach onboarding, interaction choice, chat, settings, and history patterns. The useful idea is a confident, explanatory top area before choices. | Large choice cards create a stronger "choose how this experience works" feeling than compact settings rows. Row cards also show how metadata can sit below a title without becoming a chip wall. | Chips appear as filters and metadata. This supports using fewer chips and making them passive. | Do not copy source product names, AI hype, demo names, chat copy, model/provider labels, data-sharing copy, or brand-orange defaults. | Use `STRQCard` or local tokenized cards for hero/option shells, `STRQSectionHeader` for groups, and restrained passive `STRQChip` or `STRQBadge` only where needed. |
| AI Fitness Coach interaction-choice subnode `11605:86093` | A small number of large cards makes the choice feel consequential. | The selected card has stronger border/fill than the unselected card, proving that selection can be structural. | No dense chip summary is needed for the core choice. | Do not copy the wording, CTA, orange selected treatment, or "mode" framing. | Map the pattern to coaching option cards with neutral/cool selected border, subtle fill, icon support, and checkmark. |
| AI Fitness Coach row-card subnode `11605:87046` | Section headers, search/filter, and grouped row cards show scan-friendly density. | Rows have title plus compact metadata below, which is more readable than many tiny badges. | Small dot/badge signals are present, but should be used sparingly in STRQ. | Do not copy conversation/history concepts, model labels, source copy, or plus/filter actions. | Use the row-card density as inspiration for future option cards, not as a direct screen copy. |
| Dark Profile Settings & Help Center, node `11613:167073` | The source shows a long dark profile/settings hierarchy with app bar, profile header, grouped sections, list rows, help/settings screens, and footer. | It proves dark grouped rows can be clean, but also shows the danger of feeling like ordinary settings. | Profile list items use leading icons, title/subtitle, trailing controls or chevrons. | Do not copy demo users, source branding, referral/reward screens, side sheet layout, settings copy, or orange toggles. | Use `STRQListItem`, `STRQIconContainer`, and `STRQSurface` ideas for the Profile entry only. The detail screen should move beyond pure settings rows. |
| Profile settings subnodes `11613:167244` and `11613:167256` | Screen title plus explanatory subtitle gives context before rows. | Row cards are readable and consistent, but form/settings heaviness is obvious. | Toggle/list states reinforce why Coaching Style should avoid looking like a standard settings list. | Do not copy security/notification semantics, source copy, or orange toggles. | Use the header hierarchy but translate it into a coach-personalization frame. |
| Design System App Components / List Item, node `9134:89206` | Supports one, two, and three-line rows with leading/trailing slots. | Fill and fill-selected variants are useful references for row structure. | Good for Profile entry rows, but less ideal for the richer detail experience. | Do not copy the full slot taxonomy or introduce unrelated slot types. | `STRQListItem` is appropriate for compact settings-style entries; custom option cards are better for the Coaching detail screen. |
| Design System General Components / Badge & Chip, node `9126:59240` | Wide state coverage confirms chips/badges are available, but not that they should be dense. | Selected chips exist, but Coaching Style should not rely on chip-heavy selection. | Use passive badges/pills sparingly: one badge or two max passive pills. | Do not copy the source brand/accent tone as STRQ identity. | `STRQChip` and `STRQBadge` can support passive summaries, not a matrix of technical preferences. |
| Design System General Components / Button, node `9128:103928` | Button state coverage is broad, but Coaching Style row should remain tappable rather than CTA-like. | Primary/accent button treatment is not needed for the Profile row. | Button state references help avoid overusing CTA affordances for selection. | Do not copy orange/accent primary button identity. | Use buttons only for option row tap mechanics; keep visual state card-like and neutral. |

## 6. Proposed Profile entry redesign

Preferred structure: keep one compact card between `fitnessIdentity` and Body & Nutrition. It should stay tappable through the existing `NavigationLink`, not become a CTA. The entry should communicate value first and preference details second.

Recommended content hierarchy:

- Title: `Coaching Style`
- One quiet value badge: likely `PERSONAL`, if retained.
- Subtitle strategy: replace the chip row with a meaningful summary sentence derived from the current preferences, such as a compact preference summary. This should explain the coaching value rather than simply list values.
- Preference detail strategy: choose one of these in the next implementation, in this order of preference:
  - A concise summary line using current preference display names.
  - Two max passive pills if the summary needs anchors.
  - One badge plus subtitle if space is tight.

Icon treatment should stay supportive, not decorative. A neutral icon well using `STRQColors.controlSurface`, `STRQColors.iconSecondary`, and a restrained border is appropriate. Do not introduce a new hero illustration, avatar, source image, or orange glow.

Chevron treatment should remain quiet and trailing. It should signal navigation without making the row look like a CTA.

What not to include:

- Do not include all three preference chips by default.
- Do not include automation unless a later row-copy scope approves how to summarize it.
- Do not include a primary button, edit CTA, progress indicator, reward badge, source copy, demo names, or orange selected/accent state.
- Do not move the row into another section or trigger a broad Profile layout pass.

## 7. Proposed Coaching Preferences screen redesign

The detail screen should feel like configuring a personal training coach. It should have a stronger top concept, clearer group hierarchy, and larger choice cards that feel deliberate rather than form-like.

Recommended screen structure:

- Top hero section: a calm, dark/carbon card or unframed header area explaining that STRQ adapts voice, focus, and guidance level. The hero should show a simple current-coach summary without four chips.
- Short explanation: one concise benefit line should answer why the choices matter for training. It should avoid AI hype and avoid generic personalization fluff.
- Group 1, Coach Voice / Tone: selection cards for current `CoachingTone` values. The group should explain how the coach talks to the user.
- Group 2, Training Focus / Priority: selection cards for current `CoachingEmphasis` values, preserving the existing disabled Physique branch when nutrition tracking is off.
- Group 3, Guidance Level / Control: preserve existing `CoachingDensity` and `CoachingAutomation` behavior while visually grouping them under one "how much guidance and adjustment" concept. If implementation needs to stay ultra-small, start with hero only before reorganizing both groups.
- Footer: a quiet note clarifying that preferences shape coaching presentation and focus while underlying logic remains unchanged.

Selection row/card style:

- Use card-like rows with leading icon, title, short detail, and trailing checkmark.
- Give each row enough vertical breathing room to feel like a choice, not a form input.
- Selected state should use border plus subtle selected surface and a calm checkmark.
- Avoid warm/orange selected fill. Avoid black-on-orange selected icons.
- Disabled Physique state should stay clear and noninteractive, with lower opacity and a lock or equivalent current affordance.

Scroll behavior and safe area:

- Keep the screen inside a `ScrollView`.
- Preserve navigation title and back behavior unless a later navigation prompt explicitly changes it.
- Maintain bottom padding so the footer and last option are not crowded by the home indicator.
- Do not introduce tabs, modals, sheets, sticky CTAs, or new safe-area behavior in the first implementation pass.

## 8. Information architecture

Recommended layout order:

1. Screen title: keep `Coaching Style`.
2. Hero card or header: explain the coach-personalization concept.
3. Group 1: Coach Voice / Tone.
4. Group 2: Training Focus / Priority.
5. Group 3: Guidance Level / Control.
6. Footer note.

No extra tabs. No modal changes. No new onboarding-like flow. No root Profile redesign.

Because the current model has tone, emphasis, density, and automation, the "three group" IA should not delete automation. It should combine density and automation under Guidance Level / Control or leave automation visually subordinate until a later owner-approved copy pass.

## 9. Visual direction

The visual direction should be dark carbon, calm, precise, and coach-like. Use STRQ's neutral surface hierarchy rather than loud accent identity.

Recommended visual rules:

- Use dark carbon surfaces: base background, card surface, control surface, inset surface, and selected surface.
- Keep cards calmer and less glossy.
- Reduce chip clutter.
- Favor high readability over dense labels.
- Use fewer micro-badges.
- Use borders, surface elevation, and checkmarks for selected rows.
- Keep icons supportive and consistent; avoid decorative overload.
- Avoid noisy gamification, reward badges, streak language, confetti, source media, and generic AI branding.

## 10. Selected-state and accent policy

Orange may appear only as a rare meaningful accent, not as the default selected-state identity. Coaching Style should not use orange as its primary selected card fill, default CTA color, toggle color, or icon well.

Preferred selected state:

- Slightly stronger border.
- Subtle selected surface fill.
- Calm checkmark.
- Neutral/cool semantic accent if one is needed.
- Strong text contrast without changing the choice into a CTA.

A green check can remain if it is calm and not the whole identity of selection. Warning, destructive, reward, and progress colors are irrelevant here and should not appear.

## 11. Copy/content direction

Do not edit copy or localization yet. A future copy pass can improve clarity, but it must be explicitly scoped because localization catalogs are protected.

Recommended copy direction:

- Explain the user benefit: the coach adapts how it talks, what it emphasizes, and how much it adjusts.
- Avoid AI hype.
- Avoid generic "personalization" fluff.
- Avoid technical chip overload.
- Keep STRQ's tone serious, coach-like, and strength-training specific.
- Avoid source names, source branding, demo names, and copied Figma copy.

## 12. Risk and protection map

| Area | Behavior risk | Product risk | Files touched later | Owner approval needed | Rork QA needs |
| --- | --- | --- | --- | --- | --- |
| Profile entry row | Low if `NavigationLink { CoachingPreferencesView(vm: vm) }` and displayed preference data are preserved. | Medium because it sets the value promise for the feature. | Later `ios/STRQ/Views/ProfileView.swift` only, scoped to `coachingStyleRow` and private row helpers. | No if visual/value-summary only and no copy/localization change; yes if display names or copy catalog change. | Profile root on small and large iPhone, row visible between adjacent accepted sections, tap opens Coaching Preferences, no clipping. |
| `CoachingPreferencesView` hero | Low if no update methods or preferences change. | High because this is where the feature becomes premium or stays generic. | Later `ios/STRQ/Views/CoachingPreferencesView.swift` only, scoped to `heroCard` and hero-private helpers. | No if existing strings are reused or literal planning-only text stays out of localization; yes for new product copy/localization. | Detail screen top on small/large iPhone, hero hierarchy, no chip clutter, scroll starts cleanly, back navigation unchanged. |
| Preference option rows | Medium because row buttons call update methods. | High because these define whether the screen feels like coaching configuration or settings. | Later `ios/STRQ/Views/CoachingPreferencesView.swift`, scoped to `optionRow` and `physiqueDisabledRow`. | Yes if grouping, copy, icon mapping, or disabled semantics change beyond visual shell. | Select every option, disabled Physique branch with nutrition tracking off, no changed selected values, no clipping. |
| Selected state | Medium because it must preserve tap/update behavior while changing feedback. | High because orange/loud selection would keep the wrong identity. | Later `ios/STRQ/Views/CoachingPreferencesView.swift`; maybe no design-system utility changes. | Yes if new semantic color policy is introduced outside local screen usage. | Before/after selected and unselected cards, repeated taps, all groups, contrast check. |
| Footer | Low if text and layout only. | Medium because it can either build trust or feel defensive. | Later `ios/STRQ/Views/CoachingPreferencesView.swift`, scoped to `footerNote`. | Yes for copy/localization changes. | Footer visible after scroll, no safe-area crowding, no misleading product claim. |

## 13. Recommended implementation phases

1. Docs plan completed.
2. Profile entry row redesign only, if safe.
3. `CoachingPreferencesView` hero redesign only.
4. Preference option card style pass.
5. Selected-state refinement.
6. Final Rork polish.

Do not implement all phases in one pass. The row, hero, option cards, and selected-state policy should each be reviewed in Rork before expanding scope.

## 14. Exact next implementation prompt

Recommended implementation: A. Profile `coachingStyleRow` redesign only.

Why this is the right next prompt: it is the smallest behavioral surface, it does not mutate preferences, and it fixes the first impression before deeper screen work. The row currently communicates technical preference values. The next pass should make the entry communicate user value while preserving navigation and all existing data.

Ready-to-send prompt:

```text
Work in repo: C:\Users\maxwa\Documents\GitHub\rork-strq

Task: Redesign only the Profile Coaching Style entry row so it communicates premium coach personalization value, not a compact technical settings summary.

Target file:
- ios/STRQ/Views/ProfileView.swift

Exact target section:
- `private var coachingStyleRow`
- Row-private helper(s) used only by `coachingStyleRow`, such as `styleChip`, only if needed

Allowed edits:
- Edit only the visual/layout shell of `coachingStyleRow`.
- Replace the current three crowded preference chips with either:
  A. one concise summary line, or
  B. two max passive pills, or
  C. one quiet badge plus summary subtitle.
- Use existing STRQ tokens/primitives already available in the file.
- Keep the row compact and tappable.
- Append one concise entry to docs/migration-progress-log.md after verification.

Forbidden edits:
- Do not edit CoachingPreferencesView.swift.
- Do not edit STRQDesignSystem.swift.
- Do not edit ContentView.swift, STRQApp.swift, Assets.xcassets, Localizable.xcstrings, RevenueCat/store files, ViewModels, Services, Models, Watch, Widget, Live Activity, project.pbxproj, tests, fonts, or asset catalogs.
- Do not edit subscription, account, danger, footer, trackingToggleCard, Training Setup, Body & Nutrition, controlsSection, paywall, reset, iCloud/account, analytics, or navigation outside the existing row.
- Do not introduce orange as default CTA, badge, selected, or icon identity.
- Do not copy Figma/Sandow source copy, demo users, source names, or branding.

Behavior preservation list:
- Keep `NavigationLink { CoachingPreferencesView(vm: vm) }` exactly.
- Keep the row in the same position between `fitnessIdentity` and Body & Nutrition.
- Preserve `vm.profile.coachingPreferences`.
- Preserve preference values and selected behavior.
- Do not mutate tone, emphasis, density, or automation.
- Do not change analytics.
- Do not change localization catalogs.

Visual objective:
- The row should feel like a premium personal coach configuration entry.
- It should say "Coaching Style" and communicate why it matters through a calmer value summary.
- It should reduce chip clutter.
- It should use dark/carbon surfaces, restrained borders, readable typography, a quiet icon well, and a subtle chevron.
- It should remain a row/card entry, not a CTA.

Verification commands:
- git status --short --branch
- git diff --name-only
- git diff -- ios/STRQ/Views/ProfileView.swift docs/migration-progress-log.md
- git diff --name-only -- ios/STRQ/Views/CoachingPreferencesView.swift ios/STRQ/Utilities/STRQDesignSystem.swift ios/STRQ/ContentView.swift ios/STRQ/STRQApp.swift ios/STRQ/Localizable.xcstrings ios/STRQ/Assets.xcassets ios/STRQ/ViewModels ios/STRQ/Services ios/STRQ/Models ios/STRQWidget ios/STRQWatch
- rg -n "private var coachingStyleRow|styleChip|CoachingPreferencesView|PERSONAL|prefs\\.tone|prefs\\.emphasis|prefs\\.density|prefs\\.automation" ios/STRQ/Views/ProfileView.swift
- rg -n "Sandow" ios/STRQ/Views ios/STRQ/ContentView.swift

Rork QA checklist:
- Open Profile on a small iPhone viewport.
- Open Profile on a large iPhone viewport.
- Confirm Coaching Style sits cleanly between fitnessIdentity and Body & Nutrition.
- Confirm the row reads as coach personalization, not a generic settings row.
- Confirm no text, badge, icon, summary, or chevron clips.
- Confirm there are not three crowded chips.
- Tap Coaching Style and confirm `CoachingPreferencesView(vm: vm)` opens.
- Navigate back and confirm Profile state is unchanged.
- Confirm accepted Profile sections remain unchanged.
- Confirm no orange default CTA/selected-state identity appears.

Report back format:
1. Files changed
2. Pre-existing dirty/untracked files
3. Exact Profile helper changed
4. Behavior preserved
5. Protected files untouched
6. Verification results
7. Rork QA required/completed
8. Blockers or owner approval gates
```

## 15. Rork QA checklist

Docs-only pass:

- Confirm only `docs/coaching-style-experience-redesign-plan.md` and `docs/migration-progress-log.md` changed.
- Confirm no Swift files changed.
- Confirm Figma usage was bounded and read-only.
- Confirm the plan avoids source copy, demo users, source branding, and broad redesign.

Future implementation QA:

- Profile row visible on small and large iPhone.
- Profile entry row reads as premium coach personalization.
- Row stays compact and tappable, not CTA-like.
- No three-chip clutter.
- No orange default CTA or selected-state identity.
- Tap opens `CoachingPreferencesView(vm: vm)`.
- Back navigation returns to Profile with no state change.
- Detail screen hero, option rows, selected state, disabled Physique state, and footer pass Rork screenshot QA as each later phase lands.
