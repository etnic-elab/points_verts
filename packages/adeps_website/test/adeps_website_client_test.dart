// ignore_for_file: prefer_const_constructors
import 'package:adeps_website/adeps_website.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class FakeUri extends Fake implements Uri {}

void main() {
  group('OdwbApiClient', () {
    late http.Client httpClient;
    late AdepsWebsiteClient adepsWebsiteClient;

    setUpAll(() {
      registerFallbackValue(FakeUri());
    });

    setUp(() {
      httpClient = MockHttpClient();
      adepsWebsiteClient = AdepsWebsiteClient(httpClient: httpClient);
    });

    group('constructor', () {
      test('does not require an httpClient', () {
        expect(AdepsWebsiteClient(), isNotNull);
      });
    });

    group('pointVertSearch', () {
      test('makes correct http request', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        try {
          await adepsWebsiteClient.pointVertSearch();
        } catch (_) {}
        verify(
          () => httpClient.get(
            Uri.https(
              'www.am-sport.cfwb.be',
              '/adeps/pv_data.asp',
              {},
            ),
          ),
        ).called(1);
      });

      test('throws PointVertRequestFailure on non-200 response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => await adepsWebsiteClient.pointVertSearch(),
          throwsA(isA<PointVertRequestFailure>()),
        );
      });

      test('throws PointVertNotFoundFailure on empty response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        await expectLater(
          adepsWebsiteClient.pointVertSearch(),
          throwsA(isA<PointVertNotFoundFailure>()),
        );
      });

      test('returns List<Point> on valid response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn(
          '''
16592;MELLET;M;50.502424;4.4726926;Hainaut;09-01-2022;Dimanche 9 Janvier 2022;Les Bons Villers;ptvert;
16593;NIVELLES;M;50.59777889999999;4.3364015;Brabant Wallon;09-01-2022;Dimanche 9 Janvier 2022;Nivelles;ptvert_annule;
16594;THOREMBAIS-LES-BÉGUINES;M;50.65197999999999;4.80843;Brabant Wallon;09-01-2022;Dimanche 9 Janvier 2022;Perwez;ptvert_annule;
16531;SOIGNIES;M;50.55988319999999;4.0817553;Hainaut;09-01-2022;Dimanche 9 Janvier 2022;Soignies;ptvert_annule;
16595;SIRAULT;M;50.5058399;3.7890311;Hainaut;09-01-2022;Dimanche 9 Janvier 2022;St-Ghislain;ptvert_annule;
16591;BELLEFONTAINE;M;49.665043;5.4965959;Luxembourg;09-01-2022;Dimanche 9 Janvier 2022;Tintigny;ptvert_annule;
16585;LIBRAMONT;M;49.9247853;5.3811321;Luxembourg;09-01-2022;Dimanche 9 Janvier 2022;Libramont-Chevigny;ptvert_annule;
16590;DURNAL;M;50.3389416;4.9829744;Namur;09-01-2022;Dimanche 9 Janvier 2022;Yvoir;ptvert_annule;
16586;LONZÉE;M;50.5524186;4.7248256;Namur;09-01-2022;Dimanche 9 Janvier 2022;Gembloux;ptvert_annule;
16587;WALCOURT;M;50.2508097;4.431755700000001;Namur;09-01-2022;Dimanche 9 Janvier 2022;Walcourt;ptvert_annule
''',
        );
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        final actual = await adepsWebsiteClient.pointVertSearch();
        expect(
            actual,
            isA<List<Point>>().having((l) => l.length, 'length', 10).having(
                  (l) => l.first,
                  'first_point',
                  isA<Point>()
                      .having((p) => p.activity, 'activity', Activity.walk)
                      .having(
                          (p) => p.date, 'date', DateTime.parse('2022-01-09'))
                      .having((p) => p.id, 'id', 16592)
                      .having(
                        (p) => p.location,
                        'location',
                        isA<Location>()
                            .having((l) => l.city, 'city', 'MELLET')
                            .having((l) => l.municipality, 'municipality',
                                'Les Bons Villers')
                            .having((l) => l.province, 'province', 'Hainaut')
                            .having(
                              (l) => l.latLng,
                              'latLng',
                              isA<LatLng>()
                                  .having((ll) => ll.latitude, 'latitude',
                                      50.502424)
                                  .having((ll) => ll.longitude, 'longitude',
                                      4.4726926),
                            ),
                      ),
                ));
      });
    });
  });
}
