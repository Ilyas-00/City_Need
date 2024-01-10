import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import '../data/constant.dart';
import '../data/shared_pref.dart';
import '../model/fcm_notif.dart';
import '../page_news_info_details.dart';
import '../page_place_detail.dart';

class PushNotification {

  static const int MAX_RETRY = 5;
  int retryCount = 0;
  static const String CHANNEL_ID_NAME = "Default";
  static Random random = new Random();

  BuildContext? context;
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  PushNotification.init(){
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('app_icon');
    var iOS = new IOSInitializationSettings();
    var initSettings = new InitializationSettings(android: android, iOS: iOS);
    flutterLocalNotificationsPlugin.initialize(initSettings, onSelectNotification: _onSelectNotification);
  }

  Future _onSelectNotification(String? payload) async {
    FcmNotif notif = getNotifObject(payload!)!;
    if (notif.place != null) {
      Get.to(() => PagePlaceDetails(notif.place));
    } else if (notif.news != null) {
      Get.to(() => PageNewsInfoDetails(notif.news));
    }
  }

  void prepareAndShowNotification(FcmNotif? notif) async{

    if(!await SharedPref.getNotification()) return;
    retryCount = 0;

    String url = "";
    if (notif!.place != null) {
      url = Constant.getURLimgPlace(notif.place!.image);
    } else if (notif.news != null) {
      url = Constant.getURLimgNews(notif.news!.image!);
    }
    debugPrint("image url : $url");
    if (url.isNotEmpty) {
      downloadAndSaveFile(url, 'bigPicture').then((bitmap) {
        showNotification(notif, bitmap);
      }).catchError((error){
        debugPrint("catchError : $error");
        showNotification(notif, null);
      });
    } else {
      showNotification(notif, null);
    }
  }

  showNotification(FcmNotif? notif, String? bitmap) async {
    if(notif == null) return;
    bool vibrate = await SharedPref.getVibration();
    var android = new AndroidNotificationDetails(
      CHANNEL_ID_NAME, CHANNEL_ID_NAME,
      priority: Priority.high, importance: Importance.max,
      enableVibration: vibrate, styleInformation: BigTextStyleInformation(notif.content!, htmlFormatBigText: true)
    );

    var iOS = new IOSNotificationDetails();
    if(bitmap != null){
      android = new AndroidNotificationDetails(
          CHANNEL_ID_NAME, CHANNEL_ID_NAME,
          priority: Priority.high, importance: Importance.max,
          enableVibration: false,
          styleInformation: BigPictureStyleInformation(
              FilePathAndroidBitmap(bitmap),
              largeIcon: DrawableResourceAndroidBitmap('app_icon'),
              summaryText: notif.content, htmlFormatSummaryText: true
          )
      );
      iOS = new IOSNotificationDetails(
          attachments: <IOSNotificationAttachment>[
            IOSNotificationAttachment(bitmap)
          ]
      );
    }
    var platform = new NotificationDetails(android: android, iOS: iOS);
    await flutterLocalNotificationsPlugin.show(
      random.nextInt(1000), notif.title, notif.content,
      platform, payload: getNotifJson(notif)
    );
  }

  FcmNotif? getNotifObject(String json){
    try {
      Map<String, dynamic> map = jsonDecode(json);
      FcmNotif notif = FcmNotif.fromJson(map);
      return notif;
    } catch (error) {
      return null;
    }
  }

  String getNotifJson(FcmNotif obj){
    String json = jsonEncode(obj);
    return json;
  }

  Future<String> downloadAndSaveFile(String url, String fileName) async {
    Directory directory = await getApplicationDocumentsDirectory();
    String filePath = '${directory.path}/$fileName';
    http.Response response = await http.get(Uri.parse(url));
    File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

}