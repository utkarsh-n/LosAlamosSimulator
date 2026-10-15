# Los Alamos Simulator

A native SwiftUI iPhone learning app about Trinity, fission, and chain reactions. Requires iOS 26 or later. Designed with Metro Station: near-black metal instruments, cyan signal ink, amber events, quiet explanatory panels, and native Liquid Glass controls.

## Explore

- **Trinity:** scrub a 30-second schematic sequence from first light to a rising cloud; pause, replay, change playback speed, jump to a phase, or adjust time in 0.1-second steps.
- **Fission:** manually walk through neutron approach, capture, deformation, splitting, and fragment recoil. Inspect the approximate energy per fission and its mass equivalent.
- **Chain:** vary an abstract average continuation factor, compare fading/steady/growing expectations, and step through 12 generations on a quantitative chart.
- **Field Notes:** verified historical context, source links, downwind communities, model limits, and interactive knowledge checks.

This is an educational illustration, not a reconstruction of a nuclear device or a validated explosion model. The visual cloud and ring have no physical scale. The branching model assumes a constant abstract factor and gives expected populations rather than individual trials. It has no material quantities, assembly or triggering parameters, blast damage, exposure, or fallout calculations. Historical yield estimates are reference text only.

## Build

```sh
xcodegen generate
open LosAlamosSimulator.xcodeproj
```

Select the `LosAlamosSimulator` scheme and an iPhone destination. The project uses the locally established automatic signing team. No account or network is required for app features; source links open the browser.

Pure model checks:

```sh
swift test
```

Simulator UI checks are in `UITests/LosAlamosSimulatorUITests.swift`. Reduce Motion stops automatic playback and keeps manual exploration available. Controls and readouts stay independent of decorative drawing. Native feedback signals accepted steps; physical haptic quality needs hands-on device verification.

Research and provenance: [Documentation/Research.md](Documentation/Research.md).

See [Documentation/Validation.md](Documentation/Validation.md) for this build's actual verification evidence.

Signed Release version **1.0 (1)** is installed on the physical iPhone 15 Pro Max running iOS 27.2. The user opened it from its Home Screen icon and confirmed that it stays open. Detailed feature, haptic and hardware accessibility checks remain pending; the validation notes preserve the separate build, installation, launch and test evidence.


## Public snapshot

See [PUBLICATION.md](PUBLICATION.md) for publication exclusions and setup requirements.
