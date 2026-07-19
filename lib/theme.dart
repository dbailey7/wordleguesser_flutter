import 'package:flutter/material.dart';

const wordleGreen = Color(0xFF538D4E);
const wordleYellow = Color(0xFFB59F3B);
const wordleDark = Color(0xFF3A3A3C);
const wordleGray = Color(0xFF818384);
const wordleLightGray = Color(0xFFD3D6DA);

// One-off colors used in specific screens (ported verbatim from the
// Kotlin/Compose source rather than promoted to named theme colors, since
// that's how the original app had them).
const tileNeutral = Color(0xFF565758);
const tutorialBannerBg = Color(0xFF1A2E1A);
const onboardingBackground = Color(0xFF121213);
const onboardingCardBackground = Color(0xFF1A1A1B);
const onboardingSubtleText = Color(0xFF8A8A8A);

ThemeData wordleGuesserTheme() {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: wordleDark,
    colorScheme: const ColorScheme.dark(
      primary: wordleGreen,
      secondary: wordleGray,
      surface: wordleDark,
      onPrimary: Colors.white,
      onSurface: Colors.white,
    ),
  );
}
