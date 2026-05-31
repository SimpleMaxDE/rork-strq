# STRQ Master Transfer Pack v2

Date: 2026-05-27

Post-Profile checkpoint update: 2026-05-28

Post-Recovery Trust checkpoint update: 2026-05-30

Post-English-first P0-A checkpoint update: 2026-05-30

Post-Weekly Review English-first checkpoint update: 2026-05-31

Purpose: strict canonical transfer pack for a new ChatGPT/Codex session.

Source status: CURRENT. Built from `AGENTS.md`, `docs/qa/strq-codex-operating-rules-2026-05-24.md`, the Profile and Progress planning docs listed in the task, current Profile/Progress/debug file inventory, the completed Profile, Recovery Trust, English-first P0-A, and Weekly Review English-first checkpoints, `git log --oneline -n 80`, and `git status --short`.

Status labels used in this pack:
- APPROVED = accepted direction, rule, committed artifact, or explicit current instruction.
- REJECTED = direction or artifact must not be continued as product direction.
- BLOCKED = must not proceed until an explicit review/approval gate clears.
- CURRENT = true in this checkout/session at transfer time.
- UNCERTAIN = repo evidence is missing, conflicting, or not enough to assert approval.

## 1. Executive State

- CURRENT: Repo root is `/Users/simplemax/Documents/Codex/2026-05-12/gebe-mir-den-derzeitigen-stand-ber/rork-strq`.
- CURRENT: Active branch is `main`.
- CURRENT: Current correction mode is Documentation correction only.
- CURRENT: Allowed output file for this task is `docs/qa/strq-master-transfer-pack-v2-2026-05-27.md`.
- CURRENT: Forbidden for this task: app source code, Swift files, staging, committing, pushing.
- CURRENT: `git status --short` shows no tracked dirty app files and no staged files.
- CURRENT: `git status --short` shows multiple untracked QA/artifact folders plus untracked `docs/qa/profile-v3-concept-brief-2026-05-25.md` and `ios/STRQ/Views/Debug/ProfileV3PrototypeView.swift`.
- CURRENT: Before this Weekly Review English-first documentation update, `git diff --name-only` was empty; there was no tracked dirty implementation file in this checkout.
- CURRENT: Latest commit in `git log --oneline -n 20` is `71f4ebf Make weekly review English-first`.
- CURRENT: Profile checkpoint is complete and pushed to `main` through `bbbc2a9`.
- CURRENT: Recovery Trust checkpoint is complete and pushed to `main` through Progress P1-B at `55c2ca8`.
- CURRENT: English-first P0-A checkpoint is complete and pushed to `main` through `bb85725`.
- CURRENT: Core daily/coaching production copy cleanup is committed and pushed.
- CURRENT: Weekly Review English-first cleanup is complete and pushed to `main` through `71f4ebf`.
- CURRENT: Weekly Review visible copy is now English-first.
- CURRENT: Weekly Review generator copy is English-first and avoids fake precision.
- APPROVED: Profile production direction is approved enough for the current checkpoint.
- CURRENT: Completed Profile checkpoint slices are `9d85cdb Recovery Trust Display`, `a560c1d Coach & Inputs Restructure`, `bbe5ef0 Account & Data Rehousing`, `4e940f8 Tools / Privacy / Advanced Data`, and `bbbc2a9 Auto split Copy`.
- CURRENT: Completed Recovery Trust slices are `0bf0454 Reduce recovery score precision in key surfaces`, `1d74450 Reduce recovery precision in coaching flows`, `cbb073b Reduce recovery precision in progress`, and `55c2ca8 Soften progress balance precision`.
- CURRENT: Today, Sleep & Recovery, Readiness Check-In, Coach, PreWorkout, and Progress have been cleaned up for major recovery/readiness fake precision.
- CURRENT: English-first P0-A cleaned Today, Coach, Daily Briefing, Readiness result, Phase Outlook, and Active Workout Rest fallbacks toward English-first.
- CURRENT: Weekly Review German labels such as `Wochenrückblick`, `Gesamtvolumen`, `Sätze gesamt`, `Erholung`, `Volumenvergleich`, `Signale`, `Coach-Einschätzung`, and `Nächste Schritte` were replaced with English-first copy.
- CURRENT: Weekly Review training balance now avoids score-first or muscle-balance percentage verdicts.
- BLOCKED: Residual English-first / localization strategy audit remains a carry-forward issue.
- BLOCKED: Do not treat global localization as solved.
- BLOCKED: German localization remains a later explicit localization strategy/slice.
- BLOCKED: Global `Localizable.xcstrings` / `L10n` strategy remains a future separate slice.
- BLOCKED: No visible recovery/readiness percent or score-first hero may be reintroduced without explicit approval.
- BLOCKED: Do not continue Profile polish blindly.
- BLOCKED: Future Profile work must start from a fresh plan/slice with reconfirmed allowed and forbidden files.
- BLOCKED: Stage/commit/push remains blocked until the user explicitly grants that permission.

## 2. STRQ Product Identity

- APPROVED: STRQ is an iOS fitness and strength app.
- APPROVED: STRQ targets App-of-the-Year-level quality by 2027.
- APPROVED: STRQ should feel premium, calm, gym-native, focused, data-based, and emotionally strong.
- APPROVED: The engine may be science-based.
- APPROVED: The UI must not sound scientific.
- APPROVED: Main product UI is English-first.
- APPROVED: German localization comes later in explicit localization slices.

## 3. Role Model

- APPROVED: User and ChatGPT are the final product, design, and language judges.
- APPROVED: Codex implements, audits, reads the repo, runs builds/tests, launches the app for screenshot review, captures screenshots only when explicitly requested, and proposes plans.
- APPROVED: Codex is not the final design judge.
- APPROVED: Current screenshot review workflow is user-captured screenshots by default.
- APPROVED: After every UI or implementation change, launch the updated app on iPhone 17 Pro Max before asking the user for screenshots.
- APPROVED: Agent, Mobbin, and Browser are reference-research tools; they do not approve STRQ direction.
- APPROVED: Figma is used when visual concept, design-system, mockup, asset, or handoff work cannot be solved confidently in SwiftUI alone.
- APPROVED: Figma output is not automatic design approval.
- APPROVED: Build success means the app compiles; it does not mean the product experience is approved.

## 4. Operating Rules

- APPROVED: Every task must be classified first: Plan only, Implementation, QA only, Debug/prototype, Production integration, or Goal Mode task.
- APPROVED: Before work, confirm repo root, branch, `git status --short`, allowed files, forbidden files, and no stage/commit/push permission unless explicitly granted.
- APPROVED: For UI work, confirm the screenshot plan before coding.
- APPROVED: Default flow is understand scope, identify allowed files, identify forbidden files, plan, implement only if requested, build/test, launch updated app on iPhone 17 Pro Max when UI changed, ask user for manual screenshots, stop for review.
- APPROVED: Do not stage, commit, or push without explicit approval.
- APPROVED: After explicit approval, commit and push together unless the user explicitly says otherwise.
- APPROVED: Before review, run `git diff --name-only` and `git diff --check`.
- APPROVED: Report unrelated untracked QA folders separately.
- APPROVED: Do not silently broaden scope.
- APPROVED: Do not rewrite models, persistence, or analytics unless explicitly allowed.
- APPROVED: Do not call any surface App-of-the-Year-ready without user/ChatGPT review.
- APPROVED: Report uncertainty instead of inventing certainty.
- APPROVED: Session State Refresh Rule: at the start of any new session, verify `git status --short`, `git log --oneline -n 10`, and `git diff --name-only`.
- APPROVED: Current repo state overrides this Transfer Pack only for dirty/committed file state.
- APPROVED: Product and design decisions in this pack remain valid unless explicitly changed by user/ChatGPT review or a newer approved document.
- BLOCKED: If this Transfer Pack conflicts with repo state for committed/dirty status, stop and ask before editing.

## 5. Tooling / Plugins / Defaults

- CURRENT: Project path is `/Users/simplemax/Documents/Codex/2026-05-12/gebe-mir-den-derzeitigen-stand-ber/rork-strq`.
- CURRENT: iOS project is `ios/STRQ.xcodeproj`.
- CURRENT: Scheme is `STRQ`.
- CURRENT: Default configuration is `Debug`.
- CURRENT: Preferred simulator is `iPhone 17 Pro Max`, iOS 26.5 when available.
- CURRENT: Default screenshot device is iPhone 17 Pro Max only.
- CURRENT: Small-device screenshot simulator is `iPhone 17e` only when there is concrete layout risk.
- APPROVED: Use generic simulator builds for compile checks.
- APPROVED: Use concrete simulators for launch, screenshots, and XCTest.
- APPROVED: After every UI or implementation change, launch the updated app on iPhone 17 Pro Max before asking the user for screenshots.
- APPROVED: Always report exact commands used.
- CURRENT: Default Debug compile check:

```sh
xcodebuild -project ios/STRQ.xcodeproj -scheme STRQ -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

- CURRENT: Default Release no-code-sign compile check mirrors the Debug command with Release configuration:

```sh
xcodebuild -project ios/STRQ.xcodeproj -scheme STRQ -configuration Release -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

- APPROVED: Use Superpowers for planning, debugging, and verification discipline when available; it must not override STRQ product rules.
- APPROVED: Use XcodeBuildMCP for builds, simulator launch, screenshots, UI automation, and simulator-focused tests.
- APPROVED: XcodeBuildMCP simulator workflows require checking session defaults before first build/run/test.
- APPROVED: Use GitHub for repo metadata, PR/issue work, and commit verification; do not mutate remote without explicit approval.
- APPROVED: Use Figma only for design-system, UI-kit, mockup, asset, or handoff work; do not create/edit Figma files unless requested.
- APPROVED: Use Browser, Agent, and Mobbin for external references and current docs when product/reference risk warrants it.
- APPROVED: Do not use external references as direct templates.
- APPROVED: Use Appshots for screenshot-grounded UI bugs and flow evidence when available.
- APPROVED: Appshots/screenshots are evidence, not final product judgement.
- APPROVED: Goal Mode is allowed only for objective long-running tasks such as full-app screenshot audit, static copy search, release gating, build/test matrix, localization audit, or regression pass.
- REJECTED: Goal Mode for "make it beautiful", final design judgement, broad autonomous implementation, committing, or pushing.
- BLOCKED: Goal Mode must create checkpoints and stop before commit.

## 6. Product Language Rules

- APPROVED: English-first for new product surfaces.
- APPROVED: Use short, direct, human, gym-native product copy.
- APPROVED: German only for explicit localization slices.
- APPROVED: German localization remains a later explicit localization strategy/slice.
- BLOCKED: Do not treat global localization as solved from English-first cleanup work.
- BLOCKED: Future English-first work must be scoped and reviewed by screenshots.
- APPROVED: Prefer direct state, concrete training evidence, one clear next action, short labels, confidence only where data supports it, and humility where data is thin.
- REJECTED: Academic labels, diagnostic language, vague motivational filler, AI-sounding summaries, inflated precision, and user-facing terms that require explanation.
- REJECTED: Medical or diagnostic claims.
- REJECTED: Fake precision.
- REJECTED: Visible recovery/readiness percent or score-first hero unless explicitly approved for a scoped surface.
- REJECTED: AI/lab-report wording.
- REJECTED: Generic analytics dashboard language.
- REJECTED: Score-first hero patterns unless explicitly approved.
- APPROVED: Accepted gym-native wording patterns include `on track`, `held`, `forming`, `needs more`, `logged`, `build`, `next move`, `steady`, `lighter`, `back off`, `best set`, `training rhythm`, and `finish the next session`.
- REJECTED: User-facing terms such as `Evidence Signal`, `Claim`, `Trust now`, `Signal Readiness`, `Readiness Score` as a primary verdict, `Muscle Balance 73%`, `optimal`, `diagnostiziert`, `medizinisch`, and `garantiert`.

## 7. Design Development Method

- APPROVED: Start each surface by defining the product job.
- APPROVED: Audit the current screen before proposing changes.
- APPROVED: Run a reference sprint when the visual/product pattern is not yet strong enough.
- APPROVED: Create a pattern matrix: adopt, adapt, avoid.
- APPROVED: Write a concept brief before production integration when the direction is ambiguous or high-risk.
- APPROVED: Build a DEBUG prototype before Production for major UI direction changes.
- APPROVED: Review screenshots before approving UI direction.
- APPROVED: Write a production integration plan before touching production for high-risk surfaces.
- APPROVED: Implement a small production slice first.
- APPROVED: After UI implementation, launch the updated app on iPhone 17 Pro Max before asking the user to capture screenshots.
- APPROVED: User captures review screenshots manually by default unless a task explicitly asks Codex to capture them.
- BLOCKED: Commit only after approval.
- APPROVED: ActiveWorkout worked because it had a clear action moment.
- APPROVED: Progress improved after rejecting the abstract node map and generic analytics dashboard direction.
- APPROVED: Profile improved after rejecting settings/control-panel prototypes and moving to Athlete Identity First.
- APPROVED: If SwiftUI attempts keep missing visual quality, stop and use Figma or a wireframe rather than continuing blind code churn.

## 7A. Mandatory Design Freedom / App-of-Year Evaluation Addendum

APPROVED: Figma foundation, existing assets, current components, and current SwiftUI patterns are a baseline, not a ceiling.

APPROVED: STRQ may create new layouts, new component compositions, new visual metaphors, new hierarchy systems, and new custom signature surfaces when this improves product quality.

APPROVED: Existing Figma assets or UI-kit components must not be followed blindly if they make STRQ look generic, template-like, too card-heavy, too dashboard-like, or below App-of-Year quality.

APPROVED: A screen may be rebuilt conceptually if the current direction is wrong. Do not keep polishing a weak concept just because it already exists in code.

APPROVED: If a surface feels wrong, the team must identify the root cause before implementation:
- wrong product job
- wrong visual metaphor
- too many cards
- too much dashboard density
- weak first viewport
- unclear next action
- fake precision
- copy feels internal/AI/scientific
- Pro/reset/debug/account controls dominate
- existing component system is limiting the design
- Codex translated IA into a settings/admin screen

APPROVED: Mobbin/reference research is used to understand patterns, not to copy screens. For each reference, extract:
- hierarchy
- density
- first viewport structure
- grouping
- control placement
- emotional feel
- what to adopt
- what to adapt
- what to avoid

REJECTED: Do not ask Codex to “make it premium” or “make it App-of-Year” without reference patterns, product job, allowed files, forbidden files, screenshot plan, and approval criteria.

REJECTED: Do not accept a screen because it is neatly organized. A screen can be organized and still not be STRQ-level.

REJECTED: Do not let existing components force every surface into stacked cards.

APPROVED: Major surface design process:
1. Define product job.
2. Identify what currently feels wrong.
3. Search references if direction is uncertain.
4. Extract patterns, not visuals.
5. Create 2–3 concept options when needed.
6. Choose one direction.
7. Build DEBUG prototype only.
8. Review screenshots strictly.
9. Reject, polish, or approve.
10. Only then plan production integration.
11. Production must be sliced small.

APPROVED: Strict screenshot review must ask:
- Do I understand this in 10 seconds?
- Does it feel like STRQ, not a generic app?
- Is the strongest message first?
- Is the next action clear?
- Is the UI calm but not boring?
- Is it gym-native?
- Is it emotionally strong without fake motivation?
- Does it avoid fake precision?
- Does it avoid medical/scientific/AI copy?
- Is it better than common competitor patterns?
- Would a user feel they need only this app?

APPROVED: If Codex produces a screen that looks bad, too generic, too card-heavy, too admin-like, or not App-of-Year-level, stop implementation. Do not keep polishing blindly. Re-open product job, references, or concept variants.

APPROVED: ActiveWorkout worked because it had a clear action moment. Progress improved only after rejecting abstract analytics and moving to Training Path. Profile improved only after rejecting Settings/Admin directions and moving to Athlete Identity First. Future surfaces must preserve this learning.

APPROVED: New custom STRQ components are allowed when justified:
- custom hero surfaces
- custom training identity plates
- custom progress/path visuals
- custom rest/completion moments
- custom control rows
- custom proof strips
- custom App Store/promo visuals

BLOCKED: Production use of a new custom visual system requires screenshot approval and a production integration plan.

## 8. Completed Work Ledger

| SHA | Title | Surface | Purpose | Status |
|---|---|---|---|---|
| 47a740b | Add STRQ Codex operating rules | AGENTS / operating rules | Added canonical Codex rules and workflow defaults | APPROVED committed operating source |
| a5abd7c | Polish active workout header and task | ActiveWorkout | Improved live workout top read and current task clarity | CURRENT committed slice |
| 0a5ab79 | Refine active workout rest focus overlay | Rest Overlay | Strengthened rest-focus moment | CURRENT committed slice |
| e60f92d | Polish active workout rest feedback | Rest Overlay | Hardened rest feedback presentation | CURRENT committed slice |
| 6aa7805 | Polish active workout set table | ActiveWorkout | Improved set logging table ergonomics | CURRENT committed slice |
| db12806 | Fix active workout rest recommendation trust | ActiveWorkout / Rest | Protected rest guidance trust | CURRENT committed slice |
| e613622 | Localize active workout rest guidance | ActiveWorkout / Rest | Localized rest guidance copy | CURRENT committed slice |
| c374c7a | Polish workout completion experience | Completion | Cleaned finish/reward surface | CURRENT committed slice |
| d755ff4 | Align workout prescription displays with today target | Exercise Detail / Prescription | Made prescription display consistent with Today target | CURRENT committed slice |
| 4d089ff | Clamp weekly progress display ratios | Progress | Prevented weekly progress ratio over-display | CURRENT committed slice |
| 5991e78 | Localize weekly review copy | Weekly Review | Hardened localized Weekly Review copy | CURRENT committed slice |
| 0264b15 | Localize trainer coach signal copy | Trainer / Coach | Hardened Trainer/Coach signal copy | CURRENT committed slice |
| 40a1dff | Fix sleep logging daily upsert | Sleep & Recovery | Fixed daily sleep upsert behavior | CURRENT committed slice |
| 6587d2a | Add debug progress training path prototype | Progress DEBUG | Added DEBUG Training Path prototype and brief | CURRENT committed prototype source |
| 6ec581e | Add debug progress path prototype | Progress DEBUG | Added/reworked DEBUG Progress path prototype exposure | CURRENT committed prototype source |
| d24414c | Rebase Progress to Training Path surface | Progress Production | Moved production Progress toward Training Path direction | CURRENT committed production slice |
| ffb4871 | Stabilize production progress path | Progress Production P1A | Stabilized production Progress path | CURRENT committed production slice |
| 4f85d55 | Clean up production progress lower sections | Progress Production P2 | Cleaned lower Progress sections | CURRENT committed production slice |
| 6fbc2b8 | Harden profile and pro release surfaces | Profile / Pro Release Hygiene P0 | Release-gated Profile/Pro surfaces and protected copy | CURRENT committed P0 |
| ff0a202 | Add Profile V2 redesign plan | Profile V2 | Added Profile V2 plan document | CURRENT committed plan |
| 30278ce | Add debug profile v4 prototype | Profile V4 DEBUG | Added V4 signature exploration prototype | CURRENT committed prototype |
| 310019d | Add Profile V4 production integration plan | Profile V4 Plan | Added production integration plan | CURRENT committed plan |
| 9b3a64f | Stabilize Profile V4 first viewport | Profile Production P1-class | Stabilized first viewport in production Profile | CURRENT committed Profile production implementation |
| 9d85cdb | Polish profile recovery trust display | Profile Production | Recovery Trust Display slice | CURRENT committed Profile checkpoint slice |
| a560c1d | Restructure profile coach inputs section | Profile Production | Coach & Inputs Restructure slice | CURRENT committed Profile checkpoint slice |
| bbe5ef0 | Rehouse profile account data section | Profile Production | Account & Data Rehousing slice | CURRENT committed Profile checkpoint slice |
| 4e940f8 | Finish profile tools and advanced data sections | Profile Production | Tools / Privacy / Advanced Data slice | CURRENT committed Profile checkpoint slice |
| bbbc2a9 | Polish profile automatic split copy | Profile Production | Auto split Copy slice | CURRENT committed Profile checkpoint slice |
| 0bf0454 | Reduce recovery score precision in key surfaces | Today / Sleep & Recovery / Readiness Check-In | Reduced recovery/readiness score and percent-first presentation in key surfaces | CURRENT committed Recovery Trust P0-A |
| 1d74450 | Reduce recovery precision in coaching flows | Coach / PreWorkout | Softened recovery/readiness precision and score-led coaching copy | CURRENT committed Recovery Trust P0-B |
| cbb073b | Reduce recovery precision in progress | Progress | Kept Progress in Training Path mode while reducing recovery/readiness fake precision | CURRENT committed Recovery Trust P1-A |
| 55c2ca8 | Soften progress balance precision | Progress dormant modules | Preventively softened muscle/movement/volume balance precision that could reappear later | CURRENT committed Recovery Trust P1-B |
| bb85725 | Make core daily coach copy English-first | Today / Coach / Daily Briefing / Readiness result / Phase Outlook / Active Workout Rest | Cleaned core daily/coaching production copy and rest fallbacks toward English-first | CURRENT committed and pushed English-first P0-A |
| 71f4ebf | Make weekly review English-first | Weekly Review | Replaced German visible labels, cleaned generator copy, and softened training balance verdicts | CURRENT latest committed and pushed Weekly Review English-first |

- CURRENT: `docs/qa/profile-v3-concept-brief-2026-05-25.md` exists but is untracked in this checkout.
- APPROVED: The current transfer context treats Profile V3 Concept A / Athlete Identity First as the accepted direction that led to Profile V4.1.
- CURRENT: Profile is checkpoint-complete and pushed to `main` through `bbbc2a9`.
- APPROVED: Profile production direction is approved enough for the current checkpoint.
- BLOCKED: Do not continue Profile polish blindly; future Profile work starts from a fresh plan.
- CURRENT: Recovery Trust checkpoint is complete and pushed to `main` through Progress P1-B at `55c2ca8`.
- CURRENT: Recovery Trust cleaned up major recovery/readiness fake precision across Today, Sleep & Recovery, Readiness Check-In, Coach, PreWorkout, and Progress.
- BLOCKED: Do not reintroduce visible recovery/readiness percent or score-first hero without explicit approval.
- CURRENT: English-first P0-A checkpoint is complete and pushed to `main` through `bb85725`.
- CURRENT: Core daily/coaching production copy cleanup is committed and pushed.
- CURRENT: Today, Coach, Daily Briefing, Readiness result, Phase Outlook, and Active Workout Rest fallbacks were cleaned toward English-first.
- CURRENT: Weekly Review English-first cleanup is complete and pushed to `main` through `71f4ebf`.
- CURRENT: Weekly Review visible copy is now English-first.
- CURRENT: Weekly Review generator copy is English-first and avoids fake precision.
- CURRENT: Weekly Review training balance now avoids score-first or muscle-balance percentage verdicts.
- BLOCKED: Residual English-first / localization strategy audit remains open.
- BLOCKED: Global localization is not solved; German localization remains a later explicit strategy/slice.

## 9. Surface Status Map

| Surface | Status | Strongest Current Parts | Known Weaknesses | Next Likely Slice | Blocked Items |
|---|---|---|---|---|---|
| Today | CURRENT committed polish exists | CURRENT Today activation copy and first viewport were rebuilt/polished in recent history; Recovery Trust P0-A cleaned major recovery/readiness fake precision; English-first P0-A cleaned Today and Daily Briefing copy toward English-first | UNCERTAIN latest manual screenshots after English-first cleanup | CURRENT screenshot QA/copy audit if reopened | BLOCKED broad redesign, score-first recovery/readiness hero, or global localization assumptions without approval |
| Training tab | CURRENT app surface exists | CURRENT training structure feeds active plan flows | UNCERTAIN current visual/product approval state | UNCERTAIN audit before changes | BLOCKED broad production logic changes |
| PreWorkout / Handoff | CURRENT committed redesign exists | CURRENT launch/handoff flow has dedicated polish commit; Recovery Trust P0-B softened recovery/readiness precision in coaching handoff copy | UNCERTAIN latest screenshot quality | UNCERTAIN QA-only pass if user raises issue | BLOCKED behavior changes or score-first readiness display without scope |
| Daily Briefing / Phase Outlook | CURRENT committed English-first P0-A cleanup | CURRENT daily/coaching copy and Phase Outlook production copy were cleaned toward English-first in `bb85725` | UNCERTAIN latest manual screenshots after English-first cleanup | CURRENT screenshot QA/copy audit if reopened | BLOCKED fake precision, AI/lab wording, or treating global localization as solved |
| ActiveWorkout | CURRENT strongest surface pattern | APPROVED clear action moment, live logging, rest guidance, set table polish; English-first P0-A cleaned Active Workout Rest fallbacks toward English-first | UNCERTAIN residual edge cases and rest visuals need simulator QA if reopened | CURRENT Active Workout rest visual spot-check if reopened | BLOCKED broad workout mutation changes without explicit approval |
| Rest Overlay | CURRENT polished rest-focus direction | APPROVED focused rest/back-off moment | UNCERTAIN exact latest screenshot state | CURRENT screenshot QA when touched | BLOCKED medical/recovery claims |
| Completion | CURRENT committed polish | CURRENT PR/Gold reward direction is accepted when backed by real data | UNCERTAIN latest screenshot approval | CURRENT visual QA if reopened | BLOCKED fake PR/gold claims |
| Progress | CURRENT production P1A/P2 committed; Recovery Trust P1-A/P1-B complete | APPROVED Training Path/Progress direction, proof strip, one Next Move, lower sections; dormant muscle/movement/volume modules were softened preventively | UNCERTAIN dormant module screenshot quality if reactivated | CURRENT only planned, trust-gated production slices | BLOCKED node map, analytics dashboard, overclaiming, or visible recovery/readiness percent without approval |
| Coach / More Signals | CURRENT exists | CURRENT Trainer/Coach copy hardening committed; Recovery Trust P0-B cleaned major recovery/readiness fake precision; English-first P0-A cleaned Coach production copy toward English-first | BLOCKED density/alarmism risk remains | CURRENT copy and density audit | BLOCKED alarmist, diagnostic, score-first coaching, or global localization assumptions |
| Weekly Review | CURRENT English-first cleanup complete through `71f4ebf` | CURRENT visible copy is English-first; German labels were replaced; generator copy is English-first and avoids fake precision; training balance avoids score-first or muscle-balance percentage verdicts | BLOCKED global localization is not solved; residual localization strategy audit remains open | CURRENT residual English-first / localization strategy audit if scoped | BLOCKED fake precision or treating global localization as solved |
| Sleep & Recovery | CURRENT daily sleep upsert fixed | CURRENT sleep data write path has recent fix; Recovery Trust P0-A cleaned major recovery/readiness fake precision | UNCERTAIN latest manual screenshots after Recovery Trust cleanup | CURRENT trust/data-source audit when scoped | BLOCKED medical recovery diagnosis or score-first recovery hero |
| Readiness Check-In | CURRENT app surface exists | CURRENT Recovery Trust P0-A cleaned major readiness fake precision; English-first P0-A cleaned Readiness result copy toward English-first | UNCERTAIN latest manual screenshots after English-first cleanup | CURRENT screenshot QA/copy audit if reopened | BLOCKED visible readiness percent, score-first hero, or global localization assumptions without approval |
| Nutrition / Body | CURRENT Profile body/nutrition rows exist | CURRENT nutrition toggle side effects are known/protected | BLOCKED Nutrition / Physique residual copy check remains open | CURRENT display-only quiet input slice after approval | BLOCKED side-effect changes without explicit scope |
| Exercise Detail / Prescription | CURRENT prescription consistency commit exists | CURRENT prescription displays aligned with Today target | BLOCKED trust bug remains known | CURRENT bugfix plan/audit | BLOCKED logic changes without diagnosis |
| Profile | CURRENT checkpoint-complete through `bbbc2a9` | APPROVED Athlete Passport Compact direction; Profile production direction approved enough for checkpoint | BLOCKED do not continue Profile polish blindly | CURRENT no active Profile slice; future work needs fresh plan | BLOCKED future implementation without a new plan/slice |
| Paywall / Pro | CURRENT release hygiene P0 committed | CURRENT Pro unavailable/internal copy hardened | BLOCKED revenue-sensitive behavior protected | CURRENT visual/copy QA only unless scoped | BLOCKED StoreViewModel/RevenueCat/entitlement changes |
| App Store / Onboarding / Release | CURRENT onboarding and Pro preview work exists in recent history | CURRENT release gating rules exist | BLOCKED release/App Store polish not complete | CURRENT release-gating audit | BLOCKED shipping with debug/internal surfaces |

## 10. Progress Current State

- APPROVED: Current DEBUG Progress direction is `Progress`, optional `Training Path` subtitle, this-week path visual, state headline, proof strip, one Next Move, and lower sections `Confirmed / Building / Needs More / Recent Work / Next Move`.
- APPROVED: Progress is English-first for current approved direction.
- REJECTED: Abstract node map as first viewport.
- REJECTED: Generic analytics dashboard.
- REJECTED: Score-first hero, avatar/companion, social/leaderboard-first progress.
- CURRENT: DEBUG Progress prototype file inventory includes tracked `ios/STRQ/Views/Debug/ProgressTrainingMapPrototypeView.swift`.
- CURRENT: Production Progress file inventory includes tracked `ios/STRQ/Views/ProgressAnalyticsView.swift`.
- CURRENT: Older production candidate inventory includes tracked `ios/STRQ/Views/ProgressV5ProductionCandidateView.swift`.
- CURRENT: Production Progress P1A/P2 commits exist: `ffb4871` and `4f85d55`.
- CURRENT: Recovery Trust Progress P1-A/P1-B commits exist: `cbb073b` and `55c2ca8`.
- CURRENT: Progress remains Training Path, not an analytics dashboard.
- CURRENT: Dormant Progress muscle/movement/volume modules were softened preventively during Recovery Trust P1-B, but need screenshots and review if reactivated.
- BLOCKED: Do not broaden Progress without an explicit production integration plan.
- BLOCKED: Do not add or reintroduce muscle, movement, volume, PR/best-set, recovery, or readiness states to production unless trust gates and screenshot review are explicitly approved.
- BLOCKED: Do not reintroduce visible recovery/readiness percent or a score-first Progress hero without explicit approval.
- UNCERTAIN: `docs/qa/progress-prototype-brief-v1-2026-05-21.md` references `/Users/simplemax/Documents/progress_reference_matrix_report_full.md`, but that report is not present as a repo file in the searched repo paths.

## 11. Profile Current State

- CURRENT: Profile / Pro Release Hygiene P0 is committed at `6fbc2b8`.
- CURRENT: Profile V2 plan is committed at `ff0a202`.
- APPROVED: Profile V3 Concept A / Athlete Identity First is the accepted direction in the current transfer context.
- UNCERTAIN: `docs/qa/profile-v3-concept-brief-2026-05-25.md` is untracked and its own header says no implementation is approved by that document.
- CURRENT: Profile V4 DEBUG prototype is committed at `30278ce`.
- CURRENT: Profile V4 Production Integration Plan is committed at `310019d`.
- CURRENT: Profile V4 first viewport stabilization is committed at `9b3a64f`.
- CURRENT: Profile Recovery Trust Display is committed at `9d85cdb`.
- CURRENT: Profile Coach & Inputs Restructure is committed at `a560c1d`.
- CURRENT: Profile Account & Data Rehousing is committed at `bbe5ef0`.
- CURRENT: Profile Tools / Privacy / Advanced Data is committed at `4e940f8`.
- CURRENT: Profile Auto split Copy is committed at `bbbc2a9`.
- CURRENT: Profile is checkpoint-complete and pushed to `main` through `bbbc2a9`.
- APPROVED: Profile production direction is approved enough for the current checkpoint.
- CURRENT: Production Profile source inventory is tracked `ios/STRQ/Views/ProfileView.swift`.
- CURRENT: `ProfileView.swift` is not dirty in the refreshed repo state.
- CURRENT: `git diff --name-only` was empty before this documentation update.
- CURRENT: Production Profile currently contains `profileFirstViewport`, `athletePassportHero`, reliable passport reads, three overview rows, and lower sections that preserve existing routes.
- CURRENT: Profile V4 DEBUG inventory includes tracked `ios/STRQ/Views/Debug/ProfileV4SignatureExplorationView.swift`.
- CURRENT: `ios/STRQ/Views/Debug/ProfileV3PrototypeView.swift` exists but is untracked.
- REJECTED: Treat untracked `ProfileV3PrototypeView.swift` as rejected/prototype residue unless the user explicitly revives it.
- CURRENT: There is no active Profile polish or implementation slice after the post-Profile checkpoint.
- BLOCKED: Do not continue Profile polish blindly.
- BLOCKED: Future Profile implementation requires a fresh plan/slice; do not edit `ProfileView.swift` from this pack alone.
- BLOCKED: Staging, committing, and pushing remain blocked without explicit user approval.
- CURRENT: Untracked Profile screenshot QA folders must remain untracked unless explicitly requested.

## 11A. Recovery Trust Current State

- CURRENT: Recovery Trust checkpoint is complete and pushed to `main` through Progress P1-B at `55c2ca8`.
- CURRENT: P0-A is committed at `0bf0454 Reduce recovery score precision in key surfaces`.
- CURRENT: P0-B is committed at `1d74450 Reduce recovery precision in coaching flows`.
- CURRENT: P1-A is committed at `cbb073b Reduce recovery precision in progress`.
- CURRENT: P1-B is committed at `55c2ca8 Soften progress balance precision`.
- CURRENT: Today, Sleep & Recovery, Readiness Check-In, Coach, PreWorkout, and Progress have been cleaned up for major recovery/readiness fake precision.
- CURRENT: Progress remains Training Path, not an analytics dashboard.
- CURRENT: Dormant Progress muscle/movement/volume modules were softened preventively, but need screenshots and product review if reactivated.
- CURRENT: Weekly Review training balance now avoids score-first or muscle-balance percentage verdicts after `71f4ebf`.
- BLOCKED: No visible recovery/readiness percent or score-first hero may be reintroduced without explicit approval.
- BLOCKED: Nutrition / Physique residual copy check remains a future separate slice.
- BLOCKED: Global `Localizable.xcstrings` / `L10n` strategy remains a later explicit localization strategy/slice.
- BLOCKED: Reset Safety / Destructive Action UX remains a future separate slice.
- BLOCKED: Release / Debug Gating Audit remains a future separate slice before App Store or release work.

## 11B. English-First Current State

- CURRENT: English-first P0-A checkpoint is complete and pushed to `main` through `bb85725 Make core daily coach copy English-first`.
- CURRENT: Core daily/coaching production copy cleanup is committed and pushed.
- CURRENT: Today, Coach, Daily Briefing, Readiness result, Phase Outlook, and Active Workout Rest fallbacks were cleaned toward English-first.
- CURRENT: The cleanup was scoped to core daily/coaching production copy and rest fallbacks; it was not a global localization strategy.
- CURRENT: Weekly Review English-first cleanup is complete and pushed to `main` through `71f4ebf`.
- CURRENT: Weekly Review visible copy is now English-first.
- CURRENT: Weekly Review German labels such as `Wochenrückblick`, `Gesamtvolumen`, `Sätze gesamt`, `Erholung`, `Volumenvergleich`, `Signale`, `Coach-Einschätzung`, and `Nächste Schritte` were replaced with English-first copy.
- CURRENT: Weekly Review generator copy is English-first and avoids fake precision.
- CURRENT: Weekly Review training balance now avoids score-first or muscle-balance percentage verdicts.
- BLOCKED: Residual English-first / localization strategy audit remains open.
- BLOCKED: Do not treat global localization as solved.
- BLOCKED: German localization remains a later explicit localization strategy/slice.
- BLOCKED: Global `Localizable.xcstrings` / `L10n` strategy remains a future separate slice.
- BLOCKED: Future English-first work must be scoped and reviewed by screenshots.
- CURRENT: Carry forward residual English-first / localization strategy audit.
- CURRENT: Carry forward Nutrition / Physique residual copy check.
- CURRENT: Carry forward Global `Localizable.xcstrings` / `L10n` strategy later.
- CURRENT: Carry forward Active Workout rest visual spot-check if reopened.
- CURRENT: Carry forward Release / Debug Gating Audit.
- CURRENT: Carry forward Reset Safety / Destructive Action UX.

## 12. Rejected Direction Ledger

- REJECTED: Progress abstract node map as the first viewport.
- REJECTED: Progress generic analytics dashboard.
- REJECTED: Profile V2 card-heavy control center.
- REJECTED: Profile V3 settings-like prototypes.
- REJECTED: Training DNA / gimmicky profile concept.
- REJECTED: Profile as subscription page.
- REJECTED: Profile as settings dump.
- REJECTED: Codex as design judge.
- REJECTED: Score-first hero unless explicitly approved.
- REJECTED: Avatar/companion direction.
- REJECTED: Medical claims.
- REJECTED: Fake precision.
- REJECTED: Visible recovery/readiness percent or score-first hero unless explicitly approved.
- REJECTED: Scientific UI copy.
- REJECTED: Release-visible debug tools, internal previews, diagnostics, fixture states, package/build/sandbox copy, or internal labels.

## 13. Current Active Slice

- CURRENT: There is no active Profile implementation slice after the post-Profile checkpoint.
- CURRENT: Profile is checkpoint-complete and pushed to `main` through `bbbc2a9`.
- CURRENT: There is no active Recovery Trust implementation slice after Progress P1-B.
- CURRENT: Recovery Trust checkpoint is complete and pushed to `main` through `55c2ca8`.
- CURRENT: There is no active English-first implementation slice after Weekly Review English-first cleanup.
- CURRENT: English-first P0-A is complete and pushed to `main` through `bb85725`.
- CURRENT: Weekly Review English-first cleanup is complete and pushed to `main` through `71f4ebf`.
- APPROVED: Profile production direction is approved enough for the current checkpoint.
- BLOCKED: Do not continue Profile polish blindly.
- BLOCKED: Do not continue Recovery Trust polish blindly; remaining cleanup needs separately scoped slices.
- BLOCKED: Do not continue English-first cleanup blindly; future English-first work must be scoped and reviewed by screenshots.
- CURRENT: `ProfileView.swift` was not dirty before this documentation update.
- CURRENT: User captures screenshots manually by default.
- CURRENT: Default screenshot device is iPhone 17 Pro Max only.
- CURRENT: Small-device screenshots are only required if there is concrete layout risk.
- APPROVED: After every UI or implementation change, launch the updated app on iPhone 17 Pro Max before asking the user for screenshots.
- CURRENT: Existing untracked P1B screenshot folder is `docs/qa/profile-v4-production-p1b-ordering-stabilization-2026-05-27/`.
- BLOCKED: Future Profile implementation needs a fresh plan/slice; allowed files must be reconfirmed before editing.
- BLOCKED: If a future Profile production slice is approved, likely allowed file is `ios/STRQ/Views/ProfileView.swift` only, but this must be reconfirmed from current repo state.
- BLOCKED: Models, persistence, `AppViewModel`, `StoreViewModel`, RevenueCat, StoreKit, paywall behavior, restore, manage subscription, entitlements, products/packages, account/iCloud, HealthKit, nutrition side effects, reset behavior, plan generation/regeneration, analytics, project files, debug files, Watch, Widget, Live Activity remain forbidden for any Profile visual follow-up unless explicitly approved.
- CURRENT: Required Debug build command:

```sh
xcodebuild -project ios/STRQ.xcodeproj -scheme STRQ -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

- CURRENT: Required Release compile check when release gating is in scope:

```sh
xcodebuild -project ios/STRQ.xcodeproj -scheme STRQ -configuration Release -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

- BLOCKED: Stop condition is unclear file scope, build failure, blind Profile polish, or any need to touch forbidden systems.
- APPROVED: Profile checkpoint success criteria were no behavior changes, no route changes, no debug leak, no Pro hero, no reset hero, clear Athlete Passport first viewport, Pro below setup/body, clean build, and accepted manual screenshot review.
- CURRENT: Carry forward residual English-first / localization strategy audit.
- CURRENT: Carry forward Nutrition / Physique residual copy check.
- CURRENT: Carry forward Global `Localizable.xcstrings` / `L10n` strategy later as an explicit localization strategy/slice.
- CURRENT: Carry forward Active Workout rest visual spot-check if reopened.
- CURRENT: Carry forward Reset Safety / Destructive Action UX as a future separate slice.
- CURRENT: Carry forward Release / Debug Gating Audit before App Store or release work.
- CURRENT: Optional future Training Setup concept polish remains possible, but not now.

## 14. Current Dirty / Untracked State Rules

- CURRENT: Tracked dirty files before this Weekly Review English-first documentation update: none from `git status --short`.
- CURRENT: Expected tracked dirty file from this documentation-only task is `docs/qa/strq-master-transfer-pack-v2-2026-05-27.md`.
- CURRENT: Staged files: none from `git status --short`.
- CURRENT: Important untracked files/folders from `git status --short`:

| Path | Classification | Rule |
|---|---|---|
| `docs/qa/core-app-review-progress-p1a-p2-2026-05-25/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/l3-coach-active-signals-2026-05-21/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/post-p1a-progress-review-2026-05-25/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/profile-pro-release-hygiene-p0-2026-05-25/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/profile-v2-debug-prototype-2026-05-25/` | QA ARTIFACT / REJECTED DIRECTION EVIDENCE | CURRENT: do not revive without explicit approval |
| `docs/qa/profile-v2-reference-led-debug-prototype-2026-05-25/` | QA ARTIFACT / REJECTED DIRECTION EVIDENCE | CURRENT: do not revive without explicit approval |
| `docs/qa/profile-v2-v21-debug-prototype-2026-05-25/` | QA ARTIFACT / REJECTED DIRECTION EVIDENCE | CURRENT: do not revive without explicit approval |
| `docs/qa/profile-v3-concept-brief-2026-05-25.md` | CURRENT DOC ARTIFACT / UNCERTAIN TRACKING | CURRENT: source for direction, but untracked; do not stage without approval |
| `docs/qa/profile-v3-debug-prototype-2026-05-25/` | QA ARTIFACT / REJECTED DIRECTION EVIDENCE | CURRENT: do not revive without explicit approval |
| `docs/qa/profile-v3-v35-approval-polish-2026-05-26/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/profile-v4-1-athlete-passport-compact-2026-05-27/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/profile-v4-1-final-debug-qa-2026-05-27/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/profile-v4-production-p1-2026-05-27/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/profile-v4-production-p1a-stabilization-2026-05-27/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/profile-v4-production-p1b-ordering-stabilization-2026-05-27/` | CURRENT QA ARTIFACT | CURRENT: active review evidence; leave untracked unless explicitly requested |
| `docs/qa/profile-v4-signature-exploration-2026-05-26/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/progress-p1-large-2026-05-23/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/progress-p1-small-2026-05-23/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/progress-p1a-english-large-2026-05-24/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/progress-p1a-english-small-2026-05-24/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/progress-p1a-stabilization-2026-05-25/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/progress-p2-lower-scroll-2026-05-25/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/progress-path-v03-2026-05-22/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/progress-path-v031-2026-05-22/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/progress-path-v031-polish-2026-05-22/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/progress-training-map-redesign-plan-2026-05-21.md` | CURRENT DOC ARTIFACT / UNCERTAIN TRACKING | CURRENT: used as source, untracked per status; do not stage without approval |
| `docs/qa/strq-new-chat-transfer-2026-05-22.md` | QA / TRANSFER ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `docs/qa/strq-screen-map-snapshot-2026-05-21/` | QA ARTIFACT | CURRENT: leave untracked unless explicitly requested |
| `ios/STRQ/Views/Debug/ProfileV3PrototypeView.swift` | REJECTED / UNCERTAIN SOURCE ARTIFACT | REJECTED: do not use or stage unless explicitly revived |

- CURRENT: Screenshot QA folders are local evidence and must remain untracked unless the user explicitly requests staging.
- BLOCKED: Do not stage any untracked QA folders or rejected prototype files during Profile/Progress work without an explicit file list.

## 15. Known Future Blockers

- BLOCKED: Exercise Detail / Prescription trust bug remains a known future blocker.
- BLOCKED: Coach / More Signals has density/alarmism risk.
- CURRENT: Profile checkpoint is complete; do not continue Profile polish blindly.
- BLOCKED: Future Profile implementation requires a fresh plan/slice.
- CURRENT: Recovery Trust checkpoint is complete through Progress P1-B at `55c2ca8`.
- CURRENT: English-first P0-A checkpoint is complete through `bb85725`.
- CURRENT: Weekly Review English-first cleanup is complete through `71f4ebf`.
- BLOCKED: No visible recovery/readiness percent or score-first hero may be reintroduced without explicit approval.
- BLOCKED: Residual English-first / localization strategy audit remains open.
- BLOCKED: Nutrition / Physique residual copy check remains open.
- BLOCKED: Global `Localizable.xcstrings` / `L10n` strategy remains a later explicit localization strategy/slice.
- BLOCKED: Do not treat global localization as solved.
- BLOCKED: Active Workout rest visual spot-check remains open if that surface is reopened.
- BLOCKED: Reset Safety / Destructive Action UX remains a future separate slice.
- BLOCKED: Progress PR/Best Set state is not production-verified.
- BLOCKED: Progress dormant muscle/movement/volume modules were softened preventively, but need screenshots and review if reactivated.
- BLOCKED: Muscle coverage, movement balance, volume balance, and recovery require trust gates before production claims.
- BLOCKED: Localization is not active except explicit localization slices.
- BLOCKED: App Store / onboarding / release polish remains open.
- BLOCKED: Release / Debug Gating Audit remains required before App Store or release work.
- CURRENT: Optional future Training Setup concept polish is carried forward, but not now.

## 16. QA / Screenshot Discipline

- APPROVED: Confirm screenshot plan before coding any UI change.
- APPROVED: Default screenshot device is iPhone 17 Pro Max only.
- APPROVED: Small-device screenshots are required only when there is concrete layout risk.
- APPROVED: Use iPhone 17e for small-device screenshots when concrete layout risk exists and the simulator is available.
- APPROVED: User captures review screenshots manually by default.
- APPROVED: After every UI or implementation change, launch the updated app on iPhone 17 Pro Max before asking the user for screenshots.
- APPROVED: Future English-first UI/copy work must be scoped and reviewed by screenshots.
- APPROVED: Use contact sheets when reviewing many screens/states.
- CURRENT: Local Mac paths are not reviewable by ChatGPT unless images are uploaded or otherwise made visible in the review context.
- APPROVED: Screenshots are evidence, not approval.
- APPROVED: Build pass is not approval.
- APPROVED: UI review checks 10-second clarity, premium feel, clear next action, believable data, human/gym-native copy, no fake precision, and fit with accepted STRQ visual direction.
- BLOCKED: UI changed without screenshots is not review-ready.

## 17. Prompt Templates

### Plan Only

```text
Task type: Plan only.

Goal:
<one-sentence outcome>

Allowed files:
<files or "no file edits">

Forbidden:
<files/actions>

Use AGENTS.md and STRQ Codex Operating Rules.
Read relevant repo context first.
Run git status --short first.
Do not edit code.
Do not stage, commit, or push.

Output:
- Status labels: APPROVED / REJECTED / BLOCKED / CURRENT / UNCERTAIN
- Recommended plan
- Files likely affected
- Build/test/screenshot plan
- Risks and review gates
```

### Implementation Slice

```text
Task type: Implementation.

Goal:
<specific user-facing or technical outcome>

Allowed files:
<exact file list>

Forbidden:
<production logic/data/project files out of scope>

Requirements:
<acceptance criteria>

Use AGENTS.md and STRQ Codex Operating Rules.
Confirm repo root, branch, and git status first.
Plan before editing.
Use only the allowed files.

Verification:
- Run the appropriate STRQ build/test command.
- If UI changed, launch the updated app on iPhone 17 Pro Max before asking the user for manual screenshots.
- Report exact commands and outputs.

Do not stage, commit, or push.
Stop for review after implementation and verification.
```

### UI Screenshot Fix

```text
Task type: QA only or Implementation, depending on needed fix.

Visible issue:
<what is wrong in the screenshot>

Screenshot source:
<path or simulator/app context>

Allowed files:
<exact UI files>

Forbidden:
- model changes
- persistence changes
- analytics changes
- broad redesign

Please:
1. Inspect current UI code.
2. Make the smallest fix that resolves the visible issue.
3. Build.
4. Launch the updated app on iPhone 17 Pro Max before asking the user for manual before/after screenshots if possible.
5. Report paths and remaining visual risk.

Do not stage, commit, or push.
```

### DEBUG Prototype

```text
Task type: Debug/prototype.

Goal:
Explore <surface/interaction/state> without production integration.

Allowed files:
<debug/prototype files only>

Forbidden:
- production data model changes
- persistence changes
- analytics changes
- project file changes unless explicitly approved

Prototype constraints:
- English-first unless explicit localization slice
- plausible but clearly non-production data
- optimize for product review screenshots
- stop before production integration

Verification:
- Build the app.
- Launch on iPhone 17 Pro Max for review.
- Ask the user to capture manual screenshots unless Codex screenshot capture is explicitly requested.

Do not stage, commit, or push.
```

### Reference Sprint

```text
Task type: Plan only / reference sprint.

Goal:
Research <surface> patterns before STRQ design decisions.

Allowed actions:
- Browser / Mobbin / Agent reference gathering
- notes and pattern matrix only

Forbidden:
- copying competitor layouts
- app source edits
- staging
- committing
- pushing

Return:
- product job
- current STRQ screen audit
- adopt / adapt / avoid matrix
- recommended concept direction
- screenshot/prototype plan
- explicit blockers and uncertainties
```

### Production Integration

```text
Task type: Production integration.

Goal:
Integrate approved prototype slice <name> into production.

Approved source:
<prototype/design/screenshot/plan path>

Allowed production data:
<trusted data list>

Forbidden data:
<risky or unapproved data list>

Rules:
- Do not integrate all prototype states at once.
- Keep the first slice narrow.
- Preserve existing models/persistence unless explicitly approved.
- Use low-data states where evidence is insufficient.

Verification:
- Generic no-code-sign build.
- Concrete simulator launch if UI changed.
- XCTest if behavior changed.
- User-captured screenshots for changed surface unless Codex screenshot capture is explicitly requested.

Do not stage, commit, or push.
```

### QA / Goal Mode

```text
Task type: Goal Mode task.

Objective:
<objective, measurable audit/check>

Allowed actions:
<build/test/screenshot/static search only>

Forbidden:
- autonomous broad implementation
- final design judgement
- staging
- committing
- pushing

Checkpoints:
1. Initial repo state and scope confirmation.
2. First evidence batch.
3. Findings summary.
4. Stop for review before any fix or commit.

Output:
- Evidence paths
- Commands run
- Findings by severity
- Recommended next slices
```

### Commit Approval Checklist

```text
Commit approval requested for:
<branch/scope>

Before staging, confirm:
- Scope matches the approved task.
- git diff --name-only contains only intended files.
- git diff --check passes.
- Build/test verification has been run and reported.
- Screenshots are included or excluded intentionally.
- Untracked QA folders are accounted for.
- Rejected prototype artifacts are not included.

Only after explicit approval:
1. Stage only approved files.
2. Commit with an intentional message.
3. Push only if explicitly approved.
4. Open PR only if explicitly approved.
```

## 18. SaveContext Seed Entries

| Key | Category | Priority | Value |
|---|---|---|---|
| strq_identity | product | high | APPROVED: iOS strength app; premium, calm, gym-native, focused, data-based, emotionally strong; App-of-Year target by 2027. |
| strq_role_split | operating | high | APPROVED: User/ChatGPT judge product/design/language; Codex implements/audits/builds/launches for screenshot review; screenshots are user-captured by default. |
| strq_no_commit | git | high | BLOCKED: No stage, commit, or push without explicit approval; after approval, commit and push together unless the user explicitly says otherwise. |
| strq_ui_approval | qa | high | APPROVED: Build pass is not approval; UI needs screenshots and user/ChatGPT review. |
| strq_language | copy | high | APPROVED: English-first; short gym-native copy; no medical, fake precision, AI, or lab wording; German localization remains a later explicit strategy/slice. |
| strq_english_first | copy | high | CURRENT: English-first P0-A complete and pushed through bb85725; Weekly Review English-first cleanup complete and pushed through 71f4ebf; global localization is not solved. |
| strq_weekly_review_english_first | copy | high | CURRENT: Weekly Review visible copy is English-first; German labels were replaced; generator copy is English-first and avoids fake precision; training balance avoids score-first or muscle-balance percentage verdicts. |
| strq_progress_direction | progress | high | APPROVED: Progress Training Path with state headline, proof strip, one Next Move, lower proof sections; not an analytics dashboard. |
| strq_progress_rejected | progress | high | REJECTED: node map first viewport, analytics dashboard, score-first, avatar, fake precision. |
| strq_recovery_trust | recovery | high | CURRENT: Recovery Trust checkpoint complete and pushed through Progress P1-B at 55c2ca8; Today, Sleep & Recovery, Readiness Check-In, Coach, PreWorkout, and Progress cleaned up for major recovery/readiness fake precision; no visible recovery/readiness percent or score-first hero without explicit approval. |
| strq_profile_direction | profile | high | APPROVED: Profile V4.1 Athlete Passport Compact, identity first, Pro below setup, reset isolated; production direction approved enough for checkpoint. |
| strq_profile_active | profile | high | CURRENT: Profile checkpoint-complete and pushed to main through bbbc2a9; no active Profile implementation slice. |
| strq_profile_blocked | profile | high | BLOCKED: Do not continue Profile polish blindly; future Profile work requires a fresh plan/slice; no stage/commit/push without explicit approval. |
| strq_profile_v3_warning | profile | medium | REJECTED/UNCERTAIN: Untracked ProfileV3PrototypeView.swift is rejected residue; do not stage or revive unless asked. |
| strq_tooling | tooling | medium | CURRENT: Project ios/STRQ.xcodeproj, scheme STRQ, Debug default, iPhone 17 Pro Max default screenshot device, iPhone 17e only for concrete layout risk. |
| strq_build_debug | tooling | medium | CURRENT: xcodebuild Debug generic simulator CODE_SIGNING_ALLOWED=NO build is default compile check. |
| strq_dirty_rules | git | high | CURRENT: Untracked QA folders are evidence only; leave untracked unless explicitly requested. |
| strq_screenshot_rule | qa | high | APPROVED: User captures screenshots manually by default; after every UI/implementation change, launch updated app on iPhone 17 Pro Max before asking for screenshots. |
| strq_future_blockers | roadmap | medium | BLOCKED: prescription trust, Coach density, residual English-first / localization strategy audit, Global Localizable.xcstrings / L10n strategy later, Active Workout rest visual spot-check if reopened, Nutrition / Physique residual copy check, Reset Safety / Destructive Action UX, Progress dormant module screenshots if reactivated, Release / Debug Gating Audit. |

## 19. New Chat Bootstrap Prompt

```text
Use AGENTS.md and STRQ Codex Operating Rules.

Repo path:
/Users/simplemax/Documents/Codex/2026-05-12/gebe-mir-den-derzeitigen-stand-ber/rork-strq

Start by reading AGENTS.md.
Then run:
git status --short
git branch --show-current
git log --oneline -n 10
git diff --name-only

Use SaveContext if available, but do not continue from memory alone. Verify repo state and current files.
Current repo state overrides this Transfer Pack only for dirty/committed file state. Product and design decisions remain valid unless explicitly changed. If committed/dirty status conflicts with this pack, stop and ask before editing.

Role split:
- User and ChatGPT are final product, design, and language judges.
- Codex implements, audits, reads repo, runs builds/tests, launches the app for screenshot review, captures screenshots only when explicitly requested, and proposes plans.
- Codex is not the design judge.

Product identity:
STRQ is an iOS fitness/strength app targeting App-of-the-Year-level quality by 2027. It should feel premium, calm, gym-native, focused, data-based, and emotionally strong. The engine may be science-based; the UI must not sound scientific. New product UI is English-first.

Profile checkpoint:
Profile is checkpoint-complete and pushed to main through bbbc2a9. Completed slices are 9d85cdb Recovery Trust Display, a560c1d Coach & Inputs Restructure, bbe5ef0 Account & Data Rehousing, 4e940f8 Tools / Privacy / Advanced Data, and bbbc2a9 Auto split Copy. Profile production direction is approved enough for the current checkpoint.

Recovery Trust checkpoint:
Recovery Trust is checkpoint-complete and pushed to main through Progress P1-B at 55c2ca8. Completed slices are 0bf0454 Reduce recovery score precision in key surfaces, 1d74450 Reduce recovery precision in coaching flows, cbb073b Reduce recovery precision in progress, and 55c2ca8 Soften progress balance precision. Today, Sleep & Recovery, Readiness Check-In, Coach, PreWorkout, and Progress have been cleaned up for major recovery/readiness fake precision. No visible recovery/readiness percent or score-first hero should be reintroduced without explicit approval. Progress remains Training Path, not an analytics dashboard. Dormant Progress muscle/movement/volume modules were softened preventively, but need screenshots and product review if reactivated.

English-first P0-A checkpoint:
English-first P0-A is checkpoint-complete and pushed to main through bb85725 Make core daily coach copy English-first. Core daily/coaching production copy cleanup is committed and pushed. Today, Coach, Daily Briefing, Readiness result, Phase Outlook, and Active Workout Rest fallbacks were cleaned toward English-first.

Weekly Review English-first checkpoint:
Weekly Review English-first cleanup is complete and pushed to main through 71f4ebf Make weekly review English-first. Weekly Review visible copy is now English-first. German labels such as Wochenrückblick, Gesamtvolumen, Sätze gesamt, Erholung, Volumenvergleich, Signale, Coach-Einschätzung, and Nächste Schritte were replaced with English-first copy. Training balance now avoids score-first or muscle-balance percentage verdicts. Weekly Review generator copy is English-first and avoids fake precision. Do not treat global localization as solved. German localization and Localizable.xcstrings / L10n strategy remain later explicit localization slices. Future English-first work must be scoped and reviewed by screenshots.

Active slice:
There is no active Profile, Recovery Trust, or English-first implementation slice unless the user explicitly creates one. Do not continue Profile, Recovery Trust, or English-first polish blindly. Future Profile implementation requires a fresh plan/slice and reconfirmed allowed files. Remaining carry-forward is residual English-first / localization strategy audit, Nutrition / Physique residual copy check, Global Localizable.xcstrings / L10n strategy later, Active Workout rest visual spot-check if reopened, Reset Safety / Destructive Action UX, and Release / Debug Gating Audit.

Allowed/forbidden rule:
Identify allowed and forbidden files before editing. If allowed/forbidden files are unclear, do not edit.
For any future Profile production follow-up, forbidden systems include models, persistence, AppViewModel, StoreViewModel, RevenueCat, StoreKit, paywall behavior, restore, manage subscription, entitlements, products/packages, account/iCloud, HealthKit, nutrition side effects, reset behavior, plan generation/regeneration, analytics, project files, debug files, Watch, Widget, and Live Activity unless explicitly approved.

Screenshot/build rule:
For UI work, confirm screenshot plan before coding. Build pass is not product approval. User captures screenshots manually by default. Default screenshot device is iPhone 17 Pro Max only. Small-device screenshots are only needed if there is concrete layout risk. After every UI or implementation change, launch the updated app on iPhone 17 Pro Max before asking the user for screenshots. Report exact build/test/launch commands.

Default Debug compile check:
xcodebuild -project ios/STRQ.xcodeproj -scheme STRQ -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build

No stage/commit/push rule:
Do not stage, commit, or push without explicit approval. After explicit approval, commit and push together unless the user explicitly says otherwise.

Current warnings:
- Do not treat uncommitted work as approved.
- Do not treat old dirty-slice text as current if git status and git diff disagree.
- Do not reopen or polish Profile without a fresh plan.
- Do not reintroduce visible recovery/readiness percent or score-first hero without explicit approval.
- Keep Progress as Training Path, not an analytics dashboard.
- Do not treat English-first P0-A or Weekly Review English-first cleanup as global localization completion.
- Keep German localization for a later explicit localization strategy/slice.
- Scope and screenshot-review future English-first work.
- Leave untracked QA folders untracked unless explicitly requested.
- Treat ios/STRQ/Views/Debug/ProfileV3PrototypeView.swift as rejected/untracked residue unless explicitly revived.
- Do not continue from memory alone; verify source files and status.
- Carry forward residual English-first / localization strategy audit, Nutrition / Physique residual copy check, Global Localizable.xcstrings / L10n strategy later, Active Workout rest visual spot-check if reopened, Reset Safety / Destructive Action UX, Release / Debug Gating Audit, and optional future Training Setup concept polish, but do not start them without explicit scope.
```

## 20. Strictness Clause

- BLOCKED: If unable to label status, stop and ask.
- BLOCKED: If allowed/forbidden files are unclear, do not edit.
- BLOCKED: If UI changed without screenshots, not review-ready.
- BLOCKED: If build passed but screenshots/product review missing, not approved.
- BLOCKED: If new idea conflicts with pack, treat as proposal.
