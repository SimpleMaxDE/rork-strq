# STRQ Licensed Figma Icon & Anatomy Adoption Map

Last updated: 2026-05-05

## 1. Executive summary

Icons and anatomy are the first direct Figma adoption target because they are the highest-value licensed assets with the lowest product ambiguity. STRQ already has a STRQ-owned icon registry and synced icon assets, and the purchased kit has a broad 1,078-row icon library with regular template candidates. STRQ also has muscle and body-map surfaces that currently rely on generic SF Symbols, simple SwiftUI body regions, and remote/generated body images. Those are visible places where STRQ can quickly stop feeling like a generic tracker.

This helps STRQ become less generic by replacing broad platform metaphors with a consistent fitness-specific visual language. Small icons can make navigation, coach reasoning, progress proof, profile controls, reminders, and Pro affordances feel coherent. Anatomy can make Exercise Library, Exercise Detail, onboarding muscle focus, and progress coverage feel like a serious strength product instead of a card stack with stock symbols.

This pass remains docs-only before export/import because asset export has downstream risks: bundle size, asset naming, Xcode vector rendering, selected-state duplication, muscle naming ambiguity, accessibility labels, dark/light compatibility, and project-file churn. The goal is to decide what should be adopted before any Figma export, Swift change, asset catalog import, or project-file change.

This map unlocks future implementation by naming the exact Figma source nodes, target STRQ-owned runtime names, adoption priorities, export formats, replacement opportunities, and guardrails. Future prompts can start from this map instead of rediscovering the same Figma source.

## 2. Figma usage report

[@Figma](plugin://figma@openai-curated) was used read-only before this document was written. The `figma-use` skill was loaded first. No Figma canvas writes, asset exports, screenshots, downloaded assets, Swift edits, asset catalog edits, project-file edits, localization edits, or test edits were made.

Figma file:

| Item | Value |
|---|---|
| Purchased kit | `SH-sandow-UI-Kit--v3.0-` |
| Provided file key used | `LBvxljax0ixoTvbvvUeWVC` |
| Mode | Licensed Source Mode |
| Tool behavior | `get_metadata` plus guarded read-only Plugin API traversal |
| Runtime note | Plugin API reported `fileKey: headless` while operating on the requested file key |

Inspected pages/categories/nodes:

| Figma source | Node ID | What was found |
|---|---:|---|
| Design System - Icon Set page | `5367:38988` | Page contains `Icon Container`, `Icon Featured`, and `Icons` |
| Icon library | `5454:22014` | 1,078 icon rows; 6 styles per row in most inspected matches: Light, Regular, Bold, Fill, Duotone, Duoline |
| Icon Container | `9131:300866` | Size variants `xs`, `sm`, `md`, `lg`, `xl`, `2xl`, `3xl`, `4xl` |
| Icon Featured | `5546:2332` | 180 variants by hierarchy, size, and tone |
| Illustration page area | `9125:148813` | 15 component sets, 303 components, anatomy/body/badge/illustration sources |
| Media page area | `9125:50816` | 20 component sets, 805 components, equipment/media sources |
| Anatomy Muscle | `8673:69673` | 60 vector-only components, 780 vectors, 3 group wrappers |
| Body Type | `9025:207456` | 12 vector components, male/female, ectomorph/mesomorph/endomorph, default/selected |
| Organ Anatomy | `9139:70026` | 5 size wrapper variants |
| Organ Anatomy Base | `8860:134805` | 19 organ/body variants |
| Large anatomy vector groups | `9192:5535` | 4 generic groups, 225 vectors, likely full-body line art |
| Fitness Equipment Image | `11536:90366` | Equipment image area with 20 rectangles under a media frame |
| Achievement Badge | `9064:106798` | 6 size variants from `sm` through `3xl` |
| Achievement Badge Base | `9063:203904` | 60 variants by shape and tone, with icon swap and shining boolean |
| Illustration Base | `8912:62197` | 32 base illustration variants |

Exact icon rows confirmed in this pass include:

| STRQ-relevant concept | Figma row | Regular node ID | Notes |
|---|---|---:|---|
| Home | `house-1` | `8997:7938` | Current STRQ navigation candidate |
| Calendar / Today date | `calendar-1` | `8997:8083` | Scheduling, reminders, weekly review |
| Coach / chat | `chat` | `8997:8278` | Coach tab, coach reasoning |
| Training | `barbell-horizontal` | `8997:1731` | Train and workout |
| Progress | `chart-bar-1` | `8997:14737` | Progress/analytics |
| Profile/user | `user` | `8997:8726` | Profile/settings |
| Settings | `gear-1` | `8997:7901` | Settings |
| Intelligence | `brain-1` | `8997:2666` | Coach, adaptation, Pro |
| AI/pro spark | `sparkle-1` | `8997:9191` | Use sparingly |
| Target | `target-1` | `8997:8561` | Goals, training target |
| Energy/readiness | `lightning-bolt-1` | `8997:7756` | Readiness, energy, Pro with caution |
| Gym/equipment | `kettlebell` | `8997:4224` | Equipment/gym context |
| Muscle | `bicep` | `8997:5475` | General muscle icon only |
| Full body | `person-arms-spread` | `8997:1928` | Small body selector icon |
| Progress trend | `chart-trend-up` | `8997:15175` | Chart line icon |
| Trend up | `arrow-trend-up` | `8997:13776` | Compact deltas |
| Trend down | `arrow-trend-down` | `8997:13791` | Compact deltas |
| Trophy | `trophy-1` | `8997:12250` | Milestones |
| Medal | `medal` | `8997:15781` | Achievements |
| Streak | `fire-1` | `8997:5926` | Streaks, use without over-gamifying |
| Percentage | `percentage` | `8997:7166` | Adherence, scores |
| Ring/donut | `chart-donut-1` | `8997:14897` | Activity ring approximation |
| Bell | `bell-1` | `8997:9756` | Notifications |
| Watch | `smart-watch` | `8997:8233` | Device/watch settings |
| Help | `question-mark-circle` | `8997:7586` | Support/help |
| Logout | `arrow-sign-out-1` | `8997:14200` | Account actions |
| Shield | `shield` | `8997:7512` | Trust/security |
| Lock | `lock-1` | `8997:15495` | Locked/pro states |
| Unlock | `lock-unlocked-1` | `8997:15526` | Trial/unlock states |
| Crown | `crown-1` | `9064:208861` | Pro/paywall |
| Credit card | `credit-card` | `8997:7197` | Payment only if needed |
| Check circle | `check-circle` | `8997:8934` | Included benefits/status |
| Heart | `heart` | `8997:1201` | Recovery/health |
| Heart ECG | `heart-ecg` | `8997:1230` | Readiness/health |
| Moon | `moon` | `8997:5785` | Sleep |
| Rest | `sleep-zzz` | `8997:2367` | Rest |
| Soreness | `person-injured` | `8997:2065` | Soreness/pain caution |
| Hydration | `water-drop` | `8997:1157` | Hydration |
| Nutrition | `fork-knife` | `8997:5880` | Nutrition |
| Search | `magnifying-glass` | `8997:7711` | Search fields |
| Close | `close-x` | `8997:8831` | Dismiss |
| Check | `check` | `8997:8875` | Completion |
| Plus | `plus` | `8997:8846` | Add |
| Warning | `exclamation-mark-triangle` | `8997:7601` | Caution |
| More | `dot-three-horizontal` | `8997:9099` | Overflow |

What was intentionally ignored:

- Figma canvas writes, screenshots, and asset exports.
- Sandow logo and source brand identity.
- Full-screen cloning from the kit.
- Decorative gradients and raw orange brand styling.
- Social/community, desktop side navigation, payment logos, maps, demo photos, and broad marketing media.
- Organ anatomy as a default fitness visual.
- Body-area small icons that are weaker than the anatomy assets.

Limitations:

- No asset files were exported, so vector rendering, viewBox alignment, template rendering, and Xcode import behavior remain unverified.
- Large Figma reads are prone to output truncation; targeted scripts were used to avoid broad file dumps.
- Icon category labels were not reliably exposed by the Plugin API traversal; adoption categories below are STRQ product categories mapped from confirmed icon row names.
- Large anatomy vector groups are still generically named `Group`, so male/female and front/back labels need visual/export QA.

## 3. Licensed source policy for this asset map

The purchased Figma kit is fully licensed for commercial STRQ use. Within STRQ, the inspected assets may be used directly, adapted, recreated, exported, or implemented 1:1 where appropriate.

Policy:

- Direct adoption is allowed for licensed icons, anatomy vectors, body type assets, equipment visuals, achievement badges, and illustration sources when they map to a real STRQ product need.
- Adaptation is allowed when source material needs STRQ-owned naming, dark carbon styling, fitness-specific semantics, accessibility, or reduced visual noise.
- Export/import will happen only in later scoped passes.
- Runtime names must be STRQ-owned, such as `STRQIconCrown` or `STRQAnatomyMaleChestMask`.
- Source names and node IDs should stay in docs, manifests, and provenance notes, not user-facing copy.
- User-facing labels must describe STRQ concepts, not Figma node names.
- Do not put `Sandow`, raw source icon names, or source node IDs into Swift symbols, localization keys, analytics events, app copy, or asset names.

## 4. Icon adoption inventory

Use one base regular/template icon per concept unless visual QA proves another style is needed. State, tone, selected, disabled, warning, success, destructive, premium, and pressed treatment should usually be SwiftUI styling, not duplicate exported assets.

| Group | Relevant Figma source | Likely STRQ use | Decision | Priority | Notes |
|---|---|---|---|---|---|
| Navigation/tab icons | Icon library `5454:22014`; `house-1`, `chat`, `barbell-horizontal`, `chart-bar-1`, `user`; Icon Container `9131:300866`; Icon Featured `5546:2332` | App tab bar, Today/Home, Coach, Train, Progress, Profile | Adopt directly where already imported; adapt container/tone | High | Current `ContentView` still uses SF Symbols for tabs. Replace only in a scoped app-shell pass because navigation behavior is protected. |
| Coach/intelligence icons | `chat`, `brain-1`, `sparkle-1`, `target-1`, `lightning-bolt-1`, `robot-1` | CoachTab, Weekly Review, More Signals, Pro coaching features | Adapt | High | Use `brain` and `chat` for reasoning; use `sparkle` rarely to avoid AI-app cliches. |
| Workout/training icons | `barbell-horizontal`, `kettlebell`, `clock`, `arrow-repeat-clockwise-1`, `arrow-skip-forward`, `play`, `pause`, `stop`, `list-three-bullet` | Train, active workout controls, plan days, handoff cards | Adopt directly for interface controls; adapt workout-specific grouping | High | Many are already imported. Avoid changing workout handoff/actions in an icon-only pass. |
| Exercise/muscle icons | `bicep`, `person-arms-spread`, `kettlebell`; Anatomy Muscle `8673:69673` for body regions | Exercise Library filters, exercise cards, muscle chips, body selector | Adopt small general icons; use anatomy for body regions | High | Do not force chest/back/core/legs from weak small-icon approximations such as `spine`, `stomach`, or `foot-step`. |
| Progress/analytics icons | `chart-bar-1`, `chart-trend-up`, `arrow-trend-up`, `arrow-trend-down`, `chart-donut-1`, `percentage`, `trophy-1`, `medal`, `fire-1` | Progress, Weekly Review, trends, milestones, streaks | Adopt/adapt | High | Existing STRQ icon coverage is strong. Replace scattered SF Symbols in Progress later with report/chart QA. |
| Profile/settings icons | `user`, `gear-1`, `bell-1`, `smart-watch`, `question-mark-circle`, `arrow-sign-out-1`, `shield`, `lock-1`, `cloud-1` | Profile rows, account, notifications, watch, help, sync, trust | Adapt | Medium | Profile already uses some STRQ icons; remaining SF Symbols can migrate by row cluster. |
| Notification/reminder icons | `bell-1`, `bell-ringing`, `bell-slash-*`, `calendar-1`, `calendar-check`, `clock`, `alarm` | NotificationSettings permission/schedule/reminder rows | Adopt/adapt | High | Good first runtime replacement candidate after icons are fully mapped because it is control UI, but scheduling behavior is protected. |
| Paywall/pro icons | `crown-1`, `shield`, `sparkle-1`, `lock-1`, `lock-unlocked-1`, `credit-card`, `check-circle` | Pro hero, benefits, trust row, trial, locked features | Adapt | Medium | RevenueCat behavior is protected. Use only in a paywall visual pass. `credit-card` is low until payment UI explicitly needs it. |
| Health/recovery/readiness icons | `heart`, `heart-ecg`, `moon`, `sleep-zzz`, `brain-1`, `water-drop`, `fork-knife`, `person-injured`, `leaf`, `lightning-bolt-1` | Readiness, recovery, sleep, nutrition, soreness, hydration, stress | Adopt/adapt | High | Several already imported. Keep medical implication low; do not make readiness look clinical. |
| Action/status icons | `check`, `check-circle`, `close-x`, `plus`, `minus`, `arrow-*`, `chevron-*`, `info`, `exclamation-mark-triangle`, `trash-1`, `pencil-1`, `dot-three-horizontal` | Buttons, list rows, sheets, warning states, editing, deletion | Adopt directly | High | This is the safest icon category. It should replace SF action symbols through existing `STRQIconView` and `STRQIconContainer`. |
| Empty-state/support icons | `question-mark-circle`, `info`, `magnifying-glass`, `folder`, warning/action icons; Illustration Base `8912:62197` | Exercise Library no results, Progress no data, support states | Adapt | Medium | Prefer icons for compact empty states and only use illustrations when they clarify a real empty or educational moment. |

## 5. Current STRQ icon replacement opportunity

Static source search shows production views still use many `Image(systemName:)` calls, including tab icons, CoachTab signals, Weekly Review, Progress, Train, Exercise Library, Paywall, Profile, and onboarding-adjacent body/muscle surfaces. Replacement should be phased by risk and by whether the icon is purely decorative/display-only or tied to a protected action.

| Target | Current icon issue | Figma opportunity | Replace soon or later | Risk |
|---|---|---|---|---|
| CoachTab | Heavy SF Symbol use for readiness, primary moves, supporting signals, weekly review, and action affordances | `chat`, `brain-1`, `target-1`, `heart-ecg`, `lightning-bolt-1`, `calendar-1`, Icon Featured treatment | Later, after a display-only Coach icon map | Medium | Coach has protected sheets, workout handoff, readiness check-in, weekly review, and analytics behavior. |
| Profile | Mixed state: some controls now use `STRQIcon`, but account, Pro, iCloud, trust, sign-out, and danger rows still use SF Symbols | `user`, `bell-1`, `smart-watch`, `question-mark-circle`, `arrow-sign-out-1`, `shield`, `lock-1`, `cloud-*`, `crown-1` | Soon for non-danger row clusters; later for account/subscription rows | Low/Medium | Profile row visuals are lower risk, but restore purchases, sign-out, reset, and paywall entry remain protected. |
| NotificationSettings | Likely SF Symbol reminder/control language | `bell-1`, `bell-ringing`, `bell-slash`, `clock`, `alarm`, `calendar-check` | Soon after a behavior map | Medium | Notification permission and scheduling behavior must not change. |
| CoachingPreferences | Preference rows can look like generic settings if SF Symbols vary by source | `brain-1`, `target-1`, `sparkle-1`, `check-circle`, `lock-1`, `shield` | Later | Medium | Locked/unlocked Pro behavior and persistence must remain untouched. |
| Weekly Review | SF charts, checkmarks, arrows, coach summary symbols make the report feel platform-generic | `chart-trend-up`, `chart-bar-1`, `percentage`, `medal`, `target-1`, `chat`, `brain-1` | Later | Medium/High | Weekly review has carousel, selected action, confirmation dialog, and `vm.applyReviewAction`. |
| Progress | Many SF chart, trophy, flame, heart, calendar, figure icons remain | Existing `STRQIconChartLine`, `STRQIconChartBar`, `STRQIconTrophy`, `STRQIconMedal`, `STRQIconFire`, `STRQIconHeart`, `STRQIconActivityRing` | Later as a report-system pass | Medium | Broad visual replacement could disturb dense analytics hierarchy. |
| Train | TrainingPlan and handoff surfaces use SF figures/brain/bolt/calendar controls | `barbell-horizontal`, `kettlebell`, `clock`, `repeat`, `swap`, `play`, `target-1`, `brain-1` | Later | High | Train connects to workout generation, handoff, active workout, and protected training behavior. |
| Exercise Library | Uses SF `MuscleGroup.symbolName`, stars, filters, world/family icons, and generic body imagery | `bicep`, `person-arms-spread`, `kettlebell`, `magnifying-glass`, Anatomy Muscle `8673:69673`, equipment `11536:90366` | Later, after anatomy export pilot | Medium/High | Exercise IDs, search/filter semantics, favorites, and detail routing must remain intact. |
| Paywall | Pro hero, pillars, trust row, trial, and plan states use SF Symbols | `crown-1`, `shield`, `sparkle-1`, `lock-unlocked-1`, `check-circle`, pricing/featured icon patterns | Later | High | RevenueCat purchase, restore, offering, package selection, and legal copy are protected. |
| Onboarding | Body/goal visuals can feel generic and sensitive if driven by SF or raw body-type art | Body Type `9025:207456`, Anatomy Muscle `8673:69673`, Illustration Base `8912:62197`, `target-1`, `calendar-1` | Later, plan-first | High | Onboarding creates plan inputs and has sensitive body-shape framing. |

## 6. Anatomy adoption inventory

| Asset family | What exists | STRQ use case | Likely screens | Direct/adapt/ignore | Priority | Export considerations |
|---|---|---|---|---|---|---|
| Anatomy Muscle `8673:69673` | 60 vector-only components, 2 genders x 15 body areas x selected/unselected, 88 x 128 each | Muscle focus tiles, exercise primary/secondary muscle visuals, muscle filters, plan balance | Exercise Library, Exercise Detail, MuscleFocusView, BodyMapView, Onboarding, Progress | Adopt/adapt | High | Do not import all 60 by default. Export pilot should compare selected/unselected and gender topology, then prefer masks plus SwiftUI state. |
| Large anatomy vector groups `9192:5535` | 4 unlabeled groups, 225 vectors, likely male/female front/back line art | Full-body base anatomy, front/back body map, muscle overlay base | Exercise Detail, Exercise Library, Onboarding, Progress | Adapt | High | Needs visual labeling and viewBox normalization before import. Coordinate alignment with Anatomy Muscle is unknown. |
| Body Type `9025:207456` | 12 vector components, male/female, ectomorph/mesomorph/endomorph, default/selected, 130 x 360 | Optional body-type onboarding/profile visuals | Onboarding, Profile physique setup | Adapt or ignore until product-approved | Medium | Sensitive framing risk. Prefer goal/experience language over body-shape typing unless owner approves. |
| Organ Anatomy `9139:70026` and `_OrganAnatomyBase` `8860:134805` | 5 size wrappers; 19 organ/body types including lung, brain, kidney, heart, stomach, spine, knee, skin, eye | Limited health/recovery education if STRQ adds a clear feature | Recovery education, Coach educational notes | Mostly ignore | Low | Medical tone and scope creep. Do not use as decoration. |
| Fitness Equipment Image `11536:90366` | Media/equipment area with 20 image rectangles | Equipment filters, gym setup, exercise equipment context | Exercise Library, Exercise Detail, Onboarding equipment setup | Adapt after QA | Medium | Likely raster/photo-style. Must verify quality, license source inside kit, file size, and dark background behavior. |
| Achievement Badge `9064:106798` | 6 size wrapper variants | Milestone visual shell | Progress, Weekly Review, completion states | Adapt | Medium | Use only when backed by real achievements. Avoid reward-board overload. |
| `_AchievementBadgeBase` `9063:203904` | 60 variants by shape and tone, icon swap, shining boolean | Badge base for real milestones | Progress, Weekly Review, Workout Completion | Adapt | Medium | Prefer SwiftUI tone/state where possible; do not import all shapes/tones. |
| Illustration Base `8912:62197` | 32 base illustration variants, 256 x 256 | Empty states, onboarding support, paywall support, educational moments | Exercise Library empty states, onboarding, paywall, support | Adapt selectively | Medium | Use sparingly. Avoid generic app illustration feel. |

## 7. STRQ muscle/anatomy target map

Preferred runtime strategy: base anatomy line art plus target-area masks. Use SwiftUI for selected/unselected/focus/reduce/primary/secondary/intensity state. Create selected-state assets only if export QA proves masks are not viable.

Naming convention:

- Base line art: `STRQAnatomyMaleFrontBase`, `STRQAnatomyMaleBackBase`, `STRQAnatomyFemaleFrontBase`, `STRQAnatomyFemaleBackBase`.
- Area masks: `STRQAnatomyMaleChestMask`, `STRQAnatomyFemaleChestMask`, etc.
- If later import uses full composite per body area rather than masks, drop `Mask`.
- Keep Figma body area labels in docs only.

| STRQ group | Proposed STRQ asset name | Figma source category/node | Selected/unselected need | Likely usage | Priority |
|---|---|---|---|---|---|
| chest | `STRQAnatomy{Gender}ChestMask` | Anatomy Muscle `8673:69673`, Body Area `Chest` | SwiftUI state preferred | Exercise muscle focus, Exercise Detail, onboarding focus | High |
| back | `STRQAnatomy{Gender}BackMask` | Anatomy Muscle `8673:69673`, Body Area `Back` | SwiftUI state preferred | Back-focused exercises, Progress muscle coverage | High |
| shoulders | `STRQAnatomy{Gender}ShoulderMask` | Anatomy Muscle `8673:69673`, Body Area `Shoulder` | SwiftUI state preferred | Exercise cards, body selector | High |
| biceps | `STRQAnatomy{Gender}BicepMask` | Anatomy Muscle `8673:69673`, Body Area `Bicep` | SwiftUI state preferred | Arm exercises, muscle chips | High |
| triceps | `STRQAnatomy{Gender}TricepMask` | Anatomy Muscle `8673:69673`, Body Area `Tricep` | SwiftUI state preferred | Arm exercises, rear-arm focus | High |
| forearms | `STRQAnatomy{Gender}ForearmMask` | Anatomy Muscle `8673:69673`, Body Area `Forearm` | SwiftUI state preferred | Grip/forearm exercise context | Medium |
| abs/core | `STRQAnatomy{Gender}AbsMask` | Anatomy Muscle `8673:69673`, Body Area `Abs` | SwiftUI state preferred | Core/abs exercises, onboarding focus | High |
| obliques | `STRQAnatomy{Gender}ObliqueMask` | Adapt from Anatomy Muscle `Abs`; no direct oblique source | SwiftUI state preferred | Core filters and muscle focus | Medium |
| glutes | `STRQAnatomy{Gender}GluteMask` | Anatomy Muscle `8673:69673`, Body Area `Glute` | SwiftUI state preferred | Lower body exercises, body selector | High |
| quads | `STRQAnatomy{Gender}UpperLegMask` or `STRQAnatomy{Gender}QuadMask` | Anatomy Muscle `8673:69673`, Body Area `Upper Leg` | SwiftUI state preferred | Quads/lower body filters | High |
| hamstrings | `STRQAnatomy{Gender}HamstringMask` | Anatomy Muscle `8673:69673`, Body Area `Hamstring` | SwiftUI state preferred | Posterior chain exercises | High |
| calves | `STRQAnatomy{Gender}CalfMask` | Anatomy Muscle `8673:69673`, Body Area `Calf` | SwiftUI state preferred | Calf/lower leg exercises | Medium |
| traps | `STRQAnatomy{Gender}TrapMask` | Anatomy Muscle `8673:69673`, Body Area `Trap` | SwiftUI state preferred | Upper back/shoulder support | Medium |
| lats | `STRQAnatomy{Gender}LatMask` | Adapt from Anatomy Muscle `Back`; no direct lat source | SwiftUI state preferred | Pulling exercises, Progress muscle coverage | Medium |
| lower back | `STRQAnatomy{Gender}LowerBackMask` | Adapt from Anatomy Muscle `Back`; no direct lower-back source | SwiftUI state preferred | Hinge/posterior chain context | Medium |
| tibialis/lower leg | `STRQAnatomy{Gender}LowerLegMask` | Anatomy Muscle `8673:69673`, Body Area `Lower Leg` | SwiftUI state preferred | Lower-leg/anterior shin support | Medium |
| adductors/abductors/hip flexors | `STRQAnatomy{Gender}UpperLegMask` plus STRQ overlay metadata | Anatomy Muscle `8673:69673`, Body Area `Upper Leg` | SwiftUI state preferred | Lower-body categories, not precise anatomy | Low/Medium |
| neck | `STRQAnatomy{Gender}NeckMask` | Anatomy Muscle `8673:69673`, Body Area `Neck` | SwiftUI state preferred | Rare exercise context | Low |
| full body front | `STRQAnatomy{Gender}FrontBase` | Large anatomy groups `9192:5535` | Not selected-state asset | Full body map base, onboarding focus | High |
| full body back | `STRQAnatomy{Gender}BackBase` | Large anatomy groups `9192:5535` | Not selected-state asset | Full body map base, Progress muscle map | High |
| male variants | `STRQAnatomyMale...` | Anatomy Muscle `8673:69673`; large groups `9192:5535` | Separate male geometry | Gender-specific body maps if product needs them | High |
| female variants | `STRQAnatomyFemale...` | Anatomy Muscle `8673:69673`; large groups `9192:5535` | Separate female geometry | Gender-specific body maps if product needs them | High |
| selected state | No default selected asset; use renderer state | Figma selected variants exist in `8673:69673` | SwiftUI selected/focus styles | All anatomy screens | High |
| unselected state | Base/mask neutral state | Figma unselected variants exist in `8673:69673` | SwiftUI inactive/secondary styles | All anatomy screens | High |

## 8. Export/import strategy

Do not export now. Future export/import should follow this strategy.

| Asset type | Recommended format | Scale strategy | Runtime/import strategy |
|---|---|---|---|
| Template icons | Keep current STRQ pattern: SVG template image set with vector preservation; convert SVG-to-PDF only if Xcode rendering QA fails | 24 x 24 source, sized in SwiftUI via `STRQIconView` | One `STRQIcon<Name>` asset and enum case per concept; no state/style duplicates |
| Featured icon containers | SwiftUI recreation using `STRQIconContainer` and style tokens | Use existing `xs` through `xl` container sizes, not raster sizes | Do not export featured icon backgrounds unless a multicolor illustration is needed |
| Anatomy base line art | Vector PDF or SVG after export QA | Normalize viewBox across male/female front/back | Store as base assets only if alignment is stable |
| Anatomy target areas | SVG/PDF masks preferred | Shared canvas/viewBox per gender/orientation if possible | Use SwiftUI for selected, focus, reduce, intensity, primary, secondary |
| Anatomy fallback composites | Vector PDF/SVG per gender/body area | 88 x 128 components can scale as tiles | Use only if masks cannot be isolated cleanly |
| Equipment visuals | PNG/WebP if source is raster; SVG/PDF only if vector | Export at 1x source and verify @2x/@3x appearance in app | Import only approved equipment categories; avoid photo dump |
| Body Type visuals | Vector PDF/SVG | 130 x 360 source ratio | Import only if onboarding/profile product language is approved |
| Achievement badges | SwiftUI recreation first; vector PDF/SVG only for approved base shapes | Use size wrappers in SwiftUI | Do not import 60 shape/tone variants |
| Illustrations | SVG/PDF if vector; PNG/WebP if raster | 256 x 256 source variants, responsive frame in app | Use only for approved empty/onboarding/paywall moments |

Naming convention:

- Icons: `STRQIcon<Name>`, lower-camel enum case mapping to the asset raw value.
- Anatomy base: `STRQAnatomy<Gender><Orientation>Base`.
- Anatomy masks: `STRQAnatomy<Gender><Area>Mask`.
- Equipment: `STRQEquipment<Name>`.
- Body type: `STRQBodyType<Gender><Type>`.
- Achievement: `STRQAchievement<Milestone>` or `STRQAchievementBadge<Shape>` only after milestone scope is real.
- Illustration: `STRQIllustration<Name>`.

Asset catalog structure:

- Keep current icon assets synced with `STRQIcon` and `STRQIconView`.
- Use a dedicated asset catalog group for future anatomy, such as `Anatomy`, if/when import occurs.
- Do not place Figma node IDs or source names in asset names.
- Do not add selected/disabled/pressed asset variants when SwiftUI can express state.

Accessibility:

- Icons and anatomy assets should not carry accessibility text from source names.
- Decorative icons should be hidden from accessibility.
- Informative icons need localized labels from STRQ product language.
- Anatomy controls need labels like `Chest selected`, `Back primary muscle`, or `Reduce hamstrings`, not `Body Area=Hamstring`.
- Equipment images need localized equipment names if user-visible.

Dark/light compatibility:

- Template icons should use SwiftUI tint so dark/light compatibility is controlled by STRQ tokens.
- Anatomy neutral line art must be tested on carbon/dark, grouped light surfaces, and high-contrast states.
- Avoid orange selected fills from the source unless a STRQ semantic color decision approves them.

Avoid app bundle bloat:

- Import by feature batch, not whole source family.
- Prefer one template icon per concept.
- Avoid all six icon styles.
- Avoid selected-state anatomy duplicates unless required.
- Avoid all 32 illustrations and all 60 achievement bases by default.
- Keep equipment visuals to approved filter/setup categories only.
- Run bundle-size review after any raster import.

## 9. Implementation roadmap

| Phase | Scope | Risk | Expected payoff | Required QA |
|---|---|---|---|---|
| Phase 1: docs mapping completed | This document and progress-log entry | Low | Clear licensed source map before any export/import | Git diff confirms docs-only changes |
| Phase 2: export selected pilot icon/anatomy assets | Export the chosen pilot only to a QA/provenance location, not app assets | Medium | Verifies vector quality, viewBox, state differences, and naming before app import | Figma source IDs, exported file list, vector-only check, visual preview |
| Phase 3: asset catalog import | Import only approved pilot assets into `Assets.xcassets` | Medium | Makes assets available to runtime without broad screen changes | `Contents.json`, vector/template settings, enum sync where relevant, bundle-size check |
| Phase 4: replace selected runtime icons in one low-risk screen | Use imported/existing icons in one display/control slice | Medium | Proves runtime icon style without broad app churn | Rork screenshots, tap-route checks, accessibility labels |
| Phase 5: anatomy integration in Exercise Library / muscle focus | Replace generic body map/muscle imagery with licensed anatomy renderer | Medium/High | Major STRQ differentiation in exercise discovery and muscle education | Front/back, gender if used, selected/unselected, small/large devices, search/filter behavior |
| Phase 6: broader icon system replacement | Replace scattered SF Symbols across Coach, Progress, Train, Paywall, Profile, onboarding | Medium/High | Cohesive STRQ visual language across app | Screen-by-screen behavior protection, Rork visual QA, accessibility, no generic AI-app feel |

## 10. Risks and guardrails

| Risk | Guardrail |
|---|---|
| Raw UI-kit look | Adopt source assets through STRQ-owned names, carbon styling, product roles, and restrained use. |
| Mixing SF Symbols and Figma icons poorly | Replace by scoped surface, not randomly. Keep stroke weight, size, and container treatment consistent. |
| Inconsistent stroke weights | Prefer regular-style icons as base. Run visual QA against existing `STRQIconView` at common sizes. |
| Asset bloat | Import only one base icon per concept and minimal anatomy/equipment/illustration subsets. |
| Unclear muscle naming | Map Figma body areas to `MuscleGroup` in docs before runtime implementation. Keep lats/obliques/lowerBack/adductors/etc. caveats explicit. |
| Anatomy looking medical rather than fitness | Use muscle and full-body line art before organ anatomy. Avoid clinical labels and organ visuals unless product scope demands them. |
| Overusing illustrations | Use illustrations for meaningful empty, onboarding, paywall, or educational moments only. |
| Body type sensitivity | Do not use ectomorph/mesomorph/endomorph visuals without approved product language and inclusive framing. |
| Paywall icon trust risk | Preserve RevenueCat behavior, legal text, package selection, restore, and purchase states. |
| Accessibility regression | Informative icons and anatomy states need localized labels; decorative assets should be hidden. |
| STRQ product role dilution | Today remains command, Coach reasoning, Train execution, Progress proof, Profile control, Paywall trust, Exercise Library discovery, Onboarding setup. |

## 11. Recommended first asset export pilot

Choose exactly one pilot: **B. Anatomy muscle subset**.

Why this first:

- Current icons are already partly imported and synced through `STRQIcon`.
- The largest generic-feel gap is anatomy: `BodyMapView` uses simple SwiftUI rounded rectangles, `MuscleFocusView` uses remote/generated body images, and `MuscleGroup.symbolName` relies on SF Symbols.
- Anatomy is a visible domain differentiator for STRQ's Exercise Library, Exercise Detail, onboarding muscle focus, and Progress muscle coverage.
- The Figma `Anatomy Muscle` node is vector-only and already structured around body area, gender, and selected state.
- A pilot can validate export quality without touching Swift, asset catalogs, or project files.

Exact pilot assets/categories:

- Source: Anatomy Muscle `8673:69673`.
- Export QA subset only, not app import:
  - `Chest`, `Back`, `Abs`, and `Glute`.
  - `Male` and `Female`.
  - `Is Selected=false` and `Is Selected=true`.
- Total pilot comparison set: 16 exported QA samples if the future prompt performs export.
- Do not export large anatomy groups `9192:5535` in the same first pilot; inspect/label them in that pass but keep export focused on Anatomy Muscle.

Expected visible payoff:

- Proves whether STRQ can replace generic body-map rectangles and SF muscle icons with licensed, fitness-specific anatomy.
- Gives Exercise Library and Exercise Detail a path toward a premium strength-coach identity.
- Creates reusable evidence for selected/unselected state styling before app import.

Risk level: Medium for export QA, high if mixed with app import. Keep the first pilot export-only, outside `Assets.xcassets`, with no Swift or project changes.

Next prompt type: Licensed Source Mode, export-only QA pilot for the anatomy muscle subset, with a docs report and no runtime import.

## 12. Immediate next prompt recommendation

Exactly one immediate next prompt:

```text
Use Licensed Source Mode.

Goal:
Run an export-only QA pilot for the licensed Figma Anatomy Muscle subset recommended in docs/strq-licensed-figma-icon-anatomy-adoption-map.md.

Figma requirement:
Use [@figma](plugin://figma@openai-curated) read-only before export. Inspect Anatomy Muscle node 8673:69673 again, then export only the pilot QA subset:
- Chest, Back, Abs, Glute
- Male and Female
- Is Selected=false and Is Selected=true

Allowed edits:
- Create a small export QA folder under docs/figma-export-qa/anatomy-muscle-subset/
- Create docs/strq-licensed-figma-anatomy-muscle-export-qa.md
- Append one concise entry to docs/migration-progress-log.md

Do not edit:
- Swift files
- Assets.xcassets
- project.pbxproj
- Localizable.xcstrings
- tests
- Widget/Watch/Live Activity
- production code

Acceptance criteria:
- Exported files are provenance/QA samples only and are not imported into the app
- The report records source node IDs, exported filenames, vector/raster status, selected/unselected differences, gender topology notes, naming recommendations, and whether the subset is safe for a later asset catalog import
- No runtime behavior changes

Verification:
- git status --short --branch
- git diff --name-only
- git diff -- docs/strq-licensed-figma-anatomy-muscle-export-qa.md docs/migration-progress-log.md docs/figma-export-qa/anatomy-muscle-subset
- git diff --name-only -- ios/STRQ ios/STRQWidget ios/STRQWatch
- git diff --check

Report back:
1. Files changed
2. Whether @Figma was used
3. Exact Anatomy Muscle variants exported
4. Export format and vector/raster result
5. Whether selected/unselected should be assets or SwiftUI state
6. Whether later asset catalog import is recommended
7. Verification results
8. Rork QA required or not

Push command after successful verification:
git status --short --branch
git add docs/strq-licensed-figma-anatomy-muscle-export-qa.md docs/migration-progress-log.md docs/figma-export-qa/anatomy-muscle-subset
git commit -m "docs: add anatomy muscle export qa pilot"
git push
```
