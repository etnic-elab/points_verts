import 'package:points_verts/abstractions/extended_value.dart';

class WalkFilter {
  WalkFilter();
  WalkFilter.date(this.date);

  var cancelledWalks = ExtendedValue(true,
      layout: LayoutExtension.cancelled()
          .copyWith(description: 'Afficher les marches annulées'));

  var brabantWallon = initProvince('Brabant Wallon');
  var bruxelles = initProvince('Bruxelles');
  var hainautEst = initProvince('Hainaut Est');
  var hainautOuest = initProvince('Hainaut Ouest');
  var liege = initProvince('Liège');
  var luxembourg = initProvince('Luxembourg');
  var namur = initProvince('Namur');

  var fifteenKm = initCriteria(LayoutExtension.fifteenKm());
  var wheelchair = initCriteria(LayoutExtension.wheelchair());
  var stroller = initCriteria(LayoutExtension.stroller());
  var extraOrientation = initCriteria(LayoutExtension.extraOrientation());
  var extraWalk = initCriteria(LayoutExtension.extraWalk());
  var guided = initCriteria(LayoutExtension.guided());
  var bike = initCriteria(LayoutExtension.bike());
  var mountainBike = initCriteria(LayoutExtension.mountainBike());
  var waterSupply = initCriteria(LayoutExtension.waterSupply());
  var beWapp = initCriteria(LayoutExtension.beWapp());
  var transport = initCriteria(LayoutExtension.transport());
  var adepSante = initCriteria(LayoutExtension.adepSante());
  DateTime? date;

  List<ExtendedValue<bool>> get provinces {
    return [
      brabantWallon,
      bruxelles,
      hainautEst,
      hainautOuest,
      liege,
      luxembourg,
      namur
    ];
  }

  List<ExtendedValue<bool>> get criterias {
    return [
      fifteenKm,
      wheelchair,
      stroller,
      extraOrientation,
      extraWalk,
      guided,
      bike,
      mountainBike,
      waterSupply,
      beWapp,
      transport,
      adepSante
    ];
  }

  static ExtendedValue<bool> initProvince(String labelName) {
    return ExtendedValue(true, layout: LayoutExtension.of(label: labelName));
  }

  static ExtendedValue<bool> initCriteria(LayoutExtension extension) {
    return ExtendedValue(false, layout: extension);
  }

  bool get filterByProvince => provinceFilter.length != provinces.length;

  Iterable<String> get provinceFilter {
    return provinces
        .map((province) => province.hasValue ? province.layout!.label : null)
        .whereType<String>();
  }

  WalkFilter reset({bool alsoDate = false}) {
    cancelledWalks.value = true;
    brabantWallon.value = true;
    bruxelles.value = true;
    hainautEst.value = true;
    hainautOuest.value = true;
    liege.value = true;
    luxembourg.value = true;
    namur.value = true;
    fifteenKm.value = false;
    wheelchair.value = false;
    stroller.value = false;
    extraOrientation.value = false;
    extraWalk.value = false;
    guided.value = false;
    bike.value = false;
    mountainBike.value = false;
    waterSupply.value = false;
    beWapp.value = false;
    transport.value = false;
    adepSante.value = false;
    if (alsoDate) date = null;

    return this;
  }

  factory WalkFilter.fromJson(Map<String, dynamic> json) {
    WalkFilter filter = WalkFilter();
    filter.cancelledWalks.value = json['cancelled_walks'] ?? true;
    filter.brabantWallon.value = json['brabantWallon'] ?? true;
    filter.bruxelles.value = json['bruxelles'] ?? true;
    filter.hainautEst.value = json['hainautEst'] ?? true;
    filter.hainautOuest.value = json['hainautOuest'] ?? true;
    filter.liege.value = json['liege'] ?? true;
    filter.luxembourg.value = json['luxembourg'] ?? true;
    filter.namur.value = json['namur'] ?? true;
    filter.fifteenKm.value = json['fifteen_km'] ?? false;
    filter.wheelchair.value = json['wheelchair'] ?? false;
    filter.stroller.value = json['stroller'] ?? false;
    filter.extraOrientation.value = json['extra_orientation'] ?? false;
    filter.extraWalk.value = json['extra_walk'] ?? false;
    filter.guided.value = json['guided'] ?? false;
    filter.bike.value = json['bike'] ?? false;
    filter.mountainBike.value = json['mountain_bike'] ?? false;
    filter.waterSupply.value = json['water_supply'] ?? false;
    filter.beWapp.value = json['be_wapp'] ?? false;
    filter.transport.value = json['transport'] ?? false;
    filter.adepSante.value = json['adep_sante'] ?? false;
    filter.date = DateTime.tryParse(json['date'] ?? 'noDate');

    return filter;
  }

  Map<String, dynamic> toJson() => {
        'cancelled_walks': cancelledWalks.value,
        'brabantWallon': brabantWallon.value,
        'bruxelles': bruxelles.value,
        'hainautEst': hainautEst.value,
        'hainautOuest': hainautOuest.value,
        'liege': liege.value,
        'luxembourg': luxembourg.value,
        'namur': namur.value,
        'fifteen_km': fifteenKm.value,
        'wheelchair': wheelchair.value,
        'stroller': stroller.value,
        'extra_orientation': extraOrientation.value,
        'extra_walk': extraWalk.value,
        'guided': guided.value,
        'bike': bike.value,
        'mountain_bike': mountainBike.value,
        'water_supply': waterSupply.value,
        'be_wapp': beWapp.value,
        'transport': transport.value,
        'adep_sante': adepSante.value,
        if (date != null) 'date': date!.toIso8601String(),
      };
}
