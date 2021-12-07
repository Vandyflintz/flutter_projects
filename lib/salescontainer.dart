import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'dart:math' show pi;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:emkapp/adminsales.dart';
import 'package:emkapp/adminworkersales.dart';
import 'package:emkapp/othersales.dart';
import 'package:emkapp/resetpassword.dart';
import 'package:emkapp/workadmin.dart';
import 'package:emkapp/workersdashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

import 'admindashboard.dart';
import 'channeladmindashboard.dart';
import 'keep_page_alive.dart';
import 'login.dart';
import 'resetpin.dart';

void main() => runApp(SalesContainer());

class SalesContainer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainSalesContainer(
        defaultdate: '',
      ),
    );
  }
}

class MainSalesContainer extends StatefulWidget {
  final String defaultdate;
  MainSalesContainer({Key? key, required this.defaultdate}) : super(key: key);
  @override
  State createState() => new SalesContainerState();
}

class SalesContainerState extends State<MainSalesContainer>
    with TickerProviderStateMixin {
  late AnimationController _iconanimcontroller;
  late Animation<double> _iconanim;
  late ProgressDialog pr;
  late AnimationController _animcon;
  String user = '', userid = '', _imgname = '', _nimgdir = '', _passw = '';
  late Directory _imgdir;
  String ndefaultdate = '', ndefaulttotal = "";
  late ScrollController scrollController;
  bool dialVisible = true;
  Color hiddencolor = Colors.transparent;
  Color visiblecolor = Color.fromRGBO(0, 0, 10, 1);
  Color visibletextcolor = Colors.white;
  Color hiddentextcolor = Colors.transparent;
  String imgdir = '';
  bool isfavVisible = true;
  late TabController _tabController;
  int bottomSelectedIndex = 0;
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
    _tabController = TabController(length: 1, vsync: this);
    ndefaultdate = widget.defaultdate;
    _getallsoldcars(ndefaultdate);
    _salesdateselectedDate = DateTime.parse(ndefaultdate);
    _salesdatecontroller.text = ndefaultdate;

    var dateinwords = DateFormat('EEEE , MMMM d, yyyy')
        .format(DateTime.parse(ndefaultdate))
        .toString();
    _wordsalesdate = dateinwords;
    super.initState();

    loadfile();
    print("Date from previous page : " + widget.defaultdate);
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

  TextEditingController _salesdatecontroller = new TextEditingController();
  @override
  void dispose() {
    _animcon.dispose();
    _iconanimcontroller.dispose();
    _salesdatecontroller.dispose();
    subpageController.dispose();
    super.dispose();
  }

  String _wordsalesdate = "", _salesdate = "";

  DateTime salesdateselectedDate = DateTime.now();
  DateTime? _salesdateselectedDate;

  DateTime empdateselectedDate = DateTime.now();
  DateTime? _empdateselectedDate;

  Future<void> _salesdateselectDate(BuildContext context) async {
    if (_salesdateselectedDate != null) {
    } else {
      _salesdateselectedDate = DateTime.now();
    }

    final newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _salesdateselectedDate!,
        firstDate: DateTime(1960, 1),
        lastDate: DateTime.now().add(Duration(days: 365)));
    print(newSelectedDate);
    if (newSelectedDate != null && newSelectedDate != _salesdateselectedDate)
      setState(() {
        _salesdateselectedDate = newSelectedDate;

        var month = '', day = '';
        if (newSelectedDate.month.toString().length < 2) {
          month = "0" + newSelectedDate.month.toString();
        } else {
          month = newSelectedDate.month.toString();
        }
        if (newSelectedDate.day.toString().length < 2) {
          day = "0" + newSelectedDate.day.toString();
        } else {
          day = newSelectedDate.day.toString();
        }
        //EEEE , MMMM d, YYYY
        var formatteddate = "${newSelectedDate.year}-${month}-${day}";
        _salesdate = formatteddate.toString();
        _salesdatecontroller.text = formatteddate.toString();
        setState(() {
          ndefaultdate = formatteddate.toString();
        });

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => new MainAdminDashboard(
                      opt: '6',
                      nrdate: ndefaultdate,
                    )));

        print(formatteddate);
        //_refreshpages(formatteddate.toString());
        var dateinwords = DateFormat('EEEE , MMMM d, yyyy')
            .format(newSelectedDate)
            .toString();
        _wordsalesdate = dateinwords;
      });
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

  downloadimage(String filename) async {
    var url = "http://www.emkapp.com/emkapp/imgdata/" + _imgname;
    var response = await http.get(Uri.parse(url));
    print("image : " + _imgname);
    File file = new File(_nimgdir + _imgname);
    //_showsnackbar(url, "");
    file.writeAsBytesSync(response.bodyBytes);
    print("Image has been downloaded");
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
          child: Icon(Icons.refresh, color: Colors.white),
          backgroundColor: Color.fromRGBO(0, 0, 11, 1),
          onTap: () {
            //_refreshpage();
          },
          label: 'Refresh',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Color.fromRGBO(0, 0, 11, 1),
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
        '","logged_in":"false","SalesContainer":"false","img":"' +
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

  PageController subpageController = PageController(keepPage: false);

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
          backgroundColor: Colors.transparent,
          icon: new Icon(Icons.person),
          title: new Text(
            'Admin.',
            style: new TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
                color: Colors.white),
          )),
      BottomNavigationBarItem(
        backgroundColor: Colors.transparent,
        icon: new Icon(Icons.people),
        title: new Text(
          'Admin\'s Workers',
          style: new TextStyle(
              fontWeight: FontWeight.w400, fontSize: 14.0, color: Colors.white),
        ),
      ),
      BottomNavigationBarItem(
        backgroundColor: Colors.transparent,
        icon: new Icon(Icons.people),
        title: new Text(
          'Other Channels',
          style: new TextStyle(
              fontWeight: FontWeight.w400, fontSize: 14.0, color: Colors.white),
        ),
      ),
    ];
  }

  _buildSubPages(String ndate) {
    print(ndefaultdate);

    return new PageView(
      controller: subpageController,
      onPageChanged: (index) {
        pageChanged(index);
      },
      children: <Widget>[
        KeepAlivePage(
            child: MainAdminSales(
          defaultdate: ndate,
          defaulttotal: ndefaulttotal,
        )),
        KeepAlivePage(
            child: MainAdminWorkerSales(
          defaultdate: ndate,
          defaulttotal: ndefaulttotal,
        )),
        KeepAlivePage(
            child: MainOtherChannelsSales(
          defaultdate: ndate,
          defaulttotal: ndefaulttotal,
        )),
      ],
    );
  }

  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      subpageController.animateToPage(index,
          duration: Duration(milliseconds: 300), curve: Curves.ease);
    });
  }

  _getallsoldcars(String nddate) async {
    var url = "http://www.emkapp.com/emkapp/sales.php";
    var bdata = {"sdate": nddate, "getallsales": "true"};
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

      if (jsonDecode(response.data).toString().contains("no records found")) {
        setState(() {
          _diagvisibility = false;
          ndefaulttotal = "0";
        });
      } else {
        setState(() {
          _diagvisibility = false;
          ndefaulttotal = jsonDecode(response.data).toString();
        });
        _buildSubPages(nddate);

        //searchcarresponse = json.decode(response.data);
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
                  padding: const EdgeInsets.all(0.0),
                  child: Padding(
                    padding: EdgeInsets.only(bottom: bottom),
                    child: new Stack(
                      children: <Widget>[
                        Column(
                          children: <Widget>[
                            Container(
                              height: 90,
                              padding: EdgeInsets.all(5),
                              color: Colors.black.withOpacity(.7),
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(left: 10, right: 10),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width -
                                          80,
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
                                        child: TextFormField(
                                          controller: _salesdatecontroller,
                                          decoration: InputDecoration(
                                            labelText: 'Select date here',
                                            helperText: _wordsalesdate,
                                            prefixIcon:
                                                Icon(Icons.calendar_today),
                                          ),
                                          readOnly: true,
                                          onTap: () {
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                            _salesdateselectDate(context);
                                          },
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          onSaved: (newValue) {
                                            setState(() {});
                                          },
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    new MainAdminDashboard(
                                                      opt: '6',
                                                      nrdate: ndefaultdate,
                                                    )));
                                      },
                                      child: Container(
                                        child: Icon(Icons.refresh,
                                            size: 35, color: Colors.grey),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: MediaQuery.of(context).size.height - 202,
                              child: _buildSubPages(ndefaultdate),
                            )
                          ],
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
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromRGBO(0, 0, 12, 1).withOpacity(.7),
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.amber[100],
        currentIndex: bottomSelectedIndex,
        onTap: (index) {
          bottomTapped(index);
        },
        items: buildBottomNavBarItems(),
      ),
    );
  }
}
