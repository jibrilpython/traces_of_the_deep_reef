// ─── INSTRUMENT CLASSIFICATION ───────────────────────────────────────────────
enum InstrumentClassification {
  reversingThermometer('Reversing Thermometer'),
  soundingLead('Sounding Lead'),
  bottomClamDredge('Bottom Clam Dredge'),
  slipWaterBottle('Slip-Water Bottle'),
  driftIndicator('Drift Indicator'),
  nansenBottle('Nansen Water Bottle'),
  sedimentGrab('Sediment Grab'),
  other('Unclassified Apparatus');

  const InstrumentClassification(this.label);
  final String label;
}

// ─── VALVING & SEALING MECHANICS ─────────────────────────────────────────────
enum ValvingSealingMechanics {
  dropWeightMessenger('Drop-weight messenger release'),
  rotativePlugCock('Rotative plug-cock valve'),
  springLoadedDiscs('Spring-loaded rubber discs'),
  thermometricReversal('Thermometric reversal lock'),
  tallowCavitySeal('Tallow cavity seal'),
  mechanicalTrip('Mechanical trip assembly'),
  other('Compound / Hybrid');

  const ValvingSealingMechanics(this.label);
  final String label;
}

// ─── OCEAN DEPTH ZONE ────────────────────────────────────────────────────────
enum OceanDepthZone {
  epipelagic('Epipelagic (0–200 m)'),
  mesopelagic('Mesopelagic (200–1000 m)'),
  bathypelagic('Bathypelagic (1000–4000 m)'),
  abyssal('Abyssal (4000 m+)');

  const OceanDepthZone(this.label);
  final String label;
}

// ─── COMPOSITION METALLURGY ──────────────────────────────────────────────────
enum CompositionMetallurgy {
  tinnedBrass('Heavily tinned marine brass'),
  gunmetalBronze('Solid gunmetal bronze'),
  monelLinkages('Monel-metal linkages'),
  castLead('Cast survey lead'),
  borosilicateGlass('Borosilicate & brass assembly'),
  mixedUnknown('Composite / Unknown');

  const CompositionMetallurgy(this.label);
  final String label;
}

// ─── PRESERVATION SOUNDNESS ──────────────────────────────────────────────────
enum PreservationSoundness {
  museumGrade('Museum Grade — Exhibition Ready'),
  operational('Operational — Deployment Ready'),
  saltCrustScoring('Salt-crust scoring'),
  mercurySeparation('Mercury column separation'),
  springTensionLoss('Spring tension scaling'),
  fragmentary('Fragmentary — Parts Missing'),
  unknown('Indeterminate');

  const PreservationSoundness(this.label);
  final String label;
}
