import 'package:flutter/material.dart';

class SnackbarHandler {
  BuildContext context;

  SnackbarHandler.of(this.context);

  void remove() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
  }

  void removeAll() {
    ScaffoldMessenger.of(context).clearSnackBars();
  }

  void showLocationException(String message) {
    bool isLight = Theme.of(context).brightness == Brightness.light;
    final snackBar = SnackBar(
      action: SnackBarAction(label: 'Fermer', onPressed: remove),
      backgroundColor: isLight ? Colors.white : Colors.black,
      content: Text(
        message,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isLight ? Colors.black : Colors.white,
        ),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
