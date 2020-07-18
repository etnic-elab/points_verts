class WalkFilter {
  WalkFilter();

  bool cancelledWalks = true;
  bool brabantWallon = true;
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

  bool filterByProvince() {
    return !brabantWallon ||
        !hainautEst ||
        !hainautOuest ||
        !liege ||
        !luxembourg ||
        !namur;
  }

  List<String> provinceFilter() {
    List<String> results = [];
    if (brabantWallon) results.add("Brabant Wallon");
    if (hainautEst) results.add("Hainaut Est");
    if (hainautOuest) results.add("Hainaut Ouest");
    if (liege) results.add("Liège");
    if (luxembourg) results.add("Luxembourg");
    if (namur) results.add("Namur");
    return results;
  }

  WalkFilter.fromJson(Map<String, dynamic> json)
      : cancelledWalks = json['cancelledWalks'],
        brabantWallon = json['brabantWallon'],
        hainautEst = json['hainautEst'],
        hainautOuest = json['hainautOuest'],
        liege = json['liege'],
        luxembourg = json['luxembourg'],
        namur = json['namur'],
        fifteenKm = json['fifteen_km'],
        wheelchair = json['wheelchair'],
        stroller = json['stroller'],
        extraOrientation = json['extra_orientation'],
        extraWalk = json['extra_walk'],
        guided = json['guided'],
        bike = json['bike'],
        mountainBike = json['mountain_bike'],
        waterSupply = json['water_supply'],
        beWapp = json['be_wapp'],
        transport = json['transport'];

  Map<String, dynamic> toJson() => {
        'cancelledWalks': cancelledWalks,
        'brabantWallon': brabantWallon,
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
        'transport': transport
      };
}
