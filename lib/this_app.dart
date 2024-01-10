import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'connection/rest_api.dart';
import 'data/database_handler.dart';
import 'data/shared_pref.dart';
import 'utils/theme_listener.dart';
import 'fcm/fcm.dart';
import 'model/device_info.dart';
import 'utils/tools.dart';

class ThisApp {

  Fcm? fcm;
  int fcmCount = 0;
  static const int FCM_MAX_COUNT = 10;

  bool locationLoaded = false;
  Location location = new Location();
  late LocationData locationData;
  ThemeListener themeListener = new ThemeListener();

  ThisApp(){
    initDatabase();
  }

  Future initLocation() async {
    try {
      bool serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) return;
      }
      await location.getLocation().then((value){
        locationData = value;
        locationLoaded = true;
        return;
      }).onError((dynamic error, stackTrace) {
        throw(error);
      }).timeout(Duration(seconds: 2));
    } catch (error) {
      print('initLocation : $error');
      return;
    }
  }

  void reInitLocation() async {
    try {
      PermissionStatus status = await location.hasPermission();
      if(status == PermissionStatus.denied || status == PermissionStatus.deniedForever){
        return;
      }
      bool serviceEnabled = await location.serviceEnabled();
      if(serviceEnabled){
        await location.getLocation().then((value){
          locationData = value;
          locationLoaded = true;
          return;
        });
      }
    }  catch (error) {
      print('reInitLocation : $error');
      return;
    }
  }

  void initFirebase(BuildContext context) async {
    // initialize FCM
    Firebase.initializeApp().then((value) {
      if(fcm == null) fcm = Fcm.configure(context);
      obtainFirebaseToken();
    });
  }

  void obtainFirebaseToken(){
    fcmCount++;
    fcm!.getToken().then((token) {
      if(token == '') {
        if (fcmCount > FCM_MAX_COUNT) return;
        Future.delayed(Duration(seconds: 1)).then((value) {
          obtainFirebaseToken();
        });
        return;
      }
      SharedPref.setFcmRegId(token!);
      sendRegistrationToServer(token);
    });
  }

  void sendRegistrationToServer(String token) async {
    print("FCM_TOKEN : "+ token);
    DeviceInfo deviceInfo = await Tools.getDeviceInfo();
    deviceInfo.regid = token;
    RestAPI().registerDevice(deviceInfo).then((resp) {
      if (resp.status!.toLowerCase() == "success") {
        print("Success : sendRegistrationToServer");
      }
    }).catchError((error){
      print("Error : sendRegistrationToServer");
    });
  }

  Future initDatabase() {
    return DatabaseHandler.instance.database;
  }

}