class NewsInfo {

  int? id;
  String? title;
  String? briefContent;
  String? fullContent;
  String? image;
  int? lastUpdate;

  NewsInfo.fromJson(Map<String, dynamic> json){
    this.id = json['id'];
    this.title = json['title'];
    this.briefContent = json['brief_content'];
    this.fullContent = json['full_content'];
    this.image = json['image'];
    this.lastUpdate = json['last_update'];
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'brief_content': briefContent,
    'full_content': fullContent,
    'image': image,
    'last_update': lastUpdate,
  };

}
