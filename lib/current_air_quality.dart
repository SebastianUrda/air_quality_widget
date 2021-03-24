import 'package:flutter/material.dart';
import 'package:flutter_air_quality_widget/rating_card.dart';

import 'api.dart';
import 'models/answer.dart';
import 'models/question.dart';

class CurrentAirQualityQuiz extends StatefulWidget {
  List<Question> questions;
  String userUID;

  CurrentAirQualityQuiz({this.questions, this.userUID});

  @override
  _CurrentAirQualityQuiz createState() => _CurrentAirQualityQuiz();
}

class _CurrentAirQualityQuiz extends State<CurrentAirQualityQuiz> {
  bool sent = false;
  Api api = new Api();

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
      appBar: AppBar(
        title: Text('Air Quality Index Application'),
        centerTitle: true,
      ),
      body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(children: [
            Container(
                margin: EdgeInsets.all(20.0),
                child: Text("Answer the following questions ",
                    style: TextStyle(fontSize: 20))),
            Expanded(
                child: ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: widget.questions.length,
              itemBuilder: (context, index) {
                return RatingAdapter(
                    question: widget.questions[index],
                    updateAnswer: updateAnswer);
              },
            ))
          ])),
      floatingActionButton: FloatingActionButton(
        child: Text('Send'),
        onPressed: sent
            ? () {
                _showMaterialDialog(
                    "Fail!", "A set of answers has already been sent.");
              }
            : () {
                setState(() {
                  sent = true;
                });
                List<Answer> answers = new List<Answer>();
                api.getLocation().then((currentLocation) {
                  var currentTime = new DateTime.now();
                  for (Question q in widget.questions) {
                    Answer answer = Answer(
                        currentLocation.latitude,
                        currentLocation.longitude,
                        currentTime,
                        q.answer,
                        q.uid,
                        widget.userUID);
                    answers.add(answer);
                  }

                  Api.sendAnswersToFireBase(answers).then((response) {
                    _showMaterialDialog(
                        "Success!", "Your answers were sent to the server!");
                  }).catchError((error) {
                    print('Error' + error);
                    _showMaterialDialog("Fail!",
                        "There was an error on the way, please send your answers again!");
                  });
                });
              },
      ),
    ));
  }

  updateAnswer(Question question, double answer) {
    setState(() {
      question.answer = answer.toInt();
    });
  }

  void _showMaterialDialog(String title, String text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('${title}'),
            content: Text('${text}'),
            actions: <Widget>[
              FlatButton(
                  onPressed: () {
                    _dismissDialog();
                  },
                  child: Text('Ok')),
            ],
          );
        });
  }

  _dismissDialog() {
    Navigator.pop(context);
  }
}
