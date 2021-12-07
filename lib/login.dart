import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:dio/dio.dart';
import 'package:emkapp/admindashboard.dart';
import 'package:emkapp/channeladmindashboard.dart';
import 'package:emkapp/workersdashboard.dart';
import 'package:intl/intl.dart';
import 'package:emkapp/updatepassword.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'resetpassword.dart';
import 'workadmin.dart';

void main() => runApp(LoginPage());

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainLoginPage(),
    );
  }
}

class MainLoginPage extends StatefulWidget {
  @override
  State createState() => new LoginPageState();
}

class LoginPageState extends State<MainLoginPage>
    with TickerProviderStateMixin {
  late AnimationController _iconanimcontroller;
  late Animation<double> _iconanim;
  late ProgressDialog pr;
  late AnimationController _animcon;
  String imgdir = '';
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
    loadfile();
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
  bool isButtonEnabled = true;
  String user = '', password = '', message = '';

  loadfile() async {
    final dir = await (getApplicationDocumentsDirectory());
    imgdir = dir.path + "/EmkappData/";
  }

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
  final _formkey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool pressed = false,
      _obscuretext = false,
      _visibility = false,
      _diagvisibility = false;

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
          } else if (_command.contains("Close")) {
            loginuser(user, password);
          }
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

  void loginuser(String user, String password) async {
    sharedpref = await SharedPreferences.getInstance();
    var url = "http://www.emkapp.com/emkapp/login.php";
    var bdata = {"user": user, "password": password};
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
      if (jsonDecode(response.data)
          .toString()
          .contains("error finding user's credentials")) {
        _showsnackbar("Credentials do not exist!", "Close");

        setState(() {
          _diagvisibility = false;
        });
        enableButton();
      } else if (jsonDecode(response.data).toString().contains("default")) {
        Future.delayed(Duration(seconds: 1)).then((value) {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => WorkAdmin()));
        });
      } else if (jsonDecode(response.data)
          .toString()
          .contains("reset password")) {
        Future.delayed(Duration(seconds: 1)).then((value) {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MainUpdatePassword(
                        userid: user,
                      )));
        });
      } else {
        String _foldername = "EmkappData";
        String _filename = "userconfig.json";
        final Directory _appDir = await getApplicationDocumentsDirectory();
        final Directory _appDirFolder =
            Directory('${_appDir.path}/$_foldername/');
        final configfile = new File(_appDirFolder.path + "/" + _filename);
        final fjson = jsonDecode(await configfile.readAsString());

        print(response.data);
        var date = DateTime.now();
        var sdate =
            DateFormat('EEEE, d MMM yyyy, h:mm a').format(date).toString();

        final json = jsonDecode(response.data)[0];
        final _configcontent = '{"role":"' +
            json['grole'].toString() +
            '","username":"' +
            json['user'].toString() +
            '","logged_in":"true","lockscreen":"true","img":"' +
            json['img'].toString() +
            '","cookiename":"","last_logged_in_at":"' +
            sdate +
            '","uroles":"' +
            json['roles'].toString() +
            '","pin":"' +
            json['pin'].toString() +
            '","pin_enabled":"true","wchannel":"' +
            json['channel'].toString() +
            '","nameofchannel":"' +
            json['channelname'].toString() +
            '","userid":"' +
            json['userid'].toString() +
            '","url":"","lastpage":"0", "password": "' +
            password +
            '"}';
        var usermainrole = json['grole'].toString();
        var _imgfile = json['img'].toString();

        try {
          await configfile.writeAsString(_configcontent);
          Future.delayed(Duration(seconds: 3), () async {
            _showsnackbar("User has been successfully signed in.", "Close");
            if (await File(_appDirFolder.path + "/" + _imgfile).exists()) {
              if (usermainrole == "worker") {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MainWorkersDashboard(
                              opt: "0",
                              rdate: '',
                            )));
              }
              if (usermainrole == "channeladmin") {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MainChannelAdminDashboard(opt: "0", nrdate: '')));
              }
              if (usermainrole == "OAdmin") {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MainAdminDashboard(
                              opt: "0",
                              nrdate: '',
                            )));
              }
              if (usermainrole == "Admin") {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => WorkAdmin()));
              }
            } else {
              var furl = "http://www.emkapp.com/emkapp/imgdata/" + _imgfile;
              var req = await http.get(Uri.parse(furl));
              var filepathname = imgdir + _imgfile;
              File dfile = new File(filepathname);
              dfile.writeAsBytesSync(req.bodyBytes);
              if (usermainrole == "worker") {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MainWorkersDashboard(
                              opt: "0",
                              rdate: '',
                            )));
              }
              if (usermainrole == "channeladmin") {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            MainChannelAdminDashboard(opt: "0", nrdate: '')));
              }
              if (usermainrole == "OAdmin") {
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MainAdminDashboard(
                              opt: "0",
                              nrdate: '',
                            )));
              }
              if (usermainrole == "Admin") {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) => WorkAdmin()));
              }
            }
          });
        } catch (e) {
          _showsnackbar("Error saving user data : $e", "Close");
        }
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

    return new Scaffold(
        resizeToAvoidBottomInset: false,
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
                      new BoxDecoration(color: Colors.black.withOpacity(0.65)),
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
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
                                        labelText: "User ID",
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
                                        labelText: "Password",
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
                                            const EdgeInsets.only(top: 42)),
                                    FractionallySizedBox(
                                      widthFactor: 0.40,
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
                                            "Sign In",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                          onPressed: () {
                                            if (isButtonEnabled) {
                                              final form =
                                                  _formkey.currentState;
                                              if (form!.validate()) {
                                                form.save();
                                                message =
                                                    'Please wait, user is being signed in...';
                                                loginuser(user, password);
                                                _showsnackbar(message, "");
                                                disableButton();
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
                                            "Forgotten Password?",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontFamily: 'serif',
                                              fontWeight: FontWeight.w500,
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 1),
                                            ),
                                          ),
                                          new Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10)),
                                          new GestureDetector(
                                            onTap: () {
                                              Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MainResetPassword(
                                                              userid: "",
                                                              page: "login",
                                                              image: "")));
                                            },
                                            child: new Text(
                                              "Reset Password",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontFamily: 'serif',
                                                fontWeight: FontWeight.bold,
                                                color: Colors.amber,
                                              ),
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
