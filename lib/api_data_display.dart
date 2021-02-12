import 'dart:core';

import 'package:flutter/material.dart';

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
                    'Data displayed might be less accurate at first due to missing permission to access the location.\nIf you encounter such issues please provide permission and refresh the application several times.',
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
                  Text('Temperature: ' + temperature),
                  Text('Pressure: ' + pressure),
                  Text('Humidity: ' + humidity),
                ]))),
        Padding(padding: EdgeInsets.only(top: 10.0)),
      ],
    );
  }
}
