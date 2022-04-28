class News {
  final int id;
  final String? url;
  final String name;
  final String imageUrlLandscape;
  final String imageUrlPortrait;
  final int? intervalHours;

  News.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        url = json['url'],
        name = json['name'],
        imageUrlLandscape = json['imageUrlLandscape'],
        imageUrlPortrait = json['imageUrlPortrait'],
        intervalHours = json['intervalHours'];
}
