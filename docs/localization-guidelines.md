# STRQ Localization Guidelines

STRQ uses English as the base language. German localization should sound natural for gym users in Germany and should not feel over-translated.

## Core rule for exercise names

Exercise names should only be translated when the German term is genuinely common in the German gym environment.

Do not translate exercise names just because a literal German word exists. Many German gym users naturally use English exercise names, especially for common strength-training movements.

## Preferred approach

- Keep internationally common gym terms in English when they are widely used in German gyms.
- Use German names only where they are clearly established and sound natural.
- Avoid awkward literal translations.
- Keep names short enough for small UI surfaces, especially Apple Watch, widgets, Live Activities, and workout cards.
- Keep technical consistency across the app, widgets, and watch app.

## Examples

### Usually keep English

- Bench Press
- Incline Bench Press
- Chest Press
- Shoulder Press
- Leg Press
- Hip Thrust
- Deadlift
- Romanian Deadlift
- Cable Row
- Face Pull
- Pushdown
- Lat Pulldown may also stay English if the existing exercise library uses that convention.

### German is usually acceptable

- Kniebeuge for Squat
- Kreuzheben for Deadlift, only if the library generally uses German naming
- Bankdrücken for Bench Press, only if the surrounding German exercise names also follow that style
- Latziehen for Lat Pulldown
- Rudern for Row variants where it remains clear
- Beinpresse for Leg Press
- Schulterdrücken for Shoulder Press
- Bizepscurls or Curls for Biceps Curl
- Trizepsdrücken for Triceps Pushdown, if it sounds natural in context

## Decision rule

If the German translation sounds like something a real gym member would say naturally, use it.
If it sounds artificial, too long, or overly technical, keep the English name.

## Important

Do not rename exercise IDs, internal identifiers, analytics event names, product IDs, or data model values. Only localize visible user-facing labels.