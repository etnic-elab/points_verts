import 'package:points_verts/views/walks/walks_view.dart';

class WalkFilter {
  WalkFilter();

  WalkFilter.fromJson(Map<String, dynamic> json)
      : cancelledWalks = json['cancelled_walks'] ?? true,
        brabantWallon = json['brabantWallon'] ?? true,
        bruxelles = json['bruxelles'] ?? true,
        hainautEst = json['hainautEst'] ?? true,
        hainautOuest = json['hainautOuest'] ?? true,
        liege = json['liege'] ?? true,
        luxembourg = json['luxembourg'] ?? true,
        namur = json['namur'] ?? true,
        fifteenKm = json['fifteen_km'] ?? false,
        wheelchair = json['wheelchair'] ?? false,
        stroller = json['stroller'] ?? false,
        extraOrientation = json['extra_orientation'] ?? false,
        extraWalk = json['extra_walk'] ?? false,
        guided = json['guided'] ?? false,
        bike = json['bike'] ?? false,
        mountainBike = json['mountain_bike'] ?? false,
        waterSupply = json['water_supply'] ?? false,
        beWapp = json['be_wapp'] ?? false,
        transport = json['transport'] ?? false,
        adepSante = json['adep_sante'] ?? false,
        selectedPlace = Places.values
            .firstWhereOrNull((e) => e.toString() == json['selected_place']);

  Places? selectedPlace;
  bool cancelledWalks = true;
  bool brabantWallon = true;
  bool bruxelles = true;
  bool hainautEst = true;
  bool hainautOuest = true;
  bool liege = true;
  bool luxembourg = true;
  bool namur = true;
  bool fifteenKm = false;
  bool wheelchair = false;
  bool stroller = false;
  bool extraOrientation = false;
  bool extraWalk = false;
  bool guided = false;
  bool bike = false;
  bool mountainBike = false;
  bool waterSupply = false;
  bool beWapp = false;
  bool transport = false;
  bool adepSante = false;

  bool filterByProvince() {
    return !brabantWallon ||
        !bruxelles ||
        !hainautEst ||
        !hainautOuest ||
        !liege ||
        !luxembourg ||
        !namur;
  }

  List<String> provinceFilter() {
    final var results = <String>[];
    if (brabantWallon) results.add('Brabant Wallon');
    if (bruxelles) results.add('Bruxelles');
    if (hainautEst) results.add('Hainaut Est');
    if (hainautOuest) results.add('Hainaut Ouest');
    if (liege) results.add('Liège');
    if (luxembourg) results.add('Luxembourg');
    if (namur) results.add('Namur');
    return results;
  }

  Map<String, dynamic> toJson() => {
        'cancelled_walks': cancelledWalks,
        'brabantWallon': brabantWallon,
        'bruxelles': bruxelles,
        'hainautEst': hainautEst,
        'hainautOuest': hainautOuest,
        'liege': liege,
        'luxembourg': luxembourg,
        'namur': namur,
        'fifteen_km': fifteenKm,
        'wheelchair': wheelchair,
        'stroller': stroller,
        'extra_orientation': extraOrientation,
        'extra_walk': extraWalk,
        'guided': guided,
        'bike': bike,
        'mountain_bike': mountainBike,
        'water_supply': waterSupply,
        'be_wapp': beWapp,
        'transport': transport,
        'adep_sante': adepSante,
        'selected_place': selectedPlace?.toString(),
      };

  String getLabel() {
    final result = <String>[];
    if (!cancelledWalks) result.add('pas annulé');
    if (fifteenKm) result.add('15km');
    if (wheelchair) result.add('PMR');
    if (stroller) result.add('poussettes');
    if (extraOrientation) result.add('+ orientation');
    if (extraWalk) result.add('+ marche');
    if (guided) result.add('balade guidée');
    if (bike) result.add('vélo');
    if (mountainBike) result.add('VTT');
    if (waterSupply) result.add('ravitaillement');
    if (beWapp) result.add('BeWaPP');
    if (adepSante) result.add("Adep'santé");
    if (transport) result.add('transports en commun');
    return result.isEmpty ? 'aucun' : result.join(', ');
  }
}
