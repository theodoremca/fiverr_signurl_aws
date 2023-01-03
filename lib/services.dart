import 'dart:io';

import 'package:dio/dio.dart';



class Services {
  Future<String> getAwsSignedUrl({CancelToken? cancelToken}) async {
    final Response<dynamic> response = await Dio()
        .get(
      "http://192.168.0.164:8080/s3Url",
      cancelToken: cancelToken,
    )
        .onError((DioError error, stackTrace) {
      return Future.error(error);
    });
    // print(response.data["url"]);
    return response.data["url"];
  }

  Future<String> uploadWithAwsSignedUrl({required File file,required String url,CancelToken? cancelToken}) async {
    final len = await file.length();
    final Response<dynamic> response = await Dio()
        .put(
      url,
      cancelToken: cancelToken,
      data: file.openRead(),
      options: Options(headers: {
        Headers.contentLengthHeader: len,
      })
    )
        .onError((DioError error, stackTrace) {
      return Future.error(error);
    });
    print(response.statusCode);
    print(url.split("?")[0]);
    print(" raw :  $response");
    // print(response.data["url"]);
    return url.split("?")[0];
  }
  // Future<>
}
