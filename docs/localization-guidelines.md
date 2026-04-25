# STRQ Localization Guidelines

STRQ uses English as the base language. German localization should sound natural for gym users in Germany and should not feel over-translated.

## Core rule for exercise names

Exercise names should only be translated when the German term is genuinely common in the German gym environment.

Do not translate exercise names just because a literal German word exists. Many German gym users naturally use English exercise names, especially for common strength-training movements. At the same time, do not keep an English name if the German gym term is clearly standard and sounds natural.

## Preferred approach

- Use the German gym term when it is the normal term German users would expect.
- Keep internationally common gym terms in English when they are widely used in German gyms.
- Avoid awkward literal translations.
- Keep names short enough for small UI surfaces, especially Apple Watch, widgets, Live Activities, and workout cards.
- Keep technical consistency across the app, widgets, and watch app.

## Examples

### Prefer German when clearly standard

- Bankdrücken for Bench Press
- Schrägbankdrücken for Incline Bench Press
- Kniebeuge for Squat
- Kreuzheben for Deadlift
- Latziehen for Lat Pulldown
- Rudern for Row variants where it remains clear
- Beinpresse for Leg Press
- Schulterdrücken for Shoulder Press
- Bizepscurls or Curls for Biceps Curl
- Trizepsdrücken for Triceps Pushdown, if it sounds natural in context

### Usually keep English when it is more natural in German gyms

- Hip Thrust
- Romanian Deadlift, unless the app consistently uses a natural German alternative
- Cable Row, unless the app uses a clear variant like Kabelrudern
- Face Pull
- Pushdown, unless the German UI clearly uses Trizepsdrücken

## Decision rule

If the German translation sounds like something a real gym member would say naturally, use it.
If it sounds artificial, too long, or overly technical, keep the English name.

For example: **Bankdrücken** is the correct and preferred German term for **Bench Press**.

## Important

Do not rename exercise IDs, internal identifiers, analytics event names, product IDs, or data model values. Only localize visible user-facing labels.