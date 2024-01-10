import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'connection/rest_api.dart';
import 'data/app_config.dart';
import 'page_fullscreen_image.dart';
import 'package:toast/toast.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:get/get.dart';
import 'data/dimens.dart';
import 'data/constant.dart';
import 'connection/callbacks/resp_place_details.dart';
import 'data/database_handler.dart';
import 'model/images.dart';
import 'model/place.dart';
import 'data/my_colors.dart';
import 'data/my_strings.dart';
import 'page_maps.dart';
import 'utils/admob.dart';
import 'utils/tools.dart';
import 'widget/my_text.dart';

class PagePlaceDetails extends StatefulWidget {

  final Place? place;

  PagePlaceDetails(this.place);

  @override
  PagePlaceDetailsState createState() => new PagePlaceDetailsState();
}


class PagePlaceDetailsState extends State<PagePlaceDetails> {

  late BuildContext _scaffoldCtx;

  ScrollController scrollController = new ScrollController();
  GoogleMapController? mapController;
  DatabaseHandler db = DatabaseHandler.instance;
  WebViewController? webViewController;

  BannerAd? bannerAd;
  var onBannerLoaded = false.obs;

  Place? place;
  var onProcess = false.obs;
  var flagFavorite = false.obs;
  List<String> images = [];
  var topFab = 0.0.obs, webViewHeight = 50.0.obs;
  var showFab = false.obs, loadedImages = false.obs, onMapUpdate = false.obs;
  Set<Marker> markers = {};

  void onImagesItemClick(int position) {
    Get.to(() => PageFullScreenImage(images, position));
  }

  @override
  void initState() {
    super.initState();
    place = widget.place;
    loadPlaceData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fabToggle();
      initBannerAd();
      scrollController.addListener(() {
        fabScrollController();
      });
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Scaffold(
          backgroundColor: MyColors.grey_bg,
          body: Builder(builder: (BuildContext context){
            _scaffoldCtx = context;
            return Stack(
              children: [
                NestedScrollView(
                  controller: scrollController,
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                    return <Widget>[
                      SliverAppBar(
                        expandedHeight: 300.0, systemOverlayStyle: SystemUiOverlayStyle(
                          statusBarBrightness: Brightness.dark
                        ),
                        floating: false, pinned: true, forceElevated: true,
                        backgroundColor: MyColors().primaryTheme,
                        flexibleSpace: FlexibleSpaceBar(
                          background: Stack(
                            fit: StackFit.expand,
                            children: [
                              Tools.displayImage(Constant.getURLimgPlace(place!.image)),
                              Material(
                                  color: Colors.transparent,
                                  child: InkWell( onTap: () => onImagesItemClick(0),
                                    child: Container( height: double.infinity, width: double.infinity,
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.center, end: Alignment.bottomCenter,
                                            colors: [Colors.transparent, Colors.black.withOpacity(0.4)],
                                          )
                                      ),
                                    ),
                                  )
                              ),
                            ],
                          ),
                        ),
                        bottom: PreferredSize(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(20, 0, 0, 20),
                              alignment: Alignment.bottomLeft,
                              constraints: BoxConstraints.expand(height: 80),
                              child: Text(
                                place!.name, style: MyText.title(context)!.copyWith(color: Colors.white),
                                maxLines: 2, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            preferredSize: Size.fromHeight(80)
                        ),
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        actions: <Widget>[
                          IconButton(
                            icon: Icon(Icons.share),
                            onPressed: () {
                              if(place!.isDraft()) return;
                              Tools.methodShare(place!);
                            },
                          ),
                        ],
                      ),
                    ];
                  },
                  body: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: Dimens.spacing_medium, vertical: Dimens.spacing_middle),
                    child: Column(
                      children: <Widget>[
                        Card(
                          shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(4)),
                          clipBehavior: Clip.antiAliasWithSaveLayer, elevation: 0.5,
                          child: Obx((){
                            onProcess.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(height: Dimens.spacing_medium),
                                place!.distance > 0 ? ListTile(
                                  title: Text(Tools.getFormattedDistance(place!.distance), style: MyText.body1(context)!.copyWith(color: MyColors.grey_mdark)),
                                  leading: Icon(Icons.near_me, color: MyColors.grey_hard, size: Dimens.spacing_mlarge),
                                  horizontalTitleGap: 0, dense: true,
                                  onTap: (){},
                                ) : Container(),
                                ListTile(
                                  title: Text(place!.address, style: MyText.body1(context)!.copyWith(color: MyColors.grey_mdark)),
                                  leading: Icon(Icons.directions, color: MyColors.grey_hard, size: Dimens.spacing_mlarge),
                                  horizontalTitleGap: 0, dense: true,
                                  onTap: (){
                                    String url = "http://maps.google.com/maps?daddr=" + place!.lat.toString() + "," + place!.lng.toString();
                                    Tools.directLinkToBrowser(url);
                                  },
                                ),
                                ListTile(
                                  title: Text(place!.phone, style: MyText.body1(context)!.copyWith(color: MyColors.grey_mdark)),
                                  leading: Icon(Icons.phone_in_talk, color: MyColors.grey_hard, size: Dimens.spacing_mlarge),
                                  horizontalTitleGap: 0, dense: true,
                                  onTap: (){
                                    String phone = "tel:"+place!.phone;
                                    Tools.openDialPhone(phone);
                                  },
                                ),
                                ListTile(
                                  title: Text(place!.website, style: MyText.body1(context)!.copyWith(color: MyColors.grey_mdark)),
                                  leading: Icon(Icons.public, color: MyColors.grey_hard, size: Dimens.spacing_mlarge),
                                  horizontalTitleGap: 0, dense: true,
                                  onTap: (){
                                    Tools.directLinkToBrowser(place!.website);
                                  },
                                ),
                                Container(height: Dimens.spacing_medium),
                              ],
                            );
                          }),
                        ),
                        Container(height: Dimens.spacing_medium),
                        Card(
                          shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(4)),
                          clipBehavior: Clip.antiAliasWithSaveLayer, elevation: 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(Dimens.spacing_large, Dimens.spacing_large, Dimens.spacing_large, 0),
                                child: Text(MyStrings.photos_title, style: MyText.title(context)!.copyWith(
                                    color: MyColors.grey_mdark, fontWeight: FontWeight.w300
                                )),
                              ),
                              Container(height: Dimens.spacing_large),
                              Container(
                                width: double.infinity, height: 80, padding: EdgeInsets.symmetric(horizontal: Dimens.spacing_xmiddle),
                                child: Obx(() => loadedImages.value ? ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemBuilder: (BuildContext context, int index) {
                                    return InkWell(
                                      child: Container(
                                        width: 80, height: 80, margin: const EdgeInsets.symmetric(horizontal: Dimens.spacing_small),
                                        color: MyColors.grey_hard,
                                        child: CachedNetworkImage(
                                          imageUrl : images[index], fit: BoxFit.cover,
                                        ),
                                      ),
                                      onTap: () => onImagesItemClick(index) ,
                                    );
                                  },
                                  itemCount: images.length,
                                ) : Container(height: 80)),
                              ),
                              Container(height: Dimens.spacing_mlarge),
                            ],
                          ),
                        ),
                        Container(height: Dimens.spacing_medium),
                        Card(
                          shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(4)),
                          clipBehavior: Clip.antiAliasWithSaveLayer, elevation: 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(Dimens.spacing_large),
                                child: Text(MyStrings.description_title, style: MyText.title(context)!.copyWith(
                                    color: MyColors.grey_mdark, fontWeight: FontWeight.w300
                                )),
                              ),
                              Divider(),
                              Obx(() {
                                double _webViewHeight = webViewHeight.value;
                                return Container(
                                  width: double.infinity,
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  height: _webViewHeight,
                                  child: WebView(
                                    initialUrl: 'about:blank',
                                    javascriptMode: JavascriptMode.unrestricted,
                                    onWebViewCreated: (WebViewController controller) async {
                                      webViewController = controller;
                                    },
                                    onPageFinished: (val) async {
                                      if (webViewController != null) {
                                        double height = double.parse(await webViewController!.runJavascriptReturningResult("document.documentElement.scrollHeight;"));
                                        webViewHeight.value = height;
                                      }
                                    },
                                  ),
                                );
                              }),
                              Container(height: Dimens.spacing_large),
                            ],
                          ),
                        ),
                        Container(height: Dimens.spacing_medium),
                        Card(
                          shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(4)),
                          clipBehavior: Clip.antiAliasWithSaveLayer, elevation: 0.5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(Dimens.spacing_large),
                                child: Text(MyStrings.map_title, style: MyText.title(context)!.copyWith(
                                    color: MyColors.grey_mdark, fontWeight: FontWeight.w300
                                )),
                              ),
                              Container(
                                  margin: EdgeInsets.symmetric(horizontal: Dimens.spacing_large),
                                  color: MyColors.grey_medium,
                                  height: 150, child: Obx((){
                                return onMapUpdate.value ? GoogleMap(
                                  mapType: MapType.normal, zoomControlsEnabled: false,
                                  rotateGesturesEnabled: false, compassEnabled: false,
                                  scrollGesturesEnabled: false, myLocationButtonEnabled: false,
                                  zoomGesturesEnabled: false, tiltGesturesEnabled: false,
                                  onMapCreated: onGoogleMapCreated,
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(place!.lat!, place!.lng!),
                                    zoom: 12,
                                  ),
                                  markers: markers,
                                ) : Container(color: MyColors.grey_medium);
                              })
                              ),
                              Container(height: Dimens.spacing_small),
                              Row(
                                children: [
                                  Spacer(),
                                  TextButton(
                                    child: Text(MyStrings.map_view, style: TextStyle(color: MyColors.accent)),
                                    onPressed: () => Get.to(() => PageMaps(place)),
                                  ),
                                  TextButton(
                                    child: Text(MyStrings.map_navigate, style: TextStyle(color: MyColors.accent)),
                                    onPressed: (){
                                      String url = "http://maps.google.com/maps?daddr=" + place!.lat.toString() + "," + place!.lng.toString();
                                      Tools.directLinkToBrowser(url);
                                    },
                                  ),
                                  Container(width: Dimens.spacing_large),
                                ],
                              ),
                              Container(height: Dimens.spacing_small),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                buildFloatingActionButton(),
                Obx(() => onProcess.value ? Align(
                  alignment: Alignment.center,
                  child: CircularProgressIndicator(),
                ) : Container())
              ],
            );
          }),
        )),
        Obx(() => onBannerLoaded.value && bannerAd != null ? Container(
          height: bannerAd!.size.height.toDouble(),
          width: double.infinity,
          color: MyColors.grey_bg,
          child: AdWidget(ad: bannerAd!),
        ) : Container()),
      ]
    );
  }

  void fabScrollController(){
    // default top margin, -4 for exact alignment
    double startFabPosition = 300-(4.0*2);
    double offset = scrollController.offset;
    double collapseOffset = 300 - (kToolbarHeight + 80);
    if(offset > collapseOffset) { // when stop
      showFab.value = true;
      topFab.value = startFabPosition - collapseOffset;
      return;
    }
    topFab.value = startFabPosition - offset;
    if(offset > collapseOffset - 100) {
      showFab.value = true;
      return;
    }
    showFab.value = false;
  }

  void displayWebViewData() {
    if(webViewController == null) {
      Future.delayed(Duration(milliseconds: 200), () {
        displayWebViewData();
      });
      return;
    }
    String htmlData = "<!DOCTYPE html><html><head>"
        "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
        "<style>img{max-width:100%;height:auto;} iframe{width:100%;}</style></head>"
        + place!.description +
        "</html>";

    webViewController!.loadUrl(Uri.dataFromString(
        htmlData,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  void setImageGallery() async {
    images.clear();
    images.add(Constant.getURLimgPlace(place!.image));
    List<Images> _images = await db.getListImageByPlaceId(place!.placeId);
    if(_images.isNotEmpty) {
      for(Images img in _images) {
        images.add(Constant.getURLimgPlace(img.name!));
      }
    }
    loadedImages.value = true;
  }

  // places detail load with lazy scheme
  Future loadPlaceData() async {
    debugPrint('loadPlaceData');
    place = await db.getPlace(place!.placeId);
    if (place!.isDraft()) {
      debugPrint('isDraft 2');
      requestDetailsPlace(place!.placeId);
      return null;
    } else {
      displayData();
      return place;
    }
  }

  void requestDetailsPlace(int? placeId) {
    if (onProcess.value) {
      ScaffoldMessenger.of(_scaffoldCtx).showSnackBar(
          SnackBar(content: Text(MyStrings.task_running), duration: Duration(seconds: 1))
      );
      return;
    }
    onProcess.value = true;
    RespPlaceDetails? resp;
    RestAPI().getPlaceDetails(placeId).then((_value) {
      resp = _value;
    }).whenComplete(() {
      if (resp != null && resp!.place != null) {
        db.updatePlace(resp!.place!).then((value) async {
          await Future.delayed(const Duration(milliseconds: 2000));
          onProcess.value = false;
          place = value;
          displayData();
        });  // save result into database
      } else {
        onFailureRetry(MyStrings.failed_load_details);
      }
    });
  }

  void onFailureRetry(String msg) async{
    onProcess.value = false;
    if (!await Tools.checkConnection(context)) {
      msg = MyStrings.no_internet;
    }
    showDialog(barrierDismissible: true, context: context, builder: (BuildContext context){
      return AlertDialog(content: Text(msg),
        contentPadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
        actions: [
          TextButton(child: Text(MyStrings.RETRY), onPressed: () {
            Navigator.of(context).pop();
            loadPlaceData();
          })
        ],
      );
    });
  }

  void displayData(){
    if(!place!.isDraft()){
      place!.phone = place!.phone.isEmpty || place!.phone == "-" ? MyStrings.no_phone_number : place!.phone;
      place!.website = place!.website.isEmpty || place!.website == "-" ? MyStrings.no_website : place!.website;
    }
    setImageGallery();
    displayWebViewData();

    onProcess.value = true;
    onProcess.value = false;

    onMapUpdate.value = true;

  }

  void onGoogleMapCreated(GoogleMapController controller) async {
    mapController = controller;
    markers.clear();
    Marker marker = Marker(
      markerId: MarkerId(place!.placeId.toString()),
      position: LatLng(place!.lat!, place!.lng!),
      icon: BitmapDescriptor.fromBytes(
          await Tools.getBytesFromAsset(MyColors.marker_secondary, Icons.circle)
      )
    );
    markers.add(marker);
    onMapUpdate.value = false;
    onMapUpdate.value = true;
  }

  Widget buildFloatingActionButton() {
    return Obx(() => Positioned(
      top: topFab.value, right: Dimens.spacing_mlarge,
      child: Visibility(
        visible: showFab.value,
        child: FloatingActionButton(
          heroTag: "fabFavorite", mini: false, backgroundColor: MyColors.accent,
          child: Icon(flagFavorite.value ? Icons.favorite : Icons.favorite_outline, color: Colors.white,),
          onPressed: () => onClickFavoriteButton(),
        ),
      ),
    ));
  }

  void initBannerAd(){
    if(!AppConfig.ADS_PLACE_DETAILS_BANNER) return;
    if(onBannerLoaded.value || bannerAd != null) return;
    bannerAd = AdMob.createBannerAd(new AdListener(
      onBannerAdLoaded: () => onBannerLoaded.value = true,
    ));
    bannerAd!.load();
  }

  void onClickFavoriteButton() async {
    if (flagFavorite.value) {
      await db.deleteFavorites(place!.placeId);
      Toast.show(place!.name + " " + MyStrings.remove_favorite, duration : Toast.lengthShort);
    } else {
      await db.addFavorites(place!.placeId);
      Toast.show(place!.name + " " + MyStrings.add_favorite, duration : Toast.lengthShort);
    }
    fabToggle();
  }

  void fabToggle() async {
    flagFavorite.value = await db.isFavoritesExist(place!.placeId);
  }

}
