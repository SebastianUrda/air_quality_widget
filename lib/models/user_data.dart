class User {
  String UID;
  String email;
  String gender;
  String birthday;

  User(this.email, this.gender, this.birthday);

  User.toReturn(this.UID, this.email, this.gender, this.birthday);

  User.register(
      {String username,
      String password,
      String email,
      String gender,
      String birthday}) {
    this.email = email;
    this.gender = gender;
    this.birthday = birthday;
  }

  Map<String, dynamic> toJson() =>
      {'email': email, 'gender': gender, 'birthday': birthday};

  factory User.fromJson(Map<String, dynamic> json) {
    return new User(json['email'], json['sex'], json['birthday']);
  }

  @override
  String toString() {
    return 'User{UID: $UID, email: $email, gender: $gender, birthday: $birthday}';
  }
}
