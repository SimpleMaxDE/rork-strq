# STRQ UI Direction Options

Last updated: 2026-04-30

## Purpose

This document presents possible STRQ visual directions before production UI migration begins. It does not select a final direction and does not authorize copying a Figma screen.

The Purchased Figma UI Kit should provide foundations, components, and patterns. STRQ should remain an ownable training product with its own identity, intelligence, copy, data, and runtime behavior.

Related control docs:

- [Docs README](README.md)
- [STRQ UI Migration Master Plan](strq-ui-migration-master-plan.md)
- [Figma Source Map](figma-source-map.md)
- [Design System Import Plan](design-system-import-plan.md)
- [Component Migration Plan](component-migration-plan.md)

## Current STRQ Direction

Current STRQ production UI leans dark, high-contrast, gym-focused, and utilitarian. It uses `STRQPalette`, `STRQBrand`, Forge surfaces, steel/energy accents, gradient CTAs, card surfaces, and many SF Symbols. It is functional and tied closely to production behavior, but the visual system is mixed and not yet governed by a single professional component foundation.

Current risks:

- mixed `STRQPalette`, Forge, and isolated `STRQDesignSystem` foundations
- inconsistent icon language
- dense screens without shared card/list/input primitives
- missing Work Sans binaries for exact Figma type fidelity
- temptation to copy Figma screens that do not fit STRQ product behavior

## Direction 1: Carbon Training Console

Visual description:

Dark carbon surfaces, restrained black/white/graphite contrast, crisp borders, compact cards, high information density, and sparing warm/action accents. This direction treats STRQ as a serious training tool rather than a lifestyle app.

Pros:

- strongest fit for gym/training tracker use
- supports dense Dashboard, Active Workout, Progress, and Exercise Library views
- keeps visual hierarchy quiet and repeatable
- works well with Figma dark mode foundations and app components

Cons:

- can feel too severe if reward/onboarding surfaces are not warmed up
- requires careful contrast and accessibility tuning
- less expressive for marketing-like onboarding moments

Where it fits:

- Today/Dashboard
- Train
- Active Workout
- Progress
- Exercise Detail
- Profile/settings

Risk:

- Medium. It is the safest product fit, but can become visually flat without strong typography, icon, and state design.

Figma support:

- `Main - Dark Mode`
- Home & Smart Fitness Metrics `11604:62728`
- app-specific cards `9160:324200`
- progress/chart components
- tab bar/navigation/list item/card components

User decisions needed:

- approve dark-first direction
- decide whether warm/orange remains the primary action accent
- decide how much gradient/glow is allowed

## Direction 2: Monochrome With Semantic Accent

Visual description:

Primarily black/white/gray with semantic color reserved for training state: success, warning, danger, recovery, sleep, readiness, and progress. Accent color becomes meaningful rather than decorative.

Pros:

- very ownable for STRQ
- reduces dependency on the UI kit's warm brand tone
- makes data/state colors more trustworthy
- supports analytics and readiness clarity

Cons:

- may feel less premium if typography and spacing are not strong
- requires a careful semantic color system
- onboarding and reward moments may need a separate emotional layer

Where it fits:

- Progress/Analytics
- readiness and sleep
- coach insights
- settings
- exercise data and muscle focus

Risk:

- Medium. The direction is durable, but only if token mapping is rigorous.

Figma support:

- semantic variables with Light/Dark modes
- chart/progress components
- health metric cards
- list/form/input primitives

User decisions needed:

- choose primary action accent
- define semantic color meanings
- decide whether brand accent is warm, steel, green, or custom STRQ

## Direction 3: Warm Performance System

Visual description:

Dark STRQ base with controlled warm orange/amber action accents, progress highlights, selected states, and reward moments. This borrows more from the Purchased Figma UI Kit source palette while keeping STRQ-owned runtime naming and STRQ layouts.

Pros:

- closest to purchased kit energy
- gives CTAs and reward states more lift
- useful for onboarding, workout completion, achievements, and motivation

Cons:

- can look like a copied kit if overused
- warm accents can overwhelm dense training screens
- may conflict with STRQ's current steel/carbon feel

Where it fits:

- onboarding
- workout completion
- achievements
- paywall plan selection
- selected chips and primary CTAs

Risk:

- Medium/High. Needs restraint to avoid a one-note warm/orange palette.

Figma support:

- gradients
- warm semantic/brand variables
- pricing cards
- achievement badges
- progress and reward patterns

User decisions needed:

- approve warm accent as STRQ-owned brand/action color
- define where warm accent is allowed
- decide whether dashboard/active workout stay calmer than onboarding/rewards

## Direction 4: Premium Gym Intelligence

Visual description:

Dark premium surfaces, exacting spacing, strong typography, data-rich metric cards, quiet animation, and a sharper distinction between intelligence surfaces and logging surfaces. Coach and training insights feel high-trust and professional.

Pros:

- best fit for STRQ's training intelligence and coaching logic
- scales across coach, progression, analytics, and recovery
- can feel more differentiated than a generic fitness UI kit

Cons:

- needs more design decisions before implementation
- requires careful writing and component hierarchy
- more QA effort because many screens are information-dense

Where it fits:

- Coach
- Dashboard
- Progress
- Training plan
- Exercise detail
- paywall value presentation

Risk:

- High. High upside, but should be built from primitives and tested module-by-module.

Figma support:

- AI Fitness Coach screen groups
- smart metrics/home patterns
- chart/progress components
- health metric cards
- app-specific cards
- pricing cards

User decisions needed:

- approve intelligence-first visual hierarchy
- choose first proof module
- decide whether coach should feel conversational, analytical, or both

## Recommended Decision Path

Do not decide by copying a Figma screen. Decide by selecting:

1. base surface strategy: carbon, monochrome, or warm-dark
2. accent policy: warm action, semantic-only, or hybrid
3. typography policy: Work Sans or system fallback until fonts are available
4. first proof surface: settings row, metric card, exercise card, or reward card
5. asset policy: icons first, anatomy later, rewards only if productized

## Current Recommendation

The safest starting point is a hybrid of:

- Direction 1: Carbon Training Console for core app surfaces
- Direction 2: Monochrome With Semantic Accent for data/state clarity
- limited Direction 3 warmth for CTAs, selected states, and reward moments

This keeps STRQ ownable while still benefiting from the UI kit foundations.
