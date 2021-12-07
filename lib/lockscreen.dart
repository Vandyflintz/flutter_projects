import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:math' show pi;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emkapp/resetpassword.dart';
import 'package:emkapp/workadmin.dart';
import 'package:emkapp/workersdashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'admindashboard.dart';
import 'channeladmindashboard.dart';
import 'login.dart';
import 'resetpin.dart';

void main() => runApp(LockScreen());

class LockScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainLockScreen(
        userimg: '',
      ),
    );
  }
}

class MainLockScreen extends StatefulWidget {
  final String userimg;
  MainLockScreen({Key? key, required this.userimg}) : super(key: key);
  @override
  State createState() => new LockScreenState();
}

class LockScreenState extends State<MainLockScreen>
    with TickerProviderStateMixin {
  late AnimationController _iconanimcontroller;
  late Animation<double> _iconanim;
  late ProgressDialog pr;
  late AnimationController _animcon;
  String user = '', userid = '', _imgname = '', _nimgdir = '', _passw = '';
  late Directory _imgdir;
  late ScrollController scrollController;
  bool dialVisible = true;
  Color hiddencolor = Colors.transparent;
  Color visiblecolor = Color.fromRGBO(0, 0, 10, 1);
  Color visibletextcolor = Colors.white;
  Color hiddentextcolor = Colors.transparent;
  String imgdir = '';
  bool isfavVisible = true;
  @override
  void initState() {
    getuserconfig();
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
    //showbooloption();
    scrollController = ScrollController()
      ..addListener(() {
        setDialVisible(scrollController.position.userScrollDirection ==
            ScrollDirection.forward);
      });
  }

  @override
  void dispose() {
    _animcon.dispose();
    _iconanimcontroller.dispose();
    super.dispose();
  }

  late SharedPreferences sharedpref;
  bool isButtonEnabled = true,
      _diagvisibility = false,
      _pinvisibility = true,
      _passwordvisibility = false,
      _isvisiblebuttonenabled = true,
      _hiddenbuttonenabled = false;
  String username = '',
      configpin = '',
      configpassword = '',
      password = '',
      message = '',
      role = '',
      cookiename = '',
      last_logged_in_at = '',
      uroles = '',
      wchannel = '',
      nameofchannel = '',
      url = '',
      uid = '',
      lp = '';
  final _formkey = GlobalKey<FormState>();
  Color? primarycolor = Color.fromRGBO(0, 0, 11, 1);
  enableButton() {
    setState(() {
      isButtonEnabled = true;
      primarycolor = Color.fromRGBO(0, 0, 11, 1);
    });
  }

  loadfile() async {
    final dir = await (getApplicationDocumentsDirectory());
    imgdir = dir.path + "/EmkappData/";
  }

  disableButton() {
    setState(() {
      isButtonEnabled = false;
      primarycolor = Colors.grey;
    });
  }

  getuserconfig() async {
    final dir = await (getApplicationDocumentsDirectory());

    String _foldername = "EmkappData";
    String _filename = "userconfig.json";
    final Directory _appDir = await getApplicationDocumentsDirectory();
    final Directory _appDirFolder = Directory('${_appDir.path}/$_foldername/');
    _imgdir = Directory('${_appDir.path}/$_foldername/');
    _nimgdir = _imgdir.path;
    if (await File(_appDirFolder.path + "/" + _filename).exists()) {
      final configfile = new File(_appDirFolder.path + "/" + _filename);
      final json = jsonDecode(await configfile.readAsString());
      _imgname = json['img'];
      print("image from json : " + _imgname);
      configpin = json['pin'];
      configpassword = json['password'];
      lp = json['lastpage'];
      setState(() {
        username = json['username'];
      });

      role = json['role'];
      cookiename = json['cookiename'];
      last_logged_in_at = json['last_logged_in_at'];
      uroles = json['uroles'];
      wchannel = json['wchannel'];
      nameofchannel = json['nameofchannel'];
      url = json['url'];
      uid = json['userid'];
      // _showsnackbar(_imgname, "Okay");
    }
  }

  showbooloption() {
    //_showsnackbar(_hiddenbuttonenabled.toString(), "Okay");
    print("bool option : " + _hiddenbuttonenabled.toString());
  }

  String _serveresponse = '';

  bool pressed = false, _obscuretext = false, _visibility = false;

  late SnackBar snackBar;
  double _endval = 2 * pi;
  double _endvalone = 2 * pi;

  void setDialVisible(bool value) {
    setState(() {
      dialVisible = value;
    });
  }

  resetpassword() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MainResetPassword(
                userid: uid, page: "lockscreen", image: widget.userimg)));
  }

  resetpin() {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MainResetPin(userid: uid, image: widget.userimg)));
  }

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

  getfile(String dimgdir, String name) {
    //String lastcharac = name.substring(name.length - 1);
    var fname = name.trimLeft();
    //print("${imgdir}/$name");
    if (File(imgdir + widget.userimg).existsSync()) {
      String imgname = name;

      return Container(
        width: MediaQuery.of(context).size.width * 0.45,
        height: MediaQuery.of(context).size.width * 0.45,
        decoration: BoxDecoration(
            border: Border.all(color: Color.fromRGBO(73, 73, 73, 1), width: 5),
            borderRadius:
                BorderRadius.circular(MediaQuery.of(context).size.width * 0.8),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: FileImage(File(imgdir + widget.userimg)),
            )),
      );
    } else {
      //_showsnackbar(name, "");
      downloadimage(name);

      return Container(
        width: MediaQuery.of(context).size.width * 0.45,
        height: MediaQuery.of(context).size.width * 0.45,
        decoration: BoxDecoration(
            border: Border.all(color: Color.fromRGBO(73, 73, 73, 1), width: 5),
            borderRadius:
                BorderRadius.circular(MediaQuery.of(context).size.width * 0.8),
            image: DecorationImage(
              fit: BoxFit.cover,
              image: CachedNetworkImageProvider(
                  "http://www.emkapp.com/emkapp/imgdata/" + widget.userimg),
            )),
      );

      return Container(
        width: MediaQuery.of(context).size.width * 0.45,
        height: MediaQuery.of(context).size.width * 0.45,
        decoration: BoxDecoration(
            border:
                Border.all(color: Color.fromRGBO(255, 255, 255, .2), width: 5),
            borderRadius: BorderRadius.circular(
                MediaQuery.of(context).size.width * 0.45)),
        child: CachedNetworkImage(
          imageUrl: "http://www.emkapp.com/emkapp/imgdata/" + widget.userimg,
          progressIndicatorBuilder: (context, url, dprogress) =>
              CircularProgressIndicator(
            value: dprogress.progress,
          ),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      );
    }
  }

  downloadimage(String filename) async {
    var url = "http://www.emkapp.com/emkapp/imgdata/" + _imgname;
    var response = await http.get(Uri.parse(url));
    print("image : " + _imgname);
    File file = new File(_nimgdir + _imgname);
    //_showsnackbar(url, "");
    file.writeAsBytesSync(response.bodyBytes);
    print("Image has been downloaded");
  }

  void checkpin(String value) {
    // _showsnackbar(role, "Okay");
    if (configpin == value) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _diagvisibility = false;
        });
        if (role == "worker") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MainWorkersDashboard(
                        opt: lp,
                        rdate: '',
                      )));
        }
        if (role == "channeladmin") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MainChannelAdminDashboard(opt: lp, nrdate: '')));
        }
        if (role == "OAdmin") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MainAdminDashboard(
                        opt: lp,
                        nrdate: '',
                      )));
        }
        if (role == "Admin") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => WorkAdmin()));
        }
      });
    } else {
      setState(() {
        _diagvisibility = false;
        isfavVisible = true;
      });
      _showsnackbar("Pin is incorrect!", "Close");
    }
  }

  void checkpassword(String value) {
    if (configpassword == value) {
      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _diagvisibility = false;
        });
        if (role == "worker") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MainWorkersDashboard(
                        opt: lp,
                        rdate: '',
                      )));
        }
        if (role == "channeladmin") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) =>
                      MainChannelAdminDashboard(opt: lp, nrdate: '')));
        }
        if (role == "OAdmin") {
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => MainAdminDashboard(
                        opt: lp,
                        nrdate: '',
                      )));
        }
        if (role == "Admin") {
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => WorkAdmin()));
        }
      });
    } else {
      Future.delayed(Duration(seconds: 0), () {
        setState(() {
          _diagvisibility = false;
          isfavVisible = true;
        });
      });
      _showsnackbar("Password is incorrect!", "Close");
    }
  }

  SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: Colors.white,
      overlayColor: Color.fromRGBO(255, 255, 255, 0.05),
      animatedIconTheme: IconThemeData(size: 22.0),
      visible: dialVisible,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Visibility(
              visible: _pinvisibility,
              maintainSize: false,
              maintainAnimation: false,
              maintainState: false,
              child: Icon(Icons.reset_tv, color: visibletextcolor)),
          backgroundColor: visiblecolor,
          onTap: () {
            if (_isvisiblebuttonenabled.toString() == "true") {
              resetpin();
            }
          },
          label: 'Reset Pin',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: visibletextcolor),
          labelBackgroundColor: visiblecolor,
        ),
        SpeedDialChild(
          child: Visibility(
              visible: _passwordvisibility,
              maintainSize: false,
              maintainAnimation: false,
              maintainState: false,
              child: Icon(Icons.reset_tv, color: hiddentextcolor)),
          backgroundColor: hiddencolor,
          onTap: () {
            if (_hiddenbuttonenabled.toString() != "false") {
              resetpassword();
            }
          },
          label: 'Reset Password',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: hiddentextcolor),
          labelBackgroundColor: hiddencolor,
        ),
        SpeedDialChild(
          child: Visibility(
              visible: _pinvisibility,
              maintainSize: false,
              maintainAnimation: false,
              maintainState: false,
              child: Icon(Icons.login, color: visibletextcolor)),
          backgroundColor: visiblecolor,
          onTap: () {
            if (_isvisiblebuttonenabled.toString() == "true") {
              setState(() {
                _pinvisibility = false;
                _passwordvisibility = true;
                hiddencolor = Color.fromRGBO(0, 0, 10, 1);
                visiblecolor = Colors.transparent;
                visibletextcolor = Colors.transparent;
                hiddentextcolor = Colors.white;
                _isvisiblebuttonenabled = false;
                _hiddenbuttonenabled = true;
              });
            }
          },
          label: 'Sign in using a password instead',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: visibletextcolor),
          labelBackgroundColor: visiblecolor,
        ),
        SpeedDialChild(
          child: Visibility(
              visible: _passwordvisibility,
              maintainSize: false,
              maintainAnimation: false,
              maintainState: false,
              child: Icon(Icons.login, color: hiddentextcolor)),
          backgroundColor: hiddencolor,
          onTap: () {
            if (_hiddenbuttonenabled.toString() != "false") {
              setState(() {
                _pinvisibility = true;
                _passwordvisibility = false;
                hiddencolor = Colors.transparent;
                visiblecolor = Color.fromRGBO(0, 0, 10, 1);
                visibletextcolor = Colors.white;
                hiddentextcolor = Colors.transparent;
                _isvisiblebuttonenabled = true;
                _hiddenbuttonenabled = false;
              });
            }
          },
          label: 'Sign in using your pin',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: hiddentextcolor),
          labelBackgroundColor: hiddencolor,
        ),
        SpeedDialChild(
          child: Visibility(
              visible: true,
              child: Icon(Icons.logout_rounded, color: Colors.white)),
          backgroundColor: Color.fromRGBO(0, 0, 10, 1),
          onTap: () {
            _showlogoutdialog(context);
          },
          label: 'Log out',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Color.fromRGBO(0, 0, 10, 1),
        ),
      ],
    );
  }

  _showlogoutdialog(BuildContext context) async {
    final dir = await (getApplicationDocumentsDirectory());

    String _foldername = "EmkappData";
    String _filename = "userconfig.json";
    final Directory _appDir = await getApplicationDocumentsDirectory();
    final Directory _appDirFolder = Directory('${_appDir.path}/$_foldername/');
    _imgdir = Directory('${_appDir.path}/$_foldername/');
    _nimgdir = _imgdir.path;

    final configfile = new File(_appDirFolder.path + "/" + _filename);
    final _configcontent = '{"role":"' +
        role +
        '","username":"' +
        username +
        '","logged_in":"false","lockscreen":"false","img":"' +
        _imgname +
        '","cookiename":"' +
        cookiename +
        '","last_logged_in_at":"' +
        last_logged_in_at +
        '","uroles":"' +
        uroles +
        '","pin":"' +
        configpin +
        '","pin_enabled":"true","wchannel":"' +
        wchannel +
        '","nameofchannel":"' +
        nameofchannel +
        '","url":"' +
        url +
        '", "password": "' +
        configpassword +
        '"}';
    Widget cancelbtn = FlatButton(
      onPressed: () {
        Navigator.of(context).pop();
      },
      child: Text("Cancel"),
    );
    Widget continuebtn = FlatButton(
      onPressed: () async {
        try {
          await configfile.writeAsString(_configcontent);
          Future.delayed(Duration(seconds: 3), () async {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
                (Route<dynamic> route) => false);
          });
        } catch (e) {
          _showsnackbar("Error saving user data : $e", "Close");
        }
      },
      child: Text("Continue"),
    );

    AlertDialog alert = AlertDialog(
      title: Text("Warning"),
      content: Text("Sure about logging out?"),
      actions: [cancelbtn, continuebtn],
    );

    return showDialog(
      context: context,
      builder: (context) {
        return alert;
      },
    );
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
                      new BoxDecoration(color: Colors.black.withOpacity(0.4)),
                  child: Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottom),
                      child: new Stack(
                        children: <Widget>[
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
                                      child: ListView(
                                        shrinkWrap: true,
                                        children: <Widget>[
                                          new Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 10)),
                                          Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45) +
                                                  10,
                                              height: (MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45) +
                                                  10,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Color.fromRGBO(
                                                        103, 103, 103, 1),
                                                    width: 10),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.8),
                                              ),
                                              child: Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.45,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.45,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Color.fromRGBO(
                                                            73, 73, 73, 1),
                                                        width: 5),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                0.8),
                                                    image: DecorationImage(
                                                      fit: BoxFit.fill,
                                                      image: FileImage(File(
                                                          imgdir +
                                                              widget.userimg)),
                                                    )),
                                              ),
                                            ),
                                          ),
                                          new Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 40)),
                                          Text(
                                            username,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: 'serif',
                                              fontWeight: FontWeight.bold,
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 1),
                                            ),
                                          ),
                                          new Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 40)),
                                          Visibility(
                                            visible: _pinvisibility,
                                            child: new Container(
                                              padding: EdgeInsets.only(left: 7),
                                              decoration: BoxDecoration(
                                                color:
                                                    Color.fromRGBO(0, 0, 0, .4),
                                                border: Border.all(
                                                    color: Color.fromRGBO(
                                                        73, 73, 73, 1),
                                                    width: 5),
                                              ),
                                              child: new TextFormField(
                                                keyboardType:
                                                    TextInputType.number,
                                                inputFormatters: [
                                                  FilteringTextInputFormatter
                                                      .digitsOnly,
                                                  new LengthLimitingTextInputFormatter(
                                                      4)
                                                ],
                                                onChanged: (value) {
                                                  if (value.length > 3 &&
                                                      value.length < 5) {
                                                    FocusScope.of(context)
                                                        .unfocus();
                                                    setState(() {
                                                      _diagvisibility = true;
                                                      isfavVisible = false;
                                                    });

                                                    checkpin(value);
                                                  }
                                                },
                                                decoration: new InputDecoration(
                                                  hintText: "Enter pin here",
                                                  border: InputBorder.none,
                                                  suffixIcon: IconButton(
                                                    icon: Padding(
                                                      padding:
                                                          EdgeInsets.all(3),
                                                      child: pressed == true
                                                          ? Icon(Icons
                                                              .visibility_off_rounded)
                                                          : Icon(Icons
                                                              .visibility_rounded),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        pressed = !pressed;
                                                        _obscuretext =
                                                            !_obscuretext;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                obscureText: !_obscuretext,
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: _passwordvisibility,
                                            child: new Container(
                                              padding: EdgeInsets.only(left: 7),
                                              decoration: BoxDecoration(
                                                color:
                                                    Color.fromRGBO(0, 0, 0, .4),
                                                border: Border.all(
                                                    color: Color.fromRGBO(
                                                        73, 73, 73, 1),
                                                    width: 5),
                                              ),
                                              child: new TextFormField(
                                                onSaved: (newValue) {
                                                  setState(() {
                                                    _passw = newValue!;
                                                  });
                                                },
                                                keyboardType:
                                                    TextInputType.text,
                                                decoration: new InputDecoration(
                                                  hintText:
                                                      "Enter password here",
                                                  border: InputBorder.none,
                                                  suffixIcon: IconButton(
                                                    icon: Padding(
                                                      padding:
                                                          EdgeInsets.all(3),
                                                      child: pressed == true
                                                          ? Icon(Icons
                                                              .visibility_off_rounded)
                                                          : Icon(Icons
                                                              .visibility_rounded),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        pressed = !pressed;
                                                        _obscuretext =
                                                            !_obscuretext;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'This field is required';
                                                  } else {
                                                    return null;
                                                  }
                                                },
                                                obscureText: !_obscuretext,
                                              ),
                                            ),
                                          ),
                                          Visibility(
                                            visible: _passwordvisibility,
                                            child: new Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 42)),
                                          ),
                                          Visibility(
                                            visible: _passwordvisibility,
                                            child: FractionallySizedBox(
                                              widthFactor: 0.40,
                                              child: new RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    side: BorderSide(
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.09),
                                                        width: 3),
                                                  ),
                                                  color: primarycolor,
                                                  textColor: Colors.white,
                                                  child: new Text(
                                                    "Sign In",
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  ),
                                                  onPressed: () {
                                                    if (isButtonEnabled) {
                                                      FocusScope.of(context)
                                                          .unfocus();
                                                      final form =
                                                          _formkey.currentState;
                                                      if (form!.validate()) {
                                                        form.save();
                                                        message =
                                                            'Please wait, user is being signed in...';

                                                        _showsnackbar(
                                                            message, "");
                                                        checkpassword(_passw);
                                                        //disableButton();
                                                        setState(() {
                                                          _visibility =
                                                              _visibility;
                                                          _diagvisibility =
                                                              true;
                                                          isfavVisible = false;
                                                        });
                                                      }
                                                    }
                                                  }),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ))),
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
                                        width:
                                            MediaQuery.of(context).size.width *
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.5,
                                        ),
                                      );
                                    }),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton:
            Visibility(visible: isfavVisible, child: buildSpeedDial()));
  }
}
