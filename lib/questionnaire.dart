import 'package:flutter/material.dart';

import 'api.dart';
import 'models/answer.dart';
import 'models/question.dart';
import 'question_adapter.dart';

class Questionnaire extends StatefulWidget {
  List<Question> questions;
  String userUID;

  Questionnaire({this.questions, this.userUID});

  @override
  _Questionnaire createState() => _Questionnaire(questions: questions);
}

class _Questionnaire extends State<Questionnaire> {
  List<Question> questions;
  bool sent = false;
  Api api= new Api();
  _Questionnaire({this.questions});

  updateAnswer(Question question, int answer) {
    setState(() {
      question.answer = answer;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Answer Questions"),
        centerTitle: true,
      ),
      body: Column(children: [
        Container(
            margin: EdgeInsets.all(20.0),
            child: Text("Answer the following questions ",
                style: TextStyle(fontSize: 20))),
        Expanded(
            child: ListView.builder(
          padding: EdgeInsets.all(10),
          itemCount: this.questions.length,
          itemBuilder: (context, index) {
            return QuestionAdapter(
                question: questions[index], updateAnswer: updateAnswer);
          },
        ))
      ]),
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
                  for (Question q in questions) {
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
    );
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
