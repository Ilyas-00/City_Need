import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'adapter/adapter_news_info.dart';
import 'connection/callbacks/resp_news_info.dart';
import 'data/database_handler.dart';
import 'data/my_strings.dart';
import 'data/constant.dart';
import 'connection/rest_api.dart';
import 'data/my_colors.dart';
import 'model/news_info.dart';
import 'page_news_info_details.dart';
import 'utils/tools.dart';
import 'widget/no_item.dart';

class PageNewsInfo extends StatefulWidget {

  PageNewsInfo();

  @override
  PageNewsInfoState createState() => new PageNewsInfoState();
}

class PageNewsInfoState extends State<PageNewsInfo> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  ScrollController scrollController = new ScrollController();
  late AdapterNewsInfo adapterNewsInfo;
  DatabaseHandler db = DatabaseHandler.instance;

  int? itemTotal = 0, failedPage = 0;
  var noItem = false.obs, onProcess = true.obs;
  bool onReachBottom = false;

  // can be, ONLINE or OFFLINE
  bool offlineMode = false;

  void onItemClick(int index, NewsInfo obj) {
    Get.to(() => PageNewsInfoDetails(obj));
  }

  @override
  void initState() {
    super.initState();
    adapterNewsInfo = AdapterNewsInfo([], onItemClick, scrollController);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // if already have data news at db, use mode OFFLINE
      db.getNewsInfoSize().then((value) {
        offlineMode = value! > 0;
        requestAction(1);
      });
      startLoadMoreAdapter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey, backgroundColor: MyColors.grey_bg,
      appBar: AppBar(
        backgroundColor: MyColors().primaryTheme, systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark
        ), titleSpacing: 0,
        title: Text(MyStrings.title_nav_news, style: TextStyle(color: Colors.white)),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              showFailedView(false, "");
              offlineMode = false;
              itemTotal = 0;
              requestAction(1);
            },
          ),
          PopupMenuButton<String>(
            onSelected: (String value){

            },
            itemBuilder: (context) => [
              PopupMenuItem(value: MyStrings.action_settings, child: Text(MyStrings.action_settings)),
              PopupMenuItem(value: MyStrings.pref_title_more, child: Text(MyStrings.pref_title_more)),
              PopupMenuItem(value: MyStrings.pref_title_rate, child: Text(MyStrings.pref_title_rate)),
              PopupMenuItem(value: MyStrings.pref_title_about, child: Text(MyStrings.pref_title_about)),
            ],
          )
        ],
      ),
      body: Builder(builder: (BuildContext context){
        return Obx((){
          if(onProcess.isFalse){
            if(noItem.value){
              return NoItem();
            } else {
              return adapterNewsInfo.getView();
            }
          } else {
            return Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator(),
            );
          }
        });
      }),
    );
  }

  void startLoadMoreAdapter() {
    adapterNewsInfo.resetListData();
    scrollController.addListener(() {
      int itemCount = adapterNewsInfo.getItemCount();
      if(itemCount <= 0 || (itemTotal! > 0 && itemCount == itemTotal)) {
        adapterNewsInfo.setLoaded();
        return;
      }
      // when scroll reach bottom
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100
          && !scrollController.position.outOfRange) {
        if(onReachBottom) return;
        onReachBottom = true;
        int page = (itemCount / Constant.LIMIT_NEWS_REQUEST).ceil();
        if(page == 0) return;
        requestAction(page + 1);
      }
    });
  }

  void requestAction(final int? pageNo){
    showFailedView(false, "");
    noItem.value = false;
    if (pageNo == 1) {
      onProcess.value = true;
    } else {
      adapterNewsInfo.setLoading();
    }
    Future.delayed(Duration(milliseconds: offlineMode ? 50 : 500), () {
      requestListNewsInfo(pageNo);
    });
  }

  void requestListNewsInfo(int? pageNo){
    if(!offlineMode){ // online
      RespNewsInfo? value;
      RestAPI().getNewsInfoByPage(pageNo, Constant.LIMIT_NEWS_REQUEST).then((_value) {
        value = _value;
      }).whenComplete(() {
        adapterNewsInfo.setLoaded();
        if (value != null && value!.status == "success" && value!.newsInfos != null) {
          if (pageNo == 1) {
            adapterNewsInfo.resetListData();
            db.refreshTableNewsInfo();
          }
          itemTotal = value!.countTotal;
          db.insertListNewsInfo(value!.newsInfos!);
          displayApiResult(value!.newsInfos!);
        } else {
          onFailRequest(pageNo);
        }
      });
    } else {
      if (pageNo == 1) adapterNewsInfo.resetListData();
      int limit = Constant.LIMIT_NEWS_REQUEST;
      int offset = (pageNo! * limit) - limit;
      db.getNewsInfoSize().then((_itemTotal) {
        itemTotal = _itemTotal;
        db.getNewsInfoByPage(limit, offset).then((value) => displayApiResult(value));
      });
    }
  }

  void displayApiResult(List<NewsInfo> items) {
    adapterNewsInfo.insertData(items);
    onReachBottom = false;
    refreshList();
    if (adapterNewsInfo.getItemCount() == 0) {
      noItem.value = true;
    }
  }

  void refreshList(){
    onProcess.value = true;
    onProcess.value = false;
  }

  void onFailRequest(int? pageNo) async {
    failedPage = pageNo;
    adapterNewsInfo.setLoaded();
    onProcess.value = true;
    bool conn = await Tools.checkConnection(context);
    if (conn) {
      showFailedView(true, MyStrings.refresh_failed);
    } else {
      showFailedView(true, MyStrings.no_internet);
    }
  }

  void  showFailedView(bool show, String message){
    if(!show) return;
    showDialog(barrierDismissible: true, context: context, builder: (BuildContext context){
      return AlertDialog(content: Text(message),
        contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        actions: [
          TextButton(child: Text(MyStrings.RETRY), onPressed: () {
            Navigator.of(context).pop();
            requestAction(failedPage);
          })
        ],
      );
    });
  }
}

