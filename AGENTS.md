# STRQ Codex Instructions

STRQ is an iOS fitness and strength app aiming for App-of-the-Year-level quality by 2027. The product should feel premium, calm, gym-native, focused, data-based, and emotionally strong. The engine may be science-based; the UI should not sound scientific.

User and ChatGPT are the final product, design, and language judges. Codex implements, audits, reads the repo, runs builds/tests, captures screenshots, and proposes plans. Codex is not the final design judge.

## Default Task Discipline

Classify every task first:
- Plan only
- Implementation
- QA only
- Debug/prototype
- Production integration
- Goal Mode task

Before work:
- Confirm repo root and active branch.
- Run `git status --short`.
- Identify allowed and forbidden files.
- Confirm there is no stage/commit/push permission unless explicitly granted.
- For UI work, confirm the screenshot plan before coding.

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

## Product Rules

STRQ must avoid generic analytics dashboards, AI-sounding explanations, medical claims, fake precision, score-first hero patterns unless explicitly approved, broad redesigns without prototype approval, and production logic changes while "just polishing UI."

Main product language is English-first. Use short, direct, gym-native English for new product surfaces. German localization comes later in explicit localization slices.

Codex may propose safer alternatives, recommend Agent/Mobbin/Figma research, recommend a DEBUG prototype before Production, split risky work into smaller slices, stop on blockers, ask for screenshots, or propose deleting/rebuilding a weak surface when justified.

Codex must not silently broaden scope, rewrite models/persistence/analytics without explicit permission, treat build success as product approval, call a surface App-of-the-Year-ready without user/ChatGPT review, or use screenshots as final taste judgement.

## STRQ Project Defaults

- Repo: `rork-strq`
- iOS project: `ios/STRQ.xcodeproj`
- Scheme: `STRQ`
- Default configuration: `Debug`
- Preferred simulator: `iPhone 17 Pro Max`, iOS 26.5 when available
- Small-device screenshot simulator: `iPhone 17e` when available
- Default compile check:

```sh
xcodebuild -project ios/STRQ.xcodeproj -scheme STRQ -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
```

Use generic builds for compile checks. Use a concrete simulator for launch, screenshots, and XCTest. Always report the exact command used.

## UI And Progress Rules

UI approval requires screenshots; a build is not product approval. Judge screenshots for 10-second clarity, premium feel, clear next action, believable data, human/gym-native copy, no fake precision, and fit with accepted STRQ visual direction.

Current approved DEBUG Progress direction: `Progress`, optional `Training Path` subtitle, this-week path visual, state headline, proof strip, one Next Move, lower sections `Confirmed / Building / Needs More / Recent Work / Next Move`, English-first, no abstract node map.

Production Progress is blocked until an explicit production integration plan is approved. The first production slice should likely be P1 First Viewport only: Hero State, This Week Path, Proof Strip, and Next Move using only reliable production data. Do not integrate all 12 DEBUG states into production at once.

For the full operating system, read `docs/qa/strq-codex-operating-rules-2026-05-24.md`.
