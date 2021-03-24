import 'dart:core';

import 'package:flutter/material.dart';

class DataWillDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        Text(
            'Data will be available soon.\nPlease check your internet connection and refresh the application.\n',
            style: new TextStyle(color: Colors.green, fontSize: 20.0)),
        Tooltip(
          message:
              'Please connect to a network for fresh data.\n Data displayed might be less accurate at first due to missing permission to access the location.\n',
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
    );
  }
}
