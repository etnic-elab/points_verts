import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart'
    show HydratedBloc, HydratedStorage;
import 'package:path_provider/path_provider.dart'
    show getApplicationDocumentsDirectory;
import 'package:points_verts/bootstrap.dart';
import 'package:points_verts/core/core.dart'
    show AppEnvironment, MapsApiFactory, WeatherApiFactory;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  //Instantiate API's
  final mapsApi = MapsApiFactory.create(
    provider: AppEnvironment.mapApiProvider,
    apiKey: AppEnvironment.mapApiKey,
  );
  final weatherApi = WeatherApiFactory.create(
    provider: AppEnvironment.weatherApiProvider,
    apiKey: AppEnvironment.weatherApiKey,
  );

  await bootstrap(
    mapsApi: mapsApi,
    weatherApi: weatherApi,
  );
}
