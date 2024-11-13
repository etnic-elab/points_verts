import 'package:flutter/material.dart';

enum ScreenSize { small, medium, large }

extension ScreenSizeExtension on BuildContext {
  ScreenSize get screenSize {
    final width = MediaQuery.of(this).size.width;

    if (width < 600) {
      return ScreenSize.small;
    } else if (width < 1200) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }
}

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({
    required this.small,
    required this.medium,
    required this.large,
    super.key,
  });

  final Widget small;
  final Widget medium;
  final Widget large;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        switch (context.screenSize) {
          case ScreenSize.small:
            return small;
          case ScreenSize.medium:
            return medium;
          case ScreenSize.large:
            return large;
        }
      },
    );
  }
}
