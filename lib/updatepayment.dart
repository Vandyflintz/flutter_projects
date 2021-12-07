import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_js/flutter_js.dart';
import 'package:flutter_js/javascript_runtime.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'admindashboard.dart';
import 'helperclass.dart';
import 'lockscreen.dart';
import 'login.dart';

void main() {
  runApp(UpdatePayment());
}

class UpdatePayment extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
      title: 'EM-KAPP',
      debugShowCheckedModeBanner: false,
      home: MainUpdatePayment(),
    );
  }
}

class MainUpdatePayment extends StatefulWidget {
  MainUpdatePayment({Key? key}) : super(key: key);

  @override
  State createState() => _UpdatePaymentState();
}

class _UpdatePaymentState extends State<MainUpdatePayment>
    with TickerProviderStateMixin {
  late AnimationController _animcon;
  late AnimationController _iconanimcontroller, _fabcon;
  late Animation<double> _iconanim;
  ScrollController _scrollController = ScrollController(keepScrollOffset: true);
  WebViewController? _webViewController;
  final JavascriptRuntime javascriptRuntime = getJavascriptRuntime();
  @override
  void initState() {
    getuserconfig();
    _animcon = new AnimationController(
      vsync: this,
      duration: new Duration(
        milliseconds: 1000,
      ),
    );
    super.initState();
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
    _iconanimcontroller.dispose();
    _amtwordscon.dispose();
    _amtfigurescon.dispose();
    _buyernamecon.dispose();
    _buyercontactcon.dispose();
    _buyeraddresscon.dispose();
    _buyerinvoicecon.dispose();
    super.dispose();
  }

  GlobalKey<FormState> _buyerformkey = GlobalKey<FormState>();
  GlobalKey<FormState> _invoiceformkey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool pressed = false, _obscuretext = false, _visibility = false;
  Future<List<ClientUpdatePayment>>? _future;
  List receiptlist = [];
  Future<List<ClientUpdatePayment>> fetchsoldcars() async {
    return receiptlist.map((e) => new ClientUpdatePayment.fromJson(e)).toList();
  }

  String geninvoicenum(String did) {
    String geninvoice = javascriptRuntime.evaluate("""
    
    function formatAMPM(date,did) {
    var fword = did.substring(0, 4);
    var hours = date.getHours();
    var hoursone = date.getHours();
    var minutes = date.getMinutes();
    var seconds = date.getSeconds();
    var year = date.getFullYear();
    var month = date.getMonth() + 1;
    var day = date.getDate();
    var ampm = hours >= 12 ? 'pm' : 'am';
    hours = hours % 12;
    hours = hours ? hours : 12;
    minutes = minutes < 10 ? '0' + minutes : minutes;
    seconds = seconds < 10 ? '0' + seconds : seconds;
    hoursone = hoursone < 10 ? '0' + hoursone : hoursone;
    month = month < 10 ? '0' + month : month;
    day = day < 10 ? '0' + day : day;

    //var strTime = hoursone + ":" + minutes + ":" + seconds + ' ' + ampm;
    var strid = hoursone + "" + day + "" + minutes + "" + fword + "" + "" + month + "" + seconds + "" + year;
    return strid;
}
  var date = new Date();
  formatAMPM(date,'$did');
     """).stringResult;

    return geninvoice;
  }

  Color? primarycolor = Color.fromRGBO(0, 0, 11, 1);
  List<PaymentMethod> paymentmethod = List<PaymentMethod>.from([
    {"paymentval": "", "paymentname": ""},
    {"paymentval": "full", "paymentname": "Full Payment"},
    {"paymentval": "part", "paymentname": "Part Payment"}
  ].map((i) => PaymentMethod.fromJson(i)));
  PaymentMethod? _selectedPayment;
  String _buyername = "",
      _buyercontact = "",
      _buyeraddress = "",
      _datedue = "",
      _amtwords = "",
      _amtfigures = "",
      _reason = "",
      message = "",
      _clchannel = "";
  TextEditingController _amtwordscon = new TextEditingController();
  TextEditingController _amtfigurescon = new TextEditingController();
  TextEditingController _buyernamecon = new TextEditingController();
  TextEditingController _buyercontactcon = new TextEditingController();
  TextEditingController _buyeraddresscon = new TextEditingController();
  TextEditingController _buyerinvoicecon = new TextEditingController();
  TextEditingController _invoicenumcontroller = new TextEditingController();
  late SnackBar snackBar;
  bool _diagvisibility = false,
      _buyerformvisibility = false,
      _pdfvisibility = false,
      _searchvisibility = false,
      _passwordvisibility = false,
      _isvisiblebuttonenabled = true,
      _hiddenbuttonenabled = false,
      _picvisibility = false,
      _sortvisibility = false,
      _hasSearched = false,
      _detailsvisible = false,
      _subpaymentvisibility = false,
      isfavVisible = true,
      boolTrue = true,
      _submenuVisible = false,
      _submenuvisible = false,
      _filterformvisible = false,
      _cartvisibility = false,
      _invoicevisibility = true;
  String _cinvoice = "",
      _creceipt = "",
      _ctotalamount = "",
      _camtpaid = "",
      _cbalance = "",
      _cname = "",
      _caddress = "",
      _contact = "",
      _documenturl = "",
      _fileurl = "";
  String username = '',
      configpin = '',
      configpassword = '',
      password = '',
      role = '',
      cookiename = '',
      last_logged_in_at = '',
      uroles = '',
      wchannel = '',
      nameofchannel = '',
      url = '',
      uid = '',
      nuser = '',
      image = '',
      _pricetxtname = "";
  String userid = '',
      _imgname = '',
      _nimgdir = '',
      _passw = '',
      _paymentData = "";
  late Directory _imgdir;
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
        role = json['role'];
        cookiename = json['cookiename'];
        last_logged_in_at = json['last_logged_in_at'];
        uroles = json['uroles'];
        wchannel = json['wchannel'];
        nameofchannel = json['nameofchannel'];
        url = json['url'];
        uid = json['userid'];
      });
      print(uid);
      print("Generated invoice : " + geninvoicenum(uid));
      // _showsnackbar(_imgname, "Okay");
    }
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

  Widget _receiptWidget() {
    var datawidget;
    if (receiptlist.isEmpty) {
      datawidget = Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          child: Align(
            alignment: Alignment.center,
            child: Text("No data available",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1), fontSize: 18)),
          ));
    } else {
      datawidget = Column(
        children: [
          Stack(
            children: [
              FutureBuilder<List<ClientUpdatePayment>>(
                  future: _future,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<ClientUpdatePayment>> snapshot) {
                    //print("list items : " + carresponse.toString());
                    Widget newsListSliver;
                    if (snapshot.hasData) {
                      newsListSliver = ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          controller: _scrollController,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            ClientUpdatePayment item = snapshot.data![index];
                            var cdate = item.lastpaid.split("-");
                            // _clchannel = item.clientchannel[0];
                            String newdate =
                                cdate[2] + "-" + cdate[1] + "-" + cdate[0];
                            //print("images : " + item.mainimg);
                            //print("color name : " + evalJS(item.color));
                            return Column(
                              children: <Widget>[
                                Table(
                                  columnWidths: {
                                    0: FlexColumnWidth(3),
                                    1: FlexColumnWidth(2.8),
                                    2: FlexColumnWidth(2.8),
                                    3: FlexColumnWidth(1.4),
                                  },
                                  border: TableBorder.all(
                                      color: Colors.white.withOpacity(.5),
                                      width: .6),
                                  children: [
                                    TableRow(children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 10, top: 15, bottom: 15),
                                        height: 65,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: Colors.black.withOpacity(.8),
                                        child: Text(item.rnum,
                                            style: TextStyle(
                                              color: Color.fromRGBO(
                                                  255, 255, 255, 1),
                                              fontSize: 16,
                                            )),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 10, top: 15, bottom: 15),
                                        height: 65,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: Colors.black.withOpacity(.8),
                                        child: Text(newdate,
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 1),
                                                fontSize: 16)),
                                      ),
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 10, top: 15, bottom: 15),
                                        height: 65,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: Colors.black.withOpacity(.8),
                                        child: Text(
                                            "Gh¢ " +
                                                formatter.format(double.parse(
                                                    item.amtpaid
                                                        .replaceAll(',', ''))),
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 1),
                                                fontSize: 16)),
                                      ),
                                      Container(
                                          height: 65,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.black.withOpacity(.8),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              height: 35,
                                              width: 35,
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(25.0)),
                                                gradient: LinearGradient(
                                                  colors: <Color>[
                                                    Color.fromRGBO(
                                                        109, 109, 109, 1),
                                                    Color.fromRGBO(
                                                        105, 105, 105, 1)
                                                  ],
                                                  begin: Alignment(-1.0, -1),
                                                  end: Alignment(-1.0, 1),
                                                ),
                                              ),
                                              child: RaisedButton(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    side: BorderSide(
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, 0.09),
                                                        width: 3),
                                                  ),
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.0),
                                                  textColor: Colors.white,
                                                  child: Container(
                                                    transform: Matrix4
                                                        .translationValues(
                                                            -12, 0, 0),
                                                    child: new Icon(
                                                      Icons.read_more,
                                                      size: 25,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    _showpdfDocument(
                                                        "http://www.emkapp.com/emkapp/receipts/" +
                                                            item.rnum +
                                                            ".pdf");
                                                  }),
                                            ),
                                          )),
                                    ])
                                  ],
                                ),
                              ],
                            );
                          });
                    } else {
                      newsListSliver = Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return newsListSliver;
                  }),
            ],
          ),
        ],
      );
    }

    return datawidget;
  }

  _showpdfDocument(String doc) {
    setState(() {
      _documenturl = doc;
      _pdfvisibility = true;
    });
    _showpdfLayout();
  }

  Widget _showbuyerform() {
    double? _cheight;
    setState(() {
      _cheight = 650;
    });
    return new Container(
      padding: const EdgeInsets.all(14.0),
      width: MediaQuery.of(this.context).size.width,
      height: MediaQuery.of(this.context).size.height,
      color: Color.fromRGBO(0, 0, 0, 0.7),
      child: Center(
        child: Container(
          child: ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
            child: ListView(
              controller: _scrollController,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Add Buyer\'s Details',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  height: 40,
                  width: MediaQuery.of(this.context).size.width,
                  color: Color.fromRGBO(0, 0, 10, .9),
                ),
                Form(
                  key: _buyerformkey,
                  child: Theme(
                    data: new ThemeData(
                      brightness: Brightness.dark,
                      primarySwatch: Colors.amber,
                      inputDecorationTheme: new InputDecorationTheme(
                        labelStyle: new TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    child: Column(
                      children: <Widget>[
                        new TextFormField(
                          controller: _buyerinvoicecon,
                          readOnly: true,
                          decoration: new InputDecoration(
                            labelText: "Enter invoice number here",
                            prefixIcon: Icon(Icons.note),
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
                              _buyername = newValue!;
                            });
                          },
                          keyboardType: TextInputType.text,
                        ),
                        Padding(padding: EdgeInsets.only(top: 20)),
                        new TextFormField(
                          controller: _buyernamecon,
                          readOnly: true,
                          decoration: new InputDecoration(
                            labelText: "Enter buyer's name here",
                            prefixIcon: Icon(Icons.person),
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
                              _buyername = newValue!;
                            });
                          },
                          keyboardType: TextInputType.text,
                        ),
                        Padding(padding: EdgeInsets.only(top: 20)),
                        new TextFormField(
                          controller: _buyercontactcon,
                          readOnly: true,
                          decoration: new InputDecoration(
                            labelText: "Enter buyer's contact number here",
                            prefixIcon: Icon(Icons.phone_android),
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
                              _buyercontact = newValue!;
                            });
                          },
                          keyboardType: TextInputType.text,
                        ),
                        Padding(padding: EdgeInsets.only(top: 20)),
                        new TextFormField(
                          controller: _buyeraddresscon,
                          readOnly: true,
                          decoration: new InputDecoration(
                            labelText: "Enter buyer's address here",
                            prefixIcon: Icon(Icons.contact_page),
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
                              _buyeraddress = newValue!;
                            });
                          },
                          keyboardType: TextInputType.text,
                        ),
                        Padding(padding: EdgeInsets.only(top: 20)),
                        DropdownButtonHideUnderline(
                          child: new DropdownButtonFormField<PaymentMethod>(
                              value: _selectedPayment,
                              decoration: new InputDecoration(
                                labelText: "Payment Method",
                                prefixIcon: Icon(Icons.payments),
                              ),
                              items: paymentmethod
                                  .map((PaymentMethod paymentData) {
                                return new DropdownMenuItem<PaymentMethod>(
                                    value: paymentData,
                                    child: new Text(
                                      paymentData.paymentname,
                                    ));
                              }).toList(),
                              validator: (value) => value == null
                                  ? 'This field is required'
                                  : null,
                              onSaved: (newValue) {
                                setState(() {
                                  _selectedPayment = newValue;
                                  if (_selectedPayment!.paymentval != "") {
                                    _reason = newValue!.paymentval.toString();
                                  }
                                });
                              },
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedPayment = newValue!;
                                  _reason = newValue.paymentval.toString();
                                  if (_selectedPayment!.paymentval == "" ||
                                      _selectedPayment!.paymentval == "none") {
                                    _subpaymentvisibility = false;
                                    _amtwordscon.clear();
                                    _amtfigurescon.clear();
                                    _cheight = 500;
                                  } else {
                                    _cheight = 650;
                                    _subpaymentvisibility = true;
                                    _amtwordscon.clear();
                                    _amtfigurescon.clear();
                                  }
                                });
                              }),
                        ),
                        Visibility(
                            visible: _subpaymentvisibility,
                            child: Padding(padding: EdgeInsets.only(top: 20))),
                        Visibility(
                          visible: _subpaymentvisibility,
                          child: new TextFormField(
                            controller: _amtfigurescon,
                            decoration: new InputDecoration(
                              labelText: "Enter amount in figures here",
                              prefixIcon: Padding(
                                padding: EdgeInsets.only(left: 12, top: 15),
                                child: Text(
                                  'Gh¢',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
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
                                _amtfigures = newValue!;
                              });
                            },
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        Visibility(
                            visible: _subpaymentvisibility,
                            child: Padding(padding: EdgeInsets.only(top: 20))),
                        Visibility(
                          visible: _subpaymentvisibility,
                          child: new TextFormField(
                            controller: _amtwordscon,
                            decoration: new InputDecoration(
                              labelText: "Enter amount in words here",
                              prefixIcon: Icon(Icons.receipt),
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
                                _amtwords = newValue!;
                              });
                            },
                            keyboardType: TextInputType.text,
                          ),
                        ),
                        Padding(padding: EdgeInsets.only(top: 20)),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(left: 15),
                              width:
                                  MediaQuery.of(this.context).size.width * 0.28,
                              height: 40,
                              child: new RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                        color: Color.fromRGBO(0, 0, 0, 0.09),
                                        width: 3),
                                  ),
                                  color: primarycolor,
                                  textColor: Colors.white,
                                  child: new Text(
                                    "Add",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  onPressed: () async {
                                    final form = _buyerformkey.currentState;
                                    if (form!.validate()) {
                                      List buyerobj = [];

                                      String recname = geninvoicenum(uid);
                                      String recnum = "R" + recname + "PT";
                                      String amtnum = "",
                                          amtwords = "",
                                          reason = "",
                                          finalamtnum = "",
                                          balance = "";
                                      if (_amtfigurescon.text.isNotEmpty) {
                                        amtnum = _amtfigurescon.text
                                            .replaceAll(',', '');

                                        finalamtnum = formatter
                                            .format(double.parse(amtnum))
                                            .toString();
                                        amtwords = _amtwordscon.text;
                                        reason = _reason;
                                      } else {
                                        finalamtnum = "0";
                                        reason = _reason;
                                        amtwords = "";
                                      }

                                      var bmap = {
                                        "name": _buyername,
                                        "contact": _buyercontact,
                                        "address": _buyeraddress,
                                        "datedue": _datedue,
                                        "amtpaid": finalamtnum,
                                        "amtwords": amtwords,
                                        "reason": reason,
                                        "payment": reason,
                                        "invoicenum": _cinvoice,
                                        "recnum": recname
                                      };
                                      buyerobj.add(bmap);
                                      _updatepayment(buyerobj);
                                    }
                                  }),
                            ),
                            Container(
                              padding: EdgeInsets.only(right: 15),
                              width:
                                  MediaQuery.of(this.context).size.width * 0.28,
                              height: 40,
                              child: new RaisedButton(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                    side: BorderSide(
                                        color: Color.fromRGBO(0, 0, 0, 0.09),
                                        width: 3),
                                  ),
                                  color: primarycolor,
                                  textColor: Colors.white,
                                  child: new Text(
                                    "Cancel",
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _buyerformkey.currentState!.reset();
                                      _buyerformvisibility = false;
                                      _submenuvisible = true;
                                      _submenuVisible = true;
                                      _subpaymentvisibility = false;
                                      _amtwordscon.clear();
                                      _amtfigurescon.clear();
                                      _cheight = 500;
                                      _selectedPayment = null;
                                    });
                                  }),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          width: MediaQuery.of(this.context).size.width,
          height: _cheight,
          decoration: BoxDecoration(
            color: Color.fromRGBO(53, 53, 53, 1),
            border: Border.all(color: Color.fromRGBO(73, 73, 73, .3), width: 5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }

  PdfDocumentLoadedDetails? newpdfFile;
  _printDocument() async {
    final Uint8List bytes = Uint8List.fromList(newpdfFile!.document.save());
    await Navigator.push<dynamic>(
        context,
        MaterialPageRoute<dynamic>(
            builder: (BuildContext context) => SafeArea(
                    child: PdfPreview(
                  build: (PdfPageFormat format) => bytes,
                ))));
  }

  Widget _showpdfLayout() {
    var datawidget;
    if (_documenturl.isEmpty) {
      datawidget = Container(
        color: Colors.black.withOpacity(.5),
        width: MediaQuery.of(this.context).size.width,
        height: MediaQuery.of(this.context).size.height,
      );
    } else {
      datawidget = Container(
        color: Colors.black.withOpacity(.8),
        width: MediaQuery.of(this.context).size.width,
        height: MediaQuery.of(this.context).size.height,
        child: Column(
          children: <Widget>[
            Container(
              width: MediaQuery.of(this.context).size.width,
              height: MediaQuery.of(this.context).size.height - 118,
              child: SfPdfViewer.network(
                _documenturl,
                onDocumentLoaded: (details) {
                  setState(() {
                    newpdfFile = details;
                  });
                },
              ),
            ),
            Container(
              height: 50,
              width: MediaQuery.of(this.context).size.width,
              child: Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                  image: new ExactAssetImage('assets/images/cars_0045.jpg'),
                  fit: BoxFit.cover,
                )),
                child: Container(
                  height: 50,
                  width: MediaQuery.of(context).size.width,
                  color: Colors.black.withOpacity(.8),
                  child: Align(
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 15),
                          width: MediaQuery.of(context).size.width * 0.42,
                          height: 35,
                          child: new RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                    color: Color.fromRGBO(0, 0, 0, 0.09),
                                    width: 3),
                              ),
                              color: Color.fromRGBO(0, 0, 11, 1),
                              textColor: Colors.white,
                              child: new Text(
                                "Close",
                                style: TextStyle(fontSize: 15),
                              ),
                              onPressed: () {
                                setState(() {
                                  _pdfvisibility = false;
                                });
                              }),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 15),
                          width: MediaQuery.of(context).size.width * 0.42,
                          height: 35,
                          child: new RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                    color: Color.fromRGBO(0, 0, 0, 0.09),
                                    width: 3),
                              ),
                              color: Color.fromRGBO(0, 0, 11, 1),
                              textColor: Colors.white,
                              child: new Text(
                                "Print",
                                style: TextStyle(fontSize: 15),
                              ),
                              onPressed: () {
                                _printDocument();
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }
    return datawidget;
  }

  var formatter = NumberFormat('#,###,000');
  _getinvoicedata(String dinvoicenum) async {
    var url = "http://www.emkapp.com/emkapp/invoicerecord.php";
    var bdata = {"invnum": dinvoicenum};
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

      if (jsonDecode(jsonEncode(response.data))
          .toString()
          .contains("not found")) {
        setState(() {
          _diagvisibility = false;
        });
        _showsnackbar("Invoice number is incorrect!", "Close");
      } else {
        var njson = json.decode(jsonEncode(response.data));
        var nj = njson as List;
        double tval = nj
            .map((e) => double.parse(e["amtpaid"].replaceAll(',', '')))
            .fold(0, (previousValue, elem) => previousValue + elem);
        var ubalance =
            double.parse(nj[0]["invoiceamount"].replaceAll(',', '')) - tval;
        if (nj[0]["rnum"] == "") {
          setState(() {
            _cinvoice = dinvoicenum;
            _ctotalamount = formatter
                .format(
                    double.parse(nj[0]["invoiceamount"].replaceAll(',', '')))
                .toString();
            _camtpaid = formatter.format(tval).toString();
            _cbalance = formatter.format(ubalance).toString();
            _cname = nj[0]["clientname"].toString();
            _caddress = nj[0]["clientaddress"].toString();
            _contact = nj[0]["clientcontact"].toString();
            _diagvisibility = false;
            _invoicevisibility = false;
            _clchannel = nj[0]["channel"].toString();
          });
        } else {
          receiptlist = json.decode(jsonEncode(response.data));
          setState(() {
            _cinvoice = dinvoicenum;
            _ctotalamount = formatter
                .format(
                    double.parse(nj[0]["invoiceamount"].replaceAll(',', '')))
                .toString();
            _camtpaid = formatter.format(tval).toString();
            _cbalance = formatter.format(ubalance).toString();
            _cname = nj[0]["clientname"].toString();
            _caddress = nj[0]["clientaddress"].toString();
            _contact = nj[0]["clientcontact"].toString();
            _clchannel = nj[0]["channel"].toString();
            _invoicevisibility = false;
            _diagvisibility = false;
            _future = fetchsoldcars();
          });
        }
        _receiptWidget();

        //searchcarresponse = json.decode(response.data);
      }
    } on DioError catch (ex) {
      _showsnackbar("Error : " + ex.message, "Close");
      if (mounted)
        setState(() {
          _diagvisibility = false;
        });

      throw Exception(ex.message);
    }
  }

  _updatepayment(List buyerobj) async {
    var url = "http://www.emkapp.com/emkapp/api/invoice_record.php";
    var bdata = {"buyerUpdateReq": "", "buyerobj": json.encode(buyerobj)};
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

      if (response.data.toString().contains("successfully")) {
        setState(() {
          _diagvisibility = false;
        });
        _scrollController.animateTo(0,
            duration: Duration(seconds: 1), curve: Curves.linear);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext ncontext) => MainAdminDashboard(
                      opt: "10",
                      nrdate: '',
                    )));
        _showsnackbar("The operation was successful", "Close");
      } else {
        setState(() {
          _diagvisibility = false;
        });
        _showsnackbar("Error : " + response.data.toString(), "Close");
      }
    } on DioError catch (ex) {
      _showsnackbar("Error : " + ex.message, "Close");
      if (mounted)
        setState(() {
          _diagvisibility = false;
        });

      throw Exception(ex.message);
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
                  padding: EdgeInsets.all(6.0),
                  child: Stack(children: <Widget>[
                    Center(
                      child: ListView(
                        controller: _scrollController,
                        shrinkWrap: true,
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                decoration: new BoxDecoration(
                                    image: new DecorationImage(
                                  image: new ExactAssetImage(
                                      'assets/images/cars_0045.jpg'),
                                  fit: BoxFit.cover,
                                )),
                                child: Table(columnWidths: {
                                  0: FlexColumnWidth(8.6),
                                  1: FlexColumnWidth(1.4)
                                }, children: [
                                  TableRow(children: [
                                    Container(
                                      height: 50,
                                      width: MediaQuery.of(context).size.width,
                                      color: Colors.black.withOpacity(.8),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text("Invoice No : " + _cinvoice,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Color.fromRGBO(
                                                    255, 255, 255, 1),
                                                fontSize: 18)),
                                      ),
                                    ),
                                    Container(
                                        height: 50,
                                        width:
                                            MediaQuery.of(context).size.width,
                                        color: Colors.black.withOpacity(.8),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            height: 35,
                                            width: 35,
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(25.0)),
                                              gradient: LinearGradient(
                                                colors: <Color>[
                                                  Color.fromRGBO(
                                                      109, 109, 109, 1),
                                                  Color.fromRGBO(
                                                      105, 105, 105, 1)
                                                ],
                                                begin: Alignment(-1.0, -1),
                                                end: Alignment(-1.0, 1),
                                              ),
                                            ),
                                            child: RaisedButton(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  side: BorderSide(
                                                      color: Color.fromRGBO(
                                                          0, 0, 0, 0.09),
                                                      width: 3),
                                                ),
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.0),
                                                textColor: Colors.white,
                                                child: Container(
                                                  transform:
                                                      Matrix4.translationValues(
                                                          -12, 0, 0),
                                                  child: new Icon(
                                                    Icons.read_more,
                                                    size: 25,
                                                  ),
                                                ),
                                                onPressed: () {
                                                  _showpdfDocument(
                                                      "http://www.emkapp.com/emkapp/invoices/" +
                                                          _cinvoice +
                                                          ".pdf");
                                                }),
                                          ),
                                        )),
                                  ]),
                                ]),
                              ),
                              Table(
                                  border: TableBorder.all(
                                      color: Colors.white.withOpacity(.5),
                                      width: .6),
                                  children: [
                                    TableRow(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 10, top: 15),
                                          height: 50,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.black.withOpacity(.8),
                                          child: Text(
                                              "Total amount : Gh¢ " +
                                                  _ctotalamount,
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                  ]),
                              Table(
                                  columnWidths: {
                                    0: FlexColumnWidth(5),
                                    1: FlexColumnWidth(5)
                                  },
                                  border: TableBorder.all(
                                      color: Colors.white.withOpacity(.5),
                                      width: .6),
                                  children: [
                                    TableRow(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 10, top: 15),
                                          height: 50,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.black.withOpacity(.8),
                                          child: Text(
                                              "Amt paid : Gh¢ " + _camtpaid,
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontSize: 16)),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 10, top: 15),
                                          height: 50,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.black.withOpacity(.8),
                                          child: Text(
                                              "Balance : Gh¢ " + _cbalance,
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                  ]),
                              Table(
                                  border: TableBorder.all(
                                      color: Colors.white.withOpacity(.5),
                                      width: .6),
                                  children: [
                                    TableRow(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 10, top: 15),
                                          height: 50,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.black.withOpacity(.8),
                                          child: Text("Name : " + _cname,
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                  ]),
                              Table(
                                  border: TableBorder.all(
                                      color: Colors.white.withOpacity(.5),
                                      width: .6),
                                  children: [
                                    TableRow(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 10, top: 15),
                                          height: 50,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.black.withOpacity(.8),
                                          child: Text(
                                              "Contact No : " + _contact,
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                  ]),
                              Table(
                                  border: TableBorder.all(
                                      color: Colors.white.withOpacity(.5),
                                      width: .6),
                                  children: [
                                    TableRow(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 10, top: 15),
                                          height: 50,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.black.withOpacity(.8),
                                          child: Text("Address : " + _caddress,
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                  ]),
                              Table(
                                  border: TableBorder.all(
                                      color: Colors.white.withOpacity(.5),
                                      width: .6),
                                  children: [
                                    TableRow(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 10, top: 15),
                                          height: 50,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.black.withOpacity(.8),
                                          child: Text("Receipt(s)",
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontSize: 16)),
                                        ),
                                      ],
                                    ),
                                  ]),
                              Table(
                                  columnWidths: {
                                    0: FlexColumnWidth(3),
                                    1: FlexColumnWidth(2.8),
                                    2: FlexColumnWidth(2.8),
                                    3: FlexColumnWidth(1.4),
                                  },
                                  border: TableBorder.all(
                                      color: Colors.white.withOpacity(.5),
                                      width: .6),
                                  children: [
                                    TableRow(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 10, top: 15),
                                          height: 50,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.black.withOpacity(.8),
                                          child: Text("Receipt No.",
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontSize: 16)),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 10, top: 15),
                                          height: 50,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.black.withOpacity(.8),
                                          child: Text("Date Issued",
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontSize: 16)),
                                        ),
                                        Container(
                                          padding: EdgeInsets.only(
                                              left: 10, top: 15),
                                          height: 50,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.black.withOpacity(.8),
                                          child: Text("Amount Paid",
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontSize: 16)),
                                        ),
                                        Container(
                                          height: 50,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Colors.black.withOpacity(.8),
                                        ),
                                      ],
                                    ),
                                  ]),
                              _receiptWidget(),
                              Container(
                                height: 50,
                                width: MediaQuery.of(context).size.width,
                                decoration: new BoxDecoration(
                                    image: new DecorationImage(
                                  image: new ExactAssetImage(
                                      'assets/images/cars_0045.jpg'),
                                  fit: BoxFit.cover,
                                )),
                                child: Container(
                                  height: 50,
                                  width: MediaQuery.of(context).size.width,
                                  color: Colors.black.withOpacity(.8),
                                  child: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      padding: EdgeInsets.only(left: 15),
                                      width: MediaQuery.of(context).size.width *
                                          0.42,
                                      height: 35,
                                      child: new RaisedButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            side: BorderSide(
                                                color: Color.fromRGBO(
                                                    0, 0, 0, 0.09),
                                                width: 3),
                                          ),
                                          color: Color.fromRGBO(0, 0, 11, 1),
                                          textColor: Colors.white,
                                          child: new Text(
                                            "Add New Payment",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _buyerformvisibility = true;
                                              _buyerinvoicecon.text = _cinvoice;
                                              _buyernamecon.text = _cname;
                                              _buyeraddresscon.text = _caddress;
                                              _buyercontactcon.text = _contact;
                                              _showbuyerform();
                                            });
                                          }),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Visibility(
                      visible: _invoicevisibility,
                      child: new Container(
                        padding: const EdgeInsets.all(14.0),
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        color: Color.fromRGBO(0, 0, 0, 0.7),
                        child: Center(
                          child: Container(
                            child: ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              child: ListView(
                                children: <Widget>[
                                  Container(
                                    padding: EdgeInsets.only(top: 10),
                                    child: Text(
                                      'Enter Invoice Number Here',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    height: 40,
                                    width: MediaQuery.of(context).size.width,
                                    color: Color.fromRGBO(0, 0, 10, .9),
                                  ),
                                  Form(
                                    key: _invoiceformkey,
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
                                      child: Column(
                                        children: <Widget>[
                                          new TextFormField(
                                            controller: _invoicenumcontroller,
                                            decoration: new InputDecoration(
                                              labelText: "Invoice Number",
                                              prefixIcon:
                                                  Icon(Icons.car_rental),
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
                                                _invoicenumcontroller.text =
                                                    newValue!;
                                              });
                                            },
                                            keyboardType: TextInputType.text,
                                          ),
                                          Padding(
                                              padding:
                                                  EdgeInsets.only(top: 20)),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              Container(
                                                padding:
                                                    EdgeInsets.only(left: 15),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.28,
                                                height: 40,
                                                child: new RaisedButton(
                                                    shape:
                                                        RoundedRectangleBorder(
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
                                                      "Submit",
                                                      style: TextStyle(
                                                          fontSize: 12),
                                                    ),
                                                    onPressed: () {
                                                      final form =
                                                          _invoiceformkey
                                                              .currentState;
                                                      if (form!.validate()) {
                                                        form.save();

                                                        message =
                                                            'Please wait, request is being processed...';

                                                        // _showsnackbar(
                                                        //   message, "Close");

                                                        _getinvoicedata(
                                                            _invoicenumcontroller
                                                                .text);
                                                      }
                                                    }),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            width: MediaQuery.of(context).size.width,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Color.fromRGBO(53, 53, 53, 1),
                              border: Border.all(
                                  color: Color.fromRGBO(73, 73, 73, .3),
                                  width: 5),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                        visible: _pdfvisibility, child: _showpdfLayout()),
                    Visibility(
                        visible: _buyerformvisibility, child: _showbuyerform()),
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
