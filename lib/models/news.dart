class News {
  int id;
  String? url;
  String name;
  String imageUrlLandscape;
  String imageUrlPortrait;

  News.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        url = json['url'],
        name = json['name'],
        imageUrlLandscape = json['imageUrlLandscape'],
        imageUrlPortrait = json['imageUrlPortrait'];
}
