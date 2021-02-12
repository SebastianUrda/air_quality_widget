import 'dart:core';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WaqiLinkDisplay extends StatelessWidget {
  String latitude = "";
  String longitude = "";

  WaqiLinkDisplay(this.latitude, this.longitude);

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: (latitude != 'NaN' && longitude != 'NaN')
          ? new InkWell(
              child: new Text('More detailed information can be found here',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue)),
              //https://waqi.info/#/c/47.947/22.554/9z
              onTap: () => launch('https://waqi.info/#/c/'+latitude+'/'+longitude+'/9z'))
          : new InkWell(
              child: new Text('More detailed information can be found here',
                  style: TextStyle(
                      decoration: TextDecoration.underline,
                      color: Colors.blue)),
              onTap: () => launch('https://waqi.info/')),
    );
  }
}
