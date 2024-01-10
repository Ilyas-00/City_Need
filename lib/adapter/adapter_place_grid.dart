import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../data/dimens.dart';
import '../data/constant.dart';
import '../data/my_colors.dart';
import '../utils/tools.dart';
import '../model/place.dart';
import '../widget/my_text.dart';

class AdapterPlaceGrid {

  var isLoading = false.obs;
  List items = <Place>[];
  Function? onItemClick;
  ScrollController scrollController;

  AdapterPlaceGrid(this.items, this.scrollController);

  Widget getView(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(4),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: Tools.getGridSpanCount(context),
        childAspectRatio: 7 / 9,
      ),
      itemBuilder: (BuildContext context, int _index) {
        return ItemTile(index: _index, object: items[_index], onClick: onItemClick);
      },
      controller: scrollController,
    );
  }

  Widget getSilverView(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(4),
      sliver: SliverGrid(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          childAspectRatio: 7 / 9,
          crossAxisCount: Tools.getGridSpanCount(context),
        ),
        delegate: new SliverChildBuilderDelegate((BuildContext context, int _index) {
          return ItemTile(index: _index, object: items[_index], onClick: itemClickListener);
        },
          childCount: items.length,
        ),
      ),
    );
  }

  void resetListData() => items = [];
  void insertData(List<Place> _items) => items.addAll(_items);
  int getItemCount() => items.length;
  void setLoading() => isLoading.value = true;
  void setLoaded() => isLoading.value = false;

  void itemClickListener(int index, Place value){
    if(onItemClick != null) onItemClick!(index, value);
  }

}

// ignore: must_be_immutable
class ItemTile extends StatelessWidget {
  final Place object;
  final int index;
  final Function? onClick;

  const ItemTile({
    Key? key,
    required this.index,
    required this.object,
    required this.onClick,
  })  : assert(index != null),
        assert(object != null),
        super(key: key);

  void onItemClick(Place obj) {
    if(onClick != null) onClick!(index, obj);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
        clipBehavior: Clip.antiAliasWithSaveLayer, elevation: 0.5,
        color: MyColors.white,
        margin: const EdgeInsets.all(4),
        child: Material(
            color: Colors.transparent,
            child: InkWell( onTap: () => onItemClick(object),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        width: double.infinity, height: double.infinity,
                        color: MyColors.grey_hard,
                        child: Tools.displayImage(Constant.getURLimgPlace(object.image)),
                      ),
                    ),
                    Divider(height: 0, color: MyColors.grey_medium),
                    Container(
                      height: 45,
                      padding: EdgeInsets.symmetric(horizontal: Dimens.spacing_middle),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(object.name, maxLines: 1,style: MyText.body1(context)!.copyWith(
                              color: MyColors.grey_dark
                          )),
                          Container(height : object.distance != -1 ? Dimens.spacing_xsmall : 0),
                          object.distance != -1 ? Row(
                            children: [
                              Icon(Icons.near_me, color: MyColors.grey_hard, size: Dimens.spacing_middle),
                              Container(width: Dimens.spacing_small),
                              Text(Tools.getFormattedDistance(object.distance), maxLines: 1, style: MyText.caption(context)!.copyWith(
                                  color: MyColors.grey_hard
                              ))
                            ],
                          ) : Container()
                        ],
                      ),
                    )
                  ],
                )
            )
        )
    );
  }
}
