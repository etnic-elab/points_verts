import 'package:flutter/foundation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A simple widget that builds different things on different platforms.
class PlatformWidget extends StatelessWidget {
  const PlatformWidget({
    Key key,
    @required this.androidBuilder,
    @required this.iosBuilder,
  })  : assert(androidBuilder != null),
        assert(iosBuilder != null),
        super(key: key);

  final WidgetBuilder androidBuilder;
  final WidgetBuilder iosBuilder;

  @override
  Widget build(context) {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return androidBuilder(context);
      case TargetPlatform.iOS:
        return iosBuilder(context);
      default:
        assert(false, 'Unexpected platform $defaultTargetPlatform');
        return null;
    }
  }
}

void showChoices(
    BuildContext context, List<DateTime> choices, int currentChoice, Function(int) onChoice) {
  DateFormat dateFormat = DateFormat.yMMMMEEEEd("fr_BE");
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      showDialog<void>(
        context: context,
        builder: (context) {
          int selectedRadio = currentChoice;
          return AlertDialog(
            contentPadding: EdgeInsets.only(top: 12),
            content: SingleChildScrollView(child: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: List<Widget>.generate(choices.length, (index) {
                    return RadioListTile(
                      title: Text(dateFormat.format(choices[index])),
                      value: index,
                      groupValue: selectedRadio,
                      // ignore: avoid_types_on_closure_parameters
                      onChanged: (int value) {
                        setState(() => selectedRadio = value);
                      },
                    );
                  }),
                );
              },
            )),
            actions: [
              FlatButton(
                child: Text('OK'),
                onPressed: () {
                  onChoice(selectedRadio);
                  Navigator.of(context).pop();},
              ),
              FlatButton(
                child: Text('ANNULER'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
      return;
    case TargetPlatform.iOS:
      showCupertinoModalPopup<void>(
        context: context,
        builder: (context) {
          return SizedBox(
            height: 250,
            child: CupertinoPicker(
              useMagnifier: true,
              magnification: 1.1,
              itemExtent: 40,
              scrollController: FixedExtentScrollController(initialItem: currentChoice),
              children: List<Widget>.generate(choices.length, (index) {
                return Center(
                  child: Text(dateFormat.format(choices[index]),
                    style: TextStyle(
                      fontSize: 21,
                    ),
                  ),
                );
              }),
              onSelectedItemChanged: (value) {
                onChoice(value);
              },
            ),
          );
        },
      );
      return;
    default:
      assert(false, 'Unexpected platform $defaultTargetPlatform');
  }
}
