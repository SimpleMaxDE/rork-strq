# STRQ Premium Visual Direction Report

Last updated: 2026-05-02

## Executive Summary

STRQ is functional and directionally strong. The app already has a sensible five-tab structure: Today, Coach, Train, Progress, and Profile. That structure supports the product goal and should not be changed early.

The visual system is not yet release-grade premium. The main product risk is not a missing feature; it is that production UI currently feels mixed across Forge-style surfaces, local helpers, orange CTA patterns, SF Symbols, and only limited `STRQDesignSystem` adoption.

The biggest visual risk is orange/default-kit dominance plus mixed styling systems. Orange currently appears too broadly across onboarding CTAs, selected states, progress indicators, tab accents, start/review buttons, Coach/Train actions, and sheets. This can make STRQ feel like a template instead of a serious strength-training coach.

The correct next step is Foundation hardening before broad production migration. The DEBUG Design System Lab is closer to the desired premium STRQ foundation than many production areas, but it is not final production proof. The foundation needs stricter CTA, accent, surface, list, card, icon, typography, and semantic-state rules before more screen work.

Active Workout, Paywall, Onboarding, and core training logic remain protected. Plan generation, progression, persistence, RevenueCat, HealthKit, Watch, Widget, Live Activity, notifications, analytics, localization, exercise identity, and account/restore flows also remain protected until specifically approved.

## Current Product-Quality Diagnosis

STRQ has many strong product ideas: adaptive progression, daily coaching, readiness, weekly structure, exercise education, workout logging, training history, and a profile/settings foundation. The product shape is much stronger than a generic AI-generated app.

The release-quality problem is visual consistency. Production screens still use a mix of `STRQPalette`, `STRQBrand`, `ForgeTheme`, `ForgeSurface`, `ForgeSectionHeader`, `STRQMetricTile`, `STRQBadgeChip`, `STRQPrimaryCTA`, local row/card/chip helpers, SF Symbols, and a small amount of `STRQDesignSystem`.

The app should become calmer, more precise, more premium, and more STRQ-owned. That means fewer loud accents, fewer local one-off visual helpers, stronger semantic state rules, better row/card hierarchy, and a stricter connection between each visual change and a STRQ product job.

The current production app should not be described as release-ready. It loads in Rork simulator, and the owner can perform QA, but "it loads" is not enough for shipping.

## STRQ Premium Identity Principles

STRQ should feel:

- calm
- precise
- dark/carbon
- modern
- coach-like
- data-confident
- serious strength-training focused
- premium but not flashy
- supportive but not childish
- differentiated through clarity and intelligence, not noisy gamification

The app should feel like an adaptive strength-training coach that understands training decisions. It should not feel like a generic wellness dashboard, a social fitness app, a reward-heavy game layer, or a direct copy of a purchased UI kit.

Visual hierarchy should make the user feel guided. High-value training information should be easy to scan. The app should use confidence, restraint, and well-chosen state language instead of decorative intensity.

## Orange/Accent Policy

Orange is not the default CTA identity.

Orange must not be used as the broad primary button system. Existing orange-heavy production areas should be treated as migration debt, not as proof that orange is the STRQ primary brand color.

Orange is allowed only as a restrained warm accent when explicitly scoped. It can remain for rare moments where warmth or energy has clear product meaning and owner approval exists.

Selected states should usually use STRQ semantic states, neutral contrast, border, surface hierarchy, or controlled accent. They should not automatically become orange.

Warning, destructive, success, recovery, readiness, reward, and selected states must be semantic and deliberate. Warning should not look the same as reward. Destructive should not look like warm motivation. Success and recovery should not become random green decoration.

Do not mass-replace orange yet. First document where it appears, define production rules, then migrate in controlled passes with Rork screenshot QA.

## CTA Policy

Primary actions should feel STRQ-owned. The desired direction is neutral/white/graphite-first, with controlled accent only where a specific state or product moment is approved.

Prefer neutral/white/graphite-first primary CTA treatment unless a specific accent is approved. Avoid generic orange gradient button dominance.

CTA changes must preserve:

- action closures and call order
- analytics events and timing
- async state
- disabled state
- loading state
- selection state
- copy and localization behavior
- sheet/dialog/navigation behavior

Active Workout and Paywall CTA changes require owner approval. Onboarding CTA changes also require owner approval because onboarding feeds plan generation and first workout handoff.

No future prompt should allow Codex to freely choose CTA direction. The prompt must name the exact CTA primitive, state mapping, protected calls, and screenshot checklist.

## Typography Policy

Typography is a premium-quality lever. The app can feel more expensive and more coach-like through better scale, line height, density, and consistency.

Work Sans appears in the design-system context, but the Design System Lab screenshot shows that Work Sans is not bundled and system fallback is used. Existing docs and code also record that font binaries are not present in the checkout.

Do not bundle fonts yet. Do not change runtime fonts yet.

A later owner-approved typography decision is required:

- keep Apple-native system typography with a STRQ-owned scale, or
- intentionally bundle a licensed font after the owner approves licensing, file handling, runtime registration, and QA.

Future typography work must not expose, upload, paste, or share font files in prompts or reports. Font files should only be handled as approved local project assets in a dedicated pass.

## Surface/Card/List Policy

Foundation should reduce local helper sprawl. STRQ should move toward a smaller set of hardened primitives instead of adding another visual layer on top of Forge and local helpers.

The following primitives should be hardened before large migrations:

- `STRQSurface`
- `STRQCard`
- `STRQListItem`
- `STRQSectionHeader`
- `STRQMetricCard`
- `STRQChip`
- `STRQBadge`
- `STRQToggleRow`
- `STRQModalSurface`
- `STRQBottomSheetSurface`
- `STRQProgressBar`
- `STRQProgressRing`

Avoid adding a third visual layer on top of Forge/local helpers. Each production pass should replace one small visual cluster, not rewrite whole screens.

Cards and lists should serve scanning. Surfaces should feel quiet, structured, and premium. Avoid visual clutter, nested card stacks, loud gradients, and accent strips that make every section compete for attention.

## Icon/Media/Anatomy Policy

No Sandow runtime references.

No coach/person/demo image imports.

No blind bulk asset import.

Anatomy has potential product value, especially for onboarding, muscle focus, exercise detail, and education. It requires a dedicated asset and product pass. Anatomy/media assets must not be imported blindly.

SF Symbols may remain temporarily when no exact `STRQIcon` exists. Do not mass-replace SF Symbols without an approved mapping.

New icons/assets require explicit scope and owner approval. Asset work must name the exact asset category, source, target runtime names, protected files, QA checks, and Rork screenshot requirements.

## Screen-By-Screen Visual Baseline

| Screen | Current visual impression | Product value | Main visual gap | Risk level | Early migration candidate | Must be protected |
|---|---|---|---|---|---|---|
| Onboarding | Structurally strong but too orange-heavy for final STRQ identity. | Captures user setup and builds trust before plan creation. | CTA/accent, form, card, and anatomy/media direction are not stable enough. | High | No. Plan only after foundation hardening. | Onboarding state, profile inputs, plan generation handoff, copy unless scoped. |
| Plan Generation / Plan Reveal | Useful plan summary, first steps, weekly structure, coach assessment, coach note, and Start Workout moment. | High first-run coaching potential. | Should feel more premium and less orange-default. | High | No. Owner approval required before implementation. | Onboarding completion, first workout handoff, generated plan data. |
| Today / Dashboard | Strong product value with recovery day, next workout, first-week progression, weekly schedule, and logged workout state. | One of the primary premium surfaces. | Needs calmer, more precise premium modules without rewriting behavior. | High | Only a small display-only module after Foundation hardening. | Workout start/resume, readiness, sleep/nutrition logs, weekly state, analytics. |
| Coach | Strong differentiation potential through readiness, workout guidance, baseline learning, and weekly check-in. | Can become STRQ's intelligent coach surface. | Must feel like a coach, not a generic feed. | High | No broad early migration. | Coach actions, readiness/check-in flows, applied recommendations, analytics. |
| Daily Check-in / Readiness | Clear and useful, but uses large orange progress/CTA patterns and strong selected-state colors. | Important daily state and coaching input. | Needs stable form primitives and semantic color rules first. | High | No early redesign. | Readiness writes, submit flow, daily state, coach response. |
| Train | Valuable structure: week strip, workout card, exercise list, review/start CTA, schedule sheet, edit workout sheet, library. | Central training workflow. | High action density and orange CTA/selected-state debt. | High | No broad pass. Later display-only cards or filters only. | Plan mutation, schedule/edit sheets, workout start, exercise IDs, progression. |
| Active Workout | Functionally important and visually developed. | Core logging experience. | Future work must be a dedicated high-rigor pass. | Highest | No. Keep protected early. | Set logging, rest timer, finish workout, notes, swap, load/reps, completion, persistence, Watch/Live Activity/HealthKit side effects. |
| Exercise Library | High-value area for discovery, search, filters, education, alternatives, and progression context. | Differentiates STRQ through better exercise quality. | Needs filter/card/chip polish and later media strategy. | Medium/High | Later planning, then targeted filter/card pass. | Exercise IDs, favorites, filters, progression tags, alternative selection, media provider. |
| Exercise Detail | High-value education and progression surface. | Can improve trust and training understanding. | Anatomy/media and information cards need a dedicated product pass. | Medium/High | Later. Start with low-action info cards only. | Favorite behavior, alternatives, progression reads, exercise identity, media fallback. |
| Progress | Useful but visually simpler than a premium analytics experience should be. | Builds trust through progress, consistency, strength/body/volume context. | Needs metric-card and chart-shell refinement without calculation changes. | Medium/High | Later small metric-card shell pass. | Calculations, tabs, recent workouts, history routes, data interpretation. |
| Profile | Best early migration surface. Existing controlsSection micro-migration is useful proof. | Settings, coaching identity, sync, subscription entry, tools. | Still mixed: Pro, body/nutrition, training setup, notifications/tools, sync/restore, danger zone. | Medium | Yes, for non-danger row clusters after Foundation hardening. | Danger Zone, iCloud/account, subscription/paywall, restore, reset behavior, analytics. |
| Nutrition Targets | Useful product value and coaching support. | Supports body-composition and nutrition guidance. | Current green/purple/orange semantics may not fully match premium STRQ identity. | Medium | Not early broad redesign. | Form inputs, targets, persistence, profile state, HealthKit-adjacent assumptions. |
| Sleep & Recovery | Useful recovery product value. | Supports readiness and training adaptation. | Needs form/input/card primitives and semantic state color rules first. | Medium | Not early broad redesign. | Sleep logging, recovery state, readiness links, persistence. |
| Notifications | Good row/toggle candidate visually. | Supports habits and reminders. | Needs strictly scoped row/toggle styling. | Medium/High | Planning yes, implementation only with owner approval. | Scheduling, permission requests, HealthKit row, reminder routes, deep links. |
| STRQ Pro / Paywall | Not final and shows coming-soon style messaging. | Revenue-sensitive subscription surface. | Needs dedicated visual strategy, not early implementation. | High | Planning only, no implementation. | RevenueCat, entitlement, package selection, restore, purchase state, paywall copy. |
| Design System Lab | Looks closer to desired premium STRQ foundation than many production screens. Shows token parity and primitives. | Foundation proof and QA surface. | Lab primitives are not broadly adopted; Work Sans not bundled. | Low/Medium | Yes, for foundation QA only. | DEBUG-only status, no production assumptions, no font bundling yet. |

## Protected Screens And Flows

The following areas are protected and must not be touched unless a future prompt explicitly scopes them and the owner approves where required:

- Active Workout
- plan generation
- plan regeneration
- progression
- persistence
- RevenueCat / Paywall
- onboarding state
- Watch / Widget / Live Activity
- HealthKit
- notification scheduling and routes
- analytics
- localization catalogs
- exercise identity/catalog/media provider
- subscription/account/iCloud/restore flows
- reset data / danger zone

Protected also means no indirect changes through visual work. A row, button, card, or sheet migration must preserve action calls, bindings, copy, analytics, navigation, async behavior, disabled/loading states, and data contracts.

## Design System Lab Gap Analysis

The Design System Lab is useful and closer to premium STRQ than many production areas. It shows the intended neutral/dark foundation, token parity, surfaces, typography, buttons, components, inputs, cards, metrics, progress, lists, schedule, icons, modals, and sheets.

Lab primitives are not yet broadly adopted. Production adoption of `STRQDesignSystem` is currently minimal and mostly limited to `ProfileView.controlsSection`.

Foundation should be hardened before further production migration. The Lab is a testing ground, not a release-quality guarantee.

Primary, secondary, destructive, disabled, selected, loading, and icon-only button rules need explicit production mapping before CTA migration.

Token categories to inspect next:

- colors
- typography
- spacing
- radii
- shadows
- surfaces
- buttons
- lists
- cards
- chips
- badges
- inputs
- progress
- modals
- bottom sheets
- schedule
- icons
- tab bar

Work Sans is not bundled. Do not change fonts yet.

## How STRQ Avoids Becoming A Generic UI-Kit Clone

STRQ should use the purchased Figma UI kit as a professional foundation and pattern source, not as runtime identity and not as a screen-copy source.

Guardrails:

- no Sandow runtime/source identity
- no full-screen copying
- no demo copy
- no coach/person image imports
- no orange default CTA system
- STRQ-owned naming and product language
- carbon identity
- precision over gamification
- training-coach purpose over generic fitness tracking

Every visual change should answer: what STRQ training-coach job does this improve? If the answer is only "it matches the kit," the work is not ready.

## How STRQ Can Differentiate Against Alpha Progression, Strong, Hevy, And Similar Apps

This is strategic direction, not a factual competitor review. Do not claim detailed competitor feature gaps without separate research.

Future differentiation areas:

- adaptive progression explainability
- coach reasoning and plan transparency
- superior exercise library/search/detail quality
- anatomy intelligence
- premium logging experience
- meaningful session review
- comeback/readiness guidance
- progress analytics that feel trustworthy
- less clutter than generic trackers
- better onboarding trust
- calm premium design

STRQ should win by making training decisions feel clear, personal, and trustworthy. The product should feel like serious coaching software, not just a set/reps notebook with decoration.

## Release-Quality Gates

Rork simulator visual QA is required after every UI pass.

Code/static QA is required through Codex after every implementation pass.

macOS/CI `xcodebuild` is required before shipping. Do not claim `xcodebuild` on Windows.

Owner approval is required for protected areas.

No release should be based only on "it loads."

Each migrated area must pass:

- no crash
- no behavior regression
- no clipping
- no wrong colors
- no broken tap targets
- no accidental copy changes
- no analytics changes unless scoped
- no localization changes unless scoped
- no state/action/binding changes unless scoped
- disabled/loading/empty/error states still make sense
- adjacent entry and exit states still work

## Future Codex Prompt Rules

Future prompts must be stricter and less open-ended. Codex should not choose product direction freely.

Required prompt template:

```text
Work in repo: C:\Users\maxwa\Documents\GitHub\rork-strq

Goal:
Migrate only [exact target section/function] in [exact target file].

Exact target file:
- [file]

Exact target section/function:
- [section/function]

Allowed edits:
- [file list]

Forbidden files:
- ContentView.swift unless owner-approved navigation pass
- STRQApp.swift
- Assets.xcassets
- Localizable.xcstrings
- RevenueCat/store files
- ViewModels
- Services
- Models
- Watch files
- Widget files
- Live Activity files
- project.pbxproj
- tests

Allowed primitives:
- [exact STRQ primitives]

Behavior-preservation list:
- [actions/calls/bindings/navigation/analytics/copy/localization/async states]

Visual objective:
- [specific premium STRQ outcome]

QA commands:
- git status --short --branch
- git diff --name-only
- git diff -- [target files]
- git diff --name-only -- [protected paths]
- [targeted rg checks]

Rork screenshot checklist:
- [exact screens/states]
- [small iPhone]
- [large iPhone]
- [entry/exit state]
- [disabled/loading/empty/error if applicable]

Report-back format:
1. Files changed
2. Protected files unchanged
3. Visual summary
4. Behavior preserved
5. Verification results
6. Rork QA needed/completed
7. Risks or owner approvals

Do not decide:
- no new tabs
- no root navigation changes
- no orange default CTA
- no broad screen rewrite
- no full-screen Figma copying
- no copy changes
- no localization changes
- no asset imports
- no font imports
- no icon replacement unless listed
- no product strategy changes
- no protected logic changes
```

If a future prompt cannot name the target file, section, primitives, forbidden files, behavior-preservation list, visual objective, QA commands, screenshot checklist, and do-not-decide list, it is not ready for implementation.

## Recommended Next 10 Work Packages

| Order | Work package | Objective | Target files | Risk level | Owner approval required | Protected areas | Rork QA expectation | Why it comes in this order |
|---:|---|---|---|---|---|---|---|---|
| 1 | Premium Visual Direction Report completion | Restore owner visual direction and stricter prompt controls. | `docs/strq-premium-visual-direction-report.md`, `docs/migration-progress-log.md` | Low | No | All production code, assets, localization, protected logic. | Not required for docs-only pass. | Establishes product direction before more Codex work. |
| 2 | Foundation Hardening Pass 1: CTA/accent/surface/list policy audit, no production changes | Inventory current CTA/accent/surface/list usage and convert this report into actionable primitive rules. | Docs only, likely `docs/design-system-import-plan.md`, `docs/component-migration-plan.md`, new audit doc if approved. | Low | No | No Swift, no assets, no fonts. | Not required unless screenshots are used for review. | Stops orange and helper sprawl before new UI migration. |
| 3 | Foundation Hardening Pass 2: Design System Lab QA and primitive readiness table | Validate Lab primitives, button states, semantic colors, list/card density, and Work Sans fallback status. | `ios/STRQ/Views/Debug/STRQDesignSystemPreviewView.swift` only if scoped, docs report if needed. | Medium | No for DEBUG/docs only; yes if fonts/assets are considered. | Production screens, runtime flows, font bundling. | Required if DEBUG Lab UI changes; capture Lab sections. | Lab must be trusted before production adoption expands. |
| 4 | Profile controlsSection completion / icon consistency | Complete the existing low-risk production proof without broad Profile rewrite. | `ios/STRQ/Views/ProfileView.swift` only. | Low/Medium | No if exact controlsSection only and no copy/action change. | Restore purchases, regenerate plan dialog, notification navigation, DEBUG route. | Required: Profile root, Notifications row, Restore Purchases state, Regenerate Plan dialog, DEBUG Lab route in debug. | Builds from the existing micro-migration. |
| 5 | Profile non-danger settings row cluster migration | Migrate one additional non-danger Profile row cluster to hardened row/list primitives. | `ios/STRQ/Views/ProfileView.swift` only. | Medium | Yes if subscription/account/sync included; no if low-risk non-danger tools only. | Danger Zone, account/iCloud, subscription/paywall, restore, reset. | Required: Profile root, target row taps, unchanged protected sections. | Extends consistency in the safest production surface. |
| 6 | NotificationSettings visual row/toggle planning | Plan exact row/toggle visual pass while preserving scheduling and permissions. | Docs only first; later `ios/STRQ/Views/NotificationSettingsView.swift` if approved. | Medium/High | Yes before implementation. | Notification scheduling, permission requests, HealthKit, reminder routes. | Planning: none. Implementation: all toggle/time/permission states. | Good row/toggle candidate, but protected behavior needs guardrails first. |
| 7 | Today display-only module candidate selection | Choose one display-only Today module for later premium card/metric migration. | Docs only first; later `ios/STRQ/Views/DashboardView.swift` if approved. | Medium/High | Yes. | Workout start/resume, readiness, logs, weekly state, analytics. | Planning: owner screenshot selection. Implementation: Today root and adjacent states. | Today is high value but behavior-coupled, so selection comes before code. |
| 8 | Exercise Library filter/card planning | Define safe chip/card targets without changing exercise discovery behavior. | Docs only first; later `ios/STRQ/Views/ExerciseLibraryView.swift` if approved. | Medium/High | Yes. | Exercise IDs, filters, favorites, progression tags, alternatives, media provider. | Planning: screenshots for library/filter/detail entry. Implementation: filter/search/favorite/detail states. | High differentiation area after rows/cards are proven. |
| 9 | Progress metric-card planning | Select one metric-card shell target and preserve all calculations. | Docs only first; later `ios/STRQ/Views/ProgressAnalyticsView.swift` if approved. | Medium | Yes. | Calculations, history route, tabs, derived data, copy. | Planning: Progress screenshots. Implementation: metric cluster and history entry. | Analytics can become premium after card primitives prove stable. |
| 10 | Paywall visual planning only, no implementation | Define premium paywall direction without touching RevenueCat. | Docs only; no `STRQPaywallView.swift` changes. | Medium planning, High implementation | Yes mandatory. | RevenueCat, entitlements, package selection, purchase/restore, paywall copy. | Planning screenshots only if owner provides. No implementation QA in this package. | Revenue-sensitive surface must be planned late and carefully. |

These packages intentionally do not recommend broad screen rewrites. They also intentionally defer Active Workout, Paywall implementation, Onboarding implementation, Watch/Widget, HealthKit, RevenueCat, persistence, progression, and plan generation.
