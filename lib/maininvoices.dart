import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

import 'lockscreen.dart';
import 'login.dart';

void main() {
  runApp(MainInvoices());
}

class MainInvoices extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
      title: 'EM-KAPP',
      debugShowCheckedModeBanner: false,
      home: MainMainInvoices(),
    );
  }
}

class MainMainInvoices extends StatefulWidget {
  MainMainInvoices({Key? key}) : super(key: key);

  @override
  State createState() => _MainInvoicesState();
}

class _MainInvoicesState extends State<MainMainInvoices>
    with TickerProviderStateMixin {
  late AnimationController _animcon;
  late AnimationController _iconanimcontroller, _fabcon;
  late Animation<double> _iconanim;
  ScrollController _scrollController = ScrollController(keepScrollOffset: true);
  @override
  void initState() {
    _animcon = new AnimationController(
      vsync: this,
      duration: new Duration(
        milliseconds: 1000,
      ),
    );

    _fabcon = new AnimationController(
      vsync: this,
      duration: new Duration(
        milliseconds: 500,
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

    _iconanimcontroller = new AnimationController(
        vsync: this, duration: new Duration(milliseconds: 1000));

    _iconanim =
        new CurvedAnimation(parent: _iconanimcontroller, curve: Curves.easeOut);
    _iconanim.addListener(() => this.setState(() {}));
    _iconanimcontroller.forward();
    _fabcon.forward();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    _animcon.dispose();
    // _iconanimcontroller.dispose();
    super.dispose();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool pressed = false, _obscuretext = false, _visibility = false;

  late SnackBar snackBar;
  bool _diagvisibility = false,
      _emptyconvisibility = true,
      _btnvisibility = false,
      _searchvisibility = false,
      _passwordvisibility = false,
      _isvisiblebuttonenabled = true,
      _hiddenbuttonenabled = false,
      _picvisibility = false,
      _sortvisibility = false,
      _hasSearched = false,
      _detailsvisible = false,
      isfavVisible = true,
      boolTrue = true,
      _submenuVisible = false,
      _filterformvisible = false,
      _cartvisibility = false;
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

  createuserconfig() async {
    String _foldername = "EmkappData";
    String _filecontents =
        '{"userid":"","role":"","username":"","logged_in":"","lockscreen":"","img":"","cookiename":"","last_logged_in_at":"","uroles":"","pin":"","pin_enabled":"","wchannel":"","nameofchannel":"","url":"","password":""}';
    String _filename = "userconfig.json";
    final Directory _appDir = await getApplicationDocumentsDirectory();
    final Directory _appDirFolder = Directory('${_appDir.path}/$_foldername/');
    if (await _appDirFolder.exists()) {
      //return _appDirFolder.path;
      if (await File(_appDirFolder.path + "/" + _filename).exists()) {
        final configfile = new File(_appDirFolder.path + "/" + _filename);
        final json = jsonDecode(await configfile.readAsString());
        final urole = json['role'];
        final loggedin = json['logged_in'];
        final img = json['img'];
        if (loggedin == '' || loggedin == "false") {
          //_showsnackbar("Role : $urole", "Close");
          Future.delayed(Duration(seconds: 3), () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => LoginPage()));
          });
        } else {
          Future.delayed(Duration(seconds: 3), () {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => MainLockScreen(userimg: img)));
          });
          /**/
        }
      } else {
        new File(_appDirFolder.path + "/" + _filename)
            .create(recursive: true)
            .then((File file) async {
          try {
            await file.writeAsString(_filecontents);
            Future.delayed(Duration(seconds: 3), () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => LoginPage()));
            });
          } catch (e) {
            _showsnackbar("Error writing to file : $e", "Close");
          }
        });
      }
    } else {
      _appDirFolder.create().then((Directory directory) async => {
            new File(directory.path + "/" + _filename)
                .create(recursive: true)
                .then((File file) async {
              try {
                await file.writeAsString(_filecontents);
                Future.delayed(Duration(seconds: 3), () {
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                });
              } catch (e) {
                _showsnackbar("Error writing to file : $e", "Close");
              }
            })
          });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loader = Center(
        child: Padding(
            padding: EdgeInsets.all(15.0),
            child: CircularProgressIndicator(
              strokeWidth: 5,
              backgroundColor: Color.fromRGBO(0, 0, 11, 1),
              valueColor: new AlwaysStoppedAnimation<Color>(
                  Color.fromRGBO(255, 180, 70, .5)),
            )));

    return Scaffold(resizeToAvoidBottomInset: false,
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 1,
          height: MediaQuery.of(context).size.height * 1,
          padding: const EdgeInsets.only(bottom: 0),
          decoration: new BoxDecoration(
              image: new DecorationImage(
            image: new ExactAssetImage('assets/images/cars_0045.jpg'),
            fit: BoxFit.fill,
          )),
          child: new BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 1,
              height: MediaQuery.of(context).size.height * 1,
              decoration:
                  new BoxDecoration(color: Colors.black.withOpacity(0.4)),
              child: Center(
                child: new Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: Stack(children: <Widget>[
                    Visibility(
                      visible: _diagvisibility,
                      child: new Container(
                        width: MediaQuery.of(this.context).size.width,
                        height: MediaQuery.of(this.context).size.height,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        child: Center(
                          child: new AnimatedBuilder(
                              animation: _animcon,
                              builder: (context, child) {
                                return Container(
                                  width:
                                      MediaQuery.of(this.context).size.width *
                                          0.3,
                                  height:
                                      MediaQuery.of(this.context).size.width *
                                          0.3,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color:
                                              Color.fromRGBO(255, 255, 255, .2),
                                          width: _animcon.value * 10),
                                      borderRadius: BorderRadius.circular(
                                          MediaQuery.of(this.context)
                                                  .size
                                                  .width *
                                              0.8)),
                                  child: Image.asset(
                                    'assets/images/CSI3.png',
                                    width:
                                        MediaQuery.of(this.context).size.width *
                                            0.5,
                                    height:
                                        MediaQuery.of(this.context).size.width *
                                            0.5,
                                  ),
                                );
                              }),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ),
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
