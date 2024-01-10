import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/my_colors.dart';
import '../widget/my_text.dart';

class AdapterSuggestionSearch {

  static const String SEARCH_HISTORY_KEY = "_SEARCH_HISTORY_KEY";
  static const int MAX_HISTORY_ITEMS = 5;

  var dataLoaded = false.obs;
  List? items = <String>[];
  List itemTile = <ItemTile>[];
  Function? onItemClick;

  AdapterSuggestionSearch(){
    refreshData();
  }

  void refreshData(){
    dataLoaded.value = false;
    itemTile.clear();
    getSearchHistory().then((value){
      items = value;
      for (var _index = items!.length-1; _index >= 0; _index--) {
        itemTile.add(ItemTile(index: _index, object: items![_index], onClick: itemClickListener));
      }
      dataLoaded.value = true;
    });
  }

  void itemClickListener(int index, String value){
    if(onItemClick != null) onItemClick!(index, value);
  }

  Widget getView() {
    return Obx(() => dataLoaded.value ? Container(
      padding: EdgeInsets.symmetric(vertical: 8),
      color: Colors.white, width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: itemTile as List<Widget>,
      ),
    ) : Container());
  }

  int getItemCount() => items!.length;

  void addSearchHistory(String s) async {
    List<String> result = (await getSearchHistory())!;
    if(result.contains(s)) result.remove(s);
    result.add(s);
    if (result.length > MAX_HISTORY_ITEMS) result.removeAt(0);
    String value = json.encode(result);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(SEARCH_HISTORY_KEY, value);
  }

  Future<List<String>?> getSearchHistory() async {
    List<dynamic>? result = <dynamic>[];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String value = prefs.getString(SEARCH_HISTORY_KEY) ?? "";
    if(value.isEmpty) return result as FutureOr<List<String>?>;
    result = json.decode(value);
    return result!.map((e) => e as String).toList();
  }

}

// ignore: must_be_immutable
class ItemTile extends StatelessWidget {
  final String object;
  final int index;
  final Function onClick;

  const ItemTile({
    Key? key,
    required this.index,
    required this.object,
    required this.onClick,
  })  : assert(index != null),
        assert(object != null),
        super(key: key);

  void onItemClick(String obj) {
    if(onClick != null) onClick(index, obj);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){ onItemClick(object); },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              Container(width: 10),
              Icon(Icons.history, color: MyColors.grey_hard, size: 20),
              Container(width: 15),
              Text(object, maxLines:1, style: MyText.body1(context)!.copyWith(color: MyColors.grey_hard))
            ],
          ),
        ),
      )
    );
  }
}
