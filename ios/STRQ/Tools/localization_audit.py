#!/usr/bin/env python3
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
XCSTRINGS_PATH = ROOT / "Localizable.xcstrings"

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

UI_CONTEXT_TOKENS = [
    "Text(", "Button(", "Label(", "navigationTitle(", "alert(",
    "confirmationDialog(", "Toggle(", "Picker(", "Section(", "TextField(",
    "SecureField(", "Stepper(", "Menu(", "LabeledContent(",
    "ForgeSectionHeader(", "controlRow(", "profileRow(", "statusChip(",
    "proPillarChip(", "selectionChip(", "stepHero(", "fieldGroup(",
]

GENERATED_COPY_CONTEXT_TOKENS = [
    "title:", "explanation:", "coachNote:", "reason:",
    "displayName:", "description:", "optimizingFor:", "expectedIntensityLabel:",
]

GENERATED_COPY_INITIALIZERS = [
    "NextBestAction(",
    "ExerciseProgressionState(",
]

GENERATED_COPY_PROPERTY_RE = re.compile(
    r"\bvar\s+(displayName|description|optimizingFor|expectedIntensityLabel)\s*:\s*String\b"
)
GENERATED_COPY_FUNCTION_RE = re.compile(
    r"\bfunc\s+(determineTrainingPhase|computeNextBestAction|generateCoachNote|suggestNext)\b"
)
INTERPOLATION_RE = re.compile(r"\\\([^)]*\)")
GENERATED_COPY_FILE_NAMES = {
    "ProgressionState.swift",
    "ProgressionEngine.swift",
}

NON_USER_CONTEXT_TOKENS = [
    "print(", "debugPrint(", "logger.", "os_log", "Analytics.", "ErrorReporter.",
    "NSPredicate(", "URL(", "http://", "https://", "UserDefaults", "forKey:",
    "rawValue", "identifier", "id:", "systemName:", "symbolName:", "imageName:",
    "accessibilityIdentifier(", "fatalError(", "preconditionFailure(", "icon:",
    "colorName:",
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
    "+Debug", "Debug", "Preview", "Mock", "Stub", "Fixture", "Snapshot", "Harness", "Diagnostics"
)

# Terms commonly unchanged in German product copy.
IDENTICAL_DE_ALLOWLIST = {
    "STRQ",
    "STRQ Pro",
    "PR",
    "RPE",
    "kg",
    "kcal",
    "min",
    "Push",
    "Pull",
    "Push A",
    "Push B",
    "Pull A",
    "Pull B",
    "Auto",
    "BW",
    "EX %d/%d",
    "Motivation",
    "OK",
    "OPTIONAL",
    "Optional",
    "PRO",
    "Protein",
    "REPS",
    "RPE %@",
    "Rehabilitation",
    "STRQ PRO",
    "Standard",
    "Stress",
    "e1RM %.0f",
    "vs %@",
    "~%dm",
    "× %d · e1RM %d",
    "≥ 7h",
    "< 7h",
    "%.0f kg",
    "%.1f kg",
    "%@ · %@ × %d",
    "%@%.0f kg",
    "%@%.0f%%",
    "%@kg",
    "%d",
    "%d %@",
    "%d %@ · %d %@",
    "%d cm",
    "%d kcal",
    "%dg",
    "%dkg × %d",
    "%dm",
    "%dmin",
    "%dw",
    "%dwk",
    " — %@",
}

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


def looks_like_user_facing_english_literal(line: str, literal: str, generated_context: bool = False) -> bool:
    text = literal.strip()
    if not text:
        return False

    if "\\(" in text:
        if not generated_context:
            return False
        text = INTERPOLATION_RE.sub(" ", text).strip()
        if not text:
            return False

    if any(token in line for token in NON_USER_CONTEXT_TOKENS):
        return False

    if not generated_context and not any(token in line for token in UI_CONTEXT_TOKENS):
        return False

    if not ENGLISH_CHAR_RE.search(text):
        return False

    if not generated_context and ("%" in text or "%@" in text):
        return False

    if not generated_context and ("))" in text or "\\(" in text):
        return False

    if re.fullmatch(r"[A-Z0-9_./:-]+", text):
        return False

    if re.fullmatch(r"[%0-9.\-+()/: ]+", text):
        return False

    if re.fullmatch(r"[a-z0-9]+(?:\.[a-z0-9]+)+", text):
        return False

    # Focus on phrase-like literals that are most likely visible copy.
    if not generated_context and " " not in text:
        return False

    return True


def read_de_value(entry: dict) -> str | None:
    locs = entry.get("localizations", {})
    de = locs.get("de")
    if not isinstance(de, dict):
        return None

    string_unit = de.get("stringUnit")
    if isinstance(string_unit, dict):
        value = string_unit.get("value")
        if isinstance(value, str):
            return value

    variations = de.get("variations")
    if isinstance(variations, dict):
        for variation in variations.values():
            if not isinstance(variation, dict):
                continue
            for variant in variation.values():
                if not isinstance(variant, dict):
                    continue
                unit = variant.get("stringUnit")
                if isinstance(unit, dict) and isinstance(unit.get("value"), str):
                    return unit["value"]

    return None


def main() -> int:
    issues: list[tuple[str, int, str]] = []
    l10n_keys: set[str] = set()
    files = iter_scoped_files()

    for path in files:
        rel = path.relative_to(ROOT)
        scans_generated_copy = path.name in GENERATED_COPY_FILE_NAMES
        brace_depth = 0
        paren_depth = 0
        generated_brace_depth: int | None = None
        pending_generated_brace_scope = False
        generated_call_depth: int | None = None

        for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
            if scans_generated_copy and (GENERATED_COPY_PROPERTY_RE.search(line) or GENERATED_COPY_FUNCTION_RE.search(line)):
                pending_generated_brace_scope = True

            if scans_generated_copy and any(token in line for token in GENERATED_COPY_INITIALIZERS) and generated_call_depth is None:
                generated_call_depth = paren_depth + max(line.count("(") - line.count(")"), 1)

            generated_context = (
                scans_generated_copy
                and (
                    generated_brace_depth is not None
                    or generated_call_depth is not None
                    or any(token in line for token in GENERATED_COPY_CONTEXT_TOKENS)
                )
            )

            for match in L10N_KEY_RE.finditer(line):
                l10n_keys.add(match.group(1))

            if "L10n.tr(" in line or "L10n.format(" in line or "NSLocalizedString(" in line:
                brace_depth += line.count("{") - line.count("}")
                paren_depth += line.count("(") - line.count(")")
                if pending_generated_brace_scope and "{" in line:
                    generated_brace_depth = brace_depth
                    pending_generated_brace_scope = False
                if generated_brace_depth is not None and brace_depth < generated_brace_depth:
                    generated_brace_depth = None
                if generated_call_depth is not None and paren_depth < generated_call_depth:
                    generated_call_depth = None
                continue

            for match in STRING_RE.finditer(line):
                literal = match.group(1)
                if looks_like_user_facing_english_literal(line, literal, generated_context):
                    issues.append((str(rel), lineno, literal))

            brace_depth += line.count("{") - line.count("}")
            paren_depth += line.count("(") - line.count(")")
            if pending_generated_brace_scope and "{" in line:
                generated_brace_depth = brace_depth
                pending_generated_brace_scope = False
            if generated_brace_depth is not None and brace_depth < generated_brace_depth:
                generated_brace_depth = None
            if generated_call_depth is not None and paren_depth < generated_call_depth:
                generated_call_depth = None

    catalog = json.loads(XCSTRINGS_PATH.read_text(encoding="utf-8"))
    strings = catalog.get("strings", {})
    available = set(strings.keys())
    missing_keys = sorted(k for k in l10n_keys if k not in available)

    missing_de_keys: list[str] = []
    identical_de_keys: list[str] = []
    for key in sorted(l10n_keys & available):
        entry = strings.get(key, {})
        de_value = read_de_value(entry) if isinstance(entry, dict) else None
        if not de_value:
            missing_de_keys.append(key)
            continue
        if key not in IDENTICAL_DE_ALLOWLIST and de_value.strip() == key.strip():
            identical_de_keys.append(key)

    print(f"Scanned {len(files)} Swift files")
    print(f"Likely user-facing hardcoded English literals: {len(issues)}")
    for rel, lineno, lit in issues[:250]:
        print(f"{rel}:{lineno}: {lit}")

    print(f"Missing L10n keys in Localizable.xcstrings: {len(missing_keys)}")
    for key in missing_keys[:250]:
        print(f"MISSING_KEY: {key}")

    print(f"Missing visible German translations: {len(missing_de_keys)}")
    for key in missing_de_keys[:250]:
        print(f"MISSING_DE: {key}")

    print(f"Visible German translations identical to English key: {len(identical_de_keys)}")
    for key in identical_de_keys[:250]:
        print(f"IDENTICAL_DE: {key}")

    has_failures = bool(issues or missing_keys or missing_de_keys or identical_de_keys)
    return 1 if has_failures else 0


if __name__ == "__main__":
    raise SystemExit(main())
