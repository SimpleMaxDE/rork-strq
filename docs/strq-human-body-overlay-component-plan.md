# STRQ Human Body Overlay Component Plan

## 1. Executive summary

The Human Body Overlay system should become a STRQ signature component: a premium, fitness-focused body map that explains training intent, muscle stimulus, balance, and caution without feeling clinical or like a debug anatomy viewer.

The validated direction is a neutral licensed Human Body base plus transparent vector PDF muscle overlays. SwiftUI should own state, tint, opacity, and role priority. Assets should stay dumb and reusable; the product component should decide whether a muscle is selected, primary, secondary, trained, undertrained, warning, overload, rest-caution, or neutral.

The production system should be built as one reusable component with mode-specific wrappers for Onboarding, Exercise Info, Exercise Library, Progress, and Coach explanations. The first production integration should not touch all of those screens at once. It should start with Exercise Info primary and secondary muscle display because that is the lowest-risk real product surface: display-only, high value, and close to existing exercise data.

## 2. Current validation status

Validated:

- Licensed Figma source is usable in Licensed Source Mode.
- Full Human Body groups are a better production base than the small 88x128 `Anatomy Muscle` cards.
- The base plus overlay architecture is feasible.
- The four large body groups are visually labelable as Male Front, Male Back, Female Front, and Female Back.
- Overlay alignment confidence is high because overlays share the same viewBox as their matching base.
- Node/sharp preview tinting worked for SVG `currentColor` overlays.
- Visual QA on carbon backgrounds showed that teal/blue overlays, semantic amber, and red/pink caution states are legible without becoming neon.
- The Xcode smoke pass recommends vector PDF first for runtime import.
- The runtime import pilot added 9 approved vector PDF assets to the app for DEBUG Design System Lab rendering.

Still not production-proven:

- The current output is an engineering proof, not product UI.
- The DEBUG Design System Lab composition does not define final sizing, labels, legends, empty states, accessibility, or screen placement.
- Rork runtime visual QA is still required for the imported pilot assets.
- Back, Upper Leg/Quads, and Hamstring semantics still need owner review before final production naming.
- The current 9 assets are enough to prove the path, not enough for full V1 product coverage.

## 3. Proposed component architecture

Recommended exact component names:

| Layer | Name | Responsibility |
|---|---|---|
| Production component | `STRQHumanBodyOverlayView` | Public reusable body map component for production screens. |
| Internal canvas | `STRQHumanBodyOverlayCanvas` | Renders base body and stacked overlay images in one fixed aspect frame. |
| Configuration | `STRQHumanBodyOverlayConfiguration` | Carries body variant, orientation, size, presentation mode, and highlight rules. |
| Highlight model | `STRQMuscleHighlight` | Describes one muscle plus state, side, intensity, and optional short label. |
| Asset resolver | `STRQHumanBodyOverlayAssetProvider` | Maps body variant, orientation, and muscle to vector PDF asset names. |
| Legend helper | `STRQHumanBodyOverlayLegend` | Optional compact legend for semantic states when a screen needs it. |
| Onboarding wrapper | `OnboardingMuscleFocusBodyMap` | Guided selection wrapper for focus and managed-volume muscles. |
| Exercise wrapper | `ExerciseMuscleBodyMap` | Display wrapper for primary and secondary exercise muscles. |
| Library wrapper | `ExerciseLibraryMuscleFilterMap` | Later filter wrapper that must preserve existing search/filter behavior. |
| Progress wrapper | `ProgressMuscleCoverageMap` | Later coverage wrapper driven by real training-volume data. |
| Coach wrapper | `CoachMuscleExplanationMap` | Later explanation wrapper for coach reasoning and caution states. |

Public component inputs:

| Input | Proposed type | Notes |
|---|---|---|
| `gender` / body variant | `STRQBodyVariant` | Use as artwork variant, not a judgmental user label. Support `male`, `female`, and future `neutral`. |
| `orientation` / front/back | `STRQBodyOrientation` | `front`, `back`, or `automatic` at wrapper level. The renderer should receive one resolved orientation at a time. |
| selected / highlighted muscles | `[STRQMuscleHighlight]` or `Set<STRQMuscle>` | Used mostly by Onboarding and filter-style modes. |
| primary muscles | `Set<STRQMuscle>` | Strongest normal emphasis for Exercise Info. |
| secondary muscles | `Set<STRQMuscle>` | Lower-intensity support emphasis for Exercise Info. |
| warning muscles | `Set<STRQMuscle>` | Amber caution for monitor, low volume, asymmetry, or controlled concern. |
| danger / overload muscles | `Set<STRQMuscle>` | Red/pink caution for high load, overload, or rest-needed states. |
| inactive / neutral state | `Bool` or empty highlight sets | Renders base body only with optional low-opacity neutral overlays. |
| size | `STRQHumanBodyOverlaySize` | `thumbnail`, `compact`, `standard`, `feature`. Use fixed aspect-ratio frames. |
| presentation mode | `STRQHumanBodyPresentationMode` | `onboardingSelection`, `exerciseInfo`, `libraryFilter`, `progressCoverage`, `coachExplanation`, `neutral`. |

Rendering priority:

1. Danger / overload
2. Warning / rest caution
3. Exercise primary
4. Onboarding selected or general highlighted
5. Exercise secondary
6. Progress trained / undertrained intensity
7. Inactive / neutral

Design rule: the component architecture should make the Human Body Overlay feel like a premium STRQ explanation surface. It should never ship as a raw grid of anatomy assets, a debug preview, or a medical diagram.

## 4. Proposed data model

This is a data model proposal only; no Swift should be edited in this pass.

```swift
enum STRQMuscle: String, CaseIterable, Identifiable {
    case chest
    case back
    case lats
    case shoulders
    case biceps
    case triceps
    case forearms
    case traps
    case abs
    case obliques
    case glutes
    case quads
    case hamstrings
    case calves
    case lowerBack
    case lowerLeg
    case adductors
    case abductors
    case hipFlexors
    case tibialis
    case arms
    case core
}

enum STRQBodyOrientation: String, CaseIterable {
    case front
    case back
}

enum STRQBodySide: String, CaseIterable {
    case left
    case right
    case bilateral
    case center
}

enum STRQBodyVariant: String, CaseIterable {
    case male
    case female
    case neutral
}

enum STRQMuscleHighlightState: String, CaseIterable {
    case neutral
    case selected
    case primary
    case secondary
    case trained
    case undertrained
    case warning
    case overload
    case restCaution
    case inactive
}

enum STRQHumanBodyOverlaySize: String, CaseIterable {
    case thumbnail
    case compact
    case standard
    case feature
}

enum STRQHumanBodyPresentationMode: String, CaseIterable {
    case onboardingSelection
    case exerciseInfo
    case libraryFilter
    case progressCoverage
    case coachExplanation
    case neutral
}

struct STRQMuscleHighlight: Identifiable, Hashable {
    let id: String
    let muscle: STRQMuscle
    let state: STRQMuscleHighlightState
    let side: STRQBodySide
    let intensity: Double
}
```

Mapping notes:

- `quads` should map to source-backed `UpperLeg` overlays for V1.
- `lats` and `lowerBack` should map to `Back` for V1 unless later masks split them cleanly.
- `obliques` and `core` should map to `Abs` for V1.
- `arms` should render as Bicep plus Tricep plus Forearm when those overlays exist.
- `adductors`, `abductors`, and `hipFlexors` should map to Upper Leg or Glute context only when a screen can explain the simplification clearly.
- `neutral` body variant should be a future product option. Until a neutral asset exists, the component can default to the user's chosen artwork variant or app default without exposing a clinical selector.

## 5. Runtime asset map

Current 9 pilot assets imported for DEBUG/Rork rendering QA:

| Asset | Type | Variant | Orientation | Muscle | Status |
|---|---|---|---|---|---|
| `STRQHumanBodyMaleFrontBase` | Base | Male | Front | None | Pilot imported |
| `STRQHumanBodyMaleBackBase` | Base | Male | Back | None | Pilot imported |
| `STRQHumanBodyFemaleFrontBase` | Base | Female | Front | None | Pilot imported |
| `STRQHumanBodyFemaleBackBase` | Base | Female | Back | None | Pilot imported |
| `STRQHumanBodyMaleFrontChestOverlay` | Overlay | Male | Front | Chest | Pilot imported |
| `STRQHumanBodyMaleFrontShoulderOverlay` | Overlay | Male | Front | Shoulder | Pilot imported |
| `STRQHumanBodyMaleBackBackOverlay` | Overlay | Male | Back | Back | Pilot imported |
| `STRQHumanBodyFemaleFrontChestOverlay` | Overlay | Female | Front | Chest | Pilot imported |
| `STRQHumanBodyFemaleBackGluteOverlay` | Overlay | Female | Back | Glute | Pilot imported |

Future full V1 asset set:

| Family | Required assets |
|---|---|
| Base bodies | `STRQHumanBodyMaleFrontBase`, `STRQHumanBodyMaleBackBase`, `STRQHumanBodyFemaleFrontBase`, `STRQHumanBodyFemaleBackBase` |
| Front overlays per variant | Chest, Shoulder, Bicep, Forearm, Abs, UpperLeg, LowerLeg |
| Back overlays per variant | Back, Shoulder, Tricep, Forearm, Glute, Hamstring, Calf, Trap |
| Deferred by default | Hand, Neck, organ anatomy, Body Type visuals |

Current missing overlay assets for V1:

| Variant/orientation | Missing overlays |
|---|---|
| Male Front | Abs, Bicep, Forearm, LowerLeg, UpperLeg |
| Male Back | Shoulder, Tricep, Forearm, Glute, Hamstring, Calf, Trap |
| Female Front | Shoulder, Abs, Bicep, Forearm, LowerLeg, UpperLeg |
| Female Back | Back, Shoulder, Tricep, Forearm, Hamstring, Calf, Trap |

Runtime asset naming rules:

- Base: `STRQHumanBody{Variant}{Orientation}Base`
- Overlay: `STRQHumanBody{Variant}{Orientation}{SourceArea}Overlay`
- Use source-backed area names in asset names: `UpperLeg`, `LowerLeg`, `Back`, `Abs`.
- Use product labels in UI: Quads, Lower Leg, Back, Core.
- Do not include `Selected`, `Unselected`, `Warning`, `Primary`, or `Secondary` in asset names.
- Do not include Figma node IDs or Sandow/source names in runtime asset names.
- Use vector PDF for production runtime unless a later macOS/Xcode QA pass proves another path is safer.

## 6. Visual state system

The visual state system should be semantic, calm, and carbon-first. Color should explain training meaning, not decorate the body.

| State | Treatment |
|---|---|
| Onboarding selected | Cool teal/blue overlay, confident but not neon; supports multi-select. |
| Exercise primary | Strongest normal teal/blue treatment, about 85-100 percent opacity, optional subtle edge emphasis. |
| Exercise secondary | Same family at about 40-60 percent opacity; never a competing color. |
| Progress trained | Green used only when real volume or coverage data supports it. |
| Progress undertrained | Amber used for low coverage or imbalance; should read as "needs attention", not danger. |
| Coach warning | Amber for monitor/proceed-with-awareness; red/pink only for meaningful overload or rest-needed caution. |
| Recovery/rest caution | Amber or red/pink based on severity; use training language such as rest, recovery load, or volume management. |
| Neutral body | Base body only, with quiet graphite/white line work and no bright overlay. |
| Inactive/disabled | Base body with lower opacity and no semantic accent. |

Visual guardrails:

- Do not use the source orange selected state as the default STRQ selection color.
- Do not make the body look gamified, glowing, or arcade-like.
- Do not use organ anatomy or medical colors for normal strength training education.
- Primary versus secondary should be intensity-led, not rainbow-led.
- Warning and overload must remain clearly distinct from selected and progress-trained states.

## 7. Screen integration strategy

Onboarding muscle focus:

- Use the body map to help users choose muscles they want to emphasize or manage.
- Keep the tone goal-oriented: focus, build, balance, manage volume.
- Avoid body-shape judgment, medical labels, or clinical anatomy copy.
- Protect onboarding plan creation, persistence, and analytics in any future implementation.

Exercise Info primary/secondary muscle display:

- Use `ExerciseMuscleBodyMap` to show primary muscles with strong emphasis and secondary muscles with softer emphasis.
- Start as display-only and preserve exercise IDs, routing, favorites, logging, and any existing metadata.
- If a muscle has no overlay yet, show the neutral body plus existing text/chips rather than faking precision.

Exercise Library filters:

- Use `ExerciseLibraryMuscleFilterMap` later as a richer filter doorway after existing search/filter behavior is protected.
- The body should clarify filter state, not replace the list or create hidden filter behavior.
- Do not start here because filters are behavior-sensitive.

Progress muscle coverage:

- Use `ProgressMuscleCoverageMap` later to show weekly or monthly training coverage only from real training data.
- Use opacity or grouped states to communicate coverage rather than fake heat-map complexity.
- Keep Progress as proof and analysis, not a reward board.

Coach explanations:

- Use `CoachMuscleExplanationMap` later for focused explanations such as "we are backing off hamstrings today" or "push work is covered, pull work needs attention".
- The body map should support reasoning, not diagnose injury or become a generic assistant graphic.
- Preserve Coach actions, readiness, handoff, analytics, and model/service behavior.

## 8. Recommended first production target

Recommended first production target: **Exercise Info primary/secondary muscle display**.

Why this is the right first production target:

- It is naturally display-only.
- It uses existing exercise muscle metadata rather than creating new planning, filter, progress, or coach logic.
- It gives users immediate understanding of what an exercise trains.
- It is more product-relevant than the DEBUG Design System Lab and safer than Onboarding, Exercise Library filters, Progress, or Coach.
- It can gracefully fall back to existing text/chips for missing overlays while the full V1 asset set is completed.

Scope rule: the first production pass should integrate only this Exercise Info display target. It should not integrate Onboarding, Exercise Library, Progress, or Coach in the same pass.

## 9. Accessibility strategy

Accessibility should explain the training meaning, not the art.

- The base body should usually be hidden from accessibility when it is decorative context.
- The composite body map should expose one concise label, such as `Primary muscles: Chest and shoulders. Secondary muscle: triceps.`
- Interactive Onboarding or filter modes should expose each selectable muscle as a control with selected state.
- Do not rely on color alone. Pair semantic colors with labels, legends, or state copy where the state matters.
- VoiceOver labels should use STRQ product names such as Chest, Back, Quads, Hamstrings, Glutes, Abs, and Shoulders.
- Avoid clinical labels, organ labels, diagnostic language, and source asset names.
- Respect Dynamic Type in labels, legends, and surrounding copy.
- Respect Reduce Motion if the future component adds transition animations.
- Keep touch targets at least 44 x 44 points for interactive wrappers.
- All user-facing labels must be localizable in future implementation passes.

## 10. Performance and bundle-size guardrails

- Use vector PDF as the default runtime format for base and overlay assets.
- Preserve vector data and use original rendering for bases.
- Use template rendering for overlays so SwiftUI owns tint and opacity.
- Import by approved feature batch, not by dumping every Figma anatomy variant.
- Do not import selected/unselected duplicates when the renderer can express state.
- Do not import the 60 small 88x128 `Anatomy Muscle` cards into production unless full-body overlays fail for a specific use case.
- Avoid raster anatomy assets for V1.
- Keep base and overlay images in the exact same frame and aspect ratio to prevent alignment drift.
- Limit simultaneous overlays to the active semantic set for the current screen.
- Use fixed size presets and aspect-ratio constraints so layout does not shift when muscles change.
- Review bundle impact after each asset batch. The target should stay small enough that anatomy feels like a product feature, not a heavy media pack.
- Do not add animation until static rendering, alignment, and accessibility are production-proven.

## 11. Risks and guardrails

| Risk | Guardrail |
|---|---|
| The feature ships as a debug viewer | Wrap the renderer in product-specific modes with clear sizing, state, labels, and screen role. |
| Raw Figma/UI-kit output leaks into production | Use STRQ-owned component names, asset names, colors, and product labels. |
| Medical tone | Use fitness language: primary, secondary, volume, recovery, focus, balance, rest. |
| Neon/gamified body | Keep carbon foundation, restrained tint, and semantic color hierarchy. |
| Muscle precision is overstated | Document merged mappings and use fallback copy when overlays are broad. |
| Body variant sensitivity | Treat male/female as artwork variants, avoid judgmental body-type framing, and plan for neutral later. |
| Asset bloat | Import only base plus overlay PDFs needed by a scoped production target. |
| Alignment drift | Require same-frame rendering and visual QA for every base/overlay pair. |
| Color-only communication | Add accessibility labels and optional legends where semantic state matters. |
| Scope creep | First production integration is exactly one Exercise Info display target. |

## 12. QA checklist

Docs and scope QA:

- Only the approved docs changed in this pass.
- No Swift, assets, project files, localization files, tests, Widget, Watch, fonts, or production runtime assets changed.
- The plan distinguishes debug proof from product UI.
- The plan selects exactly one first production target.

Asset QA for future implementation:

- All base and overlay PDFs preserve vector rendering.
- Bases use original rendering and overlays use template rendering.
- Overlay assets share the exact rendered frame with their matching base.
- No source background, card border, or white canvas appears.
- Missing overlays fall back honestly instead of pretending full coverage.
- Back, UpperLeg/Quads, and Hamstring names receive owner review.

Visual QA:

- Neutral body reads on carbon.
- Onboarding selected, Exercise Info primary/secondary, Progress trained/undertrained, Coach warning, recovery/rest caution, and danger/overload states are visually distinct.
- Primary and secondary states remain legible without competing colors.
- The component does not look medical, neon, or raw-kit.
- Small, compact, standard, and feature sizes keep stable aspect ratios.

Integration QA for the first production target:

- Exercise Info routes and data sources are unchanged.
- Primary and secondary muscle data are displayed accurately.
- Existing muscle text/chips remain available as fallback or supporting context.
- No Exercise Library filter behavior changes.
- No Onboarding plan creation changes.
- No Progress calculations change.
- No Coach model, service, action, analytics, or handoff behavior changes.

Accessibility QA:

- VoiceOver has a concise composite summary.
- Interactive modes expose selected state.
- Semantic states are not color-only.
- Labels use user-facing STRQ muscle names.

Performance QA:

- No raster anatomy assets are introduced for V1.
- Bundle-size impact is reviewed after each import batch.
- Multi-overlay rendering stays smooth on small and large iPhone layouts.

Rork QA:

- Rork QA is not required for this docs-only pass.
- Rork QA is required for the first Swift/product integration and should capture Exercise Info with primary only, primary plus secondary, missing-overlay fallback, front orientation, back orientation, small iPhone, and large iPhone.

## 13. Exactly one next implementation prompt

```text
Use Licensed Source Mode.

Goal:
Create the first production STRQ Human Body Overlay component and integrate it only into Exercise Info primary/secondary muscle display.

Use:
- docs/strq-human-body-overlay-component-plan.md
- docs/figma-exports/human-body-overlay-xcode-smoke/README.md
- docs/figma-exports/human-body-overlay-visual-qa/README.md
- the 9 already imported Human Body vector PDF pilot assets

Implementation scope:
- Add a reusable `STRQHumanBodyOverlayView` and supporting types with STRQ-owned names.
- Use vector PDF base assets as original-rendered images and overlay assets as template-tinted images.
- Support body variant, front/back orientation, primary muscles, secondary muscles, neutral state, size, and presentation mode.
- Integrate only the Exercise Info primary/secondary muscle display target.
- Preserve all existing Exercise Info behavior, routing, exercise IDs, favorites/logging behavior, data models, services, analytics, localization catalogs, project files, tests, Widget, Watch, and production asset files.
- If an exercise references muscles without available overlays, show the neutral body plus existing muscle text/chips instead of faking coverage.

Do not integrate:
- Onboarding
- Exercise Library filters
- Progress
- Coach

Acceptance criteria:
- The component feels like a premium STRQ fitness explanation surface, not a debug anatomy viewer.
- Exercise Info shows primary and secondary muscles clearly when available.
- Existing Exercise Info behavior is unchanged.
- Missing overlay coverage degrades honestly.
- Rork QA screenshots are captured for primary-only, primary-plus-secondary, missing-overlay fallback, front/back, small iPhone, and large iPhone.
```
