import 'dart:core';

import 'package:flutter/material.dart';

import 'api.dart';

class LocationServiceHandling extends StatelessWidget {
  Api api;

  LocationServiceHandling(this.api);

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Column(
      children: [
        OutlinedButton(
            // minWidth: MediaQuery.of(context).size.width,
            // padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
            onPressed: () {
              api.startService();
            },
            child: Text("Start Location Updating Service",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold))),
        Padding(padding: EdgeInsets.only(top: 5.0)),
        OutlinedButton(
            // minWidth: MediaQuery.of(context).size.width,
            // padding: EdgeInsets.fromLTRB(10.0, 5.0, 10.0, 5.0),
            onPressed: () {
              api.stopService();
            },
            child: Text("Stop Updating Service",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.green, fontWeight: FontWeight.bold)))
      ],
    ));
  }
}
