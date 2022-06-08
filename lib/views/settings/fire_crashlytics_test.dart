import 'dart:async';
import 'dart:io';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:points_verts/services/prefs.dart';

class FireCrashlyticsTest extends StatefulWidget {
  const FireCrashlyticsTest({Key? key}) : super(key: key);

  @override
  State createState() => _FireCrashlyticsTestState();
}

class _FireCrashlyticsTestState extends State<FireCrashlyticsTest> {
  late Future<void> _initializeFlutterFireFuture;

  Future<void> _testAsyncErrorOnInit() async {
    Future<void>.delayed(const Duration(seconds: 2), () {
      final List<int> list = <int>[];
      print(list[100]);
    });
  }

  // Define an async function to initialize FlutterFire
  Future<void> _initializeFlutterFire() async {
    FirebaseCrashlytics.instance.setCustomKey('test', true);
    await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
    await _testAsyncErrorOnInit();
  }

  @override
  void initState() {
    super.initState();
    _initializeFlutterFireFuture = _initializeFlutterFire();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        bool crashlyticsEnabled =
            await PrefsProvider.prefs.getBoolean(Prefs.crashlyticsEnabled);
        if (!crashlyticsEnabled) {
          _closeAppDialog();
          return false;
        }

        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crashlytics example app'),
        ),
        body: FutureBuilder(
          future: _initializeFlutterFireFuture,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                return Center(
                  child: Column(
                    children: <Widget>[
                      ElevatedButton(
                        onPressed: () {
                          FirebaseCrashlytics.instance
                              .setCustomKey('example', 'flutterfire');
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                'Custom Key "example: flutterfire" has been set \n'
                                'Key will appear in Firebase Console once an error has been reported.'),
                            duration: Duration(seconds: 5),
                          ));
                        },
                        child: const Text('Key'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          FirebaseCrashlytics.instance
                              .log('This is a log example');
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                'The message "This is a log example" has been logged \n'
                                'Message will appear in Firebase Console once an error has been reported.'),
                            duration: Duration(seconds: 5),
                          ));
                        },
                        child: const Text('Log'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text('App will crash is 5 seconds \n'
                                'Please reopen to send data to Crashlytics'),
                            duration: Duration(seconds: 5),
                          ));

                          // Delay crash for 5 seconds
                          sleep(const Duration(seconds: 5));

                          // Use FirebaseCrashlytics to throw an error. Use this for
                          // confirmation that errors are being correctly reported.
                          FirebaseCrashlytics.instance.crash();
                        },
                        child: const Text('Crash'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                'Thrown error has been caught and sent to Crashlytics.'),
                            duration: Duration(seconds: 5),
                          ));

                          // Example of thrown error, it will be caught and sent to
                          // Crashlytics.
                          throw StateError('Uncaught error thrown by app');
                        },
                        child: const Text('Throw Error'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text(
                                'Uncaught Exception that is handled by second parameter of runZonedGuarded.'),
                            duration: Duration(seconds: 5),
                          ));

                          // Example of an exception that does not get caught
                          // by `FlutterError.onError` but is caught by
                          // `runZonedGuarded`.
                          runZonedGuarded(() {
                            Future<void>.delayed(const Duration(seconds: 2),
                                () {
                              final List<int> list = <int>[];
                              print(list[100]);
                            });
                          }, FirebaseCrashlytics.instance.recordError);
                        },
                        child: const Text('Async out of bounds'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Recorded Error'),
                              duration: Duration(seconds: 5),
                            ));
                            throw Error();
                          } catch (e, s) {
                            // "reason" will append the word "thrown" in the
                            // Crashlytics console.
                            await FirebaseCrashlytics.instance.recordError(e, s,
                                reason: 'as an example of fatal error',
                                fatal: true);
                          }
                        },
                        child: const Text('Record Fatal Error'),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text('Recorded Error'),
                              duration: Duration(seconds: 5),
                            ));
                            throw Error();
                          } catch (e, s) {
                            // "reason" will append the word "thrown" in the
                            // Crashlytics console.
                            await FirebaseCrashlytics.instance.recordError(e, s,
                                reason: 'as an example of non-fatal error');
                          }
                        },
                        child: const Text('Record Non-Fatal Error'),
                      ),
                    ],
                  ),
                );
              default:
                return const Center(child: Text('Loading'));
            }
          },
        ),
      ),
    );
  }

  Future<void> _closeAppDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: const Text('Diagnostic'),
              content:
                  const Text("Veuillez fermer l'application pour continuer"),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ]);
        });
  }
}
