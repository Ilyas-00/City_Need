import 'package:flutter/foundation.dart';
import 'package:http_interceptor/http_interceptor.dart';

class HttpInterceptor implements InterceptorContract {
  @override
  Future<RequestData> interceptRequest({required RequestData data}) async {
    if(kDebugMode){
      print(">>>");
      print(data);
    }
    return data;
  }

  @override
  Future<ResponseData> interceptResponse({required ResponseData data}) async {
    if(kDebugMode){
      print("<<<");
      print(data);
    }
    return data;
  }

}