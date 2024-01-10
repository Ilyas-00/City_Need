import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'data/array.dart';
import 'data/constant.dart';
import 'data/database_handler.dart';
import 'data/my_strings.dart';
import 'data/my_colors.dart';
import 'model/category.dart';
import 'model/place.dart';
import 'page_place_detail.dart';
import 'utils/tools.dart';
import 'widget/my_text.dart';

class PageMaps extends StatefulWidget {

  final Place? place;

  PageMaps(this.place);

  @override
  PageMapsState createState() => new PageMapsState();
}

class PageMapsState extends State<PageMaps> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  GoogleMapController? mapController;

  DatabaseHandler db = DatabaseHandler.instance;
  Map<int?, Marker> markers = {};
  Category currentCategory = Array.headerCategories[0];
  Place? place;
  bool isSinglePlace = false;
  var onMapUpdate = false.obs;
  var toolbarTitle = MyStrings.activity_title_maps.obs;

  @override
  void initState() {
    super.initState();
    place = widget.place;
    isSinglePlace = place != null;
    if(isSinglePlace) toolbarTitle.value = place!.name;
    WidgetsBinding.instance.addPostFrameCallback((_) {

    });
  }
  List<PopupMenuItem> children = <PopupMenuItem>[];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey, backgroundColor: MyColors.grey_bg,
      appBar: AppBar(
        backgroundColor: MyColors().primaryTheme, systemOverlayStyle: SystemUiOverlayStyle(
          statusBarBrightness: Brightness.dark
        ),
        titleSpacing: 0,
        title: Obx(()=> Text(toolbarTitle.value, style: TextStyle(color: Colors.white))),
        leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context)
        ),
        actions: [
          PopupMenuButton<Category>(
            icon: Icon(Icons.dns, color: Colors.white),
            padding: EdgeInsets.all(0),
            onSelected: (Category value) => onCategorySelected(value),
            itemBuilder: (context) => generateMenu(),
          )
        ],
      ),
      body: Builder(builder: (BuildContext context){
        return Obx(() {
          onMapUpdate.value;
          return GoogleMap(
            mapType: MapType.normal, myLocationButtonEnabled: true,
            myLocationEnabled: true,
            onMapCreated: onGoogleMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(0, 0), zoom: 0,
            ),
            markers: markers.entries.map((e) => e.value).toSet(),
          );
        });
      }),
    );
  }

  void onCategorySelected(Category value) {
    Marker? singleMarker;
    if(isSinglePlace && place != null){
        singleMarker = markers[place!.placeId];
    }
    markers.clear();
    if(singleMarker != null ) markers[place!.placeId] = singleMarker;
    currentCategory = value;
    toolbarTitle.value = value.name!;
    onMapUpdate.value = true;
    onMapUpdate.value = false;
    addMarkersToMap(false);
  }

  void onGoogleMapCreated(GoogleMapController controller) async {
    mapController = controller;
    markers.clear();
    addMarkersToMap(true);
    LatLng cityLatLang = LatLng(Constant.cityLat, Constant.cityLng);
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: !isSinglePlace ? cityLatLang : LatLng(place!.lat!, place!.lng!),
      zoom: isSinglePlace ? 12 : 9,
    )));
  }

  void addMarkersToMap(bool init) async {
    List<Place?> places = [];
    if(isSinglePlace && init){
      places.add(place);
    } else {
      places = await db.getAllPlaceByCategory(currentCategory.catId);
    }
    BitmapDescriptor iconAll = BitmapDescriptor.fromBytes(
        await Tools.getBytesFromAsset(
            MyColors.marker_primary,
            currentCategory.catId == -1 ? Icons.circle : currentCategory.iconData!
        )
    );
    BitmapDescriptor iconSingle = BitmapDescriptor.fromBytes(
        await Tools.getBytesFromAsset(MyColors.marker_secondary, Icons.circle)
    );
    for(Place? p in places){
      BitmapDescriptor usedIcon = iconAll;
      if(isSinglePlace && p!.placeId == place!.placeId){
        usedIcon = iconSingle;
      }
      Marker marker = Marker(
        markerId: MarkerId(p!.placeId.toString()),
        position: LatLng(p.lat!, p.lng!),
        infoWindow: InfoWindow(title: p.name, onTap: (){
          Get.to(() => PagePlaceDetails(p));
        }),
        icon: usedIcon,
      );
      markers[p.placeId] = marker;
    }
    onMapUpdate.value = true;
  }

  List<PopupMenuEntry<Category>> generateMenu(){
    List<PopupMenuItem<Category>> children = [];
    for (Category cat in Array.headerCategories) {
      if(cat.catId == -1) {
        Widget w = Text(cat.name!, style: MyText.body2(context)!.copyWith(color: MyColors.grey_mdark));
        var menu = PopupMenuItem(value: cat, child: w);
        children.add(menu);
      }
    }
    for (Category cat in Array.categories) {
      Widget w = Text(cat.name!, style: MyText.body2(context)!.copyWith(color: MyColors.grey_mdark));
      var menu = PopupMenuItem(value: cat, child: w);
      children.add(menu);
    }
    return children;
  }

}

