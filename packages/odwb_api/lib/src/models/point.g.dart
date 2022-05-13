// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: implicit_dynamic_parameter

part of 'point.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Point _$PointFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Point',
      json,
      ($checkedConvert) {
        final val = Point(
          id: $checkedConvert('id', (v) => v as int),
          code: $checkedConvert('ndeg_pv', (v) => v as String),
          ign: $checkedConvert('ign', (v) => v as String),
          status: $checkedConvert(
              'statut',
              (v) => $enumDecode(_$StatusEnumMap, v,
                  unknownValue: Status.unknown)),
          activity: $checkedConvert(
              'activite',
              (v) => $enumDecode(_$ActivityEnumMap, v,
                  unknownValue: Activity.unknown)),
          date: $checkedConvert('date', (v) => DateTime.parse(v as String)),
          location: $checkedConvert(
            'location',
            (v) => Location.fromJson(v as Map<String, dynamic>),
            readValue: Point._readLocation,
          ),
          organizer: $checkedConvert(
            'organizer',
            (v) => Organizer.fromJson(v as Map<String, dynamic>),
            readValue: Point._readOrganizer,
          ),
          gpxs: $checkedConvert('traces_gpx',
              (v) => const GpxListConverter().fromJson(v as String)),
          eightKm: $checkedConvert('orientation',
              (v) => const BoolConverter().fromJson(v as String)),
          tenKm: $checkedConvert(
              '10km', (v) => const BoolConverter().fromJson(v as String)),
          fifteenKm: $checkedConvert(
              '15km', (v) => const BoolConverter().fromJson(v as String)),
          mountainBike: $checkedConvert(
              'vtt', (v) => const BoolConverter().fromJson(v as String)),
          bike: $checkedConvert(
              'velo', (v) => const BoolConverter().fromJson(v as String)),
          buggy: $checkedConvert(
              'poussettes', (v) => const BoolConverter().fromJson(v as String)),
          reducedMobility: $checkedConvert(
              'pmr', (v) => const BoolConverter().fromJson(v as String)),
          adepSante: $checkedConvert(
              'adep_sante', (v) => const BoolConverter().fromJson(v as String)),
          guided: $checkedConvert('balade_guidee',
              (v) => const BoolConverter().fromJson(v as String)),
          bewapp: $checkedConvert(
              'bewapp', (v) => const BoolConverter().fromJson(v as String)),
          provision: $checkedConvert('ravitaillement',
              (v) => const BoolConverter().fromJson(v as String)),
          publicTransport: $checkedConvert('gare', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'code': 'ndeg_pv',
        'status': 'statut',
        'activity': 'activite',
        'gpxs': 'traces_gpx',
        'eightKm': 'orientation',
        'tenKm': '10km',
        'fifteenKm': '15km',
        'mountainBike': 'vtt',
        'bike': 'velo',
        'buggy': 'poussettes',
        'reducedMobility': 'pmr',
        'adepSante': 'adep_sante',
        'guided': 'balade_guidee',
        'provision': 'ravitaillement',
        'publicTransport': 'gare'
      },
    );

const _$StatusEnumMap = {
  Status.modified: 'Modifié',
  Status.cancelled: 'Annulé',
  Status.ok: 'OK',
  Status.unknown: 'unknown',
};

const _$ActivityEnumMap = {
  Activity.walk: 'Marche',
  Activity.orientation: 'Orientation',
  Activity.unknown: 'unknown',
};

Organizer _$OrganizerFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Organizer',
      json,
      ($checkedConvert) {
        final val = Organizer(
          group: $checkedConvert('groupement', (v) => v as String),
          name: $checkedConvert('nom', (v) => v as String),
          surname: $checkedConvert('prenom', (v) => v as String),
          phoneNumber: $checkedConvert('gsm', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'group': 'groupement',
        'name': 'nom',
        'surname': 'prenom',
        'phoneNumber': 'gsm'
      },
    );

Location _$LocationFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Location',
      json,
      ($checkedConvert) {
        final val = Location(
          address: $checkedConvert('lieu_de_rendez_vous', (v) => v as String),
          city: $checkedConvert('localite', (v) => v as String),
          municipality: $checkedConvert('entite', (v) => v as String),
          province: $checkedConvert('province', (v) => v as String),
          latLng: $checkedConvert(
              'geopoint', (v) => const LatLngConverter().fromJson(v as List)),
          additionalInfo:
              $checkedConvert('infos_rendez_vous', (v) => v as String?),
        );
        return val;
      },
      fieldKeyMap: const {
        'address': 'lieu_de_rendez_vous',
        'city': 'localite',
        'municipality': 'entite',
        'latLng': 'geopoint',
        'additionalInfo': 'infos_rendez_vous'
      },
    );

Gpx _$GpxFromJson(Map<String, dynamic> json) => $checkedCreate(
      'Gpx',
      json,
      ($checkedConvert) {
        final val = Gpx(
          name: $checkedConvert('titre', (v) => v as String),
          file: $checkedConvert('fichier', (v) => v as String),
          availability: $checkedConvert(
              'jourdemarche',
              (v) => $enumDecode(_$AvailabilityEnumMap, v,
                  unknownValue: Availability.sameDay)),
          color: $checkedConvert('couleur', (v) => v as String),
        );
        return val;
      },
      fieldKeyMap: const {
        'name': 'titre',
        'file': 'fichier',
        'availability': 'jourdemarche',
        'color': 'couleur'
      },
    );

const _$AvailabilityEnumMap = {
  Availability.always: '0',
  Availability.sameDay: '1',
};
