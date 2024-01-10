import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/dimens.dart';
import '../utils/tools.dart';
import '../data/constant.dart';
import '../data/my_colors.dart';
import '../model/news_info.dart';
import '../widget/my_text.dart';

class AdapterNewsInfo {

  var isLoading = false.obs;
  List items = <NewsInfo>[];
  Function onItemClick;
  ScrollController scrollController;

  AdapterNewsInfo(this.items, this.onItemClick, this.scrollController);

  Widget getView() {
    return Container(
      child: ListView.builder(
        padding: EdgeInsets.all(3),
        itemBuilder: (BuildContext context, int _index) {
          if (_index == items.length) {
            return buildProgress(_index);
          } else {
            return ItemTile(index: _index, object: items[_index], onClick: onItemClick);
          }
        },
        itemCount: items.length + 1,
        controller: scrollController,
      ),
    );
  }

  void resetListData() => items = [];
  void insertData(List<NewsInfo> _items) => items.addAll(_items);
  int getItemCount() => items.length;
  void setLoading() => isLoading.value = true;
  void setLoaded() => isLoading.value = false;

  Widget buildProgress(int index) {
    return Obx(() => isLoading.value ? Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Dimens.spacing_large),
        child: Center(
          child: CircularProgressIndicator(),
        )
      ) : Container()
    );
  }

}

// ignore: must_be_immutable
class ItemTile extends StatelessWidget {
  final NewsInfo object;
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

  void onItemClick(NewsInfo obj) {
    if(onClick != null) onClick(index, obj);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        clipBehavior: Clip.antiAliasWithSaveLayer, elevation: 1,
        color: MyColors.white, margin: const EdgeInsets.all(3),
        child: InkWell(
          onTap: (){ onItemClick(object); },
          child: Column(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 4 / 2,
                child: Container(
                  width: double.infinity, height: double.infinity,
                  color: MyColors.grey_hard,
                  child: Tools.displayImage(Constant.getURLimgNews(object.image!)),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(Dimens.spacing_middle),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(object.title!, maxLines:2, style: MyText.subhead(context)!.copyWith(color: MyColors.grey_dark, fontWeight: FontWeight.bold)),
                    Container(height: Dimens.spacing_medium),
                    Text(object.briefContent!, maxLines:2, style: MyText.body1(context)!.copyWith(color: MyColors.grey_hard)),
                    Container(height: Dimens.spacing_small),
                  ],
                ),
              )
            ],
          ),
        )
    );
  }
}
