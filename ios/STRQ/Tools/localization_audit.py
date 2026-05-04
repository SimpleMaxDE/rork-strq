#!/usr/bin/env python3
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
IOS_ROOT = ROOT.parent
XCSTRINGS_PATH = ROOT / "Localizable.xcstrings"

if hasattr(sys.stdout, "reconfigure"):
    sys.stdout.reconfigure(encoding="utf-8")

UI_CONTEXT_TOKENS = [
    "Text(", "Button(", "Label(", "navigationTitle(", "alert(",
    "confirmationDialog(", "Toggle(", "Picker(", "Section(", "TextField(",
    "SecureField(", "Stepper(", "Menu(", "LabeledContent(",
    "ForgeSectionHeader(", "controlRow(", "profileRow(", "statusChip(",
    "proPillarChip(", "selectionChip(", "stepHero(", "fieldGroup(",
    "ContentUnavailableView(", "ForgePrimaryButton(", "ForgeSecondaryButton(",
    "metricPill(", "signalPill(", "momentumPill(", "roadmapRow(",
    "overviewStat(", "summaryItem(", "libraryStatColumn(", "filterChip(",
    "builderCard(", "roleSummaryChip(", "painChoiceButton(",
]

GENERATED_COPY_CONTEXT_TOKENS = [
    "title:", "explanation:", "coachNote:", "reason:",
    "displayName:", "description:", "optimizingFor:", "expectedIntensityLabel:",
]

USER_FACING_PROPERTY_NAMES = (
    "label", "title", "subtitle", "detail", "message", "free", "pro",
    "badge", "trailing", "explanation", "coachNote", "displayName",
    "headline", "footnote", "prompt", "caption", "eyebrow", "summary",
    "options", "status", "section", "items",
)
USER_FACING_PROPERTY_RE = re.compile(
    r"\b(" + "|".join(USER_FACING_PROPERTY_NAMES) + r")\s*:"
)
PAYWALL_COPY_SCOPE_RE = re.compile(
    r"\b(?:private\s+)?(?:var|func)\s+"
    r"(pillars|compareBlock|packageSelector|savingsBadge|annualSubtitle|"
    r"perMonthLine|trialBadge|purchaseButtonTitle|trustRow)\b"
)
EXERCISE_DISPLAY_NAME_RE = re.compile(r"\bvar\s+displayName\s*:\s*String\b")
SCREEN_COPY_SCOPE_RE = re.compile(
    r"\b(?:private\s+)?(?:var|func)\s+"
    r"(contextLabel|summaryTitle|shortLabel|sleepTrainingImpact|"
    r"sleepTrainingInsights|readinessLabel|streakMessage|paceMessage|"
    r"taskHeaderTitle|taskHeaderDetail|roleGroups|headlineHero|"
    r"whatChangedStrip|signalStrip|libraryHero|filterChips|"
    r"exerciseCountBar|resultView|signalBreakdown)\b"
)
USER_FACING_ARRAY_RE = re.compile(
    r"\b(?:let|var)\s+\w*(?:steps|options|status|statuses|items|"
    r"signals|sections|rows|chips|insights|adjustments)\w*"
    r"\s*(?::[^=]+)?=\s*\["
)

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
COACH_TAB_COPY_PROPERTY_RE = re.compile(
    r"\bprivate\s+var\s+(headline|coachEarlyStateMessage)\s*:\s*String\b"
)
COACH_TAB_COPY_ARRAY_RE = re.compile(
    r"\blet\s+items\s*:\s*\[\(String,\s*String,\s*Bool\)\]"
)
INTERPOLATION_RE = re.compile(r"\\\([^)]*\)")
GENERATED_COPY_FILE_NAMES = {
    "ProgressionState.swift",
    "ProgressionEngine.swift",
}
TARGETED_COPY_FILES = {
    Path("STRQ/Views/STRQPaywallView.swift"),
    Path("STRQ/Models/Exercise.swift"),
    Path("STRQ/Models/DailyReadiness.swift"),
    Path("STRQ/Models/UserProfile.swift"),
    Path("STRQ/Views/ActiveWorkoutView.swift"),
    Path("STRQ/Views/CoachingPreferencesView.swift"),
    Path("STRQ/Views/ExerciseLibraryView.swift"),
    Path("STRQ/Views/PlanGenerationView.swift"),
    Path("STRQ/Views/PlanRevealView.swift"),
    Path("STRQ/Views/PreWorkoutHandoffView.swift"),
    Path("STRQ/Views/ProgressAnalyticsView.swift"),
    Path("STRQ/Views/ReadinessCheckInView.swift"),
    Path("STRQ/Views/SessionEditorSheet.swift"),
    Path("STRQ/Views/SleepLogView.swift"),
    Path("STRQ/Services/DailyCoachEngine.swift"),
    Path("STRQWatch/ContentView.swift"),
    Path("STRQWidget/WorkoutLiveActivity.swift"),
}

NON_USER_CONTEXT_TOKENS = [
    "print(", "debugPrint(", "logger.", "os_log", "Analytics.", "ErrorReporter.",
    "NSPredicate(", "URL(", "http://", "https://", "UserDefaults", "forKey:",
    "accessibilityIdentifier(", "fatalError(", "preconditionFailure(",
    "rawValue", "exerciseId", "productIdentifier", "ProductIdentifier",
    "WCSession", "send([", "receive", "debug", "Debug",
]
NON_USER_LITERAL_PROPERTY_RE = re.compile(
    r"\b(systemName|icon|color|rawValue|identifier|id|symbolName|imageName|"
    r"accessibilityIdentifier|colorName|analyticsKey|productId|productID|"
    r"exerciseId)\s*:\s*$"
)

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

EXCLUDED_FILE_NAMES = {
    "CuratedImportedMediaBridge.swift",
    "ExerciseCatalog.swift",
    "ExerciseDBProImporter.swift",
    "ExerciseFactory.swift",
    "ExerciseIdentity.swift",
    "ExerciseLibrary.swift",
    "ExerciseLibraryArms.swift",
    "ExerciseLibraryBack.swift",
    "ExerciseLibraryChest.swift",
    "ExerciseLibraryCore.swift",
    "ExerciseLibraryFunctional.swift",
    "ExerciseLibraryLegs.swift",
    "ExerciseLibraryMobility.swift",
    "ExerciseLibraryShoulders.swift",
    "ExerciseLibrarySpecialty.swift",
}

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
    "Progression",
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
LOCALIZED_CALL_RE = re.compile(r'\b(?:L10n|WatchL10n|WidgetL10n)\.(?:tr|format)\(|NSLocalizedString\(')
ENGLISH_CHAR_RE = re.compile(r"[A-Za-z]")


def iter_scoped_files() -> list[Path]:
    files: list[Path] = []
    for scan_root in (ROOT, IOS_ROOT / "STRQWatch", IOS_ROOT / "STRQWidget"):
        if not scan_root.exists():
            continue
        for path in sorted(scan_root.rglob("*.swift")):
            rel = path.relative_to(IOS_ROOT)
            parts = set(rel.parts)
            if parts & EXCLUDED_PATH_PARTS:
                continue
            if any(hint in path.name for hint in EXCLUDED_FILE_HINTS):
                continue
            if path.name in EXCLUDED_FILE_NAMES:
                continue
            files.append(path)
    return files


def is_non_user_literal_context(line: str, start: int) -> bool:
    if any(token in line for token in NON_USER_CONTEXT_TOKENS):
        return True
    return bool(NON_USER_LITERAL_PROPERTY_RE.search(line[:start]))


def looks_like_user_facing_english_literal(
    line: str,
    literal: str,
    user_context: bool = False,
    allow_single_word: bool = False,
    allow_uppercase: bool = False,
) -> bool:
    text = literal.strip()
    if not text:
        return False

    if "\\(" in text:
        if not user_context:
            return False
        text = INTERPOLATION_RE.sub(" ", text).strip()
        if not text:
            return False

    if text in IDENTICAL_DE_ALLOWLIST:
        return False

    if not user_context and not any(token in line for token in UI_CONTEXT_TOKENS):
        return False

    if not ENGLISH_CHAR_RE.search(text):
        return False

    if not user_context and ("%" in text or "%@" in text):
        return False

    if not user_context and ("))" in text or "\\(" in text):
        return False

    if re.fullmatch(r"[A-Z0-9_./:-]+", text):
        if not allow_uppercase:
            return False

    if re.fullmatch(r"[%0-9.\-+()/: ]+", text):
        return False

    if re.fullmatch(r"[a-z0-9]+(?:\.[a-z0-9]+)+", text):
        return False

    # Focus on phrase-like literals that are most likely visible copy.
    if not allow_single_word and " " not in text:
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
        rel = path.relative_to(IOS_ROOT)
        scans_generated_copy = path.name in GENERATED_COPY_FILE_NAMES
        scans_coach_tab_copy = rel.as_posix() == "STRQ/Views/CoachTabView.swift"
        scans_paywall_copy = rel.as_posix() == "STRQ/Views/STRQPaywallView.swift"
        scans_exercise_metadata = rel.as_posix() == "STRQ/Models/Exercise.swift"
        targeted_copy_file = rel in TARGETED_COPY_FILES
        brace_depth = 0
        paren_depth = 0
        generated_brace_depth: int | None = None
        pending_generated_brace_scope = False
        generated_call_depth: int | None = None
        coach_tab_copy_brace_depth: int | None = None
        pending_coach_tab_copy_scope = False
        coach_tab_copy_array_depth: int | None = None
        paywall_copy_brace_depth: int | None = None
        pending_paywall_copy_scope = False
        exercise_display_brace_depth: int | None = None
        pending_exercise_display_scope = False
        screen_copy_brace_depth: int | None = None
        pending_screen_copy_scope = False
        user_facing_array_depth: int | None = None

        for lineno, line in enumerate(path.read_text(encoding="utf-8").splitlines(), start=1):
            if scans_generated_copy and (GENERATED_COPY_PROPERTY_RE.search(line) or GENERATED_COPY_FUNCTION_RE.search(line)):
                pending_generated_brace_scope = True

            if scans_generated_copy and any(token in line for token in GENERATED_COPY_INITIALIZERS) and generated_call_depth is None:
                generated_call_depth = paren_depth + max(line.count("(") - line.count(")"), 1)

            if scans_coach_tab_copy and COACH_TAB_COPY_PROPERTY_RE.search(line):
                pending_coach_tab_copy_scope = True

            if scans_coach_tab_copy and COACH_TAB_COPY_ARRAY_RE.search(line) and coach_tab_copy_array_depth is None:
                coach_tab_copy_array_depth = 0

            if scans_paywall_copy and PAYWALL_COPY_SCOPE_RE.search(line):
                pending_paywall_copy_scope = True

            if scans_exercise_metadata and EXERCISE_DISPLAY_NAME_RE.search(line):
                pending_exercise_display_scope = True

            if targeted_copy_file and SCREEN_COPY_SCOPE_RE.search(line):
                pending_screen_copy_scope = True

            if targeted_copy_file and USER_FACING_ARRAY_RE.search(line) and user_facing_array_depth is None:
                user_facing_array_depth = 0

            generated_context = (
                (
                    scans_generated_copy
                    and (
                        generated_brace_depth is not None
                        or generated_call_depth is not None
                        or any(token in line for token in GENERATED_COPY_CONTEXT_TOKENS)
                    )
                )
                or (
                    scans_coach_tab_copy
                    and (
                        coach_tab_copy_brace_depth is not None
                        or coach_tab_copy_array_depth is not None
                    )
                )
            )
            raw_property_context = bool(USER_FACING_PROPERTY_RE.search(line))
            property_context = targeted_copy_file and raw_property_context
            paywall_context = scans_paywall_copy and (
                paywall_copy_brace_depth is not None
                or pending_paywall_copy_scope
                or raw_property_context
            )
            exercise_metadata_context = scans_exercise_metadata and (
                exercise_display_brace_depth is not None
                or pending_exercise_display_scope
            )
            screen_copy_context = targeted_copy_file and (
                screen_copy_brace_depth is not None
                or pending_screen_copy_scope
                or user_facing_array_depth is not None
            )
            user_context = (
                generated_context
                or property_context
                or paywall_context
                or exercise_metadata_context
                or screen_copy_context
                or any(token in line for token in UI_CONTEXT_TOKENS)
            )

            for match in L10N_KEY_RE.finditer(line):
                l10n_keys.add(match.group(1))

            if LOCALIZED_CALL_RE.search(line):
                brace_depth += line.count("{") - line.count("}")
                paren_depth += line.count("(") - line.count(")")
                if pending_generated_brace_scope and "{" in line:
                    generated_brace_depth = brace_depth
                    pending_generated_brace_scope = False
                if generated_brace_depth is not None and brace_depth < generated_brace_depth:
                    generated_brace_depth = None
                if generated_call_depth is not None and paren_depth < generated_call_depth:
                    generated_call_depth = None
                if pending_coach_tab_copy_scope and "{" in line:
                    coach_tab_copy_brace_depth = brace_depth
                    pending_coach_tab_copy_scope = False
                if coach_tab_copy_brace_depth is not None and brace_depth < coach_tab_copy_brace_depth:
                    coach_tab_copy_brace_depth = None
                if coach_tab_copy_array_depth is not None:
                    coach_tab_copy_array_depth += line.count("[") - line.count("]")
                    if coach_tab_copy_array_depth <= 0:
                        coach_tab_copy_array_depth = None
                if pending_paywall_copy_scope and "{" in line:
                    paywall_copy_brace_depth = brace_depth
                    pending_paywall_copy_scope = False
                if paywall_copy_brace_depth is not None and brace_depth < paywall_copy_brace_depth:
                    paywall_copy_brace_depth = None
                if pending_exercise_display_scope and "{" in line:
                    exercise_display_brace_depth = brace_depth
                    pending_exercise_display_scope = False
                if exercise_display_brace_depth is not None and brace_depth < exercise_display_brace_depth:
                    exercise_display_brace_depth = None
                if pending_screen_copy_scope and "{" in line:
                    screen_copy_brace_depth = brace_depth
                    pending_screen_copy_scope = False
                if screen_copy_brace_depth is not None and brace_depth < screen_copy_brace_depth:
                    screen_copy_brace_depth = None
                if user_facing_array_depth is not None:
                    user_facing_array_depth += line.count("[") - line.count("]")
                    if user_facing_array_depth <= 0:
                        user_facing_array_depth = None
                continue

            for match in STRING_RE.finditer(line):
                literal = match.group(1)
                if is_non_user_literal_context(line, match.start()):
                    continue
                if looks_like_user_facing_english_literal(
                    line,
                    literal,
                    user_context,
                    allow_single_word=targeted_copy_file or exercise_metadata_context,
                    allow_uppercase=targeted_copy_file,
                ):
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
            if pending_coach_tab_copy_scope and "{" in line:
                coach_tab_copy_brace_depth = brace_depth
                pending_coach_tab_copy_scope = False
            if coach_tab_copy_brace_depth is not None and brace_depth < coach_tab_copy_brace_depth:
                coach_tab_copy_brace_depth = None
            if coach_tab_copy_array_depth is not None:
                coach_tab_copy_array_depth += line.count("[") - line.count("]")
                if coach_tab_copy_array_depth <= 0:
                    coach_tab_copy_array_depth = None
            if pending_paywall_copy_scope and "{" in line:
                paywall_copy_brace_depth = brace_depth
                pending_paywall_copy_scope = False
            if paywall_copy_brace_depth is not None and brace_depth < paywall_copy_brace_depth:
                paywall_copy_brace_depth = None
            if pending_exercise_display_scope and "{" in line:
                exercise_display_brace_depth = brace_depth
                pending_exercise_display_scope = False
            if exercise_display_brace_depth is not None and brace_depth < exercise_display_brace_depth:
                exercise_display_brace_depth = None
            if pending_screen_copy_scope and "{" in line:
                screen_copy_brace_depth = brace_depth
                pending_screen_copy_scope = False
            if screen_copy_brace_depth is not None and brace_depth < screen_copy_brace_depth:
                screen_copy_brace_depth = None
            if user_facing_array_depth is not None:
                user_facing_array_depth += line.count("[") - line.count("]")
                if user_facing_array_depth <= 0:
                    user_facing_array_depth = None

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
