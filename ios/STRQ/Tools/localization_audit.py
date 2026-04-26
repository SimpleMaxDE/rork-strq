#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
XCSTRINGS_PATH = ROOT / "Localizable.xcstrings"

ALLOW_TERMS = {
    "STRQ", "STRQ Pro", "iCloud", "Apple", "PR", "e1RM", "RPE", "kg", "min", "kcal",
    "Coach", "Pro", "Push", "Pull", "Legs", "Core", "Deload",
}

USER_CONTEXT_TOKENS = [
    "Text(", "Button(", "Label(", "NavigationLink(", "navigationTitle(", "alert(",
    "confirmationDialog(", "searchable(", "accessibilityLabel(", "accessibilityHint(",
    "ForgeSectionHeader(", "controlRow(", "controlRowContent(", "profileRow(",
    "statusChip(", "proPillarChip(", "selectionChip(", "stepHero(", "fieldGroup(",
    "title:", "detail:", "summary:", "eyebrow:", "cta:", "ctaTitle:", "displayName:",
    "shortName:", "description:", "headline:", "subtitle:", "message:", "note:", "label:",
]

NON_USER_CONTEXT_TOKENS = [
    "Analytics.", "ErrorReporter.", "print(", "debugPrint(", "logger.", "os_log",
    "systemName:", "symbolName:", "icon:", "colorName:", "id:", "identifier", "rawValue",
    "imageName:", "file", "path", "URL", "http", "https", "SF Symbol", "UserDefaults", "forKey:",
]

STRING_RE = re.compile(r'"([^"\\]*(?:\\.[^"\\]*)*)"')
L10N_KEY_RE = re.compile(r'L10n\.(?:tr|format)\("([^"]+)"')


def looks_like_user_facing_literal(line: str, literal: str) -> bool:
    s = literal.strip()
    if not s or s in ALLOW_TERMS:
        return False
    if re.fullmatch(r"[\W_]+", s) or re.fullmatch(r"[0-9.:%+\-–—/ ]+", s):
        return False
    if re.fullmatch(r"[A-Za-z0-9_.:/-]+", s) and " " not in s:
        return False
    if any(token in line for token in NON_USER_CONTEXT_TOKENS):
        return False
    if not any(token in line for token in USER_CONTEXT_TOKENS):
        return False
    return bool(re.search(r"[A-Za-z]", s))


def iter_scoped_files() -> list[Path]:
    swift_files = sorted(ROOT.rglob("*.swift"))
    target_suffixes = {
        "Views/ProfileView.swift",
        "Views/DashboardView.swift",
        "Views/ActiveWorkoutView.swift",
        "Views/OnboardingView.swift",
        "Views/TrainingPlanView.swift",
        "Views/WorkoutCompletionView.swift",
        "Views/PlanRevealView.swift",
        "Views/ProgressAnalyticsView.swift",
        "Services/DailyBriefingEngine.swift",
        "Services/PlanGenerator.swift",
        "Services/WorkoutHighlights.swift",
        "ViewModels/StoreViewModel.swift",
        "ViewModels/AppViewModel.swift",
        "Models/UserProfile.swift",
    }
    return [p for p in swift_files if any(str(p.relative_to(ROOT)).endswith(suffix) for suffix in target_suffixes)]


def main() -> int:
    issues: list[tuple[str, int, str]] = []
    l10n_keys: set[str] = set()

    for path in iter_scoped_files():
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

    print(f"Scanned {len(iter_scoped_files())} Swift files")
    print(f"Likely user-facing hardcoded literals: {len(issues)}")
    for rel, lineno, lit in issues[:250]:
        print(f"{rel}:{lineno}: {lit}")
    print(f"Missing L10n keys in Localizable.xcstrings: {len(missing_keys)}")
    for key in missing_keys[:250]:
        print(f"MISSING: {key}")

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
