class AppConfig {

  // flag for display ads, change true and false only
  static const bool ADS_ALL_ENABLE = true;

  // flag for display ads
  static const bool ADS_MAIN_BANNER = ADS_ALL_ENABLE && true;
  static const bool ADS_MAIN_INTERSTITIAL = ADS_ALL_ENABLE && true;
  static const int DELAY_NEXT_INTERSTITIAL = 60; // in second
  static const bool ADS_PLACE_DETAILS_BANNER = ADS_ALL_ENABLE && true;
  static const bool ADS_NEWS_DETAILS_BANNER = ADS_ALL_ENABLE && true;

  // this flag if you want to hide menu news info
  static const bool ENABLE_NEWS_INFO = true;

  // flag for save image offline
  static const bool IMAGE_CACHE = true;

  // if you place data more than 200 items please set TRUE
  static const bool LAZY_LOAD = false;

  // clear image cache when receive push notifications
  static const bool REFRESH_IMG_NOTIF = false;

  // when user enable gps, places will sort by distance
  static const bool SORT_BY_DISTANCE = true;

  // distance metric, fill with KILOMETER or MILE only
  static const String DISTANCE_METRIC_CODE = "KILOMETER";

  // related to UI display string
  static const String DISTANCE_METRIC_STR = "Km";

  // flag for enable disable theme color chooser, in Setting
  static const bool THEME_COLOR = true;
}
