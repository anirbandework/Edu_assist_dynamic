// lib/core/utils/responsive.dart
import 'package:flutter/material.dart';

enum DeviceType {
  mobile,
  tablet, 
  desktop,
}

enum Orientation {
  portrait,
  landscape,
}

class ResponsiveHelper {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 900;
  static const double desktopBreakpoint = 1200;

  static DeviceType getDeviceType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return DeviceType.mobile;
    if (width < tabletBreakpoint) return DeviceType.tablet;
    return DeviceType.desktop;
  }

  static Orientation getOrientation(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return size.width > size.height ? Orientation.landscape : Orientation.portrait;
  }

  static bool isMobile(BuildContext context) => getDeviceType(context) == DeviceType.mobile;
  static bool isTablet(BuildContext context) => getDeviceType(context) == DeviceType.tablet;
  static bool isDesktop(BuildContext context) => getDeviceType(context) == DeviceType.desktop;
  static bool isPortrait(BuildContext context) => getOrientation(context) == Orientation.portrait;
  static bool isLandscape(BuildContext context) => getOrientation(context) == Orientation.landscape;

  // Get screen dimensions
  static Size getScreenSize(BuildContext context) => MediaQuery.of(context).size;
  static double getScreenWidth(BuildContext context) => MediaQuery.of(context).size.width;
  static double getScreenHeight(BuildContext context) => MediaQuery.of(context).size.height;

  // Safe area
  static EdgeInsets getSafeArea(BuildContext context) => MediaQuery.of(context).padding;
  static double getStatusBarHeight(BuildContext context) => MediaQuery.of(context).padding.top;
  static double getBottomPadding(BuildContext context) => MediaQuery.of(context).padding.bottom;
}

// Responsive value selector
class ResponsiveValue<T> {
  final T mobile;
  final T? tablet;
  final T? desktop;

  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  T getValue(BuildContext context) {
    final deviceType = ResponsiveHelper.getDeviceType(context);
    switch (deviceType) {
      case DeviceType.mobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

// Responsive sizing
class ResponsiveSize {
  // Font sizes
  static const ResponsiveValue<double> headingLarge = ResponsiveValue(
    mobile: 28.0,
    tablet: 32.0, 
    desktop: 36.0,
  );

  static const ResponsiveValue<double> headingMedium = ResponsiveValue(
    mobile: 22.0,
    tablet: 26.0,
    desktop: 30.0,
  );

  static const ResponsiveValue<double> headingSmall = ResponsiveValue(
    mobile: 18.0,
    tablet: 22.0,
    desktop: 26.0,
  );

  static const ResponsiveValue<double> bodyLarge = ResponsiveValue(
    mobile: 16.0,
    tablet: 18.0,
    desktop: 20.0,
  );

  static const ResponsiveValue<double> bodyMedium = ResponsiveValue(
    mobile: 14.0,
    tablet: 16.0,
    desktop: 18.0,
  );

  static const ResponsiveValue<double> bodySmall = ResponsiveValue(
    mobile: 12.0,
    tablet: 14.0,
    desktop: 16.0,
  );

  // Icon sizes
  static const ResponsiveValue<double> iconSmall = ResponsiveValue(
    mobile: 16.0,
    tablet: 20.0,
    desktop: 24.0,
  );

  static const ResponsiveValue<double> iconMedium = ResponsiveValue(
    mobile: 24.0,
    tablet: 28.0,
    desktop: 32.0,
  );

  static const ResponsiveValue<double> iconLarge = ResponsiveValue(
    mobile: 32.0,
    tablet: 40.0,
    desktop: 48.0,
  );

  static const ResponsiveValue<double> iconXLarge = ResponsiveValue(
    mobile: 48.0,
    tablet: 64.0,
    desktop: 80.0,
  );

  // Padding & Margins
  static const ResponsiveValue<double> paddingSmall = ResponsiveValue(
    mobile: 8.0,
    tablet: 12.0,
    desktop: 16.0,
  );

  static const ResponsiveValue<double> paddingMedium = ResponsiveValue(
    mobile: 16.0,
    tablet: 24.0,
    desktop: 32.0,
  );

  static const ResponsiveValue<double> paddingLarge = ResponsiveValue(
    mobile: 24.0,
    tablet: 32.0,
    desktop: 48.0,
  );

  static const ResponsiveValue<double> paddingXLarge = ResponsiveValue(
    mobile: 32.0,
    tablet: 48.0,
    desktop: 64.0,
  );

  // Container widths
  static const ResponsiveValue<double?> maxContentWidth = ResponsiveValue(
    mobile: null,
    tablet: 700.0,
    desktop: 1200.0,
  );

  static const ResponsiveValue<double?> dialogWidth = ResponsiveValue(
    mobile: null, // Full width with margin
    tablet: 500.0,
    desktop: 600.0,
  );

  // Button heights
  static const ResponsiveValue<double> buttonHeight = ResponsiveValue(
    mobile: 48.0,
    tablet: 52.0,
    desktop: 56.0,
  );

  // Card sizes
  static const ResponsiveValue<double> cardPadding = ResponsiveValue(
    mobile: 16.0,
    tablet: 20.0,
    desktop: 24.0,
  );

  static const ResponsiveValue<double> cardMargin = ResponsiveValue(
    mobile: 8.0,
    tablet: 12.0,
    desktop: 16.0,
  );
}

// Extension methods for easy access
extension ResponsiveContext on BuildContext {
  DeviceType get deviceType => ResponsiveHelper.getDeviceType(this);
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  bool get isPortrait => ResponsiveHelper.isPortrait(this);
  bool get isLandscape => ResponsiveHelper.isLandscape(this);
  
  Size get screenSize => ResponsiveHelper.getScreenSize(this);
  double get screenWidth => ResponsiveHelper.getScreenWidth(this);
  double get screenHeight => ResponsiveHelper.getScreenHeight(this);
  
  EdgeInsets get safeArea => ResponsiveHelper.getSafeArea(this);
  double get statusBarHeight => ResponsiveHelper.getStatusBarHeight(this);
  double get bottomPadding => ResponsiveHelper.getBottomPadding(this);

  // Get responsive values easily
  T responsive<T>(ResponsiveValue<T> value) => value.getValue(this);
}

// Responsive widgets
class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context, DeviceType deviceType) builder;

  const ResponsiveBuilder({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, context.deviceType);
  }
}

// ✅ FIXED ResponsiveRow - No more Expanded issues
class ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final MainAxisAlignment mainAxisAlignment;
  final CrossAxisAlignment crossAxisAlignment;
  final double? spacing;

  const ResponsiveRow({
    super.key,
    required this.children,
    this.mainAxisAlignment = MainAxisAlignment.start,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.spacing,
  });

  @override
  Widget build(BuildContext context) {
    if (context.isMobile) {
      // Mobile: Stack vertically, no Expanded widgets
      return Column(
        mainAxisSize: MainAxisSize.min, // ✅ FIXED: Don't expand
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: CrossAxisAlignment.stretch, // ✅ Full width buttons
        children: _addSpacing(children, isVertical: true),
      );
    }
    
    // Desktop/Tablet: Side by side with IntrinsicHeight
    return IntrinsicHeight( // ✅ FIXED: Equal height without flex
      child: Row(
        mainAxisAlignment: mainAxisAlignment,
        crossAxisAlignment: crossAxisAlignment,
        children: _addSpacing(
          children.map((child) => Flexible(child: child)).toList(), // ✅ Flexible instead of Expanded
          isVertical: false,
        ),
      ),
    );
  }

  List<Widget> _addSpacing(List<Widget> children, {required bool isVertical}) {
    if (spacing == null || children.length <= 1) return children;
    
    final spacer = isVertical 
        ? SizedBox(height: spacing)
        : SizedBox(width: spacing);
    
    final List<Widget> spaced = [];
    for (int i = 0; i < children.length; i++) {
      spaced.add(children[i]);
      if (i < children.length - 1) {
        spaced.add(spacer);
      }
    }
    return spaced;
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? maxWidth;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxWidth: maxWidth ?? context.responsive(ResponsiveSize.maxContentWidth) ?? double.infinity,
      ),
      padding: padding ?? EdgeInsets.all(context.responsive(ResponsiveSize.paddingMedium)),
      margin: margin,
      child: child,
    );
  }
}
