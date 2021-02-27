import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'api.dart';
import 'models/question.dart';
import 'questionnaire.dart';

class QuestionnairePicker extends StatelessWidget {
  String userUID;

  QuestionnairePicker({this.userUID});

  Future<List<Question>> getFireBaseQuestions(String type) async {
    QuerySnapshot response = await Api.getFireBaseQuestions(type);
    List<Question> questions = new List<Question>();
    response.docs.forEach((question) {
      questions.add(new Question(
          uid: question.id,
          text: question['text'],
          answer: 0,
          possibleAnswers: question['possibleAnswers'] != null
              ? List.from(question['possibleAnswers'])
              : null));
    });
    return questions;
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(title: Text('Air Quality Index Application')),
        body: Center(
            child: Container(
          padding: EdgeInsets.all(20.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.center,
//              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("Please select the questionnaire type you want to answer!",
                    style: TextStyle(fontSize: 20)),
                SizedBox(height: 20.0),
                Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.blue,
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      onPressed: () {
                        getFireBaseQuestions('temperature').then((questions) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Questionnaire(
                                        questions: questions,
                                        userUID: userUID,
                                      )));
                        });
                      },
                      child: Text("Temperature",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    )),
                SizedBox(
                  height: 10.0,
                ),
                Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.blue,
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      onPressed: () {
                        getFireBaseQuestions('dust').then((questions) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Questionnaire(
                                      questions: questions, userUID: userUID)));
                        });
                      },
                      child: Text("Dust",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    )),
                SizedBox(
                  height: 10.0,
                ),
                Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.blue,
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      onPressed: () {
                        getFireBaseQuestions('humidity').then((questions) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Questionnaire(
                                      questions: questions, userUID: userUID)));
                        });
                      },
                      child: Text("Humidity",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    )),
                SizedBox(
                  height: 10.0,
                ),
                Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(30.0),
                    color: Colors.blue,
                    child: MaterialButton(
                      minWidth: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                      onPressed: () {
                        getFireBaseQuestions('light').then((questions) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Questionnaire(
                                      questions: questions, userUID: userUID)));
                        });
                      },
                      child: Text("Light",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold)),
                    ))
              ]),
        ))));
  }
}
