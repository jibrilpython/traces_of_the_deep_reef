import 'package:flutter/material.dart';
import 'package:traces_of_the_deep_reef/enum/my_enums.dart';

// ─── COLOR PALETTE — "Oceanographic Survey" ──────────────────────────────────
const Color kBackground = Color(0xFFEFF2F5);
const Color kPrimaryText = Color(0xFF0B1520);
const Color kPanelBg = Color(0xFFFFFFFF);
const Color kSecondaryText = Color(0xFF5A6B7A);
const Color kAccent = Color(0xFF1A6B8A);
const Color kSecondaryAccent = Color(0xFF7A5C2E);
const Color kOutline = Color(0xFFDCE4EA);
const Color kError = Color(0xFFC0392B);

const Color kAccentLight = Color(0xFF1F7A9C);
const Color kAccentSurface = Color(0xFFE8F2F8);
const Color kBronzeSurface = Color(0xFFF5EFE4);
const Color kGlassBackground = Color(0xB3FFFFFF);

Color getDepthZoneColor(OceanDepthZone zone) {
  switch (zone) {
    case OceanDepthZone.epipelagic:
      return kAccent;
    case OceanDepthZone.mesopelagic:
      return const Color(0xFF155E75);
    case OceanDepthZone.bathypelagic:
      return const Color(0xFF0F3D4C);
    case OceanDepthZone.abyssal:
      return kSecondaryAccent;
  }
}

double getDepthFraction(OceanDepthZone zone) {
  switch (zone) {
    case OceanDepthZone.epipelagic:
      return 0.25;
    case OceanDepthZone.mesopelagic:
      return 0.50;
    case OceanDepthZone.bathypelagic:
      return 0.75;
    case OceanDepthZone.abyssal:
      return 1.0;
  }
}

bool isDisplayCondition(PreservationSoundness state) {
  return state == PreservationSoundness.museumGrade ||
      state == PreservationSoundness.saltCrustScoring ||
      state == PreservationSoundness.mercurySeparation ||
      state == PreservationSoundness.springTensionLoss ||
      state == PreservationSoundness.fragmentary;
}

Color getConditionColor(PreservationSoundness state) {
  switch (state) {
    case PreservationSoundness.museumGrade:
      return kAccent;
    case PreservationSoundness.operational:
      return const Color(0xFF059669);
    case PreservationSoundness.saltCrustScoring:
      return kSecondaryAccent;
    case PreservationSoundness.mercurySeparation:
      return const Color(0xFF92400E);
    case PreservationSoundness.springTensionLoss:
      return kSecondaryText;
    case PreservationSoundness.fragmentary:
      return kError;
    case PreservationSoundness.unknown:
      return kSecondaryText;
  }
}

Color getInstrumentWireColor(PreservationSoundness state) {
  return isDisplayCondition(state) ? kSecondaryAccent : kAccent;
}

String generateRegistryCode() {
  final now = DateTime.now();
  final codes = ['DEEP', 'REEF', 'SOUND', 'DRIFT', 'BATHY', 'ABYSS'];
  final suffix = codes[now.millisecond % codes.length];
  return 'TDR-REEF-${now.year % 100}${now.month.toString().padLeft(2, '0')}-$suffix-W';
}

const double kSpacingXXS = 4.0;
const double kSpacingXS = 8.0;
const double kSpacingS = 12.0;
const double kSpacingM = 16.0;
const double kSpacingL = 20.0;
const double kSpacingXL = 24.0;
const double kSpacingXXL = 32.0;
const double kSpacingXXXL = 48.0;

const double kRadiusZero = 0.0;
const double kRadiusSubtle = 10.0;
const double kRadiusStandard = 16.0;
const double kRadiusMedium = 24.0;
const double kRadiusLarge = 32.0;
const double kRadiusPill = 999.0;

const BoxShadow kShadowSubtle = BoxShadow(
  offset: Offset(0, 4),
  blurRadius: 16,
  spreadRadius: -2,
  color: Color(0x0A0B1520),
);

const BoxShadow kShadowFloat = BoxShadow(
  offset: Offset(0, 8),
  blurRadius: 28,
  spreadRadius: -4,
  color: Color(0x141A6B8A),
);

const BoxShadow kShadowBlue = BoxShadow(
  offset: Offset(0, 8),
  blurRadius: 24,
  spreadRadius: -2,
  color: Color(0x301A6B8A),
);

const double kStrokeWeight = 1.0;
const double kStrokeWeightMedium = 2.0;
const double kStrokeWeightThick = 3.0;
