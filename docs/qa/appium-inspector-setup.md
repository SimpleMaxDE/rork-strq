# STRQ Appium Inspector Setup

Appium Inspector is a visual inspection aid for STRQ simulator QA. It is not the screenshot crawler and it is not the source of truth for automated captures. The permanent capture engine remains XCTest.

## Install

```bash
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

command -v npm >/dev/null || brew install node
npm install -g appium
appium driver install xcuitest
appium driver list --installed
brew install --cask appium-inspector
```

Notes:

- The Appium XCUITest driver is installed through the Appium extension CLI.
- The Appium Inspector Homebrew cask is convenient but community supported. If the cask is unavailable, install the macOS DMG from the Appium Inspector GitHub releases page.
- Homebrew currently warns that the Appium Inspector cask does not pass the macOS Gatekeeper check and is deprecated from Homebrew's perspective. STRQ still treats it as a local inspection aid only.
- Do not use OSAScript for STRQ simulator QA.

Verified local setup on 2026-05-14:

- Node: `v26.0.0`
- npm: `11.12.1`
- Appium: `3.4.2`
- Appium XCUITest driver: `xcuitest@11.4.0`
- Appium Inspector cask: `2026.5.1`

## Preflight

```bash
xcode-select -p
xcodebuild -version
xcrun simctl list devices booted
appium --version
appium driver list --installed
mdfind 'kMDItemFSName == "Appium Inspector.app"'
```

STRQ simulator defaults from the current QA environment:

- Bundle id: `app.rork.40gfu7dywfru7n82xfoy4`
- Primary simulator: `iPhone 17 Pro`
- Current iOS: `26.5`

Prefer the booted simulator UDID reported by:

```bash
xcrun simctl list devices booted
```

## Launch Appium

Start the server in a terminal:

```bash
appium --address 127.0.0.1 --port 4723 --base-path /
```

Open Appium Inspector and create a session with:

- Remote host: `127.0.0.1`
- Remote port: `4723`
- Remote path: `/`
- SSL: off

Capabilities:

```json
{
  "platformName": "iOS",
  "appium:automationName": "XCUITest",
  "appium:deviceName": "iPhone 17 Pro",
  "appium:platformVersion": "26.5",
  "appium:udid": "2DFD062E-297A-4E7F-9674-2D9EC522AF27",
  "appium:bundleId": "app.rork.40gfu7dywfru7n82xfoy4",
  "appium:noReset": true,
  "appium:newCommandTimeout": 120
}
```

Replace `appium:udid` and `appium:platformVersion` with the current booted simulator values when they change.

## How To Use It

Use Appium Inspector to answer inspection questions:

- Which visible controls have identifiers?
- Which controls are hittable?
- Which labels are exposed to automation?
- Which overlays block taps?
- Which views are scrollable?

Use XCTest for capture automation:

- deterministic fixture launch
- screenshot export
- screen-map JSON
- contact sheets
- CI-compatible pass/fail gates

## Guardrails

Safe to inspect:

- tabs
- non-destructive sheets
- search fields
- filters
- detail views
- close, back, cancel, done controls

Do not execute:

- purchase or subscribe
- restore purchases
- reset all data
- sign out
- delete
- discard workout
- finish workout
- destructive confirmations

## References

- Appium Inspector installation: https://appium.github.io/appium-inspector/latest/quickstart/installation/
- Appium XCUITest setup: https://appium.github.io/appium-xcuitest-driver/4.35/setup/
- Appium extension CLI: https://appium.io/docs/en/2.4/guides/managing-exts/
- XCUITest capabilities: https://appium.github.io/appium-xcuitest-driver/latest/reference/capabilities/
