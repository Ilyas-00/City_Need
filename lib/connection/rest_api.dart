import 'dart:convert';
import 'package:http_interceptor/http_interceptor.dart';
import 'package:http/http.dart' as http;
import 'callbacks/resp_device.dart';
import 'callbacks/resp_place_details.dart';
import 'callbacks/resp_list_place.dart';
import '../model/device_info.dart';
import '../data/constant.dart';
import 'callbacks/resp_news_info.dart';
import 'rest_api_interceptor.dart';

class RestAPI {

  late String base;
  late http.Client client;

  var _headers = {
    "User-Agent" : "Place",
    "Cache-Control" : "max-age=0",
    "Content-Type" : "application/json"
  };

  RestAPI(){
    base = Constant.WEB_URL;
    client = InterceptedClient.build(interceptors: [
      HttpInterceptor(),
    ], requestTimeout: Duration(seconds: 5));
  }


  Future<RespListPlace> getPlacesByPage(int page, int count, int draft) async {
    var params = {
      'page': page.toString(), 'count': count.toString(), 'draft': draft.toString()
    };

    var uri = Uri.parse(base + 'app/services/listPlaces');
    uri = uri.replace(queryParameters: params);
    final response = await client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      return RespListPlace.fromJson(json.decode(response.body));
    } else {
      return RespListPlace(status: "failed");
    }
  }

  Future<RespPlaceDetails> getPlaceDetails(int? placeId) async {
    var params = { 'place_id': placeId.toString() };
    var uri = Uri.parse(base + 'app/services/getPlaceDetails');
    uri = uri.replace(queryParameters: params);
    final response = await client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      return RespPlaceDetails.fromJson(json.decode(response.body));
    } else {
      return RespPlaceDetails();
    }
  }

  Future<RespDevice> registerDevice(DeviceInfo info) async {
    var uri = Uri.parse(base + 'app/services/insertGcm');
    var body = json.encode(info.toJson());
    final response = await client.post(uri, headers: _headers, body: body);
    if (response.statusCode == 200) {
      return RespDevice.fromJson(json.decode(response.body));
    } else {
      return RespDevice(status: "failed");
    }
  }

  Future<RespNewsInfo> getNewsInfoByPage(int? page, int count) async {
    var params = { 'page': page.toString(), 'count': count.toString() };

    var uri = Uri.parse(base + 'app/services/listNewsInfo');
    uri = uri.replace(queryParameters: params);
    final response = await client.get(uri, headers: _headers);
    if (response.statusCode == 200) {
      return RespNewsInfo.fromJson(json.decode(response.body));
    } else {
      return RespNewsInfo(status: "failed");
    }
  }

}