import '../../model/place.dart';

class RespPlaceDetails {

  Place? place;

  RespPlaceDetails();

  RespPlaceDetails.fromJson(Map<String, dynamic> json) {
    this.place = json['place'] != null ? Place.fromJson(json['place']) : null;
  }

  Map<String, dynamic> toJson() => {
    'place': place,
  };

}
