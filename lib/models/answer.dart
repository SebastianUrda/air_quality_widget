class Answer{
  double latitude;
  double longitude;
  DateTime date;
  int answer;
  String questionUID;
  String userUID;


  Answer(this.latitude, this.longitude, this.date, this.answer,
      this.questionUID, this.userUID);

  Map<String,dynamic> toJson()=>{
    'latitude':latitude,
    'longitude':longitude,
    'date':date.toIso8601String().split(".")[0]+"Z",
    'answer':answer,
    'questionUID':questionUID,
    'userUID':userUID
  };

  @override
  String toString() {
    return 'Answer{latitude: $latitude, longitude: $longitude, date: $date, answer: $answer, questionUID: $questionUID, userUID: $userUID}';
  }
}