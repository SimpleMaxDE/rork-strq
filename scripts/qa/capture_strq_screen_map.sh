#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEVICE_NAME="${STRQ_QA_DEVICE:-iPhone 17 Pro}"
DESTINATION="platform=iOS Simulator,name=${DEVICE_NAME}"
RUN_DATE="${STRQ_QA_DATE:-$(date +%F)}"
OUT_DIR="${1:-${ROOT_DIR}/docs/qa/strq-screen-map-snapshot-${RUN_DATE}}"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/strq-screen-map.XXXXXX")"
CONTROL_FILE="/tmp/strq_capture_screen_map_enabled"
BUNDLE_ID="app.rork.40gfu7dywfru7n82xfoy4"
RESULT_BUNDLE="${TMP_DIR}/STRQScreenMapSnapshot.xcresult"
ATTACHMENTS_DIR="${TMP_DIR}/attachments"

cleanup() {
  rm -f "${CONTROL_FILE}"
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

cd "${ROOT_DIR}"

mkdir -p "${OUT_DIR}/screenshots/en" "${OUT_DIR}/screenshots/de"
rm -rf "${OUT_DIR}/screenshots/en" "${OUT_DIR}/screenshots/de"
mkdir -p "${OUT_DIR}/screenshots/en" "${OUT_DIR}/screenshots/de"
rm -f "${OUT_DIR}/screen-map.json" "${OUT_DIR}/screen-map-en.json" "${OUT_DIR}/screen-map-de.json" "${OUT_DIR}/contact-sheet.jpg" "${OUT_DIR}/README.md"
touch "${CONTROL_FILE}"

COMMIT_SHA="$(git rev-parse HEAD)"
XCODE_VERSION="$(xcodebuild -version | tr '\n' ' ')"
BOOTED_DEVICES="$(xcrun simctl list devices booted | sed -n '/-- iOS/,/-- watchOS/p' | sed '/-- watchOS/d' | tr '\n' ' ')"

xcrun simctl boot "${DEVICE_NAME}" >/dev/null 2>&1 || true
xcrun simctl bootstatus "${DEVICE_NAME}" -b >/dev/null
xcrun simctl status_bar "${DEVICE_NAME}" override \
  --time "9:41" \
  --dataNetwork wifi \
  --wifiMode active \
  --wifiBars 3 \
  --cellularMode active \
  --cellularBars 4 \
  --batteryState charged \
  --batteryLevel 100 >/dev/null 2>&1 || true

rm -rf "${RESULT_BUNDLE}" "${ATTACHMENTS_DIR}"
xcodebuild test \
  -project ios/STRQ.xcodeproj \
  -scheme STRQ \
  -configuration Debug \
  -destination "${DESTINATION}" \
  -only-testing:STRQUITests/STRQScreenMapSnapshotTests \
  -resultBundlePath "${RESULT_BUNDLE}" \
  CODE_SIGNING_ALLOWED=NO

mkdir -p "${ATTACHMENTS_DIR}"
xcrun xcresulttool export attachments \
  --path "${RESULT_BUNDLE}" \
  --output-path "${ATTACHMENTS_DIR}"

if [[ ! -f "${ATTACHMENTS_DIR}/manifest.json" ]]; then
  echo "Missing attachment manifest at ${ATTACHMENTS_DIR}/manifest.json" >&2
  exit 1
fi

jq -r '.[] | .attachments[] | [.exportedFileName, .suggestedHumanReadableName] | @tsv' "${ATTACHMENTS_DIR}/manifest.json" |
  while IFS=$'\t' read -r exported suggested; do
    source="${ATTACHMENTS_DIR}/${exported}"
    [[ -f "${source}" ]] || continue

    extension="${suggested##*.}"
    stem="${suggested%.*}"
    readable="${stem%%_0_*}.${extension}"

    case "${readable}" in
      screen-map-en.json)
        cp "${source}" "${OUT_DIR}/screen-map-en.json"
        ;;
      screen-map-de.json)
        cp "${source}" "${OUT_DIR}/screen-map-de.json"
        ;;
      en-*.png)
        cp "${source}" "${OUT_DIR}/screenshots/en/${readable#en-}"
        ;;
      de-*.png)
        cp "${source}" "${OUT_DIR}/screenshots/de/${readable#de-}"
        ;;
    esac
  done

if [[ ! -f "${OUT_DIR}/screen-map-en.json" ]]; then
  echo "Missing English screen map JSON attachment." >&2
  exit 1
fi

if [[ ! -f "${OUT_DIR}/screen-map-de.json" ]]; then
  echo "Missing German screen map JSON attachment." >&2
  exit 1
fi

if ! find "${OUT_DIR}/screenshots" -type f -name '*.png' -print -quit | grep -q .; then
  echo "No screenshots were exported." >&2
  exit 1
fi

jq -n \
  --arg generatedAt "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg commit "${COMMIT_SHA}" \
  --arg xcode "${XCODE_VERSION}" \
  --arg simulator "${DEVICE_NAME}" \
  --arg booted "${BOOTED_DEVICES}" \
  --slurpfile en "${OUT_DIR}/screen-map-en.json" \
  --slurpfile de "${OUT_DIR}/screen-map-de.json" \
  '{
    schemaVersion: 1,
    generatedAt: $generatedAt,
    commit: $commit,
    xcode: $xcode,
    simulator: $simulator,
    bootedDevices: $booted,
    appBundleId: "app.rork.40gfu7dywfru7n82xfoy4",
    maps: {
      en: $en[0],
      de: $de[0]
    }
  }' > "${OUT_DIR}/screen-map.json"

swift - "${OUT_DIR}/screenshots" "${OUT_DIR}/contact-sheet.jpg" <<'SWIFT'
import AppKit
import Foundation

let args = CommandLine.arguments
guard args.count >= 3 else { exit(0) }

let inputURL = URL(fileURLWithPath: args[1])
let outputURL = URL(fileURLWithPath: args[2])
let enumerator = FileManager.default.enumerator(at: inputURL, includingPropertiesForKeys: nil)
let files = (enumerator?.compactMap { $0 as? URL } ?? [])
let images = files
    .filter { $0.pathExtension.lowercased() == "png" }
    .sorted { $0.path < $1.path }

guard !images.isEmpty else { exit(0) }

let columns = 4
let thumbWidth: CGFloat = 260
let imageHeight: CGFloat = thumbWidth * 2.05
let labelHeight: CGFloat = 42
let gutter: CGFloat = 18
let rows = Int(ceil(Double(images.count) / Double(columns)))
let canvasWidth = CGFloat(columns) * thumbWidth + CGFloat(columns + 1) * gutter
let canvasHeight = CGFloat(rows) * (imageHeight + labelHeight) + CGFloat(rows + 1) * gutter

let canvas = NSImage(size: NSSize(width: canvasWidth, height: canvasHeight))
canvas.lockFocus()

NSColor(calibratedWhite: 0.055, alpha: 1).setFill()
NSBezierPath(rect: NSRect(x: 0, y: 0, width: canvasWidth, height: canvasHeight)).fill()

let paragraph = NSMutableParagraphStyle()
paragraph.alignment = .center
paragraph.lineBreakMode = .byTruncatingTail
let attributes: [NSAttributedString.Key: Any] = [
    .font: NSFont.systemFont(ofSize: 12, weight: .semibold),
    .foregroundColor: NSColor(calibratedWhite: 0.88, alpha: 1),
    .paragraphStyle: paragraph
]

for (index, url) in images.enumerated() {
    guard let image = NSImage(contentsOf: url) else { continue }

    let column = index % columns
    let row = index / columns
    let x = gutter + CGFloat(column) * (thumbWidth + gutter)
    let yTop = gutter + CGFloat(row) * (imageHeight + labelHeight + gutter)
    let y = canvasHeight - yTop - imageHeight
    let rect = NSRect(x: x, y: y, width: thumbWidth, height: imageHeight)

    NSColor(calibratedWhite: 0.10, alpha: 1).setFill()
    NSBezierPath(roundedRect: rect, xRadius: 12, yRadius: 12).fill()
    image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)

    let locale = url.deletingLastPathComponent().lastPathComponent
    let label = "\(locale)/\(url.deletingPathExtension().lastPathComponent)"
    let labelRect = NSRect(x: x, y: y - labelHeight + 7, width: thumbWidth, height: labelHeight - 8)
    label.draw(in: labelRect, withAttributes: attributes)
}

canvas.unlockFocus()

guard let tiff = canvas.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let data = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.88]) else {
    exit(0)
}

try data.write(to: outputURL)
SWIFT

EN_SCREENSHOT_COUNT="$(find "${OUT_DIR}/screenshots/en" -type f -name '*.png' | wc -l | tr -d ' ')"
DE_SCREENSHOT_COUNT="$(find "${OUT_DIR}/screenshots/de" -type f -name '*.png' | wc -l | tr -d ' ')"
EN_SCREEN_COUNT="$(jq '.maps.en.screens | length' "${OUT_DIR}/screen-map.json")"
DE_SCREEN_COUNT="$(jq '.maps.de.screens | length' "${OUT_DIR}/screen-map.json")"
MISSING_ID_COUNT="$(jq '[.maps.en.screens[].missingIdentifierCandidates[], .maps.de.screens[].missingIdentifierCandidates[]] | length' "${OUT_DIR}/screen-map.json")"
FORBIDDEN_COUNT="$(jq '[.maps.en.screens[].elements[], .maps.de.screens[].elements[] | select(.safeAction == "forbidden")] | length' "${OUT_DIR}/screen-map.json")"

{
  echo "# STRQ Screen Map Snapshot - ${RUN_DATE}"
  echo
  echo "## Environment"
  echo
  echo "- Commit: \`${COMMIT_SHA}\`"
  echo "- Xcode: ${XCODE_VERSION}"
  echo "- Simulator: ${DEVICE_NAME}"
  echo "- Booted devices: ${BOOTED_DEVICES}"
  echo "- Bundle id: \`${BUNDLE_ID}\`"
  echo "- Build/test result: \`xcodebuild test passed\`"
  echo "- Harness: \`STRQScreenMapSnapshotTests\`"
  echo "- Contact sheet: \`contact-sheet.jpg\`"
  echo "- Screen map: \`screen-map.json\`"
  echo
  echo "## Output"
  echo
  echo "- English screenshots: \`${EN_SCREENSHOT_COUNT}\`"
  echo "- German screenshots: \`${DE_SCREENSHOT_COUNT}\`"
  echo "- English screen records: \`${EN_SCREEN_COUNT}\`"
  echo "- German screen records: \`${DE_SCREEN_COUNT}\`"
  echo "- Missing identifier candidates: \`${MISSING_ID_COUNT}\`"
  echo "- Forbidden controls observed, not tapped: \`${FORBIDDEN_COUNT}\`"
  echo
  echo "## Files"
  echo
  echo "- \`screenshots/en/\`"
  echo "- \`screenshots/de/\`"
  echo "- \`screen-map.json\`"
  echo "- \`contact-sheet.jpg\`"
  echo
  echo "## Guardrails"
  echo
  echo "- Appium Inspector remains an inspection aid only."
  echo "- XCTest remains the capture engine."
  echo "- The exporter does not tap purchase, restore, reset, sign out, delete, discard, finish, or destructive confirmation controls."
  echo "- Full autonomous click crawling is deferred to a later allowlisted slice."
} > "${OUT_DIR}/README.md"

echo "Screen Map artifacts written to: ${OUT_DIR}"
