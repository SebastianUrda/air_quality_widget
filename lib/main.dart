import 'dart:core';
import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_air_quality_widget/api_data_display.dart';
import 'package:flutter_air_quality_widget/questionnaire_type.dart';
import 'package:flutter_air_quality_widget/register.dart';
import 'package:flutter_air_quality_widget/table_with_legend.dart';

import 'api.dart';
import 'data_will_display.dart';
import 'models/user_data.dart' as UserData;

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  String authenticationUID = await Api.getCurrentUserUIDOrLoginAnonymously();
  runApp(MaterialApp(
    title: 'Air Quality Index Application',
    theme: ThemeData(
      primarySwatch: Colors.blue,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
    home: MyHomePage(
        title: 'Air Quality Index Application', userUID: authenticationUID),
  ));
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title, this.userUID}) : super(key: key);
  final String title;
  final String userUID;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  String latitude = 'NaN';
  String longitude = 'NaN';
  String airQualityIndex;
  String lastModification;
  String stationAddress;
  String stationUpdateTime;
  String humidity;
  String pressure;
  String temperature;
  Color indexColor = Colors.black;
  bool display = false;
  bool isLoading = false;
  Api api = new Api();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initiliseWidgetState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // user returned to our app
      initiliseWidgetState();
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
        actions: <Widget>[
          PopupMenuButton<String>(
            onSelected: contextMenuClick,
            itemBuilder: (BuildContext context) {
              return {'More Info', 'Questionnaire', 'User Data'}
                  .map((String choice) {
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(8.0),
              child: RefreshIndicator(
                  onRefresh: () async {
                    updateWidgetState();
                  },
                  child: ListView(children: [
                    display
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
                        : DataWillDisplay(),
                    Card(
                        child: Column(
                      children: [
                        OutlinedButton(
                            // minWidth: MediaQuery.of(context).size.width,
                            // padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                            onPressed: () {
                              updateLocationAndRefreshState();
                            },
                            child: Text("Set current location",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.only(top: 5.0)),
                        OutlinedButton(
                            // minWidth: MediaQuery.of(context).size.width,
                            // padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                            onPressed: () {
                              api.startService();
                            },
                            child: Text("Start location updating service",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold))),
                        Padding(padding: EdgeInsets.only(top: 5.0)),
                        OutlinedButton(
                            // minWidth: MediaQuery.of(context).size.width,
                            // padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
                            onPressed: () {
                              api.stopService();
                            },
                            child: Text("Stop updating service",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold)))
                      ],
                    )),
                    Padding(padding: EdgeInsets.only(top: 4.0))
                  ]))),
    );
  }

  initiliseWidgetState() {
    String aqiIndex;
    String readLatitude;
    String readLongitude;
    String dateString;
    String stationAddressFound;
    String stationUpdateTimeFound;
    String humidityFound;
    String pressureFound;
    String temperatureFound;
    api
        .getWaqiValuesMap()
        .then((nativeAppData) => {
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
              if (aqiIndex != null &&
                  aqiIndex.length > 0 &&
                  aqiIndex.isNotEmpty &&
                  aqiIndex != 'error')
                {
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
                    isLoading = false;
                  })
                }
              else
                {
                  setState(() {
                    display = false;
                  })
                },
            })
        .catchError((error) => {
              print('ERROR ' + error.toString()),
              setState(() {
                display = false;
              })
            });
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
    api
        .getAirQualityIndex(latitude, longitude)
        .then((nativeAppData) => {
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
              if (aqiIndex != null &&
                  aqiIndex.length > 0 &&
                  aqiIndex.isNotEmpty &&
                  aqiIndex != 'error')
                {
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
                    isLoading = false;
                  })
                }
              else
                {
                  setState(() {
                    display = false;
                  })
                },
            })
        .catchError((error) => {
              print('ERROR ' + error.toString()),
              setState(() {
                display = false;
              })
            });
  }

  updateLocationAndRefreshState() async {
    setLoading(true);
    api.getLocation().then((currentLocation) => {
          setState(() {
            latitude = currentLocation.latitude.toString();
            longitude = currentLocation.longitude.toString();
          }),
          api.setCurrentLocationFromFlutter(latitude, longitude),
          updateWidgetState(),
        });
  }

  setLoading(bool state) => setState(() => {isLoading = state});

  Future<void> contextMenuClick(String value) async {
    switch (value) {
      case 'More Info':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    IndexTableAndLegend(latitude, longitude)));
        break;
      case 'Questionnaire':
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    QuestionnairePicker(userUID: widget.userUID)));
        break;
      case 'User Data':
        UserData.User user = await Api.getCurrentUserWithData(widget.userUID);
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Register(
                    userUID: widget.userUID,
                    gender: user.gender,
                    birthday: user.birthday,
                    givenMail: user.email)));
        break;
    }
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
