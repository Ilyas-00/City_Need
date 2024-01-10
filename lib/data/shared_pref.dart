
import 'package:shared_preferences/shared_preferences.dart';

import 'my_strings.dart';

class SharedPref {

  static Future<void> setLastPlacePage(int page) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt("LAST_PLACE_PAGE", page);
  }

  static Future<int> getLastPlacePage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt("LAST_PLACE_PAGE") ?? 1;
  }

  static Future<void> setRefreshPlaces(bool flag) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("REFRESH_PLACES", flag);
  }

  static Future<bool> isRefreshPlaces() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool("REFRESH_PLACES") ?? true;
  }

  static setFcmRegId(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("FCM_REG_ID", value);
  }

  static Future<String?> getFcmRegId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString("FCM_REG_ID") ?? null;
  }

  /* For notifications flag */
  static Future<bool> getNotification() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(MyStrings.pref_title_notif) ?? true;
  }

  static setNotification(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(MyStrings.pref_title_notif, value);
  }

  static Future<String> getRingtone() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(MyStrings.pref_title_ringtone) ?? "content://settings/system/notification_sound";
  }

  static setRingtone(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(MyStrings.pref_title_ringtone, value);
  }

  static Future<bool> getVibration() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(MyStrings.pref_title_vibrate) ?? true;
  }

  static setVibration(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(MyStrings.pref_title_vibrate, value);
  }

  static Future<int> getThemeIndex() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(MyStrings.pref_key_theme) ?? 0;
  }

  static setThemeIndex(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(MyStrings.pref_key_theme, value);
  }

}