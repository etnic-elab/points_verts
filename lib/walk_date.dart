class WalkDate {
  final int id;
  final DateTime date;

  WalkDate({this.id, this.date});

  Map<String, dynamic> toMap() {
    return {'id': id, 'date': date.toIso8601String()};
  }

  @override
  String toString() {
    return 'WalkDate{id: $id, date: $date}';
  }
}
