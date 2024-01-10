import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as image;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:package_info/package_info.dart';
import 'package:share/share.dart';
import '../data/img.dart';
import '../model/news_info.dart';
import 'package:url_launcher/url_launcher.dart';
import 'network_check.dart';
import '../data/app_config.dart';
import '../data/my_colors.dart';
import '../data/my_strings.dart';
import '../main.dart';
import '../model/place.dart';
import '../model/device_info.dart';
import '../data/dimens.dart';

class Tools {

  static DefaultCacheManager defaultCacheManager = new DefaultCacheManager();

  static void setStatusBarColor(Color color) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: color));
  }

  static int getGridSpanCount(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    int widthCard = Dimens.item_place_width;
    int countRow = width~/widthCard;
    return countRow;
  }

  static Future<bool> checkConnection(BuildContext context) async{
    return await NetworkCheck.isConnect();
  }

  static Widget displayImage(String url) {
    return AppConfig.IMAGE_CACHE ? CachedNetworkImage(
      cacheManager: defaultCacheManager,
      imageUrl: url, fit: BoxFit.cover,
    ) : Image.network(url, fit: BoxFit.cover);
  }

  static Future<DeviceInfo> getDeviceInfo() async {
    DeviceInfo device = DeviceInfo();
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo build = await deviceInfo.iosInfo;
      device.device = build.name + ' ' +build.model;
      device.email = build.identifierForVendor + " F" ;
      device.version = build.systemVersion ;
    } else {
      AndroidDeviceInfo build = await deviceInfo.androidInfo;
      device.device = build.manufacturer + ' ' +build.model;
      device.email = build.androidId + "-F" ;
      device.version = build.version.release;
    }
    device.dateCreate = DateTime.now().millisecondsSinceEpoch;
    return device;
  }

  Future<String> getAppName() async {
    var package = await PackageInfo.fromPlatform();
    return package.appName;
  }

  static List<Place>? itemsWithDistance(List<Place>? items) {
    if (AppConfig.SORT_BY_DISTANCE) { // checking for distance sorting
      LatLng? curLoc = Tools.getCurLocation();
      if (curLoc != null) {
        return getDistanceList(items!, curLoc);
      }
    }
    return items;
  }

  static List<Place> getDistanceList(List<Place> places, LatLng curLoc) {
    if (places.length > 0) {
      for (Place p in places) {
        p.distance = calculateDistance(curLoc, p.getPosition());
      }
    }
    return places;
  }

  static LatLng? getCurLocation() {
    if(!MyApp.thisApp.locationLoaded){
      return null;
    }
    LocationData locationData = MyApp.thisApp.locationData;
    return LatLng(locationData.latitude!, locationData.longitude!);

  }

  static double calculateDistance(LatLng from, LatLng to) {
    var earthRadius = 6378137.0;
    var dLat = _toRadians(to.latitude - from.latitude);
    var dLon = _toRadians(to.longitude - from.longitude);

    num a = pow(sin(dLat / 2), 2) +
        pow(sin(dLon / 2), 2) *
            cos(_toRadians(from.latitude)) *
            cos(_toRadians(to.latitude));
    var c = 2 * asin(sqrt(a));

    double distanceInMeters =  earthRadius * c;
    double resultDist = 0;
    if (AppConfig.DISTANCE_METRIC_CODE == "KILOMETER") {
      resultDist = distanceInMeters / 1000;
    } else {
      resultDist = distanceInMeters;
    }
    return resultDist.abs();
  }

  static _toRadians(double degree) {
    const double pi = 3.1415926535897932;
    return degree * pi / 180;
  }

  static String getFormattedDistance(double distance) {
    return distance.toStringAsFixed(1) + " " + AppConfig.DISTANCE_METRIC_STR;
  }

  static String getFormattedDate(int time) {
    DateFormat newFormat = new DateFormat("MMMM dd, yyyy hh:mm");
    return newFormat.format(new DateTime.fromMillisecondsSinceEpoch(time));
  }

  static void clearImageCacheOnBackground() async{
    defaultCacheManager.emptyCache();
  }

  static void directLinkToBrowser(String url) async {
    if( !url.substring(0, 5).contains('http') ) {
      url = 'http://' + url;
    }

    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not open $url');
    }
  }

  static void openDialPhone(String url) async {
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not open $url');
    }
  }

  static void rateAction() async {
    String url = getStoreUrl();
    Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      print('Could not launch $url');
    }
  }

  static String getStoreUrl(){
    String url = MyStrings.RATE_URL_ANDROID;
    if (Platform.isIOS) {
      url = MyStrings.RATE_URL_IOS;
    }
    return url;
  }

  static Future<ui.Image> loadUiImage(String imageAssetPath, int size, Color color) async {
    final ByteData assetImageByteData = await rootBundle.load(imageAssetPath);
    image.Image baseSizeImage = image.decodeImage(assetImageByteData.buffer.asUint8List())!;
    image.Image newImage = image.colorOffset(
      image.copyResize(baseSizeImage, height: size, width: size),
      green: color.green, red: color.red, blue: color.blue
    );
    ui.Codec codec = await ui.instantiateImageCodec(image.encodePng(newImage) as Uint8List);
    ui.FrameInfo frameInfo = await codec.getNextFrame();
    return frameInfo.image;
  }

  static Future<Uint8List> getBytesFromAsset(Color color, IconData icon) async {
    int size = 70;
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    canvas.drawImage(
        await loadUiImage(Img.get('ic_marker.png'), size, color), Offset(0, 0), Paint()
    );

    TextPainter textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(fontSize: 32.0, fontFamily: icon.fontFamily, color: MyColors.white)
    );
    textPainter.layout();
    textPainter.paint(canvas,new Offset((size / 2 - textPainter.width / 2) + 0.5, 10));

    // convert to image
    final img = await pictureRecorder.endRecording().toImage(size, size);
    final data = (await img.toByteData(format: ui.ImageByteFormat.png))!;
    return data.buffer.asUint8List();
  }

  static void aboutAction(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(MyStrings.dialog_about_title),
          content: const Text(MyStrings.about_text),
          actions: [
            TextButton(
              child: Text('OK', style: TextStyle(color: MyColors.accent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  static void methodShare(Place p) async {
    // string to share
    String shareBody = "View good place '" + p.name + "'"
        + "\n" + "located at : " + p.address + "\n\n"
        + "Using app : " + getStoreUrl();
    Share.share(shareBody);
  }

  static void methodShareNews(NewsInfo n) {
    // string to share
    String shareBody = n.title! + "\n\n" + getStoreUrl();
    Share.share(shareBody);
  }

  static void addThemeListener(Function callback) {
    MyApp.thisApp.themeListener.addListener(callback as void Function());
  }

  static void updateTheme(int index) {
    MyApp.thisApp.themeListener.changeColor(index);
  }

}