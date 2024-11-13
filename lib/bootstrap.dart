import 'dart:async';
import 'dart:developer' as developer show log;

import 'package:app_cache_registry/app_cache_registry.dart'
    show AppCacheRegistry;
import 'package:app_user_preferences_registry/app_user_preferences_registry.dart'
    show AppUserPreferencesRegistry;
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart' show PlatformDispatcher;
import 'package:flutter/widgets.dart';
import 'package:maps_api/maps_api.dart' show MapsApi;
import 'package:maps_repository/maps_repository.dart' show MapsRepository;
import 'package:points_verts/core/config/app_bloc_observer.dart'
    show AppBlocObserver;
import 'package:points_verts_repository/points_verts_repository.dart'
    show PointsVertsRepository;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:weather_api/weather_api.dart' show WeatherApi;

Future<void> bootstrap({
  required MapsApi mapsApi,
  required WeatherApi weatherApi,
}) async {
  FlutterError.onError = (details) {
    developer.log(details.exceptionAsString(), stackTrace: details.stack);
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    developer.log(error.toString(), stackTrace: stack);
    return true;
  };

  Bloc.observer = const AppBlocObserver();

  final prefs = await SharedPreferences.getInstance();
  await AppUserPreferencesRegistry.instance.initializeUserPreferences(
    prefs: prefs,
  );
  await AppCacheRegistry.instance.initializeCaches(
    prefs: prefs,
  );

  final mapsRepository = MapsRepository(mapsApi: mapsApi);
  final pointsVertsRePository = PointsVertsRepository(
    mapsApi: mapsApi,
    weatherApi: weatherApi,
  );

  // Add cross-flavor configuration here

  // final tileRepository = TileRepository(websiteId: websiteId);

  // runApp(
  //   App(
  //     tileRepository: tileRepository,
  //     chatbotRepository: ChatbotRepository(),
  //   ),
  // );
}
