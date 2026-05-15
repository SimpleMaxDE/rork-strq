# STRQ Screen Map Exporter

The Screen Map exporter is a reusable XCTest QA harness that records what STRQ exposes to automation on each important screen. It complements visual snapshots by reporting identifiers, labels, hittability, frames, scroll containers, and unsafe controls.

## Slice C Scope

This slice adds the first stable exporter. It does not add a full autonomous click crawler.

Implemented surfaces:

- Today
- Coach
- Train
- Train options menu when available
- Exercise Library from the Train menu when available
- Progress
- Profile
- STRQ Pro Preview from the Profile card when available

Implemented output:

- screenshots grouped by locale
- `screen-map.json`
- `screen-contract-results.json`
- `contact-sheet.jpg`
- run `README.md`

## Screen Crawler V2 Contract Layer

Screen Crawler V2 adds a contract evaluator on top of the existing Screen Map exporter. It evaluates the already-captured `ScreenMapManifest` data only; it does not add taps, gestures, routes, navigation depth, or product accessibility identifiers.

Contracts live at:

- `docs/qa/strq-screen-contracts/strq-screen-contracts.v1.json`

Each screen contract can define:

- screen name
- supported locales
- allowed navigation depth
- required semantic roles
- optional semantic roles
- safe actions
- forbidden actions
- scroll regions
- expected screenshots
- no-go labels / forbidden labels

Initial contracts are intentionally minimal and high-confidence. Hard failures are limited to:

- required roles missing
- expected screenshots missing
- forbidden, destructive, purchase, auth, or no-go controls classified as safe

Warnings report:

- optional roles missing
- ambiguous roles
- missing scroll-region identifiers
- unknown hittable elements

Unknown hittable elements do not fail the run unless they match forbidden, destructive, purchase, or auth rules and are misclassified as safe.

## Data Shape

`screen-map.json` contains:

- run metadata: schema version, commit, Xcode, simulator, generated time
- locale maps for English and German where the run succeeds
- per-screen screenshots
- per-screen element records:
  - identifier
  - label
  - value
  - placeholder
  - element type
  - frame
  - enabled
  - selected
  - hittable
  - visible
  - safe action classification
- scroll containers
- missing identifier candidates
- warnings for optional screens that could not be opened

`screen-contract-results.json` contains:

- locale-level pass/fail
- per-screen pass/fail
- passed roles
- missing required roles
- ambiguous roles
- optional missing roles
- forbidden controls found
- unsafe elements skipped
- unknown hittable elements
- screenshot coverage
- scroll-region coverage
- localization issues
- warnings

`hittable` is an exporter-safe viewport tap-point estimate in this slice. The test intentionally does not call `XCUIElement.isHittable` while enumerating every element, because XCTest can record a failure when that property is evaluated on some invalid or offscreen activation frames. Use Appium Inspector for exact blocked-overlay debugging, and use the exporter for repeatable inventory and screenshots.

Safe action classifications:

- `allowedTap`: known safe navigation, close, cancel, search, filter, or detail entry
- `forbidden`: purchase, restore, reset, delete, sign out, discard, finish, or destructive control
- `observeOnly`: visible element should be documented but not tapped by the exporter
- `none`: non-control element

V2 contract result classifications are contract-facing:

- `safeTap`: future explicit contract allowlist; current exporter data may still call these `allowedTap`
- `observeOnly`: visible controls useful for QA but not tapped
- `forbidden`: generic never-tap match
- `destructive`: reset, delete, discard, finish, or regenerate
- `purchase`: subscribe, buy, restore, or purchase
- `auth`: sign in / sign out controls
- `unknown`: hittable controls not covered by a contract

The evaluator treats current `allowedTap` and future `safeTap` as safe classifications for hard-fail safety checks.

## Interaction Rules

Allowed interactions:

- tab navigation
- small vertical scrolls
- opening non-destructive sheets/details
- search field focus/type/clear
- menu inspection
- close, back, cancel, done

Forbidden interactions:

- purchase or subscribe
- restore purchase execution
- reset data
- sign out
- delete
- discard workout
- finish workout
- destructive confirmation

Destructive controls may appear in `screen-map.json` as `forbidden`, but the exporter must not tap them.

`action-map.json` is intentionally deferred. A later slice can generate it after contracts and forbidden classification have another stable snapshot behind them.

## Command

```bash
scripts/qa/capture_strq_screen_map.sh docs/qa/strq-screen-map-snapshot-$(date +%F)
```

The script is opt-in and creates `/tmp/strq_capture_screen_map_enabled` only for the duration of the run.

## Verification

```bash
xcodebuild -project ios/STRQ.xcodeproj -scheme STRQ -configuration Debug -sdk iphonesimulator -destination 'generic/platform=iOS Simulator' CODE_SIGNING_ALLOWED=NO build
xcodebuild test -project ios/STRQ.xcodeproj -scheme STRQ -configuration Debug -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -only-testing:STRQUITests/STRQScreenMapSnapshotTests CODE_SIGNING_ALLOWED=NO
scripts/qa/capture_strq_screen_map.sh docs/qa/strq-screen-map-snapshot-$(date +%F)
jq empty docs/qa/strq-screen-map-snapshot-$(date +%F)/screen-map.json
jq empty docs/qa/strq-screen-map-snapshot-$(date +%F)/screen-contract-results.json
jq -e '[.results[].screens[] | select(.passed != true)] | length == 0' docs/qa/strq-screen-map-snapshot-$(date +%F)/screen-contract-results.json
git diff --check
```

## Next Slice

After contracts are stable, the next slice can either deepen contract coverage or add controlled scroll-region metadata. A depth-1 allowlisted action-map crawler should remain deferred until the contract surface and forbidden classifier have another clean snapshot run.
