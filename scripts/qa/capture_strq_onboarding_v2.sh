#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PRIMARY_DEVICE="${STRQ_QA_DEVICE:-iPhone 17 Pro}"
SMALL_DEVICE="${STRQ_QA_SMALL_DEVICE:-iPhone 17e}"
PRIMARY_DESTINATION="platform=iOS Simulator,name=${PRIMARY_DEVICE}"
SMALL_DESTINATION="platform=iOS Simulator,name=${SMALL_DEVICE}"
OUT_DIR="${1:-${ROOT_DIR}/docs/qa/strq-onboarding-v2-2026-05-13}"
TMP_DIR="$(mktemp -d "${TMPDIR:-/tmp}/strq-onboarding-v2.XXXXXX")"
CONTROL_FILE="/tmp/strq_capture_onboarding_v2_enabled"
BUNDLE_ID="app.rork.40gfu7dywfru7n82xfoy4"

REQUIRED_SCREENSHOTS=(
  "00-welcome.png"
  "01-about-name-empty-or-validation.png"
  "02-about-name-filled.png"
  "03-goal.png"
  "04-training.png"
  "05-setup-equipment.png"
  "06-focus.png"
  "07-lifestyle-final-cta.png"
  "08-generation.png"
  "09-reveal.png"
  "10-small-iphone-welcome.png"
  "11-small-iphone-dense-step.png"
)

SUPPLEMENTAL_SCREENSHOTS=(
  "04-training-lower.png"
  "05-setup-equipment-lower.png"
  "07-lifestyle-final-cta-lower.png"
)

cleanup() {
  rm -f "${CONTROL_FILE}"
  rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

cd "${ROOT_DIR}"

mkdir -p "${OUT_DIR}"
for screenshot in "${REQUIRED_SCREENSHOTS[@]}" "${SUPPLEMENTAL_SCREENSHOTS[@]}"; do
  rm -f "${OUT_DIR}/${screenshot}"
done
find "${OUT_DIR}" -maxdepth 1 -name 'matrix-*.png' -delete
rm -f "${OUT_DIR}/00-welcome-iphone-17e.png"
rm -f "${OUT_DIR}/contact-sheet.jpg" "${OUT_DIR}/README.md"
touch "${CONTROL_FILE}"

COMMIT_SHA="$(git rev-parse HEAD)"
XCODE_VERSION="$(xcodebuild -version | tr '\n' ' ')"

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
    -only-testing:"STRQUITests/STRQCoreFlowSnapshotTests/${test_name}" \
    -resultBundlePath "${result_bundle}" \
    CODE_SIGNING_ALLOWED=NO

  export_attachments "${result_bundle}" "${attachments_dir}"
}

prepare_simulator "${PRIMARY_DEVICE}"
run_snapshot_test "${PRIMARY_DESTINATION}" "testOnboardingFlowSnapshot" "STRQOnboardingV2Primary"
run_snapshot_test "${PRIMARY_DESTINATION}" "testOnboardingMatrixSnapshot" "STRQOnboardingV2Matrix"

prepare_simulator "${SMALL_DEVICE}"
run_snapshot_test "${SMALL_DESTINATION}" "testOnboardingSmallPhoneSnapshot" "STRQOnboardingV2SmallPhone"

missing=()
for screenshot in "${REQUIRED_SCREENSHOTS[@]}"; do
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
  echo "# STRQ Onboarding V2 QA"
  echo
  echo "- Commit at capture: \`${COMMIT_SHA}\`"
  echo "- Xcode: ${XCODE_VERSION}"
  echo "- Primary simulator: ${PRIMARY_DEVICE}"
  echo "- Small simulator: ${SMALL_DEVICE}"
  echo "- Build/test result: \`xcodebuild test passed\`"
  echo "- Harness: \`STRQCoreFlowSnapshotTests.testOnboardingFlowSnapshot\`, \`testOnboardingMatrixSnapshot\`, and \`testOnboardingSmallPhoneSnapshot\`"
  echo "- Contact sheet: \`contact-sheet.jpg\`"
  echo
  echo "## Required Screenshots"
  echo
  for screenshot in "${REQUIRED_SCREENSHOTS[@]}"; do
    echo "- \`${screenshot}\`"
  done
  echo
  echo "## Supplemental Scroll Checks"
  echo
  for screenshot in "${SUPPLEMENTAL_SCREENSHOTS[@]}"; do
    echo "- \`${screenshot}\`"
  done
  echo
  echo "## Matrix Screenshots"
  echo
  matrix_count="$(find "${OUT_DIR}" -maxdepth 1 -name 'matrix-*.png' | wc -l | tr -d ' ')"
  echo "- Count: \`${matrix_count}\`"
  find "${OUT_DIR}" -maxdepth 1 -name 'matrix-*.png' -print | sort | while read -r matrix_file; do
    echo "- \`$(basename "${matrix_file}")\`"
  done
  echo
  echo "## QA Checklist"
  echo
  echo "- Name-only validation: covered by XCTest."
  echo "- All onboarding steps and fields: covered by XCTest label assertions plus scroll screenshots on dense steps."
  echo "- Clickable onboarding choices: covered by the matrix harness where identifiers are available in \`OnboardingView.swift\`."
  echo "- Final CTA enters PlanGenerationView: covered by XCTest."
  echo "- PlanRevealView appears: covered by XCTest."
  echo "- Paywall/pricing/locked-premium copy: covered by XCTest label assertions."
  echo "- Visual clipping/overlap/readability: manual review of screenshots required."
} > "${OUT_DIR}/README.md"

echo "Onboarding V2 QA artifacts written to: ${OUT_DIR}"
