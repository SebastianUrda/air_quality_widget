import 'dart:core';

import 'package:flutter/material.dart';

class IndexTableAndLegend extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('Colour codes and values legend',
          style: new TextStyle(color: Colors.green, fontSize: 15.0)),
      Padding(padding: EdgeInsets.only(top: 6.0)),
      Table(
        border: TableBorder.lerp(
            TableBorder(top: BorderSide(width: 2, color: Colors.blue)),
            TableBorder(bottom: BorderSide(width: 2, color: Colors.green)),
            0.5),
        columnWidths: {0: IntrinsicColumnWidth(), 1: IntrinsicColumnWidth()},
        children: [
          TableRow(children: [
            TableCell(
              child: Center(
                child: Text("Air Quality Index range", textScaleFactor: 1.5),
              ),
            ),
            TableCell(
              child: Center(
                child: Text("Nominal quality", textScaleFactor: 1.5),
              ),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: Container(
                color: Color.fromRGBO(0, 153, 102, 1),
                child: Text("0-50", textScaleFactor: 1.5),
              ),
            ),
            TableCell(
              child: Container(
                color: Color.fromRGBO(0, 153, 102, 1),
                child: Text("Good", textScaleFactor: 1.5),
              ),
            ),
          ]),
          TableRow(children: [
            TableCell(
              child: Container(
                color: Color.fromRGBO(255, 222, 51, 1),
                child: Text("51-100", textScaleFactor: 1.5),
              ),
            ),
            TableCell(
              child: Container(
                color: Color.fromRGBO(255, 222, 51, 1),
                child: Text("Moderate", textScaleFactor: 1.5),
              ),
            )
          ]),
          TableRow(children: [
            TableCell(
                child: Container(
              color: Color.fromRGBO(255, 153, 51, 1),
              child: Text("101-150\n", textScaleFactor: 1.5),
            )),
            TableCell(
                child: Container(
              color: Color.fromRGBO(255, 153, 51, 1),
              child:
                  Text("Unhealthy for Sensitive Groups", textScaleFactor: 1.5),
            ))
          ]),
          TableRow(children: [
            TableCell(
              child: Container(
                color: Color.fromRGBO(204, 0, 51, 1),
                child: Text("151-200", textScaleFactor: 1.5),
              ),
            ),
            TableCell(
              child: Container(
                color: Color.fromRGBO(204, 0, 51, 1),
                child: Text("Unhealthy", textScaleFactor: 1.5),
              ),
            )
          ]),
          TableRow(children: [
            TableCell(
              child: Container(
                color: Color.fromRGBO(102, 0, 153, 1),
                child: Text("201-300", textScaleFactor: 1.5),
              ),
            ),
            TableCell(
              child: Container(
                color: Color.fromRGBO(102, 0, 153, 1),
                child: Text("Very Unhealthy", textScaleFactor: 1.5),
              ),
            )
          ]),
          TableRow(children: [
            TableCell(
              child: Container(
                color: Color.fromRGBO(126, 0, 35, 1),
                child: Text("300+", textScaleFactor: 1.5),
              ),
            ),
            TableCell(
              child: Container(
                color: Color.fromRGBO(126, 0, 35, 1),
                child: Text("Hazardous", textScaleFactor: 1.5),
              ),
            )
          ]),
        ],
      )
    ]);
  }
}
