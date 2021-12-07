import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io' as Io;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:emkapp/helperclass.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Fp;
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'admindashboard.dart';
import 'form_screens/demography.dart';

void main() => runApp(AddChannelAdmin());

class AddChannelAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainAddChannelAdmin(),
    );
  }
}

class MainAddChannelAdmin extends StatefulWidget {
  @override
  State createState() => new AddChannelAdminState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class AddChannelAdminState extends State<MainAddChannelAdmin>
    with TickerProviderStateMixin {
  late List<DropdownMenuItem<String>> _dropDownMenuTitles;
  late AnimationController _iconanimcontroller;
  late Animation<double> _iconanim;
  late ProgressDialog pr;
  late AnimationController _animcon;
  Uint8List bytes = Uint8List(0);
  late AppState appstate;
  String user = '', _imgname = '', _nimgdir = '', _passw = '';
  late Directory _imgdir;
  String _firstname = '',
      _lastname = '',
      _title = '',
      message = '',
      _password = '',
      _userid = '',
      _email = '',
      _contact = '';
  static ChannelData cdata = new ChannelData();
  static ExistingUserData edata = new ExistingUserData();
  late TextEditingController _fnamecontroller,
      _lnamecontroller,
      _titlecontroller,
      _pwordcontroller,
      _uidcontroller,
      _emailcontroller,
      _contactcontroller;
  bool isButtonEnabled = true,
      _diagvisibility = false,
      _verify = false,
      channelvisibility = false,
      _refreshchannels = false;
  File? galleryfile, camerafile;
  String _imgfile = '', _finalfile = '';
  bool _autovalidatename = false;
  String base64image = '';
  final _formkey = GlobalKey<FormState>();
  final _key = GlobalKey<FormFieldState>();
  late ScrollController _scrollController;

  RaisedButton fRB = RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.blueGrey.shade900, width: 3),
      ),
      color: Color.fromRGBO(0, 0, 15, 1),
      textColor: Colors.white,
      child: new Text(
        "Back",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12),
      ),
      onPressed: () {
        //_dismissdialog();
      });

  RaisedButton sRB = RaisedButton(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.blueGrey.shade900, width: 3),
      ),
      color: Color.fromRGBO(0, 0, 15, 1),
      textColor: Colors.white,
      child: new Text(
        "Proceed",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12),
      ),
      onPressed: () {});

  String eximg = '', exname = '', exid = '', exmail = '', excon = '';

  List<DropdownMenuItem<String>> getDropDownMenuTitles() {
    List<DropdownMenuItem<String>> alltitles = [];
    for (String titlelist in _titles) {
      alltitles.add(DropdownMenuItem(value: titlelist, child: Text(titlelist)));
    }
    return alltitles;
  }

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
    _fnamecontroller = TextEditingController();
    _lnamecontroller = TextEditingController();
    _titlecontroller = TextEditingController();
    _pwordcontroller = TextEditingController();
    _uidcontroller = TextEditingController();
    _emailcontroller = TextEditingController();
    _contactcontroller = TextEditingController();
    _dropDownMenuTitles = getDropDownMenuTitles();
    super.initState();
    getchannels();
    loadimg();
    eximg = 'http://www.emkapp.com/emkapp/icons/CSI3.png';
    _scrollController = ScrollController();
    appstate = AppState.free;
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

  loadimg() async {
    var bytes = await rootBundle.load("assets/images/pic.png");
    String tempPath = (await getTemporaryDirectory()).path;
    setState(() {
      galleryfile = File('$tempPath/pic.png');
    });

    await galleryfile!.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    return galleryfile;
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

  List<CChanels> channeldata = [];
  List<dynamic> dchanneldata = [];
  CChanels? _selectedChannel;
  Future<String> getchannels() async {
    var url = 'http://www.emkapp.com/emkapp/api/channels.php';
    var bdata = {"getchannels": ""};
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
          .contains("No records available")) {
        channeldata.add(CChanels("", ""));
        channeldata.add(CChanels("", "Add More.."));
        setState(() {
          _selectedChannel = channeldata[0];
          _diagvisibility = false;
          _refreshchannels = false;
        });
      } else {
        setState(() {
          _refreshchannels = false;
          dchanneldata = json.decode(response.data);
          channeldata = List<CChanels>.from(
              dchanneldata.map((i) => CChanels.fromJson(i)));
          _selectedChannel = channeldata[0];
          _diagvisibility = false;
        });

        //searchactiveadminresponse = json.decode(response.body);
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

    return "Success";
  }

  String _serveresponse = '';

  bool pressed = false,
      _obscuretext = false,
      _visibility = false,
      _delchannelvisibility = false;

  late SnackBar snackBar;
  final ImagePicker _picker = ImagePicker();
  void _showsnackbar(String _message, String _command) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();

    snackBar = SnackBar(
      duration: const Duration(minutes: 5),
      content: Text(_message),
      action: SnackBarAction(
        label: _command,
        onPressed: () {
          if (_command.contains("Close")) {
          } else if (_command.contains("Close")) {}
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _showfilepicker(context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            height: 150,
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    galleryimage();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.all(15),
                    margin: EdgeInsets.only(right: 30),
                    child: Column(children: [
                      Icon(Icons.photo_library, size: 55, color: Colors.grey),
                      new Text('Gallery')
                    ]),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    cameraimage();
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.all(15),
                    child: Column(children: [
                      Icon(Icons.photo_camera, size: 55, color: Colors.grey),
                      new Text('Camera')
                    ]),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  cameraimage() async {
    // ignore: deprecated_member_use
    XFile? gfile = await _picker.pickImage(source: ImageSource.camera);
    if (gfile != null) {
      galleryfile = File(gfile.path);
    }
    if (galleryfile != null) {
      final bytes = Io.File(galleryfile!.path).readAsBytesSync();
      _imgfile = galleryfile.toString().split('/').last.split('r').last;
      base64image = base64Encode(bytes);
      _finalfile = _imgfile.substring(0, _imgfile.indexOf('\''));
      setState(() {
        appstate = AppState.picked;
      });
      Future.delayed(Duration(seconds: 0), () {
        if (gfile != null) {
          cropimage();
        }
      });
    }
  }

  GlobalKey<FormState> _channelformkey = GlobalKey<FormState>();
  String _channeltxtname = '';

  createchannel(_channeltxtname) async {
    var url = "http://www.emkapp.com/emkapp/api/channels.php";
    var bdata = {"txtAddChannel": _channeltxtname, "create-channel": ""};
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
      if (jsonDecode(response.data).toString().contains("successful")) {
        _showsnackbar("operation was successful", "Close");

        Future.delayed(Duration(seconds: 0)).then((value) {
          getchannels();

          setState(() {
            _diagvisibility = false;
            channelvisibility = false;
            _channelformkey.currentState!.reset();
          });
        });
      } else {
        _showsnackbar("Error creating channel.", "Close");
        setState(() {
          _diagvisibility = false;
        });
        enableButton();
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

  galleryimage() async {
    // ignore: deprecated_member_use
    XFile? gfile = await _picker.pickImage(source: ImageSource.gallery);
    if (gfile != null) {
      galleryfile = File(gfile.path);
    }
    if (galleryfile != null) {
      final bytes = Io.File(galleryfile!.path).readAsBytesSync();
      _imgfile = galleryfile.toString().split('/').last.split('r').last;
      base64image = base64Encode(bytes);
      _finalfile = _imgfile.substring(0, _imgfile.indexOf('\''));
      setState(() {
        appstate = AppState.picked;
      });
      Future.delayed(Duration(seconds: 0), () {
        if (gfile != null) {
          cropimage();
        }
      });
    }
  }

  cropimage() async {
    File? croppedfile = await ImageCropper.cropImage(
        sourcePath: galleryfile!.path,
        aspectRatioPresets: Platform.isAndroid
            ? [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio16x9,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
              ]
            : [
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio16x9,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Image Cropper',
            toolbarColor: Colors.pink[800],
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          title: 'Image Cropper',
        ));

    if (croppedfile != null) {
      setState(() {
        galleryfile = croppedfile;
        final bytes = Io.File(galleryfile!.path).readAsBytesSync();
        _imgfile = galleryfile.toString().split('/').last.split('r').last;
        base64image = base64Encode(bytes);
        _finalfile = _imgfile.substring(0, _imgfile.indexOf('\''));
        appstate = AppState.cropped;
      });
    }
  }

  _delchannel(String channel) {
    Widget cancelbtn = FlatButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop(context);
      },
      child: Text("Cancel"),
    );
    Widget continuebtn = FlatButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop(context);
        _finaldelrank(channel);
      },
      child: Text("Continue"),
    );

    AlertDialog alert = AlertDialog(
      title: Text("Warning"),
      content: Text(
          "Sure about deleting selected channel?\nThis action cannot be undone"),
      actions: [cancelbtn, continuebtn],
    );

    return showDialog(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  _finaldelrank(String channel) async {
    var url = "http://www.emkapp.com/emkapp/api/channels.php";
    var bdata = {"delchan": channel, "chanid": channel};
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
      if (jsonDecode(response.data).toString().contains("successfully")) {
        _showsnackbar("operation was successful", "Close");

        Future.delayed(Duration(seconds: 0)).then((value) {
          getchannels();
          setState(() {
            _diagvisibility = false;
            _delchannelvisibility = false;
          });
        });
      } else {
        _showsnackbar("Error creating rank.", "Close");
        setState(() {
          _diagvisibility = false;
        });
        enableButton();
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

  displayselectedfile() {
    return new SizedBox(
      height: 300,
      width: 400,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.only(left: 0),
          width: MediaQuery.of(context).size.width,
          child: galleryfile == null
              ? new Image.asset('assets/images/pic.png',
                  height: 300.0, width: MediaQuery.of(context).size.width)
              : new Image.file(galleryfile!,
                  height: 300.0, width: MediaQuery.of(context).size.width),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fnamecontroller.dispose();
    _lnamecontroller.dispose();
    _titlecontroller.dispose();
    _pwordcontroller.dispose();
    _uidcontroller.dispose();
    _emailcontroller.dispose();
    _contactcontroller.dispose();
    _scrollController.dispose();
    _animcon.dispose();
    _iconanimcontroller.dispose();
    super.dispose();
  }

  _dismissdialog() {
    setState(() {
      _verify = false;
    });
  }

  createadmin(_firstname, _lastname, _title, galleryfile, _contact, _email,
      _userid, _password, _channeltxtname) async {
    // _showsnackbar(Fp.basename(galleryfile.path).toString() + "\n" + _email, "Okay");
    var url = "http://www.emkapp.com/emkapp/api/channels.php";
    setState(() {
      _diagvisibility = true;
    });
    var bdata = {"verifydata": cdata.channel};
    FormData fdata = FormData.fromMap(bdata);
    BaseOptions options = new BaseOptions(
      baseUrl: "http://www.emkapp.com/emkapp",
      connectTimeout: 5000,
      receiveTimeout: 3000,
    );

    Dio dio = new Dio(options);

    try {
      var response = await dio.post(url, data: fdata);
      print(response.data);
      var json = jsonDecode(response.data);
      print(json);
      if (json.toString().contains("vacant")) {
        createchanneladmin(_firstname, _lastname, _title, galleryfile, _contact,
            _email, _userid, _password, _channeltxtname);
      } else {
        var nj = json as List;
        print("New List : " + nj.toString());
        setState(() {
          _diagvisibility = false;
          _verify = true;
          eximg = 'http://www.emkapp.com/emkapp/imgdata/' +
              nj[0]["eximg"].toString();
          exid = nj[0]["exid"].toString();
          excon = nj[0]["excon"].toString();
          exmail = nj[0]["exmail"].toString();
          exname = nj[0]["exname"].toString();
        });
        // ignore: unnecessary_statements
        fRB.onPressed !=
            () {
              setState(() {
                _verify = false;
              });
            };
        print("img from server : " + eximg);
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

  createchanneladmin(_firstname, _lastname, _title, galleryfile, _contact,
      _email, _userid, _password, _channeltxtname) async {
    // _showsnackbar(Fp.basename(galleryfile.path).toString() + "\n" + _email, "Okay");
    var url = "http://www.emkapp.com/emkapp/api/channels.php";
    var bdata = {
      "uid": _uidcontroller.text,
      "pw": _pwordcontroller.text,
      "title": _title,
      "firstname": _fnamecontroller.text,
      "lastname": _lnamecontroller.text,
      "email": _emailcontroller.text,
      "contact": _contactcontroller.text,
      "imgname": Fp.basename(galleryfile.path).toString(),
      "img": base64image,
      "channel": cdata.channel,
      "operation": "insert",
      "create-admin": ""
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
      if (jsonDecode(response.data).toString().contains("successfully")) {
        _showsnackbar("Admin has been successfully added", "Close");

        _scrollController.animateTo(0,
            duration: Duration(seconds: 1), curve: Curves.linear);
        Future.delayed(Duration(seconds: 0)).then((value) {
          loadimg();

          setState(() {
            _diagvisibility = false;
            _title = null;
            _dropDownMenuTitles.clear();
            _dropDownMenuTitles = getDropDownMenuTitles();
            _formkey.currentState!.reset();
            _key.currentState!.reset();
          });
          getDropDownMenuTitles();
          enableButton();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext ncontext) => MainAdminDashboard(
                        opt: "1",
                        nrdate: '',
                      )));
        });
        enableButton();
      } else {
        _showsnackbar("Error creating admin.", "Close");
        setState(() {
          _diagvisibility = false;
        });
        enableButton();
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

  updatechanneladmin(_firstname, _lastname, _title, galleryfile, _contact,
      _email, _userid, _password, _channeltxtname) async {
    // _showsnackbar(Fp.basename(galleryfile.path).toString() + "\n" + _email, "Okay");
    var bdata = {
      "uid": _uidcontroller.text,
      "pw": _pwordcontroller.text,
      "title": _title,
      "firstname": _fnamecontroller.text,
      "lastname": _lnamecontroller.text,
      "email": _emailcontroller.text,
      "contact": _contactcontroller.text,
      "imgname": Fp.basename(galleryfile.path).toString(),
      "img": base64image,
      "channel": cdata.channel,
      "operation": "update",
      "create-admin": ""
    };
    FormData fdata = FormData.fromMap(bdata);
    var url = 'http://www.emkapp.com/emkapp/api/channels.php';

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
      if (jsonDecode(response.data).toString().contains("successfully")) {
        _showsnackbar("Admin has been successfully updated", "Close");

        _scrollController.animateTo(0,
            duration: Duration(seconds: 1), curve: Curves.linear);
        Future.delayed(Duration(seconds: 0)).then((value) {
          loadimg();

          setState(() {
            _diagvisibility = false;
            _title = null;
            _dropDownMenuTitles.clear();
            _dropDownMenuTitles = getDropDownMenuTitles();
            _formkey.currentState!.reset();
            _key.currentState!.reset();
          });
          getDropDownMenuTitles();
          enableButton();
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext ncontext) => MainAdminDashboard(
                        opt: "1",
                        nrdate: '',
                      )));
        });
        enableButton();
      } else {
        _showsnackbar("Error creating admin.", "Close");
        setState(() {
          _diagvisibility = false;
        });
        enableButton();
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
                                    child: SingleChildScrollView(
                                      controller: _scrollController,
                                      child: Column(children: <Widget>[
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new Image.asset(
                                          'assets/images/CSI3.png',
                                          width: _iconanim.value * 100,
                                          height: _iconanim.value * 100,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 60)),
                                        new TextFormField(
                                          controller: _uidcontroller,
                                          decoration: new InputDecoration(
                                            labelText: "User ID",
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
                                              _userid = newValue!;
                                            });
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _fnamecontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Firstname",
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
                                              _firstname = newValue!;
                                            });
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _lnamecontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Lastname",
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
                                              _lastname = newValue!;
                                            });
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _emailcontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Email Address",
                                            prefixIcon: Icon(Icons.email),
                                          ),
                                          validator: (value) {
                                            bool emailValid = RegExp(
                                                    r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                .hasMatch(value!);
                                            if (value.isEmpty) {
                                              return 'This field is required';
                                            } else if (emailValid.toString() ==
                                                "false") {
                                              return "Your email address is incorrect";
                                            } else {
                                              return null;
                                            }
                                          },
                                          onSaved: (newValue) {
                                            setState(() {
                                              _email = newValue!;
                                            });
                                          },
                                          keyboardType:
                                              TextInputType.emailAddress,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _contactcontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Contact Number",
                                            prefixIcon:
                                                Icon(Icons.phone_android),
                                          ),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else if (value.length < 10) {
                                              return 'Contact number cannot be less than 10 digits';
                                            } else {
                                              return null;
                                            }
                                          },
                                          onSaved: (newValue) {
                                            setState(() {
                                              _contact = newValue!;
                                            });
                                          },
                                          keyboardType: TextInputType.phone,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new DropdownButtonFormField(
                                            value: _title,
                                            key: _key,
                                            decoration: new InputDecoration(
                                              labelText: "Title",
                                              prefixIcon: Icon(Icons.person),
                                            ),
                                            isExpanded: true,
                                            items: _dropDownMenuTitles,
                                            validator: (value) => value == null
                                                ? 'This field is required'
                                                : null,
                                            onSaved: (newValue) {
                                              setState(() {
                                                _title = newValue.toString();
                                              });
                                            },
                                            onChanged: (newValue) {
                                              setState(() {
                                                _title = newValue.toString();
                                              });
                                            }),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _pwordcontroller
                                            ..text = "chadm2021",
                                          readOnly: true,
                                          decoration: new InputDecoration(
                                            labelText: "Password",
                                            prefixIcon: Icon(Icons.security),
                                            suffixIcon: IconButton(
                                              icon: Padding(
                                                padding: EdgeInsets.all(3),
                                                child: pressed == true
                                                    ? Icon(Icons
                                                        .visibility_off_rounded)
                                                    : Icon(Icons
                                                        .visibility_rounded),
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
                                              _password = newValue!;
                                            });
                                          },
                                          keyboardType: TextInputType.text,
                                          obscureText: !_obscuretext,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 40)),
                                        Container(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(10.0)),
                                            child: Column(
                                              children: <Widget>[
                                                Container(
                                                  padding:
                                                      EdgeInsets.only(top: 10),
                                                  child: Text(
                                                    'Profile Picture',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                  height: 40,
                                                  width: 400,
                                                  color: Colors.grey
                                                      .withOpacity(.3),
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    _showfilepicker(context);
                                                  },
                                                  child: displayselectedfile(),
                                                ),
                                              ],
                                            ),
                                          ),
                                          width: 400,
                                          height: 350,
                                          decoration: BoxDecoration(
                                            color:
                                                Color.fromRGBO(93, 93, 93, .3),
                                            border: Border.all(
                                                color: Color.fromRGBO(
                                                    73, 73, 73, .3),
                                                width: 5),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new DropdownButtonFormField<CChanels>(
                                            value: _selectedChannel,
                                            decoration: new InputDecoration(
                                                labelText: "Channel",
                                                prefixIcon: Icon(Icons.people),
                                                suffixIcon: Stack(
                                                  children: <Widget>[
                                                    Visibility(
                                                      visible:
                                                          _delchannelvisibility,
                                                      child: IconButton(
                                                        icon: Padding(
                                                          padding:
                                                              EdgeInsets.all(3),
                                                          child: Icon(
                                                              Icons.delete),
                                                        ),
                                                        onPressed: () {
                                                          _delchannel(
                                                              cdata.channel);
                                                        },
                                                      ),
                                                    ),
                                                    Visibility(
                                                      visible: _refreshchannels,
                                                      child: IconButton(
                                                        icon: Padding(
                                                          padding:
                                                              EdgeInsets.all(3),
                                                          child: Icon(
                                                              Icons.refresh),
                                                        ),
                                                        onPressed: () {
                                                          getchannels();
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                )),
                                            items: channeldata
                                                .map((CChanels cChanels) {
                                              return new DropdownMenuItem<
                                                      CChanels>(
                                                  value: cChanels,
                                                  child: new Text(
                                                      cChanels.channelName));
                                            }).toList(),
                                            validator: (value) {
                                              _selectedChannel = value!;
                                              if (_selectedChannel!.channelID ==
                                                  "") {
                                                return 'This field is required';
                                              }
                                            },
                                            onSaved: (newValue) {
                                              setState(() {
                                                _selectedChannel = newValue!;
                                                cdata.channel =
                                                    _selectedChannel!.channelID
                                                        .toString();
                                              });
                                            },
                                            onChanged: (newValue) {
                                              setState(() {
                                                _selectedChannel = newValue!;
                                                if (_selectedChannel!
                                                        .channelID !=
                                                    "") {
                                                  cdata.channel =
                                                      _selectedChannel!
                                                          .channelID
                                                          .toString();
                                                  //_delchannelvisibility = true;
                                                }
                                                if (_selectedChannel!
                                                        .channelID ==
                                                    "") {
                                                  _delchannelvisibility = false;
                                                }
                                                if (_selectedChannel!
                                                    .channelName
                                                    .toString()
                                                    .contains("Add More")) {
                                                  channelvisibility = true;
                                                }
                                              });
                                            }),
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
                                                "Add Admin",
                                                style: TextStyle(fontSize: 15),
                                              ),
                                              onPressed: () {
                                                if (isButtonEnabled) {
                                                  final form =
                                                      _formkey.currentState;
                                                  if (form!.validate()) {
                                                    form.save();

                                                    if (Fp.basename(galleryfile!
                                                                .path)
                                                            .toString() ==
                                                        "pic.png") {
                                                      _showsnackbar(
                                                          "Please select a picture",
                                                          "Close");
                                                    } else {
                                                      message =
                                                          'Please wait, request is being processed...';

                                                      _showsnackbar(
                                                          message, "");
                                                      disableButton();
                                                      setState(() {
                                                        _visibility =
                                                            _visibility;
                                                        _diagvisibility = true;
                                                      });

                                                      createadmin(
                                                          _firstname,
                                                          _lastname,
                                                          _title,
                                                          galleryfile,
                                                          _contact,
                                                          _email,
                                                          _userid,
                                                          _password,
                                                          _channeltxtname);
                                                    }
                                                  }
                                                }
                                              }),
                                        ),
                                      ]),
                                    ),
                                  )),
                            ),
                          ),
                          Visibility(
                            visible: _verify,
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              height: MediaQuery.of(context).size.height,
                              color: Colors.black.withOpacity(.65),
                              child: ListView(
                                children: <Widget>[
                                  Padding(
                                    padding: EdgeInsets.only(top: 5, bottom: 5),
                                    child: Text(
                                      'Sure about replacing channel admin?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: Colors.white,
                                        decoration: TextDecoration.underline,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                1,
                                        constraints: BoxConstraints(
                                            maxHeight: double.infinity),
                                        height: 515,
                                        decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Color.fromRGBO(0, 0, 0, .3),
                                              spreadRadius: 12.0,
                                            ),
                                            BoxShadow(
                                              color: Color.fromRGBO(
                                                  93, 93, 93, .1),
                                              spreadRadius: -12.0,
                                              blurRadius: 12.0,
                                            ),
                                          ],
                                          color: Color.fromRGBO(93, 93, 93, .3),
                                          border: Border(
                                              top: BorderSide(
                                                  color: Color.fromRGBO(
                                                      123, 123, 123, 1),
                                                  width: 15),
                                              bottom: BorderSide(
                                                  color: Color.fromRGBO(
                                                      83, 83, 83, 1),
                                                  width: 15),
                                              left: BorderSide(
                                                  color: Color.fromRGBO(
                                                      93, 93, 93, 1),
                                                  width: 1),
                                              right: BorderSide(
                                                  color: Color.fromRGBO(
                                                      93, 93, 93, 1),
                                                  width: 1)),
                                        ),
                                        padding: EdgeInsets.only(
                                            left: 10,
                                            right: 10,
                                            bottom: 10,
                                            top: 10),
                                        child: Column(
                                          children: <Widget>[
                                            Stack(
                                              children: [
                                                GestureDetector(
                                                  onTap: () {},
                                                  child: Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.45,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.45,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Color.fromRGBO(
                                                                    103,
                                                                    103,
                                                                    103,
                                                                    1),
                                                            width: 11),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                        image: DecorationImage(
                                                          fit: BoxFit.fill,
                                                          image:
                                                              CachedNetworkImageProvider(
                                                            eximg,
                                                          ),
                                                        )),
                                                  ),
                                                ),
                                                GestureDetector(
                                                  onTap: () {},
                                                  child: Container(
                                                    padding: EdgeInsets.all(3),
                                                    child: Container(
                                                      width: (MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.45) -
                                                          6,
                                                      height: (MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.45) -
                                                          6,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Color.fromRGBO(
                                                                    133,
                                                                    133,
                                                                    133,
                                                                    .5),
                                                            width: 3),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color: Color.fromRGBO(
                                                            0, 0, 0, .2),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 15)),
                                            Divider(
                                              color:
                                                  Colors.white.withOpacity(.7),
                                              height: 1,
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 20)),
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
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 27,
                                                    color: Colors.amber[100],
                                                  ),
                                                ),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10)),
                                                Flexible(
                                                    child: new Text(
                                                  exname,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontFamily: 'serif',
                                                    color: Colors.white,
                                                  ),
                                                )),
                                              ],
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 20)),
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
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Icon(
                                                    Icons.badge_rounded,
                                                    size: 27,
                                                    color: Colors.amber[100],
                                                  ),
                                                ),
                                                Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10)),
                                                Flexible(
                                                    child: new Text(
                                                  exid,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontFamily: 'serif',
                                                    color: Colors.white,
                                                  ),
                                                )),
                                              ],
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 20)),
                                            GestureDetector(
                                              onTap: () {},
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
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: Icon(
                                                      Icons.mail,
                                                      size: 27,
                                                      color: Colors.amber[100],
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10)),
                                                  Flexible(
                                                      child: new Text(
                                                    exmail,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontFamily: 'serif',
                                                      color: Colors.white,
                                                    ),
                                                  )),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 20)),
                                            GestureDetector(
                                              onTap: () {},
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
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: Icon(
                                                      Icons
                                                          .phone_android_rounded,
                                                      size: 27,
                                                      color: Colors.amber[100],
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10)),
                                                  Flexible(
                                                      child: new Text(
                                                    excon,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontFamily: 'serif',
                                                      color: Colors.white,
                                                    ),
                                                  )),
                                                ],
                                              ),
                                            ),
                                            Padding(
                                                padding:
                                                    EdgeInsets.only(top: 20)),
                                            GestureDetector(
                                              onTap: () {},
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
                                                          BorderRadius.circular(
                                                              5),
                                                    ),
                                                    child: Icon(
                                                      Icons.sms,
                                                      size: 27,
                                                      color: Colors.amber[100],
                                                    ),
                                                  ),
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 10)),
                                                  Flexible(
                                                      child: new Text(
                                                    excon,
                                                    style: TextStyle(
                                                      fontSize: 15,
                                                      fontFamily: 'serif',
                                                      color: Colors.white,
                                                    ),
                                                  )),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: FractionallySizedBox(
                                      widthFactor: 0.40,
                                      child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            side: BorderSide(
                                                color: Colors.blueGrey.shade900,
                                                width: 3),
                                          ),
                                          color: Color.fromRGBO(0, 0, 15, 1),
                                          textColor: Colors.white,
                                          child: new Text(
                                            "Back",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _verify = false;
                                            });
                                            enableButton();
                                          }),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: FractionallySizedBox(
                                      widthFactor: 0.40,
                                      child: RaisedButton(
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                            side: BorderSide(
                                                color: Colors.blueGrey.shade900,
                                                width: 3),
                                          ),
                                          color: Color.fromRGBO(0, 0, 15, 1),
                                          textColor: Colors.white,
                                          child: new Text(
                                            "Proceed",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(fontSize: 12),
                                          ),
                                          onPressed: () {
                                            updatechanneladmin(
                                                _firstname,
                                                _lastname,
                                                _title,
                                                galleryfile,
                                                _contact,
                                                _email,
                                                _userid,
                                                _password,
                                                _channeltxtname);
                                          }),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                          Visibility(
                            visible: channelvisibility,
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
                                            'Add Channel',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          height: 40,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Color.fromRGBO(0, 0, 10, .9),
                                        ),
                                        Form(
                                          key: _channelformkey,
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
                                                  decoration:
                                                      new InputDecoration(
                                                    labelText:
                                                        "Enter channel here",
                                                    prefixIcon:
                                                        Icon(Icons.person),
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
                                                      _channeltxtname =
                                                          newValue!;
                                                    });
                                                  },
                                                  keyboardType:
                                                      TextInputType.text,
                                                ),
                                                Padding(
                                                    padding: EdgeInsets.only(
                                                        top: 20)),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: <Widget>[
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          left: 15),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.28,
                                                      height: 40,
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
                                                          color: primarycolor,
                                                          textColor:
                                                              Colors.white,
                                                          child: new Text(
                                                            "Add",
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                          onPressed: () {
                                                            final form =
                                                                _channelformkey
                                                                    .currentState;
                                                            if (form!
                                                                .validate()) {
                                                              form.save();

                                                              message =
                                                                  'Please wait, request is being processed...';

                                                              _showsnackbar(
                                                                  message, "");

                                                              setState(() {
                                                                _diagvisibility =
                                                                    true;
                                                              });

                                                              createchannel(
                                                                  _channeltxtname);
                                                            }
                                                          }),
                                                    ),
                                                    Container(
                                                      padding: EdgeInsets.only(
                                                          right: 15),
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.28,
                                                      height: 40,
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
                                                          color: primarycolor,
                                                          textColor:
                                                              Colors.white,
                                                          child: new Text(
                                                            "Cancel",
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                          onPressed: () {
                                                            setState(() {
                                                              _channelformkey
                                                                  .currentState!
                                                                  .reset();
                                                              channelvisibility =
                                                                  false;
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
            ))));
  }

  List<String> _titles = [
    '',
    'Mr.',
    'Mrs.',
    'Ms.',
    'Mad.',
    'Prof.',
    'Rev.',
    'Dr.'
  ];
}
