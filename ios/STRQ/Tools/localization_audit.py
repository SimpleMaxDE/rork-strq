#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
XCSTRINGS_PATH = ROOT / "Localizable.xcstrings"

ALLOW_TERMS = {
    "STRQ", "STRQ Pro", "iCloud", "Apple", "PR", "e1RM", "RPE", "kg", "min", "kcal",
    "Coach", "Pro", "Push", "Pull", "Legs", "Core", "Deload"
}

USER_FACING_CONTEXT_RE = re.compile(
    r"\b(Text|Button|Label|navigationTitle|alert|confirmationDialog|sheet|toolbar|Section|Picker|TextField)\s*\(|"
    r"\b(title|detail|summary|eyebrow|ctaTitle|displayName|shortName|description|headline|subtitle|message|"
    r"emptyState|note|label|primaryAction|unlocksNext|learning)\s*:\s*"
)
NON_USER_CONTEXT_RE = re.compile(
    r"\b(Analytics\.|ErrorReporter\.|print\(|debugPrint\(|logger\.|os_log|"
    r"systemName\s*:|symbolName\s*:|icon\s*:|colorName\s*:|id\s*:|identifier|rawValue|"
    r"imageName\s*:|file|path|URL|http|https|SF Symbol)"
)

STRING_RE = re.compile(r'"([^"\\]*(?:\\.[^"\\]*)*)"')
L10N_KEY_RE = re.compile(r'L10n\.(?:tr|format)\("([^"]+)"')


def looks_like_user_facing_literal(line: str, literal: str) -> bool:
    s = literal.strip()
    if not s:
        return False
    if s in ALLOW_TERMS:
        return False
    if re.fullmatch(r"[\W_]+", s):
        return False
    if re.fullmatch(r"[0-9.:%+\-–—/ ]+", s):
        return False
    if re.fullmatch(r"[A-Za-z0-9_.:/-]+", s) and " " not in s:
        # likely identifiers/paths/symbols/keys/units
        return False
    if NON_USER_CONTEXT_RE.search(line):
        return False
    if not USER_FACING_CONTEXT_RE.search(line):
        return False
    return bool(re.search(r"[A-Za-z]", s))


def main() -> int:
    swift_files = sorted(ROOT.rglob("*.swift"))
    issues: list[tuple[str, int, str]] = []
    l10n_keys: set[str] = set()

    target_suffixes = {
        "Services/DailyBriefingEngine.swift",
        "Services/PlanGenerator.swift",
        "Services/WorkoutHighlights.swift",
        "ViewModels/StoreViewModel.swift",
        "Models/UserProfile.swift",
        "ViewModels/AppViewModel.swift",
    }
    scoped_files = [p for p in swift_files if any(str(p.relative_to(ROOT)).endswith(s) for s in target_suffixes)]

    for path in scoped_files:
        rel = path.relative_to(ROOT)
        for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
            for m in L10N_KEY_RE.finditer(line):
                l10n_keys.add(m.group(1))

            if "L10n.tr(" in line or "L10n.format(" in line or "NSLocalizedString(" in line:
                continue

            for m in STRING_RE.finditer(line):
                lit = m.group(1)
                if looks_like_user_facing_literal(line, lit):
                    issues.append((str(rel), lineno, lit))

    catalog = json.loads(XCSTRINGS_PATH.read_text(encoding="utf-8"))
    available = set(catalog.get("strings", {}).keys())
    missing_keys = sorted(k for k in l10n_keys if k not in available)

    print(f"Scanned {len(scoped_files)} Swift files (localization-critical scope)")
    print(f"Likely user-facing hardcoded literals: {len(issues)}")
    for rel, lineno, lit in issues[:200]:
        print(f"{rel}:{lineno}: {lit}")
    if len(issues) > 200:
        print(f"... {len(issues)-200} more")

    print(f"Missing L10n keys in Localizable.xcstrings: {len(missing_keys)}")
    for key in missing_keys[:200]:
        print(f"MISSING: {key}")
    if len(missing_keys) > 200:
        print(f"... {len(missing_keys)-200} more")

    return 1 if issues or missing_keys else 0


if __name__ == "__main__":
    raise SystemExit(main())
