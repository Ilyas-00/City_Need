import 'package:flutter/material.dart';
import 'package:the_city_flutter/data/app_config.dart';
import '../data/my_colors.dart';
import '../data/shared_pref.dart';

class ThemeListener with ChangeNotifier {

  static int colorIndex = 0;

  ThemeListener() {
    SharedPref.getThemeIndex().then((value) => colorIndex = value);
  }

  Color currentColor(){
    if(!AppConfig.THEME_COLOR) return MyColors.primary;
    return MyColors.themeColors[colorIndex].values.first;
  }

  void changeColor(int index) async {
    SharedPref.setThemeIndex(index);
    colorIndex = index;
    notifyListeners();
  }
}