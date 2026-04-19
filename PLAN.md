# Native Feel + Real Device Polish pass

A focused polish pass to make STRQ feel more tactile, finished, and iPhone-native in actual use. No new features, no redesign, identity preserved.

**Tap & Press Feedback**
- Unified pressed-state for all primary cards, rows, and choice tiles — subtle scale + dim on touch down, instant release.
- Consistent haptic language: light tick for selections, medium for confirmations, success haptic on set logged and workout completed, warning on destructive actions.
- All tappable rows get proper touch-down highlight instead of dead taps.

**Selection States**
- Onboarding choice tiles: stronger selected border, filled check affordance, clearer unselected vs selected contrast.
- Session editor rows: clearer active edit state, pressed state, and coach-vs-custom badge alignment.
- Library filters & segmented controls: tighter selected indicator, smoother cross-fade between options.

**Sheets & Modals**
- All sheets use consistent detents, grabber visibility, and corner treatment.
- Content-aware sheet heights (exercise swap, set notes, rest timer) so sheets don't feel oversized.
- Scrollable sheets get proper presentationContentInteraction so swipe scrolls content, not the sheet.
- Dismiss gestures feel native everywhere.

**Transitions & Navigation**
- Push/pop transitions feel consistent across Train, Library, Progress, and Profile stacks.
- Plan reveal and completion flow get calmer, more confident enter/exit motion.
- Tab switches stay instant; no jank when returning from deep stacks.

**Active Workout Polish**
- Set-logged confirmation: tighter micro-motion, success tick haptic, row highlight that settles quickly.
- Rest timer sheet presents and dismisses more smoothly, with subtle countdown motion.
- Weight/reps steppers get firmer press feedback and repeat-tap rhythm.
- Sticky bottom CTA respects home indicator and keyboard safely.

**Row Interactions**
- History rows, exercise rows, and plan rows get unified press feedback and disclosure behavior.
- Swipe actions (where present) feel native with proper resistance.

**Completion Flow**
- Entry animation into completion screen feels earned but calm — slight stagger, no noisy particles.
- Highlight cards reveal with a gentle sequence, then settle.
- Dismiss returns cleanly to Today without stack flicker.

**Real-Device Ergonomics**
- All primary actions sit within comfortable thumb reach.
- Minimum 44pt touch targets verified across dense rows and editor controls.
- Safe-area and home-indicator spacing consistent across sheets and sticky CTAs.
- Scroll rhythm tuned — no layouts that jump when content loads.

**Micro-Motion Guardrails**
- Springs unified across the app (one response/damping baseline).
- No animation longer than it needs to be; no decorative motion.
- Respect Reduce Motion setting everywhere new motion was added.

**Consistency Sweep**
- Button hierarchy (primary / secondary / tertiary) behaves identically in onboarding, editor, logger, and completion.
- Status accents, chevrons, and disclosure indicators aligned system-wide.
- Identical pressed/selected/disabled language across all modules.

STRQ keeps its dark premium identity, semantic palette, strong typography, and coach authority — this pass only sharpens how it feels in the hand.