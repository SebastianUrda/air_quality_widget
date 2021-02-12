import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_air_quality_widget/api_data_display.dart';
import 'package:flutter_air_quality_widget/table_with_legend.dart';

import 'api.dart';
import 'data_source_display.dart';

main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Air Quality Index Application '),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  String latitude;
  String longitude;
  String airQualityIndex;
  String lastModification;
  String stationAddress;
  String stationUpdateTime;
  String humidity;
  String pressure;
  String temperature;
  Color indexColor = Colors.black;
  bool display = false;
  Api api = new Api();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    updateWidgetState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("APP_STATE: $state");

    if (state == AppLifecycleState.resumed) {
      // user returned to our app
      updateWidgetState();
    } else if (state == AppLifecycleState.inactive) {
      // app is inactive
    } else if (state == AppLifecycleState.paused) {
      // user quit our app temporally
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Padding(
          padding: EdgeInsets.all(8.0),
          child: RefreshIndicator(
              onRefresh: () async {
                updateWidgetState();
              },
              child: ListView(children: [
                display == true
                    ? ApiDataDisplay(
                        latitude,
                        longitude,
                        airQualityIndex,
                        lastModification,
                        stationAddress,
                        stationUpdateTime,
                        humidity,
                        pressure,
                        temperature,
                        indexColor)
                    : Center(
                        child: Column(children: [
                          Text(
                              'Data will be available soon.\nSwipe down to refresh the application.',
                              style: new TextStyle(
                                  color: Colors.green, fontSize: 20.0)),
                          Tooltip(
                            message:
                                'Data displayed might be less accurate at first due to missing permission to access the location.\n If you encounter such issues please provide permission and restart the application several times.',
                            child: FlatButton(
                              minWidth: 100,
                              child: Icon(
                                Icons.info_outline,
                                size: 20,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        ]),
                      ),
                Padding(padding: EdgeInsets.only(top: 6.0)),
                IndexTableAndLegend(),
                Padding(padding: EdgeInsets.only(top: 6.0)),
                WaqiLinkDisplay(latitude, longitude)
              ]))),
    );
  }

  updateWidgetState() {
    String aqiIndex;
    String readLatitude;
    String readLongitude;
    String dateString;
    String stationAddressFound;
    String stationUpdateTimeFound;
    String humidityFound;
    String pressureFound;
    String temperatureFound;
    api.getWaqiValuesMap().then((nativeAppData) => {
          print('Data from main app'),
          aqiIndex = nativeAppData["airQualityIndex"],
          readLatitude = nativeAppData["latitude"],
          readLongitude = nativeAppData["longitude"],
          if (readLongitude == null ||
              readLongitude.isEmpty ||
              readLongitude == 'error')
            {readLongitude = 'NaN'},
          if (readLatitude == null ||
              readLatitude.isEmpty ||
              readLatitude == 'error')
            {readLatitude = 'NaN'},
          dateString = nativeAppData["dateString"],
          stationAddressFound = nativeAppData["stationAddress"],
          stationUpdateTimeFound = nativeAppData["stationUpdateTime"],
          humidityFound = nativeAppData["humidity"],
          pressureFound = nativeAppData["pressure"],
          temperatureFound = nativeAppData["temperature"],
          print(humidityFound),
          print(pressureFound),
          print(temperatureFound),
          if (aqiIndex != null &&
              aqiIndex.length > 0 &&
              aqiIndex.isNotEmpty &&
              aqiIndex != 'error')
            {
              print('Will display'),
              setState(() {
                latitude = double.parse(readLatitude).toStringAsFixed(2);
                longitude = double.parse(readLongitude).toStringAsFixed(2);
                airQualityIndex = aqiIndex;
                lastModification = dateString;
                indexColor = determineColor(int.parse(aqiIndex));
                stationAddress = stationAddressFound;
                stationUpdateTime = stationUpdateTimeFound;
                humidity = humidityFound;
                pressure = pressureFound;
                temperature = temperatureFound;
                display = true;
              })
            }
          else
            {
              print('Will not display'),
              setState(() {
                display = false;
              })
            },
        });
  }

  determineColor(index) {
    if (index <= 50)
      return Color.fromRGBO(0, 153, 102, 1);
    else if (index <= 100)
      return Color.fromRGBO(255, 222, 51, 1);
    else if (index <= 150)
      return Color.fromRGBO(255, 153, 51, 1);
    else if (index <= 200)
      return Color.fromRGBO(204, 0, 51, 1);
    else if (index <= 300)
      return Color.fromRGBO(102, 0, 153, 1);
    else
      return Color.fromRGBO(126, 0, 35, 1);
  }
}
