# STRQ Icon Coverage Plan

Last prepared: 2026-04-29

## Scope

This document prepares STRQ's core icon system for future STRQ UI modules and
tracks isolated icon import batches.

Batch 1 imported Core UI Actions + Settings as template SVG assets. No
production views, app logic, workout logic, persistence, analytics, product IDs,
localization, navigation behavior, data models, paywall, onboarding, dashboard,
active workout, workout completion, profile, content, or progress analytics
screens were modified.

Source/reference:

- `STRQDesignSystem.swift`
- `STRQDesignSystemRoadmap.md`
- `STRQDesignSystemNamingPlan.md`
- `SandowImportManifest.md`
- `Assets.xcassets/STRQIcon*.imageset`
- Purchased Sandow UI Kit, Icon Set page `5367:38988`, Icons node `5454:22014`

The purchased UI kit remains an internal source/reference. STRQ owns runtime
names, asset names, enum cases, and component APIs.

## Figma Inspection Summary

Figma node `5454:22014` was inspected in bounded chunks. The full metadata for
the icon node is very large, so the pass avoided a full document scan and
queried only the icon-list structure and targeted icon names.

Observed icon system structure:

| Area | Result |
|---|---|
| Icon Set page | `5367:38988` |
| Icons node | `5454:22014` |
| Icon rows inspected | 1,078 component sets |
| Columns | Health & Biology, General UI, Arrows & Directions, Nature, Finance, Data & Tech, Security, Transport, Misc |
| Styles per row | Light, Regular, Bold, Fill, Duotone, Duoline |
| Recommended import style | Use the `Style=Regular` symbol as the base template candidate unless a later visual QA pass chooses another base style |

## Current STRQ Icon Inventory

Current `STRQIcon` exposes 31 enum cases. Every enum raw value has a matching
`STRQIcon*.imageset` folder. Every image set has valid `Contents.json`, an
existing referenced SVG, `preserves-vector-representation: true`, and
`template-rendering-intent: "template"`.

| Enum case | Raw value / asset | SVG | JSON valid | Vector | Template |
|---|---|---|---|---|---|
| `home` | `STRQIconHome` | `STRQIconHome.svg` | Yes | Yes | Yes |
| `coach` | `STRQIconCoach` | `STRQIconCoach.svg` | Yes | Yes | Yes |
| `train` | `STRQIconTrain` | `STRQIconTrain.svg` | Yes | Yes | Yes |
| `progress` | `STRQIconProgress` | `STRQIconProgress.svg` | Yes | Yes | Yes |
| `profile` | `STRQIconProfile` | `STRQIconProfile.svg` | Yes | Yes | Yes |
| `settings` | `STRQIconSettings` | `STRQIconSettings.svg` | Yes | Yes | Yes |
| `recovery` | `STRQIconRecovery` | `STRQIconRecovery.svg` | Yes | Yes | Yes |
| `calendar` | `STRQIconCalendar` | `STRQIconCalendar.svg` | Yes | Yes | Yes |
| `sleep` | `STRQIconSleep` | `STRQIconSleep.svg` | Yes | Yes | Yes |
| `check` | `STRQIconCheck` | `STRQIconCheck.svg` | Yes | Yes | Yes |
| `search` | `STRQIconSearch` | `STRQIconSearch.svg` | Yes | Yes | Yes |
| `plus` | `STRQIconPlus` | `STRQIconPlus.svg` | Yes | Yes | Yes |
| `close` | `STRQIconClose` | `STRQIconClose.svg` | Yes | Yes | Yes |
| `chevronRight` | `STRQIconChevronRight` | `STRQIconChevronRight.svg` | Yes | Yes | Yes |
| `chevronLeft` | `STRQIconChevronLeft` | `STRQIconChevronLeft.svg` | Yes | Yes | Yes |
| `arrowRight` | `STRQIconArrowRight` | `STRQIconArrowRight.svg` | Yes | Yes | Yes |
| `arrowLeft` | `STRQIconArrowLeft` | `STRQIconArrowLeft.svg` | Yes | Yes | Yes |
| `edit` | `STRQIconEdit` | `STRQIconEdit.svg` | Yes | Yes | Yes |
| `trash` | `STRQIconTrash` | `STRQIconTrash.svg` | Yes | Yes | Yes |
| `more` | `STRQIconMore` | `STRQIconMore.svg` | Yes | Yes | Yes |
| `info` | `STRQIconInfo` | `STRQIconInfo.svg` | Yes | Yes | Yes |
| `warning` | `STRQIconWarning` | `STRQIconWarning.svg` | Yes | Yes | Yes |
| `lock` | `STRQIconLock` | `STRQIconLock.svg` | Yes | Yes | Yes |
| `checkCircle` | `STRQIconCheckCircle` | `STRQIconCheckCircle.svg` | Yes | Yes | Yes |
| `clock` | `STRQIconClock` | `STRQIconClock.svg` | Yes | Yes | Yes |
| `target` | `STRQIconTarget` | `STRQIconTarget.svg` | Yes | Yes | Yes |
| `trophy` | `STRQIconTrophy` | `STRQIconTrophy.svg` | Yes | Yes | Yes |
| `barbell` | `STRQIconBarbell` | `STRQIconBarbell.svg` | Yes | Yes | Yes |
| `weightScale` | `STRQIconWeightScale` | `STRQIconWeightScale.svg` | Yes | Yes | Yes |
| `bell` | `STRQIconBell` | `STRQIconBell.svg` | Yes | Yes | Yes |
| `star` | `STRQIconStar` | `STRQIconStar.svg` | Yes | Yes | Yes |

Current `STRQIcon*.imageset` folders:

- `STRQIconArrowLeft.imageset`
- `STRQIconArrowRight.imageset`
- `STRQIconBarbell.imageset`
- `STRQIconBell.imageset`
- `STRQIconCalendar.imageset`
- `STRQIconCheck.imageset`
- `STRQIconCheckCircle.imageset`
- `STRQIconChevronLeft.imageset`
- `STRQIconChevronRight.imageset`
- `STRQIconClock.imageset`
- `STRQIconClose.imageset`
- `STRQIconCoach.imageset`
- `STRQIconEdit.imageset`
- `STRQIconHome.imageset`
- `STRQIconInfo.imageset`
- `STRQIconLock.imageset`
- `STRQIconMore.imageset`
- `STRQIconPlus.imageset`
- `STRQIconProfile.imageset`
- `STRQIconProgress.imageset`
- `STRQIconRecovery.imageset`
- `STRQIconSearch.imageset`
- `STRQIconSettings.imageset`
- `STRQIconSleep.imageset`
- `STRQIconStar.imageset`
- `STRQIconTarget.imageset`
- `STRQIconTrain.imageset`
- `STRQIconTrash.imageset`
- `STRQIconTrophy.imageset`
- `STRQIconWarning.imageset`
- `STRQIconWeightScale.imageset`

Sandow icon status:

- No `SandowIcon*.imageset` assets remain.
- No `SandowIcon` runtime references were found.
- `SandowIcon` text remains only in docs/provenance files:
  `STRQDesignSystemNamingPlan.md` and `SandowImportManifest.md`.

## Desired STRQ Core Icons

### App Navigation

- `STRQIconHome`
- `STRQIconCoach`
- `STRQIconTrain`
- `STRQIconProgress`
- `STRQIconProfile`
- `STRQIconSettings`

### Core UI Actions

- `STRQIconPlus`
- `STRQIconClose`
- `STRQIconCheck`
- `STRQIconChevronRight`
- `STRQIconChevronLeft`
- `STRQIconArrowRight`
- `STRQIconArrowLeft`
- `STRQIconSearch`
- `STRQIconEdit`
- `STRQIconTrash`
- `STRQIconMore`
- `STRQIconInfo`
- `STRQIconWarning`
- `STRQIconLock`
- `STRQIconUnlock`

### Training / Workout

- `STRQIconBarbell`
- `STRQIconWeightPlate`
- `STRQIconClock`
- `STRQIconRest`
- `STRQIconRepeat`
- `STRQIconSwap`
- `STRQIconSkip`
- `STRQIconPlay`
- `STRQIconPause`
- `STRQIconStop`
- `STRQIconTarget`
- `STRQIconReps`
- `STRQIconSets`
- `STRQIconCalendar`
- `STRQIconChecklist`

### Progress / Analytics

- `STRQIconChartLine`
- `STRQIconChartBar`
- `STRQIconTrendUp`
- `STRQIconTrendDown`
- `STRQIconTrophy`
- `STRQIconMedal`
- `STRQIconFire`
- `STRQIconPercentage`
- `STRQIconActivityRing`

### Health / Recovery

- `STRQIconHeart`
- `STRQIconHeartbeat`
- `STRQIconMoon`
- `STRQIconRecovery`
- `STRQIconBolt`
- `STRQIconSoreness`
- `STRQIconStress`
- `STRQIconWater`
- `STRQIconNutrition`

### Exercise / Body

- `STRQIconMuscle`
- `STRQIconChest`
- `STRQIconBack`
- `STRQIconLegs`
- `STRQIconArms`
- `STRQIconShoulders`
- `STRQIconCore`
- `STRQIconFullBody`
- `STRQIconGym`

### Paywall / Commerce

- `STRQIconCrown`
- `STRQIconStar`
- `STRQIconShield`
- `STRQIconSpark`
- `STRQIconCheckCircle`
- `STRQIconCreditCard`

### Social / Profile / Settings

- `STRQIconUser`
- `STRQIconUsers`
- `STRQIconAvatar`
- `STRQIconBell`
- `STRQIconWatch`
- `STRQIconLanguage`
- `STRQIconHelp`
- `STRQIconLogout`

## Figma Matching Results

`Figma node id` below is the regular-style symbol where available. Current
imports are the existing STRQ assets in this repo, not a guarantee that the
current asset was exported from the exact same listed Figma row.

| Category | Desired STRQ icon | Figma icon found | Figma node id | Imported | Recommended asset | Priority | Notes |
|---|---|---:|---:|---|---|---|---|
| App Navigation | `STRQIconHome` | `house-1` | `8997:7938` | Yes | `STRQIconHome` | High | Current home asset covers this. Use calendar only for date-specific Today surfaces. |
| App Navigation | `STRQIconCoach` | `chat` | `8997:8278` | Yes | `STRQIconCoach` | High | Current coach asset exists; chat is a good future coach/chat base. |
| App Navigation | `STRQIconTrain` | `barbell-horizontal` | `8997:1731` | Yes | `STRQIconTrain` | High | Current train asset exists; barbell can support explicit workout affordances. |
| App Navigation | `STRQIconProgress` | `chart-bar-1` | `8997:14737` | Yes | `STRQIconProgress` | High | Current progress asset exists; add chart-specific assets separately. |
| App Navigation | `STRQIconProfile` | `user` | `8997:8726` | Yes | `STRQIconProfile` | High | Current profile asset exists. |
| App Navigation | `STRQIconSettings` | `gear-1` | `8997:7901` | Yes | `STRQIconSettings` | High | Imported in Batch 1 as regular template SVG. |
| Core UI Actions | `STRQIconPlus` | `plus` | `8997:8846` | Yes | `STRQIconPlus` | High | Already imported. |
| Core UI Actions | `STRQIconClose` | `close-x` | `8997:8831` | Yes | `STRQIconClose` | High | Imported in Batch 1 as regular template SVG. |
| Core UI Actions | `STRQIconCheck` | `check` | `8997:8875` | Yes | `STRQIconCheck` | High | Already imported. |
| Core UI Actions | `STRQIconChevronRight` | `chevron-right` | `8997:12820` | Yes | `STRQIconChevronRight` | High | Already imported. |
| Core UI Actions | `STRQIconChevronLeft` | `chevron-left` | `8997:12848` | Yes | `STRQIconChevronLeft` | High | Imported in Batch 1 as regular template SVG. |
| Core UI Actions | `STRQIconArrowRight` | `arrow-right` | `8997:13113` | Yes | `STRQIconArrowRight` | High | Already imported. |
| Core UI Actions | `STRQIconArrowLeft` | `arrow-left` | `8997:13143` | Yes | `STRQIconArrowLeft` | High | Imported in Batch 1 as regular template SVG. |
| Core UI Actions | `STRQIconSearch` | `magnifying-glass` | `8997:7711` | Yes | `STRQIconSearch` | High | Already imported. |
| Core UI Actions | `STRQIconEdit` | `pencil-1` | `8997:9428` | Yes | `STRQIconEdit` | High | Imported in Batch 1 as regular template SVG; use `note-pencil` only where document editing is implied. |
| Core UI Actions | `STRQIconTrash` | `trash-1` | `8997:8010` | Yes | `STRQIconTrash` | High | Imported in Batch 1 as regular template SVG; named Trash, not Delete, for asset clarity. |
| Core UI Actions | `STRQIconMore` | `dot-three-horizontal` | `8997:9099` | Yes | `STRQIconMore` | High | Imported in Batch 1 as regular template SVG; horizontal more icon preferred for iOS menus. |
| Core UI Actions | `STRQIconInfo` | `info` | `8997:9343` | Yes | `STRQIconInfo` | High | Imported in Batch 1 as regular template SVG; add `InfoCircle` later only if framed info is needed. |
| Core UI Actions | `STRQIconWarning` | `exclamation-mark-triangle` | `8997:7601` | Yes | `STRQIconWarning` | High | Imported in Batch 1 as regular template SVG. |
| Core UI Actions | `STRQIconLock` | `lock-1` | `8997:15495` | Yes | `STRQIconLock` | High | Imported in Batch 1 as regular template SVG. |
| Core UI Actions | `STRQIconUnlock` | `lock-unlocked-1` | `8997:15526` | No | `STRQIconUnlock` | Medium | Import with lock if unlock appears in flows. |
| Training / Workout | `STRQIconBarbell` | `barbell-horizontal` | `8997:1731` | Yes | `STRQIconBarbell` | High | Already imported. |
| Training / Workout | `STRQIconWeightPlate` | No direct plate row; nearest `weight` | `8997:2232` | No | `STRQIconWeightPlate` | Medium | Verify visually before import; current `WeightScale` is not a plate. |
| Training / Workout | `STRQIconClock` | `clock` | `8997:8203` | Yes | `STRQIconClock` | High | Already imported; consider `STRQIconStopwatch` only if distinct timer semantics matter. |
| Training / Workout | `STRQIconRest` | `sleep-zzz` | `8997:2367` | No | `STRQIconRest` | Medium | Could also use `bed` or `moon` depending on rest-copy context. |
| Training / Workout | `STRQIconRepeat` | `arrow-repeat-clockwise-1` | `8997:13583` | No | `STRQIconRepeat` | High | Useful for intervals, repeated sets, and cycles. |
| Training / Workout | `STRQIconSwap` | `arrow-left-right` | `8997:13493` | No | `STRQIconSwap` | High | Use for exercise swaps. |
| Training / Workout | `STRQIconSkip` | `arrow-skip-forward` | `8997:14124` | No | `STRQIconSkip` | Medium | Import only when workout controls migrate. |
| Training / Workout | `STRQIconPlay` | `play` | `8997:11220` | No | `STRQIconPlay` | High | Core workout/session control. |
| Training / Workout | `STRQIconPause` | `pause` | `8997:11234` | No | `STRQIconPause` | High | Core workout/session control. |
| Training / Workout | `STRQIconStop` | `stop` | `8997:11249` | No | `STRQIconStop` | High | Core workout/session control. |
| Training / Workout | `STRQIconTarget` | `target-1` | `8997:8561` | Yes | `STRQIconTarget` | High | Already imported. |
| Training / Workout | `STRQIconReps` | `hash-tag-1` | `8997:8440` | No | `STRQIconReps` | Medium | Better semantic fit than number-circle variants. |
| Training / Workout | `STRQIconSets` | `list-three-check` | `8997:10756` | No | `STRQIconSets` | Medium | Could share checklist until a stronger sets metaphor is needed. |
| Training / Workout | `STRQIconCalendar` | `calendar-1` | `8997:8083` | Yes | `STRQIconCalendar` | High | Already imported. |
| Training / Workout | `STRQIconChecklist` | `list-two-check` | `8997:10711` | No | `STRQIconChecklist` | High | Useful for plan/session completion UI. |
| Progress / Analytics | `STRQIconChartLine` | `chart-trend-up` | `8997:15175` | No | `STRQIconChartLine` | High | No plain `chart-line` row found. |
| Progress / Analytics | `STRQIconChartBar` | `chart-bar-1` | `8997:14737` | No | `STRQIconChartBar` | High | Import before analytics cards migrate. |
| Progress / Analytics | `STRQIconTrendUp` | `arrow-trend-up` | `8997:13776` | No | `STRQIconTrendUp` | High | Use arrow trend for compact deltas. |
| Progress / Analytics | `STRQIconTrendDown` | `arrow-trend-down` | `8997:13791` | No | `STRQIconTrendDown` | High | Use arrow trend for compact deltas. |
| Progress / Analytics | `STRQIconTrophy` | `trophy-1` | `8997:12250` | Yes | `STRQIconTrophy` | High | Already imported. |
| Progress / Analytics | `STRQIconMedal` | `medal` | `8997:15781` | No | `STRQIconMedal` | Medium | Reward/achievement support. |
| Progress / Analytics | `STRQIconFire` | `fire-1` | `8997:5926` | No | `STRQIconFire` | Medium | Streak support. |
| Progress / Analytics | `STRQIconPercentage` | `percentage` | `8997:7166` | No | `STRQIconPercentage` | Medium | Useful for score deltas and adherence. |
| Progress / Analytics | `STRQIconActivityRing` | `chart-donut-1` | `8997:14897` | No | `STRQIconActivityRing` | Medium | No direct activity ring row found; donut chart is the best icon-set fit. |
| Health / Recovery | `STRQIconHeart` | `heart` | `8997:1201` | No | `STRQIconHeart` | High | Clean health/recovery base icon. |
| Health / Recovery | `STRQIconHeartbeat` | `heart-ecg` | `8997:1230` | No | `STRQIconHeartbeat` | Medium | Good readiness/vitals candidate. |
| Health / Recovery | `STRQIconMoon` | `moon` | `8997:5785` | No | `STRQIconMoon` | High | Current `STRQIconSleep` exists, but moon is a cleaner general sleep icon. |
| Health / Recovery | `STRQIconRecovery` | `heart-ecg` | `8997:1230` | Yes | `STRQIconRecovery` | High | Already imported; keep as semantic recovery asset. |
| Health / Recovery | `STRQIconBolt` | `lightning-bolt-1` | `8997:7756` | No | `STRQIconBolt` | High | Energy/intensity/status utility. |
| Health / Recovery | `STRQIconSoreness` | `person-injured` | `8997:2065` | No | `STRQIconSoreness` | Medium | Better than a generic body icon for soreness. |
| Health / Recovery | `STRQIconStress` | `brain-1` | `8997:2666` | No | `STRQIconStress` | Medium | Could pair with stress copy; avoid medical overreach. |
| Health / Recovery | `STRQIconWater` | `water-drop` | `8997:1157` | No | `STRQIconWater` | Medium | Hydration candidate. |
| Health / Recovery | `STRQIconNutrition` | `fork-knife` | `8997:5880` | No | `STRQIconNutrition` | Medium | Use only if nutrition surfaces remain in scope. |
| Exercise / Body | `STRQIconMuscle` | `bicep` | `8997:5475` | No | `STRQIconMuscle` | Medium | Good general muscle icon. |
| Exercise / Body | `STRQIconChest` | No direct row found | N/A | No | `STRQIconChest` | Low | Use anatomy illustration assets rather than forcing a generic icon. |
| Exercise / Body | `STRQIconBack` | `spine` | `8997:3000` | No | `STRQIconBack` | Low | Spine is only an approximation; anatomy assets are better for body areas. |
| Exercise / Body | `STRQIconLegs` | `foot-step` | `8997:3260` | No | `STRQIconLegs` | Low | No direct leg row found. |
| Exercise / Body | `STRQIconArms` | `bicep` | `8997:5475` | No | `STRQIconArms` | Medium | Could reuse muscle/bicep if body-area icons are needed. |
| Exercise / Body | `STRQIconShoulders` | No direct row found | N/A | No | `STRQIconShoulders` | Low | Prefer anatomy illustration strategy. |
| Exercise / Body | `STRQIconCore` | `stomach` | `8997:2761` | No | `STRQIconCore` | Low | Stomach is not an abs icon; verify product fit first. |
| Exercise / Body | `STRQIconFullBody` | `person-arms-spread` | `8997:1928` | No | `STRQIconFullBody` | Medium | Better as a high-level body selector icon. |
| Exercise / Body | `STRQIconGym` | `kettlebell` | `8997:4224` | No | `STRQIconGym` | Medium | Use barbell if avoiding an additional equipment icon. |
| Paywall / Commerce | `STRQIconCrown` | `crown-1` | `9064:208861` | No | `STRQIconCrown` | Medium | Paywall/pro candidate; import only when a STRQ screen needs it. |
| Paywall / Commerce | `STRQIconStar` | `star` | Existing asset | Yes | `STRQIconStar` | Medium | Already imported. |
| Paywall / Commerce | `STRQIconShield` | `shield` | `8997:7512` | No | `STRQIconShield` | Medium | Also useful for trust/privacy/security. |
| Paywall / Commerce | `STRQIconSpark` | `sparkle-1` | `8997:9191` | No | `STRQIconSpark` | Medium | Use for AI/pro enhancement sparingly. |
| Paywall / Commerce | `STRQIconCheckCircle` | `check-circle` | `8997:8934` | Yes | `STRQIconCheckCircle` | High | Already imported. |
| Paywall / Commerce | `STRQIconCreditCard` | `credit-card` | `8997:7197` | No | `STRQIconCreditCard` | Low | Do not import unless payment UI needs it. |
| Social / Profile / Settings | `STRQIconUser` | `user` | `8997:8726` | No | `STRQIconUser` | Medium | Current `Profile` asset may be enough until explicit user rows migrate. |
| Social / Profile / Settings | `STRQIconUsers` | `users-two` | `8997:8801` | No | `STRQIconUsers` | Low | Optional until friends/social scope is real. |
| Social / Profile / Settings | `STRQIconAvatar` | `user` | `8997:8726` | No | `STRQIconAvatar` | Low | Prefer generated/text avatars unless a distinct avatar icon is needed. |
| Social / Profile / Settings | `STRQIconBell` | `bell-1` | `8997:9756` | Yes | `STRQIconBell` | Medium | Already imported. |
| Social / Profile / Settings | `STRQIconWatch` | `smart-watch` | `8997:8233` | No | `STRQIconWatch` | Medium | Device/watch settings candidate. |
| Social / Profile / Settings | `STRQIconLanguage` | `globe` | `8997:8711` | No | `STRQIconLanguage` | Low | No direct language row found; globe is acceptable. |
| Social / Profile / Settings | `STRQIconHelp` | `question-mark-circle` | `8997:7586` | No | `STRQIconHelp` | Medium | Useful for settings/support. |
| Social / Profile / Settings | `STRQIconLogout` | `arrow-sign-out-1` | `8997:14200` | No | `STRQIconLogout` | Medium | Import with settings/profile batch if logout row migrates. |

## Batch 1 Import Results

Batch 1 imported only Core UI Actions + Settings from the recorded regular-style
Figma nodes. All assets use SVG format with template rendering intent and
vector preservation enabled. No fallback icons were used.

| STRQ enum case | Asset name | Figma/source match | Figma node id | Imported format | Status | Notes |
|---|---|---|---:|---|---|---|
| `settings` | `STRQIconSettings` | `gear-1`, `Style=Regular` | `8997:7901` | SVG template vector | imported | No fallback used. |
| `close` | `STRQIconClose` | `close-x`, `Style=Regular` | `8997:8831` | SVG template vector | imported | No fallback used. |
| `chevronLeft` | `STRQIconChevronLeft` | `chevron-left`, `Style=Regular` | `8997:12848` | SVG template vector | imported | No fallback used. |
| `arrowLeft` | `STRQIconArrowLeft` | `arrow-left`, `Style=Regular` | `8997:13143` | SVG template vector | imported | No fallback used. |
| `edit` | `STRQIconEdit` | `pencil-1`, `Style=Regular` | `8997:9428` | SVG template vector | imported | No fallback used. |
| `trash` | `STRQIconTrash` | `trash-1`, `Style=Regular` | `8997:8010` | SVG template vector | imported | No fallback used. |
| `more` | `STRQIconMore` | `dot-three-horizontal`, `Style=Regular` | `8997:9099` | SVG template vector | imported | No fallback used. |
| `info` | `STRQIconInfo` | `info`, `Style=Regular` | `8997:9343` | SVG template vector | imported | No fallback used. |
| `warning` | `STRQIconWarning` | `exclamation-mark-triangle`, `Style=Regular` | `8997:7601` | SVG template vector | imported | No fallback used. |
| `lock` | `STRQIconLock` | `lock-1`, `Style=Regular` | `8997:15495` | SVG template vector | imported | No fallback used. |

## Missing Icons By Priority

High priority:

- `STRQIconRepeat`
- `STRQIconSwap`
- `STRQIconPlay`
- `STRQIconPause`
- `STRQIconStop`
- `STRQIconChecklist`
- `STRQIconChartLine`
- `STRQIconChartBar`
- `STRQIconTrendUp`
- `STRQIconTrendDown`
- `STRQIconHeart`
- `STRQIconMoon`
- `STRQIconBolt`

Medium priority:

- `STRQIconUnlock`
- `STRQIconWeightPlate`
- `STRQIconRest`
- `STRQIconSkip`
- `STRQIconReps`
- `STRQIconSets`
- `STRQIconMedal`
- `STRQIconFire`
- `STRQIconPercentage`
- `STRQIconActivityRing`
- `STRQIconHeartbeat`
- `STRQIconSoreness`
- `STRQIconStress`
- `STRQIconWater`
- `STRQIconNutrition`
- `STRQIconMuscle`
- `STRQIconArms`
- `STRQIconFullBody`
- `STRQIconGym`
- `STRQIconCrown`
- `STRQIconShield`
- `STRQIconSpark`
- `STRQIconUser`
- `STRQIconBell` already exists, but remains medium for profile/settings usage
- `STRQIconWatch`
- `STRQIconHelp`
- `STRQIconLogout`

Low priority:

- `STRQIconChest`
- `STRQIconBack`
- `STRQIconLegs`
- `STRQIconShoulders`
- `STRQIconCore`
- `STRQIconCreditCard`
- `STRQIconUsers`
- `STRQIconAvatar`
- `STRQIconLanguage`

Low-priority body-area icons should not be forced from the generic icon set.
Prefer the existing anatomy/body asset roadmap for body-region UI.

## Import Strategy

- Import one regular/base template SVG per icon.
- Prefer `Style=Regular` from the Figma component set unless visual QA chooses a
  different base style for STRQ consistency.
- Name assets `STRQIcon<Name>.imageset`.
- Add matching `STRQIcon` enum cases whose raw values equal the asset names.
- Preserve `preserves-vector-representation: true`.
- Preserve `template-rendering-intent: "template"`.
- Render with `STRQIconView` and SwiftUI tinting.
- Use SwiftUI state styling for selected, disabled, pressed, warning, success,
  destructive, and premium states.
- Do not import duplicate color, tone, hierarchy, hover, selected, disabled, or
  pressed variants.
- Do not import social, payment, brand, or commerce icons unless a STRQ screen
  actually needs them.
- Do not import huge icon sets blindly.
- Import in category batches, with validation after each batch.

Recommended batch order:

1. Core UI Actions + Settings
2. Training / Workout
3. Progress / Analytics
4. Health / Recovery
5. Exercise / Body
6. Paywall/Profile optional

Batch 1 completed:

- `STRQIconSettings`
- `STRQIconClose`
- `STRQIconChevronLeft`
- `STRQIconArrowLeft`
- `STRQIconEdit`
- `STRQIconTrash`
- `STRQIconMore`
- `STRQIconInfo`
- `STRQIconWarning`
- `STRQIconLock`

Recommended next import batch:

- `STRQIconRepeat`
- `STRQIconSwap`
- `STRQIconPlay`
- `STRQIconPause`
- `STRQIconStop`
- `STRQIconChecklist`
- `STRQIconRest`
- `STRQIconSkip`
- `STRQIconReps`
- `STRQIconSets`

This next batch would unlock reusable STRQ workout controls and plan/session
UI foundations without touching production screens.

## Naming Rules

- Runtime assets use `STRQIcon<Name>`.
- Enum cases use lower camel case and map directly to `STRQIcon<Name>` raw
  values.
- Prefer semantic STRQ names over source/vendor names:
  - `STRQIconSettings`, not `STRQIconGear1`
  - `STRQIconClose`, not `STRQIconCloseX`
  - `STRQIconTrash`, not `STRQIconDelete`
  - `STRQIconBolt`, not `STRQIconLightningBolt1`
- Use suffixes only when STRQ needs two distinct concepts:
  - `STRQIconCheck` and `STRQIconCheckCircle`
  - `STRQIconChartLine` and `STRQIconChartBar`
- Keep Sandow names in docs/provenance only.

## What Not To Import

- Full icon library.
- All six icon styles for every icon.
- Tone/color/hierarchy variants.
- Selected, disabled, pressed, hover, warning, destructive, success, or premium
  image-state duplicates.
- Social/payment/brand icons unless a concrete STRQ screen needs them.
- Medical/organ/body-part icons as generic decoration.
- Body-region icons that should instead come from anatomy/body illustrations.
- Assets that do not map to a near-term STRQ component, module, or product
  moment.

## Validation Commands

Run after any future icon import pass:

```bash
rg -n "enum STRQIcon|STRQIconView|STRQIcon[A-Za-z]+\\.imageset|SandowIcon" ios/STRQ
rg -n "Image\\(systemName:" ios/STRQ/Views ios/STRQ/ContentView.swift
rg -n "Sandow" ios/STRQ/Views ios/STRQ/ContentView.swift ios/STRQ/Utilities/*.swift
rg -n "exercise\\.singular|set\\.plural|Start Session|Per Session" ios/STRQ
```

Expected:

- Existing STRQ icon assets remain synced.
- Sandow runtime matches remain absent.
- SF Symbol usage in production views is reported only.
- No runtime screen changes.
- No raw localization keys are introduced.
