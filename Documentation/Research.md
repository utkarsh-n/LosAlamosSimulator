# Los Alamos Simulator — research and model boundaries

Verified on October 13, 2026. Source text is paraphrased; the app uses original vector drawing rather than historical photographs. Institution links are citations, not endorsement.

## Historical record

- [National Park Service, Trinity Site, NM](https://www.nps.gov/places/000/trinity-site.htm) supports July 16, 1945, 5:29 a.m. **Mountain War Time**, the Jornada del Muerto location, and trinitite. Trinity was a test site separate from Los Alamos. The app gives no seconds: official summaries differ in their rounding (the [NPS overview](https://www.nps.gov/mapr/learn/historyculture/trinity.htm) uses 5:30 a.m.).
- [Selby and colleagues’ original 2021 manuscript](https://arxiv.org/abs/2103.06258) reports **24.8 ± 2 kilotons TNT equivalent** and identifies the earlier DOE-released estimate as **21 kilotons**. The [LANL publication record](https://laro.lanl.gov/esploro/outputs/journalArticle/A-New-Yield-Assessment-for-the/9916394339803761) identifies the final journal article, *A New Yield Assessment for the Trinity Nuclear Test, 75 Years Later*, DOI [10.1080/00295450.2021.1932176](https://doi.org/10.1080/00295450.2021.1932176), LA-UR-21-20675. Both figures are historical estimates; the app retains the later uncertainty and does not use either figure to calibrate or tune its scene.

## Introductory physics

- [DOE Office of Science, The Strong Force](https://www.energy.gov/science/doe-explainsthe-strong-force) supports the electrical repulsion of protons and the short-range interaction binding a nucleus. [DOE radiation protection study guide, Module 1.04](https://www.energy.gov/documents/doe-hdbk-1122-99studyguidemodule104pdf), printed pages 1.04-4 through 1.04-8, supports binding energy, mass-energy and the lower binding energy per nucleon of very heavy nuclei. The fission lesson paraphrases these introductory principles without modeling nuclear structure or a device.

- [DOE Office of Science, Nuclear Fission](https://www.energy.gov/science/doe-explainsnuclear-fission) supports splitting a nucleus into smaller nuclei and other particles, the possibility of neutron-induced fission, and additional neutrons causing subsequent events. This app confines the physics to those introductory concepts.
- [DOE General Technical Base Qualification Standard Reference Guide](https://www.energy.gov/sites/prod/files/2013/10/f4/QSR-GeneralTechnicalBase.pdf), March 2012, nuclear fundamentals, printed pages 12–13 (PDF pages 20–21): approximately **200 MeV per fission** is a representative teaching value. Energy release varies by products and accounting convention. Energy appears in moving fragments, neutrons, prompt radiation, and subsequent decay. The app does not imply that 200 MeV is an exact universal prompt-energy value.
- NIST’s [electronvolt–joule relationship](https://physics.nist.gov/cgi-bin/cuu/Value?Revj) and [speed of light in vacuum](https://physics.nist.gov/cgi-bin/cuu/Value?c) give the exact SI conversion, 1 eV = 1.602176634 × 10⁻¹⁹ J, and c = 299792458 m/s. Applying them to the approximate 200 MeV input gives approximately 3.2 × 10⁻¹¹ J per event. Exact unit constants do not make the underlying event-energy approximation exact.
- [DOE History of Nuclear Energy](https://www.energy.gov/ne/history) supplies the high-level chain-reaction context. The app’s equation **E[N_g] = N₀ k^g**, with N₀ = 1, is an elementary mathematical expectation model selected for teaching. This equation is a model assumption, not a reconstruction of Trinity. Fractional expectations are averages over imagined runs; they are not fractional physical particles. At k = 1 the mean stays level without guaranteeing survival of every chain.

## Communities and environmental consequences

- [National Park Service, Trinity Test Downwinders](https://www.nps.gov/articles/000/trinity-test-downwinders.htm) supports the lack of advance warning, nearby inhabited communities, environmental contamination, and downwinders’ accounts of lasting consequences. The app does not reproduce the article’s construction details, exposure map, or historical compensation-law summary.
- [National Cancer Institute, community summary of its Trinity study](https://dceg.cancer.gov/research/how-we-study/exposure-assessment/trinity/community-summary) describes the research published in 2020, retrospective exposure reconstruction, projected excess cancer risk, substantial uncertainties and inability to attribute an individual cancer definitively. The app makes no exposure or cancer calculation and gives no individualized health conclusion. It does not equate projected excess cases with directly observed or individually identified cases.

## Deliberate abstraction

The Trinity view is a fixed 30-second narrative with dimensionless drawing envelopes. Flash, expansion and rising-cloud shapes communicate sequence only. Their dimensions, brightness, motion and timing are not validated measurements or physical estimates.

The chain lab shows a generic expected population by generation. It has no apparatus, geometry, material inventory, neutron-transport calculation, real generation duration, changing physical conditions or efficiency model. Its reproduction-factor control is an abstract lesson input.

The energy lab converts a representative single-event energy between units. It does not derive a material requirement, apparatus specification or detonation yield. Its rest-mass equivalence is an application of E = Δm c², not the mass of a physical nucleus, material sample or weapon.

The application includes no assembly or triggering model, weapon schematic, design parameters, operational optimization, calibrated blast dimensions, damage thresholds, fallout forecast, dose estimator or exposure map. All these boundaries should remain visible in the corresponding lesson as well as in the Field Guide.

## Design adaptation

The Field Guide uses Metro Station’s quiet dark panels, restrained cyan/amber/violet accents, rounded factual readouts and native text. Historical figures remain independent of animation. Source links and quiz answers have at least 44-point targets; prose and answers reflow with Dynamic Type. The guide needs native compilation and simulator/hardware review with the final host components; these design choices alone are not test evidence.
