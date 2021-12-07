import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

import 'helperclass.dart';
import 'lockscreen.dart';
import 'login.dart';

void main() {
  runApp(Debtors());
}

class Debtors extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
      title: 'EM-KAPP',
      debugShowCheckedModeBanner: false,
      home: MainMainDebtors(),
    );
  }
}

class MainMainDebtors extends StatefulWidget {
  MainMainDebtors({Key? key}) : super(key: key);

  @override
  State createState() => _MainDebtorsState();
}

class _MainDebtorsState extends State<MainMainDebtors>
    with TickerProviderStateMixin {
  late AnimationController _animcon;
  late AnimationController _iconanimcontroller, _fabcon;
  late Animation<double> _iconanim;
  ScrollController _outerscrollController =
      ScrollController(keepScrollOffset: true);
  ScrollController _innerscrollController =
      ScrollController(keepScrollOffset: true);
  TextEditingController _searchcon = new TextEditingController();
  GlobalKey<FormState> _searchformkey = GlobalKey<FormState>();
  Future<List<ClientUpdatePayment>>? _cfuture;
  List receiptlist = [];
  Future<List<ClientUpdatePayment>> fetchsoldcars() async {
    return receiptlist.map((e) => new ClientUpdatePayment.fromJson(e)).toList();
  }

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
    getalldebtors();
    super.initState();
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
            _cfuture = fetchsoldcars();
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

  getalldebtors() async {
    var url = 'http://www.emkapp.com/emkapp/debtors.php';
    var bdata = {"getallinvoicesandreceipts": "true"};
    FormData fdata = FormData.fromMap(bdata);
    setState(() {
      _diagvisibility = true;
    });

    BaseOptions options = new BaseOptions(
      baseUrl: "http://www.emkapp.com/emkapp",
      connectTimeout: 100000,
      receiveTimeout: 3000,
    );

    Dio dio = new Dio(options);

    try {
      var response = await dio.post(url, data: fdata);
      print(response.data);
      if (jsonDecode(jsonEncode(response.data))
          .toString()
          .contains("no records available")) {
        setState(() {
          _diagvisibility = false;
          _serverDataWidget();
        });
      } else {
        setState(() {
          serverresponse = json.decode(jsonEncode(response.data));
          secondserverresponse = json.decode(jsonEncode(response.data));
          _diagvisibility = false;

          _future = fetchalldebtors();
          _serverDataWidget();
        });

        //searchactiveadminresponse = json.decode(response.body);
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

  String _cinvoice = "",
      _creceipt = "",
      _ctotalamount = "",
      _camtpaid = "",
      _cbalance = "",
      _cname = "",
      _caddress = "",
      _contact = "",
      _documenturl = "",
      _fileurl = "",
      _clchannel = "";

  List serverresponse = [],
      secondserverresponse = [],
      searchserverresponse = [];
  Future<List<CDebtors>> fetchalldebtors() async {
    return serverresponse.map((e) => new CDebtors.fromJson(e)).toList();
  }

  Future<List<CDebtors>> searchalldebtors() async {
    return searchserverresponse.map((e) => new CDebtors.fromJson(e)).toList();
  }

  Future<List<CDebtors>>? _future;

  @override
  void dispose() {
    _animcon.dispose();
    _iconanimcontroller.dispose();
    _searchcon.dispose();
    super.dispose();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool pressed = false,
      _obscuretext = false,
      _visibility = false,
      _clearbtnvisibility = false,
      _searchbtnvisibility = true,
      _pdfvisibility = false,
      _invoicevisibility = true;

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
      _cartvisibility = false,
      _detailsvisibility = false;
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

  Widget _tableWidget() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      color: Colors.black.withOpacity(.4),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
            width: MediaQuery.of(context).size.width,
            color: Color.fromRGBO(0, 0, 12, 1),
            child: Form(
              key: _searchformkey,
              child: Theme(
                data: new ThemeData(
                  brightness: Brightness.dark,
                  primarySwatch: Colors.amber,
                  inputDecorationTheme: new InputDecorationTheme(
                    labelStyle: new TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width - 70,
                      child: FocusScope(
                        child: Focus(
                          onFocusChange: (value) {
                            //print("Focus : $value");
                            //  _showsnackbar(
                            //    "Focus : $value", "Okay");
                          },
                          child: new TextFormField(
                            style: TextStyle(color: Colors.white),
                            controller: _searchcon,
                            readOnly: false,
                            maxLines: 1,
                            decoration: new InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.all(5),
                                hintText: "Search here or by date (yyyy-mm-dd)",
                                hintStyle:
                                    TextStyle(color: Colors.grey.shade600),
                                filled: true,
                                fillColor: Colors.grey.shade900,
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: Colors.grey.shade800, width: 2),
                                    borderRadius: BorderRadius.circular(10))),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return null;
                              } else {
                                return null;
                              }
                            },
                            onChanged: (value) {
                              setState(() {
                                _clearbtnvisibility = false;
                                _searchbtnvisibility = true;
                              });
                            },
                            onSaved: (newValue) {},
                            keyboardType: TextInputType.text,
                          ),
                        ),
                      ),
                    ),
                    Padding(padding: EdgeInsets.only(top: 20)),
                    Stack(
                      children: [
                        Visibility(
                          visible: _clearbtnvisibility,
                          child: new GestureDetector(
                            onTap: () {
                              setState(() {
                                _clearbtnvisibility = false;
                                _searchbtnvisibility = true;

                                _searchformkey.currentState!.reset();
                                _future = fetchalldebtors();
                                _searchcon.clear();
                                _searchcon.text = "";
                              });
                            },
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35))),
                              child: Icon(
                                Icons.clear_all_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                          visible: _searchbtnvisibility,
                          child: new GestureDetector(
                            onTap: () {
                              final form = _searchformkey.currentState;
                              if (form!.validate()) {
                                form.save();
                                searchserverresponse = secondserverresponse
                                    .where((i) =>
                                        i["name"]
                                            .toString()
                                            .toLowerCase()
                                            .contains(_searchcon.text) ||
                                        i["name"]
                                            .toString()
                                            .contains(_searchcon.text) ||
                                        i["invoicenum"]
                                            .toString()
                                            .toLowerCase()
                                            .contains(_searchcon.text) ||
                                        i["invoicenum"]
                                            .toString()
                                            .contains(_searchcon.text) ||
                                        i["contact"]
                                            .toString()
                                            .contains(_searchcon.text) ||
                                        i["dateissued"]
                                            .toString()
                                            .contains(_searchcon.text))
                                    .toList();
                                setState(() {
                                  _future = searchalldebtors();
                                  _clearbtnvisibility = true;
                                  _searchbtnvisibility = false;
                                });
                              }
                            },
                            child: Container(
                              height: 35,
                              width: 35,
                              decoration: BoxDecoration(
                                  color: Colors.grey[900],
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(35))),
                              child: Icon(
                                Icons.search,
                                size: 20,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            controller: _outerscrollController,
            scrollDirection: Axis.vertical,
            child: Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                padding: EdgeInsets.all(10),
                child: SingleChildScrollView(
                  controller: _innerscrollController,
                  scrollDirection: Axis.horizontal,
                  child: Column(
                    children: [
                      Container(width: 1490, child: _serverDataWidget())
                    ],
                  ),
                )),
          ))
        ],
      ),
    );
  }

  Widget _verticaldivider = const VerticalDivider(
    color: Colors.white,
    thickness: 1,
  );

  bool _nodatavisible = false;
  var formatter = NumberFormat('#,###,000');
  Widget _serverDataWidget() {
    var datawidget;
    if (serverresponse.isEmpty) {
      datawidget = Table(
        columnWidths: {0: FixedColumnWidth(1380)},
        border: TableBorder.all(color: Colors.white.withOpacity(.5), width: .6),
        children: [
          TableRow(children: [
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(left: 10, top: 15, bottom: 15),
              height: 65,
              width: MediaQuery.of(context).size.width,
              color: Colors.black.withOpacity(.8),
              child: Text("No Data Available",
                  style: TextStyle(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      fontSize: 19,
                      fontWeight: FontWeight.bold)),
            ),
          ])
        ],
      );
    } else {
      datawidget = Container(
        width: MediaQuery.of(this.context).size.width,
        height: MediaQuery.of(this.context).size.height - 95,
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: ScrollPhysics(),
              controller: _innerscrollController,
              child: Column(
                children: [
                  FutureBuilder<List<CDebtors>>(
                      future: _future,
                      builder: (BuildContext context,
                          AsyncSnapshot<List<CDebtors>> snapshot) {
                        //print("list items : " + carresponse.toString());
                        Widget newsListSliver;
                        if (snapshot.hasData) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              dividerColor: Colors.white,
                            ),
                            child: DataTable(
                                decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(.7),
                                    border: Border.all(
                                        width: 1, color: Colors.white)),
                                dividerThickness: 1,
                                horizontalMargin: 0,
                                columnSpacing: 0,
                                dataRowHeight: 70,
                                columns: <DataColumn>[
                                  DataColumn(
                                      label: Align(
                                    alignment: Alignment.center,
                                    child: Container(
                                      width: 300,
                                      child: Text(
                                        "Name",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'serif',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700),
                                      ),
                                    ),
                                  )),
                                  DataColumn(label: _verticaldivider),
                                  DataColumn(
                                      label: Container(
                                    width: 200,
                                    child: Text("Contact",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'serif',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700)),
                                  )),
                                  DataColumn(label: _verticaldivider),
                                  DataColumn(
                                      label: Container(
                                    width: 200,
                                    child: Text("Total Amount",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'serif',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700)),
                                  )),
                                  DataColumn(label: _verticaldivider),
                                  DataColumn(
                                      label: Container(
                                    width: 200,
                                    child: Text("Amount Paid",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'serif',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700)),
                                  )),
                                  DataColumn(label: _verticaldivider),
                                  DataColumn(
                                      label: Container(
                                    width: 200,
                                    child: Text("Balance",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'serif',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700)),
                                  )),
                                  DataColumn(label: _verticaldivider),
                                  DataColumn(
                                      label: Container(
                                    width: 200,
                                    child: Text("Duration",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'serif',
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700)),
                                  )),
                                  DataColumn(label: _verticaldivider),
                                  DataColumn(label: Text(""))
                                ],
                                rows: snapshot.data!
                                    .map((e) => DataRow(cells: <DataCell>[
                                          DataCell(Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                left: 10, top: 15, bottom: 15),
                                            height: 65,
                                            width: 300,
                                            color: Colors.black.withOpacity(.0),
                                            child: Text(e.name,
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontSize: 16,
                                                )),
                                          )),
                                          DataCell(_verticaldivider),
                                          DataCell(Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                left: 10, top: 15, bottom: 15),
                                            height: 65,
                                            width: 200,
                                            color: Colors.black.withOpacity(.0),
                                            child: Text(e.contact,
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontSize: 16,
                                                )),
                                          )),
                                          DataCell(_verticaldivider),
                                          DataCell(Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                left: 10, top: 15, bottom: 15),
                                            height: 65,
                                            width: 200,
                                            color: Colors.black.withOpacity(.0),
                                            child: Text(
                                                "Gh¢ " +
                                                    formatter.format(
                                                        double.parse(e
                                                            .totalamount
                                                            .replaceAll(
                                                                ',', ''))),
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontSize: 16,
                                                )),
                                          )),
                                          DataCell(_verticaldivider),
                                          DataCell(Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                left: 10, top: 15, bottom: 15),
                                            height: 65,
                                            width: 200,
                                            color: Colors.black.withOpacity(.0),
                                            child: Text(
                                                "Gh¢ " +
                                                    formatter.format(
                                                        double.parse(e
                                                            .amtpaid
                                                            .replaceAll(
                                                                ',', ''))),
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontSize: 16,
                                                )),
                                          )),
                                          DataCell(_verticaldivider),
                                          DataCell(Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                left: 10, top: 15, bottom: 15),
                                            height: 65,
                                            width: 200,
                                            color: Colors.black.withOpacity(.0),
                                            child: Text(
                                                "Gh¢ " +
                                                    formatter.format(
                                                        double.parse(e
                                                            .balance
                                                            .replaceAll(
                                                                ',', ''))),
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontSize: 16,
                                                )),
                                          )),
                                          DataCell(_verticaldivider),
                                          DataCell(Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                left: 10, top: 15, bottom: 15),
                                            height: 65,
                                            width: 200,
                                            color: Colors.black.withOpacity(.0),
                                            child: Text(e.duration,
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontSize: 16,
                                                )),
                                          )),
                                          DataCell(_verticaldivider),
                                          DataCell(Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                left: 10, top: 15, bottom: 15),
                                            height: 65,
                                            width: 80,
                                            color: Colors.black.withOpacity(.0),
                                            child: Align(
                                              alignment: Alignment.center,
                                              child: Container(
                                                height: 35,
                                                width: 35,
                                                decoration: const BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              25.0)),
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
                                                      setState(() {
                                                        _detailsvisibility =
                                                            true;
                                                      });
                                                      _getinvoicedata(
                                                          e.invoicenum);
                                                    }),
                                              ),
                                            ),
                                          )),
                                        ]))
                                    .toList()),
                          );
                          newsListSliver = ListView.builder(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              controller: _outerscrollController,
                              itemCount: snapshot.data!.length,
                              itemBuilder: (BuildContext context, int index) {
                                CDebtors item = snapshot.data![index];

                                return Column(
                                  children: <Widget>[
                                    Table(
                                      columnWidths: {
                                        0: FixedColumnWidth(300),
                                        1: FixedColumnWidth(200),
                                        2: FixedColumnWidth(200),
                                        3: FixedColumnWidth(200),
                                        4: FixedColumnWidth(200),
                                        5: FixedColumnWidth(200),
                                        6: FixedColumnWidth(80),
                                      },
                                      border: TableBorder.all(
                                          color: Colors.white.withOpacity(.5),
                                          width: .6),
                                      children: [
                                        TableRow(children: [
                                          Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                left: 10, top: 15, bottom: 15),
                                            height: 65,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            color: Colors.black.withOpacity(.8),
                                            child: Text(item.name,
                                                style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      255, 255, 255, 1),
                                                  fontSize: 16,
                                                )),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                left: 10, top: 15, bottom: 15),
                                            height: 65,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            color: Colors.black.withOpacity(.8),
                                            child: Text(item.contact,
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        255, 255, 255, 1),
                                                    fontSize: 16)),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                left: 10, top: 15, bottom: 15),
                                            height: 65,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            color: Colors.black.withOpacity(.8),
                                            child: Text(
                                                "Gh¢ " +
                                                    formatter.format(
                                                        double.parse(item
                                                            .totalamount
                                                            .replaceAll(
                                                                ',', ''))),
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        255, 255, 255, 1),
                                                    fontSize: 16)),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                left: 10, top: 15, bottom: 15),
                                            height: 65,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            color: Colors.black.withOpacity(.8),
                                            child: Text(
                                                "Gh¢ " +
                                                    formatter.format(
                                                        double.parse(item
                                                            .amtpaid
                                                            .toString()
                                                            .replaceAll(
                                                                ',', ''))),
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        255, 255, 255, 1),
                                                    fontSize: 16)),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                left: 10, top: 15, bottom: 15),
                                            height: 65,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            color: Colors.black.withOpacity(.8),
                                            child: Text(
                                                "Gh¢ " +
                                                    formatter.format(
                                                        double.parse(item
                                                            .balance
                                                            .replaceAll(
                                                                ',', ''))),
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        255, 255, 255, 1),
                                                    fontSize: 16)),
                                          ),
                                          Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                left: 10, top: 15, bottom: 15),
                                            height: 65,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            color: Colors.black.withOpacity(.8),
                                            child: Text(
                                                item.duration.toUpperCase(),
                                                style: TextStyle(
                                                    color: Color.fromRGBO(
                                                        255, 255, 255, 1),
                                                    fontSize: 16)),
                                          ),
                                          Container(
                                              height: 65,
                                              width: MediaQuery.of(context)
                                                  .size
                                                  .width,
                                              color:
                                                  Colors.black.withOpacity(.8),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Container(
                                                  height: 35,
                                                  width: 35,
                                                  decoration:
                                                      const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                25.0)),
                                                    gradient: LinearGradient(
                                                      colors: <Color>[
                                                        Color.fromRGBO(
                                                            109, 109, 109, 1),
                                                        Color.fromRGBO(
                                                            105, 105, 105, 1)
                                                      ],
                                                      begin:
                                                          Alignment(-1.0, -1),
                                                      end: Alignment(-1.0, 1),
                                                    ),
                                                  ),
                                                  child: RaisedButton(
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15),
                                                        side: BorderSide(
                                                            color:
                                                                Color.fromRGBO(
                                                                    0,
                                                                    0,
                                                                    0,
                                                                    0.09),
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
                                                      onPressed: () {}),
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
            ),
            Visibility(
              visible: _nodatavisible,
              child: Table(
                columnWidths: {0: FixedColumnWidth(1380)},
                border: TableBorder.all(
                    color: Colors.white.withOpacity(.5), width: .6),
                children: [
                  TableRow(children: [
                    Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(left: 10, top: 15, bottom: 15),
                      height: 65,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black.withOpacity(.8),
                      child: Text("No Data Available",
                          style: TextStyle(
                              color: Color.fromRGBO(255, 255, 255, 1),
                              fontSize: 19,
                              fontWeight: FontWeight.bold)),
                    ),
                  ])
                ],
              ),
            )
          ],
        ),
      );
    }

    return datawidget;
  }

  Widget _detailsWidget() {
    return Center(
      child: ListView(
        controller: _outerscrollController,
        shrinkWrap: true,
        children: <Widget>[
          Column(
            children: <Widget>[
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width,
                decoration: new BoxDecoration(
                    image: new DecorationImage(
                  image: new ExactAssetImage('assets/images/cars_0045.jpg'),
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
                                color: Color.fromRGBO(255, 255, 255, 1),
                                fontSize: 18)),
                      ),
                    ),
                    Container(
                        height: 50,
                        width: MediaQuery.of(context).size.width,
                        color: Colors.black.withOpacity(.8),
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: 35,
                            width: 35,
                            decoration: const BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(25.0)),
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color.fromRGBO(109, 109, 109, 1),
                                  Color.fromRGBO(105, 105, 105, 1)
                                ],
                                begin: Alignment(-1.0, -1),
                                end: Alignment(-1.0, 1),
                              ),
                            ),
                            child: RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                  side: BorderSide(
                                      color: Color.fromRGBO(0, 0, 0, 0.09),
                                      width: 3),
                                ),
                                color: Color.fromRGBO(0, 0, 0, 0.0),
                                textColor: Colors.white,
                                child: Container(
                                  transform:
                                      Matrix4.translationValues(-12, 0, 0),
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
                      color: Colors.white.withOpacity(.5), width: .6),
                  children: [
                    TableRow(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10, top: 15),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black.withOpacity(.8),
                          child: Text("Total amount : Gh¢ " + _ctotalamount,
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 16)),
                        ),
                      ],
                    ),
                  ]),
              Table(
                  columnWidths: {0: FlexColumnWidth(5), 1: FlexColumnWidth(5)},
                  border: TableBorder.all(
                      color: Colors.white.withOpacity(.5), width: .6),
                  children: [
                    TableRow(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10, top: 15),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black.withOpacity(.8),
                          child: Text("Amt paid : Gh¢ " + _camtpaid,
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 16)),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10, top: 15),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black.withOpacity(.8),
                          child: Text("Balance : Gh¢ " + _cbalance,
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 16)),
                        ),
                      ],
                    ),
                  ]),
              Table(
                  border: TableBorder.all(
                      color: Colors.white.withOpacity(.5), width: .6),
                  children: [
                    TableRow(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10, top: 15),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black.withOpacity(.8),
                          child: Text("Name : " + _cname,
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 16)),
                        ),
                      ],
                    ),
                  ]),
              Table(
                  border: TableBorder.all(
                      color: Colors.white.withOpacity(.5), width: .6),
                  children: [
                    TableRow(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10, top: 15),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black.withOpacity(.8),
                          child: Text("Contact No : " + _contact,
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 16)),
                        ),
                      ],
                    ),
                  ]),
              Table(
                  border: TableBorder.all(
                      color: Colors.white.withOpacity(.5), width: .6),
                  children: [
                    TableRow(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10, top: 15),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black.withOpacity(.8),
                          child: Text("Address : " + _caddress,
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 16)),
                        ),
                      ],
                    ),
                  ]),
              Table(
                  border: TableBorder.all(
                      color: Colors.white.withOpacity(.5), width: .6),
                  children: [
                    TableRow(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10, top: 15),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black.withOpacity(.8),
                          child: Text("Receipt(s)",
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
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
                      color: Colors.white.withOpacity(.5), width: .6),
                  children: [
                    TableRow(
                      children: [
                        Container(
                          padding: EdgeInsets.only(left: 10, top: 15),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black.withOpacity(.8),
                          child: Text("Receipt No.",
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 16)),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10, top: 15),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black.withOpacity(.8),
                          child: Text("Date Issued",
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 16)),
                        ),
                        Container(
                          padding: EdgeInsets.only(left: 10, top: 15),
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          color: Colors.black.withOpacity(.8),
                          child: Text("Amount Paid",
                              style: TextStyle(
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                  fontSize: 16)),
                        ),
                        Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
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
                  image: new ExactAssetImage('assets/images/cars_0045.jpg'),
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
                      width: MediaQuery.of(context).size.width * 0.42,
                      height: 35,
                      child: new RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                            side: BorderSide(
                                color: Color.fromRGBO(0, 0, 0, 0.09), width: 3),
                          ),
                          color: Color.fromRGBO(0, 0, 11, 1),
                          textColor: Colors.white,
                          child: new Text(
                            "Close",
                            style: TextStyle(fontSize: 15),
                          ),
                          onPressed: () {
                            setState(() {
                              _detailsvisibility = false;
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
    );
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
                  future: _cfuture,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<ClientUpdatePayment>> snapshot) {
                    //print("list items : " + carresponse.toString());
                    Widget newsListSliver;
                    if (snapshot.hasData) {
                      newsListSliver = ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          controller: _outerscrollController,
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

    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                    _tableWidget(),
                    Visibility(
                      visible: _detailsvisibility,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1,
                        height: MediaQuery.of(context).size.height * 1,
                        padding: const EdgeInsets.only(bottom: 0),
                        decoration: new BoxDecoration(
                            image: new DecorationImage(
                          image: new ExactAssetImage(
                              'assets/images/cars_0045.jpg'),
                          fit: BoxFit.fill,
                        )),
                        child: new BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 7.0, sigmaY: 7.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width * 1,
                            height: MediaQuery.of(context).size.height * 1,
                            decoration: new BoxDecoration(
                                color: Colors.black.withOpacity(0.4)),
                            child: Center(
                              child: new Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                child: _detailsWidget(),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Visibility(
                        visible: _pdfvisibility, child: _showpdfLayout()),
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
