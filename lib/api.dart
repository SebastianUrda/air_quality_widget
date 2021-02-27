import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:location/location.dart';

import 'models/answer.dart';
import 'models/user_data.dart' as UserData;

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

  startService() {
    platform.invokeMethod('startLocationUpdates');
  }

  stopService() {
    platform.invokeMethod('stopLocationUpdates');
  }

  static Future getLocation() async {
    var location = new Location();
    var currentLocation = await location.getLocation();
    return currentLocation;
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
    print(uid);
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
      FirebaseFirestore.instance
          .collection('anonymousUsers')
          .get()
          .then((QuerySnapshot querySnapshot) => {
                querySnapshot.docs.forEach((doc) {
                  print(doc["email"]);
                  print(doc.id);
                })
              });
      DocumentSnapshot currentUserData = await FirebaseFirestore.instance
          .collection("anonymousUsers")
          .doc(userUID)
          .get();
      print(currentUserData.data());
      UserData.User toReturn = UserData.User.toReturn(
          userUID,
          currentUserData.data()['email'],
          currentUserData.data()['gender'],
          currentUserData.data()['birthday']);
      return toReturn;
    } catch (error) {
      print(error);
      UserData.User toReturn =
          UserData.User.toReturn(userUID, "", "", DateTime.now().toString());
      print(toReturn);
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
