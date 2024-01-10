import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'data/dimens.dart';
import 'data/img.dart';
import 'data/my_strings.dart';
import 'data/my_colors.dart';
import 'dart:async';
import 'main.dart';
import 'page_main.dart';
import 'widget/my_text.dart';


class PageSplash extends StatefulWidget {

  @override
  PageSplashState createState() => PageSplashState();
}

class PageSplashState extends State<PageSplash> {

  int retryPermission = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestLocationPermission(false);
    });
  }

  @override
  Widget build(context) {
    return Scaffold(
      backgroundColor: MyColors().primaryTheme,
      body: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(MyStrings.splash_welcome_text, style: MyText.display1(context)!.copyWith(
                    color: MyColors.white
                )),
                Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.all(Dimens.spacing_mlarge),
                  width: Dimens.text_desc_width, height: Dimens.text_desc_width,
                  child: Image.asset(Img.get('splash_icon_.png')),
                ),
                Container(height: 15),
                Container(
                  width: Dimens.text_desc_width,
                  child: Text(MyStrings.splash_desc_text, textAlign : TextAlign.center, style: MyText.body1(context)!.copyWith(
                      color: MyColors.white
                  )),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              margin: const EdgeInsets.all(Dimens.spacing_mxlarge),
              child: const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(MyColors.accent),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future requestLocationPermission(bool retry) async {
    retryPermission++;
    try{
      Location location = new Location();
      PermissionStatus status = await location.hasPermission();
      if (status == PermissionStatus.denied && !retry) {
        await location.requestPermission();
        requestLocationPermission(true);
        return;
      } else if(status == PermissionStatus.granted){
        await MyApp.thisApp.initLocation();
      }
      startPageMainDelay();
    } catch (error) {
      print('requestLocationPermission : $error');
      if(retryPermission < 10) {
        requestLocationPermission(false);
      } else {
        startPageMainDelay();
      }
    }
  }

  void startPageMainDelay() {
    Future.delayed(const Duration(milliseconds: 1500), () {
      Get.off(() => PageMain());
    });
  }

}
