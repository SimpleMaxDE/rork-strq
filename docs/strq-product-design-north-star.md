# STRQ Product & Design North Star

This document is the shared product and design source of truth for future STRQ Codex prompts. It exists to make future work faster, more autonomous, more product-driven, and safer around high-risk logic.

It should be read before visual/product work on STRQ screens, especially Today/Home, Coach, Train, Progress, Profile, NotificationSettings, CoachingPreferences, Paywall, Exercise Library, Exercise Detail, Onboarding, Readiness, and Active Workout-adjacent flows.

## 1. Product ambition

STRQ should feel like a premium intelligent training coach. The app should communicate judgment, clarity, and progression, not just data capture. It should help users understand what to do, why it matters today, and how their training should progress over time.

STRQ must not feel like a generic tracker, a white-label fitness app, or an AI-generated template. It should not look like a purchased UI kit with STRQ text dropped into it. The product should feel STRQ-owned: calm, precise, dark/carbon, serious about strength training, and differentiated by coaching intelligence.

Release means a strong app the owner can stand behind, not a rough MVP that merely loads in Rork. The release bar is not "acceptable enough"; it is "I would use this and show it."

The product should make training decisions easier. Users should know what matters now, what STRQ has learned from them, what action is recommended, what risk or recovery signal affects the decision, and how today's work connects to longer-term progress.

## 2. Product positioning

STRQ is not just workout logging. Logging is part of execution, but the product should not reduce itself to sets, reps, and history tables.

STRQ is not just plan generation. A generated plan is only the starting point. The value is how the app adapts, explains, protects, and improves the plan as real training happens.

STRQ is not just dashboard metrics. Metrics matter only when they support decisions, behavior change, recovery, progression, or trust.

STRQ is a coach system that interprets readiness, training rhythm, progression, recovery, and behavior. It should connect signals across the app so the user feels guided by a coherent training intelligence rather than by isolated screens.

## 3. Screen roles

Screens must not all look the same. They should share quality, tokens, restraint, and craft, but each screen needs a distinct product role and visual character.

Today/Home = daily command / what matters now. It should summarize the user's day, surface the most relevant training decision, and make the next meaningful action easy.

Coach = decision + reasoning + adaptation. It should explain the call, show supporting signals, reflect readiness and training rhythm, and expose adaptation carefully without becoming a generic feed.

Train = execution / focus / workout flow. It should help the user start, follow, adjust, and complete training with low friction and high confidence.

Progress = proof / analysis / progress story. It should turn training history into evidence, trends, milestones, and trustworthy analysis.

Profile = identity / control / settings. It should hold user identity, preferences, account state, subscription entry, and app-level controls in a calm, structured way.

NotificationSettings = system control / reminder management. It should expose permission, schedule, reminder type, and control state clearly without feeling like a marketing surface.

CoachingPreferences = coach voice and personalization. It should let the user shape coaching tone, focus, density, and automation while making downstream coaching effects understandable.

Paywall = value, trust, conversion. It should communicate why Pro is worth paying for, preserve purchase trust, and avoid manipulative or generic subscription UI.

Exercise Library = discovery, learning, clarity. It should help users find, compare, understand, and trust exercises with strong search, filters, education, and clear exercise identity.

Onboarding = motivation, setup, trust-building. It should collect enough information to build a useful plan while making users believe STRQ understands their goal and will coach responsibly.

## 4. Design principles

Same quality, different character. STRQ screens should share a premium standard without sharing identical anatomy. The operating rule is same quality, different character.

No copy-paste screen anatomy. Do not make every screen a hero card, a stack of identical cards, and a footer row. Reuse craft, not sameness.

Color clarifies meaning, never decorates. Every accent should tell the user something about state, priority, risk, control, or value.

Premium dark/carbon foundation. STRQ should lean on dark carbon surfaces, quiet borders, controlled contrast, and precise hierarchy.

Controlled semantic accents. Accents should usually be localized to icons, rings, badges, borders, status dots, or compact state zones. Avoid flooding whole cards with color.

Strong hierarchy before decoration. The user should understand priority from layout, scale, grouping, typography, and spacing before color or effects are needed.

Fewer generic cards, more product-specific composition. Cards are allowed, but not every product idea should become the same rounded rectangle.

Every surface needs a reason. A row, chip, metric, card, badge, action, chart, or empty state should have a clear product job.

Avoid "AI generated app" patterns: repeated glassy cards, random gradients, uniform icon wells, meaningless dashboards, oversized generic heroes, fake insight clusters, and interchangeable screens.

No loud orange as default brand identity. Orange is legacy energy/accent debt unless explicitly approved for a specific product meaning.

No random gradients. Gradients need a product reason, not just visual richness.

No fake complexity. Do not add charts, signals, chips, tabs, or badges that imply intelligence without real state behind them.

No over-gamification. STRQ can motivate, but it should not turn serious training into a reward board.

No excessive sameness. Consistency should protect quality and comprehension; it should not flatten product identity.

## 5. Screen differentiation rules

Profile can be card/list based because its role is identity, settings, subscription entry, account state, and control.

Notifications can be controlled/toggle based because its role is reminder management, permission state, and schedule control.

Coach must be command/reasoning based because its role is interpretation, recommendation, adaptation, and trust.

Progress must be analytical/proof based because its role is evidence, trend, comparison, and story.

Train must be action/execution based because its role is workout focus, handoff, session flow, and completion.

Paywall must be persuasion/value based because its role is trust, offer clarity, conversion, and purchase confidence.

Exercise Library must be discovery/search based because its role is finding, filtering, learning, and exercise clarity.

If a proposed visual direction makes Coach feel like Profile, Progress feel like Notifications, or Train feel like a dashboard, challenge it before implementing.

## 6. Component reuse policy

Reuse tokens, typography, spacing, radii, surfaces, accessibility standards, and quality expectations.

Do not blindly reuse layouts. A shared primitive should support a screen's role, not erase it.

Repeated card shapes are allowed only when they serve the same product job. A settings row, a coach recommendation, a proof metric, and a paywall value proof should not all become the same card just because the primitive exists.

A shared component should not flatten screen identity. If a component makes multiple screens feel copied, refine the composition or create a role-specific wrapper.

When in doubt, prefer product role over strict visual sameness. The app should feel coherent, not cloned.

Extraction should follow repeated proven need. Do not extract a shared component just to tidy a file before the product role and states are validated.

## 7. Color policy

Green = positive / good to proceed / completed. It should signal readiness, success, completion, progression, or safe continuation when that meaning is true.

Amber = moderate / controlled / monitor. It should signal caution, calibration, uncertainty, watch state, or proceed-with-awareness.

Red/pink = caution / rest needed / pain / destructive. It should signal strong caution, rest, pain, destructive actions, or meaningful risk.

Violet/indigo = Pro/subscription only if approved. Do not use Pro colors for ordinary selected states, coach intelligence, or generic premium decoration.

Orange = legacy energy/accent debt; avoid as default. Existing orange should be treated as migration debt unless a future prompt explicitly approves a narrow warm-energy role.

Blue/teal = coach/readiness/system depending on context, must be intentional. Coach, readiness, system trust, and notification meanings can overlap visually only when the prompt names the intended meaning.

Color must match user meaning. A `Moderate` readiness state should not look like danger. A destructive reset should not look like motivation. A Pro offer should not look like a health warning.

Do not make the whole app a rainbow. Semantic diversity is useful, but the carbon foundation should keep the app calm.

Semantic accents should usually be localized, not flood whole cards. Prefer accents in rings, icons, status dots, borders, dividers, compact capsules, or small glow zones.

## 8. Prompt strategy for Codex

Future Codex prompts should explicitly name risk modes. The goal is to let Codex move faster where risk is low, and slow down where behavior is protected.

### Low-risk visual batch

Use for display-only UI.

No buttons/actions/routes/services/models should be changed.

Codex may improve multiple related components in one pass when they are display-only and share the same product role.

Codex should avoid copied patterns across screens, self-review design quality, and challenge any direction that makes STRQ feel generic or AI-generated.

Good examples: passive shell polish, read-only support signals, static proof modules, noninteractive explanatory rows, docs-only planning, and visual QA reports.

### Medium-risk scoped pass

Use for UI with actions where exact behavior must be preserved.

Limit scope to one screen slice.

Actions, sheets, routes, bindings, analytics, async behavior, disabled/loading states, and copy/localization are protected.

No model, service, persistence, scheduling, purchase, progression, or handoff changes.

Good examples: settings row visual pass with existing toggles preserved, a navigation row shell, an action-adjacent card shell, or a route doorway where destination behavior stays unchanged.

### High-risk protected plan first

Use for any area where product, data, revenue, health, legal, or training behavior can be affected.

High-risk areas include payments/RevenueCat, HealthKit, Notifications scheduling, workout handoff, active workout, plan mutation, deload/regeneration/swap, persistence/data deletion, legal/App Store, onboarding plan creation, analytics contracts, localization catalogs, Watch, Widget, and Live Activity.

High-risk work starts with a plan, behavior map, protected-file list, QA plan, owner approval where needed, and state coverage before Swift implementation.

The stronger prompt strategy is not "small forever." It is larger product slices where safe, scoped passes where behavior is adjacent, and plan-first discipline where protected logic exists.

## 9. Prompt requirements

Future prompts should include:

- Mission: what product outcome this pass should create.
- Screen role: how the target screen should feel and what job it owns.
- Design objective: the specific visual/product improvement, not just "make it premium."
- Allowed autonomy: whether Codex may make a visual batch, must stay in one slice, or must plan first.
- Protected behavior: calls, bindings, routes, analytics, copy, async state, disabled/loading state, and state sources that must not change.
- Forbidden files: Swift files, services, models, assets, localization, project files, tests, Watch, Widget, Live Activity, or other paths that are out of scope.
- Acceptance criteria: exact product, visual, behavior, and file-change expectations.
- Verification: git, diff, and targeted `rg` commands.
- Rork QA: screenshots, states, interactions, devices, missing state notes, and whether QA is required or completed.
- Push command: the exact git commands to stage, commit, and push after successful verification when the owner wants a commit.
- Self-review checklist: the questions Codex must answer before reporting back.

If a prompt does not define target files, protected behavior, forbidden files, risk mode, acceptance criteria, verification, and Rork QA expectations, it is not ready for implementation.

## 10. Self-review checklist for Codex

After visual work, Codex should answer:

- Does this look like a generic AI app?
- Does this copy another STRQ screen too closely?
- Does the screen role come through?
- Is color semantic?
- Is anything overdesigned?
- Is anything too plain?
- Is behavior untouched?
- Is the result release-quality or only acceptable?

Codex should be honest in this checklist. If the result is only acceptable, say so and recommend the next highest-leverage correction instead of pretending it is finished.

## 11. Freeze policy

Accepted areas are frozen unless screenshots reveal a real defect.

No endless micro-polish. STRQ needs momentum as much as refinement.

One correction pass maximum unless the defect is severe, behavior-breaking, visually embarrassing, or owner-approved for another pass.

High-risk behavior always needs QA. Static inspection is useful but not enough for purchase, notification, HealthKit, active workout, handoff, persistence, plan mutation, or destructive flows.

Visual batch can be frozen after owner approval. Once accepted, future prompts should treat that area as protected unless a new issue is clearly documented.

Do not reopen accepted Profile, NotificationSettings, or CoachingPreferences surfaces just because another screen is being improved. New work should learn from them without forcing every screen to become them.

## 12. Release standard

Release standard means:

- no obvious placeholder UI
- no generic template feel
- no broken hierarchy
- no accidental orange/green/violet misuse
- no known dangerous behavior bugs
- no embarrassing copy/layout issues
- key flows tested
- owner can say "I would use this and show it."

No release should be based only on "it loads." Rork visual QA, static verification, and macOS/CI build validation remain part of the release path where applicable.

For docs-only passes, release standard means the document is specific, actionable, grounded in current STRQ constraints, and useful for both owner and engineering.

## 13. Working relationship

The assistant is not a yes-man. The assistant must challenge weak ideas, generic UI direction, risky scope, accidental behavior changes, and prompts that would make STRQ less distinctive.

The owner has final sign-off. The assistant should recommend better paths when needed, explain tradeoffs plainly, and then execute efficiently once direction is clear.

Quality and speed both matter. STRQ should not crawl through one tiny card forever, but it also should not rush protected logic.

The strongest working model is honest critique plus efficient execution. Codex should be autonomous in safe zones, cautious in protected zones, and product-minded everywhere.

## 14. Immediate process change

Future CoachTab work should use larger product slices where safe. The direction should move from isolated micro-card churn toward coherent Coach product slices, while still protecting action logic.

Next likely sprint: Coach Supporting Signals batch, not one tiny card at a time, unless risk demands it. A supporting-signals batch can include display-only or low-action modules that share the same established-user reasoning role, while preserving primary CTA, workout handoff, readiness submission, More Signals action cards, progression, analytics, and model/service behavior.

Figma can be used read-only for inspiration on major visual/product surfaces. It should provide pattern awareness and quality references, not copied screens, assets, text, or runtime identity.

Before the next CoachTab implementation, the prompt should name the exact supporting-signal modules, classify their risk mode, protect every action path, and define Rork QA screenshots for density, emphasis, readiness, early/established, and small/large iPhone states.
