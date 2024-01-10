import 'package:flutter/material.dart';
import 'package:sprintf/sprintf.dart';
import 'data/my_strings.dart';
import 'data/my_colors.dart';
import 'utils/tools.dart';
import 'widget/my_text.dart';
import 'package:get/get.dart';

class PageFullScreenImage extends StatefulWidget {

  final List<String> images;
  final int position;

  PageFullScreenImage(this.images, this.position);

  @override
  PageFullScreenImageState createState() => new PageFullScreenImageState();
}


class PageFullScreenImageState extends State<PageFullScreenImage> {

  PageController? pageController;
  var page = 0.obs;

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: widget.position,
    );
    page.value = widget.position;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MyColors.black,
      appBar: PreferredSize(preferredSize: Size.fromHeight(0), child: Container(color: Colors.black)),
      body: Container(
        width: double.infinity, height: double.infinity,
        child: Stack(
          children: <Widget>[
            PageView(
              onPageChanged: onPageViewChange,
              controller: pageController,
              children: buildPageViewItem(),
            ),
            Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.topRight,
              child: IconButton(icon: Icon(Icons.close, color: MyColors.white), onPressed: (){
                Navigator.of(context).pop();
              }),
            ),
            Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.bottomCenter,
              child: Obx(() => Text(
                  sprintf(MyStrings.image_of, [page.value+1, widget.images.length]),
                  style: MyText.subhead(context)!.copyWith(color: MyColors.white)
              )),
            ),
          ]
        )
      ),
    );
  }

  void onPageViewChange(int _page) => page.value = _page;

  List<Widget> buildPageViewItem(){
    List<Widget> widgets = [];
    for(String img in widget.images) {
      Widget wg = InteractiveViewer(
        panEnabled: true,
        child: Container(
          alignment: Alignment.center,
          width: double.infinity, height: double.infinity,
          child: Tools.displayImage(img)
        )
      );
      widgets.add(wg);
    }
    return widgets;
  }

}

