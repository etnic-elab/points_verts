// // ignore_for_file: prefer_const_constructors
// import 'package:http/http.dart' as http;
// import 'package:meta_points_verts_adeps_api/odwb_api.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:test/test.dart';

// class MockHttpClient extends Mock implements http.Client {}

// class MockResponse extends Mock implements http.Response {}

// class FakeUri extends Fake implements Uri {}

// void main() {
//   group('OdwbApiClient', () {
//     late http.Client httpClient;
//     late OdwbApiClient odwbApiClient;

//     setUpAll(() {
//       registerFallbackValue(FakeUri());
//     });

//     setUp(() {
//       httpClient = MockHttpClient();
//       odwbApiClient = OdwbApiClient(httpClient: httpClient);
//     });

//     group('constructor', () {
//       test('does not require an httpClient', () {
//         expect(OdwbApiClient(), isNotNull);
//       });
//     });

//     group('locationSearch', () {
//       const query = 'mock-query';
//       test('makes correct http request', () async {
//         final response = MockResponse();
//         when(() => response.statusCode).thenReturn(200);
//         when(() => response.body).thenReturn('[]');
//         when(() => httpClient.get(any())).thenAnswer((_) async => response);
//         try {
//           await odwbApiClient.pointVertSearch(query);
//         } catch (_) {}
//         verify(
//           () => httpClient.get(
//             Uri.https(
//               'www.metaweather.com',
//               '/api/location/search',
//               <String, String>{'query': query},
//             ),
//           ),
//         ).called(1);
//       });

//       test('throws PointVertRequestFailure on non-200 response', () async {
//         final response = MockResponse();
//         when(() => response.statusCode).thenReturn(400);
//         when(() => httpClient.get(any())).thenAnswer((_) async => response);
//         expect(
//           () async => await odwbApiClient.pointVertSearch(query),
//           throwsA(isA<PointVertRequestFailure>()),
//         );
//       });

//       test('throws PointVertNotFoundFailure on empty response', () async {
//         final response = MockResponse();
//         when(() => response.statusCode).thenReturn(200);
//         when(() => response.body).thenReturn('[]');
//         when(() => httpClient.get(any())).thenAnswer((_) async => response);
//         await expectLater(
//           odwbApiClient.pointVertSearch(query),
//           throwsA(isA<PointVertNotFoundFailure>()),
//         );
//       });

//       test('returns Location on valid response', () async {
//         final response = MockResponse();
//         when(() => response.statusCode).thenReturn(200);
//         when(() => response.body).thenReturn(
//           '''[{
//             "title": "mock-title",
//             "location_type": "City",
//             "latt_long": "-34.75,83.28",
//             "woeid": 42
//           }]''',
//         );
//         when(() => httpClient.get(any())).thenAnswer((_) async => response);
//         final actual = await odwbApiClient.pointVertSearch(query);
//         expect(
//           actual,
//           isA<Location>()
//               .having((l) => l.title, 'title', 'mock-title')
//               .having((l) => l.locationType, 'type', LocationType.city)
//               .having(
//                 (l) => l.latLng,
//                 'latLng',
//                 isA<LatLng>()
//                     .having((c) => c.latitude, 'latitude', -34.75)
//                     .having((c) => c.longitude, 'longitude', 83.28),
//               )
//               .having((l) => l.woeid, 'woeid', 42),
//         );
//       });
//     });

//     group('getWeather', () {
//       const locationId = 42;

//       test('makes correct http request', () async {
//         final response = MockResponse();
//         when(() => response.statusCode).thenReturn(200);
//         when(() => response.body).thenReturn('{}');
//         when(() => httpClient.get(any())).thenAnswer((_) async => response);
//         try {
//           await odwbApiClient.getWeather(locationId);
//         } catch (_) {}
//         verify(
//           () => httpClient.get(
//             Uri.https('www.metaweather.com', '/api/location/$locationId'),
//           ),
//         ).called(1);
//       });

//       test('throws WeatherRequestFailure on non-200 response', () async {
//         final response = MockResponse();
//         when(() => response.statusCode).thenReturn(400);
//         when(() => httpClient.get(any())).thenAnswer((_) async => response);
//         expect(
//           () async => await odwbApiClient.getWeather(locationId),
//           throwsA(isA<WeatherRequestFailure>()),
//         );
//       });

//       test('throws WeatherNotFoundFailure on empty response', () async {
//         final response = MockResponse();
//         when(() => response.statusCode).thenReturn(200);
//         when(() => response.body).thenReturn('{}');
//         when(() => httpClient.get(any())).thenAnswer((_) async => response);
//         expect(
//           () async => await odwbApiClient.getWeather(locationId),
//           throwsA(isA<WeatherNotFoundFailure>()),
//         );
//       });

//       test('throws WeatherNotFoundFailure on empty consolidated weather',
//           () async {
//         final response = MockResponse();
//         when(() => response.statusCode).thenReturn(200);
//         when(() => response.body).thenReturn('{"consolidated_weather": []}');
//         when(() => httpClient.get(any())).thenAnswer((_) async => response);
//         expect(
//           () async => await odwbApiClient.getWeather(locationId),
//           throwsA(isA<WeatherNotFoundFailure>()),
//         );
//       });

//       test('returns weather on valid response', () async {
//         final response = MockResponse();
//         when(() => response.statusCode).thenReturn(200);
//         when(() => response.body).thenReturn('''
//           {"consolidated_weather":[{
//             "id":4907479830888448,
//             "weather_state_name":"Showers",
//             "weather_state_abbr":"s",
//             "wind_direction_compass":"SW",
//             "created":"2020-10-26T00:20:01.840132Z",
//             "applicable_date":"2020-10-26",
//             "min_temp":7.9399999999999995,
//             "max_temp":13.239999999999998,
//             "the_temp":12.825,
//             "wind_speed":7.876886316914553,
//             "wind_direction":246.17046093256732,
//             "air_pressure":997.0,
//             "humidity":73,
//             "visibility":11.037727173307882,
//             "predictability":73
//           }]}
//         ''');
//         when(() => httpClient.get(any())).thenAnswer((_) async => response);
//         final actual = await odwbApiClient.getWeather(locationId);
//         expect(
//           actual,
//           isA<Weather>()
//               .having((w) => w.id, 'id', 4907479830888448)
//               .having((w) => w.weatherStateName, 'state', 'Showers')
//               .having((w) => w.weatherStateAbbr, 'abbr', WeatherState.showers)
//               .having((w) => w.windDirectionCompass, 'wind',
//                   WindDirectionCompass.southWest)
//               .having((w) => w.created, 'created',
//                   DateTime.parse('2020-10-26T00:20:01.840132Z'))
//               .having((w) => w.applicableDate, 'applicableDate',
//                   DateTime.parse('2020-10-26'))
//               .having((w) => w.minTemp, 'minTemp', 7.9399999999999995)
//               .having((w) => w.maxTemp, 'maxTemp', 13.239999999999998)
//               .having((w) => w.theTemp, 'theTemp', 12.825)
//               .having((w) => w.windSpeed, 'windSpeed', 7.876886316914553)
//               .having(
//                   (w) => w.windDirection, 'windDirection', 246.17046093256732)
//               .having((w) => w.airPressure, 'airPressure', 997.0)
//               .having((w) => w.humidity, 'humidity', 73)
//               .having((w) => w.visibility, 'visibility', 11.037727173307882)
//               .having((w) => w.predictability, 'predictability', 73),
//         );
//       });
//     });
//   });
// }


//         // isA<Point>()
//         //       .having(
//         //         (p) => p.status,
//         //         'status',
//         //         Status.cancelled,
//         //       )
//         //       .having(
//         //         (p) => p.activity,
//         //         'activity',
//         //         Activity.unknown,
//         //       )
//         //       .having(
//         //         (p) => p.buggy,
//         //         'buggy',
//         //         false,
//         //       )
//         //       .having(
//         //         (p) => p.eightKm,
//         //         'eightKm',
//         //         true,
//         //       )
//         //       .having(
//         //         (p) => p.organizer.surname,
//         //         'organizer.surname',
//         //         'Géraldine',
//         //       )
//         //       .having(
//         //         (p) => p.location.latLng,
//         //         'location.latLng',
//         //         const LatLng(latitude: 50.2731, longitude: 4.43281),
//         //       )
//         //       .having(
//         //         (p) => p.gpxs.first.availability,
//         //         'gpxs.first.availability',
//         //         Availability.always,
//         //       )
//         //       .having(
//         //         (p) => p.gpxs.length,
//         //         'gpxs.length',
//         //         4,
//         //       )
//         //       .having(
//         //         (p) => p.date,
//         //         'date',
//         //         DateTime.parse('2021-01-03'),
//         //       )
//         //       .having(
//         //         (p) => p.code,
//         //         'code',
//         //         'N146',
//         //       )
//         //       .having(
//         //         (p) => p.publicTransport,
//         //         'public_transport',
//         //         null,
//         //       ),