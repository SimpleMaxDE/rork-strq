# STRQ Figma Token Parity Report

Last updated: 2026-04-30

## Scope

This report records the Figma Token Parity Pass for STRQ. It compares the purchased Figma UI Kit foundation and component-state tokens against the current STRQ-owned isolated runtime design system. This pass does not redesign screens, migrate production UI, import assets, change app logic, or change workout/training behavior.

Runtime Swift must remain STRQ-owned. Figma source labels and node IDs are recorded here as provenance only.

## Figma Nodes Inspected

| Area | Node ID | Result |
|---|---:|---|
| Foundations page | `5358:6096` | Previously verified; used as parent reference |
| Colors | `5359:9002` | Inspected with variable definitions and local variable API |
| Gradients | `5442:13546` | Inspected with variable definitions and paint style inventory |
| Typography | `9119:6481` | Inspected with variable definitions and local text style inventory |
| Effects | `9120:58753` | Inspected with variable definitions and local effect style inventory |
| Grid | `9122:4683` | Inspected with variable definitions and grid style inventory |
| Size & Spacing | `9122:6944` | Inspected with variable definitions and local variable API |
| Button | `9128:103928` | Inspected with 1,400-descendant cap |
| Badge & Chip | `9126:59240` | Inspected with 1,400-descendant cap |
| Progress | `9129:207997` | Inspected with 1,400-descendant cap |
| Tab | `9131:172586` | Inspected with 900-descendant cap |
| Navigation | `11614:57585` | Inspected fully in bounded read |
| Tab Bar | `9131:291579` | Inspected with 900-descendant cap |
| List Item | `9134:89206` | Inspected with 900-descendant cap |
| Schedule | `9132:170645` | Inspected fully in bounded read |
| Card - General | `9131:326493` | Inspected with 900-descendant cap |
| Card - App Specific | `9160:324200` | Inspected with 900-descendant cap |

## Pending Or Capped Inspection

| Area | Reason | Action |
|---|---|---|
| Large component nodes | Button, Badge & Chip, Progress, Tab, Tab Bar, List Item, Card - General, and Card - App Specific were capped deliberately to avoid full-file-scale scans | Inspect a single component set variant family only when needed for implementation |
| Exact two-layer Swift shadow modeling | Figma shadows are stacked effects; current `STRQShadowToken` models one layer | Add a small stack token only if a production primitive needs exact elevation |
| Mesh gradients | Figma mesh gradients are image paints | Keep docs-only unless a future visual direction explicitly approves them |
| Component hover/focus parity | Figma includes web-like Hover/Focus states; iOS runtime should map only useful states | Map Focus to accessibility/focus rings and Hover to docs-only unless iPad pointer support is scoped |
| Work Sans runtime fidelity | Figma uses Work Sans; font binaries are absent from the checkout | Add licensed font files in a separate approved pass |

No Figma timeout occurred in this pass. One initial component summary response was too large because Button icon-swap metadata was verbose; it was replaced with smaller exact-node summaries.

## Current STRQ Foundation Audit

| STRQ area | Coverage | Notes |
|---|---|---|
| `STRQColors` | Partial | Primitive black/white/gray 50-950, brand/orange 50-950, success/warning/danger, text, surface, border, icon, selected, and warm aliases exist. Figma has broader light/dark semantic hover/disabled state tokens and more primitive color families. STRQ intentionally keeps monochrome action defaults instead of orange. |
| `STRQGradients` | Partial | Runtime has primary action, progress/status, dark card, inset card, overlay, and warm accent gradients. Figma has directional alpha gradients, brand/success/warning/destructive/accent gradients, image mesh gradients, and utility gradients. Mesh/image gradients should remain docs-only for now. |
| `STRQTypography` | Mostly complete, font pending | Display, heading, text, paragraph, label categories exist with line-height and tracking constants. STRQ role aliases exist for screen title, section title, card title, body, caption, metric, button, chip, and label. Exact Work Sans fidelity remains pending because font files are missing. |
| `STRQSpacing` | Partial | Runtime covers useful app increments from 0 through 128 plus component sizing. Figma also has large layout/artboard spacing values through 1920 and semantic spacing aliases. Large values are not currently needed at runtime. |
| `STRQRadii` | Partial | Runtime covers 0, 2, 4, 8, 12, 16, 20, 24, 32, and full, plus component roles. Figma also exposes 6, 40, 48, and 64. These can stay pending until a component needs them. |
| `STRQEffects` | Partial | Runtime covers border widths, selected border, focus width, single-layer shadows, blur radii, and glass background/stroke. Figma has focus rings for gray/black/white/brand/destructive/warning/success/purple/blue and two-layer shadows from xs to 2xl. |
| `STRQComponentStyle` | Partial | Runtime has surface variants, border variants, radii, and component tones. Figma has a larger state/tone taxonomy across component sets. |
| `STRQButton` states | Partial | Runtime covers primary, secondary, ghost, destructive, compact, icon, and disabled. Figma has hierarchy Primary/Secondary/Tertiary/Outlined/Link, sizes xs-sm-md-lg-xl, states Default/Selected/Disabled/Focus/Hover, tones Brand/Destructive/Accent/Gray. |
| `STRQChip` states | Partial | Runtime covers neutral, selected, warm/brand, success, warning, danger, disabled, compact/regular/large. Figma chips include Primary/Secondary/Tertiary/Outlined, xs-sm-md-lg-xl, Default/Selected/Hover/Disabled, Brand/Accent/Destructive/Gray. |
| `STRQBadge` states | Partial | Runtime covers small, count, status, achievement using chip tones. Dedicated Figma badge parity beyond chip-style states remains pending. |
| `STRQCard` / `STRQSurface` variants | Partial | Runtime supports standard/elevated/selected/compact/hero surfaces. Figma general cards include article, video, simple, choice, metric, category, profile, CTA, plus selected/disabled states. App cards include doctor appointment, activity, nutrition, and health metric variants. |
| `STRQProgressBar` / `STRQProgressRing` states | Partial | Runtime supports linear bars, labels, compact bars, and compact/score/activity rings. Figma includes linear progress values 0-100, top/bottom/inline/none labels, circular sweep 50/75/100, step/linear types, and size variants 2xs through 2xl. |
| `STRQListItem` / `STRQSchedule` states | Partial | Runtime supports list icon/avatar/trailing/chevron/divider and schedule rows/cards. Figma list items include Default/Fill/Fill Selected, slots none/leading/trailing/both, one/two/three text lines. Figma schedule includes Empty/Event/Event Swiped and internal time/item slots. |
| `STRQTabBar` primitives | Partial | Runtime has item, center action, container, and background primitives. Figma tab bar includes Type Default/With FAB, Configuration Docked/Floating, and indicators Default/Fill/Notch/Dot/Line. |

Extra STRQ-owned additions include monochrome action roles, neutral selected surfaces, STRQ-specific metric/card roles, debug-only previews, icon registry, and runtime Work Sans registration support. Source compatibility aliases include warm/orange token aliases retained for provenance compatibility, but they are not the default STRQ action direction. Risky/confusing tokens are the orange aliases, negative display tracking while Work Sans is missing, and current single-layer shadows that approximate but do not exactly model Figma effect stacks.

## Color Token Parity

| Figma token/category | Figma value if known | Current STRQ token | Status | Action needed |
|---|---|---|---|---|
| `color/base/white`, `color/base/black` | `#ffffff`, `#000000` | `STRQColors.white`, `STRQColors.black` | matched | None |
| `color/gray/50...950` | `#fafafa` through `#09090b` | `STRQColors.gray50...gray950` | matched | None |
| `color/brand/50...950` | orange scale, `500 = #f97316` | `STRQColors.orange50...orange950`, `warmAccent` aliases | intentionally changed | Keep as optional warm accent, not default STRQ action |
| Default backgrounds | Light: white/gray 50/100; Dark: black/gray 900/800 | `baseBackground`, `cardSurface`, `elevatedCardSurface`, `controlSurface` | matched for dark STRQ direction | Do not add light runtime theme yet |
| Default text | Light: gray 900/600/400; Dark: white/gray 300/500 | `primaryText`, `secondaryText`, `mutedText` | mostly matched | Keep current dark-first STRQ mapping |
| Default borders | Light gray 400/300/200; Dark gray 500/600/700 | `borderSecondary`, `borderTertiary`, `borderMuted`, `divider` | partial | Document stronger default border roles before production migration |
| Default icons | Light gray 800/600/400; Dark white/gray 200/500 | `iconPrimary`, `iconSecondary`, `iconMuted` | mostly matched | None |
| Brand bg/text/icon/border | Primary `#f97316`, light/dark tonal aliases | warm accent aliases and optional chip tone | intentionally changed | Keep docs-only mapping unless warm accent is approved as product accent |
| Destructive | `#f43f5e`, dark text `#fecdd3`, dark tertiary `#881337` | `danger`, `dangerSoft`, `dangerDim`, danger text aliases | matched/partial | No code change needed |
| Warning | `#f59e0b`, dark text `#fde68a` | `warning`, `warningSoft`, `warningDim`, warning text aliases | matched | None |
| Success | Light primary `#65a30d`, dark primary `#84cc16`, dark text `#d9f99d` | `success`, `successGreen`, success text aliases | matched | None |
| Accent | Figma uses blue/accent tokens in components | `blue`, `blueSoft` | partial | Treat as optional info/accent; no default action switch |

## Gradient Token Parity

| Figma token/category | Figma value if known | Current STRQ token | Status | Action needed |
|---|---|---|---|---|
| Directional white/black fade gradients | 0-100 alpha gradients | `STRQGradients.subtleOverlay` | partial | Current overlay is enough for runtime cards |
| Brand directional gradients | `#f9731600` to `#f97316` | `orangeCTA`, `orangeGlow`, `progressOrange` | partial | Keep optional warm accent only |
| Success/warning/destructive gradients | Alpha directional gradients using `#65a30d`, `#f59e0b`, `#f43f5e` | `progressSuccess`, `progressWarning`, `progressDanger` | partial | Runtime progress gradients are adequate |
| Accent gradient | Blue alpha gradient using `#2563eb` | none dedicated, `blue` primitive exists | missing | Docs-only unless an info/accent component needs it |
| Mesh gradients | Image paints `Gradient/Mesh/1...15` | none | intentionally ignored | Do not import image gradients in this foundation pass |
| Utility gradients | Rainbow diagonal, social media story | none | not relevant | Ignore unless product scope needs them |

## Typography Token Parity

| Figma token/category | Figma value if known | Current STRQ token | Status | Action needed |
|---|---|---|---|---|
| Display lg/md/sm | 180/128/96, line heights 188/136/104, tracking -8/-4/-2, Work Sans Medium/SemiBold/Bold | `displayLarge`, `displayMedium`, `displaySmall`, line-height/tracking constants | matched structurally | Work Sans files still pending |
| Heading 2xl/xl/lg/md/sm/xs | 72/60/48/36/30/24, line heights 80/68/56/44/38/32, Regular/Medium/SemiBold/Bold | heading constants and helper functions | partial | Runtime exposes bold defaults and helpers, not every named weight as a static constant |
| Text 2xl/xl/lg/md/sm/xs/2xs | 24/20/18/16/14/12/10, line heights 32/28/24/22/20/16/14, Regular/Medium/SemiBold/Bold | `text2XL...text2XS`, helpers, line-height/tracking constants | mostly matched | No code change needed |
| Paragraph 2xl/xl/lg/md/sm/xs | 24/20/18/16/14/12, line heights 38/32/28/26/22/20, Regular | `paragraph2XL...paragraphXS` | matched | None |
| Label 2xl/xl/lg/md/sm/xs | 20/18/16/14/12/10, line heights 28/24/22/20/16/14, Bold, tracking 2/2/1.5/1.5/1/1 | `label2XL...labelXS`, line-height/tracking constants | matched | None |
| STRQ roles | Source has generic typography scale | `screenTitle`, `sectionTitle`, `cardTitle`, `body`, `caption`, `metric*`, `button`, `chip`, `label` | extra STRQ-owned additions | Keep |

Exact Figma typography fidelity is not claimed while Work Sans font files are missing.

## Spacing/Grid Token Parity

| Figma token/category | Figma value if known | Current STRQ token | Status | Action needed |
|---|---|---|---|---|
| Core spacing primitives | 0, 2, 4, 6, 8, 10, 12, 14, 16, 20, 24, 32, 40, 48, 56, 64, 80, 96, 128 | `STRQSpacing.none`, `px50...px3200` | matched | None |
| Large spacing primitives | 160, 192, 224, 256, 320, 384, 480, 560, 640, 720, 768, 1024, 1280, 1440, 1600, 1920 | none | intentionally ignored | Treat as layout/artboard values, not app runtime tokens |
| Semantic spacing aliases | `2xs` 4, `xs` 8, `sm` 12, `md` 16, `lg` 20, `xl` 24, `2xl` 32, `3xl` 40, `5xl` 64 | `xxs`, `xs`, `sm`, `md`, `lg`, `xl`, `xxl`, `xxxl` | matched/partial naming | Keep STRQ names |
| General sizes | xs 24, sm 32, md 40, lg 48, xl 56, 2xl 64 | component size constants | partial | Add only as needed |
| Icon sizes | 2xs 12, xs 16, sm 20, md 24, lg 28, xl 32, 2xl 40 | `icon2XS...icon2XL` | matched | None |
| Grid styles | Desktop 12 cols gutter 32 offset 112; Tablet 6 cols gutter 32 offset 32; Mobile 4 cols gutter 16 offset 16 | `screenHorizontalMargin = 16` plus component spacing | partial | Keep mobile grid docs; do not add desktop/tablet runtime yet |

## Radius Token Parity

| Figma token/category | Figma value if known | Current STRQ token | Status | Action needed |
|---|---|---|---|---|
| Core radii | 0, 2, 4, 6, 8, 12, 16, 20, 24, 32, 40, 48, 64, full 9999 | 0, 2, 4, 8, 12, 16, 20, 24, 32, full | partial | 6/40/48/64 can remain pending until a component requires exact parity |
| Card radius | Figma cards commonly show 16/24; some wrappers use 64 | `card = 24`, `largeCard = 32` | partial/intentionally restrained | Keep restrained STRQ card policy |
| Button/chip/icon/tab radii | Buttons often 16; chips 10-14; pills full | `button = 20`, `chip = 12`, `iconContainer = 12`, `tabItem = 12` | partial | Verify visually in debug lab before production use |

## Effects/Shadow/Elevation Token Parity

| Figma token/category | Figma value if known | Current STRQ token | Status | Action needed |
|---|---|---|---|---|
| Focus rings | gray/black/white/brand/destructive/warning/success/purple/blue, all drop shadows with spread 4 | `focusRingWidth = 4`, `focusGlowColor` | partial | Add focus tone tokens only if accessibility/focus work is scoped |
| Shadows xs-sm-md-lg-xl-2xl | Two-layer shadows, e.g. xs y2/r4/spread -1 plus y1/r2 | `subtleShadow`, `cardShadow`, `softShadow` | partial | Current single-layer approximations are acceptable until exact elevation is needed |
| Background blur | 4, 8, 16, 32, 64 | `backgroundBlurXS...XL` | matched | None |
| Layer blur | 4, 8, 16, 32, 64 | none | missing/docs-only | Ignore unless a layer blur primitive is needed |
| Glass/nav effects | Some component styles use background blur 32 and shadows | `darkGlassBackground`, `darkGlassStroke`, tab/nav surfaces | partial | Keep in isolated primitives |

## Component-State Token Parity

| Figma token/category | Figma value if known | Current STRQ token | Status | Action needed |
|---|---|---|---|---|
| Button | 500 variants; hierarchy Primary/Secondary/Tertiary/Outlined/Link; sizes xl/lg/md/sm/xs; states Default/Selected/Disabled/Focus/Hover; tones Brand/Destructive/Accent/Gray | `STRQButton` variants primary/secondary/ghost/destructive/compact/icon; disabled | partial | Add selected/focus/loading only when a real primitive QA pass needs them |
| Chip | 320 variants; hierarchy Primary/Secondary/Tertiary/Outlined; sizes sm/md/lg/xl/xs; states Default/Selected/Hover/Disabled; tones Brand/Accent/Destructive/Gray | `STRQChip` tones and compact/regular/large | partial | Missing hierarchy and all five sizes |
| Badge | Source node shares chip/token structure; badge-specific details remain bounded | `STRQBadge` small/count/status/achievement | partial | Inspect badge set alone if badge production work starts |
| Progress | Progress Bar values 0-100, label Top/Bottom/Inline/None, sizes sm/md/lg/xl/2xl/xs/2xs; circular sweep 50/75/100; Linear/Step/Text/Icon/Active/Inactive | `STRQProgressBar`, `STRQProgressRing` | partial | Add semantic state wrappers before analytics migration |
| Tab | Orientation horizontal; sizes sm/xs/md/lg; styles Default/Button/Border Bottom/Border Left; flow horizontal/vertical | `STRQTabBarItem` only | partial | Need segmented tab primitive if tabs are migrated |
| Navigation | Fixed side navigation Position Left/Right, Tone Default/Inverse/Brand | `STRQNavigationBar` top bar | partial/not directly relevant | Side navigation is docs-only for iPhone app |
| Tab Bar | Type Default/With FAB; Configuration Docked/Floating; Indicator Default/Fill/Notch/Dot/Line | `STRQTabBarContainer`, item, center action | partial | Good isolated base; indicators/floating pending |
| List Item | Style Default/Fill/Fill Selected; Slot None/Leading/Trailing/Both; Text Leading/Both; lines 1/2/3 | `STRQListItem` icon/avatar/trailing/chevron/divider | partial | Good first production primitive candidate |
| Schedule | Type Empty/Event/Event Swiped; internal time/item slots and action booleans | `STRQScheduleRow`, `STRQScheduleCard` | partial | Event-swiped/action states pending |
| Card - General | Article, Video, Simple, Choice, Metric, Category, Profile, CTA; selected/disabled states in simple/choice cards | `STRQCard`, `STRQMetricCard` | partial | Split into STRQ-specific wrappers only when needed |
| Card - App Specific | Doctor Appointment, Activity, Nutrition, Health Metric; health metric variants row/col | `STRQMetricCard`, schedule/card shells | partial | Workout/exercise/paywall cards still need dedicated passes |

## Implementation Recommendations

1. Do not switch STRQ defaults back to orange. The Figma brand token is orange, but STRQ's runtime default should remain black/white/carbon/graphite with semantic states.
2. Do not add Figma node IDs or source names to Swift runtime code. Keep this report and source maps as provenance.
3. Keep Work Sans pending until licensed font binaries are present and verified in the app bundle.
4. Avoid broad token churn in `STRQDesignSystem.swift`; current primitives already cover the safe runtime foundation.
5. Use the debug Design System Lab to visualize parity gaps before production adoption.
6. In the next component primitive QA pass, focus on Button, Chip/Badge, List Item, Progress, Card, and Tab Bar states in isolation.
7. Model exact two-layer shadows or additional radii only if a concrete component needs them.

## Next Pass Recommendation

Run a Component Primitive QA Pass in the DEBUG Design System Lab:

- Verify buttons, icon buttons, chips, badges, cards, progress, list rows, schedule rows, and tab bar primitives against this report.
- Add only STRQ-owned missing primitive state APIs that prove necessary.
- Keep production screens untouched.
- Continue to defer Work Sans fidelity until font files are available.
