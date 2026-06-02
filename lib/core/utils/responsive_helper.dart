import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Device Breakpoints
  static const double mobileMax = 600.0;
  static const double tabletMax = 1024.0;

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < mobileMax;

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileMax && width < tabletMax;
  }

  static bool isTv(BuildContext context) =>
      MediaQuery.of(context).size.width >= tabletMax;

  // Scale factor based on device type
  static double scale(BuildContext context, double baseMobile, {double? tablet, double? tv}) {
    final width = MediaQuery.of(context).size.width;
    if (width >= tabletMax) {
      return tv ?? tablet ?? (baseMobile * 1.4);
    } else if (width >= mobileMax) {
      return tablet ?? (baseMobile * 1.2);
    }
    return baseMobile;
  }

  // Scales font size adaptively
  static double fontSize(BuildContext context, double baseSize) {
    return scale(context, baseSize);
  }

  // Scales horizontal/vertical spacing adaptively
  static double spacing(BuildContext context, double baseSpacing) {
    return scale(context, baseSpacing);
  }
}

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
