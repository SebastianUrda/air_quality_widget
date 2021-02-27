import 'package:flutter/material.dart';

import 'models/question.dart';

class QuestionAdapter extends StatefulWidget {
  Question question;
  final void Function(Question question, int answer) updateAnswer;

  QuestionAdapter({this.question, this.updateAnswer});

  @override
  _QuestionAdapter createState() => _QuestionAdapter(question: this.question);
}

class _QuestionAdapter extends State<QuestionAdapter> {
  Question question;
  double answer = 0;

  _QuestionAdapter({this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
        margin: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 0),
        child: ExpansionTile(
          title: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  question.text,
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 6.0),
              ],
            ),
          ),
          children: <Widget>[
            FittedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Container(
                      width: 300,
                      child: question.possibleAnswers == null
                          ? Slider(
                              value: answer,
                              min: -5,
                              max: 5,
                              divisions: 10,
                              onChanged: (double newValue) {
                                setState(() {
                                  answer = newValue;
                                });
                                widget.updateAnswer(question, newValue.toInt());
                              },
                            )
                          : (question.possibleAnswers.length < 3
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: question.possibleAnswers
                                      .map((item) =>
                                          new Column(children: <Widget>[
                                            new Text(item['ans']),
                                            new Radio(
                                                value: item['value'].toInt(),
                                                groupValue: answer,
                                                onChanged: (value) {
                                                  setState(() {
                                                    answer = value.toDouble();
                                                  });
                                                  widget.updateAnswer(
                                                      question, value);
                                                })
                                          ]))
                                      .toList())
                              : Column(
                                  children: question.possibleAnswers
                                      .map((item) =>
                                          new Column(children: <Widget>[
                                            new Text(item['ans']),
                                            new Radio(
                                                value: item['value'].toInt(),
                                                groupValue: answer,
                                                onChanged: (value) {
                                                  setState(() {
                                                    answer = value.toDouble();
                                                  });
                                                  widget.updateAnswer(
                                                      question, value);
                                                })
                                          ]))
                                      .toList()))),
                ],
              ),
            )
          ],
        ));
  }
}
