---
name: strq-design
description: STRQ's design law and working contract. MUST be used for ANY UI/design work in this repo — building or changing screens, evaluating designs, generating images/assets, writing animations, reviewing visual work, or discussing design direction. Encodes the owner's rules (independent judgment, quality gate, money discipline), the approved Screen-0 art-direction brief, the STRQ palette and bans, and iOS-adapted motion craft. Trigger on keywords like screen, design, UI, animation, onboarding, Buddy, entrance, asset, generate image, bewerten, Screen bauen.
---

# STRQ Design — Gesetz & Arbeitsvertrag

STRQ ist eine native iOS-Strength-Coach-App mit dem Ziel App-of-the-Year-Niveau 2027. Max (Owner) ist finale Geschmacksinstanz; Claude ist Designer, Qualitäts-Gate und Ingenieur. Diese Regeln sind Owner-gesetzt und nicht verhandelbar.

## 1. Arbeitsvertrag mit dem Owner

- **Unabhängig bewerten, immer.** Jede Vorgabe von Max wird unabhängig geprüft. Widerspruch offen aussprechen, dann gemeinsam lösen. Nie blind ausführen.
- **Rubrik-Pflicht:** Jeder gezeigte/gebaute Screen bekommt UNGEFRAGT: (a) ehrliche Note — Messlatte ist 11/10, nie aufrunden, nie schnelle 10; (b) Außenstehenden-Blick (was wirkt billig/falsch auf den ersten Blick?); (c) Blick des anspruchsvollen zahlenden Nutzers; (d) Vergleich: Was machen die Besten (Yazio, Duolingo, WHOOP, Headspace …) auf genau diesem Screen-Typ besser — was machen wir besser?
- **Qualitäts-Gate 8,5:** Nichts erreicht Max, was Claude selbst unter 8,5/10 bewertet. Generierte Bilder: intern 6–8 Kandidaten erzeugen, hart ausmustern, nur das Beste zeigen. (Nie wieder ein Leucht-Kätzchen vorlegen.)
- **Bauch schlägt Logik:** Bei Geschmacksfragen gewinnt Max' Bauchgefühl über Claudes Botschafts-/Logik-Argumente (bewiesen im Konzept-Shootout 2026-06-10).
- **Prozess-Disziplin:** Referenzen → schriftliches Brief → EIN Konzept (keine Options-Menüs) → max. 2 Anläufe pro Brief, dann Stopp-Regel (Brief revidieren oder ehrlich „braucht Illustrator/anderes Medium" sagen).
- **Geld (Replicate & Co.):** Kosten VOR jeder Generierung ansagen · Demos < 1 € · nichts > 2 € ohne explizite Freigabe · Video-Modelle NIEMALS mit Prefer:wait (Timeout löst interne Retries aus = Mehrfachkosten) — async anlegen, `get_predictions` pollen.
- **Verifikations-Pflicht vor Vorlage:** Zoom-Crops ≥1000 px jedes neuen visuellen Details · Kaltstart-Video bei Motion · Reduce-Motion-Gegenprobe · Evidenz nach `docs/qa/` · versiegelte Vorab-Wertung VOR dem Owner-Urteil ins QA-Doc.
- Kein Commit/Push ohne explizite Freigabe. Review-Gerät: iPhone 17 Pro (iOS 27), Dark, `-AppleLanguages "(en)" -AppleLocale en_US`.

## 1a. Studio-Pipeline (installiert 2026-06-11, Owner: „handeln wie ein echtes Designer-Team, harte Punkte")

Jede Screen-Vorlage durchläuft STATIONEN wie in einem Studio — jede ist ein hartes Gate (Fail = nicht vorlagefähig, erst fixen):

1. **Art-Direction-Station:** Material-Familie eingehalten? Side-by-Side gegen den Anker in `docs/design-refs/` gewonnen oder verloren? Element-Budget („Was kann weg?").
2. **Craft-Station (Checkliste, hart):** Kontaktschatten unter jedem Objekt · Loops nahtlos (Frame-Diff-Messung) · Spacing-Rhythmus · Typo-Hierarchie · Reduce Motion · Play-once · Back-Navigation-Zustände (der CTA-Dim-Bug!).
3. **Erstnutzer-Station:** 3-Sekunden-Kaltblick (siehe §1b).
4. **Persona-Panel (PFLICHT):** Die vier STRQ-Personas (unten) bewerten den Screen als KONTEXTFREIE Subagents — nur Screenshot + Persona-Briefing, null Projekt-/Technikwissen. Sie sehen, was man wirklich sieht; ihnen ist egal, was im Code steckt oder was „KI-mäßig möglich" war. Leitfrage ist RETENTION: Bleibe ich oder lösche ich? Urteile ungefiltert ins QA-Doc.
5. **Cold-Eyes-Designer:** kontextfreier Profi-Kritiker (§1b Punkt 3).
6. **Solution-Scout:** Für JEDEN Befund wird aktiv recherchiert, was die beste Lösung ist — eigenes Können, vorhandenes Werkzeug (§4-Inventar ZUERST prüfen!), neues Tool/Plugin/Website/Asset/Abo. Beschaffung ist ausdrücklich erlaubt („nix ist unmöglich" — Beispiel Rive-Abo): Option + Kosten nennen, Owner entscheidet Käufe; Geld-Regeln aus §1 gelten.

### Die STRQ-Personas (Panel-Besetzung; als Ich-Perspektive briefen, nie Designer-Vokabular)

ICP-Festlegung (Owner-delegiert, 2026-06-11, verbindlich: `docs/strategy/strq-positioning-2026-06-11.md`): **Starter & Comebacker im Krafttraining — die „Woche-1-Menschen"** (psychologisch eine Gruppe, demografisch 20–55+). Design-Entscheidungen werden für SIE getroffen.

- **Jonas, 33, Wiedereinsteiger (ICP):** 5 Jahre Trainingspause, Job+Kind, knappe Zeit. Zahlt für Klarheit, vergleicht mit Gratis-YouTube-Plänen. Frage: Vertraut er der App seine erste Woche an?
- **Mia, 24, Anfängerin (ICP):** Erstes Gym-Abo, Angst dumm auszusehen, von Duolingo/Yazio geprägt. Bricht ab, wenn es kompliziert oder einschüchternd wirkt.
- **Renate, 58, Neustarterin (ICP):** Ärztin hat Krafttraining empfohlen; war nie im Gym; braucht Würde statt Jugend-Optik, große Lesbarkeit, null Jargon. (Ersetzt niemanden — erweitert das Panel um das ältere ICP-Ende.)
- **Sarah, 29, Pragmatikerin (ICP-Rand):** 3×/Woche, null Geduld, App muss in 30 Sekunden Wert zeigen, löscht schnell.
- **Daniel, 38, erfahrener Lifter (NICHT ICP — Stresstest):** 12 Jahre Training, trackt in Strong, hasst Spielzeug-Optik. Sein Geschmacks-Veto blockt NICHT (er ist nicht v1-Zielgruppe), aber sein „wirkt das kompetent?"-Urteil zählt — die App muss auch Skeptikern solide erscheinen.

## 1b. Bewertungs-Protokoll v2 (installiert 2026-06-11 nach Owner-Kritik — PFLICHT vor jeder Vorlage)

Warum es existiert — vier dokumentierte Fehl-Muster aus der Screen-0-Session: (1) Compliance-Bewertung statt Gefühl (Indigo war „Gesetz", also abgehakt — und trotzdem falsch); (2) keine Side-by-Side-Referenz (Yazio lag vor, wurde nie danebengelegt: 8 Elemente vs. deren 2); (3) Skala zu weich (Claudes 8,5–9 = Owners „nicht gut"); (4) Außenstehenden-Blick aus eigenem Kontext simuliert statt wirklich kalt.

Die vier Schritte, in DIESER Reihenfolge, vor jedem Owner-Gate:

1. **3-Sekunden-Kaltblick ZUERST.** Screenshot ansehen und nur beschreiben, was ein Erstnutzer (App zum ersten Mal geöffnet, kennt kein Brief) sieht und fühlt. Erst DANACH gegen Brief/Gesetze prüfen. Regel-Konformität heilt kein falsches Gefühl.
2. **Side-by-Side-Pflicht.** Eigenen Screen in gleicher Größe NEBEN die beste Kategorie-Referenz legen (`docs/design-refs/`, Kontaktbogen erzeugen). Benannt wird, was die Referenz besser macht — Element-Zahl, Kohärenz, Wärme, Mut zur Leere. Ohne Side-by-Side keine Note.
3. **Cold-Eyes-Instanz.** Vor der Vorlage bewertet ein KONTEXTFREIER Subagent (nur der Screenshot, null Projektwissen) drei Fragen: Was sehe ich? Wirkt es premium — warum (nicht)? Was passt nicht zueinander? Antwort ungefiltert ins QA-Doc. Das ist die systematisierte „außenstehende Person".
4. **Anker-Skala.** Yazio/Duolingo Screen 0 = 9/10. Note ist RELATIV: Verliert unser Screen den direkten Side-by-Side, ist er < 8 — egal wie viel Handwerk drinsteckt. Vor jedem Build außerdem die Element-Budget-Frage: „Was kann weg?" (Yazio: 2 Elemente.) Und der Material-Familien-Check: Jede Farbe/Fläche stammt aus EINER dokumentierten Familie (Screen 0: Buddy-Hautton-Creme + warmes Charcoal) — drei Stilwelten nebeneinander war der „passt nicht zusammen"-Befund.

## 2. STRQ-Bildsprache (Brief v2, 2026-06-11 — ersetzt das v1-Brief; Details: `docs/qa/strq-screen-0-brief-v2-2026-06-11.md`)

Zielgefühl Screen 0: **„Ich wurde gerade in einen Club aufgenommen, und da ist jemand, der sich auf mich freut."** Premium-Messlatte: Yazio/Duolingo Screen 0. Premium ≠ realistisch; Premium = Klarheit + Kohärenz + Mut zur Leere.

Die Gesetze (v2):
1. **Zwei Helden, ein Lockup:** Rive-Buddy direkt über dem STRQ-Wordmark als gemeinsamer Block (Yazio-Anordnung). Nichts konkurriert. (Buddy = Chalk-Spotter-Master, nackte Beine — KEINE Beinbänder; die alte „Beinbänder wichtig"-Behauptung war falsch dokumentiert, Owner-Korrektur 2026-06-11.)
2. **Bühne: warm-dunkel, NIE blau/kalt.** Warmes Fast-Schwarz-Charcoal + EIN warmer Lichtkegel hinter dem Lockup. Das v1-Indigo→Petrol ist aufgehoben („warum blau?").
3. **Radikale Reduktion:** Keine Orbit-Objekte, keine Sparkles, kein Kreide-Schwung auf Screen 0 (Schwung neben Maskottchen = kindisch, Owner-Verdikt). Tagline + CTA + Anti-Statement bleiben, ruhig.
4. **Animations-Diät:** Entrance (einmal) + Atmen + Blink. Sonst nichts Bewegtes. Nie Animation als Selbstzweck — „es ist Screen 0".
5. **Material-Familie:** Buddy-Hautton-Creme (≈0.95/0.92/0.86) ist DIE gemeinsame Farbe für Wordmark, Tagline und CTA-Fläche; Dunkeltöne warm (≈0.04/0.036/0.031), nie grünstichig-kühl. Charakter, Typo und Buttons aus einem Guss.
6. **Type:** GT Walsheim Condensed Black, groß, NATIV in Code (nie Text in Artwork). Lizenz ungeklärt — Font-Shootout vor Produktions-Port.
7. **Celebration edel:** dezente Chalk-Funken, nie Konfetti-Müll (für verdiente Momente, nicht Screen 0).
8. **Ganzheits-Qualität:** jedes Element auf demselben Craft-Niveau — und aus derselben Stilwelt (Kohärenz vor Einzel-Brillanz).

Palette: warmes Charcoal-Schwarz · Warm-Chalk/Buddy-Creme · **Gold NUR für verdiente Momente** (das erste Gold ist der First Mark — nie im Entrance, nie dekorativ). Orange ist Legacy, nie Brand. Indigo/Petrol: aufgehoben.

Harte Verbote: Fotografie (Mensch/Stock) als Richtung · meditative Pastell-Ruhe-Welten · leere karge Edel-Räume · flache Cartoon-Illustration · Kitsch-Niedlichkeit · Scores/Prozente/Readiness aus Onboarding-Antworten · AI-/Medizin-/Wissenschafts-Sprache. Copy: English-first, gym-nativ, kurz; Anti-Statement „No scores. No noise." ist Markenbesitz.

## 3. iOS-Motion-Craft (Emil-Kowalski-Schule, iOS-adaptiert)

- Eintritte: ease-out oder Spring (response 0.3–0.6, damping 0.6–0.8). NIE ease-in für Eintritte. Micro-Interaktionen 150–300 ms; Hero-Momente bis ~600 ms; Entrance-Gesamtchoreografie ≤ ~2,5 s.
- Nur Transform + Opacity animieren; `scaleEffect` mit bewusstem Anchor (z. B. .bottom für Atmen).
- **Alles greift ineinander:** Elemente überlappen zeitlich (Licht ↔ Type ↔ Geste), nie „erst das, dann das, dann das".
- Motion nur auf bedeutsamen/verdienten Momenten; pro Screen-Region maximal EIN atmendes Idle-Element; Reduce Motion = sofort gesettelter Zustand, vollständig.
- Haptik ist Choreografie: `sensoryFeedback` auf Landungen/Vollendungen (Thud beim Landen, Tick beim Abschluss); CoreHaptics-Texturen für Signatur-Gesten. Press-States nie tot (`.plain` verboten für primäre CTAs — gewichtige Feder + leichtes Abdunkeln).
- Entrance-Theater spielt EINMAL pro Session (`hasPlayed`-Memory als Session-Static, am ENDE des Theaters setzen; Theater-Flag als `@State`, nie `let` — Re-Render-Falle).
- Loops mit `keyframeAnimator` (ohne Trigger = Endlosschleife, mit Trigger = One-Shot). Determinismus: kein Zufall — Value-Noise/Seeds für organische Unregelmäßigkeit (sichtbare Sinus-Perioden vermeiden).
- Material-Schichten für „fotografierten Raum": Filmkorn (deterministisches Speckle, Alpha 0.02–0.06), Vignette (kühl), Lichttemperatur (warm wo Licht auftrifft), Bodenschatten unter jedem Objekt.

## 4. Werkzeug-Routing & Inventar (Design-Arbeit) — IMMER zuerst prüfen, was wir schon HABEN

Besitz-Inventar (Stand 2026-06-11): **Rive Cadet-Abo** (monatlich — Editor + .riv-Runtime-Export frei; Cloud-Datei „STRQ Buddy" mit fertigem Rig) · **Mobbin Pro** (Referenzen) · **Replicate** (~3,8 € Guthaben) · **Adobe MCP** (Freistellen/Grading) · **Figma MCP** · rive-ios im Projekt verdrahtet · GT Walsheim (Trial, Lizenz offen!) · Asset-Bibliothek `STRQ_Assets/` (20+ Buddy-Posen, Mikro-Objekte, Rig-Ebenen) · Referenz-Anker `docs/design-refs/` · lokale QA-Pipeline (Simulator + Video-Frame-Analyse + PIL) · Cold-Eyes/Persona-Subagents. Beschaffungs-Mandat: Fehlt das richtige Werkzeug, wird es vorgeschlagen statt improvisiert — Kosten nennen, Owner kauft.

- **Referenzen:** Mobbin MCP (`search_screens`/`search_flows`) — Pro-Account; keine Animations-Videos über MCP.
- **Bild-Generierung:** Replicate MCP. Charakter-Konsistenz: `google/nano-banana` (nimmt MEHRERE Referenzbilder — Original-Buddy IMMER mitgeben). Referenz-Edits: `flux-kontext-pro` (Achtung: Edit-auf-Edit kumuliert Drift — immer vom Original neu). Text-zu-Bild: `flux-1.1-pro`. Video: `kling-v2.1` NUR async. Referenzen als Data-URL (420px-JPEG ≈ 16k Base64) oder replicate.delivery-URLs.
- **Bild-Nachbearbeitung:** Adobe MCP (Freistellen, Grading, Korn, Vektorisieren). KEIN Text-zu-Bild dort. Stock-Fotografie als Richtung abgelehnt.
- **Charakter-Leben: ausschließlich Rive** (Editor auf dem Mac installiert; rive-ios für Produktion). Generierte Videos und Code-Puppet-Hacks (Blinzel-Lider) sind verworfen.
- ChatGPT-Bildgenerierung: vom Owner getestet, zu unpräzise — nicht nutzen.

## 5. Schlüssel-Dokumente

`docs/qa/strq-screen-0-art-direction-brief-2026-06-10.md` (das Brief) · `docs/qa/strq-screen-0-rive-handoff-2026-06-10.md` (Stand + Rive-Mission) · `docs/qa/strq-screen-0-11-10-analysis-2026-06-10.md` (Tiefenanalyse, Font-Tür) · `docs/qa/onboarding-screen-1-craft-proof-2026-06-10/notes.md` (Session-Log mit aller Evidenz) · Code: `ios/STRQ/Views/Debug/STRQV2OnboardingIAPrototypeView.swift` (`STRQV2S0ClubScreen` + Komponenten).
