import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class Api {
  static const platform = const MethodChannel('air.quality.widget');

  //    "https://api.waqi.info/feed/geo:" + latitude + ";" + longitude + "/?token=2af09b666411b6719ba2528edaba5f126f6fdfa3"
  Future getAirQualityIndex(latitude, longitude) async {
    var url = 'https://api.waqi.info/feed/geo:' +
        latitude +
        ';' +
        longitude +
        '/?token=2af09b666411b6719ba2528edaba5f126f6fdfa3';
    var response = await http.get(url);
    return response;
  }

  Future getWaqiValuesMap() async {
    Map toReturn;
    try {
      toReturn = await platform.invokeMethod('getWaqiData');
    } on PlatformException catch (e) {
      print("Failed to get shared pref data level: '${e.message}'.");
    }
    return toReturn;
  }
}
