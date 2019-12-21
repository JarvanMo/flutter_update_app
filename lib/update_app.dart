import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class UpdateApp {
  static const MethodChannel _channel =
      const MethodChannel('cn.mofada.cn/update_app');

  //更新app
  static Future<bool> updateApp({
    @required String url,
    @required String appleId,
    String title,
    String description = "应用更新",
  }) async {
    var result = await _channel.invokeMethod('updateApp', {
      "argumentsUrl": url,
      "argumentsTitle": title ?? appName(url),
      "argumentsDescription": description,
      "appleId": appleId
    });
    return result;
  }

}
