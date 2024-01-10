import 'dart:core';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'category.dart';
import 'images.dart';

class Place {
  int? placeId;
  String name = "";
  String image = "";
  String address = "";
  String phone = "";
  String website = "";
  String description = "";
  double? lng;
  double? lat;
  int? lastUpdate;
  double distance = -1;

  List<Category> categories = [];
  List<Images> images = [];

  Place(this.placeId, this.name, this.image);

  LatLng getPosition() {
    return new LatLng(lat!, lng!);
  }

  bool isDraft() {
    return (address.isEmpty && phone.isEmpty && website.isEmpty && description.isEmpty);
  }

  Place.fromJson(Map<String, dynamic> json) {
    this.placeId = json['place_id'];
    this.name = json['name'] ?? "";
    this.image = json['image'] ?? "";
    this.address = json['address'] ?? "";
    this.phone = json['phone'] != null ? json['phone'].toString() : "";
    this.website = json['website'] ?? "";
    this.description = json['description'] ?? "";
    this.lng = json['lng'] != null ? json['lng'].toDouble() : 0.0;
    this.lat = json['lat'] != null ? json['lat'].toDouble() : 0.0;
    this.distance = json['distance'] ?? -1;
    this.lastUpdate = json['last_update'] ?? 0;

    this.categories = json['categories'] == null ? [] : List<Category>.from(json['categories'].map((value) {
      return Category.fromJson(value);
    }));

    this.images = json['images'] == null ? [] : List<Images>.from(json['images'].map((value) {
      return Images.fromJson(value);
    }));

  }

  Map<String, dynamic> toJson() => {
    'place_id': placeId,
    'name': name,
    'image': image,
    'address': address,
    'phone': phone,
    'website': website,
    'description': description,
    'lng': lng,
    'lat': lat,
    'distance': distance,
    'last_update': lastUpdate,
  };
}
