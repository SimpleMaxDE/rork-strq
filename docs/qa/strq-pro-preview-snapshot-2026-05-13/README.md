# STRQ Pro Preview Snapshot - 2026-05-13

## Environment

- Commit SHA tested: `f147c57c075bb0461029e68e72e8ebb0925c4720`
- Xcode: Xcode 26.5 Build version 17F42
- Primary simulator/device: iPhone 17 Pro
- Small simulator/device: iPhone 17e
- Build/test result: `xcodebuild test passed`
- Harness: `STRQProPreviewSnapshotTests.testProPreviewSnapshot` and `testProPreviewSmallPhoneSnapshot`
- Contact sheet: `contact-sheet.jpg`

## Screenshots

- `01-profile-pro-card.png`
- `02-pro-preview-top.png`
- `03-pro-preview-lower.png`
- `04-pro-preview-footer-restore.png`
- `05-profile-after-dismiss.png`
- `06-small-iphone-pro-preview-top.png`

## Monetization Guardrails

- No purchase UI was live in the captured Pro Preview flow.
- The XCTest asserts that subscribe, trial, discount, monthly, annual, and price-string UI is absent.
- RevenueCat integration, entitlement behavior, purchase behavior, and restore behavior were not changed by this QA harness.
- `StoreViewModel` remains the existing stub.

## Visual Caveats

- The Profile card and Pro Preview were captured from the deterministic `coreFlow` UI fixture in English.
- The preview footer includes restore access for continuity with the existing screen, but the test does not tap restore.
- The small iPhone capture covers the top Pro Preview viewport only.
