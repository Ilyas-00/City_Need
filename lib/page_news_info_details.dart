import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'data/app_config.dart';
import 'page_fullscreen_image.dart';
import 'data/dimens.dart';
import 'data/constant.dart';
import 'data/my_colors.dart';
import 'model/news_info.dart';
import 'utils/admob.dart';
import 'utils/tools.dart';
import 'widget/my_text.dart';

class PageNewsInfoDetails extends StatefulWidget {

  final NewsInfo? newsInfo;
  PageNewsInfoDetails(this.newsInfo);

  @override
  PageNewsInfoDetailsState createState() => new PageNewsInfoDetailsState();
}

class PageNewsInfoDetailsState extends State<PageNewsInfoDetails> {

  NewsInfo? newsInfo;
  late BuildContext context;
  WebViewController? webViewController;
  double? webViewHeight;

  BannerAd? bannerAd;
  var onBannerLoaded = false.obs;

  @override
  void initState() {
    super.initState();
    newsInfo = widget.newsInfo;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      displayWebView();
      initBannerAd();
    });
  }

  void onImagesItemClick() {
    List<String> images = [Constant.getURLimgNews(newsInfo!.image!)];
    Get.to(() => PageFullScreenImage(images, 0));
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Column(
      children: [
        Expanded(child: Scaffold(
          backgroundColor: MyColors.white,
          body: NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  systemOverlayStyle: SystemUiOverlayStyle(
                      statusBarBrightness: Brightness.dark
                  ), forceElevated: true,
                  elevation: 0, backgroundColor: MyColors().primaryTheme,
                  expandedHeight: 120.0, floating: false, pinned: false,
                  flexibleSpace: FlexibleSpaceBar(),
                  bottom: PreferredSize(
                      child: Container(
                        color: MyColors().primaryTheme, padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
                        alignment: Alignment.bottomLeft,
                        constraints: BoxConstraints.expand(height: 80),
                        child: Text(newsInfo!.title!, maxLines:3, style: MyText.medium(context).copyWith(
                            color: Colors.white, fontWeight: FontWeight.w500
                        )),
                      ),
                      preferredSize: Size.fromHeight(80)
                  ),
                  actions: <Widget>[
                    IconButton(
                      icon: Icon(Icons.share),
                      onPressed: () => Tools.methodShareNews(newsInfo!),
                    ),
                  ],
                ),
              ];
            },
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Material(
                      color: Colors.transparent,
                      child: InkWell( onTap: () => onImagesItemClick(),
                        child: AspectRatio(
                            aspectRatio: 8 / 5,
                            child: Tools.displayImage(Constant.getURLimgNews(newsInfo!.image!))
                        ),
                      )
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    height: Dimens.spacing_xxlarge,
                    child: Row(
                      children: [
                        Icon(Icons.event, size: Dimens.spacing_large, color: MyColors.grey_hard),
                        Container(width: 10),
                        Text(Tools.getFormattedDate(newsInfo!.lastUpdate!), style: MyText.body2(context)!.copyWith(color: MyColors.grey_hard)),
                      ],
                    ),
                  ),
                  Divider(height: 0),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                    height: webViewHeight != null ? webViewHeight : 500,
                    child: WebView(
                      initialUrl: 'about:blank',
                      javascriptMode: JavascriptMode.unrestricted,
                      onWebViewCreated: (WebViewController controller) async {
                        webViewController = controller;
                      },
                      onPageFinished: (val) async {
                        if (webViewController != null) {
                          double height = double.parse(await webViewController!.runJavascriptReturningResult("document.documentElement.scrollHeight;"));
                          setState(() {
                            webViewHeight = height;
                          });
                        }
                      },
                    ),
                  )
                ],
              ),
            ),
          ),
        )),
        Obx(() => onBannerLoaded.value && bannerAd != null ? Container(
          height: bannerAd!.size.height.toDouble(),
          width: double.infinity,
          color: MyColors.white,
          child: AdWidget(ad: bannerAd!),
        ) : Container()),
      ],
    );
  }

  void displayWebView() {
    if(webViewController == null) {
      Future.delayed(const Duration(milliseconds: 300), () {
        displayWebView();
      });
      return;
    }
    String htmlData = "<!DOCTYPE html><html><head>"
        "<meta name='viewport' content='width=device-width, initial-scale=1.0'>"
        "<style>img{max-width:100%;height:auto;} iframe{width:100%;}</style></head>"
        + newsInfo!.fullContent! +
        "</html>";
    webViewController!.loadUrl(Uri.dataFromString(
        htmlData,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }

  void initBannerAd(){
    if(!AppConfig.ADS_NEWS_DETAILS_BANNER) return;
    if(onBannerLoaded.value || bannerAd != null) return;
    bannerAd = AdMob.createBannerAd(new AdListener(
      onBannerAdLoaded: () => onBannerLoaded.value = true,
    ));
    bannerAd!.load();
  }

}

