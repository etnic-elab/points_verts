import 'package:flutter/cupertino.dart';

enum WindowSize { compact, medium, expanded }

class WindowSizer {
  final BuildContext context;

  WindowSizer.of(this.context);

  WindowSize get height {
    double height = MediaQuery.of(context).size.height;
    if (height < 480) return WindowSize.compact;
    if (height < 900) return WindowSize.medium;
    return WindowSize.expanded;
  }

  WindowSize get width {
    double width = MediaQuery.of(context).size.width;
    if (width < 600) return WindowSize.compact;
    if (width < 840) return WindowSize.medium;
    return WindowSize.expanded;
  }
}
