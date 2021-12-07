import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'login.dart';

void main() => runApp(UpdatePassword());

class UpdatePassword extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainUpdatePassword(),
    );
  }
}

class MainUpdatePassword extends StatefulWidget {
  final String? userid;
  MainUpdatePassword({Key? key, this.userid}) : super(key: key);

  @override
  State createState() => new UpdatePasswordState();
}

class UpdatePasswordState extends State<MainUpdatePassword>
    with TickerProviderStateMixin {
  late AnimationController _iconanimcontroller;
  late Animation<double> _iconanim;
  late ProgressDialog pr;
  late AnimationController _animcon;
  @override
  void initState() {
    _animcon = new AnimationController(
      vsync: this,
      duration: new Duration(
        milliseconds: 1000,
      ),
    );
    _animcon.addStatusListener((status) {
      switch (status) {
        case AnimationStatus.completed:
          _animcon.reverse();
          break;
        case AnimationStatus.dismissed:
          _animcon.forward();
          break;
        case AnimationStatus.forward:
          break;
        case AnimationStatus.reverse:
          break;
      }
    });
    _animcon.forward();
    super.initState();
    _iconanimcontroller = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 1000));

    _iconanim =
        new CurvedAnimation(parent: _iconanimcontroller, curve: Curves.easeOut);
    _iconanim.addListener(() => this.setState(() {}));
    _iconanimcontroller.forward();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  late SharedPreferences sharedpref;
  bool isButtonEnabled = true, _diagvisibility = false;
  String user = '',
      password = '',
      message = '',
      _secqn = '',
      _secan = '',
      _pin = '';
  final _formkey = GlobalKey<FormState>();

  Color? primarycolor = Color.fromRGBO(0, 0, 11, 1);
  enableButton() {
    setState(() {
      isButtonEnabled = true;
      primarycolor = Color.fromRGBO(0, 0, 11, 1);
    });
  }

  disableButton() {
    setState(() {
      isButtonEnabled = false;
      primarycolor = Colors.grey;
    });
  }

  String _serveresponse = '';

  bool pressed = false, _obscuretext = false, _visibility = false;

  late SnackBar snackBar;

  void _showsnackbar(String _message, String _command) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    snackBar = SnackBar(
      duration: const Duration(minutes: 5),
      content: Text(_message),
      action: SnackBarAction(
        label: _command,
        onPressed: () {
          if (_command.contains("Close")) {
          } else if (_command.contains("Retry")) {}
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    _animcon.dispose();
    _iconanimcontroller.dispose();
    super.dispose();
  }

  updatepassword(userid, pw, secqn, secans, pin) async {
    var url = "http://www.emkapp.com/emkapp/resetpassword.php";
    var bdata = {
      "user": user,
      "password": password,
      "updatepassword": "",
      "secqn": secqn,
      "secans": secans,
      "pin": pin
    };
    FormData fdata = FormData.fromMap(bdata);
    setState(() {
      _diagvisibility = true;
    });

    BaseOptions options = new BaseOptions(
      baseUrl: "http://www.emkapp.com/emkapp",
      connectTimeout: 5000,
      receiveTimeout: 3000,
    );

    Dio dio = new Dio(options);

    try {
      var response = await dio.post(url, data: fdata);
      print(response.data);
      if (jsonDecode(response.data).toString().contains("error")) {
        _showsnackbar("Error resetting password!", "Close");

        setState(() {
          _diagvisibility = false;
        });
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LoginPage()));
        _showsnackbar("Operation was successful", "Close");
      }
    } on DioError catch (ex) {
      _showsnackbar("Error : " + ex.message, "Close");
      if (mounted)
        setState(() {
         _diagvisibility = false;
        });
      enableButton();
      throw Exception(ex.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return new Scaffold(resizeToAvoidBottomInset: false,
        
        body: new GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Center(
            child: new Container(
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.height * 1,
              padding: const EdgeInsets.only(bottom: 0),
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                image: new ExactAssetImage('assets/images/cars_0045.jpg'),
                fit: BoxFit.fill,
              )),
              child: new BackdropFilter(
                filter: new ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: new Container(
                  width: MediaQuery.of(context).size.width * 1,
                  height: MediaQuery.of(context).size.height * 1,
                  decoration:
                      new BoxDecoration(color: Colors.black.withOpacity(0.4)),
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottom),
                      child: new Stack(children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(30.0),
                          child: new Form(
                            key: _formkey,
                            child: Theme(
                                data: new ThemeData(
                                  brightness: Brightness.dark,
                                  primarySwatch: Colors.amber,
                                  inputDecorationTheme:
                                      new InputDecorationTheme(
                                    labelStyle: new TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                child: Center(
                                  child: ListView(shrinkWrap: true, children: <
                                      Widget>[
                                    new Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10)),
                                    new Image.asset(
                                      'assets/images/CSI3.png',
                                      width: _iconanim.value * 100,
                                      height: _iconanim.value * 100,
                                    ),
                                    new Padding(
                                        padding:
                                            const EdgeInsets.only(top: 60)),
                                    new TextFormField(
                                      decoration: new InputDecoration(
                                        labelText: "Enter user id here",
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'This field is required';
                                        } else {
                                          return null;
                                        }
                                      },
                                      onSaved: (newValue) {
                                        setState(() {
                                          user = newValue!;
                                        });
                                      },
                                      keyboardType: TextInputType.text,
                                    ),
                                    new Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10)),
                                    new TextFormField(
                                      decoration: new InputDecoration(
                                        labelText: "Enter new password here",
                                        suffixIcon: IconButton(
                                          icon: Padding(
                                            padding: EdgeInsets.all(3),
                                            child: pressed == true
                                                ? Icon(Icons
                                                    .visibility_off_rounded)
                                                : Icon(
                                                    Icons.visibility_rounded),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              pressed = !pressed;
                                              _obscuretext = !_obscuretext;
                                            });
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'This field is required';
                                        } else if (value.length < 5) {
                                          return 'Password cannot be less than 5 characters';
                                        } else {
                                          return null;
                                        }
                                      },
                                      onSaved: (newValue) {
                                        setState(() {
                                          password = newValue!;
                                        });
                                      },
                                      keyboardType: TextInputType.text,
                                      obscureText: !_obscuretext,
                                    ),
                                    new Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10)),
                                    new TextFormField(
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [
                                        FilteringTextInputFormatter.digitsOnly,
                                        new LengthLimitingTextInputFormatter(4)
                                      ],
                                      decoration: new InputDecoration(
                                        hintText: "Enter your 4-digit pin here",
                                        border: InputBorder.none,
                                        suffixIcon: IconButton(
                                          icon: Padding(
                                            padding: EdgeInsets.all(3),
                                            child: pressed == true
                                                ? Icon(Icons
                                                    .visibility_off_rounded)
                                                : Icon(
                                                    Icons.visibility_rounded),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              pressed = !pressed;
                                              _obscuretext = !_obscuretext;
                                            });
                                          },
                                        ),
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'This field is required';
                                        } else if (value.length < 4) {
                                          return 'Pin code cannot be less than 4 digits';
                                        } else if (value.length > 4) {
                                          return 'Pin code cannot be more than 4 digits';
                                        } else {
                                          return null;
                                        }
                                      },
                                      onSaved: (newValue) {
                                        setState(() {
                                          _pin = newValue!;
                                        });
                                      },
                                      obscureText: !_obscuretext,
                                    ),
                                    new DropdownButtonFormField(
                                        value: _secqn,
                                        decoration: new InputDecoration(
                                          labelText: "Security Question",
                                        ),
                                        isExpanded: true,
                                        items: <String>[
                                          '',
                                          'City or town you spent the early part of your childhood in.',
                                          'Favourite sport',
                                          'Favourite team',
                                          'First school attended',
                                          'Name of childhood bestfriend',
                                          'Name of favourite pet',
                                          'Nickname of your bestfriend',
                                          'Favourite musician or actor/actress'
                                        ].map((String value) {
                                          return new DropdownMenuItem<String>(
                                              value: value,
                                              child: new Text(value));
                                        }).toList(),
                                        validator: (value) => value == null
                                            ? 'This field is required'
                                            : null,
                                        onSaved: (newValue) {
                                          setState(() {
                                            _secqn = newValue.toString();
                                          });
                                        },
                                        onChanged: (newValue) {
                                          setState(() {
                                            _secqn = newValue.toString();
                                          });
                                        }),
                                    new Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10)),
                                    new TextFormField(
                                      decoration: new InputDecoration(
                                        labelText: "Enter answer here",
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'This field is required';
                                        } else {
                                          return null;
                                        }
                                      },
                                      onSaved: (newValue) {
                                        setState(() {
                                          _secan = newValue!;
                                        });
                                      },
                                      keyboardType: TextInputType.text,
                                    ),
                                    new Padding(
                                        padding:
                                            const EdgeInsets.only(top: 42)),
                                    FractionallySizedBox(
                                      widthFactor: 0.60,
                                      child: new RaisedButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            side: BorderSide(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.09),
                                                width: 3),
                                          ),
                                          color: primarycolor,
                                          textColor: Colors.white,
                                          child: new Text(
                                            "Reset Password",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                          onPressed: () {
                                            if (isButtonEnabled) {
                                              final form =
                                                  _formkey.currentState;
                                              if (form!.validate()) {
                                                form.save();
                                                message =
                                                    'Please wait, request is being processed...';
                                                updatepassword(user, password,
                                                    _secqn, _secan, _pin);
                                                _showsnackbar(message, "");
                                                //disableButton();
                                                setState(() {
                                                  _visibility = _visibility;
                                                });
                                              }
                                            }
                                          }),
                                    ),
                                    Visibility(
                                      visible: !_visibility,
                                      child: new Padding(
                                          padding:
                                              const EdgeInsets.only(top: 75)),
                                    ),
                                    Visibility(
                                      visible: !_visibility,
                                      child: new Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: <Widget>[
                                          new Text(
                                            "",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'serif',
                                              fontWeight: FontWeight.w500,
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 1),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ]),
                                )),
                          ),
                        ),
                        Visibility(
                          visible: _diagvisibility,
                          child: new Container(
                            width: MediaQuery.of(context).size.width,
                            height: MediaQuery.of(context).size.height,
                            color: Color.fromRGBO(0, 0, 0, 0.7),
                            child: Center(
                              child: new AnimatedBuilder(
                                  animation: _animcon,
                                  builder: (context, child) {
                                    return Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.3,
                                      height:
                                          MediaQuery.of(context).size.width *
                                              0.3,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, .2),
                                              width: _animcon.value * 10),
                                          borderRadius: BorderRadius.circular(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.8)),
                                      child: Image.asset(
                                        'assets/images/CSI3.png',
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        height:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                      ),
                                    );
                                  }),
                            ),
                          ),
                        )
                      ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
