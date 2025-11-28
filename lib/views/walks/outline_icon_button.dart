import 'package:flutter/material.dart';

class OutlineIconButton extends StatelessWidget {
  const OutlineIconButton({
    required this.onPressed,
    required this.iconData,
    required this.semanticLabel,
    super.key,
  });

  final VoidCallback? onPressed;
  final IconData? iconData;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return IconButton.outlined(
      onPressed: onPressed,
      icon: Icon(iconData, semanticLabel: semanticLabel),
    );
  }
}
