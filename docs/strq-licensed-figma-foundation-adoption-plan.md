# STRQ Licensed Figma Foundation Adoption Plan

Last updated: 2026-05-05

## 1. Executive summary

The purchased Figma kit is licensed source material for STRQ. It can be used, adapted, recreated, exported, or implemented directly, including foundations, design-system primitives, anatomy, icons, assets, typography structure, spacing, radius, shadows, screen sections, component patterns, supporting visuals, and selected 1:1 implementation where it genuinely serves STRQ.

That changes the STRQ workflow. Previous planning treated the kit as pattern awareness or inspiration. Licensed Source Mode means future visual and product work can begin from inspected Figma foundations and component anatomy instead of asking Codex to invent generic dark mobile UI from scratch.

This plan is intended to unlock faster, higher-confidence implementation. It identifies which Figma foundations should become STRQ runtime primitives, which assets should be adopted directly, which components need adaptation, and which screen surfaces can safely use the licensed kit as an implementation source without flattening STRQ into raw kit output.

This should accelerate future Codex work because prompts can name exact Figma pages, node IDs, source categories, adoption modes, and guardrails before Swift implementation begins. Codex can report what was used directly, what was adapted, and what was intentionally ignored, instead of spending each pass rediscovering the same source map.

The main product benefit is avoiding generic AI-generated UI. STRQ should not look like a prompt-made dashboard, a white-label fitness app, or a purchased kit with text swapped. Licensed Source Mode gives STRQ a real design source while the STRQ Product & Design North Star keeps screen roles distinct: Today is daily command, Coach is decision and reasoning, Train is execution, Progress is proof, Profile is control, Paywall is value and trust, Exercise Library is discovery, and Onboarding is setup and confidence.

## 2. Figma usage report

[@Figma](plugin://figma@openai-curated) was used read-only before this report was written. The `figma-use` workflow was loaded first, including the Plugin API index and design-system guidance. No Figma canvas writes, asset exports, or production code changes were made.

Figma source inspected:

- File: `SH-sandow-UI-Kit--v3.0-`
- Provided file key used for tool calls: `LBvxljax0ixoTvbvvUeWVC`
- The Plugin API runtime reported a headless execution context while operating on the requested file.

Pages and tabs inspected:

| Page/category | Page or node ID | What was inspected | STRQ relevance |
|---|---:|---|---|
| File page inventory | root inventory | 11 pages, top-level page structure, variable/style counts | Confirms full kit structure |
| Main - Light Mode | `8839:195620` | 18 mobile screen groups | Secondary source for onboarding, auth, workout, profile, utility flows |
| Main - Dark Mode | `11602:73423` | 18 mobile screen groups | High source for STRQ dark mobile direction |
| Design System - General Components | `5358:4030` | 28 component sections | High reusable primitive source |
| Design System - App Components | `5643:11300` | 15 app-specific component sections | High mobile app component source |
| Design System - Foundations | `5358:6096` | 9 foundation sections | Primary token and asset foundation source |
| Design System - Icon Set | `5367:38988` | icon container, featured icon, icon library | High direct icon source |
| Bonus - Dashboard | `5643:11291` | 7 dashboard frames | Progress, reporting, dense analytics reference |
| Bonus - Mobile Patterns | `5367:35452` | 19 mobile pattern frames | Onboarding, utility, secondary flow source |

Specific foundation nodes inspected:

| Foundation | Node ID | Finding |
|---|---:|---|
| Colors | `5359:9002` | Color swatches, primitives, semantic collections, dark/light structure |
| Gradients | `5442:13546` | Fade, brand, status, accent, and utility gradient families |
| Typography | `9119:6481` | Work Sans primary type system, display/heading/text/paragraph/label scales |
| Effects | `9120:58753` | Shadows `xs` through `2xl`, background blur, layer blur |
| Grid | `9122:4683` | Desktop, tablet, and mobile grid examples |
| Size & Spacing | `9122:6944` | Radius, padding, and size variable swatches |
| Media | `9125:50816` | Avatar, flag, media, equipment image area |
| Illustration | `9125:148813` | Illustration and anatomy/achievement source families |

Specific component and asset nodes inspected:

| Source | Node ID | Finding |
|---|---:|---|
| Icon library | `5454:22014` | Large icon set with many component sets and Light/Regular/Bold/Fill/Duotone/Duoline styles |
| Icon Container | `9131:300866` | Size variants from `xs` through `4xl` |
| Icon Featured | `5546:2332` | 180 hierarchy/size/tone variants |
| Button | `9128:103928` | 500 variants across hierarchy, size, state, and tone |
| Badge & Chip | `9126:59240` | 320 chip variants across hierarchy, size, state, and tone |
| Chart | `9129:26029` | Line, pie, donut, bar, area, violin, trend label, legend, line chart layouts |
| Form Control | `9129:175150` | Action boxes, checkbox, checkbox plus text, radio, radio plus text |
| Input | `9129:190574` | 120 input field variants including default/action/currency/card/date/link states |
| Modal | `9129:50010` | Text, checklist, inputs, image, illustration, achievement, rating, chips, textarea modal types |
| Progress | `9129:207997` | 132 progress bar variants by value, size, and label position |
| Tab | `9131:172586` | 64 tab variants across orientation, size, style, and flow |
| Step | `9131:45359` | vertical/horizontal step items, active/completed/destructive/disabled states |
| Bottom Sheet | `9131:299492` | stacked and default bottom sheet patterns with iOS drag handles |
| Card - App Specific | `9160:324200` | doctor appointment, activity, nutrition, health metric cards |
| Card - General | `9131:326493` | article, video, simple, choice, metric, category, profile cards |
| List Item | `9134:89206` | 72 list item variants by style, slot, text position, and line count |
| Navigation | `11614:57585` | fixed side navigation variants, mostly not direct iPhone runtime source |
| Schedule | `9132:170645` | empty, event, and event-swiped schedule patterns |
| Section Header | `9131:291060` | 36 variants with icon, text link, button, badge, dropdown, and other right slots |
| Tab Bar | `9131:291579` | 20 docked/floating tab bars with default, fill, notch, dot indicators and FAB variants |
| Toolbar | `9131:290751` | slot, search, trailing/leading, icon, button, carousel, text, badge configurations |
| Pricing Card | `8751:102794` | 16 pricing card variants with default/selected states |
| Anatomy Muscle | `8673:69673` | 60 vector variants, male/female, selected/unselected, 15 body areas |
| Body Type | `9025:207456` | 12 variants for male/female ectomorph, mesomorph, endomorph, default/selected |
| Organ Anatomy | `9139:70026` | size wrapper variants |
| Organ Anatomy Base | `8860:134805` | 19 organ/body types including lung, brain, kidney, heart, stomach, liver, spine, knee, skin, eye |
| Large anatomy vector groups | `9192:5535` | 4 groups, 225 vectors, likely full-body anatomy artwork |
| Fitness Equipment Image | `11536:90366` | equipment image area with 20 rectangles under the media source |
| Achievement Badge | `9064:106798` | 6 size variants |
| Achievement Badge Base | `9063:203904` | 60 variants by shape and tone |
| Illustration Base | `8912:62197` | 32 base illustration variants |

STRQ-relevant screen-pattern nodes inspected or confirmed:

| Screen source | Node ID | Relevance |
|---|---:|---|
| Dark Home & Smart Fitness Metrics | `11604:62728` | Today/Home, Progress, metric cards, tab bar, daily dashboard structure |
| AI Fitness Coach | `11605:86057` | Coach surfaces, coach/chat patterns, supporting signal language |
| Personalized Workout Library | `11608:96542` | Train, Exercise Library, workout/exercise browsing |
| Activity Tracker | `11611:134946` | Progress, analytics, trend/report modules |
| Error & Utility | `11612:154006` | Empty states, loading, utility states |
| Profile Settings & Help Center | `11613:167073` | Profile/settings support patterns |
| Achievements & Leaderboard | `11613:176014` | Progress milestones, rewards, proof moments |
| Welcome and Assessment | `11579:58703`, `11603:111144`, `11579:59846`, `11603:112700` | Onboarding and assessment flows |

Most relevant parts for STRQ:

- Directly useful: icon library, anatomy muscle assets, chart/data-viz primitives, progress bars/rings, tab/tab bar patterns, pricing cards, list items, bottom sheets, modal anatomy, cards, section headers, typography, spacing, radii, shadows, empty states, onboarding/assessment patterns.
- Highly useful with adaptation: dark home metrics, AI Fitness Coach, workout library, activity tracker, app-specific cards, achievement badges, supporting illustrations.
- Useful mostly as source context: light-mode pages, fixed side navigation, desktop dashboard layouts, medical/organ visuals, community/social content, full raw screen copies.

Intentionally ignored for now:

- Sandow logo and brand identity.
- Direct full-screen cloning of light or dark mobile screens.
- Social/community surfaces unless STRQ adds that product scope.
- Medical organ visuals except as optional health/recovery education.
- Desktop side navigation, table, file upload, social media, map pin, and web hover-only states.
- Mesh/image gradients and decorative utility gradients.

Limitations and blockers:

- No assets were exported in this docs-only pass.
- No visual screenshots were captured from Figma nodes.
- The kit is large; reads were bounded to avoid timeouts and output truncation.
- Some tool responses were truncated after the useful summaries were returned.
- Exact per-variable values, every icon name, and every nested screen frame remain implementation-pass work.
- Work Sans font files are still not present in the repo, based on prior STRQ docs.

## 3. Licensed source policy for STRQ

Licensed Source Mode means STRQ may use the purchased Figma material as source, not merely as inspiration.

What can be used directly:

- Icons where the concept maps to a STRQ runtime need.
- Anatomy muscle vectors and selected/unselected state logic.
- Pricing card anatomy for Paywall plan options.
- Chart primitives, progress treatment, trend labels, legends, and report visuals.
- Component anatomy for buttons, chips, badges, list items, cards, tabs, tab bars, sheets, modals, inputs, form controls, empty states, and onboarding steps.
- Foundation values for typography scale, spacing, radius, shadow, blur, border, state, and color structure.

What can be adapted:

- Full screen sections from dark mobile screens.
- Coach/chat patterns into STRQ's Coach reasoning language.
- Workout library patterns into STRQ Train and Exercise Library surfaces.
- Activity tracker and dashboard patterns into Progress and Today.
- Achievement visuals into progress milestones only when tied to real product state.
- Supporting illustrations into onboarding, empty states, paywall, and educational surfaces.

What can be exported or recreated:

- SVG/PDF template icons.
- Anatomy vector assets or masks.
- Equipment images if export quality and product fit are approved.
- Illustration and achievement assets if they have a real STRQ use.
- Component structures recreated in SwiftUI with STRQ-owned names.
- Token values and style anatomy recreated as STRQ runtime tokens.

When 1:1 implementation is acceptable:

- A component is generic, licensed, and maps directly to a STRQ primitive, such as a chip state, icon container, progress bar, bottom sheet handle, tab indicator, modal footer, or pricing plan card state.
- The implementation does not copy Sandow brand identity, source strings, or unrelated product assumptions.
- The target screen role remains STRQ-specific.
- Protected behavior, localization, analytics, data contracts, and routing are unchanged or explicitly scoped.

How to keep STRQ coherent:

- Runtime naming must stay STRQ-owned.
- Figma source node names belong in docs and source maps, not Swift symbols, localization keys, analytics events, or user-facing copy.
- STRQ keeps its premium carbon/graphite foundation and semantic color policy.
- The Figma orange brand scale remains licensed source-compatible, not STRQ's default identity.
- Screen roles override kit sameness. A Coach card, Profile row, Progress chart, and Paywall plan card should not all become the same rounded rectangle just because the kit has a card primitive.

Difference between Licensed Source Mode and external inspiration mode:

| Mode | Allowed use | Reporting expectation |
|---|---|---|
| Licensed Source Mode | Direct use, adaptation, export, recreation, and selected 1:1 implementation from the purchased kit | Codex must name Figma sources used directly, adapted, and ignored |
| External inspiration mode | Pattern awareness only; no copying proprietary assets, layouts, or components | Codex must keep references broad and avoid source-specific reproduction |

## 4. Foundation inventory

### Foundation inventory table

| Area | What exists in Figma | STRQ relevance | Adoption mode | Priority |
|---|---|---|---|---|
| Color system | Primitives and Semantics collections; 608 color variables; light/dark semantic modes; gray, brand, rose, amber, green, accent/status families | Strong source for neutral surfaces, text, borders, status, selected states, and dark mode | Adapt | High |
| Typography | Work Sans primary typeface; display, heading, text, paragraph, label scales; 73 text styles | Direct structure for type hierarchy; runtime font files still pending | Adapt, then direct when font files exist | High |
| Spacing | spacing/padding variables and mobile grid examples | Direct source for margins, card padding, row gaps, toolbar heights | Adopt directly where values match iOS needs | High |
| Radii | radius scale from none through full; component radius examples | Useful for consistent cards, sheets, chips, buttons, tabs, icon containers | Adapt | High |
| Borders/strokes | color/border tokens, selected and disabled border states, component strokes | Needed for premium dark cards and selected states | Adopt/adapt | High |
| Elevation/shadows | shadows `xs` through `2xl`, focus rings, background blur, layer blur | Better depth language for cards, sheets, modals, premium panels | Adapt | Medium |
| Iconography | large icon library, featured icons, icon containers, multiple icon styles | Strongest direct-use opportunity; can replace SF Symbol gaps | Adopt directly with STRQ mapping | High |
| Illustration/supporting visuals | 32 illustration base variants, achievement badges, media/utility illustrations | Useful for empty states, onboarding, paywall, reward moments | Adapt selectively | Medium |
| Anatomy assets | 60 Anatomy Muscle variants; full-body vector groups; body type; organ anatomy | Major STRQ differentiator for Exercise Library, onboarding, muscle focus, progress | Adopt directly after asset QA | High |
| Charts/data viz | line, pie, donut, bar, area, violin, trend labels, legends, line chart layouts | Progress, Weekly Review, Today, Coach proof modules | Adapt directly into STRQ chart language | High |
| Navigation/tab systems | Tab, Tab Bar, App Bar, Toolbar, fixed navigation | Useful for app tabs, segmented controls, library filters, report tabs | Adapt | High |
| List/row patterns | 72 List Item variants by slot, style, text lines | Profile, settings, notification, exercise rows, coach signal rows | Adopt/adapt | High |
| Cards/panels | general cards and app-specific health/activity/nutrition/metric cards | Today, Coach, Progress, Train, Paywall, Profile panels | Adapt selectively | High |
| Form/toggle/input patterns | form controls, inputs, action boxes, toolbar search | Onboarding, Exercise Library search/filter, settings, preferences | Adopt/adapt | High |
| Badges/chips/tags | 320 chip variants, badges inside cards/pricing | Filters, status, Pro, readiness, muscle tags, equipment tags | Adopt/adapt | High |
| Buttons/CTAs | 500 variants across hierarchy, size, state, tone | Needed for calmer CTAs and consistent action hierarchy | Adapt; avoid raw orange default | High |
| Empty states | Error & Utility pages, Modal illustration types, utility components | Exercise Library no results, Progress no data, onboarding gaps | Adapt | Medium |
| Modal/sheet patterns | Bottom Sheet, Modal, Side Sheet | Weekly Review, More Signals, onboarding, paywall, confirmations | Adopt/adapt with behavior preservation | High |
| Onboarding/paywall patterns | Welcome, assessment, profile setup, Pricing Card | Onboarding and Paywall can use licensed structure | Adapt; pricing card can be direct | High |

## 5. STRQ adoption opportunities

| Opportunity | What it improves | Screens that benefit | Safe now or wait |
|---|---|---|---|
| Licensed icon replacement path | Replaces generic SF Symbol feel with a cohesive icon language | Today, Coach, Train, Progress, Profile, Notifications, Paywall, Exercise Library | Safe as docs-only mapping now; asset/code later |
| Anatomy muscle asset adoption | Makes exercise/muscle education feel ownable and fitness-specific | Exercise Library, Exercise Detail, Onboarding, Train, Progress | Docs-only mapping safe now; export/import should wait |
| Chart/report visual language | Makes progress and weekly reports feel credible, not fake dashboards | Progress, Weekly Review, Today, Coach proof modules | Safe as docs-only plan now; Swift after data contracts |
| Tab/navigation treatment | Improves app shell, segmented controls, filters, and report tabs | ContentView tabs, Train filters, Progress tabs, Exercise Library | Should wait for protected navigation plan |
| Panel/card structures | Gives consistent surfaces without generic card stacks | Today, Coach, Train, Progress, Paywall | Safe when each screen keeps distinct role |
| Typography hierarchy | Builds more professional hierarchy and reduces random local font choices | All screens | Safe as docs; Swift waits for font/token scope |
| Component primitives | Speeds future implementation with known button/chip/list/input/sheet anatomy | All screens | Safe in isolated primitives; screen adoption scoped |
| Coach-specific visual motifs | Uses AI Fitness Coach and chat/insight source as licensed source for reasoning surfaces | Coach, Weekly Review, More Signals | Safe as adapted screen-specific work |
| Paywall pricing cards | Gives Pro plan options a real licensed structure | Paywall, Profile subscription entry | Docs-only first because RevenueCat is protected |
| Empty-state illustrations | Avoids generic blank screens and placeholder copy | Exercise Library, Progress, onboarding, errors | Safe once asset choices are approved |

Direct adoption should start with icons, anatomy, pricing-card anatomy, chart primitives, progress indicators, list rows, and bottom-sheet/modal structure. Full screen adoption should wait until protected behavior and screen role are mapped.

## 6. Screen mapping

| STRQ screen | Useful Figma foundations/components | Could be directly adopted | Should remain distinct | Do not copy blindly | Missing assets/visuals Figma can supply |
|---|---|---|---|---|---|
| Today/Home | Dark Home metrics `11604:62728`, Metric Card, Health Metric Card, Chart, Progress, Tab Bar, icon containers | Metric card anatomy, trend labels, compact progress, daily status icons | Daily command and next-action hierarchy | Full Sandow dashboard layout, sample health copy, generic wellness metrics | Cohesive icons, daily metric panels, chart snippets |
| Coach | AI Fitness Coach `11605:86057`, Chat, Card, List Item, Step, Progress, Icon Featured | Coach signal cards, icon treatments, bottom sheet/modal anatomy | Decision plus reasoning, not chat-only UI | Raw chat screen, equal-weight feed cards, orange brand CTAs | Coach-specific icons, reasoning panels, signal chips |
| Train | Personalized Workout Library `11608:96542`, Schedule, Card App Specific, List Item, Button, Progress | Schedule row/card anatomy, workout card shells, exercise rows | Execution focus and workout handoff clarity | Appointment-style scheduling or generic workout marketplace | Workout/exercise icons, equipment imagery, session progress |
| Progress | Activity Tracker `11611:134946`, Bonus Dashboard, Chart, Progress, Achievement Badge | Chart primitives, trend labels, progress rings/bars, achievement badge shells | Proof and analysis story | Desktop admin dashboards, fake complex charts, leaderboard overuse | Report charts, milestone badges, empty proof states |
| Profile | Profile Settings & Help Center `11613:167073`, List Item, Section Header, Badge/Chip, Button | List row anatomy, section headers, compact badges | Identity and control surface | Profile card/feed look, social/community sections | Account/status icons, calm row treatments |
| NotificationSettings | Form Control, List Item, Section Header, Toggle/Input, Icon Featured | Toggle/control anatomy, section labels, status badges | Reminder management and permission clarity | Marketing notification screens or noisy status cards | Permission/state icons, compact control rows |
| CoachingPreferences | Form Control, List Item, Badge/Chip, Step, Modal | Selected row state, chips, disabled/locked row treatment | Coach voice and personalization | A generic settings checklist or onboarding questionnaire | Preference icons, selected-state structure |
| Weekly Review | Chart, Progress, Step, Modal, Bottom Sheet, AI Fitness Coach, Activity Tracker | Report page sections, chart/trend visuals, sheet structure | Weekly coach report and action confirmation | A raw analytics dashboard or generic carousel report | Review charts, proof visuals, summary icons |
| Paywall | Pricing Card `8751:102794`, Button, Badge/Chip, Modal, Illustration | Pricing card anatomy, selected/default plan states, feature checklist structure | Value, trust, purchase safety, STRQ Pro positioning | Raw pricing copy, manipulative urgency, RevenueCat logic changes | Pricing cards, feature icons, premium panel visuals |
| Exercise Library | Personalized Workout Library, Anatomy Muscle `8673:69673`, Equipment Image `11536:90366`, Input, Toolbar, Chips, List Item | Search/input anatomy, filter chips, anatomy assets, equipment images | Discovery and learning | Generic content library, social fitness feed, medical organ visuals | Muscle maps, equipment thumbnails, exercise category icons |
| Onboarding | Welcome, Comprehensive Fitness Assessment, Body Type `9025:207456`, Step, Form Control, Progress, Illustration | Stepper/progress anatomy, selected-choice cards, body type visuals if approved | Motivation, setup, trust-building | Full copied onboarding flow, source brand voice, unnecessary medical detail | Assessment visuals, body type assets, step illustrations |

Screen mapping rule: STRQ can share foundations, but each product surface needs a different composition. Do not reduce Today, Coach, Train, Progress, Paywall, Exercise Library, and Onboarding into the same hero-card plus card-stack formula.

## 7. Priority adoption roadmap

### Phase 1: highest leverage foundation adoption

Scope:

- Create an exact licensed-source mapping for icons, anatomy, chart/report primitives, typography roles, spacing, radii, shadow/elevation, and selected-state patterns.
- Keep it docs-only or isolated preview-only unless a later prompt approves code.

Why it matters:

- It converts the kit from source material into implementation-ready STRQ decisions.
- It creates stable references for future Codex prompts.

Risk level: Low for docs; medium if assets are exported.

Likely payoff: Very high. This reduces generic UI quickly and avoids repeated Figma rediscovery.

### Phase 2: component/system adoption

Scope:

- Adapt list rows, chips/badges, buttons, icon containers, progress, cards, inputs/search, bottom sheets, modals, tabs, and chart building blocks into STRQ-owned primitives.
- Keep protected routing, persistence, analytics, purchase, notification, and workout behavior untouched.

Why it matters:

- Screens can move faster once primitives are stable.
- Codex can implement screen-specific composition instead of re-solving component anatomy.

Risk level: Medium.

Likely payoff: High, especially for Profile, NotificationSettings, CoachingPreferences, Exercise Library, Progress, and Paywall.

### Phase 3: screen-level adoption

Scope:

- Apply licensed source mode to screen-specific product surfaces: Paywall pricing, Exercise Library discovery, Progress report modules, Today command panels, Coach reasoning panels, Train schedule/workout cards, and Onboarding assessment.

Why it matters:

- This is where the licensed kit becomes visible product value.
- It gives each major surface more craft without copying screens blindly.

Risk level: Medium to high, depending on screen behavior.

Likely payoff: High. This is the point where STRQ stops feeling like a locally patched app and starts feeling designed.

### Phase 4: deeper asset/anatomy/report integration

Scope:

- Export/import selected icons, muscle anatomy, equipment images, illustrations, achievement badges, and report visuals.
- Build STRQAnatomy, STRQChart/report wrappers, and milestone visuals only after asset QA.

Why it matters:

- Anatomy and report visuals are the most differentiated licensed-source gains.
- They can make Exercise Library, Progress, Onboarding, and Coach feel domain-specific.

Risk level: Medium/high because assets, project files, accessibility, and visual QA are involved.

Likely payoff: Very high if scoped tightly.

## 8. Fastest wins

1. Icon replacement path: map the Figma icon library to current `STRQIcon` needs and the remaining SF Symbol gaps.
2. Anatomy asset adoption: map the 60 Anatomy Muscle variants to STRQ muscle groups and exercise filters.
3. Stronger chart/report language: use Chart, Progress, Trend Label, and Activity Tracker source for Progress and Weekly Review.
4. Better empty states: adapt utility, modal illustration, and base illustration assets for no-results and no-data states.
5. Better tab treatment: use Tab and Tab Bar source for segmented filters and eventual app shell planning.
6. Reusable premium panel structures: adapt Card General, Card App Specific, and Metric Card anatomy into role-specific STRQ wrappers.
7. Paywall visual uplift: use Pricing Card default/selected plan states while preserving RevenueCat behavior.
8. Coach-specific supporting visuals: adapt AI Fitness Coach, Chat, Step, and Icon Featured patterns into reasoning panels.
9. Exercise Library search/filter polish: use Input, Toolbar search, Chips, List Item, Anatomy Muscle, and Equipment Image source.
10. Onboarding assessment polish: use Step, Body Type, Form Control, Progress, and illustration source for a more confident setup flow.

## 9. Risks and guardrails

Risk: raw untouched UI-kit output.

Guardrail: Licensed Source Mode permits direct use, but STRQ must still own runtime naming, screen roles, copy, and product meaning. Direct adoption is strongest at the primitive/asset level, not full-screen clone level.

Risk: overusing the same shapes/components everywhere.

Guardrail: Reuse foundations, not identical layouts. Coach, Profile, Progress, Train, Paywall, and Exercise Library need different composition rules.

Risk: mixing old STRQ patterns with new Figma patterns poorly.

Guardrail: Each implementation prompt must name the legacy patterns being preserved, replaced, or intentionally left alone. Avoid partial hybrids where old orange Forge CTAs, new carbon cards, and raw Figma brand tokens compete.

Risk: asset/font confusion.

Guardrail: Keep Work Sans pending until font files are present. Export assets only after a docs-only asset map names exact nodes, sizes, formats, accessibility needs, and target runtime names.

Risk: screen roles collapsing.

Guardrail: Today remains daily command, Coach remains decision/reasoning, Train remains execution, Progress remains proof, Profile remains control, NotificationSettings remains reminder management, CoachingPreferences remains personalization, Paywall remains trust/conversion, Exercise Library remains discovery, and Onboarding remains setup/trust.

Risk: protected behaviors changing.

Guardrail: RevenueCat, notifications, workout handoff, active workout, readiness submission, weekly review actions, plan mutation, persistence, analytics, HealthKit, localization, Watch, Widget, and Live Activity remain protected unless explicitly scoped.

Risk: importing everything blindly.

Guardrail: Every licensed-source pass must say what was used directly, what was adapted, what was ignored, and why. Do not import entire icon families, illustration sets, screen layouts, or component variants just because the license allows it.

## 10. Prompt rules update

Future Codex rules for Licensed Source Mode:

- Use [@Figma](plugin://figma@openai-curated) read-only for major visual/product surfaces before implementation.
- Figma is optional for tiny bugfixes, text wrapping fixes, narrow behavior fixes, and docs-only updates unrelated to visual/product direction.
- Prompts should explicitly state `Licensed Source Mode`.
- Codex must report what was used directly from Figma.
- Codex must report what was adapted from Figma.
- Codex must report what licensed assets/components are relevant even if not used in that pass.
- Codex must report what was intentionally not used.
- Codex must include Figma page/category/node IDs when available.
- Codex must keep STRQ screen roles distinct.
- Codex must not reduce every screen to the same card stack.
- Codex must not copy Sandow logo, source brand voice, sample content, or irrelevant medical/social/product assumptions into STRQ runtime.
- Codex must preserve protected behavior unless the prompt explicitly scopes behavior work.
- Codex must keep runtime symbols, assets, localization keys, analytics events, and product identifiers STRQ-owned.

Recommended prompt language:

```text
Use Licensed Source Mode. Inspect the purchased Figma kit read-only before implementation. Report which Figma pages, node IDs, assets, components, and foundations were used directly, adapted, or intentionally ignored. Preserve STRQ screen roles and protected behavior. Do not make every screen the same card stack.
```

## 11. Recommended next 3 implementation sprints

| Priority | Sprint target | Why now | Risk level | Docs-only or Swift | Licensed Source Mode required |
|---:|---|---|---|---|---|
| 1 | Licensed Figma icon and anatomy adoption map | Icons and anatomy are the clearest direct-use differentiators and should be mapped before asset export or Swift changes | Low | Docs-only | Yes |
| 2 | Licensed chart/report visual language plan for Progress and Weekly Review | Progress and Weekly Review need stronger proof/report visuals, and Figma has real chart/progress primitives | Low/Medium | Docs-only first, Swift later | Yes |
| 3 | Paywall pricing card and premium panel risk plan | Pricing Card can materially improve conversion trust, but RevenueCat and purchase behavior are protected | Medium | Docs-only first | Yes |

## 12. Exactly one immediate next prompt recommendation

### Immediate next prompt

Target: create a docs-only licensed Figma icon and anatomy adoption map.

Reason: this is the best next move because icons and anatomy are the highest-value direct adoption opportunities from the licensed kit, and they should be mapped before any asset export, project-file change, or Swift implementation. This will make future Exercise Library, Train, Coach, Progress, Onboarding, and Profile work faster and more STRQ-specific.

Scope:

- Inspect the Figma Icon Set, Icon Container, Icon Featured, Anatomy Muscle, large anatomy vector groups, Body Type, Equipment Image, Achievement Badge, and Illustration Base nodes read-only.
- Map which assets should be adopted directly, adapted, or ignored.
- Map exact target STRQ runtime names and likely screens.
- Do not export assets.
- Do not edit Swift, assets, project files, localization, tests, Watch, Widget, or Live Activity.

Risk level: Low for docs-only; medium for the later asset import pass this would unlock.

Mode: docs-only.

Licensed Source Mode: required.

Recommended prompt:

```text
Use Licensed Source Mode. Create a docs-only STRQ licensed Figma icon and anatomy adoption map. Inspect the purchased Figma kit read-only, especially Icon Set, Icon Container, Icon Featured, Anatomy Muscle, large anatomy vector groups, Body Type, Equipment Image, Achievement Badge, and Illustration Base. Map exact Figma node IDs to STRQ-owned target names, likely screens, direct/adapt/ignore decisions, asset format recommendations, accessibility notes, and implementation priority. Do not export assets or edit Swift, assets, project files, localization, tests, Watch, Widget, or Live Activity. Create only docs/strq-licensed-figma-icon-anatomy-adoption-map.md and append one concise entry to docs/migration-progress-log.md.
```
