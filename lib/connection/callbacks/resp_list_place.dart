import '../../model/place.dart';

class RespListPlace {

  String? status = "";
  int? count = -1;
  int? countTotal = -1;
  int? pages = -1;
  List<Place>? places = [];

  RespListPlace({this.status, this.count, this.countTotal, this.pages, this.places});

  RespListPlace.fromJson(Map<String, dynamic> json) {
    this.status = json['status'];
    this.count = json['count'];
    this.countTotal = json['count_total'];
    this.pages = json['pages'];
    this.places = List<Place>.from(json["places"].map((value) {
      return Place.fromJson(value);
    }));
  }

  Map<String, dynamic> toJson() => {
    'status': status,
    'count': count,
    'count_total': countTotal,
    'pages': pages,
    'places': places,
  };
}
