import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:emkapp/login.dart';
import 'package:emkapp/menuitems.dart';
import 'package:emkapp/salescontainer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'addcarchanneladmin.dart';
import 'addchannelworkeradmin.dart';
import 'allchannelcarscontainer.dart';
import 'allchannelworkers.dart';
import 'invoicesandreceipts.dart';
import 'messages.dart';

void main() => runApp(ChannelAdminDashboard());

class ChannelAdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainChannelAdminDashboard(
        opt: '',
        nrdate: '',
      ),
    );
  }
}

class MainChannelAdminDashboard extends StatefulWidget {
  MainChannelAdminDashboard({Key? key, required this.opt, required this.nrdate})
      : super(key: key);
  final String opt;
  final String nrdate;
  @override
  State createState() => new ChannelAdminDashboardState();
}

class ChannelAdminDashboardState extends State<MainChannelAdminDashboard>
    with TickerProviderStateMixin {
  var _appBarTitle;
  Color? _appBarBackgroundColor;
  MenuItem? _selectedMenuItem;
  List<MenuItem> _menuItems = [];
  List<Widget> _menuOptionWidgets = [];
  late AnimationController _iconanimcontroller;
  late Animation<double> _iconanim;
  late ProgressDialog pr;
  late AnimationController _animcon;
  String user = '', userid = '', _imgname = '', _nimgdir = '', _passw = '';
  late Directory _imgdir;
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
      _totalmsgs = "";
  bool isButtonEnabled = true, _diagvisibility = false, nv = true, ov = false;

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
    _inimenu(widget.opt);
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

  _inimenu(String moption) {
    print("option : " + moption);
    _menuItems = createMenuItems();
    final menuMap = _menuItems.asMap();
    _selectedMenuItem = menuMap[int.parse(moption)];
    _appBarTitle = new Text(menuMap[int.parse(moption)]!.title);
    _appBarBackgroundColor = menuMap[int.parse(moption)]!.color;
  }

  List msgcount = [];

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
      print("User ID : " + uid);
      _getallworkers(uid);
    }
  }

  _getallworkers(uid) async {
    var url = "http://www.emkapp.com/emkapp/messages.php";
    var bdata = {"getworkers": "", "uid": uid};
    FormData fdata = FormData.fromMap(bdata);

    BaseOptions options = new BaseOptions(
      baseUrl: "http://www.emkapp.com/emkapp",
      connectTimeout: 15000,
      receiveTimeout: 3000,
    );

    Dio dio = new Dio(options);

    try {
      var response = await dio.post(url, data: fdata);
      print(response.data);

      if (jsonDecode(jsonEncode(response.data))
          .toString()
          .contains("no records found")) {
        setState(() {
          nv = false;
        });
      } else {
        var _nformatter =
            NumberFormat.compactCurrency(decimalDigits: 2, symbol: '');
        msgcount = json.decode(response.data);
        int tmsgs = 0;
        msgcount.forEach((el) {
          tmsgs += int.parse(el["msgcount"]);
        });
        print("total messages : " + tmsgs.toString());
        if (tmsgs < 1) {
          setState(() {
            nv = false;
          });
        } else {
          setState(() {
            nv = true;
            if (tmsgs < 1000) {
              _totalmsgs = tmsgs.toString();
            } else {
              _totalmsgs = _nformatter.format(tmsgs).toLowerCase();
            }
          });
        }
      }
    } on DioError catch (ex) {
      if (mounted)
        setState(() {
          _diagvisibility = false;
        });

      throw Exception(ex.message);
    }
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
        '","lastpage":"", "password": "' +
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

  List<MenuItem> smenuItems = [];
  DateTime nSelectedDate = DateTime.now();
  var month = '', day = '';

  _getcurrentdate(DateTime newSelectedDate) {
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
    return formatteddate.toString();
  }

  List<MenuItem> createMenuItems() {
    var useraddcodepoint = Icons.person_add.codePoint;
    String _sentdate = "";
    if (widget.nrdate.toString().isEmpty) {
      _sentdate = _getcurrentdate(nSelectedDate);
    } else {
      _sentdate = widget.nrdate.toString();
    }
    smenuItems = [
      new MenuItem("Add Worker", "983146", Colors.black,
          () => new MainAddChannelAdminWorker(), ov),
      new MenuItem("Add Cars", "63001", Colors.black,
          () => new MainAddChannelAdminCar(), ov),
      new MenuItem("All Workers", "63432", Colors.black,
          () => new MainAllChannelWorkers(), ov),
      new MenuItem("All Cars", "59449", Colors.black,
          () => new MainAllChannelCars(), ov),
      new MenuItem(
          "Sales",
          "58780",
          Colors.black,
          () => new MainSalesContainer(
                defaultdate: _sentdate,
              ),
          ov),
      new MenuItem(
          "Messages", "58307", Colors.black, () => new ComMessages(), nv),
      new MenuItem("Invoices & Receipts", "58637", Colors.black,
          () => new MainInvoicesAndReceiptsContainer(), ov),
      /*
      
      new MenuItem("All Channel Admins", "63432", Colors.black,
          () => new MainAllChannelAdmins(), ov),
      
      
      new MenuItem(
          "Transfers",
          "58999",
          Colors.black,
          () => new MainTransfers(
                defaultdate: _sentdate,
              ),
          ov),
      new MenuItem(
          "Stolen Car?", "63001", Colors.black, () => new MainStolenCar(), ov),
      new MenuItem(
          "Shippers",
          "63432",
          Colors.black,
          () => new MainShippers(
                defaultdate: _sentdate,
              ),
          ov),
      new MenuItem("Update Payment", "58780", Colors.black,
          () => new MainUpdatePayment(), ov),
     
      new MenuItem(
          "Debtors", "63432", Colors.black, () => new MainMainDebtors(), ov),*/
    ];

    return smenuItems;
  }

  _getMenuItemWidget(MenuItem menuItem) {
    return menuItem.func();
  }

  _onSelectItem(MenuItem menuItem) {
    setState(() {
      _selectedMenuItem = menuItem;
      _appBarTitle = new Text(menuItem.title);
      _appBarBackgroundColor = menuItem.color;
    });

    var lindex;
    smenuItems.map((e) {
      lindex = smenuItems.indexOf(menuItem);
    });
    print(lindex);
    Navigator.of(context).pop(); // close side menu
  }

  savelistposition(String pos) async {
    String _foldername = "EmkappData";
    String _filename = "userconfig.json";
    final Directory _appDir = await getApplicationDocumentsDirectory();
    final Directory _appDirFolder = Directory('${_appDir.path}/$_foldername/');
    if (await File(_appDirFolder.path + "/" + _filename).exists()) {
      final configfile = new File(_appDirFolder.path + "/" + _filename);
      final json = jsonDecode(await configfile.readAsString());
      final _configcontent = '{"role":"' +
          json['role'].toString() +
          '","username":"' +
          json['username'].toString() +
          '","logged_in":"true","lockscreen":"true","img":"' +
          json['img'].toString() +
          '","cookiename":"","last_logged_in_at":"' +
          json['last_logged_in_at'].toString() +
          '","uroles":"' +
          json['uroles'].toString() +
          '","pin":"' +
          json['pin'].toString() +
          '","pin_enabled":"true","wchannel":"' +
          json['wchannel'].toString() +
          '","nameofchannel":"' +
          json['nameofchannel'].toString() +
          '","userid":"' +
          json['userid'].toString() +
          '","url":"","lastpage":"' +
          pos +
          '", "password": "' +
          json['password'] +
          '"}';

      try {
        await configfile.writeAsString(_configcontent);
      } catch (e) {
        _showsnackbar("Error saving user data : $e", "Close");
      }
    }
  }

  PreferredSizeWidget _buildBar(BuildContext context) {
    return new AppBar(
      title: _appBarTitle,
      backgroundColor: _appBarBackgroundColor,
      centerTitle: true,
    );
  }

  Widget twidget(String mtitle, MenuItem menuItem) {
    var datawidget;
    if (mtitle.toLowerCase() == "messages") {
      datawidget = new Visibility(
          visible: nv,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              color: menuItem == _selectedMenuItem
                  ? Colors.amber[100]
                  : Colors.black,
            ),
            child: Text(_totalmsgs,
                style: TextStyle(
                    color: menuItem == _selectedMenuItem
                        ? Colors.black
                        : Colors.white,
                    fontSize: 16)),
          ));
    } else {
      datawidget = new Visibility(
          visible: ov,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(8.0)),
              color: menuItem == _selectedMenuItem
                  ? Colors.amber[100]
                  : Colors.black,
            ),
            child: Text(_totalmsgs,
                style: TextStyle(
                    color: menuItem == _selectedMenuItem
                        ? Colors.black
                        : Colors.white,
                    fontSize: 16)),
          ));
    }

    return datawidget;
  }

  @override
  void dispose() {
    _animcon.dispose();
    _iconanimcontroller.dispose();
    super.dispose();
  }

  String _serveresponse = '';

  bool pressed = false,
      _obscuretext = false,
      _visibility = false,
      boolTrue = true;

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    _menuOptionWidgets = [];

    for (var menuItem in _menuItems) {
      _menuOptionWidgets.add(new Container(
          decoration: new BoxDecoration(
              color: menuItem == _selectedMenuItem
                  ? Colors.grey[900]
                  : Colors.white),
          child: Column(
            children: [
              new ListTile(
                  leading: new Icon(
                    IconData(int.parse(menuItem.icon),
                        fontFamily: 'MaterialIcons'),
                    color: menuItem == _selectedMenuItem
                        ? Colors.amber[100]
                        : Colors.black,
                  ),
                  trailing: twidget(menuItem.title, menuItem),
                  onTap: () {
                    print("Index : " + _menuItems.indexOf(menuItem).toString());
                    if (!(menuItem.title.contains("Log Out"))) {
                      savelistposition(_menuItems.indexOf(menuItem).toString());
                    }
                    return _onSelectItem(menuItem);
                  },
                  title: Text(
                    menuItem.title,
                    style: new TextStyle(
                        fontSize: 20.0,
                        color: menuItem == _selectedMenuItem
                            ? Colors.white
                            : Colors.black,
                        fontWeight: menuItem == _selectedMenuItem
                            ? FontWeight.bold
                            : FontWeight.w300),
                  )),
            ],
          )));

      _menuOptionWidgets.add(
        new SizedBox(
          child: new Center(
            child: new Container(
              margin: new EdgeInsetsDirectional.only(start: 20.0, end: 20.0),
              height: 0.3,
              color: Color.fromRGBO(150, 150, 150, 1),
            ),
          ),
        ),
      );
    }
    return new Scaffold(
        appBar: boolTrue ? _buildBar(context) : null,
        drawer: new Drawer(
          child: new ListView(
            children: <Widget>[
              new Container(
                  child: new ListTile(
                    leading: Container(
                      width: 55,
                      height: 70,
                      decoration: BoxDecoration(
                          border: Border.all(
                              color: Color.fromRGBO(73, 73, 73, 1), width: 3),
                          borderRadius: BorderRadius.circular(70),
                          image: DecorationImage(
                            fit: BoxFit.cover,
                            image: CachedNetworkImageProvider(
                                "http://www.emkapp.com/emkapp/imgdata/" +
                                    _imgname),
                          )),
                    ),
                    title: Text(username,
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                        )),
                    subtitle: Text(nameofchannel + " Administrator",
                        style: TextStyle(
                          color: Color.fromRGBO(255, 255, 255, 1),
                        )),
                    tileColor: Color.fromRGBO(0, 0, 10, 1),
                  ),
                  margin: new EdgeInsetsDirectional.only(top: 0.0),
                  color: Color.fromRGBO(0, 0, 10, 1),
                  padding: EdgeInsets.only(top: 20),
                  constraints:
                      BoxConstraints(maxHeight: 110.0, minHeight: 110.0)),
              new SizedBox(
                child: new Center(
                  child: new Container(
                    margin:
                        new EdgeInsetsDirectional.only(start: 10.0, end: 10.0),
                    height: 0.3,
                    color: Colors.black,
                  ),
                ),
              ),
              new Container(
                color: Colors.white,
                child: Column(
                  children: [
                    new ListTile(
                        leading: new Icon(
                          Icons.refresh,
                          color: Colors.black,
                        ),
                        onTap: () {
                          _getallworkers(uid);
                        },
                        title: Text(
                          "Refresh",
                          style: new TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                              fontWeight: FontWeight.w300),
                        )),
                    new Column(children: _menuOptionWidgets),
                    new ListTile(
                        leading: new Icon(
                          IconData(int.parse("63627"),
                              fontFamily: 'MaterialIcons'),
                          color: Colors.black,
                        ),
                        onTap: () {
                          _showlogoutdialog(context);
                        },
                        title: Text(
                          "Log Out",
                          style: new TextStyle(
                              fontSize: 20.0,
                              color: Colors.black,
                              fontWeight: FontWeight.w300),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
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
                          _getMenuItemWidget(_selectedMenuItem!),
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
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
