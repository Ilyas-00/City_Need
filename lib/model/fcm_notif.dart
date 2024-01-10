
import 'news_info.dart';
import 'place.dart';

class FcmNotif {

  String? title, content, type;
  Place? place;
  NewsInfo? news;

  FcmNotif(this.title, this.content);

  FcmNotif.fromJson(Map<String, dynamic> json) {
    this.title = json['title'];
    this.content = json['content'];
    this.type = json['type'];
    this.place = json['place'] != null ? Place.fromJson(json['place']) : null;
    this.news = json['news'] != null ? NewsInfo.fromJson(json['news']) : null;
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'type': type,
    'place': place,
    'news': news
  };

}