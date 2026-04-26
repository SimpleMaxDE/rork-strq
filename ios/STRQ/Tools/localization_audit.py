#!/usr/bin/env python3
import json
import re
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
XCSTRINGS_PATH = ROOT / "Localizable.xcstrings"

ALLOW_TERMS = {
    "STRQ", "STRQ Pro", "iCloud", "Apple", "PR", "e1RM", "RPE", "kg", "min", "kcal",
    "Coach", "Pro", "Deload", "Push", "Pull", "Legs",
}

USER_CONTEXT_RE = re.compile(
    r"\b(Text|Button|Label|NavigationLink|navigationTitle|alert|confirmationDialog|searchable|"
    r"accessibilityLabel|accessibilityHint|ForgeSectionHeader|controlRow|controlRowContent|profileRow|"
    r"statusChip|proPillarChip|selectionChip|stepHero|fieldGroup)\s*\(|"
    r"\b(title|detail|summary|eyebrow|ctaTitle|displayName|shortName|description|headline|subtitle|message|note|label)\s*:"
)
NON_USER_RE = re.compile(
    r"\b(Analytics\.|ErrorReporter\.|print\(|debugPrint\(|logger\.|os_log|"
    r"systemName\s*:|symbolName\s*:|icon\s*:|id\s*:|identifier|rawValue|imageName\s*:|forKey:)"
)
STRING_RE = re.compile(r'"([^"\\]*(?:\\.[^"\\]*)*)"')
L10N_KEY_RE = re.compile(r'L10n\.(?:tr|format)\("([^"]+)"')

TARGET_VIEW_FILES = {
    "Views/CoachTabView.swift",
    "Views/CoachingHistoryView.swift",
    "Views/CoachingPreferencesView.swift",
    "Views/ExercisePrescriptionSheet.swift",
    "Views/NotificationSettingsView.swift",
    "Views/NutritionSettingsView.swift",
    "Views/ReadinessCheckInView.swift",
    "Views/STRQPaywallView.swift",
    "Views/SessionEditorSheet.swift",
    "Views/SleepLogView.swift",
    "Views/SwapExerciseSheet.swift",
    "Views/WeeklyCheckInView.swift",
}

EXCLUDED_DIRS = {"Tools", "STRQTests", "STRQUITests"}
COPY_FILES = {
    "Services/DailyBriefingEngine.swift",
    "Services/PlanGenerator.swift",
    "Services/WorkoutHighlights.swift",
    "ViewModels/AppViewModel.swift",
    "ViewModels/StoreViewModel.swift",
    "Models/UserProfile.swift",
}

def iter_swift_files() -> list[Path]:
    out=[]
    for p in sorted(ROOT.rglob("*.swift")):
        if set(p.parts).intersection(EXCLUDED_DIRS):
            continue
        out.append(p)
    return out

def is_user_surface(path: Path) -> bool:
    rel=str(path.relative_to(ROOT))
    if rel.endswith("Views/MediaDiagnosticsView.swift"):
        return False
    return rel in TARGET_VIEW_FILES or rel in COPY_FILES

def is_user_literal(path: Path, line: str, lit: str) -> bool:
    if not is_user_surface(path):
        return False
    s=lit.strip()
    if not s or s in ALLOW_TERMS:
        return False
    if "\\(" in s or "%@" in s or re.search(r"%\d*\.?\d*[df]", s):
        return False
    if s.startswith(",") or "))" in s:
        return False
    if re.fullmatch(r"[\W_]+", s) or re.fullmatch(r"[0-9.%+\-–—/: ]+", s):
        return False
    if NON_USER_RE.search(line) or not USER_CONTEXT_RE.search(line):
        return False
    if " " not in s:
        return False
    return bool(re.search(r"[A-Za-z]", s))

def is_visible_prose(key: str) -> bool:
    k=key.strip()
    if not k or k in ALLOW_TERMS:
        return False
    if "%" in k or "@" in k:
        return False
    if " " not in k:
        return False
    if re.fullmatch(r"[%@0-9. +\-–—/:]+", k):
        return False
    if k.isupper():
        return False
    return bool(re.search(r"[A-Za-z]", k))

def main() -> int:
    files=iter_swift_files()
    issues=[]
    l10n_keys=set()
    visible_l10n_keys=set()

    for path in files:
        rel=path.relative_to(ROOT)
        for lineno,line in enumerate(path.read_text(encoding="utf-8").splitlines(),start=1):
            for m in L10N_KEY_RE.finditer(line):
                key=m.group(1)
                if is_user_surface(path):
                    l10n_keys.add(key)
                    visible_l10n_keys.add(key)
            if "L10n.tr(" in line or "L10n.format(" in line or "NSLocalizedString(" in line:
                continue
            for m in STRING_RE.finditer(line):
                if is_user_literal(path,line,m.group(1)):
                    issues.append(f"{rel}:{lineno}: {m.group(1)}")

    catalog=json.loads(XCSTRINGS_PATH.read_text(encoding="utf-8"))
    strings=catalog.get("strings",{})
    missing=[k for k in sorted(l10n_keys) if k not in strings]

    untranslated=[]
    for key in sorted(visible_l10n_keys):
        if key not in strings:
            continue
        de=(strings.get(key,{}).get("localizations",{}).get("de",{}).get("stringUnit",{}).get("value"))
        if not de:
            untranslated.append(f"{key} (missing de translation)")
            continue
        if is_visible_prose(key) and de.strip()==key.strip() and key not in ALLOW_TERMS:
            untranslated.append(f"{key} (de identical to key)")

    print(f"Scanned {len(files)} Swift files under {ROOT}")
    print(f"Likely user-facing hardcoded literals: {len(issues)}")
    for row in issues[:200]:
        print(row)
    print(f"Missing L10n keys in Localizable.xcstrings: {len(missing)}")
    for row in missing[:200]:
        print(f"MISSING: {row}")
    print(f"Visible prose keys with missing/identical German translations: {len(untranslated)}")
    for row in untranslated[:200]:
        print(f"UNTRANSLATED: {row}")

    return 1 if issues or missing or untranslated else 0

if __name__=="__main__":
    raise SystemExit(main())
