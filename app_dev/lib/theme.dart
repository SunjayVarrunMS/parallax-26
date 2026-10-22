// colours and fonts. dark colours come from css/style.css, light colours from css/light.css.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'store.dart';

const String themeKey = 'parallax:theme';

// 'dark' or 'light'. the header button changes it.
final ValueNotifier<String> themeNotifier = ValueNotifier<String>('dark');

String getTheme() {
  return readStore(themeKey, 'dark') as String;
}

void loadTheme() {
  themeNotifier.value = getTheme();
}

void toggleTheme() {
  String next = 'light';
  if (getTheme() == 'light') {
    next = 'dark';
  }
  writeStore(themeKey, next);
  themeNotifier.value = next;
}

class PlxColors {
  const PlxColors({
    required this.paper,
    required this.surface,
    required this.ink,
    required this.muted,
    required this.cyan,
    required this.accent,
    required this.accentHover,
    required this.blue,
    required this.green,
    required this.error,
    required this.lineSoft,
    required this.onCyan,
    required this.onAccent,
    required this.violet,
  });

  final Color paper;
  final Color surface;
  final Color ink;
  final Color muted;
  final Color cyan;
  final Color accent;
  final Color accentHover;
  final Color blue;
  final Color green;
  final Color error;
  final Color lineSoft;
  final Color onCyan;
  final Color onAccent;
  final Color violet;

  static const PlxColors dark = PlxColors(
    paper: Color(0xFF1A0B3D),
    surface: Color(0xFF22104F),
    ink: Color(0xFFEFEFEF),
    muted: Color(0xFFB3A8D6),
    cyan: Color(0xFF4DF4FC),
    accent: Color(0xFFFD308E),
    accentHover: Color(0xFFE531B5),
    blue: Color(0xFF653BF7),
    green: Color(0xFF05DD8B),
    error: Color(0xFFE03A5B),
    lineSoft: Color(0xFF3D2A78),
    onCyan: Color(0xFF1A0B3D),
    onAccent: Color(0xFFEFEFEF),
    violet: Color(0xFF653BF7),
  );

  static const PlxColors light = PlxColors(
    paper: Color(0xFFF4F1FB),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF1A0B3D),
    muted: Color(0xFF5A4C82),
    cyan: Color(0xFF057379),
    accent: Color(0xFFC4126A),
    accentHover: Color(0xFFA30E57),
    blue: Color(0xFF653BF7),
    green: Color(0xFF0A7A52),
    error: Color(0xFFB3203F),
    lineSoft: Color(0xFFCDC3E6),
    onCyan: Color(0xFFFFFFFF),
    onAccent: Color(0xFFFFFFFF),
    violet: Color(0xFFC9BCF5),
  );

  // the colours for the current theme
  static PlxColors of(BuildContext context) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return dark;
    }
    return light;
  }
}

// body text (JetBrains Mono)
TextStyle monoStyle({
  double size = 15.2,
  FontWeight weight = FontWeight.w400,
  Color? color,
  double spacing = 0,
  double height = 1.65,
}) {
  return GoogleFonts.jetBrainsMono(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: spacing,
    height: height,
  );
}

// headings (Tektur)
TextStyle displayStyle({
  double size = 24,
  FontWeight weight = FontWeight.w900,
  Color? color,
  double spacing = 0,
  double height = 1.1,
}) {
  return GoogleFonts.tektur(
    fontSize: size,
    fontWeight: weight,
    color: color,
    letterSpacing: spacing,
    height: height,
  );
}

ThemeData buildTheme(Brightness brightness) {
  final c = brightness == Brightness.dark ? PlxColors.dark : PlxColors.light;
  final baseText = ThemeData(brightness: brightness).textTheme;
  return ThemeData(
    brightness: brightness,
    scaffoldBackgroundColor: c.paper,
    colorScheme: ColorScheme(
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.onAccent,
      secondary: c.cyan,
      onSecondary: c.onCyan,
      error: c.error,
      onError: c.onAccent,
      surface: c.surface,
      onSurface: c.ink,
    ),
    textTheme: GoogleFonts.jetBrainsMonoTextTheme(baseText).apply(
      bodyColor: c.ink,
      displayColor: c.ink,
    ),
    drawerTheme: DrawerThemeData(
      backgroundColor: c.surface,
      shape: const RoundedRectangleBorder(),
    ),
    splashFactory: NoSplash.splashFactory,
    useMaterial3: true,
  );
}
