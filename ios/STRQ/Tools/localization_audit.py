#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
XCSTRINGS_PATH = ROOT / "Localizable.xcstrings"

UI_CONTEXT_TOKENS = [
    "Text(", "Button(", "Label(", "navigationTitle(", "alert(",
    "confirmationDialog(", "Toggle(", "Picker(", "Section(", "TextField(",
    "SecureField(", "Stepper(", "Menu(", "LabeledContent(",
    "ForgeSectionHeader(", "controlRow(", "profileRow(", "statusChip(",
    "proPillarChip(", "selectionChip(", "stepHero(", "fieldGroup(",
]

NON_USER_CONTEXT_TOKENS = [
    "print(", "debugPrint(", "logger.", "os_log", "Analytics.", "ErrorReporter.",
    "NSPredicate(", "URL(", "http://", "https://", "UserDefaults", "forKey:",
    "rawValue", "identifier", "id:", "systemName:", "symbolName:", "imageName:",
    "accessibilityIdentifier(", "fatalError(", "preconditionFailure(",
]

EXCLUDED_PATH_PARTS = {
    "Tools",
    "Tests",
    "Preview Content",
    "Previews",
    "Fixtures",
    "Generated",
}

EXCLUDED_FILE_HINTS = (
    "+Debug", "Debug", "Preview", "Mock", "Stub", "Fixture", "Snapshot", "Harness"
)

STRING_RE = re.compile(r'"([^"\\]*(?:\\.[^"\\]*)*)"')
L10N_KEY_RE = re.compile(r'L10n\.(?:tr|format)\("([^"]+)"')
ENGLISH_CHAR_RE = re.compile(r"[A-Za-z]")


def iter_scoped_files() -> list[Path]:
    files: list[Path] = []
    for path in sorted(ROOT.rglob("*.swift")):
        rel = path.relative_to(ROOT)
        parts = set(rel.parts)
        if parts & EXCLUDED_PATH_PARTS:
            continue
        if any(hint in path.name for hint in EXCLUDED_FILE_HINTS):
            continue
        files.append(path)
    return files


def looks_like_user_facing_english_literal(line: str, literal: str) -> bool:
    text = literal.strip()
    if not text:
        return False

    if "\\(" in text:
        return False

    if any(token in line for token in NON_USER_CONTEXT_TOKENS):
        return False

    if not any(token in line for token in UI_CONTEXT_TOKENS):
        return False

    if not ENGLISH_CHAR_RE.search(text):
        return False

    if re.fullmatch(r"[A-Z0-9_./:-]+", text):
        return False

    if re.fullmatch(r"[%0-9.\-+()/: ]+", text):
        return False

    # Skip single tokens that are likely technical identifiers.
    if " " not in text and text.count("-") == 0 and text.lower() == text and len(text) <= 3:
        return False

    return True


def main() -> int:
    issues: list[tuple[str, int, str]] = []
    l10n_keys: set[str] = set()
    files = iter_scoped_files()

    for path in files:
        rel = path.relative_to(ROOT)
        for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
            for match in L10N_KEY_RE.finditer(line):
                l10n_keys.add(match.group(1))

            if "L10n.tr(" in line or "L10n.format(" in line or "NSLocalizedString(" in line:
                continue

            for match in STRING_RE.finditer(line):
                literal = match.group(1)
                if looks_like_user_facing_english_literal(line, literal):
                    issues.append((str(rel), lineno, literal))

    catalog = json.loads(XCSTRINGS_PATH.read_text(encoding="utf-8"))
    available = set(catalog.get("strings", {}).keys())
    missing_keys = sorted(k for k in l10n_keys if k not in available)

    print(f"Scanned {len(files)} Swift files")
    print(f"Likely user-facing hardcoded English literals: {len(issues)}")
    for rel, lineno, lit in issues[:250]:
        print(f"{rel}:{lineno}: {lit}")

    print(f"Missing L10n keys in Localizable.xcstrings: {len(missing_keys)}")
    for key in missing_keys[:250]:
        print(f"MISSING: {key}")

    return 1 if issues else 0


if __name__ == "__main__":
    raise SystemExit(main())
