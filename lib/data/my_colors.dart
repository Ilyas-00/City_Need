import 'package:flutter/material.dart';

import '../main.dart';

class MyColors {

  Color primaryTheme = MyApp.thisApp.themeListener.currentColor();

  static const Color primary = Color(0xFF568AB7);
  static const Color primaryDark = Color(0xFF4576a1);
  static const Color primaryLight = Color(0xFF709cc2);
  static const Color accent = Color(0xFFE6C14D);
  static const Color accentDark = Color(0xFFC4A035);
  static const Color accentLight = Color(0xFFFEEAAB);

  static const Color black = Color(0xFF000000);
  static const Color white = Color(0xFFFFFFFF);

  static const Color grey_hard = Color(0xFF96989A);
  static const Color grey_medium = Color(0xFFBDBFC1);
  static const Color grey_soft = Color(0xFFF5F5F5);
  static const Color grey_mdark = Color(0xFF424242);
  static const Color grey_dark = Color(0xFF332C2B);

  static const Color grey_bg = Color(0xFFE6E6E6);
  static const Color icon_drawer_color = Color(0xFF727272);
  static const Color drawer_header_bg = Color(0xFF568AB7);

  static const Color marker_primary = Color(0xFF1F59A6);
  static const Color marker_secondary = Color(0xFFEE792A);

  static const Color dark_overlay = Color(0xFF73000000);
  static const Color dark_soft_overlay = Color(0xFF33000000);
  static const Color grid_title_bg = Color(0xFFFFFFFF);

  static List<Map<String, Color>> themeColors = [
    {'Default' : primary},
    {'Red' : Color(0xFFF44336)},
    {'Pink' : Color(0xFFEC407A)},
    {'Purple' : Color(0xFF9C27B0)},
    {'Deep Purple' : Color(0xFF673AB7)},

    {'Indigo' : Color(0xFF3F51B5)},
    {'Blue' : Color(0xFF2196F3)},
    {'Light Blue' : Color(0xFF03A9F4)},
    {'Cyan' : Color(0xFF00BCD4)},
    {'Teal' : Color(0xFF009688)},

    {'Green' : Color(0xFF4CAF50)},
    {'Orange' : Color(0xFFFF9800)},
    {'Deep Orange' : Color(0xFFFF5722)},
    {'Brown' : Color(0xFF795548)},
    {'Blue Grey' : Color(0xFF607D8B)}
  ];

}