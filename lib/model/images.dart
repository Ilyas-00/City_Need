class Images {

  int? placeId;
  String? name;

  Images.fromJson(Map<String, dynamic> json) {
    this.placeId = json['place_id'];
    this.name = json['name'];
  }

  Map<String, dynamic> toJson() => {
    'place_id': placeId,
    'name': name,
  };
}
