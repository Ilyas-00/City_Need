import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'page_splash.dart';
import 'data/my_colors.dart';
import 'this_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  static late ThisApp thisApp;

  MyApp() {
    thisApp = new ThisApp();
  }

  @override
  Widget build(BuildContext context) {
    MyApp.thisApp.initFirebase(context);
    return GetMaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primaryColor: MyColors.primary,
          primaryColorDark: MyColors.primaryDark,
          primaryColorLight: MyColors.primaryLight,
          bottomSheetTheme: BottomSheetThemeData(
              backgroundColor: Colors.transparent
          ),
        ),
        home: PageSplash()
    );
  }

}
