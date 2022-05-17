// ignore_for_file: prefer_const_constructors
import 'package:http/http.dart' as http;
import 'package:meta_points_verts_adeps_api/odwb_api.dart';
import 'package:test/test.dart';
import 'package:mocktail/mocktail.dart';

class MockHttpClient extends Mock implements http.Client {}

class MockResponse extends Mock implements http.Response {}

class MockGeofilterDistance extends Mock implements GeofilterDistance {}

class MockGeofilterPolygon extends Mock implements GeofilterPolygon {}

class FakeUri extends Fake implements Uri {}

void main() {
  group('OdwbApiClient', () {
    late http.Client httpClient;
    late OdwbApiClient odwbApiClient;

    setUpAll(() {
      registerFallbackValue(FakeUri());
    });

    setUp(() {
      httpClient = MockHttpClient();
      odwbApiClient = OdwbApiClient(httpClient: httpClient);
    });

    group('constructor', () {
      test('does not require an httpClient', () {
        expect(OdwbApiClient(), isNotNull);
      });
    });

    group('pointVertSearch', () {
      Set<String>? query = {'mock-query'};
      Map<String, dynamic> refine = {'mock': 'query'};
      Map<String, dynamic> exclude = {'mock': 'query'};
      MockGeofilterDistance geofilterDistance = MockGeofilterDistance();
      MockGeofilterPolygon geofilterPolygon = MockGeofilterPolygon();
      test('makes correct http request', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        try {
          await odwbApiClient.pointVertSearch(
              query: query,
              refine: refine,
              exclude: exclude,
              geofilterDistance: geofilterDistance,
              geofilterPolygon: geofilterPolygon);
        } catch (_) {}
        verify(
          () => httpClient.get(
            Uri.https(
              'www.odwb.be',
              '/api/records/1.0/search/',
              <String, dynamic>{
                'dataset': 'points-verts-de-ladeps',
                'q': query.join(' AND'),
                ...refine,
                ...exclude,
                'geofilter.distance': '$geofilterDistance',
                'geofilter.polygon': '$geofilterPolygon',
              },
            ),
          ),
        ).called(1);
      });

      test('throws PointVertRequestFailure on non-200 response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(400);
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => await odwbApiClient.pointVertSearch(),
          throwsA(isA<PointVertRequestFailure>()),
        );
      });

      test('throws PointVertNotFoundFailure on empty response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        await expectLater(
          odwbApiClient.pointVertSearch(),
          throwsA(isA<PointVertNotFoundFailure>()),
        );
      });

      test('throws PointVertNotFoundFailure on empty records', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn('{"records": []}');
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        expect(
          () async => await odwbApiClient.pointVertSearch(),
          throwsA(isA<PointVertNotFoundFailure>()),
        );
      });

      test('returns List<Point> on valid response', () async {
        final response = MockResponse();
        when(() => response.statusCode).thenReturn(200);
        when(() => response.body).thenReturn(
          '''
{
   "records":[
      {
         "datasetid":"points-verts-de-ladeps",
         "recordid":"80d0e62b9ec651f841f2ed9387c9a2eefc22d50f",
         "fields":{
            "statut":"Annulé",
            "activite":"Marche",
            "vtt":"Non",
            "adep_sante":"Non",
            "15km":"Oui",
            "ign":"40/8",
            "infos_rendez_vous":"Locaux scouts.",
            "balade_guidee":"Non",
            "velo":"Non",
            "ndeg_pv":"N055",
            "nom":"Danheux",
            "10km":"Non",
            "entite":"Fernelmont",
            "traces_gpx":"[{\\"titre\\": \\"Parcours 5 kms\\", \\"fichier\\": \\"https://www.am-sport.cfwb.be/adeps/pv_traces.asp?id=270&fichier=Parcours+5kms%2Egpx\\", \\"jourdemarche\\": \\"0\\", \\"couleur\\": \\"1\\"}, {\\"titre\\": \\"Parcours 10 kms\\", \\"fichier\\": \\"https://www.am-sport.cfwb.be/adeps/pv_traces.asp?id=271&fichier=Parcours+10kms+%2Egpx\\", \\"jourdemarche\\": \\"0\\", \\"couleur\\": \\"2\\"}, {\\"titre\\": \\"Parcours 15 kms\\", \\"fichier\\": \\"https://www.am-sport.cfwb.be/adeps/pv_traces.asp?id=272&fichier=Parcours+15kms+%2Egpx\\", \\"jourdemarche\\": \\"0\\", \\"couleur\\": \\"5\\"}, {\\"titre\\": \\"Parcours 20 kms\\", \\"fichier\\": \\"https://www.am-sport.cfwb.be/adeps/pv_traces.asp?id=273&fichier=Parcours+20kms+%2Egpx\\", \\"jourdemarche\\": \\"0\\", \\"couleur\\": \\"3\\"}]",
            "groupement":"Prêt à servir asbl",
            "province":"Namur",
            "poussettes":"Oui",
            "bewapp":"Oui",
            "orientation":"Non",
            "pmr":"Oui",
            "geopoint":[
               50.5570713,
               4.983708
            ],
            "lieu_de_rendez_vous":"Rue de la Victoire 7-9",
            "gsm":"0473 693 535",
            "prenom":"Jérémie",
            "ravitaillement":"Non",
            "latitude":"50.5570713",
            "longitude":"4.983708",
            "date":"2021-01-03",
            "id":15115,
            "localite":"NOVILLE-LES-BOIS"
         },
         "geometry":{
            "type":"Point",
            "coordinates":[
               4.983708,
               50.5570713
            ]
         },
         "record_timestamp":"2022-03-08T16:28:21.623Z"
      }
   ]
}
''',
        );
        when(() => httpClient.get(any())).thenAnswer((_) async => response);
        final actual = await odwbApiClient.pointVertSearch();
        expect(
            actual,
            isA<List<Point>>().having(
              (l) => l.first,
              'first_point',
              isA<Point>()
                  .having((p) => p.date, 'date', DateTime.parse('2021-01-03'))
                  .having((p) => p.code, 'code', 'N055')
                  .having((p) => p.publicTransport, 'public_transport', null)
                  .having((p) => p.status, 'status', Status.cancelled)
                  .having((p) => p.activity, 'activity', Activity.walk)
                  .having((p) => p.provision, 'provision', false)
                  .having((p) => p.reducedMobility, 'reduced_mobility', true)
                  .having((p) => p.buggy, 'buggy', true)
                  .having((p) => p.bewapp, 'bewapp', true)
                  .having((p) => p.mountainBike, 'mountain_bike', false)
                  .having((p) => p.bike, 'bike', false)
                  .having((p) => p.eightKm, 'eightKm', false)
                  .having((p) => p.tenKm, 'ten_km', false)
                  .having((p) => p.fifteenKm, 'fifteen_km', true)
                  .having((p) => p.guided, 'guided', false)
                  .having((p) => p.id, 'id', 15115)
                  .having(
                    (p) => p.organizer,
                    'organizer',
                    isA<Organizer>()
                        .having((o) => o.group, 'group', 'Prêt à servir asbl')
                        .having((o) => o.name, 'name', 'Danheux')
                        .having((o) => o.phoneNumber, 'phone_number',
                            '0473 693 535')
                        .having((o) => o.surname, 'surname', 'Jérémie'),
                  )
                  .having(
                    (p) => p.location,
                    'location',
                    isA<Location>()
                        .having((l) => l.additionalInfo, 'additional_info',
                            'Locaux scouts.')
                        .having((l) => l.address, 'address',
                            'Rue de la Victoire 7-9')
                        .having((l) => l.city, 'city', 'NOVILLE-LES-BOIS')
                        .having(
                            (l) => l.municipality, 'municipality', 'Fernelmont')
                        .having((l) => l.province, 'province', 'Namur')
                        .having(
                          (l) => l.latLng,
                          'latLng',
                          isA<LatLng>()
                              .having(
                                  (ll) => ll.latitude, 'latitude', 50.5570713)
                              .having(
                                  (ll) => ll.longitude, 'longitude', 4.983708),
                        ),
                  )
                  .having(
                    (p) => p.gpxs,
                    'gpxs',
                    isA<List>().having((l) => l.length, 'length', 4).having(
                          (l) => l.first,
                          'gpx',
                          isA<Gpx>()
                              .having((g) => g.availability, 'availability',
                                  Availability.always)
                              .having((g) => g.color, 'color', '1')
                              .having((g) => g.url, 'url',
                                  'https://www.am-sport.cfwb.be/adeps/pv_traces.asp?id=270&fichier=Parcours+5kms%2Egpx')
                              .having((g) => g.name, 'name', 'Parcours 5 kms'),
                        ),
                  ),
            ));
      });
    });
  });
}
