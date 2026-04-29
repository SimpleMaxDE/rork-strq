# STRQ Icon Coverage Plan

Last prepared: 2026-04-29

## Scope

This document prepares STRQ's core icon system for future STRQ UI modules and
tracks isolated icon import batches.

Batch 1 imported Core UI Actions + Settings as template SVG assets. Batch 2
imported Training / Workout control icons as template SVG assets. Batch 3
imported Progress / Analytics icons as template SVG assets. Batch 4 imported
Health / Recovery icons as template SVG assets. Batch 5 imported only clear
Exercise / Body small-icon matches as template SVG assets. No Anatomy Muscle
assets, full-body vector groups, Body Type assets, image/media assets,
production views, app logic, workout logic, persistence, analytics, product
IDs, localization, navigation behavior, data models, paywall, onboarding,
dashboard, active workout, workout completion, profile, content, or progress
analytics screens were modified.

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

Batch 3 bounded Figma export confirmed all eight target nodes as 24x24
`Style=Regular` components. `ActivityRing` uses the recorded closest-match
donut chart icon because no direct activity ring row was found in the icon set.
`Medal` is distinct from the existing Trophy icon and was imported from its own
regular component.

Batch 4 bounded Figma export confirmed all eight target nodes as 24x24
`Style=Regular` components. The existing `STRQIconSleep` asset was audited
before importing Moon; it is the `sleep-zzz` icon and remains useful for rest,
but it is not the cleaner moon/sleep symbol recorded for `STRQIconMoon`.

Batch 5 bounded Figma inspection searched only recorded Exercise / Body node
IDs and targeted names under the Icons node. It confirmed `bicep`,
`person-arms-spread`, and `kettlebell` as 24x24 `Style=Regular` components.
It also confirmed that body-region candidates such as `spine`, `foot-step`,
and `stomach` are approximations rather than clear chest/back/leg/core icons,
and that there is no distinct small `body`, `equipment`, `chest`, `shoulder`,
`abs`, or `core` row suitable for this isolated icon pass.

## Current STRQ Icon Inventory

Current `STRQIcon` exposes 60 enum cases. Every enum raw value has a matching
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
| `heart` | `STRQIconHeart` | `STRQIconHeart.svg` | Yes | Yes | Yes |
| `heartbeat` | `STRQIconHeartbeat` | `STRQIconHeartbeat.svg` | Yes | Yes | Yes |
| `moon` | `STRQIconMoon` | `STRQIconMoon.svg` | Yes | Yes | Yes |
| `bolt` | `STRQIconBolt` | `STRQIconBolt.svg` | Yes | Yes | Yes |
| `soreness` | `STRQIconSoreness` | `STRQIconSoreness.svg` | Yes | Yes | Yes |
| `stress` | `STRQIconStress` | `STRQIconStress.svg` | Yes | Yes | Yes |
| `water` | `STRQIconWater` | `STRQIconWater.svg` | Yes | Yes | Yes |
| `nutrition` | `STRQIconNutrition` | `STRQIconNutrition.svg` | Yes | Yes | Yes |
| `muscle` | `STRQIconMuscle` | `STRQIconMuscle.svg` | Yes | Yes | Yes |
| `fullBody` | `STRQIconFullBody` | `STRQIconFullBody.svg` | Yes | Yes | Yes |
| `gym` | `STRQIconGym` | `STRQIconGym.svg` | Yes | Yes | Yes |
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
| `repeatAction` | `STRQIconRepeat` | `STRQIconRepeat.svg` | Yes | Yes | Yes |
| `swap` | `STRQIconSwap` | `STRQIconSwap.svg` | Yes | Yes | Yes |
| `play` | `STRQIconPlay` | `STRQIconPlay.svg` | Yes | Yes | Yes |
| `pause` | `STRQIconPause` | `STRQIconPause.svg` | Yes | Yes | Yes |
| `stop` | `STRQIconStop` | `STRQIconStop.svg` | Yes | Yes | Yes |
| `checklist` | `STRQIconChecklist` | `STRQIconChecklist.svg` | Yes | Yes | Yes |
| `rest` | `STRQIconRest` | `STRQIconRest.svg` | Yes | Yes | Yes |
| `skip` | `STRQIconSkip` | `STRQIconSkip.svg` | Yes | Yes | Yes |
| `reps` | `STRQIconReps` | `STRQIconReps.svg` | Yes | Yes | Yes |
| `sets` | `STRQIconSets` | `STRQIconSets.svg` | Yes | Yes | Yes |
| `target` | `STRQIconTarget` | `STRQIconTarget.svg` | Yes | Yes | Yes |
| `chartLine` | `STRQIconChartLine` | `STRQIconChartLine.svg` | Yes | Yes | Yes |
| `chartBar` | `STRQIconChartBar` | `STRQIconChartBar.svg` | Yes | Yes | Yes |
| `trendUp` | `STRQIconTrendUp` | `STRQIconTrendUp.svg` | Yes | Yes | Yes |
| `trendDown` | `STRQIconTrendDown` | `STRQIconTrendDown.svg` | Yes | Yes | Yes |
| `trophy` | `STRQIconTrophy` | `STRQIconTrophy.svg` | Yes | Yes | Yes |
| `medal` | `STRQIconMedal` | `STRQIconMedal.svg` | Yes | Yes | Yes |
| `fire` | `STRQIconFire` | `STRQIconFire.svg` | Yes | Yes | Yes |
| `percentage` | `STRQIconPercentage` | `STRQIconPercentage.svg` | Yes | Yes | Yes |
| `activityRing` | `STRQIconActivityRing` | `STRQIconActivityRing.svg` | Yes | Yes | Yes |
| `barbell` | `STRQIconBarbell` | `STRQIconBarbell.svg` | Yes | Yes | Yes |
| `weightScale` | `STRQIconWeightScale` | `STRQIconWeightScale.svg` | Yes | Yes | Yes |
| `bell` | `STRQIconBell` | `STRQIconBell.svg` | Yes | Yes | Yes |
| `star` | `STRQIconStar` | `STRQIconStar.svg` | Yes | Yes | Yes |

Current `STRQIcon*.imageset` folders:

- `STRQIconActivityRing.imageset`
- `STRQIconArrowLeft.imageset`
- `STRQIconArrowRight.imageset`
- `STRQIconBarbell.imageset`
- `STRQIconBell.imageset`
- `STRQIconBolt.imageset`
- `STRQIconCalendar.imageset`
- `STRQIconChartBar.imageset`
- `STRQIconChartLine.imageset`
- `STRQIconCheck.imageset`
- `STRQIconCheckCircle.imageset`
- `STRQIconChecklist.imageset`
- `STRQIconChevronLeft.imageset`
- `STRQIconChevronRight.imageset`
- `STRQIconClock.imageset`
- `STRQIconClose.imageset`
- `STRQIconCoach.imageset`
- `STRQIconEdit.imageset`
- `STRQIconFire.imageset`
- `STRQIconFullBody.imageset`
- `STRQIconGym.imageset`
- `STRQIconHome.imageset`
- `STRQIconHeart.imageset`
- `STRQIconHeartbeat.imageset`
- `STRQIconInfo.imageset`
- `STRQIconLock.imageset`
- `STRQIconMedal.imageset`
- `STRQIconMore.imageset`
- `STRQIconMuscle.imageset`
- `STRQIconMoon.imageset`
- `STRQIconNutrition.imageset`
- `STRQIconPause.imageset`
- `STRQIconPercentage.imageset`
- `STRQIconPlay.imageset`
- `STRQIconPlus.imageset`
- `STRQIconProfile.imageset`
- `STRQIconProgress.imageset`
- `STRQIconRecovery.imageset`
- `STRQIconRepeat.imageset`
- `STRQIconReps.imageset`
- `STRQIconRest.imageset`
- `STRQIconSearch.imageset`
- `STRQIconSets.imageset`
- `STRQIconSettings.imageset`
- `STRQIconSkip.imageset`
- `STRQIconSleep.imageset`
- `STRQIconSoreness.imageset`
- `STRQIconStar.imageset`
- `STRQIconStop.imageset`
- `STRQIconStress.imageset`
- `STRQIconSwap.imageset`
- `STRQIconTarget.imageset`
- `STRQIconTrain.imageset`
- `STRQIconTrash.imageset`
- `STRQIconTrendDown.imageset`
- `STRQIconTrendUp.imageset`
- `STRQIconTrophy.imageset`
- `STRQIconWarning.imageset`
- `STRQIconWater.imageset`
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
- `STRQIconBody`
- `STRQIconChest`
- `STRQIconBack`
- `STRQIconLegs`
- `STRQIconArms`
- `STRQIconShoulders`
- `STRQIconCore`
- `STRQIconFullBody`
- `STRQIconGym`
- `STRQIconEquipment`

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
| Training / Workout | `STRQIconRest` | `sleep-zzz` | `8997:2367` | Yes | `STRQIconRest` | Medium | Imported in Batch 2 as the recorded closest rest match; no direct `rest` row was available. |
| Training / Workout | `STRQIconRepeat` | `arrow-repeat-clockwise-1` | `8997:13583` | Yes | `STRQIconRepeat` | High | Imported in Batch 2; useful for intervals, repeated sets, and cycles. |
| Training / Workout | `STRQIconSwap` | `arrow-left-right` | `8997:13493` | Yes | `STRQIconSwap` | High | Imported in Batch 2; use for exercise swaps. |
| Training / Workout | `STRQIconSkip` | `arrow-skip-forward` | `8997:14124` | Yes | `STRQIconSkip` | Medium | Imported in Batch 2 for workout control foundations. |
| Training / Workout | `STRQIconPlay` | `play` | `8997:11220` | Yes | `STRQIconPlay` | High | Imported in Batch 2; core workout/session control. |
| Training / Workout | `STRQIconPause` | `pause` | `8997:11234` | Yes | `STRQIconPause` | High | Imported in Batch 2; core workout/session control. |
| Training / Workout | `STRQIconStop` | `stop` | `8997:11249` | Yes | `STRQIconStop` | High | Imported in Batch 2; core workout/session control. |
| Training / Workout | `STRQIconTarget` | `target-1` | `8997:8561` | Yes | `STRQIconTarget` | High | Already imported. |
| Training / Workout | `STRQIconReps` | `hash-tag-1` | `8997:8440` | Yes | `STRQIconReps` | Medium | Imported in Batch 2 as the recorded closest repeat-count match; better semantic fit than number-circle variants. |
| Training / Workout | `STRQIconSets` | `list-three-check` | `8997:10756` | Yes | `STRQIconSets` | Medium | Imported in Batch 2 as a distinct set-list/checklist variant, not a reused Checklist asset. |
| Training / Workout | `STRQIconCalendar` | `calendar-1` | `8997:8083` | Yes | `STRQIconCalendar` | High | Already imported. |
| Training / Workout | `STRQIconChecklist` | `list-two-check` | `8997:10711` | Yes | `STRQIconChecklist` | High | Imported in Batch 2; useful for plan/session completion UI. |
| Progress / Analytics | `STRQIconChartLine` | `chart-trend-up` | `8997:15175` | Yes | `STRQIconChartLine` | High | Imported in Batch 3; no plain `chart-line` row found, so the recorded chart trend row is used. |
| Progress / Analytics | `STRQIconChartBar` | `chart-bar-1` | `8997:14737` | Yes | `STRQIconChartBar` | High | Imported in Batch 3 for analytics cards. |
| Progress / Analytics | `STRQIconTrendUp` | `arrow-trend-up` | `8997:13776` | Yes | `STRQIconTrendUp` | High | Imported in Batch 3; use arrow trend for compact deltas. |
| Progress / Analytics | `STRQIconTrendDown` | `arrow-trend-down` | `8997:13791` | Yes | `STRQIconTrendDown` | High | Imported in Batch 3; use arrow trend for compact deltas. |
| Progress / Analytics | `STRQIconTrophy` | `trophy-1` | `8997:12250` | Yes | `STRQIconTrophy` | High | Already imported. |
| Progress / Analytics | `STRQIconMedal` | `medal` | `8997:15781` | Yes | `STRQIconMedal` | Medium | Imported in Batch 3 as a distinct reward/achievement icon, not a Trophy reuse. |
| Progress / Analytics | `STRQIconFire` | `fire-1` | `8997:5926` | Yes | `STRQIconFire` | Medium | Imported in Batch 3 for streak support. |
| Progress / Analytics | `STRQIconPercentage` | `percentage` | `8997:7166` | Yes | `STRQIconPercentage` | Medium | Imported in Batch 3 for score deltas and adherence. |
| Progress / Analytics | `STRQIconActivityRing` | `chart-donut-1` | `8997:14897` | Yes | `STRQIconActivityRing` | Medium | Imported in Batch 3; no direct activity ring row found, donut chart is the documented closest icon-set fit. |
| Health / Recovery | `STRQIconHeart` | `heart` | `8997:1201` | Yes | `STRQIconHeart` | High | Imported in Batch 4 as a clean health/recovery base icon. |
| Health / Recovery | `STRQIconHeartbeat` | `heart-ecg` | `8997:1230` | Yes | `STRQIconHeartbeat` | Medium | Imported in Batch 4 for readiness/vitals. |
| Health / Recovery | `STRQIconMoon` | `moon` | `8997:5785` | Yes | `STRQIconMoon` | High | Imported in Batch 4 after auditing existing `STRQIconSleep` as `sleep-zzz`, not a moon silhouette. |
| Health / Recovery | `STRQIconRecovery` | `heart-ecg` | `8997:1230` | Yes | `STRQIconRecovery` | High | Already imported; keep as semantic recovery asset. |
| Health / Recovery | `STRQIconBolt` | `lightning-bolt-1` | `8997:7756` | Yes | `STRQIconBolt` | High | Imported in Batch 4 for energy/intensity/status utility. |
| Health / Recovery | `STRQIconSoreness` | `person-injured` | `8997:2065` | Yes | `STRQIconSoreness` | Medium | Imported in Batch 4 as the recorded soreness match; better than a generic body icon. |
| Health / Recovery | `STRQIconStress` | `brain-1` | `8997:2666` | Yes | `STRQIconStress` | Medium | Imported in Batch 4 as the recorded stress/mind match; avoid medical overreach in copy. |
| Health / Recovery | `STRQIconWater` | `water-drop` | `8997:1157` | Yes | `STRQIconWater` | Medium | Imported in Batch 4 for hydration. |
| Health / Recovery | `STRQIconNutrition` | `fork-knife` | `8997:5880` | Yes | `STRQIconNutrition` | Medium | Imported in Batch 4 for nutrition/meal surfaces. |
| Exercise / Body | `STRQIconMuscle` | `bicep` | `8997:5475` | Yes | `STRQIconMuscle` | Medium | Imported in Batch 5 as the clear reusable general muscle icon. |
| Exercise / Body | `STRQIconBody` | No distinct direct row found | N/A | No | `STRQIconBody` | Low | Do not duplicate `FullBody`; `body-fat` is not an exercise/body base icon. |
| Exercise / Body | `STRQIconChest` | No direct row found | N/A | No | `STRQIconChest` | Low | Use Anatomy Muscle assets rather than forcing a generic icon. |
| Exercise / Body | `STRQIconBack` | `spine` | `8997:3000` | No | `STRQIconBack` | Low | Spine is only an approximation; defer back-area imagery to anatomy assets. |
| Exercise / Body | `STRQIconLegs` | `foot-step` | `8997:3260` | No | `STRQIconLegs` | Low | Foot-step is not a clear reusable legs icon; defer lower-body region imagery to anatomy assets. |
| Exercise / Body | `STRQIconArms` | `bicep` | `8997:5475` | No | `STRQIconArms` | Medium | Covered by imported `STRQIconMuscle`; no duplicate bicep asset was added. |
| Exercise / Body | `STRQIconShoulders` | No direct row found | N/A | No | `STRQIconShoulders` | Low | Prefer Anatomy Muscle strategy. |
| Exercise / Body | `STRQIconCore` | `stomach` | `8997:2761` | No | `STRQIconCore` | Low | Stomach is not an abs/core icon; defer abs/core imagery to anatomy assets. |
| Exercise / Body | `STRQIconFullBody` | `person-arms-spread` | `8997:1928` | Yes | `STRQIconFullBody` | Medium | Imported in Batch 5 as a small full-body selector icon, not a full-body vector group. |
| Exercise / Body | `STRQIconGym` | `kettlebell` | `8997:4224` | Yes | `STRQIconGym` | Medium | Imported in Batch 5 as a distinct gym/equipment-context icon; existing Barbell remains for workout/training. |
| Exercise / Body | `STRQIconEquipment` | No distinct generic equipment row found | N/A | No | `STRQIconEquipment` | Low | Existing `STRQIconBarbell` and imported `STRQIconGym` cover gym equipment contexts; no duplicate generic equipment asset was added. |
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

## Batch 2 Import Results

Batch 2 imported only Training / Workout controls from the recorded
regular-style Figma nodes. All assets use SVG format with template rendering
intent and vector preservation enabled. `Rest`, `Reps`, and `Sets` use the
closest source matches already recorded in the matching plan; no SF Symbol
replacement assets were used.

| STRQ enum case | Asset name | Figma/source match | Figma node id | Imported format | Status | Notes |
|---|---|---|---:|---|---|---|
| `repeatAction` | `STRQIconRepeat` | `arrow-repeat-clockwise-1`, `Style=Regular` | `8997:13583` | SVG template vector | imported | No fallback used; enum case avoids Swift keyword `repeat`. |
| `swap` | `STRQIconSwap` | `arrow-left-right`, `Style=Regular` | `8997:13493` | SVG template vector | imported | No fallback used. |
| `play` | `STRQIconPlay` | `play`, `Style=Regular` | `8997:11220` | SVG template vector | imported | No fallback used. |
| `pause` | `STRQIconPause` | `pause`, `Style=Regular` | `8997:11234` | SVG template vector | imported | No fallback used. |
| `stop` | `STRQIconStop` | `stop`, `Style=Regular` | `8997:11249` | SVG template vector | imported | No fallback used. |
| `checklist` | `STRQIconChecklist` | `list-two-check`, `Style=Regular` | `8997:10711` | SVG template vector | imported | No fallback used. |
| `rest` | `STRQIconRest` | `sleep-zzz`, `Style=Regular` | `8997:2367` | SVG template vector | imported | Closest recorded rest match; no direct `rest` row found. |
| `skip` | `STRQIconSkip` | `arrow-skip-forward`, `Style=Regular` | `8997:14124` | SVG template vector | imported | No fallback used. |
| `reps` | `STRQIconReps` | `hash-tag-1`, `Style=Regular` | `8997:8440` | SVG template vector | imported | Closest recorded rep-count match; no direct `reps` row found. |
| `sets` | `STRQIconSets` | `list-three-check`, `Style=Regular` | `8997:10756` | SVG template vector | imported | Closest recorded set-list match; distinct from `Checklist`. |

## Batch 3 Import Results

Batch 3 imported only Progress / Analytics icons from the recorded
regular-style Figma nodes. All assets use SVG format with template rendering
intent and vector preservation enabled. `ActivityRing` uses the closest source
match already recorded in the matching plan; no SF Symbol replacement assets
were used.

| STRQ enum case | Asset name | Figma/source match | Figma node id | Imported format | Status | Notes |
|---|---|---|---:|---|---|---|
| `chartLine` | `STRQIconChartLine` | `chart-trend-up`, `Style=Regular` | `8997:15175` | SVG template vector | imported | Closest recorded chart-line match; no plain `chart-line` row found. |
| `chartBar` | `STRQIconChartBar` | `chart-bar-1`, `Style=Regular` | `8997:14737` | SVG template vector | imported | No fallback used. |
| `trendUp` | `STRQIconTrendUp` | `arrow-trend-up`, `Style=Regular` | `8997:13776` | SVG template vector | imported | No fallback used. |
| `trendDown` | `STRQIconTrendDown` | `arrow-trend-down`, `Style=Regular` | `8997:13791` | SVG template vector | imported | No fallback used. |
| `medal` | `STRQIconMedal` | `medal`, `Style=Regular` | `8997:15781` | SVG template vector | imported | Distinct regular medal icon; not a Trophy reuse. |
| `fire` | `STRQIconFire` | `fire-1`, `Style=Regular` | `8997:5926` | SVG template vector | imported | No fallback used. |
| `percentage` | `STRQIconPercentage` | `percentage`, `Style=Regular` | `8997:7166` | SVG template vector | imported | No fallback used. |
| `activityRing` | `STRQIconActivityRing` | `chart-donut-1`, `Style=Regular` | `8997:14897` | SVG template vector | imported | Closest recorded activity-ring match; no direct activity ring row found. |

## Batch 4 Import Results

Batch 4 imported only Health / Recovery icons from the recorded regular-style
Figma nodes. All assets use SVG format with template rendering intent and
vector preservation enabled. `Moon` was imported because the existing
`STRQIconSleep` raw asset is `sleep-zzz`, not the regular moon icon. No SF
Symbol replacement assets were used.

| STRQ enum case | Asset name | Figma/source match | Figma node id | Imported format | Status | Notes |
|---|---|---|---:|---|---|---|
| `heart` | `STRQIconHeart` | `heart`, `Style=Regular` | `8997:1201` | SVG template vector | imported | No fallback used. |
| `heartbeat` | `STRQIconHeartbeat` | `heart-ecg`, `Style=Regular` | `8997:1230` | SVG template vector | imported | No fallback used. |
| `moon` | `STRQIconMoon` | `moon`, `Style=Regular` | `8997:5785` | SVG template vector | imported | Imported after `STRQIconSleep` audit found a `sleep-zzz` asset rather than a moon silhouette. |
| `bolt` | `STRQIconBolt` | `lightning-bolt-1`, `Style=Regular` | `8997:7756` | SVG template vector | imported | No fallback used. |
| `soreness` | `STRQIconSoreness` | `person-injured`, `Style=Regular` | `8997:2065` | SVG template vector | imported | Recorded closest soreness match; not a generic body icon. |
| `stress` | `STRQIconStress` | `brain-1`, `Style=Regular` | `8997:2666` | SVG template vector | imported | Recorded stress/mind match; avoid medical overreach in product copy. |
| `water` | `STRQIconWater` | `water-drop`, `Style=Regular` | `8997:1157` | SVG template vector | imported | No fallback used. |
| `nutrition` | `STRQIconNutrition` | `fork-knife`, `Style=Regular` | `8997:5880` | SVG template vector | imported | Recorded nutrition/meal match. |

## Batch 5 Import Results

Batch 5 imported only Exercise / Body concepts with clear, reusable,
regular/base small-icon matches. All imported assets use SVG format with
template rendering intent and vector preservation enabled. No Anatomy Muscle
assets, full-body vector groups, Body Type assets, media assets, SF Symbol
replacement assets, or production views were touched.

Imported icons:

| STRQ enum case | Asset name | Figma/source match | Figma node id | Imported format | Status | Notes |
|---|---|---|---:|---|---|---|
| `muscle` | `STRQIconMuscle` | `bicep`, `Style=Regular` | `8997:5475` | SVG template vector | imported | Clear general muscle icon. Also covers high-level arms use where a bicep metaphor is acceptable. |
| `fullBody` | `STRQIconFullBody` | `person-arms-spread`, `Style=Regular` | `8997:1928` | SVG template vector | imported | Small full-body selector icon; distinct from future full-body vector group assets at `9192:5535`. |
| `gym` | `STRQIconGym` | `kettlebell`, `Style=Regular` | `8997:4224` | SVG template vector | imported | Distinct gym/equipment-context icon. Existing `STRQIconBarbell` still covers barbell/training affordances. |

Batch 5 target decisions:

| Concept | Decision | Existing/imported coverage | Figma match inspected | Notes |
|---|---|---|---|---|
| Muscle | imported | `muscle` / `STRQIconMuscle` | `bicep` regular `8997:5475` | Clear reusable small icon. |
| Body | missing distinct small icon | Use `fullBody` when a generic full-body selector works | No distinct direct row; `body-fat` rejected | No `STRQIconBody` case was added to avoid duplicating `FullBody` or importing a body-fat/body-type concept. |
| FullBody | imported | `fullBody` / `STRQIconFullBody` | `person-arms-spread` regular `8997:1928` | Imported as a small icon only; full-body vector groups remain deferred to the anatomy asset pass. |
| Gym | imported | `gym` / `STRQIconGym`; existing `barbell` remains useful | `kettlebell` regular `8997:4224` | Clear reusable gym icon, not a color or illustration variant. |
| Equipment | already covered | Existing `barbell` and imported `gym`; `weightScale` remains bodyweight/measurement | `weight` regular `8997:2232` inspected but not imported | No distinct generic equipment asset was added. |
| Arms | already covered / no duplicate | Imported `muscle` uses the same bicep match | `bicep` regular `8997:5475` | No duplicate `STRQIconArms` asset or enum case was added. Dedicated arm-region anatomy remains future anatomy work. |
| Legs | deferred to anatomy asset pass | None as small icon | `foot-step` regular `8997:3260` rejected | Foot-step is not a clear legs/body-region icon. See `SandowAnatomyImportPlan.md`, Anatomy Muscle `8673:69673`. |
| Chest | deferred to anatomy asset pass | None as small icon | No direct row found | Use Anatomy Muscle `8673:69673`; do not force a generic icon. |
| Back | deferred to anatomy asset pass | None as small icon | `spine` regular `8997:3000` rejected | Spine is medical/anatomical approximation, not a reusable exercise back icon. Use Anatomy Muscle `8673:69673`. |
| Shoulders | deferred to anatomy asset pass | None as small icon | No direct row found | Use Anatomy Muscle `8673:69673`. |
| Core / Abs | deferred to anatomy asset pass | None as small icon | `stomach` regular `8997:2761` rejected | Stomach is not an abs/core icon. Use Anatomy Muscle `8673:69673`. |

Future anatomy/full-body asset work remains tracked in
`SandowAnatomyImportPlan.md`, especially Anatomy Muscle node `8673:69673` and
full-body vector groups node `9192:5535`.

## Missing Icons By Priority

High priority:

- None after Batch 5.

Medium priority:

- `STRQIconUnlock`
- `STRQIconWeightPlate`
- `STRQIconCrown`
- `STRQIconShield`
- `STRQIconSpark`
- `STRQIconUser`
- `STRQIconBell` already exists, but remains medium for profile/settings usage
- `STRQIconWatch`
- `STRQIconHelp`
- `STRQIconLogout`

Low priority:

- `STRQIconBody`
- `STRQIconEquipment`
- `STRQIconArms` as a dedicated arm-region icon, only if `STRQIconMuscle` is not enough
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

Batch 2 completed:

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

Batch 3 completed:

- `STRQIconChartLine`
- `STRQIconChartBar`
- `STRQIconTrendUp`
- `STRQIconTrendDown`
- `STRQIconMedal`
- `STRQIconFire`
- `STRQIconPercentage`
- `STRQIconActivityRing`

Batch 4 completed:

- `STRQIconHeart`
- `STRQIconHeartbeat`
- `STRQIconMoon`
- `STRQIconBolt`
- `STRQIconSoreness`
- `STRQIconStress`
- `STRQIconWater`
- `STRQIconNutrition`

Batch 5 completed:

- `STRQIconMuscle`
- `STRQIconFullBody`
- `STRQIconGym`

Recommended next icon import batch:

- Paywall/Profile optional icons only if a concrete screen/component pass needs
  them, such as `STRQIconCrown`, `STRQIconShield`, `STRQIconSpark`,
  `STRQIconUser`, `STRQIconWatch`, `STRQIconHelp`, or `STRQIconLogout`.

Recommended next non-icon pass:

- Anatomy asset export QA from `SandowAnatomyImportPlan.md`, starting with a
  tiny sample from Anatomy Muscle node `8673:69673` and full-body vector groups
  node `9192:5535`, without production screen migration.

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
