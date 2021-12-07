import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io' as Io;
import 'package:dio/dio.dart';
import 'package:emkapp/form_screens/demography.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as Fp;
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'admindashboard.dart';
import 'dropdowns.dart';
import 'package:intl/intl.dart';

import 'helperclass.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Permission.camera.request();
  // await Permission.microphone.request();
  // await Permission.storage.request();

  if (Platform.isAndroid) {
    await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);

    var swAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_BASIC_USAGE);
    var swInterceptAvailable = await AndroidWebViewFeature.isFeatureSupported(
        AndroidWebViewFeature.SERVICE_WORKER_SHOULD_INTERCEPT_REQUEST);

    if (swAvailable && swInterceptAvailable) {
      AndroidServiceWorkerController serviceWorkerController =
          AndroidServiceWorkerController.instance();

      serviceWorkerController.serviceWorkerClient = AndroidServiceWorkerClient(
        shouldInterceptRequest: (request) async {
          print(request);
          return null;
        },
      );
    }
  }

  runApp(AddChannelAdminWorker());
}
//void main() => runApp(AddChannelAdminWorker());

class AddChannelAdminWorker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainAddChannelAdminWorker(),
    );
  }
}

class MainAddChannelAdminWorker extends StatefulWidget {
  @override
  State createState() => new AddChannelAdminWorkerState();
}

enum AppState {
  free,
  picked,
  cropped,
}

List<GlobalKey<FormState>> formkeys = [
  GlobalKey<FormState>(),
  GlobalKey<FormState>(),
  GlobalKey<FormState>(),
  GlobalKey<FormState>(),
  GlobalKey<FormState>()
];

List<GlobalKey<FormFieldState>> _key = [
  GlobalKey<FormFieldState>(),
  GlobalKey<FormFieldState>(),
  GlobalKey<FormFieldState>(),
  GlobalKey<FormFieldState>(),
  GlobalKey<FormFieldState>(),
  GlobalKey<FormFieldState>()
];

class AddChannelAdminWorkerState extends State<MainAddChannelAdminWorker>
    with TickerProviderStateMixin {
  late List<DropdownMenuItem<String>> _dropDownMenuTitles;
  late List<DropdownMenuItem<String>> _dropDownMenuMarriageStatus;
  late List<DropdownMenuItem<String>> _dropDownMenuRelationship;
  late List<DropdownMenuItem<String>> _dropDownMenuGender;
  late List<DropdownMenuItem<String>> _dropDownMenuNationality;
  late AnimationController _iconanimcontroller;
  late Animation<double> _iconanim;
  late ProgressDialog pr;
  late AnimationController _animcon;
  Uint8List bytes = Uint8List(0);
  late AppState appstate;
  double percent = 0.0;
  Color? pcolor;
  String user = '', _imgname = '', _nimgdir = '', _passw = '';
  late Directory _imgdir;
  String _firstname = '',
      _lastname = '',
      _title = '',
      message = '',
      _password = '',
      _userid = '',
      _email = '',
      _contact = '',
      _worddob = '';
  late TextEditingController _fnamecontroller,
      _lnamecontroller,
      _titlecontroller,
      _pwordcontroller,
      _uidcontroller,
      _emailcontroller,
      _contactcontroller,
      _daddrcontroller,
      _paddrcontroller,
      _raddrcontroller,
      _cononecontroller,
      _contwocontroller,
      _noknamecontroller,
      _noknumcontroller,
      _idcardnumcontroller,
      _doecontroller,
      _nobcontroller,
      _accnamecontroller,
      _acnumcontroller,
      _empidcontroller,
      _empasswordcontroller,
      _dobcontroller,
      _nokrelcontroller;
  bool isButtonEnabled = true,
      _diagvisibility = false,
      _rolevisibility = false,
      _rankvisibility = false,
      _delrankvisibility = false,
      _refreshrole = false,
      _refreshrank = false;
  bool firstdemo = true,
      seconddemo = false,
      firstwork = false,
      secondwork = false,
      acinfo = false,
      nokrel = false;
  File? frontgalleryfile,
      backgalleryfile,
      frontcamerafile,
      backcamerafile,
      galleryfile;
  String _frontimgfile = '',
      _backimgfile = '',
      _frontfinalfile = '',
      _finalfile = '',
      _backfinalfile = '',
      _roletxtname = '',
      _imgfile = '',
      _ranktxtname = '';
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
      _totalmsgs = "";
  String _nationality = '',
      _gender = '',
      _marriagestatus = '',
      _relationship = '',
      _dob = '',
      _empdate = '',
      _wordempdate = '',
      _fronttitle = '',
      _ranksel = '';
  bool _autovalidatename = false,
      _progressvisibility = false,
      _backviewvisibility = false,
      _emptyroles = true,
      _fullroles = false,
      _emptyranks = true,
      _fullranks = false;
  String frontbase64image = '', backbase64image = '', base64image = '';
  GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  GlobalKey<FormState> _roleformkey = GlobalKey<FormState>();
  GlobalKey<FormState> _rankformkey = GlobalKey<FormState>();
  static DemoData demo = new DemoData();
  List roledata = [];
  List<WRanks> rankdata = [];
  List<dynamic> droledata = [];
  List<dynamic> drankdata = [];
  WRanks? _selectedRank;
  Future<String> getroles(String channel) async {
    roledata.clear();
    var url = "http://www.emkapp.com/emkapp/api/roles.php";
    var bdata = {"channel_id": channel};
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
        setState(() {
          _emptyroles = true;
          _fullroles = false;
          _diagvisibility = false;
        });
      } else {
        setState(() {
          _diagvisibility = false;
          roledata = json.decode(response.data);
          _emptyroles = false;
          _fullroles = true;
          isChecked = List<bool>.generate(roledata.length, (index) => false);
        });
        fetchallroles();
        //searchactiveadminresponse = json.decode(response.data);
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

  _retryroles() {
    getroles(wchannel);
  }

  _retryranks() {
    setState(() {
      _diagvisibility = true;
    });

    getranks(wchannel);
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
      setState(() {
        username = json['username'];
        wchannel = json['wchannel'];
      });

      role = json['grole'];
      cookiename = json['cookiename'];
      last_logged_in_at = json['last_logged_in_at'];
      uroles = json['uroles'];

      nameofchannel = json['nameofchannel'];
      url = json['url'];
      uid = json['userid'];
      // _showsnackbar(_imgname, "Okay");
      print("User ID : " + uid);
      setState(() {
        demo.channel = wchannel;
      });

      getroles(wchannel);
      getranks(wchannel);
    }
  }

  _createadminworker() async {
    var url = "http://www.emkapp.com/emkapp/api/addworker.php";
    var bdata = {
      "frontimg": demo.frontview,
      "backimg": demo.backview,
      "profimg": demo.dp,
      "frontpicname": demo.frontpicname,
      "backpicname": demo.backpicname,
      "profilename": demo.dpname,
      "roles": demo.roles,
      "firstname": demo.firstname,
      "lastname": demo.lastname,
      "title": demo.title,
      "nationality": demo.nationality,
      "gender": demo.sex,
      "dob": demo.dob,
      "residential_address": demo.residentialaddress,
      "digital_address": demo.digitaladdress,
      "postal_address": demo.postaladdress,
      "marital_status": demo.maritalstatus,
      "contactone": demo.contactone,
      "contacttwo": demo.contacttwo,
      "nokname": demo.nokname,
      "noktel": demo.noknum,
      "nokrel": demo.nokrel,
      "idcardnum": demo.idcardnum,
      "doe": demo.empdate,
      "rank": demo.rank,
      "bankname": demo.nob,
      "acname": demo.acname,
      "acnum": demo.acnum,
      "staffid": demo.empid,
      "password": demo.emppass,
      "idtype": demo.idtype,
      "email_address": demo.emailaddress,
      "channel": demo.channel,
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
      if (jsonDecode(jsonEncode(response.data))
          .toString()
          .contains("successfully")) {
        _showsnackbar("Worker has been successfully added", "Close");

        _fnamecontroller.clear();
        _lnamecontroller.clear();
        _titlecontroller.clear();
        _pwordcontroller.clear();
        _uidcontroller.clear();
        _emailcontroller.clear();
        _contactcontroller.clear();
        _daddrcontroller.clear();
        _raddrcontroller.clear();
        _paddrcontroller.clear();
        _cononecontroller.clear();
        _contwocontroller.clear();
        _noknamecontroller.clear();
        _noknumcontroller.clear();
        _idcardnumcontroller.clear();
        _doecontroller.clear();
        _nobcontroller.clear();
        _accnamecontroller.clear();
        _acnumcontroller.clear();
        _empidcontroller.clear();
        _empasswordcontroller.clear();
        _dobcontroller.clear();
        _nokrelcontroller.clear();

        _scrollController.animateTo(0,
            duration: Duration(seconds: 1), curve: Curves.linear);
        Future.delayed(Duration(seconds: 0)).then((value) {
          loadimg();
          loadfrontimg();
          loadbackimg();

          setState(() {
            demo.channel = '';
            demo.firstname = '';
            demo.lastname = '';
            demo.emailaddress = '';
            demo.title = '';
            demo.nationality = '';
            demo.sex = '';
            demo.dob = '';
            demo.digitaladdress = '';
            demo.postaladdress = '';
            demo.residentialaddress = '';
            demo.maritalstatus = '';
            demo.contactone = '';
            demo.contacttwo = '';
            demo.nokname = '';
            demo.nokrel = '';
            demo.noknum = '';
            demo.idtype = '';
            demo.frontview = '';
            demo.backview = '';
            demo.frontpicname = '';
            demo.backpicname = '';
            demo.empdate = '';
            demo.rank = '';
            demo.roles = '';
            demo.nob = '';
            demo.acname = '';
            demo.acnum = '';
            demo.idcardnum = '';
            demo.dp = '';
            demo.dpname = '';
            demo.empid = '';
            demo.emppass = '';
          });
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (BuildContext ncontext) => MainAdminDashboard(
                        opt: "0",
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

  Future<String> getranks(String channel) async {
    var url = "http://www.emkapp.com/emkapp/api/ranks.php";
    var bdata = {"channel_id": channel};
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
      roledata.clear();
      var response = await dio.post(url, data: fdata);
      print(response.data);
      if (jsonDecode(response.data)
          .toString()
          .contains("No records available")) {
        var mapone = {"channelid": "", "rankid": "", "rank": ""};
        var maptwo = {"channelid": "", "rankid": "", "rank": "Add More..."};
        rankdata.add(WRanks("", "", ""));
        rankdata.add(WRanks("", "", "Add More.."));
        setState(() {
          _selectedRank = rankdata[0];
          _diagvisibility = false;
        });
      } else {
        setState(() {
          drankdata = json.decode(response.data);
          rankdata =
              List<WRanks>.from(drankdata.map((i) => WRanks.fromJson(i)));
          _selectedRank = rankdata[0];
          _emptyranks = false;
          _fullranks = true;
          _diagvisibility = false;
        });

        //searchactiveadminresponse = json.decode(response.data);
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

  Future<List<WRoles>> fetchallroles() async {
    return roledata.map((e) => new WRoles.fromJson(e)).toList();
  }

  late ScrollController _scrollController;

  List<DropdownMenuItem<String>> getDropDownMenuTitles() {
    List<DropdownMenuItem<String>> alltitles = [];
    for (String titlelist in _titles) {
      alltitles.add(DropdownMenuItem(value: titlelist, child: Text(titlelist)));
    }
    return alltitles;
  }

  DateTime dobselectedDate = DateTime.now();
  DateTime? _dobselectedDate;

  DateTime empdateselectedDate = DateTime.now();
  DateTime? _empdateselectedDate;

  Future<void> _dobselectDate(BuildContext context) async {
    if (_dobselectedDate != null) {
    } else {
      _dobselectedDate = DateTime.now();
    }

    final newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _dobselectedDate!,
        firstDate: DateTime(1960, 1),
        lastDate: DateTime.now().add(Duration(days: 365)));

    if (newSelectedDate != null && newSelectedDate != _dobselectedDate)
      setState(() {
        _dobselectedDate = newSelectedDate;

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
        _dob = formatteddate.toString();
        demo.dob = formatteddate.toString();
        _dobcontroller.text = formatteddate.toString();
        var dateinwords = DateFormat('EEEE , MMMM d, yyyy')
            .format(newSelectedDate)
            .toString();
        _worddob = dateinwords;
      });
  }

  Future<Null> _empdateselectDate(BuildContext context) async {
    if (_empdateselectedDate != null) {
    } else {
      _empdateselectedDate = DateTime.now();
    }

    final DateTime? newSelectedDate = await showDatePicker(
        context: context,
        initialDate: empdateselectedDate,
        firstDate: DateTime(1960, 1),
        lastDate: DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day));

    if (newSelectedDate != null && newSelectedDate != _empdateselectedDate)
      setState(() {
        _empdateselectedDate = newSelectedDate;
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
        _empdate = formatteddate.toString();
        demo.empdate = formatteddate.toString();
        _doecontroller.text = formatteddate.toString();
        var dateinwords = DateFormat('EEEE , MMMM d, yyyy')
            .format(newSelectedDate)
            .toString();
        _wordempdate = dateinwords;
        //dateinwords = DateFormat('EEEE , MMMM d, yyyy').format(newSelectedDate).toString();
      });
  }

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
    _fnamecontroller = TextEditingController();
    _lnamecontroller = TextEditingController();
    _titlecontroller = TextEditingController();
    _pwordcontroller = TextEditingController();
    _uidcontroller = TextEditingController();
    _emailcontroller = TextEditingController();
    _contactcontroller = TextEditingController();
    _daddrcontroller = TextEditingController();
    _raddrcontroller = TextEditingController();
    _paddrcontroller = TextEditingController();
    _cononecontroller = TextEditingController();
    _contwocontroller = TextEditingController();
    _noknamecontroller = TextEditingController();
    _noknumcontroller = TextEditingController();
    _idcardnumcontroller = TextEditingController();
    _doecontroller = TextEditingController();
    _nobcontroller = TextEditingController();
    _accnamecontroller = TextEditingController();
    _acnumcontroller = TextEditingController();
    _empidcontroller = TextEditingController();
    _empasswordcontroller = TextEditingController();
    _dobcontroller = TextEditingController();
    _nokrelcontroller = TextEditingController();

    super.initState();
    pcolor = Colors.black;

    _populatedropdowns();
    _fronttitle = 'Upload a copy of passport document here';
    loadfrontimg();
    loadbackimg();
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

  _populatedropdowns() {
    setState(() {
      _dropDownMenuTitles = getDropDownMenuTitles();

      _dropDownMenuGender = getDropDownMenuGender();
      _dropDownMenuRelationship = getDropDownMenuRelationship();
      _dropDownMenuNationality = getDropDownMenuNationalities();
      _dropDownMenuMarriageStatus = getDropDownMenuMarriageStatus();
    });
  }

  loadfrontimg() async {
    var bytes = await rootBundle.load("assets/images/pic.png");
    String tempPath = (await getTemporaryDirectory()).path;
    setState(() {
      frontgalleryfile = File('$tempPath/pic.png');
    });

    await frontgalleryfile!.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    return frontgalleryfile;
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

  loadbackimg() async {
    var bytes = await rootBundle.load("assets/images/pic.png");
    String tempPath = (await getTemporaryDirectory()).path;
    setState(() {
      backgalleryfile = File('$tempPath/pic.png');
    });

    await backgalleryfile!.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    return backgalleryfile;
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

  String _serveresponse = '', _frontpicname = '', _backpicname = '';

  bool pressed = false, _obscuretext = false, _visibility = false;

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
                    galleryimage("profile");
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
                    cameraimage("profile");
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

  void _showfrontfilepicker(context) {
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
                    galleryimage("front");
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
                    cameraimage("front");
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

  void _showbackfilepicker(context) {
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
                    galleryimage("back");
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
                    cameraimage("back");
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

  cameraimage(String phase) async {
    // ignore: deprecated_member_use
    File? galfile;
    XFile? gfile = await _picker.pickImage(source: ImageSource.camera);
    if (gfile != null) {
      if (phase == "front") {
        frontgalleryfile = File(gfile.path);
        galfile = frontgalleryfile;
      } else {
        backgalleryfile = File(gfile.path);
        galfile = backgalleryfile;
      }
    }
    if (galfile != null) {
      final bytes = Io.File(galfile.path).readAsBytesSync();

      if (phase == "front") {
        _frontimgfile = galfile.toString().split('/').last.split('r').last;
        frontbase64image = base64Encode(bytes);
        _frontfinalfile =
            _frontimgfile.substring(0, _frontimgfile.indexOf('\''));
        setState(() {
          _frontpicname = _frontfinalfile.toString();
        });
      } else {
        _backimgfile = galfile.toString().split('/').last.split('r').last;
        backbase64image = base64Encode(bytes);
        _backfinalfile = _backimgfile.substring(0, _backimgfile.indexOf('\''));
        setState(() {
          _backpicname = Fp.basename(galfile!.path).toString();
        });
      }

      setState(() {
        appstate = AppState.picked;
      });
      Future.delayed(Duration(seconds: 0), () {
        if (gfile != null) {
          if (phase == "front") {
            cropfrontimage();
          } else {
            cropbackimage();
          }
        }
      });
    }
  }

  galleryimage(String phase) async {
    // ignore: deprecated_member_use
    File? galfile;
    XFile? gfile = await _picker.pickImage(source: ImageSource.gallery);
    if (gfile != null) {
      if (phase == "front") {
        frontgalleryfile = File(gfile.path);
        galfile = frontgalleryfile;
      } else if (phase == "back") {
        backgalleryfile = File(gfile.path);
        galfile = backgalleryfile;
      } else {
        galleryfile = File(gfile.path);
        galfile = galleryfile;
      }
    }
    if (galfile != null) {
      final bytes = Io.File(galfile.path).readAsBytesSync();
      if (phase == "front") {
        _frontimgfile =
            frontgalleryfile.toString().split('/').last.split('r').last;
        frontbase64image = base64Encode(bytes);
        _frontfinalfile =
            _frontimgfile.substring(0, _frontimgfile.indexOf('\''));
      } else if (phase == "back") {
        _backimgfile =
            backgalleryfile.toString().split('/').last.split('r').last;
        backbase64image = base64Encode(bytes);
        _backfinalfile = _backimgfile.substring(0, _backimgfile.indexOf('\''));
      } else {
        _imgfile = galleryfile.toString().split('/').last.split('r').last;
        base64image = base64Encode(bytes);
        _finalfile = _imgfile.substring(0, _imgfile.indexOf('\''));
      }

      setState(() {
        appstate = AppState.picked;
      });
      Future.delayed(Duration(seconds: 0), () {
        if (gfile != null) {
          if (phase == "front") {
            cropfrontimage();
          } else if (phase == "back") {
            cropbackimage();
          } else {
            cropimage();
          }
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
        _finalfile = _imgfile.substring(0, _frontimgfile.indexOf('\''));
        appstate = AppState.cropped;
        demo.dp = base64image;
        demo.dpname = Fp.basename(galleryfile!.path).toString();
      });
    }
  }

  cropfrontimage() async {
    File? croppedfile = await ImageCropper.cropImage(
        sourcePath: frontgalleryfile!.path,
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
        frontgalleryfile = croppedfile;
        final bytes = Io.File(frontgalleryfile!.path).readAsBytesSync();
        _frontimgfile =
            frontgalleryfile.toString().split('/').last.split('r').last;
        frontbase64image = base64Encode(bytes);
        _frontfinalfile =
            _frontimgfile.substring(0, _frontimgfile.indexOf('\''));
        appstate = AppState.cropped;
        demo.frontview = frontbase64image;
        demo.frontpicname = Fp.basename(frontgalleryfile!.path).toString();
      });
    }
  }

  cropbackimage() async {
    File? croppedfile = await ImageCropper.cropImage(
        sourcePath: backgalleryfile!.path,
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
        backgalleryfile = croppedfile;
        final bytes = Io.File(backgalleryfile!.path).readAsBytesSync();
        _backimgfile =
            backgalleryfile.toString().split('/').last.split('r').last;
        backbase64image = base64Encode(bytes);
        _backfinalfile = _backimgfile.substring(0, _backimgfile.indexOf('\''));
        appstate = AppState.cropped;
        demo.backview = backbase64image;
        demo.backpicname = Fp.basename(backgalleryfile!.path).toString();
      });
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

  displayselectedfrontfile() {
    return new SizedBox(
      height: 300,
      width: 400,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.only(left: 0),
          width: MediaQuery.of(context).size.width,
          child: frontgalleryfile == null
              ? new Image.asset('assets/images/pic.png',
                  height: 300.0, width: MediaQuery.of(context).size.width)
              : new Image.file(frontgalleryfile!,
                  height: 300.0, width: MediaQuery.of(context).size.width),
        ),
      ),
    );
  }

  displayselectedbackfile() {
    return new SizedBox(
      height: 300,
      width: 400,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          padding: EdgeInsets.only(left: 0),
          width: MediaQuery.of(context).size.width,
          child: backgalleryfile == null
              ? new Image.asset('assets/images/pic.png',
                  height: 300.0, width: MediaQuery.of(context).size.width)
              : new Image.file(backgalleryfile!,
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
    _daddrcontroller.dispose();
    _raddrcontroller.dispose();
    _paddrcontroller.dispose();
    _cononecontroller.dispose();
    _contwocontroller.dispose();
    _noknamecontroller.dispose();
    _noknumcontroller.dispose();
    _idcardnumcontroller.dispose();
    _doecontroller.dispose();
    _nobcontroller.dispose();
    _accnamecontroller.dispose();
    _acnumcontroller.dispose();
    _empidcontroller.dispose();
    _empasswordcontroller.dispose();
    _dobcontroller.dispose();
    _nokrelcontroller.dispose();
    _scrollController.dispose();
    _animcon.dispose();
    _iconanimcontroller.dispose();
    super.dispose();
  }

  _firstdemography(BuildContext context) {
    return Visibility(
      visible: firstdemo,
      child: Form(
        key: formkeys[0],
        child: Container(
          margin: EdgeInsets.only(top: 15),
          padding: EdgeInsets.all(5.0),
          child: Stack(
            children: <Widget>[
              new Container(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.white.withOpacity(.6), width: 1),
                  color: Colors.black.withOpacity(.4),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  children: <Widget>[
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
                          demo.firstname = newValue;
                        });
                      },
                      keyboardType: TextInputType.text,
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
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
                          demo.lastname = newValue;
                        });
                      },
                      keyboardType: TextInputType.text,
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
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
                        } else if (emailValid.toString() == "false") {
                          return "Your email address is incorrect";
                        } else {
                          return null;
                        }
                      },
                      onSaved: (newValue) {
                        setState(() {
                          _email = newValue!;
                          demo.emailaddress = newValue;
                        });
                      },
                      keyboardType: TextInputType.emailAddress,
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    new DropdownButtonFormField(
                        value: _title,
                        key: _key[0],
                        decoration: new InputDecoration(
                          labelText: "Title",
                          prefixIcon: Icon(Icons.person),
                        ),
                        isExpanded: true,
                        items: _dropDownMenuTitles,
                        validator: (value) =>
                            value == null ? 'This field is required' : null,
                        onSaved: (newValue) {
                          setState(() {
                            _title = newValue.toString();
                            demo.title = newValue.toString();
                          });
                        },
                        onChanged: (newValue) {
                          setState(() {
                            _title = newValue.toString();
                            demo.title = newValue.toString();
                          });
                        }),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    new DropdownButtonFormField(
                        value: _nationality,
                        key: _key[1],
                        decoration: new InputDecoration(
                          labelText: "Nationality",
                          prefixIcon: Icon(Icons.person),
                        ),
                        isExpanded: true,
                        items: _dropDownMenuNationality,
                        validator: (value) =>
                            value == null ? 'This field is required' : null,
                        onSaved: (newValue) {
                          setState(() {
                            _nationality = newValue.toString();
                            demo.nationality = newValue.toString();
                          });
                        },
                        onChanged: (newValue) {
                          setState(() {
                            _nationality = newValue.toString();
                            demo.nationality = newValue.toString();
                          });
                        }),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    new DropdownButtonFormField(
                        value: _gender,
                        key: _key[2],
                        decoration: new InputDecoration(
                          labelText: "Gender",
                          prefixIcon: Icon(Icons.person),
                        ),
                        isExpanded: true,
                        items: _dropDownMenuGender,
                        validator: (value) =>
                            value == null ? 'This field is required' : null,
                        onSaved: (newValue) {
                          setState(() {
                            _gender = newValue.toString();
                            demo.sex = newValue.toString();
                          });
                        },
                        onChanged: (newValue) {
                          setState(() {
                            _gender = newValue.toString();
                            demo.sex = newValue.toString();
                          });
                        }),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    TextFormField(
                      controller: _dobcontroller,
                      decoration: InputDecoration(
                        labelText: 'Date of Birth',
                        helperText: _worddob,
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _dobselectDate(context);
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
                    new Padding(padding: const EdgeInsets.only(top: 42)),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      padding: EdgeInsets.all(7.0),
                      child: Align(
                        alignment: Alignment.topRight,
                        child: FractionallySizedBox(
                          widthFactor: 0.35,
                          child: new RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                    color: Color.fromRGBO(0, 0, 0, 0.09),
                                    width: 3),
                              ),
                              color: primarycolor,
                              textColor: Colors.white,
                              child: new Text(
                                "Next",
                                style: TextStyle(fontSize: 15),
                              ),
                              onPressed: () {
                                setState(() {
                                  _scrollController.animateTo(0,
                                      duration: Duration(seconds: 1),
                                      curve: Curves.linear);
                                  final form = formkeys[0].currentState;
                                  if (form!.validate()) {
                                    form.save();
                                    firstdemo = false;
                                    seconddemo = true;
                                    _progressvisibility = true;
                                    percent = 20.0;
                                    pcolor = Colors.black;
                                  }
                                });
                              }),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    transform: Matrix4.translationValues(0, -12.0, 0),
                    child: Text(
                      'DEMOGRAPHIC DETAILS',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.73),
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _seconddemography(BuildContext context) {
    return Visibility(
      visible: seconddemo,
      child: Form(
        key: formkeys[1],
        child: Container(
          margin: EdgeInsets.only(top: 15),
          padding: EdgeInsets.all(5.0),
          child: Stack(
            children: <Widget>[
              new Container(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.white.withOpacity(.6), width: 1),
                  color: Colors.black.withOpacity(.4),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  children: <Widget>[
                    new TextFormField(
                      controller: _daddrcontroller,
                      decoration: new InputDecoration(
                        labelText: "Digital Address",
                        prefixIcon: Icon(Icons.credit_card),
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
                          demo.digitaladdress = newValue!;
                        });
                      },
                      keyboardType: TextInputType.text,
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    new TextFormField(
                      controller: _raddrcontroller,
                      maxLines: 4,
                      decoration: new InputDecoration(
                        labelText: "Residential Address",
                        prefixIcon: Icon(Icons.credit_card),
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
                          demo.residentialaddress = newValue!;
                        });
                      },
                      keyboardType: TextInputType.text,
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    new TextFormField(
                      controller: _paddrcontroller,
                      maxLines: 4,
                      decoration: new InputDecoration(
                        labelText: "Postal Address",
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
                          demo.residentialaddress = newValue!;
                        });
                      },
                      keyboardType: TextInputType.text,
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    new DropdownButtonFormField(
                        value: demo.maritalstatus,
                        key: _key[3],
                        decoration: new InputDecoration(
                          labelText: "Marital Status",
                          prefixIcon: Icon(Icons.people),
                        ),
                        isExpanded: true,
                        items: _dropDownMenuMarriageStatus,
                        validator: (value) =>
                            value == null ? 'This field is required' : null,
                        onSaved: (newValue) {
                          setState(() {
                            demo.maritalstatus = newValue.toString();
                          });
                        },
                        onChanged: (newValue) {
                          setState(() {
                            demo.maritalstatus = newValue.toString();
                          });
                        }),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    new TextFormField(
                      controller: _cononecontroller,
                      decoration: new InputDecoration(
                        labelText: "Contact Line 1",
                        prefixIcon: Icon(Icons.phone_android),
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
                          demo.contactone = newValue!;
                        });
                      },
                      keyboardType: TextInputType.phone,
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    new TextFormField(
                      controller: _contwocontroller,
                      decoration: new InputDecoration(
                        labelText: "Contact Line 2",
                        prefixIcon: Icon(Icons.phone_android),
                      ),
                      onSaved: (newValue) {
                        setState(() {
                          demo.contacttwo = newValue!;
                        });
                      },
                      keyboardType: TextInputType.phone,
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 39)),
                    Text(
                      'Next of Kin',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontSize: 20,
                      ),
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    new TextFormField(
                      controller: _noknamecontroller,
                      decoration: new InputDecoration(
                        labelText: "Name",
                        prefixIcon: Icon(Icons.credit_card),
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
                          demo.nokname = newValue!;
                        });
                      },
                      keyboardType: TextInputType.text,
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    new DropdownButtonFormField(
                        value: _relationship,
                        key: _key[4],
                        decoration: new InputDecoration(
                          labelText: "Relationship shared with kin",
                          prefixIcon: Icon(Icons.people),
                        ),
                        isExpanded: true,
                        items: _dropDownMenuRelationship,
                        validator: (value) =>
                            value == null ? 'This field is required' : null,
                        onSaved: (newValue) {
                          if (nokrel.toString() == "false") {
                            setState(() {
                              demo.nokrel = newValue.toString();
                            });
                          }
                        },
                        onChanged: (newValue) {
                          if (newValue.toString().contains("Other")) {
                            setState(() {
                              nokrel = true;
                            });
                          } else {
                            setState(() {
                              nokrel = false;
                              demo.nokrel = newValue.toString();
                            });
                          }
                        }),
                    Visibility(
                        visible: nokrel,
                        child: new Padding(
                            padding: const EdgeInsets.only(top: 26))),
                    Visibility(
                      visible: nokrel,
                      child: new TextFormField(
                        controller: _nokrelcontroller,
                        decoration: new InputDecoration(
                          labelText: "Please specify",
                          prefixIcon: Icon(Icons.people),
                        ),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'This field is required';
                          } else {
                            return null;
                          }
                        },
                        onSaved: (newValue) {
                          if (nokrel.toString() == "true") {
                            setState(() {
                              demo.nokrel = newValue!;
                            });
                          }
                        },
                        keyboardType: TextInputType.text,
                      ),
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    new TextFormField(
                      controller: _noknumcontroller,
                      decoration: new InputDecoration(
                        labelText: "Contact",
                        prefixIcon: Icon(Icons.phone_android),
                      ),
                      onSaved: (newValue) {
                        setState(() {
                          demo.noknum = newValue!;
                        });
                      },
                      keyboardType: TextInputType.phone,
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 43)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 15),
                          width: MediaQuery.of(context).size.width * 0.30,
                          height: 40,
                          child: new RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                    color: Color.fromRGBO(0, 0, 0, 0.09),
                                    width: 3),
                              ),
                              color: Color.fromRGBO(0, 0, 10, 1),
                              textColor: Colors.white,
                              child: new Text(
                                "Previous",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                setState(() {
                                  _scrollController.animateTo(0,
                                      duration: Duration(seconds: 1),
                                      curve: Curves.linear);
                                  firstdemo = true;
                                  seconddemo = false;
                                  percent = 0.0;
                                  pcolor = Colors.black;
                                });
                              }),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 15),
                          width: MediaQuery.of(context).size.width * 0.30,
                          height: 40,
                          child: new RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                    color: Color.fromRGBO(0, 0, 0, 0.09),
                                    width: 3),
                              ),
                              color: Color.fromRGBO(0, 0, 10, 1),
                              textColor: Colors.white,
                              child: new Text(
                                "Next",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                _scrollController.animateTo(0,
                                    duration: Duration(seconds: 1),
                                    curve: Curves.linear);
                                setState(() {
                                  final form = formkeys[1].currentState;
                                  if (form!.validate()) {
                                    form.save();
                                    seconddemo = false;
                                    firstwork = true;
                                    percent = 40.0;
                                    pcolor = Colors.black;
                                  }
                                });
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    transform: Matrix4.translationValues(0, -12.0, 0),
                    child: Text(
                      'DEMOGRAPHIC DETAILS',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.73),
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _firstworkdetails(BuildContext context) {
    return Visibility(
      visible: firstwork,
      child: Form(
        key: formkeys[2],
        child: Container(
          margin: EdgeInsets.only(top: 15),
          padding: EdgeInsets.all(5.0),
          child: Stack(
            children: <Widget>[
              new Container(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.white.withOpacity(.6), width: 1),
                  color: Colors.black.withOpacity(.4),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  children: <Widget>[
                    DefaultTextStyle(
                      style: TextStyle(color: Colors.white),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FormBuilderRadioGroup(
                            initialValue: 'Passport',
                            name: 'ID CARDS',
                            decoration: InputDecoration(
                              labelText: 'Identification Card',
                              fillColor: Colors.amber,
                              focusColor: Colors.amber,
                              prefixIcon: Icon(Icons.credit_card),
                            ),
                            activeColor: Colors.amber,
                            focusColor: Colors.white,
                            wrapAlignment: WrapAlignment.start,
                            onChanged: (newValue) {
                              setState(() {
                                if (newValue.toString().contains("Passport")) {
                                  _backviewvisibility = false;
                                  _fronttitle =
                                      "Upload a copy of your passport document here";
                                  _frontpicname = '';
                                  _backpicname = '';
                                  loadbackimg();
                                  loadfrontimg();
                                  demo.frontpicname = '';
                                  demo.frontview = '';
                                  demo.backpicname = '';
                                  demo.backview = '';
                                } else {
                                  _backviewvisibility = true;
                                  _frontpicname = '';
                                  _backpicname = '';
                                  loadbackimg();
                                  loadfrontimg();
                                  demo.frontpicname = '';
                                  demo.frontview = '';
                                  demo.backpicname = '';
                                  demo.backview = '';
                                  _fronttitle =
                                      "Upload a copy of the front view here";
                                }
                                demo.idtype = newValue.toString();
                              });
                              //_showsnackbar(newValue.toString(), "Okay");
                              print(newValue.toString());
                            },
                            onSaved: (newValue) {
                              setState(() {
                                demo.idtype = newValue.toString();
                              });
                            },
                            validator: FormBuilderValidators.required(context),
                            options: [
                              "Passport",
                              "Driver's License",
                              "National ID Card"
                            ]
                                .map((card) => FormBuilderFieldOption(
                                      value: card,
                                      child: Text('$card'),
                                    ))
                                .toList(growable: false)),
                      ),
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    new TextFormField(
                      controller: _idcardnumcontroller,
                      decoration: new InputDecoration(
                        labelText: "ID Card Number",
                        prefixIcon: Icon(Icons.credit_card),
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
                          demo.idcardnum = newValue!;
                        });
                      },
                      keyboardType: TextInputType.text,
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    Text(
                      _fronttitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        fontSize: 19,
                      ),
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 10)),
                    Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                _frontpicname,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              height: 40,
                              width: 400,
                              color: Colors.grey.withOpacity(.3),
                            ),
                            GestureDetector(
                              onTap: () {
                                _showfrontfilepicker(context);
                              },
                              child: displayselectedfrontfile(),
                            ),
                          ],
                        ),
                      ),
                      width: 400,
                      height: 350,
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(93, 93, 93, .3),
                        border: Border.all(
                            color: Color.fromRGBO(73, 73, 73, .3), width: 5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Visibility(
                      visible: _backviewvisibility,
                      child:
                          new Padding(padding: const EdgeInsets.only(top: 26)),
                    ),
                    Visibility(
                      visible: _backviewvisibility,
                      child: Text(
                        'Upload a copy of the rear view',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          fontSize: 19,
                        ),
                      ),
                    ),
                    Visibility(
                      visible: _backviewvisibility,
                      child:
                          new Padding(padding: const EdgeInsets.only(top: 10)),
                    ),
                    Visibility(
                      visible: _backviewvisibility,
                      child: Container(
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          child: Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(top: 10),
                                child: Text(
                                  _backpicname,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                                height: 40,
                                width: 400,
                                color: Colors.grey.withOpacity(.3),
                              ),
                              GestureDetector(
                                onTap: () {
                                  _showbackfilepicker(context);
                                },
                                child: displayselectedbackfile(),
                              ),
                            ],
                          ),
                        ),
                        width: 400,
                        height: 350,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(93, 93, 93, .3),
                          border: Border.all(
                              color: Color.fromRGBO(73, 73, 73, .3), width: 5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 43)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 15),
                          width: MediaQuery.of(context).size.width * 0.30,
                          height: 40,
                          child: new RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                    color: Color.fromRGBO(0, 0, 0, 0.09),
                                    width: 3),
                              ),
                              color: Color.fromRGBO(0, 0, 10, 1),
                              textColor: Colors.white,
                              child: new Text(
                                "Previous",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                setState(() {
                                  _scrollController.animateTo(0,
                                      duration: Duration(seconds: 1),
                                      curve: Curves.linear);
                                  firstwork = false;
                                  seconddemo = true;
                                  percent = 20.0;
                                  pcolor = Colors.black;
                                });
                              }),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 15),
                          width: MediaQuery.of(context).size.width * 0.30,
                          height: 40,
                          child: new RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                    color: Color.fromRGBO(0, 0, 0, 0.09),
                                    width: 3),
                              ),
                              color: Color.fromRGBO(0, 0, 10, 1),
                              textColor: Colors.white,
                              child: new Text(
                                "Next",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                setState(() {
                                  _scrollController.animateTo(0,
                                      duration: Duration(seconds: 1),
                                      curve: Curves.linear);
                                  final form = formkeys[2].currentState;
                                  if (form!.validate()) {
                                    if (_backviewvisibility.toString() ==
                                        "false") {
                                      if (Fp.basename(frontgalleryfile!.path)
                                              .toString() ==
                                          "pic.png") {
                                        _showsnackbar(
                                            "Please upload a picture of your passport document!",
                                            "Close");
                                      } else {
                                        form.save();
                                        firstwork = false;
                                        secondwork = true;
                                        percent = 60.0;
                                        pcolor = Colors.white;
                                      }
                                    } else {
                                      if (Fp.basename(frontgalleryfile!.path)
                                                  .toString() ==
                                              "pic.png" ||
                                          Fp.basename(backgalleryfile!.path)
                                                  .toString() ==
                                              "pic.png") {
                                        _showsnackbar(
                                            "Please upload pictures of the required documents!",
                                            "Close");
                                      } else {
                                        form.save();
                                        firstwork = false;
                                        secondwork = true;
                                        percent = 60.0;
                                        pcolor = Colors.white;
                                      }
                                    }
                                  }
                                });
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    transform: Matrix4.translationValues(0, -12.0, 0),
                    child: Text(
                      'WORK DETAILS',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.73),
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List selectedroles = [];
  _getselectedoption(bool schecked, String srole) {
    if (schecked == true) {
      setState(() {
        selectedroles.add(srole);
      });
    } else {
      setState(() {
        selectedroles.remove(srole);
      });
    }
  }

  List<bool> isChecked = [];

  _buildRolesWidget() {
    var datawidget;
    if (_fullroles.toString() == "false") {
      datawidget = Center(
        child: new Text(
          'Add roles',
          style: TextStyle(
            fontSize: 18,
            fontFamily: 'serif',
            color: Colors.white,
          ),
        ),
      );
    } else {
      datawidget = ListView.builder(
          shrinkWrap: true,
          itemCount: roledata.length,
          itemBuilder: (BuildContext context, int index) {
            // WRoles item = snapshot.data![index];
            return Padding(
              padding: const EdgeInsets.only(left: 5, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                      child: CheckboxListTile(
                    value: isChecked[index],
                    onChanged: (checked) {
                      isChecked[index] = checked!;
                      _getselectedoption(checked, roledata[index]['roleid']);
                    },
                    title: Text(roledata[index]['role']),
                  )),
                  IconButton(
                    iconSize: 20,
                    icon: Padding(
                      padding: EdgeInsets.all(3),
                      child: Icon(Icons.delete),
                    ),
                    onPressed: () {
                      _delrole(wchannel, roledata[index]['roleid']);
                    },
                  )
                ],
              ),
            );
          });
    }
    return datawidget;
  }

  _secondworkdetails(BuildContext context) {
    return Visibility(
      visible: secondwork,
      child: Form(
        key: formkeys[3],
        child: Container(
          margin: EdgeInsets.only(top: 15),
          padding: EdgeInsets.all(5.0),
          child: Stack(
            children: <Widget>[
              new Container(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.white.withOpacity(.6), width: 1),
                  color: Colors.black.withOpacity(.4),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _doecontroller,
                      decoration: InputDecoration(
                        labelText: 'Date of Employment',
                        helperText: _wordempdate,
                        prefixIcon: Icon(Icons.calendar_today),
                      ),
                      readOnly: true,
                      onTap: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        _empdateselectDate(context);
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
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    new DropdownButtonFormField<WRanks>(
                        key: _key[5],
                        value: _selectedRank,
                        decoration: new InputDecoration(
                            labelText: "Rank",
                            prefixIcon: Icon(Icons.people),
                            suffixIcon: Stack(
                              children: <Widget>[
                                Visibility(
                                  visible: _delrankvisibility,
                                  child: IconButton(
                                    icon: Padding(
                                      padding: EdgeInsets.all(3),
                                      child: Icon(Icons.delete),
                                    ),
                                    onPressed: () {
                                      _delrank(wchannel, demo.rank);
                                    },
                                  ),
                                ),
                                Visibility(
                                  visible: _refreshrank,
                                  child: IconButton(
                                    icon: Padding(
                                      padding: EdgeInsets.all(3),
                                      child: Icon(Icons.refresh),
                                    ),
                                    onPressed: () {
                                      _retryranks();
                                    },
                                  ),
                                )
                              ],
                            )),
                        items: rankdata.map((WRanks wRanks) {
                          return new DropdownMenuItem<WRanks>(
                              value: wRanks, child: new Text(wRanks.rank));
                        }).toList(),
                        validator: (value) {
                          _selectedRank = value!;
                          if (_selectedRank!.rankid == "") {
                            return 'This field is required';
                          }
                        },
                        onSaved: (newValue) {
                          setState(() {
                            _selectedRank = newValue!;
                            demo.rank = _selectedRank!.rankid.toString();
                          });
                        },
                        onChanged: (newValue) {
                          setState(() {
                            _selectedRank = newValue!;
                            if (_selectedRank!.rankid != "") {
                              demo.rank = _selectedRank!.rankid.toString();
                              _delrankvisibility = true;
                            }
                            if (_selectedRank!.rankid == "") {
                              _delrankvisibility = false;
                            }
                            if (_selectedRank!.rank
                                .toString()
                                .contains("Add More")) {
                              _rankvisibility = true;
                            }
                          });
                        }),
                    new Padding(padding: const EdgeInsets.only(top: 39)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        new Text(
                          'Roles',
                          style: TextStyle(
                            fontSize: 18,
                            fontFamily: 'serif',
                            decoration: TextDecoration.underline,
                            color: Colors.white,
                          ),
                        ),
                        Visibility(
                          visible: _refreshrole,
                          child: IconButton(
                            icon: Padding(
                              padding: EdgeInsets.all(3),
                              child: Icon(Icons.refresh),
                            ),
                            onPressed: () {
                              _retryroles();
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _rolevisibility = true;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Colors.white.withOpacity(.7),
                                  width: 1),
                              color: Color.fromRGBO(0, 0, 10, 1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 17)),
                    Container(
                      padding: EdgeInsets.all(0),
                      width: MediaQuery.of(context).size.width,
                      constraints:
                          BoxConstraints(minHeight: 30, maxHeight: 200),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(.43),
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: Colors.white.withOpacity(.6), width: 1),
                      ),
                      child: Stack(
                        children: [_buildRolesWidget()],
                      ),
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    new TextFormField(
                      controller: _nobcontroller,
                      decoration: new InputDecoration(
                        labelText: "Name of Bank",
                        prefixIcon: Icon(Icons.account_balance),
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
                          demo.nob = newValue!;
                        });
                      },
                      keyboardType: TextInputType.text,
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    new TextFormField(
                      controller: _accnamecontroller,
                      decoration: new InputDecoration(
                        labelText: "Account Name",
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
                          demo.acname = newValue!;
                        });
                      },
                      keyboardType: TextInputType.text,
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    new TextFormField(
                      controller: _acnumcontroller,
                      decoration: new InputDecoration(
                        labelText: "Account Number",
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
                          demo.acnum = newValue!;
                        });
                      },
                      keyboardType: TextInputType.text,
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 42)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 15),
                          width: MediaQuery.of(context).size.width * 0.30,
                          height: 40,
                          child: new RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                    color: Color.fromRGBO(0, 0, 0, 0.09),
                                    width: 3),
                              ),
                              color: Color.fromRGBO(0, 0, 10, 1),
                              textColor: Colors.white,
                              child: new Text(
                                "Previous",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                setState(() {
                                  _scrollController.animateTo(0,
                                      duration: Duration(seconds: 1),
                                      curve: Curves.linear);
                                  firstwork = true;
                                  secondwork = false;
                                  percent = 40.0;
                                  pcolor = Colors.black;
                                });
                              }),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 15),
                          width: MediaQuery.of(context).size.width * 0.30,
                          height: 40,
                          child: new RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                    color: Color.fromRGBO(0, 0, 0, 0.09),
                                    width: 3),
                              ),
                              color: Color.fromRGBO(0, 0, 10, 1),
                              textColor: Colors.white,
                              child: new Text(
                                "Next",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                setState(() {
                                  final form = formkeys[3].currentState;
                                  if (form!.validate()) {
                                    if (selectedroles.isEmpty) {
                                      _showsnackbar(
                                          "Please assign roles to worker!",
                                          "Close");
                                    } else {
                                      form.save();
                                      _scrollController.animateTo(0,
                                          duration: Duration(seconds: 1),
                                          curve: Curves.linear);
                                      secondwork = false;
                                      acinfo = true;
                                      percent = 80.0;
                                      pcolor = Colors.white;
                                    }
                                  }
                                });
                              }),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Positioned(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    transform: Matrix4.translationValues(0, -12.0, 0),
                    child: Text(
                      'WORK DETAILS',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.73),
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _accountdetails(BuildContext context) {
    return Visibility(
      visible: acinfo,
      child: Form(
        key: formkeys[4],
        child: Container(
          margin: EdgeInsets.only(top: 15),
          padding: EdgeInsets.all(5.0),
          child: Stack(
            children: <Widget>[
              new Container(
                padding:
                    EdgeInsets.all(MediaQuery.of(context).size.width * 0.05),
                decoration: BoxDecoration(
                  border:
                      Border.all(color: Colors.white.withOpacity(.6), width: 1),
                  color: Colors.black.withOpacity(.4),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Column(
                  children: <Widget>[
                    new TextFormField(
                      controller: _empidcontroller,
                      decoration: new InputDecoration(
                        labelText: "Employee's ID",
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
                          demo.empid = newValue!;
                        });
                      },
                      keyboardType: TextInputType.text,
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    new TextFormField(
                      controller: _pwordcontroller..text = "chworker2021",
                      decoration: new InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.security),
                        suffixIcon: IconButton(
                          icon: Padding(
                            padding: EdgeInsets.all(3),
                            child: pressed == true
                                ? Icon(Icons.visibility_off_rounded)
                                : Icon(Icons.visibility_rounded),
                          ),
                          onPressed: () {
                            setState(() {
                              pressed = !pressed;
                              _obscuretext = !_obscuretext;
                            });
                          },
                        ),
                      ),
                      readOnly: true,
                      onSaved: (newValue) {
                        setState(() {
                          demo.emppass = newValue!;
                        });
                      },
                      keyboardType: TextInputType.text,
                      obscureText: !_obscuretext,
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 26)),
                    Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        child: Column(
                          children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(top: 10),
                              child: Text(
                                'Profile Picture',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                              height: 40,
                              width: 400,
                              color: Colors.grey.withOpacity(.3),
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
                        color: Color.fromRGBO(93, 93, 93, .3),
                        border: Border.all(
                            color: Color.fromRGBO(73, 73, 73, .3), width: 5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    new Padding(padding: const EdgeInsets.only(top: 42)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.only(left: 15),
                          width: MediaQuery.of(context).size.width * 0.30,
                          height: 40,
                          child: new RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                    color: Color.fromRGBO(0, 0, 0, 0.09),
                                    width: 3),
                              ),
                              color: Color.fromRGBO(0, 0, 10, 1),
                              textColor: Colors.white,
                              child: new Text(
                                "Previous",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                setState(() {
                                  _scrollController.animateTo(0,
                                      duration: Duration(seconds: 1),
                                      curve: Curves.linear);
                                  secondwork = true;
                                  acinfo = false;
                                  percent = 60.0;
                                  pcolor = Colors.white;
                                });
                              }),
                        ),
                        Container(
                          padding: EdgeInsets.only(right: 15),
                          width: MediaQuery.of(context).size.width * 0.30,
                          height: 40,
                          child: new RaisedButton(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                                side: BorderSide(
                                    color: Color.fromRGBO(0, 0, 0, 0.09),
                                    width: 3),
                              ),
                              color: Color.fromRGBO(0, 0, 10, 1),
                              textColor: Colors.white,
                              child: new Text(
                                "Next",
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                              onPressed: () {
                                setState(() {
                                  final form = formkeys[4].currentState;
                                  if (form!.validate()) {
                                    if (Fp.basename(galleryfile!.path)
                                            .toString() ==
                                        "pic.png") {
                                      _showsnackbar(
                                          "Please select a picture", "Close");
                                    } else {
                                      form.save();
                                      percent = 100.0;
                                      demo.roles = selectedroles.join(', ');
                                      Future.delayed(Duration(seconds: 3))
                                          .then((value) {
                                        _showsnackbar(
                                            "Please wait, request is being processed",
                                            "Close");
                                        _diagvisibility = true;
                                        _createadminworker();
                                      });
                                      pcolor = Colors.white;
                                    }
                                  }
                                });
                              }),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Positioned(
                child: Align(
                  alignment: Alignment.center,
                  child: Container(
                    padding: EdgeInsets.all(5),
                    transform: Matrix4.translationValues(0, -12.0, 0),
                    child: Text(
                      'ACCOUNT DETAILS',
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: 'serif',
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(.73),
                      borderRadius: BorderRadius.circular(9),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _finaldelrank(String channel, String rankid) async {
    var url = "http://www.emkapp.com/emkapp/ranks-insert.php";
    var bdata = {"txtDelRank": rankid, "rank_id": rankid};
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
          getranks(wchannel);
          setState(() {
            _diagvisibility = false;
            _rankvisibility = false;
            _delrankvisibility = false;
            _key[5].currentState!.reset();
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

  _finaldelrole(String channel, String roleid) async {
    var url = "http://www.emkapp.com/emkapp/roles-insert.php";
    var bdata = {"txtDelRole": roleid, "channel_id": channel};
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
          getroles(wchannel);
          setState(() {
            _diagvisibility = false;
            _rolevisibility = false;
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

  _delrole(String channel, String roleid) {
    Widget cancelbtn = FlatButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop(context);
      },
      child: Text("Cancel"),
    );
    Widget continuebtn = FlatButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop(context);
        _finaldelrole(channel, roleid);
      },
      child: Text("Continue"),
    );

    AlertDialog alert = AlertDialog(
      title: Text("Warning"),
      content: Text("Sure about deleting  role?"),
      actions: [cancelbtn, continuebtn],
    );

    return showDialog(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  _delrank(String channel, String rankid) {
    Widget cancelbtn = FlatButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop(context);
      },
      child: Text("Cancel"),
    );
    Widget continuebtn = FlatButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop(context);
        _finaldelrank(channel, rankid);
      },
      child: Text("Continue"),
    );

    AlertDialog alert = AlertDialog(
      title: Text("Warning"),
      content: Text("Sure about deleting selected rank?"),
      actions: [cancelbtn, continuebtn],
    );

    return showDialog(
      context: context,
      builder: (context) {
        return alert;
      },
    );
  }

  createrole(String channel, String rolename) async {
    var url = "http://www.emkapp.com/emkapp/roles-insert.php";
    var bdata = {"txtAddRole": rolename, "channel_id": channel};
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
          getroles(wchannel);
          setState(() {
            _diagvisibility = false;
            _rolevisibility = false;
            _roleformkey.currentState!.reset();
          });
        });
      } else {
        _showsnackbar("Error creating role.", "Close");
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

  createrank(String channel, String rankname) async {
    var url = "http://www.emkapp.com/emkapp/ranks-insert.php";
    var bdata = {"txtAddRank": rankname, "channel_id": channel};
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
          getranks(wchannel);
          selectedroles.clear();
          getroles(wchannel);
          setState(() {
            _diagvisibility = false;
            _rankvisibility = false;
            _rankformkey.currentState!.reset();
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
                        Theme(
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
                              Visibility(
                                visible: _progressvisibility,
                                child: Container(
                                    height: 30,
                                    width: MediaQuery.of(context).size.width,
                                    padding: EdgeInsets.only(left: 7, right: 7),
                                    color: Color.fromRGBO(0, 0, 0, .3),
                                    child: LinearPercentIndicator(
                                      //leaner progress bar
                                      animation: true,
                                      animationDuration: 1000,
                                      lineHeight: 15.0,
                                      percent: percent / 100,
                                      center: Text(
                                        percent.toString() + "%",
                                        style: TextStyle(
                                            fontSize: 10.0,
                                            fontWeight: FontWeight.w600,
                                            color: pcolor),
                                      ),
                                      linearStrokeCap: LinearStrokeCap.roundAll,
                                      progressColor:
                                          Color.fromRGBO(0, 0, 10, 1),
                                      backgroundColor: Colors.grey[300],
                                    )),
                              ),
                              Expanded(
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height - 30,
                                  child: Center(
                                    child: SingleChildScrollView(
                                      controller: _scrollController,
                                      child: Column(children: <Widget>[
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
                                                const EdgeInsets.only(top: 20)),
                                        _firstdemography(context),
                                        _seconddemography(context),
                                        _firstworkdetails(context),
                                        _secondworkdetails(context),
                                        _accountdetails(context),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 30)),
                                      ]),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Visibility(
                          visible: _rolevisibility,
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
                                          'Add Role',
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
                                        key: _roleformkey,
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
                                                decoration: new InputDecoration(
                                                  labelText: "Enter role here",
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
                                                    _roletxtname = newValue!;
                                                  });
                                                },
                                                keyboardType:
                                                    TextInputType.text,
                                              ),
                                              Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 20)),
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
                                                                  .circular(15),
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
                                                        textColor: Colors.white,
                                                        child: new Text(
                                                          "Add Role",
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                        onPressed: () {
                                                          final form =
                                                              _roleformkey
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

                                                            createrole(
                                                                "Admin20210508024527",
                                                                _roletxtname);
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
                                                                  .circular(15),
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
                                                        textColor: Colors.white,
                                                        child: new Text(
                                                          "Cancel",
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            _roleformkey
                                                                .currentState!
                                                                .reset();
                                                            _rolevisibility =
                                                                false;
                                                          });
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
                          visible: _rankvisibility,
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
                                          'Add Rank',
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
                                        key: _rankformkey,
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
                                                decoration: new InputDecoration(
                                                  labelText: "Enter rank here",
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
                                                    _ranktxtname = newValue!;
                                                  });
                                                },
                                                keyboardType:
                                                    TextInputType.text,
                                              ),
                                              Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 20)),
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
                                                                  .circular(15),
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
                                                        textColor: Colors.white,
                                                        child: new Text(
                                                          "Add Rank",
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                        onPressed: () {
                                                          final form =
                                                              _rankformkey
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

                                                            createrank(
                                                                "Admin20210508024527",
                                                                _ranktxtname);
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
                                                                  .circular(15),
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
                                                        textColor: Colors.white,
                                                        child: new Text(
                                                          "Cancel",
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        ),
                                                        onPressed: () {
                                                          setState(() {
                                                            _rankformkey
                                                                .currentState!
                                                                .reset();
                                                            _rankvisibility =
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ))),
    );
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
