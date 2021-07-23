import 'dart:core';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ApiDataDisplay extends StatelessWidget {
  String latitude;
  String longitude;
  String airQualityIndex;
  String lastUpdate;
  String stationAddress;
  String stationUpdateTime;
  String humidity;
  String pressure;
  String temperature;
  String epaNameLocal;
  String epaUrlLocal;
  String waqiNameLocal;
  String waqiUrlLocal;
  Color indexColor = Colors.black;

  ApiDataDisplay(
      this.latitude,
      this.longitude,
      this.airQualityIndex,
      this.lastUpdate,
      this.stationAddress,
      this.stationUpdateTime,
      this.humidity,
      this.pressure,
      this.temperature,
      this.epaUrlLocal,
      this.epaNameLocal,
      this.waqiUrlLocal,
      this.waqiNameLocal,
      this.indexColor);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            //Center Row contents horizontally,
            crossAxisAlignment: CrossAxisAlignment.center,
            //Center Row contents vertically,
            children: [
              Text(airQualityIndex,
                  style: new TextStyle(color: indexColor, fontSize: 50.0)),
              Tooltip(
                message:
                    'Data displayed might be less accurate at first due to missing permission to access the location.\nIf you encounter such issues please provide permission and swipe down to refresh the application several times.',
                child: FlatButton(
                  minWidth: 20,
                  child: Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Colors.teal,
                  ),
                ),
              ),
            ],
          ),
        ),
        Card(
          child: Padding(
            padding: EdgeInsets.all(6.0),
            child: Column(
              children: [
                Text('Spatial and temporal data',
                    style: new TextStyle(color: Colors.green, fontSize: 15.0)),
                Text('Last updated at: ' + lastUpdate),
                Text('Last known location: ' + latitude + ", " + longitude),
                Text('Measurement station address: '),
                Text(stationAddress),
                Text('Last station data update: ' + stationUpdateTime),
              ],
            ),
          ),
        ),
        Card(
            child: Padding(
                padding: EdgeInsets.all(6.0),
                child: Column(children: [
                  Text('Weather measurements',
                      style:
                          new TextStyle(color: Colors.green, fontSize: 15.0)),
                  Text('Temperature: ' + temperature + " \u2103"),
                  Text('Pressure: ' + pressure + " mbar"),
                  Text('Humidity: ' + humidity + " %"),
                ]))),
        Padding(padding: EdgeInsets.only(top: 5.0)),
        Card(
            child: Padding(
                padding: EdgeInsets.all(5.0),
                child: Column(
                  children: [
                    Text('Data was provided by',
                        style: new TextStyle(
                          color: Colors.green,
                          fontSize: 15.0,
                        )),
                    InkWell(
                        child: new Text(epaNameLocal,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                color: Colors.blue)),
                        onTap: () => launch(epaUrlLocal)),
                    Text('Via ',
                        style: new TextStyle(
                          color: Colors.green,
                          fontSize: 15.0,
                        )),
                    InkWell(
                        child: new Text(waqiNameLocal,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 12,
                                decoration: TextDecoration.underline,
                                color: Colors.blue)),
                        onTap: () => launch(waqiUrlLocal)),
                  ],
                ))),
      ],
    );
  }
}
