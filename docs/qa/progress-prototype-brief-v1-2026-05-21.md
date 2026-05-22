# Progress Prototype Brief v1 - 2026-05-21

Status: Approved reference matrix converted into a concrete DEBUG-only prototype brief.

Source:

- `docs/qa/progress-training-map-redesign-plan-2026-05-21.md`
- `/Users/simplemax/Documents/progress_reference_matrix_report_full.md`
- Accepted STRQ directions: Today poster, ActiveWorkout logger, Rest Focus Overlay, Completion PR/Gold system

Hard rule: production Progress remains blocked until DEBUG prototype screenshots are approved.

## 1. Product Job

Progress must become the STRQ Training Map signature surface.

In 10 seconds, Progress must communicate:

- What my recent training has actually proven.
- What is starting to form, but is not ready to call stable.
- What is missing or still locked because STRQ does not have enough evidence.
- What the next useful training move is.

Progress must feel like proof from completed training, not like a generic analytics dashboard.

Screen role boundary:

- Today poster owns the daily command and the immediate next action.
- ActiveWorkout owns live logging, set execution, rest timer, and workout mutation.
- Rest Focus Overlay owns the focused rest / back-off moment.
- Completion owns the immediate finish reward, including real PR/Gold moments.
- Progress owns the slower proof story after training is complete.

Approved exclusions:

- No global score-first hero.
- No avatar or companion.
- No leaderboard or social-first logic.
- No exact muscle-balance percentages without trust gates.
- No fake precision.
- No medical recovery claims.
- No production implementation before DEBUG screenshots are approved.

## 2. First Viewport Structure

The first viewport must be a fixed composition. It should answer: "Where is my training map right now, what proof exists, and what should I do next?"

### 2.1 Header

Purpose: orient the user without turning the top into navigation chrome.

Required content:

- Title: `Progress`
- Subtitle or compact label: `Training Map`
- Optional state switcher in DEBUG only.

Rules:

- Do not add tabs above the hero.
- Do not show a global score.
- Do not expose internal confidence terms.
- Header must remain compact on small iPhone.

### 2.2 Hero State

Purpose: one gym-native read for the current state.

Required content:

- One German headline.
- One short German explanation, max two lines on large iPhone.
- One semantic state accent.

Rules:

- Headline must describe training, not app intelligence.
- Do not use scientific or debug copy.
- Do not make a warning state look like a failure.

### 2.3 Training Map Visual

Purpose: the STRQ-owned signature visual.

Required content:

- A path or map of training nodes.
- Node states: proven, forming, missing, locked, PR.
- Broad training areas only for V0: rhythm, volume, strength, coverage, recovery.

Rules:

- No dense chart stack above the fold.
- No exact percentages.
- No body-medical framing.
- Map must read as a training surface, not a settings card.

### 2.4 Proof Row

Purpose: three to four facts that explain why the state is shown.

Required content:

- Completed sessions or target status.
- Rhythm or spacing.
- Strength / volume / coverage / recovery fact relevant to the state.
- One locked or forming fact when trust is not high.

Rules:

- Values must be plain and short.
- Prefer counts, labels, and directions over exact deltas.
- Never show fake precision to make the row look smarter.

### 2.5 Next Move Card

Purpose: one useful training move that hands off mentally to Today / Train without replacing them.

Required content:

- German action headline.
- One-line reason.
- Optional secondary label: `Heute`, `Nächste Einheit`, or `Diese Woche`.

Rules:

- Do not start a workout from this prototype unless it is a non-functional DEBUG affordance.
- Do not imply the plan was changed.
- Do not override Today.

## 3. Lower Scroll Structure

Lower scroll must feel like proof behind the map, not a dashboard.

Exact sections, in order:

1. `Was steht`
   - Proven completed work.
   - Stable enough facts only.
   - Green semantics.

2. `Was sich bildet`
   - Early rhythm, strength, coverage, or volume patterns.
   - Amber or steel semantics.
   - Must explain what STRQ needs next without internal math.

3. `Was fehlt`
   - Locked or missing evidence.
   - Gray semantics unless recovery is a real caution.
   - Must not shame the user.

4. `Letzte Belege`
   - Recent completed sessions and meaningful events.
   - Short timeline rows.
   - Each row must connect to a visible map state.

5. `Nächster Schritt`
   - One clear next training move.
   - Can repeat the first-viewport next move in more detail.
   - Must not become a second Today screen.

Lower scroll rules:

- No raw history table as the primary experience.
- No chart wall.
- No all-zero deltas.
- No labels such as `Evidence Signal`, `Claim`, `Trust now`, or `Signal Readiness`.
- Advanced detail can be represented as a locked doorway, not a full analytics surface.

## 4. Required Prototype States

Each state must exist in the DEBUG prototype and be selectable from a DEBUG-only state switcher. All copy below is user-facing German unless marked internal.

### State 1 - Low Data

- Hero headline: `Die Map startet.`
- Short explanation: `Ein paar Sätze sind drin. Für echte Muster braucht STRQ noch mehr Training.`
- Map node states: rhythm locked gray; volume forming amber; strength locked gray; coverage locked gray; recovery context steel if available.
- Proof row values: `1 Einheit`; `Ziel offen`; `Kraft noch offen`; `Abdeckung offen`.
- Next move: `Nächste Einheit sauber loggen.`
- Must not claim: trend, PR, stable rhythm, muscle balance, readiness verdict, or adaptation.

### State 2 - Normal Week

- Hero headline: `Die Woche läuft.`
- Short explanation: `Du bist im Plan. Die nächste Einheit hält die Map sauber in Bewegung.`
- Map node states: rhythm forming amber; volume on track green; strength forming steel; coverage forming amber; recovery steel.
- Proof row values: `2 von 3 Einheiten`; `Abstand passt`; `Volumen normal`; `1 Bereich noch offen`.
- Next move: `Nächste geplante Einheit halten.`
- Must not claim: breakthrough, PR, perfect balance, or that the week is already proven before completion.

### State 3 - Target Hit

- Hero headline: `Wochenziel getroffen.`
- Short explanation: `Die geplante Arbeit ist erledigt. Jetzt zählt, ob der Rhythmus wiederholbar bleibt.`
- Map node states: target/completion green; rhythm forming or green depending demo; volume green; strength steel; coverage forming amber.
- Proof row values: `3 von 3 Einheiten`; `Ziel erreicht`; `Volumen steht`; `Rhythmus prüfen`.
- Next move: `Rhythmus nächste Woche wiederholen.`
- Must not claim: long-term consistency, full adaptation, perfect plan compliance, or guaranteed progress.

### State 4 - Target Overhit / Clustered Week

- Hero headline: `Ziel getroffen. Rhythmus noch nicht.`
- Short explanation: `Du hast mehr geschafft als geplant. Die Einheiten lagen eng beieinander, deshalb bleibt der Rhythmus offen.`
- Map node states: completion green; volume amber/green with watch accent; rhythm amber; strength forming steel; recovery amber if recent work is high.
- Proof row values: `4 Einheiten`; `3/3 Ziel`; `eng gebündelt`; `mehr Arbeit`.
- Next move: `Nächste Woche gleichmäßiger setzen.`
- Must not claim: stable rhythm, ideal amount of work, PR, recovery safety, or that overhitting is always better.

### State 5 - Volume Up

- Hero headline: `Mehr Arbeit drin.`
- Short explanation: `Dein geloggtes Volumen ist hochgegangen. Vor dem nächsten Push zählt Erholung.`
- Map node states: volume green or amber watch; rhythm steel; strength forming steel; coverage forming amber; recovery amber if limited.
- Proof row values: `Volumen rauf`; `3 Einheiten`; `Push/Pull drin`; `Erholung checken`.
- Next move: `Schwer nur, wenn du frisch bist.`
- Must not claim: adaptation, muscle gain, guaranteed strength increase, or "more is better".

### State 6 - PR / Best Set

- Hero headline: `Bestes Set geloggt.`
- Short explanation: `Ein Satz sticht sauber heraus. Gold bleibt für echte Bestmarken reserviert.`
- Map node states: PR node gold; strength green or gold; rhythm steel; volume steel; coverage unchanged.
- Proof row values: `Bankdrücken`; `80 kg x 6`; `besser als vorher`; `echte Bestmarke`.
- Next move: `Qualität halten, dann bestätigen.`
- Must not claim: PR if comparison history is thin, one-rep-max certainty, broad strength trend, or plan adaptation.

### State 7 - Recovery Low

- Hero headline: `Heute leichter.`
- Short explanation: `Der Kontext spricht gegen einen harten Push. Training geht, aber nicht auf Anschlag.`
- Map node states: recovery red; volume amber; rhythm steel; strength locked or amber; coverage steel.
- Proof row values: `Erholung niedrig`; `Gewicht zuletzt hoch`; `Schlaf kurz`; `Push begrenzen`.
- Next move: `Gewicht runter, Technik sauber.`
- Must not claim: diagnosis, injury, illness, medical readiness, or "du darfst nicht trainieren".

### State 8 - Deload Week

- Hero headline: `Absichtlich rausnehmen.`
- Short explanation: `Diese Woche soll Arbeit ankommen, nicht neue Härte beweisen.`
- Map node states: deload/recovery green or steel; volume amber down; rhythm green if maintained; strength locked gray; coverage steel.
- Proof row values: `Volumen runter`; `Rhythmus bleibt`; `Qualität zählt`; `kein PR-Fokus`.
- Next move: `Sauber bewegen, Druck raus.`
- Must not claim: regression, lost progress, weakness, or that lower volume means failure.

### State 9 - Plateau

- Hero headline: `Der Lift hängt.`
- Short explanation: `Der gleiche Bereich wiederholt sich. Der nächste Schritt ist kleiner, nicht härter.`
- Map node states: strength amber; rhythm green or steel; volume steel; coverage forming; recovery steel.
- Proof row values: `3 Versuche`; `Gewicht gehalten`; `kein klarer Sprung`; `Hebel ändern`.
- Next move: `Wdh., Gewicht oder Pause fein anpassen.`
- Must not claim: cause, lack of effort, overtraining, guaranteed fix, or medical limitation.

### State 10 - Comeback Week

- Hero headline: `Wieder drin.`
- Short explanation: `Nach der Pause zählt ein sauberer Einstieg mehr als ein harter Sprung.`
- Map node states: comeback/rhythm amber; completion green for resumed session; volume steel; strength locked gray; coverage forming amber.
- Proof row values: `Pause beendet`; `1 Einheit drin`; `Gewicht vorsichtig`; `Map baut neu auf`.
- Next move: `Zweite Einheit ruhig setzen.`
- Must not claim: old rhythm restored, prior strength recovered, lost progress quantified, or shame around the gap.

### State 11 - Consistent Rhythm

- Hero headline: `Der Rhythmus steht.`
- Short explanation: `Die Einheiten wiederholen sich über mehrere Wochen. Jetzt kannst du gezielt drücken.`
- Map node states: rhythm green; completion green; volume steel/green; strength forming or green; coverage forming.
- Proof row values: `4 Wochen`; `Ziel oft getroffen`; `Abstände sauber`; `Gezielt steigern`.
- Next move: `Einen Hebel gezielt pushen.`
- Must not claim: perfect adherence, no recovery risk, guaranteed progression, or complete coverage.

### State 12 - Muscle Coverage Forming

- Hero headline: `Abdeckung bildet sich.`
- Short explanation: `Einige Bereiche haben genug Arbeit gesehen. Andere brauchen noch die nächste Einheit.`
- Map node states: push green; pull forming amber; legs missing gray or amber; core locked gray; rhythm steel.
- Proof row values: `Push steht`; `Pull bildet sich`; `Beine offen`; `keine Prozentwerte`.
- Next move: `Offenen Bereich einplanen.`
- Must not claim: exact balance, posture issue, muscle recovery, symmetry, weakness diagnosis, or precise per-muscle percentages.

## 5. Copy System

Prototype UI copy must be German, short, premium, and gym-native.

Preferred user-facing terms:

- `steht`
- `bildet sich`
- `offen`
- `drin`
- `sauber`
- `halten`
- `ruhig setzen`
- `leichter`
- `rausnehmen`
- `bestes Set`
- `Wochenziel`
- `nächster Schritt`
- `nächste Einheit`
- `mehr Arbeit`
- `Rhythmus`
- `Map`

Use sparingly:

- `belastbar`
- `gelernt`
- `angepasst`

Forbidden user-facing terms:

- `Evidence Signal`
- `Claim`
- `Trust now`
- `Signal Readiness`
- `Readiness Score` as a primary verdict
- `Muscle Balance 73%`
- `optimal`
- `diagnostiziert`
- `medizinisch`
- `garantiert`

Tone rules:

- Write like a serious gym coach, not a lab report.
- Prefer verbs over abstract nouns.
- Explain uncertainty without exposing internal confidence mechanics.
- Celebrate real completion without hype.
- Gold copy appears only for PR / best set states.
- Recovery copy says how hard to push, not what is medically wrong.

## 6. Color Semantics

Color must clarify state, not decorate the screen.

- Green = proven / completed.
- Amber = forming / watch.
- Gold = PR / best set only.
- Red = real caution / recovery limited, used sparingly.
- Blue/steel = context.
- Gray = locked / not enough data.

Required node treatment:

- Proven nodes: green accent, stable fill or ring.
- Forming nodes: amber ring or partial fill.
- Missing nodes: gray with low emphasis.
- Locked nodes: gray and visually closed, but not punitive.
- PR node: gold reveal only when the state is PR / best set.
- Recovery caution: red localized to the recovery node and specific caution copy only.

Do not flood whole cards with color.

## 7. Motion Intent

V0 motion must be SwiftUI-native only.

Allowed motion:

- Map node lights up when a state is selected.
- PR node receives a short gold reveal in PR / best set state only.
- Evidence card settles in after the hero.
- Proof row values can count or fade in if they do not feel like a scoreboard.

Not allowed in V0:

- Rive.
- Lottie.
- Confetti.
- Avatar animation.
- Complex replay timeline.
- Motion that hides copy or changes layout height.

Reduce Motion fallback:

- No scale bounce.
- No shimmer.
- Use instant state changes plus subtle opacity.
- PR gold state can appear as a static gold ring.

## 8. Prototype Implementation Boundary

This brief authorizes only a DEBUG-only prototype.

Allowed:

- New DEBUG-only Progress Training Map prototype view.
- Local demo data only.
- DEBUG-only state switcher.
- DEBUG-only Design System Lab entry.
- SwiftUI-native prototype motion.
- Screenshot capture for review.

Not allowed:

- Production Progress changes.
- Production navigation changes except the minimum DEBUG Design System Lab entry.
- Production models.
- Persistence.
- Analytics.
- Recovery scoring.
- Readiness scoring.
- Workout logging.
- Completion flow changes.
- Today flow changes.
- ActiveWorkout flow changes.
- Plan generation changes.
- Widget, Watch, Live Activity, or HealthKit changes.
- Staging, committing, or pushing.

The prototype must not import demo logic into production Progress later without a separate approved production plan.

## 9. Screenshot Checklist

Capture:

- Large iPhone first viewport for all 12 states.
- Small iPhone first viewport for all 12 states.
- Large iPhone lower scroll.
- Small iPhone lower scroll.
- DEBUG state switcher.
- DEBUG Design System Lab entry.
- Reduce Motion fallback for at least normal week and PR / best set.

Reject screenshots if:

- Text clips, overlaps, or becomes unreadable.
- First viewport reads like a generic analytics dashboard.
- A global score dominates the hero.
- Charts dominate above the fold.
- Copy sounds scientific, internal, or translated from debug notes.
- PRs are overclaimed.
- Gold appears outside PR / best set.
- Muscle coverage implies exact percentages.
- Recovery sounds medical or diagnostic.
- Red is used as decoration.
- The target-overhit clustered week looks like the default Progress state.
- The next move competes with Today.
- The prototype feels like ActiveWorkout logging.

Approval question for every screenshot:

`Kann ein Nutzer in 10 Sekunden sagen: was steht, was bildet sich, was fehlt, und was ist der nächste sinnvolle Schritt?`

## 10. Final DEBUG Implementation Prompt

```text
Build a DEBUG-only Progress / Training Map prototype from:

- docs/qa/progress-prototype-brief-v1-2026-05-21.md
- docs/qa/progress-training-map-redesign-plan-2026-05-21.md
- /Users/simplemax/Documents/progress_reference_matrix_report_full.md

Do not edit production Progress.
Do not change production data models.
Do not change persistence.
Do not change analytics.
Do not change workout logging.
Do not change recovery or readiness scoring.
Do not change Today, ActiveWorkout, Completion, plan generation, Widget, Watch, Live Activity, or HealthKit.
Do not stage, commit, or push.

Create only a DEBUG-only prototype view with local demo data and expose it only through a DEBUG-only Design System Lab entry.

The prototype must include:

1. First viewport structure:
   - compact header
   - hero state
   - Training Map visual
   - proof row
   - next move card

2. Lower scroll structure:
   - Was steht
   - Was sich bildet
   - Was fehlt
   - Letzte Belege
   - Nächster Schritt

3. DEBUG state switcher with exactly these states:
   - Low data
   - Normal week
   - Target hit
   - Target overhit / clustered week
   - Volume up
   - PR / best set
   - Recovery low
   - Deload week
   - Plateau
   - Comeback week
   - Consistent rhythm
   - Muscle coverage forming

Use German, gym-native, short premium copy. Do not use:

- Evidence Signal
- Claim
- Trust now
- Signal Readiness
- exact muscle-balance percentages
- medical recovery claims
- fake precision

Use color semantics exactly:

- green = proven / completed
- amber = forming / watch
- gold = PR / best set only
- red = real caution / recovery limited, sparingly
- blue/steel = context
- gray = locked / not enough data

Use SwiftUI-native V0 motion only:

- map node lights up
- PR node gold reveal
- evidence card settles in
- Reduce Motion fallback

After implementation, capture screenshots:

- large iPhone first viewport for all states
- small iPhone first viewport for all states
- lower scroll on large and small iPhone
- DEBUG state switcher
- DEBUG Design System Lab entry

Reject and revise if the prototype is clipped, dashboard-like, fake precise, too generic, score-first, social-first, avatar-led, medically framed, or if it competes with Today / ActiveWorkout / Completion.

Production Progress remains blocked until DEBUG prototype screenshots are approved.
```
