class Walk {
  Walk(
      {this.city,
      this.type,
      this.province,
      this.long,
      this.lat,
      this.date,
      this.status});

  final String city;
  final String type;
  final String province;
  final String date;
  final double long;
  final double lat;
  final String status;

  double distance;
}
