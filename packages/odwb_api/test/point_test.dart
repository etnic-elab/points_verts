import 'package:meta_points_verts_adeps_api/odwb_api.dart';
import 'package:test/test.dart';

void main() {
  group('Weather', () {
    group('fromJson', () {
      test(
          'returns WeatherState.unknown '
          'for unsupported weather_state_abbr', () {
        expect(
          Point.fromJson(<String, dynamic>{
            "statut": "Annulé",
            "activite": "Unknown",
            "vtt": "Non",
            "adep_sante": "Non",
            "15km": "Non",
            "ign": "52/8",
            "balade_guidee": "Non",
            "velo": "Non",
            "ndeg_pv": "N146",
            "nom": "Laeremans",
            "10km": "Non",
            "entite": "Walcourt",
            "traces_gpx": "[]",
            "groupement": "Marche militaire et folklorique de Pry asbl",
            "province": "Namur",
            "poussettes": "Non",
            "bewapp": "Non",
            "orientation": "Non",
            "pmr": "Non",
            "geopoint": [50.2731, 4.43281],
            "lieu_de_rendez_vous": "Hall Les Scousses, rue du Grand Pont",
            "gsm": "0494 254 180",
            "prenom": "Géraldine",
            "ravitaillement": "Non",
            "latitude": "50.2731",
            "longitude": "4.43281",
            "date": "2021-01-03",
            "id": 15117,
            "localite": "PRY",
          }),
          isA<Point>()
              .having(
                (p) => p.status,
                'status',
                Status.cancelled,
              )
              .having(
                (p) => p.activity,
                'activity',
                Activity.unknown,
              ),
        );
      });
    });

    group('WeatherStateX', () {
      const weatherState = WeatherState.showers;
      test('abbr returns correct string abbreviation', () {
        expect(weatherState.abbr, 's');
      });
    });
  });
}
