# STRQ Pro Preview Snapshot - 2026-05-14

## Environment

- Base commit SHA at capture: `b26bafe12ffb7e90dcde96f75e484208835595ff`
- Working tree: includes local Slice D1 changes under test
- Xcode: Xcode 26.5 Build version 17F42
- Primary simulator/device: iPhone 17 Pro
- Small simulator/device: iPhone 17e
- Build/test result: `xcodebuild test passed`
- Harness: `STRQProPreviewSnapshotTests.testProPreviewSnapshot`, `testPackagePreviewShowsLiveMetadataWithoutPurchasing`, `testProPreviewSmallPhoneSnapshot`, and `testPackagePreviewSmallPhoneSnapshot`
- Contact sheet: `contact-sheet.jpg`

## Screenshots

- `01-profile-pro-card.png`
- `02-pro-preview-top.png`
- `03-pro-preview-lower.png`
- `04-pro-preview-footer-restore.png`
- `05-profile-after-dismiss.png`
- `06-small-iphone-pro-preview-top.png`
- `07-package-preview-live-metadata.png`
- `08-small-iphone-package-preview-top.png`

## Monetization Guardrails

- No-key/unconfigured Pro Preview remains preview-only with no live package UI.
- The default preview XCTest asserts that subscribe, trial, discount, monthly, annual, and price-string UI is absent.
- The package-preview fixture asserts monthly/yearly metadata, legal copy, disabled/internal CTA behavior, and no call to purchase.
- RevenueCat integration, entitlement behavior, purchase behavior, and restore behavior were not changed by this QA harness.
- `StoreViewModel` exposes display-only packages when valid product metadata is available.

## Visual Caveats

- The Profile card and Pro Preview were captured from the deterministic `coreFlow` UI fixture in English.
- The preview footer includes restore access for continuity with the existing screen, but the test does not tap restore.
- The small iPhone capture covers the top Pro Preview viewport only.
