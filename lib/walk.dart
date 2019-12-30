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

  bool isCancelled() {
    return status == "ptvert_annule";
  }

  String getFormattedDistance() {
    if (distance == null) {
      return null;
    } else if (distance < 1000) {
      return '${distance.round().toString()} m';
    } else {
      return '${(distance / 1000).round().toString()} km';
    }
  }
}
