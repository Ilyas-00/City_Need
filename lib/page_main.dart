import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:sprintf/sprintf.dart';
import 'page_news_info.dart';
import 'connection/callbacks/resp_list_place.dart';
import 'data/array.dart';
import 'data/database_handler.dart';
import 'data/dimens.dart';
import 'data/my_strings.dart';
import 'data/shared_pref.dart';
import 'main.dart';
import 'model/category.dart';
import 'model/place.dart';
import 'adapter/adapter_place_grid.dart';
import 'connection/rest_api.dart';
import 'data/app_config.dart';
import 'data/constant.dart';
import 'data/img.dart';
import 'data/my_colors.dart';
import 'page_maps.dart';
import 'page_place_detail.dart';
import 'page_search.dart';
import 'page_setting.dart';
import 'utils/admob.dart';
import 'utils/tools.dart';
import 'widget/my_text.dart';
import 'widget/no_item.dart';

class PageMain extends StatefulWidget {

  @override
  PageMainState createState() => PageMainState();
}

class PageMainState extends State<PageMain> with TickerProviderStateMixin{

  late BuildContext _scaffoldCtx;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  Category currentCategory = Array.headerCategories[0];
  DatabaseHandler db = DatabaseHandler.instance;

  InterstitialAd? interstitialAd;
  BannerAd? bannerAd;
  var onBannerLoaded = false.obs;
  bool isInterstitialLoaded = false;

  late AnimationController animationController;
  late Animation animation;
  ScrollController scrollController = new ScrollController();
  late AdapterPlaceGrid adapterPlaceGrid;

  // observable variable
  var onProcess = false.obs, showText = false.obs;
  var showNoItem = false.obs;
  var loadText = "".obs, toolbarTitle = "".obs;
  var favCount = 0.obs;

  bool loading = false, success = true;
  int? countTotal = 0, itemTotal = 0;
  bool onReachBottom = false, scrolledDown = false;

  void initAction() async {
    bool isRefresh = await SharedPref.isRefreshPlaces();
    int? placeSize = await db.getAllPlacesSize();
    if (isRefresh || placeSize == 0) {
      actionRefresh(await SharedPref.getLastPlacePage());
    } else {
      startLoadMoreAdapter();
    }
  }

  void onDrawerItemClicked(Category category){
    if(scaffoldKey.currentState!.isDrawerOpen) Navigator.of(context).pop();
    if(category.catId == -3){
      Get.to(() => PageNewsInfo());
    } else {
      currentCategory = category;
      // for place grid
      refreshList();
      toolbarTitle.value = currentCategory.name!;
      startLoadMoreAdapter();
    }
  }

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(vsync: this, duration: Duration(milliseconds: 500));
    animation = Tween<Offset>(begin: Offset(0, 0), end: Offset(0, 2)).animate(animationController);

    toolbarTitle.value = currentCategory.name!;
    adapterPlaceGrid = AdapterPlaceGrid([], scrollController);
    adapterPlaceGrid.onItemClick = (int index, Place obj) {
      Get.to(() => PagePlaceDetails(obj));
    };

    WidgetsBinding.instance.addPostFrameCallback((_) {
      MyApp.thisApp.reInitLocation();
      initAction();
      initBannerAd();
      initInterstitialAd();
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    animationController.dispose();
    bannerAd?.dispose();
    interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget widget = Column(
      children: [
        Expanded(child: Scaffold(
          key: scaffoldKey, backgroundColor: MyColors.grey_bg,
          body: Builder(builder: (BuildContext context){
            _scaffoldCtx = context;
            return CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverAppBar(
                    systemOverlayStyle: SystemUiOverlayStyle(
                        statusBarBrightness: Brightness.dark
                    ),
                    floating: true,
                    backgroundColor: MyColors().primaryTheme,
                    forceElevated: true,
                    title: Obx(() => Text(toolbarTitle.value)),
                    leading: IconButton(icon: new Icon(Icons.menu, color: Colors.white), onPressed: handleMenuClick),
                    actions: <Widget>[
                      IconButton(
                        icon: Icon(Icons.refresh),
                        onPressed: () {
                          // ThisApplication.getInstance().setLocation(null);
                          SharedPref.setRefreshPlaces(true);
                          loadText.value = "";
                          adapterPlaceGrid.resetListData();
                          SharedPref.setLastPlacePage(1).then((value) {
                            actionRefresh(1);
                          });
                        },
                      ),
                      PopupMenuButton<String>(
                        onSelected: (String value){
                          if(value == MyStrings.action_settings){
                            Get.to(() => PageSetting());
                          } else if(value == MyStrings.pref_title_more){
                            Tools.directLinkToBrowser(MyStrings.more_app_url);
                          } else if(value == MyStrings.pref_title_rate){
                            Tools.rateAction();
                          } else if(value == MyStrings.pref_title_about){
                            Tools.aboutAction(context);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(value: MyStrings.action_settings, child: Text(MyStrings.action_settings)),
                          PopupMenuItem(value: MyStrings.pref_title_more, child: Text(MyStrings.pref_title_more)),
                          PopupMenuItem(value: MyStrings.pref_title_rate, child: Text(MyStrings.pref_title_rate)),
                          PopupMenuItem(value: MyStrings.pref_title_about, child: Text(MyStrings.pref_title_about)),
                        ],
                      )
                    ]
                ),
                Obx((){
                  if(onProcess.isFalse){
                    return showNoItem.isFalse ? adapterPlaceGrid.getSilverView(context) : SliverFillRemaining(
                        child: NoItem()
                    );
                  } else {
                    return SliverFillRemaining(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            Container(height: Dimens.spacing_mxlarge),
                            Text("$loadText", style : MyText.body1(context)!.copyWith(color: MyColors.grey_hard))
                          ],
                        )
                    );
                  }
                }),
                SliverToBoxAdapter(
                  child: Obx(() {
                    return adapterPlaceGrid.isLoading.isTrue ? Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(Dimens.spacing_mxlarge),
                            child: CircularProgressIndicator(),
                          ),
                        ]
                    ) : Container();
                  }),
                ),
              ],
            );
          }),
          drawer: Container(
            width: Dimens.drawer_menu_width,
            child: Drawer(
              child: SingleChildScrollView(
                child: Column(
                  children: generateDrawer(context),
                ),
              ),
            ),
          ),
          floatingActionButton: SlideTransition(
            position: animation as Animation<Offset>,
            child: FloatingActionButton(
              heroTag: "fabSearch", mini: false, backgroundColor: MyColors.accent,
              child: Icon(Icons.search, color: Colors.white,),
              onPressed: () {
                Get.to(() => PageSearch());
              },
            ),
          ),
        )),
        Obx(() => onBannerLoaded.value && bannerAd != null ? Container(
          height: bannerAd!.size.height.toDouble(),
          width: double.infinity,
          color: MyColors.grey_bg,
          child: AdWidget(ad: bannerAd!),
        ) : Container())
      ],
    );
    return widget;
  }

  handleMenuClick() async{
    scaffoldKey.currentState!.openDrawer();
    if(showInterstitial()) return;
    favCount.value = (await db.getFavoritesSize())!;
  }

  List<Widget> generateDrawer(BuildContext context){
    List<Widget> children = <Widget>[];

    children.add(DrawerHeaderWidget());
    children.add(Container(height: 10));
    for (Category cat in Array.headerCategories) {
      Widget w = ListTile(
        dense: true,
        title: Text(cat.name!, style: MyText.body2(context)!.copyWith(color: MyColors.grey_mdark)),
        leading: Icon(cat.iconData, color: MyColors.accentDark),
        trailing: cat.catId != -2 ? Container(width: 0) : Container(
          alignment: Alignment.center,
          width: Dimens.spacing_mxlarge, height: Dimens.spacing_mxlarge,
          decoration: BoxDecoration(color: MyColors.grey_medium, shape: BoxShape.circle,),
          child: Obx(() => Text(favCount.value.toString(), style: MyText.body2(context)!.copyWith(color: MyColors.white)))
        ),
        onTap: (){ onDrawerItemClicked(cat); },
      );
      if(cat.catId == -3 && !AppConfig.ENABLE_NEWS_INFO ) continue;
      children.add(w);
    }

    children.add(Divider());

    for (Category cat in Array.categories) {
      Widget w = ListTile(
        dense: true,
        title: Text(cat.name!, style: MyText.body2(context)!.copyWith(color: MyColors.grey_mdark)),
        leading: Icon(cat.iconData, color: MyColors.accentDark),
        onTap: (){ onDrawerItemClicked(cat); },
      );
      children.add(w);
    }

    children.add(Container(height: 10));
    return children;
  }

  // checking some condition before perform refresh data
  void actionRefresh(int pageNo) async{
    bool conn = await Tools.checkConnection(context);
    if (conn) {
      MyApp.thisApp.reInitLocation();
      if (onProcess.isFalse) {
        onRefresh(pageNo);
      } else {
        ScaffoldMessenger.of(_scaffoldCtx).showSnackBar(SnackBar(content: Text(MyStrings.task_running), duration: Duration(seconds: 1)));
      }
    } else {
      onFailureRetry(pageNo, MyStrings.no_internet);
    }
  }

  void onRefresh(int pageNo) {
    onProcess.value = true;
    RespListPlace? resp;
    RestAPI().getPlacesByPage(pageNo, Constant.LIMIT_PLACE_REQUEST, AppConfig.LAZY_LOAD ? 1 : 0).then((_value) {
      resp = _value;
    }).whenComplete(() {
      if (resp != null && resp!.status == "success" && resp!.places != null) {
        countTotal = resp!.countTotal;
        if (pageNo == 1) db.refreshTablePlace();
        db.insertListPlace(resp!.places);  // save result into database
        SharedPref.setLastPlacePage(pageNo + 1);
        delayNextRequest(pageNo);
        loadText.value = sprintf(MyStrings.load_of, [(pageNo * Constant.LIMIT_PLACE_REQUEST), countTotal]);
      } else {
        onFailureRetry(pageNo, MyStrings.refresh_failed);
      }
    });
  }

  void delayNextRequest(final int pageNo) {
    if (countTotal == 0) {
      onFailureRetry(pageNo, MyStrings.refresh_failed);
      return;
    }
    if ((pageNo * Constant.LIMIT_PLACE_REQUEST) > countTotal!) { // when all data loaded
      onProcess.value = false;
      loadText.value = "";
      startLoadMoreAdapter();
      SharedPref.setRefreshPlaces(false);
      ScaffoldMessenger.of(_scaffoldCtx).showSnackBar(SnackBar(content: Text(MyStrings.load_success), duration: Duration(seconds: 1)));
      return;
    }
    Future.delayed(const Duration(milliseconds: 800), () {
      onRefresh(pageNo + 1);
    });
  }

  void startLoadMoreAdapter() {
    adapterPlaceGrid.resetListData();
    db.getPlacesSize(currentCategory.catId).then((value) {
      itemTotal = value;
      showNoItemView();
    });
    db.getPlacesByPage(currentCategory.catId, Constant.LIMIT_LOAD_MORE, 0).then((items) {
      refreshList();
      adapterPlaceGrid.insertData(items);
    });
    scrollController.addListener(() {
      // for fab hide
      onScroll();

      int itemCount = adapterPlaceGrid.getItemCount();
      if(itemCount <= 0 || (itemTotal! > 0 && itemCount == itemTotal)) {
        adapterPlaceGrid.setLoaded();
        return;
      }

      // when scroll reach bottom
      if (scrollController.position.pixels >= scrollController.position.maxScrollExtent - 100
          && !scrollController.position.outOfRange) {
        if(onReachBottom) return;
        onReachBottom = true;
        int page = (itemCount / Constant.LIMIT_LOAD_MORE).ceil();
        if(page == 0) return;
        displayDataByPage(page);
      }
    });
  }

  void onScroll(){
    if(scrollController == null || !scrollController.hasClients) return;
    if (scrollController.position.userScrollDirection == ScrollDirection.reverse) {
      // scroll down
      if(scrolledDown) return;
      Future.delayed(Duration(milliseconds: 100)).then((value) {
        animationController.forward();
      });
      scrolledDown = true;
    } else if (scrollController.position.userScrollDirection == ScrollDirection.forward) {
      // scroll up
      if(!scrolledDown) return;
      Future.delayed(Duration(milliseconds: 100)).then((value) {
        animationController.reverse();
      });
      scrolledDown = false;
    }
  }

  void displayDataByPage(final int nextPage) {
    adapterPlaceGrid.setLoading();
    Future.delayed(const Duration(milliseconds: 100), () {
      db.getPlacesByPage(currentCategory.catId, Constant.LIMIT_LOAD_MORE, (nextPage * Constant.LIMIT_LOAD_MORE)).then((items) {
        adapterPlaceGrid.insertData(items);
        refreshList();
        onReachBottom = false;
        showNoItemView();
      });
    });
  }

  void showNoItemView() {
    showNoItem.value = itemTotal == 0;
  }

  void onFailureRetry(final int pageNo, String msg) {
    onProcess.value = false;
    showNoItemView();
    startLoadMoreAdapter();
    showDialog(barrierDismissible: true, context: context, builder: (BuildContext context){
      return AlertDialog(content: Text(msg),
        contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        actions: [
          TextButton(child: Text(MyStrings.RETRY), onPressed: () {
            Navigator.of(context).pop();
            actionRefresh(pageNo);
          })
        ],
      );
    });
  }

  void refreshList(){
    onProcess.value = true;
    onProcess.value = false;
  }

  void initBannerAd(){
    if(!AppConfig.ADS_MAIN_BANNER) return;
    if(onBannerLoaded.value || bannerAd != null) return;
    bannerAd = AdMob.createBannerAd(new AdListener(
        onBannerAdLoaded: () => onBannerLoaded.value = true,
    ));
    bannerAd!.load();
  }

  void initInterstitialAd(){
    if(!AppConfig.ADS_MAIN_INTERSTITIAL) return;
    if(interstitialAd != null) return;
    isInterstitialLoaded = false;
    hideInterstitial();
    AdMob.createInterstitialAd(new AdListener(
      onIntersAdLoaded: (InterstitialAd ad){
        isInterstitialLoaded = true;
        interstitialAd = ad;
      },
      onAdClosed: (){
        Future.delayed(const Duration(seconds: AppConfig.DELAY_NEXT_INTERSTITIAL), () {
          initInterstitialAd();
        });
      }
    ));
  }

  void hideInterstitial(){
    try { interstitialAd?.dispose(); } catch (ex) { }
  }

  bool showInterstitial(){
    print("showInterstitial");
    if(!AppConfig.ADS_MAIN_INTERSTITIAL) return false;
    try {
      if(interstitialAd == null || !isInterstitialLoaded) return false;
      interstitialAd?.show();
      return true;
    } catch (error) {
      return false;
    }
  }

}

class DrawerHeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160, color: MyColors().primaryTheme.withOpacity(0.8),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Image.asset(Img.get('drawer_bg.png'),
              width: double.infinity, height: 100, fit: BoxFit.cover,
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: Dimens.spacing_large, vertical: Dimens.spacing_middle),
            child: Stack(
              children: <Widget>[
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                      padding: EdgeInsets.symmetric(vertical: Dimens.spacing_mxlarge),
                      child: Row(
                        children: <Widget>[
                          Spacer(),
                          MaterialButton(
                            minWidth: Dimens.spacing_xmlarge,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            onPressed: () {
                              Get.to(() => PageMaps(null));
                            },
                            elevation: 0, color: MyColors.accentDark,
                            child: Icon(Icons.map, color: MyColors.white),
                            padding: EdgeInsets.all(10),
                            shape: CircleBorder(side: BorderSide(color: MyColors.white, width: 0.6)),
                          ),
                          Container(width: Dimens.spacing_large, height: 0),
                          MaterialButton(
                            minWidth: Dimens.spacing_xmlarge,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            onPressed: () {
                              Get.to(() => PageSetting());
                            },
                            elevation: 0, color: MyColors.accentDark,
                            child: Icon(Icons.settings, color: MyColors.white),
                            padding: EdgeInsets.all(10),
                            shape: CircleBorder(side: BorderSide(color: MyColors.white, width: 0.6)),
                          ),
                        ],
                      )
                  ),
                ),
                Align(
                  alignment: Alignment.bottomLeft,
                  child: Padding(
                      padding: EdgeInsets.only(top: Dimens.spacing_xlarge, bottom: Dimens.spacing_small),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(MyStrings.city_name, style: MyText.subtitle1(context)!.copyWith(
                              color: Colors.white, fontWeight: FontWeight.bold
                          )),
                          Container(height: Dimens.spacing_medium),
                          Text(MyStrings.city_address, style: MyText.caption(context)!.copyWith(
                              color: Colors.white
                          )),
                        ],
                      )
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
