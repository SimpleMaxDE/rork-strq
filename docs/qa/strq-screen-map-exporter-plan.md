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
- `contact-sheet.jpg`
- run `README.md`

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

`hittable` is an exporter-safe viewport tap-point estimate in this slice. The test intentionally does not call `XCUIElement.isHittable` while enumerating every element, because XCTest can record a failure when that property is evaluated on some invalid or offscreen activation frames. Use Appium Inspector for exact blocked-overlay debugging, and use the exporter for repeatable inventory and screenshots.

Safe action classifications:

- `allowedTap`: known safe navigation, close, cancel, search, filter, or detail entry
- `forbidden`: purchase, restore, reset, delete, sign out, discard, finish, or destructive control
- `observeOnly`: visible element should be documented but not tapped by the exporter
- `none`: non-control element

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
git diff --check
```

## Next Slice

After the exporter is stable, the next slice can add an allowlisted click graph crawler. That crawler should reuse the same safe action classification and only tap elements classified as safe.
