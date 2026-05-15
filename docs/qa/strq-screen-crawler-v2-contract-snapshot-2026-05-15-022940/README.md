# STRQ Screen Map Snapshot - 2026-05-15

## Environment

- Commit: `589cd5d6f7c452404fa58772ce2ea471ea24de6c`
- Xcode: Xcode 26.5 Build version 17F42 
- Simulator: iPhone 17 Pro
- Booted devices: -- iOS 26.5 --     iPhone 17 Pro (2DFD062E-297A-4E7F-9674-2D9EC522AF27) (Booted)  
- Bundle id: `app.rork.40gfu7dywfru7n82xfoy4`
- Build/test result: `xcodebuild test passed`
- Harness: `STRQScreenMapSnapshotTests`
- Contact sheet: `contact-sheet.jpg`
- Screen map: `screen-map.json`
- Screen contract results: `screen-contract-results.json`

## Output

- English screenshots: `18`
- German screenshots: `18`
- English screen records: `18`
- German screen records: `18`
- Missing identifier candidates: `212`
- Forbidden controls observed, not tapped: `14`
- Warnings: `0`
- Scroll positions: `max-depth=16, middle=2, single=2, top=16`
- Contract failures: `0`
- Contract warnings: `22`
- Unknown hittable elements reported: `408`

## Files

- `screenshots/en/`
- `screenshots/de/`
- `screen-map.json`
- `screen-contract-results.json`
- `contact-sheet.jpg`

## Guardrails

- Appium Inspector remains an inspection aid only.
- XCTest remains the capture engine.
- The exporter does not tap purchase, subscribe, restore, reset, sign-in/account, sign out, delete, discard, finish, plan-regeneration, or destructive confirmation controls.
- German sensitive controls such as `Käufe wiederherstellen`, `Plan neu erstellen`, `Alle Daten zurücksetzen`, and `Mit Apple anmelden` are classified with the same never-tap guardrails as the English equivalents.
- Scrollable captures report their bounded position as top, middle, max-depth, bottom-or-repeat, or single.
- Each screen record includes visible scrollable containers for ScrollView, Table, and CollectionView elements.
- Screen contracts hard-fail only for missing required roles, missing expected screenshots, or forbidden/no-go controls misclassified as safe.
- Ambiguous roles, optional missing roles, missing scroll-region identifiers, and unknown hittable elements are reported as warnings.
- Full autonomous click crawling is deferred to a later allowlisted slice.
