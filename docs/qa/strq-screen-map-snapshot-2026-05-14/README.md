# STRQ Screen Map Snapshot - 2026-05-14

## Environment

- Commit: `3dd0979f9233f936d931027b19b896994f3333b1`
- Xcode: Xcode 26.5 Build version 17F42 
- Simulator: iPhone 17 Pro
- Booted devices: -- iOS 26.5 --     iPhone 17 Pro (2DFD062E-297A-4E7F-9674-2D9EC522AF27) (Booted)  
- Bundle id: `app.rork.40gfu7dywfru7n82xfoy4`
- Build/test result: `xcodebuild test passed`
- Harness: `STRQScreenMapSnapshotTests`
- Contact sheet: `contact-sheet.jpg`
- Screen map: `screen-map.json`

## Output

- English screenshots: `16`
- German screenshots: `16`
- English screen records: `16`
- German screen records: `16`
- Missing identifier candidates: `400`
- Forbidden controls observed, not tapped: `7`

## Files

- `screenshots/en/`
- `screenshots/de/`
- `screen-map.json`
- `contact-sheet.jpg`

## Guardrails

- Appium Inspector remains an inspection aid only.
- XCTest remains the capture engine.
- The exporter does not tap purchase, restore, reset, sign out, delete, discard, finish, or destructive confirmation controls.
- Full autonomous click crawling is deferred to a later allowlisted slice.
