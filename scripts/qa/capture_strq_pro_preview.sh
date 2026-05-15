#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PRIMARY_DEVICE="${STRQ_QA_DEVICE:-iPhone 17 Pro}"
SMALL_DEVICE="${STRQ_QA_SMALL_DEVICE:-iPhone 17e}"
PRIMARY_DESTINATION="platform=iOS Simulator,name=${PRIMARY_DEVICE}"
SMALL_DESTINATION="platform=iOS Simulator,name=${SMALL_DEVICE}"
RUN_DATE="${STRQ_QA_DATE:-$(date +%F)}"
OUT_DIR="${1:-${ROOT_DIR}/docs/qa/strq-pro-preview-snapshot-${RUN_DATE}}"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/strq-pro-preview.XXXXXX")"
CONTROL_FILE="/tmp/strq_capture_pro_preview_enabled"
BUNDLE_ID="app.rork.40gfu7dywfru7n82xfoy4"

SCREENSHOTS=(
  "01-profile-pro-card.png"
  "02-pro-preview-top.png"
  "03-pro-preview-lower.png"
  "04-pro-preview-footer-restore.png"
  "05-profile-after-dismiss.png"
  "06-small-iphone-pro-preview-top.png"
  "07-package-preview-live-metadata.png"
  "08-small-iphone-package-preview-top.png"
  "09-de-profile-pro-card.png"
  "10-de-pro-preview-top.png"
  "11-de-pro-preview-lower.png"
  "12-de-pro-preview-footer-restore.png"
  "13-de-profile-after-dismiss.png"
  "14-de-small-iphone-pro-preview-top.png"
  "15-de-package-preview-live-metadata.png"
  "16-de-small-iphone-package-preview-top.png"
)

cleanup() {
  rm -f "${CONTROL_FILE}"
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

cd "${ROOT_DIR}"

mkdir -p "${OUT_DIR}"
for screenshot in "${SCREENSHOTS[@]}"; do
  rm -f "${OUT_DIR}/${screenshot}"
done
rm -f "${OUT_DIR}/contact-sheet.jpg" "${OUT_DIR}/README.md"
touch "${CONTROL_FILE}"

COMMIT_SHA="$(git rev-parse HEAD)"
XCODE_VERSION="$(xcodebuild -version | paste -sd ' ' -)"

prepare_simulator() {
  local device="$1"

  xcrun simctl boot "${device}" >/dev/null 2>&1 || true
  xcrun simctl bootstatus "${device}" -b >/dev/null
  xcrun simctl uninstall "${device}" "${BUNDLE_ID}" >/dev/null 2>&1 || true
  xcrun simctl status_bar "${device}" override \
    --time "9:41" \
    --dataNetwork wifi \
    --wifiMode active \
    --wifiBars 3 \
    --cellularMode active \
    --cellularBars 4 \
    --batteryState charged \
    --batteryLevel 100 >/dev/null 2>&1 || true
}

export_attachments() {
  local result_bundle="$1"
  local attachments_dir="$2"

  mkdir -p "${attachments_dir}"
  xcrun xcresulttool export attachments \
    --path "${result_bundle}" \
    --output-path "${attachments_dir}"

  if [[ ! -f "${attachments_dir}/manifest.json" ]]; then
    echo "Missing attachment manifest at ${attachments_dir}/manifest.json" >&2
    return 1
  fi

  jq -r '.[] | .attachments[] | [.exportedFileName, .suggestedHumanReadableName] | @tsv' "${attachments_dir}/manifest.json" |
    while IFS=$'\t' read -r exported suggested; do
      local source="${attachments_dir}/${exported}"
      [[ -f "${source}" ]] || continue

      local extension="${suggested##*.}"
      local stem="${suggested%.*}"
      local readable="${stem%%_0_*}.${extension}"
      cp "${source}" "${OUT_DIR}/${readable}"
    done
}

run_snapshot_test() {
  local destination="$1"
  local test_name="$2"
  local result_name="$3"
  local result_bundle="${TMP_DIR}/${result_name}.xcresult"
  local attachments_dir="${TMP_DIR}/${result_name}-attachments"

  rm -rf "${result_bundle}" "${attachments_dir}"
  xcodebuild test \
    -project ios/STRQ.xcodeproj \
    -scheme STRQ \
    -configuration Debug \
    -destination "${destination}" \
    -only-testing:"STRQUITests/STRQProPreviewSnapshotTests/${test_name}" \
    -resultBundlePath "${result_bundle}" \
    CODE_SIGNING_ALLOWED=NO

  export_attachments "${result_bundle}" "${attachments_dir}"
}

prepare_simulator "${PRIMARY_DEVICE}"
run_snapshot_test "${PRIMARY_DESTINATION}" "testProPreviewSnapshot" "STRQProPreviewPrimary"
run_snapshot_test "${PRIMARY_DESTINATION}" "testGermanProPreviewSnapshot" "STRQProPreviewPrimaryGerman"
run_snapshot_test "${PRIMARY_DESTINATION}" "testPackagePreviewShowsLiveMetadataWithoutPurchasing" "STRQProPackagePreviewPrimary"
run_snapshot_test "${PRIMARY_DESTINATION}" "testGermanPackagePreviewShowsLiveMetadataWithoutPurchasing" "STRQProPackagePreviewPrimaryGerman"

prepare_simulator "${SMALL_DEVICE}"
run_snapshot_test "${SMALL_DESTINATION}" "testProPreviewSmallPhoneSnapshot" "STRQProPreviewSmallPhone"
run_snapshot_test "${SMALL_DESTINATION}" "testGermanProPreviewSmallPhoneSnapshot" "STRQProPreviewSmallPhoneGerman"
run_snapshot_test "${SMALL_DESTINATION}" "testPackagePreviewSmallPhoneSnapshot" "STRQProPackagePreviewSmallPhone"
run_snapshot_test "${SMALL_DESTINATION}" "testGermanPackagePreviewSmallPhoneSnapshot" "STRQProPackagePreviewSmallPhoneGerman"

missing=()
for screenshot in "${SCREENSHOTS[@]}"; do
  if [[ ! -f "${OUT_DIR}/${screenshot}" ]]; then
    missing+=("${screenshot}")
  fi
done

if (( ${#missing[@]} > 0 )); then
  printf 'Missing required screenshots:\n' >&2
  printf -- '- %s\n' "${missing[@]}" >&2
  exit 1
fi

swift - "${OUT_DIR}" "${OUT_DIR}/contact-sheet.jpg" <<'SWIFT'
import AppKit
import Foundation

let args = CommandLine.arguments
guard args.count >= 3 else { exit(0) }

let inputURL = URL(fileURLWithPath: args[1])
let outputURL = URL(fileURLWithPath: args[2])
let files = (try? FileManager.default.contentsOfDirectory(at: inputURL, includingPropertiesForKeys: nil)) ?? []
let images = files
    .filter { $0.pathExtension.lowercased() == "png" }
    .sorted { $0.lastPathComponent < $1.lastPathComponent }

guard !images.isEmpty else { exit(0) }

let columns = 3
let thumbWidth: CGFloat = 280
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
  echo "# STRQ Pro Preview Snapshot - ${RUN_DATE}"
  echo
  echo "## Environment"
  echo
  echo "- Base commit SHA at capture: \`${COMMIT_SHA}\`"
  echo "- Working tree: includes local Slice D1 changes under test"
  echo "- Xcode: ${XCODE_VERSION}"
  echo "- Primary simulator/device: ${PRIMARY_DEVICE}"
  echo "- Small simulator/device: ${SMALL_DEVICE}"
  echo "- Build/test result: \`xcodebuild test passed\`"
  echo "- Harness: English and German \`STRQProPreviewSnapshotTests\` Pro Preview, package-preview, and small-phone snapshots"
  echo "- Contact sheet: \`contact-sheet.jpg\`"
  echo
  echo "## Screenshots"
  echo
  for screenshot in "${SCREENSHOTS[@]}"; do
    echo "- \`${screenshot}\`"
  done
  echo
  echo "## Monetization Guardrails"
  echo
  echo "- No-key/unconfigured Pro Preview remains preview-only with no live package UI."
  echo "- The default preview XCTest asserts that subscribe, trial, discount, monthly, annual, and price-string UI is absent."
  echo "- The package-preview fixture asserts monthly/yearly metadata, legal copy, disabled/internal CTA behavior, and no call to purchase."
  echo "- RevenueCat integration, entitlement behavior, purchase behavior, and restore behavior were not changed by this QA harness."
  echo "- \`StoreViewModel\` exposes display-only packages when valid product metadata is available."
  echo
  echo "## Visual Caveats"
  echo
  echo "- The Profile card and Pro Preview were captured from the deterministic \`coreFlow\` UI fixture in English and German."
  echo "- The preview footer includes restore access for continuity with the existing screen, but the test does not tap restore."
  echo "- The small iPhone Pro Preview captures cover the top viewport only."
} > "${OUT_DIR}/README.md"

echo "STRQ Pro Preview QA artifacts written to: ${OUT_DIR}"
