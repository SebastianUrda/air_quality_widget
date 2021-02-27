import 'package:flutter/material.dart';

import 'api.dart';
import 'models/user_data.dart';

class Register extends StatefulWidget {
  String userUID;
  String gender;
  String birthday;
  String givenMail;

  Register({this.userUID, this.gender, this.birthday, this.givenMail});

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool male ;
  bool female;
  String email;
  DateTime selectedBirthDay;
  final TextEditingController _emailController = new TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedBirthDay,
        firstDate: DateTime(1950, 1),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedBirthDay)
      setState(() {
        selectedBirthDay = picked;
      });
  }

  @override
  void initState() {
    super.initState();
    print('init register state');
    print(widget.givenMail);
    setState(() {
      male = widget.gender == 'male' ? true : false;
      female = widget.gender == 'female' ? true : false;
      selectedBirthDay = DateTime.parse(widget.birthday);
      email = widget.givenMail;
      _emailController.text=widget.givenMail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Text('Air Quality Index Application'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Container(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 10.0,
                  ),
                  TextField(
                    obscureText: false,
                    controller: _emailController,
                    onChanged: (text) => setState(() {
                      email = text;
                    }),
                    decoration: InputDecoration(
                        contentPadding:
                            EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        hintText: "Email",
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(32.0))),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Container(
                      padding: EdgeInsets.all(10.0),
                      child: Row(
                        children: <Widget>[
                          Text("Male",
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.normal,
                                  fontSize: 20)),
                          Checkbox(
                            value: male,
                            onChanged: (bool val) => setState(() {
                              male = val;
                              female = !val;
                            }),
                          ),
                          Text("Female",
                              style: TextStyle(
                                  color: Colors.grey[800],
                                  fontWeight: FontWeight.normal,
                                  fontSize: 20)),
                          Checkbox(
                            value: female,
                            onChanged: (bool val) => setState(() {
                              female = val;
                              male = !val;
                            }),
                          )
                        ],
                      )),
                  Container(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      children: <Widget>[
                        MaterialButton(
                          onPressed: () => _selectDate(context),
                          color: Color(0xff01A0C7),
                          textColor: Colors.white,
                          child: Icon(
                            Icons.calendar_today,
                            size: 18,
                          ),
                          padding: EdgeInsets.all(14),
                          shape: CircleBorder(),
                        ),
                        Text("Birthday "),
                        Text("${selectedBirthDay.toLocal()}".split(' ')[0],
                            style: TextStyle(
                                color: Colors.grey[800],
                                fontWeight: FontWeight.normal,
                                fontSize: 14)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(30.0),
                      color: Color(0xff01A0C7),
                      child: MaterialButton(
                        minWidth: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        onPressed: () {
                          RegExp dateRegEx = new RegExp(
                              r"^\d{4}\-(0?[1-9]|1[012])\-(0?[1-9]|[12][0-9]|3[01])$");
                          if (!dateRegEx.hasMatch(
                              "${selectedBirthDay.toLocal()}".split(' ')[0])) {
                            _showMaterialDialog("Fail", "Wrong Date format");
                          }
                          String gender = male ? "male" : "female";

                          User toRegister = User.register(
                              email: email,
                              gender: gender,
                              birthday: "${selectedBirthDay.toLocal()}"
                                  .split(' ')[0]);
                          Api.setDataToUser(toRegister, widget.userUID)
                              .then((value) => _showMaterialDialog(
                                  "Success!", "Data saved successfully!"))
                              .catchError((error) => {
                                    print(error),
                                    _showMaterialDialog(
                                        "Failure!", "Please try again!")
                                  });
                        },
                        child: Text("Save Data",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
                      ))
                ],
              )),
        )));
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
