import '../../model/news_info.dart';

class RespNewsInfo {

  String? status = "";
  int? count = -1;
  int? countTotal = -1;
  int? pages = -1;
  List<NewsInfo>? newsInfos = [];

  RespNewsInfo({this.status, this.count, this.countTotal, this.pages, this.newsInfos});

  RespNewsInfo.fromJson(Map<String, dynamic> json) {
    this.status = json['status'];
    this.count = json['count'];
    this.countTotal = json['count_total'];
    this.pages = json['pages'];
    this.newsInfos = List<NewsInfo>.from(json["news_infos"].map((value) {
      return NewsInfo.fromJson(value);
    }));
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'count': count,
    'count_total': countTotal,
    'pages': pages,
    'news_infos': newsInfos,
  };
}
