import 'package:flutter/material.dart';

class Category {
  int? catId;
  String? name;
  IconData? iconData;
  int? icon;

  Category(this.catId, this.name, this.iconData);

  Category.fromJson(Map<String, dynamic> json) {
    this.catId = json['cat_id'];
    this.name = json['name'];
    if(json['icon'] != null){
      this.icon = json['icon'];
      this.iconData = IconData(this.icon!, fontFamily: 'MaterialIcons');
    }
  }

  Map<String, dynamic> toJson() => {
    'cat_id': catId,
    'name': name,
    'icon': iconData != null ? iconData!.codePoint : null,
  };
}
