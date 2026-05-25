# STRQ Codex Operating Rules

Date: 2026-05-24

This document defines how Codex should work on STRQ. It is meant to protect the project while still leaving room for strong product judgment, creative exploration, and App-of-the-Year-level craft.

STRQ is an iOS fitness and strength app aiming for App-of-the-Year-level quality by 2027. It should feel premium, calm, gym-native, focused, data-based, and emotionally strong. The engine may be science-based, but the UI should not sound scientific.

## 1. Role Model

User and ChatGPT are the final product, design, and language judges.

Codex implements, audits, reads the repo, runs builds/tests, captures screenshots, and proposes plans. Codex is not the final design judge.

Agent, Mobbin, and Browser are for external references. They help gather examples, current documentation, and product context. They do not approve STRQ product direction.

Figma is for design context, design-system work, mockups, UI-kit work, assets, and handoff. Figma output is not automatic design approval.

Build success means the app compiles. It does not mean the product experience is approved.

## 2. Product Quality Principles

STRQ must feel:
- premium
- gym-native
- focused
- clear
- emotionally strong
- data-based but not academic
- trustworthy with evidence gates

STRQ must avoid:
- generic analytics dashboards
- AI-sounding explanations
- medical claims
- fake precision
- score-first hero patterns unless explicitly approved
- broad redesigns without prototype approval
- changing production logic while "just polishing UI"

Use the product bar as a constraint, not a cage. Codex may propose stronger alternatives when the requested path would weaken the app, but it must make the tradeoff explicit and wait at the right review gate.

## 3. Language Rules

Main product language is English-first.

For new product surfaces, use short, direct, gym-native English. The copy should sound like a premium training product, not a research paper, chatbot, medical app, or enterprise analytics tool.

German localization comes later in explicit localization slices. Do not over-optimize new product surfaces in German unless the task explicitly says German localization.

Avoid:
- academic labels
- diagnostic language
- vague motivational filler
- AI-sounding summaries
- inflated precision
- user-facing terms that require explanation

Prefer:
- direct state
- concrete training evidence
- one clear next action
- short labels
- confidence where the data supports it
- humility where the data is thin

## 4. Workflow Rules

Every task must be classified first:
- Plan only
- Implementation
- QA only
- Debug/prototype
- Production integration
- Goal Mode task

Default flow:
1. Understand scope.
2. Identify allowed files.
3. Identify forbidden files.
4. Plan.
5. Implement only if requested.
6. Build/test.
7. Capture screenshots when UI changed.
8. Stop for review.
9. Do not stage, commit, or push without explicit approval.

Before work, Codex should run:

```sh
git status --short
```

Before review, Codex should run:

```sh
git diff --name-only
git diff --check
```

Codex should report unrelated untracked QA folders separately so they are not confused with the current slice.

## 5. Allowed Openness

Codex may:
- propose better alternatives if the requested path is risky
- recommend Agent/Mobbin/Figma research before implementation
- recommend a DEBUG prototype before Production
- recommend splitting a task into safer slices
- stop and report blockers
- ask for screenshots if visual review is required
- propose deleting or rebuilding a weak surface if justified

Codex must not:
- silently broaden scope
- rewrite models, persistence, or analytics unless explicitly allowed
- commit or push without approval
- treat build success as product approval
- call a surface App-of-the-Year-ready without user/ChatGPT review
- use screenshots as final taste judgement

## 6. Default Tool Settings For STRQ

Project:
- repo: `rork-strq`
- iOS project: `ios/STRQ.xcodeproj`
- scheme: `STRQ`
- default configuration: `Debug`
- default simulator: `iPhone 17 Pro Max`, iOS 26.5 when available

Default no-code-sign build:

```sh
xcodebuild -project ios/STRQ.xcodeproj -scheme STRQ -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Concrete simulator build/test when needed:
- Use XcodeBuildMCP session defaults.
- project = `ios/STRQ.xcodeproj`
- scheme = `STRQ`
- device = `iPhone 17 Pro Max`
- configuration = `Debug`

Testing:
- Use generic build for compile checks.
- Use concrete simulator for UI launch, screenshots, and XCTest.
- If generic test cannot run, use `iPhone 17 Pro Max` concrete simulator.
- Always report the exact command used.

Screenshots:
- Use XcodeBuildMCP/Appshots for UI evidence when available.
- For full flows, save screenshots under `docs/qa/<slice-name>-YYYY-MM-DD/` or `STRQ-Screenshots/<slice-name>-YYYY-MM-DD/`.
- Do not stage screenshots unless explicitly requested.

Git:
- Before work: `git status --short`
- Before review: `git diff --name-only`
- Before review: `git diff --check`
- Do not stage unless approved.
- Do not commit unless approved.
- Do not push unless approved.
- Report untracked QA folders separately.

## 7. Tool Usage Rules

### Superpowers

Use Superpowers for planning, debugging, and verification discipline.

Do not let Superpowers override STRQ product rules. If a process skill pushes toward unnecessary ceremony for a clearly scoped STRQ documentation or QA task, follow the user-approved STRQ scope and keep the process lightweight.

### XcodeBuildMCP

Use XcodeBuildMCP for builds, simulator launch, screenshots, UI automation, and simulator-focused tests.

Always set or check project, scheme, and device defaults before simulator workflows. If defaults are unset, use:
- project: `ios/STRQ.xcodeproj`
- scheme: `STRQ`
- device: `iPhone 17 Pro Max`
- configuration: `Debug`

### GitHub

Use GitHub for repo metadata, PR/issue work, and commit verification.

Do not mutate the remote without explicit approval. This includes opening PRs, adding labels, commenting, pushing branches, or changing issue state.

### Figma

Use Figma only for design-system, UI-kit, mockup, asset, or design handoff work.

Do not create or edit Figma files unless explicitly requested.

Do not copy competitor UI. External references can inform principles, density, hierarchy, motion, and interaction patterns, but STRQ must remain its own product.

### Browser, Agent, And Mobbin

Use Browser, Agent, and Mobbin for external references and current docs.

Use them when recommendations require current information or when visual/product references would reduce risk.

Do not use external references as direct templates.

### Appshots

Use Appshots for screenshot-grounded UI bugs.

Use Appshots when the user points at a visible simulator/app issue or when a UI flow needs evidence across screens.

Appshots can provide evidence, but not final product judgement.

### Goal Mode

Goal Mode is allowed only for objective, long-running tasks:
- full-app screenshot audit
- static copy search
- release gating checks
- build/test matrix
- localization audit
- regression pass

Goal Mode is not allowed for:
- "make it beautiful"
- final design judgement
- broad autonomous implementation
- committing or pushing

Goal Mode must create checkpoints and stop before commit.

## 8. Progress-Specific Rules

Current approved DEBUG direction:
- `Progress`
- optional `Training Path` subtitle
- this-week path visual
- state headline
- proof strip
- one Next Move
- lower sections: `Confirmed / Building / Needs More / Recent Work / Next Move`
- English-first
- no abstract node map

Rejected Progress directions:
- abstract node map as first viewport
- generic analytics dashboard
- score-first hero
- avatar/companion
- leaderboard/social-first progress
- exact muscle-balance percentages without trust gates
- medical recovery claims
- `Training Read` / `Read` as user-facing terms

Production Progress rule:

Production Progress is blocked until an explicit production integration plan is approved.

The first production slice should likely be P1 First Viewport only:
- Hero State
- This Week Path
- Proof Strip
- Next Move

Use only reliable production data for P1. Do not integrate all 12 DEBUG states into production at once.

## 9. Production-Data Trust Rules

Reliable for P1:
- completed workout count
- weekly target completed / target / overflow clamp
- workout dates and spacing
- recent best set only if already trusted
- low-data state

Risky for P1:
- muscle coverage percentages
- broad strength trend
- recovery diagnosis
- plateau cause
- giant volume deltas
- PR claims without comparable history

If a data point is risky, Codex should either remove it from the slice, gate it behind a low-confidence state, or ask for explicit approval before using it.

## 10. UI Review Rules

A UI slice is not approved because it builds. UI approval requires screenshots.

For screenshots, judge:
- Can the user understand it in 10 seconds?
- Does it feel premium?
- Is the next action clear?
- Is the data believable?
- Is the copy human/gym-native?
- Does it avoid fake precision?
- Does it match accepted STRQ visual direction?

Screenshots are evidence, not final taste judgement. The final product/design/language judges are User and ChatGPT.

## 11. Standard Prompt Templates

### Plan-Only Task

```text
Task type: Plan only.

Goal:
<one-sentence outcome>

Allowed files:
<files or "no file edits">

Forbidden:
<files/actions>

Please:
1. Read the relevant repo context.
2. Identify risks and dependencies.
3. Propose a minimal safe plan.
4. Do not edit code.
5. Do not stage, commit, or push.

Output:
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
<exact file list or scoped folders>

Forbidden:
<production logic/data/project files if out of scope>

Requirements:
<acceptance criteria>

Verification:
- Run the appropriate STRQ build/test command.
- Capture screenshots if UI changed.
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
1. Inspect the current UI code.
2. Make the smallest fix that resolves the visible issue.
3. Build.
4. Capture before/after screenshots if possible.
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
- English-first
- use plausible but clearly non-production data
- optimize for product review screenshots
- stop before production integration

Verification:
- Build the app.
- Launch on concrete simulator if needed.
- Capture screenshots to docs/qa/<slice-name>-YYYY-MM-DD/.

Do not stage, commit, or push.
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
- Screenshots for the changed surface.

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
- `git diff --name-only` contains only intended files.
- `git diff --check` passes.
- Build/test verification has been run and reported.
- Screenshots are included or excluded intentionally.
- Untracked QA folders are accounted for.

Only after explicit approval:
1. Stage only approved files.
2. Commit with an intentional message.
3. Push only if explicitly approved.
4. Open PR only if explicitly approved.
```

## 12. Defaults To Actively Set Or Check Per Codex Session

At the start of a STRQ Codex session:
- Confirm repo root.
- Run `git status --short`.
- Confirm active branch.
- Confirm Xcode project path: `ios/STRQ.xcodeproj`.
- Confirm scheme: `STRQ`.
- Confirm simulator availability:
  - `iPhone 17 Pro Max` preferred
  - `iPhone 17e` for small-device screenshots
- Confirm whether task is Plan / Implementation / QA / Goal.
- Confirm no commit/push permission unless explicitly given.
- If UI task: confirm screenshot plan before coding.

## 13. End-Of-Task Output Format

At the end of any Codex task, report:
- What changed
- Files changed
- Build result
- Test result if applicable
- Screenshot paths if applicable
- Scope confirmation
- Not staged / not committed / not pushed, unless explicitly approved

For documentation-only tasks, explicitly report that no app source code, production Swift files, project files, staging, commits, or pushes were changed.

## 14. Safety Defaults

When in doubt:
- choose the smaller slice
- preserve production logic
- ask for design review before production integration
- use screenshots for UI evidence
- report uncertainty instead of inventing certainty
- keep STRQ English-first unless localization is explicitly in scope

STRQ quality should rise through disciplined slices, not broad autonomous rewrites.
