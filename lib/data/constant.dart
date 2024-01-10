
class Constant {

  // -------------------- EDIT THIS WITH YOURS -------------------------------------------------

  // Edit WEB_URL with your url. Make sure you have backslash('/') in the end url
  static const String WEB_URL = "https://demo.dream-space.web.id/the_city/";

  // for map zoom
  static const double cityLat = -6.9174639;
  static const double cityLng = 107.6191228;

  // ------------------- DON'T EDIT THIS -------------------------------------------------------

  // this limit value used for give pagination (request and display) to decrease payload
  static const int LIMIT_PLACE_REQUEST = 40;
  static const int LIMIT_LOAD_MORE = 40;

  static const int LIMIT_NEWS_REQUEST = 40;

  // Method get path to image
  static String getURLimgPlace(String fileName) {
    return WEB_URL + "uploads/place/" + fileName;
  }
  static String getURLimgNews(String fileName) {
    return WEB_URL + "uploads/news/" + fileName;
  }

}
