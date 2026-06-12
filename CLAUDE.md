# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

STRQ is a native iOS strength-coaching app (SwiftUI, Xcode project at `ios/STRQ.xcodeproj`) aiming for App-of-the-Year-level quality by 2027. The owner (Max) and ChatGPT are the final product/design/language judges — Claude implements, audits, builds, captures screenshots, and proposes plans, but never declares a surface "approved" on its own. Build success ≠ product approval.

`AGENTS.md` and `docs/qa/strq-codex-operating-rules-2026-05-24.md` define the full operating contract. For ANY UI/design work, the `strq-design` skill (`.claude/skills/strq-design/SKILL.md`) is mandatory — it carries the design law, quality gates, persona panel, and money rules.

## Commands

Compile check (generic simulator build, no signing). Pipe through `xcbeautify --quiet` (installed) so only warnings/errors surface; `pipefail` preserves the exit code:

```sh
set -o pipefail && xcodebuild -project ios/STRQ.xcodeproj -scheme STRQ -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build | xcbeautify --quiet
```

Unit tests (single test class/method via `-only-testing`):

```sh
xcodebuild test -project ios/STRQ.xcodeproj -scheme STRQ -configuration Debug \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' \
  -only-testing:STRQTests/STRQTests CODE_SIGNING_ALLOWED=NO
```

UI screenshot capture (build + UI test + export attachments to `docs/qa/`):

```sh
scripts/qa/capture_strq_core_flow.sh        # core flow snapshots
scripts/qa/capture_strq_onboarding_v2.sh    # onboarding
scripts/qa/capture_strq_screen_map.sh       # full screen map
scripts/qa/capture_strq_pro_preview.sh      # pro/paywall preview
```

Device conventions: `iPhone 17 Pro Max` for default work, `iPhone 17e` for small-device checks. Owner review screenshots: iPhone 17 Pro, Dark Mode, `-AppleLanguages "(en)" -AppleLocale en_US`. Always report the exact command used. Use generic builds for compile checks; a concrete simulator only for launch/screenshots/XCTest.

Launch a DEBUG prototype directly (bundle id `app.rork.40gfu7dywfru7n82xfoy4`; flags are the `STRQ*Launch` ProcessInfo arguments in `STRQApp.swift` / `Views/Debug/`) — much faster than clicking through the app:

```sh
xcrun simctl launch "iPhone 17 Pro" app.rork.40gfu7dywfru7n82xfoy4 -STRQOnboardingOpeningMotion -AppleLanguages "(en)" -AppleLocale en_US
```

There is no linter configured (deliberate — SwiftLint default rules produce only style noise on this codebase). CI (`.github/workflows/`) runs the simulator build on push and targeted tests on PRs; inspect runs with `gh run list` / `gh run view` (gh is authenticated).

## Architecture

Targets: `STRQ` (app), `STRQWatch` (watchOS), `STRQWidget` (widgets + Live Activity), `STRQShared` (ActivityKit attributes shared app↔widget), `STRQTests`, `STRQUITests`. SPM dependencies: RevenueCat (`purchases-ios-spm`) and Rive (`rive-ios`).

- **`AppViewModel` (ios/STRQ/ViewModels/AppViewModel.swift, ~2300 lines) is the central runtime contract.** A single `@Observable @MainActor` object owning profile, plan, workout history, active workout, onboarding phase, readiness, coach state. Nearly every screen reads from it. Persisted by `PersistenceStore` to `strq_state_v1.json` — schema, keys, and app-group identifiers are data contracts.
- **`Services/` is the intelligence layer**, not UI helpers: plan generation (`PlanGenerator`), progression/prescription (`ProgressionEngine`, `AdaptivePrescriptionEngine`, `StartingLoadEngine`), coaching (`CoachingCoordinator`, `DailyCoachEngine`, `WeeklyReviewGenerator`), exercise identity/catalog (`ExerciseLibrary*`, `ExerciseIdentity`), sync surfaces (HealthKit, WatchConnectivity, Live Activity, widgets, RevenueCat).
- **DEBUG prototype system:** `STRQApp.swift` branches at launch on `STRQ*Launch` flags (driven by launch arguments, DEBUG-only) into isolated prototype views under `Views/Debug/`. New UI explorations go here first; production integration is a separate, explicitly approved slice.
- **Design system:** `Utilities/STRQDesignSystem.swift` (tokens, components); preview surface in `Views/Debug/STRQDesignSystemPreviewView.swift`.
- **Localization:** `Localizable.xcstrings` + `Localization/L10n.swift` helpers. Product language is English-first, short gym-native copy; German localization only in explicit localization slices.

## Computer-use discipline (Rive, Figma, design reviews)

Long computer-use sessions degrade hard: every screenshot stays in context permanently, so a marathon session (measured: 950 screenshots, 113 MB) spends minutes per turn on context replay, cache misses, and auto-compaction — the model isn't "thinking slowly", it's re-reading hundreds of images. Rules:

- **Delegate long click-sequences to a subagent** (Agent tool). The screenshots pile up in the agent's disposable context; only the findings return to the main session.
- **Batch aggressively**: plan the full action sequence and execute it in one `computer_batch` call. Verify with a screenshot at milestones, not after every micro-action.
- **Prefer keyboard shortcuts** over mouse navigation in Rive/Figma — fewer actions, fewer verification screenshots.
- **Use `zoom` crops** instead of repeated full-screen captures when checking one detail.
- **One work block per session.** When a computer-use phase is done, recommend the owner start a fresh session for the next block instead of continuing a heavy one.

## Hard rules

- **`docs/protected-logic-map.md` lists logic that UI work must not touch**: training/progression algorithms, persistence schema/keys, exercise IDs, analytics event names, RevenueCat/product identifiers, notification routes, HealthKit behavior, app group `group.app.rork.40gfu7dywfru7n82xfoy4`. UI may read state and pass actions through unchanged — never alter the contracts behind them.
- No stage/commit/push without explicit approval.
- UI changes require screenshots for review; classify each task first (plan / implementation / QA / debug-prototype / production integration).
- Don't change production logic while "just polishing UI"; don't integrate a DEBUG prototype into production without an approved plan.
- Avoid: generic analytics dashboards, AI-sounding copy, medical claims, fake precision, score-first hero patterns (unless explicitly approved).
- Evidence (screenshots, QA notes) goes to `docs/qa/<topic>-<date>/`.
