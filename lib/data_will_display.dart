import 'dart:core';

import 'package:flutter/material.dart';

class DataWillDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(children: [
        Text(
            'Data will be available soon.\nPlease check your internet connection and swipe down to refresh the application.\n',
            style: new TextStyle(color: Colors.green, fontSize: 20.0))
      ]),
    );
  }
}
