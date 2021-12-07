import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:emkapp/shipped_in_stock.dart';
import 'package:emkapp/shipped_sold.dart';
import 'package:flutter_sms/flutter_sms.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:path_provider/path_provider.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'helperclass.dart';
import 'keep_page_alive.dart';

void main() => runApp(ShippedCars());

class ShippedCars extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainShippedCars(),
    );
  }
}

class MainShippedCars extends StatefulWidget with PreferredSizeWidget {
  @override
  State createState() => new ShippedCarsState();

  @override
  Size get preferredSize => Size.fromHeight(100);
}

class ShippedCarsState extends State<MainShippedCars>
    with TickerProviderStateMixin {
  ScrollController _scrollController = ScrollController(keepScrollOffset: true);
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
      nuser = '',
      image = '';
  bool isButtonEnabled = true,
      _diagvisibility = false,
      _emptyconvisibility = true,
      _btnvisibility = false,
      _searchvisibility = false,
      _passwordvisibility = false,
      _isvisiblebuttonenabled = true,
      _hiddenbuttonenabled = false,
      _picvisibility = false,
      _sortvisibility = false,
      _hasSearched = false;
  var listname;
  Icon _searchIcon = new Icon(Icons.search);
  Icon _clearIcon = new Icon(Icons.clear_all);
  Widget _appBarTitle = new Text('Search for workers here');
  late SFields _selectedField = sfields[0];
  late SMethod _selectedMethod = smethod[0];
  List activeadminresponse = [];
  List secondactiveadminresponse = [];
  List searchactiveadminresponse = [];
  List<SFields> sfields = <SFields>[
    const SFields('', ''),
    const SFields('firstname', 'First Name'),
    const SFields('lastname', 'Last Name'),
    const SFields('id', 'ID')
  ];
  List<SMethod> smethod = <SMethod>[
    const SMethod('', ''),
    const SMethod('ascending', 'Ascending Order'),
    const SMethod('descending', 'Descending Order')
  ];
  Future<List<CWorkers>>? _future;
  late TabController _tabController;
  int bottomSelectedIndex = 0;
  String _results = "";
  FutureBuilder<List<CWorkers>>? myfutureBuilder;
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
    super.initState();

    _selectedField = sfields[0];
    _selectedMethod = smethod[0];
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

  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      subpageController.animateToPage(index,
          duration: Duration(milliseconds: 300), curve: Curves.ease);
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
      //print("image from json : " + _imgname);
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
    }
  }

  Future<List<CWorkers>> fetchactiveworkers() async {
    return activeadminresponse.map((e) => new CWorkers.fromJson(e)).toList();
  }

  Future<List<CWorkers>> sortactiveworkers() async {
    return secondactiveadminresponse
        .map((e) => new CWorkers.fromJson(e))
        .toList();
  }

  Future<List<CWorkers>> secondsortactiveworkers() async {
    return searchactiveadminresponse
        .map((e) => new CWorkers.fromJson(e))
        .toList();
  }

  Future<List<CWorkers>> searchactiveworkers() async {
    return searchactiveadminresponse
        .map((e) => new CWorkers.fromJson(e))
        .toList();
  }

  clearsearch() {
    searchactiveadminresponse.clear();
    setState(() {
      _future = sortactiveworkers();
      _hasSearched = false;
      _btnvisibility = false;
      listname = secondactiveadminresponse;
    });
  }

  clearsort() {
    setState(() {
      _future = fetchactiveworkers();
      _sortvisibility = false;
    });
  }

  _performsearch(String searchval) {
    setState(() {
      _diagvisibility = true;
      _hasSearched = true;
    });

    searchactiveadminresponse = secondactiveadminresponse
        .where((i) =>
            i["name"].toString().toLowerCase().contains(searchval) ||
            i["id"].toString().toLowerCase().contains(searchval) ||
            i["email"].toString().toLowerCase().contains(searchval) ||
            i["contact"].toString().contains(searchval))
        .toList();

    if (searchactiveadminresponse.isEmpty) {
      setState(() {
        _results = "No results found";
        _diagvisibility = false;
        _emptyconvisibility = true;
        _btnvisibility = true;
      });
    } else {
      setState(() {
        _diagvisibility = false;
        _emptyconvisibility = false;
        _future = searchactiveworkers();
        // listname = searchactiveadminresponse;
      });
    }
  }

  _performsort(String sfval, String smval) {
    //firstname, lastname, id, ascending, descending
    setState(() {
      _diagvisibility = true;
    });
    if (smval.contains("ascending")) {
      if (_hasSearched.toString() == "true" &&
          searchactiveadminresponse.isNotEmpty) {
        searchactiveadminresponse
            .sort((a, b) => a[sfval].toString().compareTo(b[sfval].toString()));
        setState(() {
          _diagvisibility = false;
          _emptyconvisibility = false;
          _future = secondsortactiveworkers();
          listname = searchactiveadminresponse;
        });
      } else {
        secondactiveadminresponse
            .sort((a, b) => a[sfval].toString().compareTo(b[sfval].toString()));
        setState(() {
          _diagvisibility = false;
          _emptyconvisibility = false;
          _future = sortactiveworkers();
          listname = secondactiveadminresponse;
        });
      }
    } else {
      if (_hasSearched.toString() == "true" &&
          searchactiveadminresponse.isNotEmpty) {
        searchactiveadminresponse
            .sort((b, a) => a[sfval].toString().compareTo(b[sfval].toString()));
        setState(() {
          _diagvisibility = false;
          _emptyconvisibility = false;
          _future = secondsortactiveworkers();
          listname = searchactiveadminresponse;
        });
      } else {
        secondactiveadminresponse
            .sort((b, a) => a[sfval].toString().compareTo(b[sfval].toString()));
        setState(() {
          _diagvisibility = false;
          _emptyconvisibility = false;
          _future = sortactiveworkers();
          listname = secondactiveadminresponse;
        });
      }
    }
  }

  _showfullpicture(String username, String img) {
    setState(() {
      _picvisibility = true;
      image = img;
    });
    _buildPictureWidget(username, img);
    //print("full image : " + img);
  }

  Widget _buildPictureWidget(String userval, String imageval) {
    var conWidget;
    //print("img : " + image);
    if (userval.isEmpty && image.isEmpty) {
      setState(() {
        nuser = "Profile Picture";
      });
      conWidget = SizedBox(
        height: 390,
        width: 400,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
              padding: EdgeInsets.only(left: 0),
              width: MediaQuery.of(context).size.width,
              decoration: new BoxDecoration(
                  image: new DecorationImage(
                image: new ExactAssetImage('assets/images/pic.png'),
                fit: BoxFit.fill,
              ))),
        ),
      );
    } else {
      setState(() {
        nuser = userval;
      });
      conWidget = SizedBox(
        height: 390,
        width: 400,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.only(left: 0),
            width: MediaQuery.of(context).size.width,
            decoration: new BoxDecoration(
                image: new DecorationImage(
              image: new CachedNetworkImageProvider(
                  "http://www.emkapp.com/emkapp/imgdata/" + image),
              fit: BoxFit.fill,
            )),
          ),
        ),
      );
    }
    return conWidget;
  }

  _openlink(String val, String opr) async {
    if (opr.contains("tel")) {
      _makephonecall('tel:' + val);
    }
    if (opr.contains("sms")) {
      if (val.startsWith("+")) {
        _makephonecall('sms:' + Uri.encodeComponent(val));
      } else {
        _makephonecall('sms:0' + Uri.encodeComponent(val));
      }
      /*List<String> persons = [];
      try {
        persons.add(val);
        await sendSMS(message: '', recipients: persons);
      } catch (err) {
        print("sms error : " + err.toString());
      }*/
    }
    if (opr.contains("email")) {
      _makephonecall(Uri.encodeFull('mailto:' + val + '?subject=&body='));
    }
  }

  Future<void> _makephonecall(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  _performdelete(String uid) {
    setState(() {
      _diagvisibility = true;
    });
    Widget cancelbtn = FlatButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop(context);
      },
      child: Text("Cancel"),
    );
    Widget continuebtn = FlatButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop(context);
      },
      child: Text("Continue"),
    );

    AlertDialog alert = AlertDialog(
      title: Text("Warning"),
      content: Text("Sure about removing Admin with ID : " + uid + " ?"),
      actions: [cancelbtn, continuebtn],
    );

    return showDialog(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  closeemptydiag() {
    setState(() {
      _btnvisibility = false;
      _emptyconvisibility = false;
    });
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

  _buildDataWidget() {
    var datawidget;
    if (activeadminresponse.isEmpty) {
      datawidget = Container(
        padding: const EdgeInsets.all(14.0),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Color.fromRGBO(0, 0, 0, 0.7),
        child: Center(
          child: Text(
            "No data available",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      );
    } else {
      datawidget = SingleChildScrollView(
          physics: ScrollPhysics(),
          controller: _scrollController,
          child: Column(
            children: [
              FutureBuilder<List<CWorkers>>(
                  future: _future,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<CWorkers>> snapshot) {
                    //print("list items : " + activeadminresponse.toString());
                    Widget newsListSliver;
                    if (snapshot.hasData) {
                      newsListSliver = ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (BuildContext context, int index) {
                          CWorkers item = snapshot.data![index];

                          return Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              child: Container(
                                width: MediaQuery.of(context).size.width * 1,
                                constraints:
                                    BoxConstraints(maxHeight: double.infinity),
                                height: 615,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color.fromRGBO(0, 0, 0, .3),
                                      spreadRadius: 12.0,
                                    ),
                                    BoxShadow(
                                      color: Color.fromRGBO(93, 93, 93, .1),
                                      spreadRadius: -12.0,
                                      blurRadius: 12.0,
                                    ),
                                  ],
                                  color: Color.fromRGBO(93, 93, 93, .3),
                                  border: Border(
                                      top: BorderSide(
                                          color:
                                              Color.fromRGBO(123, 123, 123, 1),
                                          width: 15),
                                      bottom: BorderSide(
                                          color: Color.fromRGBO(83, 83, 83, 1),
                                          width: 15),
                                      left: BorderSide(
                                          color: Color.fromRGBO(93, 93, 93, 1),
                                          width: 1),
                                      right: BorderSide(
                                          color: Color.fromRGBO(93, 93, 93, 1),
                                          width: 1)),
                                ),
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, bottom: 10, top: 10),
                                child: Column(
                                  children: <Widget>[
                                    Stack(
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            _showfullpicture(
                                                item.username, item.userimg);
                                          },
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
                                                        103, 103, 103, 1),
                                                    width: 11),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                image: DecorationImage(
                                                  fit: BoxFit.fill,
                                                  image:
                                                      CachedNetworkImageProvider(
                                                    'http://www.emkapp.com/emkapp/imgdata/' +
                                                        item.userimg,
                                                  ),
                                                )),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            _showfullpicture(
                                                item.username, item.userimg);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(3),
                                            child: Container(
                                              width: (MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45) -
                                                  6,
                                              height: (MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.45) -
                                                  6,
                                              decoration: BoxDecoration(
                                                border: Border.all(
                                                    color: Color.fromRGBO(
                                                        133, 133, 133, .5),
                                                    width: 3),
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                color:
                                                    Color.fromRGBO(0, 0, 0, .2),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 15)),
                                    Divider(
                                      color: Colors.white.withOpacity(.7),
                                      height: 1,
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 20)),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(.7),
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Icon(
                                            Icons.person,
                                            size: 27,
                                            color: Colors.amber[100],
                                          ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10)),
                                        Flexible(
                                            child: new Text(
                                          item.username,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'serif',
                                            color: Colors.white,
                                          ),
                                        )),
                                      ],
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 20)),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(.7),
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Icon(
                                            Icons.badge_rounded,
                                            size: 27,
                                            color: Colors.amber[100],
                                          ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10)),
                                        Flexible(
                                            child: new Text(
                                          item.userid,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'serif',
                                            color: Colors.white,
                                          ),
                                        )),
                                      ],
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 20)),
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          padding: EdgeInsets.all(2),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.white
                                                    .withOpacity(.7),
                                                width: 1),
                                            borderRadius:
                                                BorderRadius.circular(5),
                                          ),
                                          child: Icon(
                                            Icons.stream,
                                            size: 27,
                                            color: Colors.amber[100],
                                          ),
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.only(
                                                left: 10)),
                                        Flexible(
                                            child: new Text(
                                          item.channel,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: 'serif',
                                            color: Colors.white,
                                          ),
                                        )),
                                      ],
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 20)),
                                    GestureDetector(
                                      onTap: () {
                                        _openlink(item.usermail, "email");
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(.7),
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Icon(
                                              Icons.mail,
                                              size: 27,
                                              color: Colors.amber[100],
                                            ),
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10)),
                                          Flexible(
                                              child: new Text(
                                            item.usermail,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'serif',
                                              color: Colors.white,
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 20)),
                                    GestureDetector(
                                      onTap: () {
                                        _openlink(item.usercontact, "tel");
                                        print("Contact : " + item.usercontact);
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(.7),
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Icon(
                                              Icons.phone_android_rounded,
                                              size: 27,
                                              color: Colors.amber[100],
                                            ),
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10)),
                                          Flexible(
                                              child: new Text(
                                            item.usercontact,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'serif',
                                              color: Colors.white,
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 20)),
                                    GestureDetector(
                                      onTap: () {
                                        _openlink(item.usercontact, "sms");
                                      },
                                      child: Row(
                                        children: <Widget>[
                                          Container(
                                            padding: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.white
                                                      .withOpacity(.7),
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                            ),
                                            child: Icon(
                                              Icons.sms,
                                              size: 27,
                                              color: Colors.amber[100],
                                            ),
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10)),
                                          Flexible(
                                              child: new Text(
                                            item.usercontact,
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontFamily: 'serif',
                                              color: Colors.white,
                                            ),
                                          )),
                                        ],
                                      ),
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 20)),
                                    Divider(
                                      color: Colors.white.withOpacity(.7),
                                      height: 1,
                                    ),
                                    Padding(padding: EdgeInsets.only(top: 15)),
                                    Center(
                                      child: Container(
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(.7),
                                              width: 1),
                                          borderRadius:
                                              BorderRadius.circular(5),
                                        ),
                                        child: GestureDetector(
                                          onTap: () {
                                            _performdelete(item.userid);
                                          },
                                          child: Icon(
                                            Icons.delete,
                                            size: 27,
                                            color: Colors.amber[100],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    } else {
                      newsListSliver = Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return newsListSliver;
                  }),
              Container(height: 100, width: MediaQuery.of(context).size.width)
            ],
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

  bool pressed = false, _obscuretext = false, _visibility = false;

  late SnackBar snackBar;
  bool _datevisibility = true, boolTrue = true, isfavVisible = true;
  String _field = '', _method = '';
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

  Widget _buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      backgroundColor: Color.fromRGBO(53, 53, 53, 1),
      title: _appBarTitle,
      leading: new IconButton(
        icon: _searchIcon,
        onPressed: _searchPressed,
      ),
      actions: <Widget>[
        new IconButton(
          icon: _clearIcon,
          onPressed: () {
            clearsearch();
          },
        )
      ],
    );
  }

  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(Icons.close);
        this._appBarTitle = Theme(
          data: new ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.yellow,
            inputDecorationTheme: new InputDecorationTheme(
              labelStyle: new TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          child: Visibility(
            visible: _searchvisibility,
            child: new TextField(
              onSubmitted: (value) {
                _performsearch(value);
              },
              textInputAction: TextInputAction.search,
              decoration: new InputDecoration(
                  prefixIcon: new Icon(Icons.search), hintText: 'Search...'),
            ),
          ),
        );
      } else {
        this._searchIcon = new Icon(Icons.search);
        this._appBarTitle = new Text('Search for workers here');
      }
    });
  }

  _showsortdiag() {
    setState(() {
      _sortvisibility = true;
    });
  }

  PageController subpageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
          backgroundColor: Colors.transparent,
          icon: new Icon(Icons.directions_ferry),
          title: new Text(
            'In Stock',
            style: new TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
                color: Colors.white),
          )),
      BottomNavigationBarItem(
        backgroundColor: Colors.transparent,
        icon: new Icon(Icons.car_rental),
        title: new Text(
          'Sold',
          style: new TextStyle(
              fontWeight: FontWeight.w400, fontSize: 14.0, color: Colors.white),
        ),
      ),
    ];
  }

  Widget buildPageView() {
    return PageView(
      controller: subpageController,
      onPageChanged: (index) {
        pageChanged(index);
      },
      children: <Widget>[
        KeepAlivePage(child: MainShippedInStock(opt: "0")),
        KeepAlivePage(child: MainShippedSold(opt: "0")),
      ],
    );
  }

  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  bool dialVisible = true;
  final _sortformkey = GlobalKey<FormState>();
  final _sortfieldkey = GlobalKey<FormFieldState>();
  final _sortmethodkey = GlobalKey<FormFieldState>();
  SpeedDial buildSpeedDial() {
    return SpeedDial(
      animatedIcon: AnimatedIcons.menu_close,
      backgroundColor: Color.fromRGBO(0, 0, 11, 1),
      overlayColor: Color.fromRGBO(0, 0, 0, 0.05),
      animatedIconTheme: IconThemeData(size: 22.0, color: Colors.amber[100]),
      visible: dialVisible,
      curve: Curves.bounceIn,
      children: [
        SpeedDialChild(
          child: Icon(Icons.sort_by_alpha, color: Colors.white),
          backgroundColor: Color.fromRGBO(0, 0, 11, 1),
          onTap: () {
            _showsortdiag();
          },
          label: 'Sort',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Color.fromRGBO(0, 0, 11, 1),
        ),
        SpeedDialChild(
          child: Icon(Icons.refresh, color: Colors.white),
          backgroundColor: Color.fromRGBO(0, 0, 11, 1),
          onTap: () {},
          label: 'Refresh',
          labelStyle:
              TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
          labelBackgroundColor: Color.fromRGBO(0, 0, 11, 1),
        ),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: EdgeInsets.only(left: 15, right: 15),
      child: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.only(top: 20)),
          new DropdownButtonFormField<SFields>(
              key: _sortfieldkey,
              value: _selectedField,
              decoration: new InputDecoration(
                labelText: "Choose field",
              ),
              items: sfields.map((SFields sField) {
                return new DropdownMenuItem<SFields>(
                    value: sField, child: new Text(sField.sftext));
              }).toList(),
              validator: (value) {
                _selectedField = value!;
                if (_selectedField.sfval == "") {
                  return 'This field is required';
                }
              },
              onSaved: (newValue) {
                setState(() {
                  _selectedField = newValue!;
                });
              },
              onChanged: (newValue) {
                setState(() {
                  _selectedField = newValue!;
                });
              }),
          Padding(padding: EdgeInsets.only(top: 20)),
          new DropdownButtonFormField<SMethod>(
              key: _sortmethodkey,
              value: _selectedMethod,
              decoration: new InputDecoration(
                labelText: "Choose method",
              ),
              items: smethod.map((SMethod sMethod) {
                return new DropdownMenuItem<SMethod>(
                    value: sMethod, child: new Text(sMethod.smtext));
              }).toList(),
              validator: (value) {
                _selectedMethod = value!;
                if (_selectedMethod.smval == "") {
                  return 'This field is required';
                }
              },
              onSaved: (newValue) {
                setState(() {
                  _selectedMethod = newValue!;
                });
              },
              onChanged: (newValue) {
                setState(() {
                  _selectedMethod = newValue!;
                });
              }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return new Scaffold(resizeToAvoidBottomInset: false,
        
        body: NestedScrollView(
          body: TabBarView(
            controller: _tabController,
            children: <Widget>[
              Container(
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
                    padding: EdgeInsets.all(0.0),
                    width: MediaQuery.of(context).size.width * 1,
                    height: MediaQuery.of(context).size.height * 1,
                    decoration:
                        new BoxDecoration(color: Colors.black.withOpacity(0.4)),
                    child: Padding(
                      padding: EdgeInsets.only(bottom: bottom),
                      child: buildPageView(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[];
          },
        ),
        bottomNavigationBar: Visibility(
          visible: boolTrue,
          child: BottomNavigationBar(
            backgroundColor: Color.fromRGBO(0, 0, 12, 1).withOpacity(.7),
            unselectedItemColor: Colors.white,
            selectedItemColor: Colors.amber[100],
            currentIndex: bottomSelectedIndex,
            onTap: (index) {
              bottomTapped(index);
            },
            items: buildBottomNavBarItems(),
          ),
        ));
  }
}
