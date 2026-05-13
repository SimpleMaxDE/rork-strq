# STRQ Onboarding V2 QA

- Commit at capture: `7780471b37dfb5b31c73bbe53c5936ac8972edce`
- Xcode: Xcode 26.5 Build version 17F42 
- Primary simulator: iPhone 17 Pro
- Small simulator: iPhone 17e
- Build/test result: `xcodebuild test passed`
- Harness: `STRQCoreFlowSnapshotTests.testOnboardingFlowSnapshot`, `testOnboardingMatrixSnapshot`, and `testOnboardingSmallPhoneSnapshot`
- Contact sheet: `contact-sheet.jpg`

## Required Screenshots

- `00-welcome.png`
- `01-about-name-empty-or-validation.png`
- `02-about-name-filled.png`
- `03-goal.png`
- `04-training.png`
- `05-setup-equipment.png`
- `06-focus.png`
- `07-lifestyle-final-cta.png`
- `08-generation.png`
- `09-reveal.png`
- `10-small-iphone-welcome.png`
- `11-small-iphone-dense-step.png`

## Supplemental Scroll Checks

- `04-training-lower.png`
- `05-setup-equipment-lower.png`
- `07-lifestyle-final-cta-lower.png`

## Matrix Screenshots

- Count: `77`
- `matrix-about-age-sheet.png`
- `matrix-about-gender-female.png`
- `matrix-about-gender-male.png`
- `matrix-about-gender-other.png`
- `matrix-about-gender-prefernottosay.png`
- `matrix-body-metric-body-fat-sheet.png`
- `matrix-body-metric-height-sheet.png`
- `matrix-body-metric-target-weight-sheet.png`
- `matrix-body-metric-weight-sheet.png`
- `matrix-focus-default.png`
- `matrix-goal-athleticperformance.png`
- `matrix-goal-endurance.png`
- `matrix-goal-fatloss.png`
- `matrix-goal-flexibility.png`
- `matrix-goal-generalfitness.png`
- `matrix-goal-musclegain.png`
- `matrix-goal-rehabilitation.png`
- `matrix-goal-strength.png`
- `matrix-lifestyle-activity-extremelyactive.png`
- `matrix-lifestyle-activity-lightlyactive.png`
- `matrix-lifestyle-activity-moderatelyactive.png`
- `matrix-lifestyle-activity-sedentary.png`
- `matrix-lifestyle-activity-veryactive.png`
- `matrix-lifestyle-recovery-high.png`
- `matrix-lifestyle-recovery-low.png`
- `matrix-lifestyle-recovery-moderate.png`
- `matrix-lifestyle-sleep-excellent.png`
- `matrix-lifestyle-sleep-fair.png`
- `matrix-lifestyle-sleep-good.png`
- `matrix-lifestyle-sleep-poor.png`
- `matrix-lifestyle-stress-high.png`
- `matrix-lifestyle-stress-low.png`
- `matrix-lifestyle-stress-moderate.png`
- `matrix-lifestyle-stress-veryhigh.png`
- `matrix-setup-equipment-abwheel.png`
- `matrix-setup-equipment-bench.png`
- `matrix-setup-equipment-dumbbell.png`
- `matrix-setup-equipment-foamroller.png`
- `matrix-setup-equipment-kettlebell.png`
- `matrix-setup-equipment-mat.png`
- `matrix-setup-equipment-pullupbar.png`
- `matrix-setup-equipment-resistanceband.png`
- `matrix-setup-equipment-rings.png`
- `matrix-setup-equipment-stabilityball.png`
- `matrix-setup-equipment-trx.png`
- `matrix-setup-injury-ankle.png`
- `matrix-setup-injury-elbow.png`
- `matrix-setup-injury-hip.png`
- `matrix-setup-injury-knee.png`
- `matrix-setup-injury-lower-back.png`
- `matrix-setup-injury-neck.png`
- `matrix-setup-injury-shoulder.png`
- `matrix-setup-injury-wrist.png`
- `matrix-setup-location-gym.png`
- `matrix-setup-location-homegym.png`
- `matrix-setup-location-homenoequipment.png`
- `matrix-training-days-1.png`
- `matrix-training-days-2.png`
- `matrix-training-days-3.png`
- `matrix-training-days-4.png`
- `matrix-training-days-5.png`
- `matrix-training-days-6.png`
- `matrix-training-level-advanced.png`
- `matrix-training-level-beginner.png`
- `matrix-training-level-intermediate.png`
- `matrix-training-minutes-120.png`
- `matrix-training-minutes-30.png`
- `matrix-training-minutes-45.png`
- `matrix-training-minutes-60.png`
- `matrix-training-minutes-75.png`
- `matrix-training-minutes-90.png`
- `matrix-training-split-automatic.png`
- `matrix-training-split-bodypart.png`
- `matrix-training-split-fullbody.png`
- `matrix-training-split-musclegroup.png`
- `matrix-training-split-pushpulllegs.png`
- `matrix-training-split-upperlower.png`

## QA Checklist

- Name-only validation: covered by XCTest.
- All onboarding steps and fields: covered by XCTest label assertions plus scroll screenshots on dense steps.
- Clickable onboarding choices: covered by the matrix harness where identifiers are available in `OnboardingView.swift`.
- Final CTA enters PlanGenerationView: covered by XCTest.
- PlanRevealView appears: covered by XCTest.
- Paywall/pricing/locked-premium copy: covered by XCTest label assertions.
- Visual clipping/overlap/readability: manual review completed from required, supplemental, matrix, and contact-sheet screenshots. No blocking onboarding-shell issues found.
- PlanGenerationView and PlanRevealView were captured for verification only and not edited.
