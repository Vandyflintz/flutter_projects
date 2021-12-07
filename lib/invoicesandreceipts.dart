import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:states_rebuilder/states_rebuilder.dart';

import 'helperclass.dart';
import 'lockscreen.dart';
import 'login.dart';

void main() {
  runApp(InvoicesAndReceiptsContainer());
}

class InvoicesAndReceiptsContainer extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
      title: 'EM-KAPP',
      debugShowCheckedModeBanner: false,
      home: MainInvoicesAndReceiptsContainer(),
    );
  }
}

class MainInvoicesAndReceiptsContainer extends StatefulWidget {
  MainInvoicesAndReceiptsContainer({Key? key}) : super(key: key);

  @override
  State createState() => _InvoicesAndReceiptsContainerState();
}

class _InvoicesAndReceiptsContainerState
    extends State<MainInvoicesAndReceiptsContainer>
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
    _getinvoicesandreceipts();
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

  @override
  void dispose() {
    _animcon.dispose();
    // _iconanimcontroller.dispose();
    super.dispose();
  }

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool pressed = false, _obscuretext = false, _visibility = false;
  List<bool> isInvoicePrinted = [], isReceiptPrinted = [];
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

  List serverresponse = [];
  Future<List<InvoicesAndReceipts>>? _future;
  Future<List<InvoicesAndReceipts>> fetchinvoicesandreceipts() async {
    return serverresponse
        .map((e) => new InvoicesAndReceipts.fromJson(e))
        .toList();
  }

  _fetchinvoice(String pfile, int index) async {
    setState(() {
      _diagvisibility = true;
    });
    var url = 'http://www.emkapp.com/emkapp/invoices/' + pfile + ".pdf";
    BaseOptions options = new BaseOptions(
      baseUrl: "http://www.emkapp.com/emkapp",
      connectTimeout: 15000,
      receiveTimeout: 3000,
      responseType: ResponseType.bytes,
      followRedirects: false,
      validateStatus: (status) {
        return status! < 500;
      },
    );

    Dio dio = new Dio(options);

    try {
      var response = await dio.get(url);

      setState(() {
        _diagvisibility = false;
      });

      await Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext dcontext) => SafeArea(
                      child: PdfPreview(
                    build: (PdfPageFormat format) => response.data,
                    onPrinted: (dcontext) {
                      Navigator.of(dcontext).pop();
                      setState(() {
                        isInvoicePrinted[index] = true;
                      });
                      if (isInvoicePrinted[index].toString() == "true" &&
                          isReceiptPrinted[index].toString() == "true") {
                        _updateinvoices(pfile);
                      }
                    },
                  ))));
    } catch (ex) {
      _showsnackbar("Error : " + ex.toString(), "Close");
    }
  }

  _fetchreceipts(String pfile, int index) async {
    setState(() {
      _diagvisibility = true;
    });
    var url = 'http://www.emkapp.com/emkapp/receipts/' + pfile + ".pdf";
    BaseOptions options = new BaseOptions(
      baseUrl: "http://www.emkapp.com/emkapp",
      connectTimeout: 15000,
      receiveTimeout: 3000,
      responseType: ResponseType.bytes,
      followRedirects: false,
      validateStatus: (status) {
        return status! < 500;
      },
    );

    Dio dio = new Dio(options);

    try {
      var response = await dio.get(url);

      setState(() {
        _diagvisibility = false;
      });

      await Navigator.push<dynamic>(
          context,
          MaterialPageRoute<dynamic>(
              builder: (BuildContext dcontext) => SafeArea(
                      child: PdfPreview(
                    build: (PdfPageFormat format) => response.data,
                    onPrinted: (dcontext) {
                      Navigator.of(dcontext).pop();
                      setState(() {
                        isReceiptPrinted[index] = true;
                      });
                      if (isInvoicePrinted[index].toString() == "true" &&
                          isReceiptPrinted[index].toString() == "true") {
                        _updatereceipts(pfile);
                      }
                    },
                  ))));
    } catch (ex) {
      _showsnackbar("Error : " + ex.toString(), "Close");
    }
  }

  _updateinvoices(String dpfile) async {
    var url = 'http://www.emkapp.com/emkapp/invoicerecord.php';
    var bdata = {"updateinvoiceandreceiptone": "true", "invoicenum": dpfile};
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
      _getinvoicesandreceipts();
    } on DioError catch (ex) {
      _showsnackbar("Error : " + ex.message, "Close");
      if (mounted)
        setState(() {
          _diagvisibility = false;
        });

      throw Exception(ex.message);
    }
  }

  _updatereceipts(String dpfile) async {
    var url = 'http://www.emkapp.com/emkapp/invoicerecord.php';
    var bdata = {"updateinvoiceandreceiptone": "true", "receiptnum": dpfile};
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
      _getinvoicesandreceipts();
    } on DioError catch (ex) {
      _showsnackbar("Error : " + ex.message, "Close");
      if (mounted)
        setState(() {
          _diagvisibility = false;
        });

      throw Exception(ex.message);
    }
  }

  _getinvoicesandreceipts() async {
    var url = 'http://www.emkapp.com/emkapp/invoicerecord.php';
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
          _allInvoicesWidget();
        });
      } else {
        setState(() {
          serverresponse = json.decode(jsonEncode(response.data));
          _diagvisibility = false;
          isInvoicePrinted =
              List<bool>.generate(serverresponse.length, (index) => false);
          isReceiptPrinted =
              List<bool>.generate(serverresponse.length, (index) => false);
          _future = fetchinvoicesandreceipts();
          _allInvoicesWidget();
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

  Widget _allInvoicesWidget() {
    var datawidget;
    if (serverresponse.isEmpty) {
      datawidget = Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.black.withOpacity(.5),
        child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "No data available",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'serif',
                  fontSize: 30,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 50),
                child: Container(
                  width: 150,
                  height: 38,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
                    gradient: LinearGradient(
                      colors: <Color>[
                        Color(0xBD212121),
                        Color.fromRGBO(0, 0, 15, .89)
                      ],
                      begin: Alignment(-1.0, -1),
                      end: Alignment(-1.0, 1),
                    ),
                  ),
                  child: new RaisedButton(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                            color: Color.fromRGBO(0, 0, 0, 0.09), width: 3),
                      ),
                      color: Color.fromRGBO(0, 0, 0, 0.0),
                      textColor: Colors.white,
                      child: Container(
                        child: new Text(
                          'Refresh',
                          style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'serif',
                              fontWeight: FontWeight.bold,
                              fontSize: 18),
                        ),
                      ),
                      onPressed: () {
                        _getinvoicesandreceipts();
                      }),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      datawidget = SingleChildScrollView(
          physics: ScrollPhysics(),
          controller: _scrollController,
          child: Column(
            children: [
              FutureBuilder<List<InvoicesAndReceipts>>(
                  future: _future,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<InvoicesAndReceipts>> snapshot) {
                    //print("list items : " + carresponse.toString());
                    Widget newsListSliver;
                    if (snapshot.hasData) {
                      newsListSliver = ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          controller: _scrollController,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            InvoicesAndReceipts item = snapshot.data![index];
                            return Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  width: MediaQuery.of(context).size.width,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color: Colors.black.withOpacity(.5)),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 50,
                                        decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                          colors: <Color>[
                                            Colors.grey.shade900
                                                .withOpacity(.89),
                                            Color.fromRGBO(0, 0, 0, .89),
                                          ],
                                          begin: Alignment(-1.0, -1),
                                          end: Alignment(-1.0, 1),
                                        )),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            item.clientname,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'serif',
                                                fontSize: 18),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 10.0),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.42,
                                              height: 261,
                                              decoration: BoxDecoration(
                                                color: Color.fromRGBO(
                                                    0, 0, 20, .4),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(.8),
                                                  width: 1,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      child: new Text(
                                                        "Invoice",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: new TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14.0,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                    Divider(
                                                      color: Colors.white
                                                          .withOpacity(.4),
                                                      height: 1,
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          top: 15.0,
                                                          bottom: 15.0,
                                                          left: 10,
                                                          right: 10),
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                        child: Icon(
                                                          Icons
                                                              .receipt_long_rounded,
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.25,
                                                          color: Colors
                                                              .grey.shade400,
                                                        ),
                                                      ),
                                                    ),
                                                    Divider(
                                                      color: Colors.white
                                                          .withOpacity(.4),
                                                      height: 1,
                                                    ),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      child: new Text(
                                                        "Invoice No : \n" +
                                                            item.invoicenum,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: new TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14.0,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                    Divider(
                                                      color: Colors.white
                                                          .withOpacity(.4),
                                                      height: 1,
                                                    ),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      child: Container(
                                                        width: 150,
                                                        height: 38,
                                                        decoration:
                                                            const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12.0)),
                                                          gradient:
                                                              LinearGradient(
                                                            colors: <Color>[
                                                              Color(0xBD212121),
                                                              Color.fromRGBO(
                                                                  0, 0, 15, .89)
                                                            ],
                                                            begin: Alignment(
                                                                -1.0, -1),
                                                            end: Alignment(
                                                                -1.0, 1),
                                                          ),
                                                        ),
                                                        child: new RaisedButton(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              side: BorderSide(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.09),
                                                                  width: 3),
                                                            ),
                                                            color:
                                                                Color.fromRGBO(
                                                                    0,
                                                                    0,
                                                                    0,
                                                                    0.0),
                                                            textColor:
                                                                Colors.white,
                                                            child: Container(
                                                              child: new Text(
                                                                'Print',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontFamily:
                                                                        'serif',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        18),
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              _fetchinvoice(
                                                                  item.invoicenum,
                                                                  index);
                                                            }),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.42,
                                              height: 261,
                                              decoration: BoxDecoration(
                                                color: Color.fromRGBO(
                                                    0, 0, 20, .4),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(15)),
                                                border: Border.all(
                                                  color: Colors.grey
                                                      .withOpacity(.8),
                                                  width: 1,
                                                ),
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(15.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      child: new Text(
                                                        "Receipt",
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: new TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14.0,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                    Divider(
                                                      color: Colors.white
                                                          .withOpacity(.4),
                                                      height: 1,
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          top: 15.0,
                                                          bottom: 15.0,
                                                          left: 10,
                                                          right: 10),
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      child: ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(15.0),
                                                        child: Icon(
                                                          Icons
                                                              .receipt_long_rounded,
                                                          size: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.25,
                                                          color: Colors
                                                              .grey.shade400,
                                                        ),
                                                      ),
                                                    ),
                                                    Divider(
                                                      color: Colors.white
                                                          .withOpacity(.4),
                                                      height: 1,
                                                    ),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      child: new Text(
                                                        "Receeipt No : \n" +
                                                            item.receiptnum,
                                                        textAlign:
                                                            TextAlign.center,
                                                        style: new TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14.0,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ),
                                                    Divider(
                                                      color: Colors.white
                                                          .withOpacity(.4),
                                                      height: 1,
                                                    ),
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(5),
                                                      child: Container(
                                                        width: 150,
                                                        height: 38,
                                                        decoration:
                                                            const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          12.0)),
                                                          gradient:
                                                              LinearGradient(
                                                            colors: <Color>[
                                                              Color(0xBD212121),
                                                              Color.fromRGBO(
                                                                  0, 0, 15, .89)
                                                            ],
                                                            begin: Alignment(
                                                                -1.0, -1),
                                                            end: Alignment(
                                                                -1.0, 1),
                                                          ),
                                                        ),
                                                        child: new RaisedButton(
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          15),
                                                              side: BorderSide(
                                                                  color: Color
                                                                      .fromRGBO(
                                                                          0,
                                                                          0,
                                                                          0,
                                                                          0.09),
                                                                  width: 3),
                                                            ),
                                                            color:
                                                                Color.fromRGBO(
                                                                    0,
                                                                    0,
                                                                    0,
                                                                    0.0),
                                                            textColor:
                                                                Colors.white,
                                                            child: Container(
                                                              child: new Text(
                                                                'Print',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontFamily:
                                                                        'serif',
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        18),
                                                              ),
                                                            ),
                                                            onPressed: () {
                                                              _fetchreceipts(
                                                                  item.receiptnum,
                                                                  index);
                                                            }),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          });
                    } else {
                      newsListSliver = Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return newsListSliver;
                  }),
              Container(
                  height: 100, width: MediaQuery.of(this.context).size.width)
            ],
          ));
    }
    return datawidget;
  }

  @override
  Widget build(BuildContext context) {
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
                    _allInvoicesWidget(),
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
