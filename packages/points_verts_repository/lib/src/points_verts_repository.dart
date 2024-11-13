import 'package:adeps_website_api/adeps_website_api.dart' show AdepsWebsiteApi;
import 'package:app_cache_registry/app_cache_registry.dart'
    show
        AdepsWebsiteCacheManager,
        AppCacheRegistry,
        OdwbCacheManager,
        TrailParserCacheManager,
        TripsCacheManager,
        WeatherCacheManager;

import 'package:app_user_preferences_registry/app_user_preferences_registry.dart'
    show AppUserPreferencesRegistry, HomeAddressStorage;

import 'package:maps_api/maps_api.dart' show Geolocation, MapsApi;
import 'package:odwb_points_verts_api/odwb_points_verts_api.dart'
    show OdwbPointsVertsApi;
import 'package:points_verts_repository/points_verts_repository.dart';
import 'package:rxdart/rxdart.dart' show BehaviorSubject;
import 'package:trail_parser_api/trail_parser_api.dart' show TrailParserApi;
import 'package:weather_api/weather_api.dart' show WeatherApi, WeatherForecast;

/// {@template points_verts_repository}
/// A repository to fetch, manipulate and store the points verts data.
///
/// Uses various cache managers and storage systems to handle data persistence
/// and retrieval.
/// {@endtemplate}
class PointsVertsRepository {
  /// {@macro points_verts_repository}
  PointsVertsRepository({
    required MapsApi mapsApi,
    required WeatherApi weatherApi,
    OdwbPointsVertsApi? odwbPointVertApi,
    AdepsWebsiteApi? adepsWebsiteApi,
    TrailParserApi? trailParserApi,
  })  : _mapsApi = mapsApi,
        _weatherApi = weatherApi,
        _odwbPointsVertsApi = odwbPointVertApi ?? OdwbPointsVertsApi(),
        _adepsWebsiteApi = adepsWebsiteApi ?? AdepsWebsiteApi(),
        _trailParserApi = trailParserApi ?? TrailParserApi();

  final MapsApi _mapsApi;
  final WeatherApi _weatherApi;
  final OdwbPointsVertsApi _odwbPointsVertsApi;
  final AdepsWebsiteApi _adepsWebsiteApi;
  final TrailParserApi _trailParserApi;

  final _pointVertStreamController =
      BehaviorSubject<List<PointVert>>.seeded(const <PointVert>[]);

  /// Stream of [PointVert] list that broadcasts updates to all listeners
  Stream<List<PointVert>> get pointsVerts =>
      _pointVertStreamController.asBroadcastStream();

  /// Closes the stream controller when the repository is disposed
  void dispose() {
    _pointVertStreamController.close();
  }

  Future<void> loadPointsVerts() async {
    // TODO(msimonart): load backup walks if needed
    // Fetch all points verts from ODWB
    final odwbCacheManager = AppCacheRegistry.instance.get<OdwbCacheManager>();

    final odwbPointsVerts = await odwbCacheManager.fetchPointsVerts(
      defaultValueProvider: _odwbPointsVertsApi.getAllPointsVerts,
    );

    final pointsVerts = odwbPointsVerts.map(PointVert.fromOdwb).toList();

    // Update the stream with new data
    _pointVertStreamController.add(pointsVerts);
  }

  Future<void> loadCalendarInfo({
    required DateTime date,
  }) async {
    // Get current points verts from stream
    final currentPointsVerts = await pointsVerts.first;

    // Create a copy of current points verts
    final updatedPointsVerts = List<PointVert>.from(currentPointsVerts);

    await _fixStatuses(updatedPointsVerts, date: date);

    final homeAddressStorage =
        AppUserPreferencesRegistry.instance.get<HomeAddressStorage>();

    final homeAddress = await homeAddressStorage.get();

    if (homeAddress != null) {
      await _loadTrips(
        updatedPointsVerts,
        date: date,
        origin: homeAddress.geolocation,
      );
    }

    // Update the stream with new data
    _pointVertStreamController.add(updatedPointsVerts);
  }

  Future<void> loadDetailedInfo(int pointVertId) async {
    // Get current points verts from stream
    final currentPointsVerts = await pointsVerts.first;

    // Find the specific point vert
    final index = currentPointsVerts.indexWhere((pv) => pv.id == pointVertId);
    if (index == -1) return;

    final pointVert = currentPointsVerts[index];

    // Create a copy of current points verts
    final updatedPointsVerts = List<PointVert>.from(currentPointsVerts);

    // Load weather and trail info
    final weatherForecasts = await _loadWeather(pointVert);
    final updatedParcours = await _loadTrails(pointVert);

    // Update the point vert with new info
    updatedPointsVerts[index] = pointVert.copyWith(
      previsionsMeteo: weatherForecasts,
      parcours: updatedParcours,
    );

    // Update the stream with new data
    _pointVertStreamController.add(updatedPointsVerts);
  }

  Future<void> _fixStatuses(
    List<PointVert> pointsVerts, {
    required DateTime date,
  }) async {
    // Fetch website points for each date and update statuses
    final adepsWebsiteCacheManager =
        AppCacheRegistry.instance.get<AdepsWebsiteCacheManager>();

    final websitePointsVerts = await adepsWebsiteCacheManager.fetchPointsVerts(
      date,
      defaultValueProvider: () => _adepsWebsiteApi.getPointsVerts(date),
    );

    // Update statuses for matching points
    for (final websitePointVert in websitePointsVerts) {
      final index =
          pointsVerts.indexWhere((pv) => pv.id == websitePointVert.id);
      if (index != -1) {
        // Create a new point vert with updated status
        pointsVerts[index] = pointsVerts[index].copyWith(
          statut: PointVertStatut.fromWebsite(websitePointVert.statut),
        );
      }
    }
  }

  Future<void> _loadTrips(
    List<PointVert> pointsVerts, {
    required DateTime date,
    required Geolocation origin,
  }) async {
    // Find points verts for the specified date
    final datePointsVerts = pointsVerts.where((pointVert) {
      final pointVertDate = pointVert.date;
      return pointVertDate.year == date.year &&
          pointVertDate.month == date.month &&
          pointVertDate.day == date.day &&
          pointVert.statut == PointVertStatut.ok;
    }).toList();

    if (datePointsVerts.isEmpty) {
      return;
    }

    // Extract destinations from points verts
    final destinations =
        datePointsVerts.map((pointVert) => pointVert.geolocation).toList();

    // Fetch trips information with cache expiration at end of the requested date
    final tripsCacheManager =
        AppCacheRegistry.instance.get<TripsCacheManager>();

    final trips = await tripsCacheManager.fetchTrips(
      origin: origin,
      destinations: destinations,
      expiration: DateTime(
        date.year,
        date.month,
        date.day,
        23,
        59,
        59,
      ),
      defaultValueProvider: _mapsApi.getTrips,
    );

    // Match trips with points verts and update the list
    for (final trip in trips) {
      final index = pointsVerts.indexWhere(
        (pointVert) => pointVert.geolocation == trip.destination,
      );

      if (index != -1) {
        pointsVerts[index] = pointsVerts[index].copyWith(
          trajetDomicile: trip,
        );
      }
    }
  }

  Future<List<WeatherForecast>> _loadWeather(PointVert pointVert) async {
    final date = pointVert.date;

    final startDate = DateTime(date.year, date.month, date.day);
    final endDate = DateTime(date.year, date.month, date.day, 23, 59, 59, 999);

    final weatherCacheManager =
        AppCacheRegistry.instance.get<WeatherCacheManager>();

    return weatherCacheManager.fetchWeatherForecasts(
      geolocation: pointVert.geolocation,
      date: pointVert.date,
      defaultValueProvider: () => _weatherApi.getForecast(
        geolocation: pointVert.geolocation,
        startDate: startDate,
        endDate: endDate,
      ),
    );
  }

  Future<List<Parcours>> _loadTrails(PointVert pointVert) async {
    final updatedParcours = <Parcours>[];

    final trailParserCacheManager =
        AppCacheRegistry.instance.get<TrailParserCacheManager>();

    for (final parcours in pointVert.parcours) {
      try {
        final trailInfo = await trailParserCacheManager.fetchTrail(
          parcours.fichier,
          defaultValueProvider: () =>
              _trailParserApi.parseTrailFromUrl(parcours.fichier),
        );
        updatedParcours.add(parcours.copyWith(detailParcours: trailInfo));
      } catch (e) {
        // If trail loading fails, keep the original parcours
        updatedParcours.add(parcours);
      }
    }

    return updatedParcours;
  }
}
