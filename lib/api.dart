import 'dart:collection';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:location/location.dart';

import 'models/answer.dart';
import 'models/user_data.dart' as UserData;

class Api {
  static const platform = const MethodChannel('air.quality.widget');

  //    "https://api.waqi.info/feed/geo:" + latitude + ";" + longitude + "/?token=2af09b666411b6719ba2528edaba5f126f6fdfa3"
  Future getAirQualityIndex(latitude, longitude) async {
    var currentLocationFromSharedPrefs =
        await getLocationFromSharedPreferences();
    if (latitude == 'NaN' && longitude == 'NaN') {
      latitude = currentLocationFromSharedPrefs["latitude"];
      longitude = currentLocationFromSharedPrefs["longitude"];
    }
    setCurrentLocationFromFlutter(latitude, longitude);
    var url;
    if (latitude != null &&
        longitude != null &&
        latitude != 'NaN' &&
        longitude != 'NaN' &&
        latitude != 'error' &&
        longitude != 'error') {
      url = 'https://api.waqi.info/feed/geo:' +
          latitude +
          ';' +
          longitude +
          '/?token=2af09b666411b6719ba2528edaba5f126f6fdfa3';
    } else {
      url =
          'https://api.waqi.info/feed/here/?token=2af09b666411b6719ba2528edaba5f126f6fdfa3';
    }

    var response = await http.get(url);
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    return mapApiDataToNativeAppData(jsonResponse, latitude, longitude);
  }

  Future getLocationFromSharedPreferences() async {
    Map toReturn;
    try {
      toReturn = await platform.invokeMethod('getCurrentLocation');
    } on PlatformException catch (e) {
      print("Failed to get shared pref data level: '${e.message}'.");
    }
    return toReturn;
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

  mapApiDataToNativeAppData(apiJsonResponse, latitude, longitude) {
    Map<String, dynamic> toDisplay = new HashMap<String, dynamic>();
    toDisplay.putIfAbsent(
        "airQualityIndex", () => apiJsonResponse["data"]["aqi"].toString());
    toDisplay.putIfAbsent("stationAddress",
        () => apiJsonResponse["data"]["city"]["name"].toString());
    toDisplay.putIfAbsent("stationUpdateTime",
        () => apiJsonResponse["data"]["time"]["s"].toString());
    toDisplay.putIfAbsent(
        "humidity", () => apiJsonResponse["data"]["iaqi"]["h"]["v"].toString());
    toDisplay.putIfAbsent(
        "pressure", () => apiJsonResponse["data"]["iaqi"]["p"]["v"].toString());
    toDisplay.putIfAbsent("temperature",
        () => apiJsonResponse["data"]["iaqi"]["t"]["v"].toString());
    toDisplay.putIfAbsent(
        "dateString", () => DateFormat.jm().format(DateTime.now()));
    toDisplay.putIfAbsent("latitude", () => latitude);
    toDisplay.putIfAbsent("longitude", () => longitude);
    return toDisplay;
  }

  startService() {
    try {
      platform.invokeMethod('startLocationUpdates');
    } on PlatformException catch (e) {
      print("Failed to invoke : '${e.message}'.");
    }
  }

  stopService() {
    try {
      platform.invokeMethod('stopLocationUpdates');
    } on PlatformException catch (e) {
      print("Failed to invoke : '${e.message}'.");
    }
  }

  setCurrentLocationFromFlutter(latitude, longitude) {
    try {
      platform.invokeMethod(
          'setCurrentLocation', {"latitude": latitude, "longitude": longitude});
    } on PlatformException catch (e) {
      print("Failed to get shared pref after location update: '${e.message}'.");
    }
  }

   Future getLocation() async {
    var location = new Location();
    return location.getLocation();
  }

  static String generateMd5(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

//Firebase Implementation
  static Future signIn(email, password) {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, password: generateMd5(password));
  }

  static Future setDataToUser(UserData.User toRegister, String uid) {
    return FirebaseFirestore.instance
        .collection("anonymousUsers")
        .doc(uid)
        .set({
      'email': toRegister.email,
      'birthday': toRegister.birthday,
      'gender': toRegister.gender,
    });
  }

  static Future getCurrentUserUIDOrLoginAnonymously() async {
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    return FirebaseAuth.instance.currentUser.uid;
  }

  static Future getCurrentUserWithData(String userUID) async {
    try {
      DocumentSnapshot currentUserData = await FirebaseFirestore.instance
          .collection("anonymousUsers")
          .doc(userUID)
          .get();
      UserData.User toReturn = UserData.User.toReturn(
          userUID,
          currentUserData.data()['email'],
          currentUserData.data()['gender'],
          currentUserData.data()['birthday']);
      return toReturn;
    } catch (error) {
      print("Failed to get user data '${error}'.");
      UserData.User toReturn =
          UserData.User.toReturn(userUID, "", "", DateTime.now().toString());
      return toReturn;
    }
  }

  static Future signOut() {
    return FirebaseAuth.instance.signOut();
  }

  static Future getFireBaseQuestions(type) {
    return FirebaseFirestore.instance
        .collection("questions")
        .where('type', isEqualTo: type)
        .get();
  }

  static Future sendAnswersToFireBase(List<Answer> answers) {
    return FirebaseFirestore.instance.runTransaction((transaction) {
      answers.forEach((answer) {
        FirebaseFirestore.instance
            .collection("anonymousUsersAnswers")
            .add(answer.toJson());
      });
    });
  }
}
