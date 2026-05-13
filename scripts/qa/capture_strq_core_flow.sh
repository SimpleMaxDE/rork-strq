#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEVICE_NAME="${STRQ_QA_DEVICE:-iPhone 17 Pro}"
DESTINATION="platform=iOS Simulator,name=${DEVICE_NAME}"
STAMP="$(date +%Y-%m-%d-%H%M%S)"
OUT_DIR="${1:-${ROOT_DIR}/docs/qa/strq-core-flow-snapshot-${STAMP}}"
RESULT_BUNDLE="${OUT_DIR}/STRQCoreFlowSnapshot.xcresult"
ATTACHMENTS_DIR="${OUT_DIR}/attachments"
SCREENSHOTS_DIR="${OUT_DIR}/screenshots"
CONTROL_FILE="/tmp/strq_capture_core_flow_enabled"

mkdir -p "${OUT_DIR}" "${ATTACHMENTS_DIR}" "${SCREENSHOTS_DIR}"
rm -rf "${RESULT_BUNDLE}" "${ATTACHMENTS_DIR}" "${SCREENSHOTS_DIR}"
mkdir -p "${ATTACHMENTS_DIR}" "${SCREENSHOTS_DIR}"
touch "${CONTROL_FILE}"
trap 'rm -f "${CONTROL_FILE}"' EXIT

cd "${ROOT_DIR}"

COMMIT_SHA="$(git rev-parse HEAD)"
XCODE_VERSION="$(xcodebuild -version | tr '\n' ' ')"

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

xcodebuild test \
  -project ios/STRQ.xcodeproj \
  -scheme STRQ \
  -configuration Debug \
  -destination "${DESTINATION}" \
  -only-testing:STRQUITests/STRQCoreFlowSnapshotTests/testCoreFlowSnapshot \
  -resultBundlePath "${RESULT_BUNDLE}" \
  CODE_SIGNING_ALLOWED=NO

xcrun xcresulttool export attachments \
  --path "${RESULT_BUNDLE}" \
  --output-path "${ATTACHMENTS_DIR}"

if [[ -f "${ATTACHMENTS_DIR}/manifest.json" ]] && command -v jq >/dev/null 2>&1; then
  jq -r '.[] | .attachments[] | [.exportedFileName, .suggestedHumanReadableName] | @tsv' "${ATTACHMENTS_DIR}/manifest.json" |
    while IFS=$'\t' read -r exported suggested; do
      source="${ATTACHMENTS_DIR}/${exported}"
      [[ -f "${source}" ]] || continue
      extension="${suggested##*.}"
      stem="${suggested%.*}"
      readable="${stem%%_0_*}.${extension}"
      cp "${source}" "${SCREENSHOTS_DIR}/${readable}"
    done
else
  find "${ATTACHMENTS_DIR}" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -print |
    sort |
    while IFS= read -r image; do
      base="$(basename "${image}")"
      cp "${image}" "${SCREENSHOTS_DIR}/${base}"
    done
fi

swift - "${SCREENSHOTS_DIR}" "${OUT_DIR}/contact-sheet.jpg" <<'SWIFT'
import AppKit
import Foundation

let args = CommandLine.arguments
guard args.count >= 3 else { exit(0) }

let inputURL = URL(fileURLWithPath: args[1])
let outputURL = URL(fileURLWithPath: args[2])
let files = (try? FileManager.default.contentsOfDirectory(at: inputURL, includingPropertiesForKeys: nil))
    ?? []
let images = files
    .filter { ["png", "jpg", "jpeg"].contains($0.pathExtension.lowercased()) }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }

guard !images.isEmpty else { exit(0) }

let columns = 4
let thumbWidth: CGFloat = 260
let labelHeight: CGFloat = 42
let gutter: CGFloat = 18
let rows = Int(ceil(Double(images.count) / Double(columns)))
let canvasWidth = CGFloat(columns) * thumbWidth + CGFloat(columns + 1) * gutter
let canvasHeight = CGFloat(rows) * (thumbWidth * 2.05 + labelHeight) + CGFloat(rows + 1) * gutter

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
    let yTop = gutter + CGFloat(row) * (thumbWidth * 2.05 + labelHeight + gutter)
    let imageHeight = thumbWidth * 2.05
    let y = canvasHeight - yTop - imageHeight

    let rect = NSRect(x: x, y: y, width: thumbWidth, height: imageHeight)
    NSColor(calibratedWhite: 0.10, alpha: 1).setFill()
    NSBezierPath(roundedRect: rect, xRadius: 12, yRadius: 12).fill()

    image.draw(in: rect, from: .zero, operation: .sourceOver, fraction: 1)

    let labelRect = NSRect(x: x, y: y - labelHeight + 7, width: thumbWidth, height: labelHeight - 8)
    url.deletingPathExtension().lastPathComponent.draw(in: labelRect, withAttributes: attributes)
}

canvas.unlockFocus()

guard let tiff = canvas.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let data = bitmap.representation(using: .jpeg, properties: [.compressionFactor: 0.88]) else {
    exit(0)
}

try data.write(to: outputURL)
SWIFT

{
  echo "# STRQ Core Flow Snapshot"
  echo
  echo "- Commit: \`${COMMIT_SHA}\`"
  echo "- Xcode: ${XCODE_VERSION}"
  echo "- Simulator: ${DEVICE_NAME}"
  echo "- Result bundle: \`$(basename "${RESULT_BUNDLE}")\`"
  echo "- Build/test result: \`xcodebuild test passed\`"
  echo "- Attachments: \`attachments/\`"
  echo "- Screenshots: \`screenshots/\`"
  echo "- Contact sheet: \`contact-sheet.jpg\`"
  echo
  echo "## Screenshots"
  echo
  find "${SCREENSHOTS_DIR}" -maxdepth 1 -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" \) -print |
    sort |
    while read -r image; do
      echo "- \`screenshots/$(basename "${image}")\`"
    done
} > "${OUT_DIR}/README.md"

echo "Snapshot artifacts written to: ${OUT_DIR}"
