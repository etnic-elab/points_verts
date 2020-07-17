class WalkFilter {

  WalkFilter();

  bool cancelledWalks = true;
  bool brabantWallon = true;
  bool hainautEst = true;
  bool hainautOuest = true;
  bool liege = true;
  bool luxembourg = true;
  bool namur = true;

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
        namur = json['namur'];

  Map<String, dynamic> toJson() => {
        'cancelledWalks': cancelledWalks,
        'brabantWallon': brabantWallon,
        'hainautEst': hainautEst,
        'hainautOuest': hainautOuest,
        'liege': liege,
        'luxembourg': luxembourg,
        'namur': namur,
      };
}
