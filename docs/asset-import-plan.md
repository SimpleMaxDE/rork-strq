# STRQ Asset Import Plan

Last updated: 2026-04-30

## Purpose

This plan controls future visual asset imports from the Purchased Figma UI Kit into STRQ-owned runtime assets. It prevents random ZIP dumps, redundant variants, source-name leakage, and assets that do not map to actual STRQ product needs.

No assets were imported in this pass.

Related control docs:

- [Docs README](README.md)
- [STRQ UI Migration Master Plan](strq-ui-migration-master-plan.md)
- [Figma Source Map](figma-source-map.md)
- [Design System Import Plan](design-system-import-plan.md)
- [Component Migration Plan](component-migration-plan.md)
- [STRQ Icon Coverage Plan](../ios/STRQ/Utilities/STRQIconCoveragePlan.md)
- [Sandow Anatomy Import Plan](../ios/STRQ/Utilities/SandowAnatomyImportPlan.md)

## Global Rules

- Do not import the full ZIP.
- Do not dump whole Figma pages into `Assets.xcassets`.
- Do not import coach/person photos unless explicitly approved.
- Do not import huge marketing mockups.
- Do not import social, payment, press, or brand logos unless a STRQ feature needs them.
- Do not import redundant state/color variants when SwiftUI tinting/state can handle them.
- Use STRQ-owned runtime naming for runtime asset names.
- Keep source/provenance names only in docs and manifests.
- Prefer the smallest useful asset set tied to a real STRQ screen, component, or product moment.

## Current Repo Asset State

| Category | Current state |
|---|---|
| App icon/accent | `AppIcon.appiconset`, `AccentColor.colorset` |
| STRQ sigil | `STRQSigil.imageset` |
| STRQ icons | 60 `STRQIcon*.imageset` folders |
| Body images | male/female front/back body PNGs plus premium male front/back PNGs |
| Work Sans fonts | No `.ttf`, `.otf`, `.woff`, or `.woff2` files found |
| New assets from this pass | None |

## Asset Categories

| Category | Figma source node(s) | Current repo state | Recommended format | Naming convention | Strategy | Template/tint | Priority | Risks |
|---|---:|---|---|---|---|---|---|---|
| Icons | Icon Set page `5367:38988`, Icons `5454:22014` | 60 STRQ template SVG image sets | SVG or vector PDF | `STRQIcon<Name>` | Import only needed gaps by feature batch | Yes, template/tintable | High | Mass replacement can break semantics and consistency |
| Anatomy muscle | `8673:69673` | Not imported; existing body map uses local SwiftUI/PNG assets | SVG/PDF masks preferred | `STRQAnatomy<Gender><Area>Mask` | Prefer base/masks plus SwiftUI state | Masks tintable; composites not pure template | High | 60 variants, gender topology differences, alignment |
| Full-body vectors | `9192:5535` | Not imported | SVG/PDF | `STRQAnatomyMaleFrontBase`, etc. | Export sample, verify viewBox alignment | Possibly neutral base, not state asset | High | Generic group names, alignment with masks unknown |
| Body type | `9025:207456` | Not imported | SVG/PDF or SwiftUI state | `STRQBodyType<Gender><Type>` | Only if product approves body type in onboarding/profile | Selected state in SwiftUI | Medium | Product scope and sensitive body-shape framing |
| Achievement badges | `9064:106798`, `_AchievementBadgeBase` `9063:203904` | Only generic icon/reward effects exist | SVG/PDF or SwiftUI vectors | `STRQAchievement<Milestone>` | Import only real STRQ milestones | Mostly tint/state in SwiftUI | Medium/High | Decorative overload, fake feature expectations |
| Fitness equipment visuals | `11536:90366` | Not imported | PNG/WebP if raster, SVG/PDF if vector | `STRQEquipment<Name>` | Import only for equipment filters/setup if approved | Usually no | Medium | Licensing and photo/demo placeholder risk |
| Base illustrations | `_IllustrationBase` `8912:62197`, Illustration `9125:148813` | Not imported | SVG/PDF/PNG by source | `STRQIllustration<Name>` | Use only for empty/onboarding/reward states with approved direction | Usually no | Medium | Generic style may dilute STRQ identity |
| Avatar illustrations | `8845:308989`, Media Avatar `5468:1034` | Not imported | SVG/PDF/PNG | `STRQAvatarIllustration<Name>` | Optional; use only if profile/coach/community needs it | Usually no | Low/Medium | Demo avatars can feel off-brand |
| Reward/confetti | Search pending; achievement/reward text found | Existing SwiftUI reward effects | SwiftUI first, asset only if needed | `STRQReward<Name>` | Prefer existing SwiftUI reward effects until real gap exists | State driven | Low/Medium | Unnecessary animation/asset churn |
| Organ anatomy | `9139:70026`, `_OrganAnatomyBase` `8860:134805` | Not imported | SVG/PDF | `STRQOrgan<Name>` | Do not import unless health education scope is approved | Maybe tintable by component | Low | Medical implication and scope creep |
| Media/image assets | Media `9125:50816` | Not imported | PNG/WebP/JPG by source | `STRQMedia<Name>` | Import only tied to product screens | No | Low/Medium | Licensing, file size, generic stock feel |

## Icon Import Policy

Use the [STRQ Icon Coverage Plan](../ios/STRQ/Utilities/STRQIconCoveragePlan.md) as the source of truth for current icon status.

Next icon imports should be tied to a concrete implementation need. Candidate medium-priority gaps:

- `STRQIconUnlock`
- `STRQIconWeightPlate`
- `STRQIconCrown`
- `STRQIconShield`
- `STRQIconSpark`
- `STRQIconUser`
- `STRQIconWatch`
- `STRQIconHelp`
- `STRQIconLogout`

Rules:

- Import one base regular/template icon per concept.
- Preserve vector representation.
- Set template rendering intent.
- Add matching `STRQIcon` enum cases in a dedicated implementation pass.
- Verify enum/asset sync after import.
- Do not import hover, selected, disabled, filled, bold, duotone, or color variants unless a real STRQ use case requires them.

## Anatomy Import Strategy

Use the [Sandow Anatomy Import Plan](../ios/STRQ/Utilities/SandowAnatomyImportPlan.md) as source/provenance context, but do not carry source naming into runtime assets.

Preferred strategy:

1. Inspect/export one male and one female sample from `Anatomy Muscle` `8673:69673`.
2. Inspect/export one full-body base sample from `9192:5535`.
3. Verify all samples are vector-only, transparent, crisp, and aligned.
4. Prefer base anatomy line art plus per-area masks.
5. Represent selected, inactive, primary, secondary, focus, reduce, and intensity states in SwiftUI.
6. Import only approved masks/base assets.
7. Add `STRQAnatomy*` components only after asset QA passes.

Fallback:

- If masks cannot align, use one composite body-area asset per gender/body area and still avoid selected-state duplicates.

Avoid:

- importing all 60 selected/unselected variants by default
- creating selected/disabled/pressed asset duplicates
- importing `Hand` unless STRQ adds grip/hand scope
- assuming Sandow body areas map perfectly to STRQ's richer `MuscleGroup` model

## Achievement Asset Strategy

Achievement badges are useful only if tied to real STRQ milestones.

Candidate milestone categories:

- first completed workout
- weekly consistency
- streak
- volume milestone
- personal record
- plan adherence
- recovery improvement
- sleep consistency

Do not imply leaderboard/social features unless STRQ product scope includes them.

## Equipment Asset Strategy

Only import equipment visuals if one of these product surfaces needs them:

- onboarding gym setup
- equipment filters
- exercise library filtering
- exercise detail equipment section
- workout card equipment context

Before import:

- confirm licensing/export rights
- confirm raster quality at iOS sizes
- confirm file size and dark/light background behavior
- decide whether visual should be a photo, icon, or simple illustration

## Assets Not To Import

Do not import by default:

- full source ZIP
- entire Figma file exports
- coach/person photos
- demo user photos
- marketing mockups
- maps
- press logos
- social media logos
- payment logos
- random brand logos
- medical/organ illustrations as decoration
- medication/pill assets unless product scope changes
- large background images
- redundant icon variants
- selected-state duplicates
- any unused asset without a STRQ target

## Import Workflow

| Step | Action |
|---:|---|
| 1 | Pick one asset category and exact Figma node |
| 2 | Record source node, variants, dimensions, and export risk |
| 3 | Choose STRQ-owned runtime names |
| 4 | Export only a tiny sample if format is uncertain |
| 5 | Verify asset renders correctly before adding a batch |
| 6 | Import minimal approved batch |
| 7 | Update manifest, source map, and asset plan |
| 8 | Verify `Contents.json`, vector/template settings, and runtime lookup |
| 9 | Keep production screens untouched unless separately approved |

## Validation Checks After Future Asset Imports

Run:

```bash
rg -n "Sandow" ios/STRQ/Assets.xcassets ios/STRQ/Views ios/STRQ/ContentView.swift
rg -n "enum STRQIcon|STRQIconView|STRQIcon[A-Za-z]+\\.imageset" ios/STRQ
rg -n "Image\\(systemName:" ios/STRQ/Views ios/STRQ/ContentView.swift
```

Expected:

- Sandow references remain docs/provenance only.
- New assets use STRQ names.
- Icon enum and assets are synced.
- Production screens are unchanged unless the pass explicitly scopes a migration.
