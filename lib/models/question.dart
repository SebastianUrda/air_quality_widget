class Question {
  String uid;
  String text;
  int answer;
  List possibleAnswers;

  Question({this.uid, this.text, this.answer, this.possibleAnswers});

  factory Question.fromJson(Map<String, dynamic> parsedJson) {
    return new Question(
        uid: parsedJson['id'],
        text: parsedJson['text'],
        possibleAnswers: parsedJson['possibleAnswers'],
        answer: 0);
  }

  @override
  String toString() {
    return 'Question{id: $uid, text: $text, answer: $answer}';
  }
}
