import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'models/question.dart';

class RatingAdapter extends StatefulWidget {
  Question question;
  final void Function(Question question, double answer) updateAnswer;

  RatingAdapter({this.question, this.updateAnswer});

  @override
  _RatingAdapter createState() => _RatingAdapter();
}

class _RatingAdapter extends State<RatingAdapter> {
  double _rating;
  double _initialRating = 3.0;
  bool _isVertical = false;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                Text(widget.question.text),
                Padding(padding: EdgeInsets.only(top: 2.0)),
                RatingBar.builder(
                  initialRating: _initialRating,
                  direction: _isVertical ? Axis.vertical : Axis.horizontal,
                  itemCount: 5,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, index) {
                    switch (index) {
                      case 0:
                        return Icon(
                          Icons.sentiment_very_dissatisfied,
                          color: Colors.red,
                        );
                      case 1:
                        return Icon(
                          Icons.sentiment_dissatisfied,
                          color: Colors.redAccent,
                        );
                      case 2:
                        return Icon(
                          Icons.sentiment_neutral,
                          color: Colors.amber,
                        );
                      case 3:
                        return Icon(
                          Icons.sentiment_satisfied,
                          color: Colors.lightGreen,
                        );
                      case 4:
                        return Icon(
                          Icons.sentiment_very_satisfied,
                          color: Colors.green,
                        );
                      default:
                        return Container();
                    }
                  },
                  onRatingUpdate: (rating) {
                    print(rating);
                    widget.updateAnswer(widget.question, rating);
                    setState(() {
                      _rating = rating;
                    });
                  },
                  updateOnDrag: true,
                )
              ],
            )));
  }
}
