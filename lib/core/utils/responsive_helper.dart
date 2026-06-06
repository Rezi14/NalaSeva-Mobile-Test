import 'package:flutter/material.dart';

class ResponsiveHelper {
  // ─── Device Breakpoints ──────────────────────────────────────────────────
  static const double mobileMax = 600.0;
  static const double tabletMax = 1024.0;

  // ─── Layout checks (sensitive to rotation/landscape) ────────────────────
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMax;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMax && width < tabletMax;
  }

  static bool isTv(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMax;

  // ─── Orientation helpers ─────────────────────────────────────────────────
  static bool isLandscape(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.landscape;

  static bool isPortrait(BuildContext context) =>
      MediaQuery.of(context).orientation == Orientation.portrait;

  // ─── Physical device type (immune to rotation) ───────────────────────────
  static bool isPhysicalMobile(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide < mobileMax;

  static bool isPhysicalTablet(BuildContext context) {
    final shortestSide = MediaQuery.of(context).size.shortestSide;
    return shortestSide >= mobileMax && shortestSide < tabletMax;
  }

  static bool isPhysicalTv(BuildContext context) =>
      MediaQuery.of(context).size.shortestSide >= tabletMax;

  // ─── Base Scale Factor ───────────────────────────────────────────────────
  /// Returns a scaled value based on device width category.
  static double scale(BuildContext context, double baseMobile, {double? tablet, double? tv}) {
    final width = MediaQuery.of(context).size.width;
    if (width >= tabletMax) {
      return tv ?? tablet ?? (baseMobile * 1.4);
    } else if (width >= mobileMax) {
      return tablet ?? (baseMobile * 1.2);
    }
    return baseMobile;
  }

  // ─── Typography ──────────────────────────────────────────────────────────
  /// Heading font size (e.g. dialog titles, section titles)
  static double fontSizeHeading(BuildContext context) =>
      scale(context, 17, tablet: 19, tv: 22);

  /// Body font size (e.g. dialog content, list items)
  static double fontSizeBody(BuildContext context) =>
      scale(context, 13, tablet: 14, tv: 15);

  /// Caption font size (e.g. labels, hints, badges)
  static double fontSizeCaption(BuildContext context) =>
      scale(context, 11, tablet: 12, tv: 13);

  /// Button label font size
  static double fontSizeButton(BuildContext context) =>
      scale(context, 13, tablet: 14, tv: 15);

  /// Generic adaptive font size
  static double fontSize(BuildContext context, double baseSize) =>
      scale(context, baseSize);

  // ─── Spacing ─────────────────────────────────────────────────────────────
  /// Generic adaptive spacing
  static double spacing(BuildContext context, double baseSpacing) =>
      scale(context, baseSpacing);

  // ─── Dialog ──────────────────────────────────────────────────────────────
  /// Max width of alert dialogs / confirmation dialogs.
  /// In landscape on phone, reduces to avoid dialog spanning full width.
  static double dialogMaxWidth(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenW = mq.size.width;
    if (isLandscape(context) && isPhysicalMobile(context)) {
      // Phone landscape: cap at 80% of width but not more than 420
      return (screenW * 0.80).clamp(280.0, 420.0);
    }
    if (isPhysicalTablet(context)) {
      return 520.0;
    }
    if (isTv(context)) {
      return 600.0;
    }
    return 460.0; // default phone portrait
  }

  /// Max height ratio for dialogs (avoids overflow in landscape)
  static double dialogMaxHeight(BuildContext context) {
    if (isLandscape(context) && isPhysicalMobile(context)) {
      return MediaQuery.of(context).size.height * 0.88;
    }
    return MediaQuery.of(context).size.height * 0.85;
  }

  // ─── Bottom Sheets ───────────────────────────────────────────────────────
  /// Max height for bottom sheet / modal forms.
  static double sheetMaxHeight(BuildContext context) {
    final mq = MediaQuery.of(context);
    if (isLandscape(context) && isPhysicalMobile(context)) {
      // Phone landscape: use 95% so form doesn't clip but still scrollable
      return mq.size.height * 0.95;
    }
    if (isPhysicalTablet(context)) {
      return mq.size.height * 0.80;
    }
    return mq.size.height * 0.85;
  }

  // ─── Buttons ─────────────────────────────────────────────────────────────
  /// Standard action button height
  static double buttonHeight(BuildContext context) =>
      scale(context, 48, tablet: 52, tv: 56);

  /// Compact button height (e.g. inside dialogs)
  static double buttonHeightCompact(BuildContext context) =>
      scale(context, 44, tablet: 48, tv: 52);

  // ─── Icons ───────────────────────────────────────────────────────────────
  /// Standard icon size
  static double iconSize(BuildContext context, {double base = 24}) =>
      scale(context, base, tablet: base * 1.15, tv: base * 1.3);

  /// Navigation bar icon size
  static double navIconSize(BuildContext context) =>
      scale(context, 22, tablet: 24, tv: 26);

  // ─── Border Radius ───────────────────────────────────────────────────────
  /// Dialog / card border radius
  static double radiusDialog(BuildContext context) =>
      scale(context, 16, tablet: 20, tv: 24);

  /// Button border radius
  static double radiusButton(BuildContext context) =>
      scale(context, 12, tablet: 14, tv: 16);

  /// Card border radius
  static double radiusCard(BuildContext context) =>
      scale(context, 16, tablet: 20, tv: 24);

  /// Small element radius (chips, badges, small buttons)
  static double radiusSmall(BuildContext context) =>
      scale(context, 8, tablet: 10, tv: 12);

  // ─── Padding / Spacing ───────────────────────────────────────────────────
  /// Standard card / content padding
  static double paddingCard(BuildContext context) =>
      scale(context, 16, tablet: 20, tv: 24);

  /// Dialog internal padding
  static double paddingDialog(BuildContext context) =>
      scale(context, 20, tablet: 24, tv: 28);

  /// Screen-level horizontal padding
  static double paddingPage(BuildContext context) =>
      scale(context, 16, tablet: 24, tv: 32);

  // ─── Navigation Bar ──────────────────────────────────────────────────────
  /// Bottom navigation bar vertical padding
  static double bottomNavPaddingV(BuildContext context) {
    if (isLandscape(context) && isPhysicalMobile(context)) return 6.0;
    return scale(context, 8, tablet: 10, tv: 12);
  }

  /// Center FAB padding in bottom nav
  static double bottomNavFabPadding(BuildContext context) =>
      scale(context, 10, tablet: 12, tv: 14);

  // ─── Avatar / Profile Circle ─────────────────────────────────────────────
  /// Header avatar diameter
  static double avatarSize(BuildContext context) =>
      scale(context, 44, tablet: 50, tv: 58);
}

// ─── Layout Widgets ──────────────────────────────────────────────────────────

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? tv;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.tv,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= ResponsiveHelper.tabletMax) {
          return tv ?? tablet ?? mobile;
        } else if (constraints.maxWidth >= ResponsiveHelper.mobileMax) {
          return tablet ?? mobile;
        } else {
          return mobile;
        }
      },
    );
  }
}

class ResponsiveCenter extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry padding;

  const ResponsiveCenter({
    super.key,
    required this.child,
    this.maxWidth = 800,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
