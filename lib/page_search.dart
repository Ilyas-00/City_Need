import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'adapter/adapter_place_grid.dart';
import 'adapter/adapter_suggestion_search.dart';
import 'data/database_handler.dart';
import 'model/place.dart';
import 'page_place_detail.dart';
import 'widget/my_text.dart';
import 'widget/no_item.dart';
import 'package:toast/toast.dart';
import 'data/my_strings.dart';
import 'data/my_colors.dart';

class PageSearch extends StatefulWidget {

  PageSearch();

  @override
  PageSearchState createState() => new PageSearchState();
}

class PageSearchState extends State<PageSearch> {

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController? textEditingController;
  late BuildContext context;
  late AdapterPlaceGrid adapterPlaceGrid;
  late AdapterSuggestionSearch adapterSuggestionSearch;
  DatabaseHandler db = DatabaseHandler.instance;

  var loading = false.obs, showNoItem = true.obs;
  var showClear = false.obs, showSuggestion = true.obs;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();

    adapterPlaceGrid = AdapterPlaceGrid([], new ScrollController());
    adapterPlaceGrid.onItemClick = (int index, Place obj) {
      Get.to(() => PagePlaceDetails(obj));
    };

    adapterSuggestionSearch = AdapterSuggestionSearch();
    adapterSuggestionSearch.onItemClick = (int index, String value){
      showNoItem.value = false;
      textEditingController!.text = value;
      showClear.value = true;
      refreshData(value);
    };
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: MyColors.grey_bg,
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.dark
        ),
        backgroundColor: MyColors.white, titleSpacing: 0,
        title: TextField(
          controller: textEditingController,
          keyboardType: TextInputType.text, autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: MyStrings.hint_search,
            hintStyle: MyText.subhead(context)!.copyWith(color: MyColors.grey_medium),
            labelStyle: MyText.subhead(context)!.copyWith(color: MyColors.grey_dark),
            border: InputBorder.none,
          ),
          onSubmitted: (value){
            if(value == ""){
              Toast.show(MyStrings.please_fill, duration : Toast.lengthShort);
              return;
            }
            showNoItem.value = false;
            refreshData(value);
          },
          onTap: () => showSuggestion.value = true,
          onChanged: (value){
            showClear.value = value.isNotEmpty;
          },
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: MyColors.grey_hard),
          onPressed: () => Navigator.pop(context)
        ),
        actions: [
          Obx(() => showClear.value ? IconButton(
              icon: Icon(Icons.clear, color: MyColors.grey_hard),
              onPressed: () {
                textEditingController!.text = "";
                showClear.value = false;
                refreshData("");
              }
          ) : Container())
        ],
      ),
      body: Stack(
        children: [
          Obx(() {
            if(loading.value){
              return Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(),
              );
            } else {
              return showNoItem.value ? NoItem() : adapterPlaceGrid.getView(context);
            }
          }),
          Obx(() => showSuggestion.value ? adapterSuggestionSearch.getView() : Container()),
        ],
      )
    );
  }

  void refreshData(String query){
    loading.value = true;
    showSuggestion.value = false;
    adapterSuggestionSearch.refreshData();
    adapterPlaceGrid.resetListData();
    if(query.isEmpty){
      loading.value = false;
      showNoItem.value = true;
      return;
    }
    adapterSuggestionSearch.addSearchHistory(query);
    db.searchAllPlace(query).then((items) {
      adapterPlaceGrid.insertData(items);
      loading.value = false;
      showNoItem.value = adapterPlaceGrid.getItemCount() == 0;
    });
  }

}

