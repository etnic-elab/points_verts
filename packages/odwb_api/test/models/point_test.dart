import 'package:json_annotation/json_annotation.dart';
import 'package:meta_points_verts_adeps_api/odwb_api.dart';
import 'package:test/test.dart';

void main() {
  group('Point', () {
    group('fromJson', () {
      test(
          'throws CheckedFromJsonException when non-null annotated field is null',
          () {
        expect(
          () => Point.fromJson(<String, dynamic>{}),
          throwsA(isA<CheckedFromJsonException>()),
        );
      });

      test('returns Enum.unknown for unsupported enums', () {
        expect(
            Point.fromJson(<String, dynamic>{
              "statut": "-",
              "activite": "-",
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
              "orientation": "Oui",
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
                  Status.unknown,
                )
                .having(
                  (p) => p.activity,
                  'activity',
                  Activity.unknown,
                ));
      });
    });
  });
}
