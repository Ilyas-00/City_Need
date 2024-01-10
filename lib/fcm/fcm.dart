import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'push_notification.dart';
import '../data/app_config.dart';
import '../model/news_info.dart';
import '../model/place.dart';
import '../utils/tools.dart';
import '../data/shared_pref.dart';
import '../model/fcm_notif.dart';

class Fcm {

  bool? appActive;

  String token = '';
  static const String TOPIC = 'ALL-DEVICE';
  bool isSubscribed = false;
  late PushNotification notif;

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    debugPrint('fcm : BackgroundHandler');
    await Firebase.initializeApp();
    FcmNotif? n = getNotifModel(message);
    PushNotification.init().prepareAndShowNotification(n);
    onReceiveNotification();
  }

  Fcm.configure(BuildContext context){
    configureInBackground(context);
  }

  Future configureInBackground(BuildContext context) async {
    await Firebase.initializeApp();
    notif = PushNotification.init();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      onReceiveMessage(message);
      onReceiveNotification();
    });

    // Set the background messaging handler early on, as a named top-level function
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    //Update the iOS foreground notification presentation options to allow heads up notifications.
    FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true,
    );

    subscribe();
  }

  static void onReceiveNotification() {
    SharedPref.setRefreshPlaces(true);
    if (AppConfig.REFRESH_IMG_NOTIF) {
      Tools.clearImageCacheOnBackground();
    }
  }

  Future<String?> getToken() async {
    return await FirebaseMessaging.instance.getToken();
  }

  void onReceiveMessage(RemoteMessage message) async {
    debugPrint('fcm : onReceiveMessage');
    try {
      FcmNotif? n = getNotifModel(message);
      notif.prepareAndShowNotification(n);
    } catch (error) {
      debugPrint("onMessage : error: $error");
    }
  }

  void subscribe(){
    FirebaseMessaging.instance.subscribeToTopic(TOPIC);
  }

}

FcmNotif? getNotifModel(RemoteMessage message){
  FcmNotif? fcmNotif;
  try {
    if(message.data.isNotEmpty){
      Map<String, dynamic> data = message.data;
      fcmNotif = FcmNotif(data['title'], data['content']);
      fcmNotif.type = data['type'];

      // load data place if exist
      fcmNotif.place = null;
      if(data['place'] != null){
        fcmNotif.place = Place.fromJson(jsonDecode(data['place']));
      }

      // load data news_info if exist
      fcmNotif.news = null;
      if(data['news'] != null){
        fcmNotif.news = NewsInfo.fromJson(jsonDecode(data['news']));
      }
    } else if(message.notification != null){
      RemoteNotification notification = message.notification!;
      fcmNotif = FcmNotif(notification.title, notification.body);
    }

    return fcmNotif;
  } catch(error){
    debugPrint("getNotifModel : error: $error");
    return null;
  }
}