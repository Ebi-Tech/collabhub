import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // these helpers switch between light/dark values based on the current theme

  // background for cards, dialogs, and the app header
  static Color surface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF1C1C2E)
          : white;

  static Color onSurface(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFECEFF4)
          : foreground;

  static Color border(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0x1AFFFFFF) // rgba(255,255,255,0.1)
          : cardBorder;

  // background colour for text fields
  static Color input(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF252535)
          : inputBg;

  // black in light mode, blue in dark mode so it doesn't disappear
  static Color actionButton(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? primary : foreground;

  static Color secondaryText(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? gray400 : gray600;

  // background for skill chips
  static Color badgeBg(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A2A3E)
          : secondary;

  // Primary
  static const Color primary = Color(0xFF2563EB); // blue-600
  static const Color primaryHover = Color(0xFF1D4ED8); // blue-700

  // Status
  static const Color green600 = Color(0xFF16A34A);
  static const Color green700 = Color(0xFF15803D);
  static const Color green100 = Color(0xFFDCFCE7);
  static const Color red600 = Color(0xFFDC2626);
  static const Color red700 = Color(0xFFB91C1C);
  static const Color red100 = Color(0xFFFEE2E2);

  // Neutral
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray300 = Color(0xFFD1D5DB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray500 = Color(0xFF6B7280);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray700 = Color(0xFF374151);

  // Backgrounds
  static const Color white = Color(0xFFFFFFFF);
  static const Color inputBg = Color(0xFFF3F3F5);
  static const Color secondary = Color(0xFFECECF0);
  static const Color cardBorder = Color(0x1A000000); // rgba(0,0,0,0.1)
  static const Color foreground = Color(0xFF030213);

  // Gradient (login screen)
  static const Color blue50 = Color(0xFFEFF6FF);
  static const Color indigo100 = Color(0xFFE0E7FF);

  // Google logo colours
  static const Color googleBlue = Color(0xFF4285F4);
  static const Color googleGreen = Color(0xFF34A853);
  static const Color googleYellow = Color(0xFFFBBC05);
  static const Color googleRed = Color(0xFFEA4335);
}

class AppRadius {
  AppRadius._();
  static const double xs = 4;
  static const double md = 6;
  static const double lg = 8;
  static const double xl = 10; // default card/button radius
  static const double xxl = 12;
  static const double xxxl = 16;
}

class AppTextStyles {
  AppTextStyles._();

  // no colour set here — inherits from the Material3 theme so dark mode works automatically

  static const TextStyle heading2xl = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle headingXl = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headingLg = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyBase = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  static const TextStyle bodySm = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.gray500,
    height: 1.5,
  );

  static const TextStyle bodyXs = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.gray500,
    height: 1.5,
  );

  static const TextStyle labelBase = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    height: 1.5,
  );

  static const TextStyle labelSm = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
  );
}

class AppShadows {
  AppShadows._();

  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 2,
      offset: Offset(0, -1),
    ),
  ];

  static const List<BoxShadow> sm = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  static const List<BoxShadow> lg = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 15,
      offset: Offset(0, 10),
    ),
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 6,
      offset: Offset(0, 4),
    ),
  ];
}
