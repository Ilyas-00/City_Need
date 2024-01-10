import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'data/app_config.dart';
import 'data/shared_pref.dart';
import 'utils/tools.dart';
import 'widget/my_text.dart';
import 'data/my_strings.dart';
import 'data/my_colors.dart';

class PageSetting extends StatefulWidget {

  PageSetting();

  @override
  PageSettingState createState() => new PageSettingState();
}

class PageSettingState extends State<PageSetting> {

  late BuildContext context;
  late BuildContext _scaffoldCtx;
  List<Map<String, Color>> themeColors = MyColors.themeColors;

  bool? notification = false, vibrate = false;
  String sound = "";

  @override
  void initState() {
    super.initState();
    SharedPref.getNotification().then((value) => setState(() => notification = value));
    SharedPref.getVibration().then((value) => setState(() => vibrate = value));
    SharedPref.getRingtone().then((value) => setState(() => sound = value));
    Tools.addThemeListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;

    return Scaffold(
      backgroundColor: MyColors.white,
      appBar: AppBar(
        backgroundColor: MyColors().primaryTheme, systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark
        ),
        titleSpacing: 0,
        title: Text(MyStrings.activity_title_settings, style: TextStyle(color: Colors.white)),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)
        ),
      ),
      body: Builder(builder: (BuildContext context){
        _scaffoldCtx = context;
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(height: 15),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Text(MyStrings.pref_category_notif, style: MyText.body1(context)!.copyWith(color: MyColors.accent))
              ),
              SwitchListTile(
                contentPadding : EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                value: notification!,
                title: Text(MyStrings.pref_title_notif),
                onChanged: (value) {
                  notification = value;
                  SharedPref.setNotification(notification!);
                  setState(() {});
                },
              ),
              CheckboxListTile(
                value: vibrate,
                title: Text(MyStrings.pref_title_vibrate),
                onChanged: notification! ? (value) {
                  vibrate = value;
                  SharedPref.setVibration(vibrate!);
                  setState(() {});
                } : null,
              ),

              Container(child: Divider(height: 0), padding: EdgeInsets.symmetric(horizontal: 15)),
              Container(height: 15),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 15,),
                  child: Text(MyStrings.pref_category_display, style: MyText.body1(context)!.copyWith(color: MyColors.accent))
              ),
              ListTile(
                contentPadding : EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                title: Text(MyStrings.pref_title_cache),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(MyStrings.dialog_confirm_title),
                        content: const Text(MyStrings.message_clear_image_cache),
                        actions: <Widget>[
                          TextButton(
                            child: const Text(MyStrings.CANCEL, style: TextStyle(color: MyColors.accent)),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          TextButton(
                            child: const Text('OK', style: TextStyle(color: MyColors.accent)),
                            onPressed: () {
                              Navigator.of(context).pop();
                              Tools.clearImageCacheOnBackground();
                              ScaffoldMessenger.of(_scaffoldCtx).showSnackBar(
                                  SnackBar(content: Text(MyStrings.message_after_clear_image_cache), duration: Duration(seconds: 1))
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              AppConfig.THEME_COLOR ? ListTile(
                contentPadding : EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                title: Text(MyStrings.pref_title_theme),
                onTap: () => dialogTheme(context),
              ) : Container(),
              Container(child: Divider(height: 0), padding: EdgeInsets.symmetric(horizontal: 15)),
              Container(height: 15),
              Container(
                  padding: EdgeInsets.symmetric(horizontal: 15,),
                  child: Text(MyStrings.pref_category_other, style: MyText.body1(context)!.copyWith(color: MyColors.accent))
              ),
              ListTile(
                contentPadding : EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                title: Text(MyStrings.pref_title_dev_name),
                subtitle: Text(MyStrings.developer_name),
                onTap: () {},
              ),
              ListTile(
                contentPadding : EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                title: Text(MyStrings.pref_title_copyright),
                subtitle: Text(MyStrings.copyright),
                onTap: () => Tools.directLinkToBrowser(MyStrings.privacy_policy_url),
              ),
              ListTile(
                contentPadding : EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                title: Text(MyStrings.pref_title_term),
                onTap: () => dialogTerm(context),
              ),
              ListTile(
                contentPadding : EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                title: Text(MyStrings.pref_title_more),
                onTap: () => Tools.directLinkToBrowser(MyStrings.more_app_url),
              ),
              ListTile(
                contentPadding : EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                title: Text(MyStrings.pref_title_rate),
                onTap: () => Tools.rateAction(),
              ),
              ListTile(
                contentPadding : EdgeInsets.symmetric(horizontal: 15, vertical: 0),
                title: Text(MyStrings.pref_title_about),
                onTap: () => Tools.aboutAction(context),
              ),
            ],
          ),
        );
      }),
    );
  }

  void dialogTheme(BuildContext context){
    AlertDialog alert = AlertDialog(
      title : Text(MyStrings.pref_title_theme),
      contentPadding: EdgeInsets.all(0),
      titlePadding: EdgeInsets.all(15),
      content: Container(
        height: 300, width: 250,
        child: ListView.builder(
          itemCount: themeColors.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: EdgeInsets.only(bottom: 1),
              color: themeColors[index].values.first,
              child: ListTile(
                title: Text(themeColors[index].keys.first, style: TextStyle(color: MyColors.white)),
                onTap: () {
                  Tools.updateTheme(index);
                  Navigator.of(context).pop();
                },
              ),
            );
          },
        ),
      ),
    );
    showDialog(barrierDismissible: true, context:context, builder:(BuildContext context){
      return alert;
    });
  }

  void dialogTerm(BuildContext context){
    AlertDialog alert = AlertDialog(
      title : Text(MyStrings.pref_title_term),
      content: SingleChildScrollView(
        padding: EdgeInsets.only(left: 25, right: 25, top: 15),
        child: Text(MyStrings.content_term),
      ),
      contentPadding: EdgeInsets.all(0),
      actions: [
        TextButton(child: Text(MyStrings.OK), onPressed: () => Navigator.of(context).pop())
      ],
    );
    showDialog(barrierDismissible: true, context:context, builder:(BuildContext context){
      return alert;
    });
  }

}