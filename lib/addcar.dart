import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io' as Io;
import 'dart:async' show Future;
import 'package:dio/dio.dart';
import 'package:emkapp/workersdashboard.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cached_network_image/cached_network_image.dart';
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

void main() => runApp(AddWorkersCar());

class AddWorkersCar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainAddWorkersCar(),
    );
  }
}

class MainAddWorkersCar extends StatefulWidget {
  @override
  State createState() => new AddWorkersCarState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class AddWorkersCarState extends State<MainAddWorkersCar>
    with TickerProviderStateMixin {
  static NewCarData ncdata = new NewCarData();

  late AppState appstate;
  String base64image = '';
  Uint8List bytes = Uint8List(0);
  File? galleryfile, camerafile, emptygalleryfile;
  String eximg = '', exname = '', exid = '', exmail = '', excon = '';
  List imagelist = [];
  List imageencodedlist = [];
  List imagenamelist = [];
  bool isButtonEnabled = true,
      _diagvisibility = false,
      _verify = false,
      channelvisibility = false,
      _refreshchannels = false;

  late ProgressDialog pr;
  bool pressed = false,
      _obscuretext = false,
      _visibility = false,
      _delchannelvisibility = false;

  Color? primarycolor = Color.fromRGBO(0, 0, 11, 1);
  late SharedPreferences sharedpref;
  late SnackBar snackBar;
  String user = '', _imgname = '', _nimgdir = '', _passw = '';

  late AnimationController _animcon;
  bool _autovalidatename = false, _vinvisibility = true;
  GlobalKey<FormState> _vinformkey = GlobalKey<FormState>();
  GlobalKey<FormState> _channelformkey = GlobalKey<FormState>();
  String _channeltxtname = '';
  late TextEditingController _yearcontroller,
      _makecontroller,
      _modelcontroller,
      _trimcontroller,
      _countrycontroller,
      _chassisnocontroller,
      _wblcontroller,
      _dimensioncontroller,
      _abscontroller,
      _drivetraincontroller,
      _mileagecontroller,
      _bodycontroller,
      _enginecontroller,
      _transmissioncontroller,
      _partscostcontroller,
      _towingcostcontroller,
      _purchasingcostcontroller,
      _shippingcontroller,
      _vincontroller;

  late List<DropdownMenuItem<String>> _dropDownMenuTitles;
  String _firstname = '',
      _lastname = '',
      _title = '',
      message = '',
      _password = '',
      _userid = '',
      _email = '',
      _contact = '';

  final _formkey = GlobalKey<FormState>();
  late Animation<double> _iconanim;
  late AnimationController _iconanimcontroller;
  late Directory _imgdir;
  String _imgfile = '', _finalfile = '';
  final _key = GlobalKey<FormFieldState>();
  final ImagePicker _picker = ImagePicker();
  late ScrollController _scrollController;
  String _serveresponse = '', carnum = 'WP0CA29873U624034';
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

  List<ColorData> colorsdata = [];
  ColorData? _selectedColor;
  Future<String> loadJsonData() async {
    var jtext = await rootBundle.loadString('assets/colors.json');
    setState(() {
      //colorsdata = json.decode(jtext);
      colorsdata = List<ColorData>.from(
          json.decode(jtext).map((i) => ColorData.fromJson(i)));
    });
    return 'done';
  }

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
      uid = '';

  @override
  void dispose() {
    _scrollController.dispose();
    _animcon.dispose();
    _iconanimcontroller.dispose();
    _yearcontroller.dispose();
    _makecontroller.dispose();
    _modelcontroller.dispose();
    _trimcontroller.dispose();
    _countrycontroller.dispose();
    _chassisnocontroller.dispose();
    _wblcontroller.dispose();
    _dimensioncontroller.dispose();
    _abscontroller.dispose();
    _drivetraincontroller.dispose();
    _mileagecontroller.dispose();
    _bodycontroller.dispose();
    _enginecontroller.dispose();
    _transmissioncontroller.dispose();
    _vincontroller.dispose();
    _partscostcontroller.dispose();
    _towingcostcontroller.dispose();
    _purchasingcostcontroller.dispose();
    _shippingcontroller.dispose();
    super.dispose();
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

    super.initState();
    loadimg();
    getcardata(carnum);
    this.loadJsonData();
    // eximg = 'http://www.emkapp.com/emkapp/icons/CSI3.png';
    _scrollController = ScrollController();

    _yearcontroller = new TextEditingController();
    _makecontroller = new TextEditingController();
    _modelcontroller = new TextEditingController();
    _trimcontroller = new TextEditingController();
    _countrycontroller = new TextEditingController();
    _chassisnocontroller = new TextEditingController();
    _wblcontroller = new TextEditingController();
    _dimensioncontroller = new TextEditingController();
    _abscontroller = new TextEditingController();
    _drivetraincontroller = new TextEditingController();
    _mileagecontroller = new TextEditingController();
    _bodycontroller = new TextEditingController();
    _enginecontroller = new TextEditingController();
    _transmissioncontroller = new TextEditingController();
    _vincontroller = new TextEditingController();
    _partscostcontroller = new TextEditingController();
    _towingcostcontroller = new TextEditingController();
    _purchasingcostcontroller = new TextEditingController();
    _shippingcontroller = new TextEditingController();
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
      emptygalleryfile = File('$tempPath/pic.png');
    });

    await emptygalleryfile!.writeAsBytes(
        bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes));
    return emptygalleryfile;
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

  _uploadadmincar(String imageencoded, String imagenames) async {
    String lotnum = wchannel.substring(0, 4) +
        _makecontroller.text.toString().substring(0, 4) +
        _modelcontroller.text.toString().substring(0, 4) +
        _yearcontroller.text.toString().substring(0, 4);
    var bdata = {
      'car_partsamt': _partscostcontroller.text.toString(),
      'car_purchasecost': _purchasingcostcontroller.text.toString(),
      'car_shippingcost': _shippingcontroller.text.toString(),
      'car_towingcost': _towingcostcontroller.text.toString(),
      'channel': wchannel,
      'car_lotnum': lotnum,
      'insertrequest': 'true',
      'insertedby': uid,
      'car_year': _yearcontroller.text.toString(),
      'car_make': _makecontroller.text.toString(),
      'car_model': _modelcontroller.text.toString(),
      'car_trim': _trimcontroller.text.toString(),
      'car_drivetrain': _drivetraincontroller.text.toString(),
      'car_body': _bodycontroller.text.toString(),
      'car_engine': _enginecontroller.text.toString(),
      'car_color': ncdata.ccolor,
      'car_mileage': _mileagecontroller.text.toString(),
      'car_chassisno': _chassisnocontroller.text.toString(),
      'country': _countrycontroller.text.toString(),
      'car_transmission': _transmissioncontroller.text.toString(),
      'car_dimensions': _dimensioncontroller.text.toString(),
      'wheelbase_length': _wblcontroller.text.toString(),
      'anti_brake_system': _abscontroller.text.toString(),
      'images': imageencoded,
      'imagenames': imagenames,
    };
    FormData fdata = FormData.fromMap(bdata);
    var url = 'http://www.emkapp.com/emkapp/api/AddWorkersCar.php';
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
        _showsnackbar("Car has been successfully added", "Close");

        _scrollController.animateTo(0,
            duration: Duration(seconds: 1), curve: Curves.linear);

        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (BuildContext ncontext) => MainWorkersDashboard(
                      opt: "0",
                      rdate: '',
                    )));
      } else {
        setState(() {
          _diagvisibility = false;
          _showsnackbar("Car already exists in database", "Close");
        });
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

  getcardata(String cnum) async {
    var url =
        "https://api.carsxe.com/specs?key=bvc339qso_05realx8e_sf97wl6bm&vin=" +
            cnum; //Obj
    var data = await http.get(Uri.parse(url));
    if (data.statusCode == 200) {
      var jsonData = jsonDecode(data.body);
      //print("Car data : " + jsonData.toString());
      print("Car data -: Year : " +
          jsonData["attributes"]["year"] +
          ", Chassis no : " +
          jsonData["input"]["vin"]);
    }
  }

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
        var imgname = Fp.basename(croppedfile.path).toString();
        final bytes = Io.File(galleryfile!.path).readAsBytesSync();
        _imgfile = galleryfile.toString().split('/').last.split('r').last;
        base64image = base64Encode(bytes);
        _finalfile = _imgfile.substring(0, _imgfile.indexOf('\''));
        appstate = AppState.cropped;
        imagelist.add(croppedfile);
        imageencodedlist.add(base64image);
        imagenamelist.add(imgname);
      });
      _buildPictureWidget();
    }
  }

  displayselectedfile(File selfile) {
    return Container(
        height: 260,
        width: double.infinity,
        decoration: new BoxDecoration(
          //this is not accepted becuse Image.file is not ImageProvider
          image: new DecorationImage(
              image: new FileImage(selfile), fit: BoxFit.fill),
        ));
  }

  _dismissdialog() {
    setState(() {
      _verify = false;
    });
  }

  _delimg(int index) {
    setState(() {
      imagelist.removeAt(index);
      imageencodedlist.removeAt(index);
      imagenamelist.removeAt(index);
    });

    _buildPictureWidget();
  }

  _buildPictureWidget() {
    var datawidget;
    if (imagelist.isEmpty) {
      datawidget = SizedBox(
        height: 300,
        width: 400,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: EdgeInsets.only(left: 0),
            width: MediaQuery.of(context).size.width,
            child: emptygalleryfile == null
                ? new Image.asset('assets/images/pic.png',
                    height: 300.0, width: MediaQuery.of(context).size.width)
                : new Image.file(emptygalleryfile!,
                    height: 300.0, width: MediaQuery.of(context).size.width),
          ),
        ),
      );
    } else {
      datawidget = ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemCount: imagelist.length,
          itemBuilder: (BuildContext context, int index) {
            // WRoles item = snapshot.data![index];
            return Padding(
              padding: const EdgeInsets.only(top: 5, bottom: 10),
              child: Container(
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  child: Column(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {},
                        child: displayselectedfile(imagelist[index]),
                      ),
                      Container(
                        child: Center(
                          child: IconButton(
                            iconSize: 20,
                            icon: Padding(
                              padding: EdgeInsets.all(3),
                              child: Icon(Icons.delete),
                            ),
                            onPressed: () {
                              _delimg(index);
                            },
                          ),
                        ),
                        height: 40,
                        width: 400,
                        color: Colors.grey.withOpacity(.3),
                      ),
                    ],
                  ),
                ),
                width: 400,
                height: 310,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(93, 93, 93, .3),
                  border: Border.all(
                      color: Color.fromRGBO(73, 73, 73, .3), width: 5),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
          });
    }
    return datawidget;
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
                            padding: const EdgeInsets.all(10.0),
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
                                      controller: _scrollController,
                                      shrinkWrap: true,
                                      children: <Widget>[
                                        new TextFormField(
                                          controller: _yearcontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Year",
                                            prefixIcon: Icon(Icons.car_rental),
                                          ),
                                          readOnly: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _modelcontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Model",
                                            prefixIcon: Icon(Icons.car_rental),
                                          ),
                                          readOnly: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _trimcontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Trim",
                                            prefixIcon: Icon(Icons.car_rental),
                                          ),
                                          readOnly: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _makecontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Make",
                                            prefixIcon: Icon(Icons.car_rental),
                                          ),
                                          readOnly: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _drivetraincontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Drivetrain",
                                            prefixIcon: Icon(Icons.car_rental),
                                          ),
                                          readOnly: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _bodycontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Body",
                                            prefixIcon: Icon(Icons.car_rental),
                                          ),
                                          readOnly: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _enginecontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Engine Type",
                                            prefixIcon: Icon(Icons.car_rental),
                                          ),
                                          readOnly: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        DropdownButtonHideUnderline(
                                          child: new DropdownButtonFormField<
                                                  ColorData>(
                                              value: _selectedColor,
                                              decoration: new InputDecoration(
                                                labelText: "Color",
                                                prefixIcon:
                                                    Icon(Icons.color_lens),
                                              ),
                                              items: colorsdata
                                                  .map((ColorData colorData) {
                                                var ncolor;

                                                if (colorData.colorid == "") {
                                                  ncolor = "0x00000000";
                                                } else {
                                                  ncolor = "0xff" +
                                                      colorData.colorid
                                                          .toString()
                                                          .substring(1);
                                                }
                                                var tcolor;
                                                Color scolor =
                                                    Color(int.parse(ncolor));

                                                final double relativeLuminance =
                                                    scolor.computeLuminance();
                                                const double
                                                    brightnessThreshold = 0.15;
                                                if ((relativeLuminance + 0.05) *
                                                        (relativeLuminance +
                                                            0.05) >
                                                    brightnessThreshold) {
                                                  tcolor = Colors.black;
                                                } else if ((relativeLuminance +
                                                            0.05) *
                                                        (relativeLuminance +
                                                            0.05) <
                                                    brightnessThreshold) {
                                                  tcolor = Colors.white;
                                                } else {
                                                  tcolor = Colors.white;
                                                }
                                                return new DropdownMenuItem<
                                                        ColorData>(
                                                    value: colorData,
                                                    child: Container(
                                                        height: 30,
                                                        padding:
                                                            EdgeInsets.only(
                                                          top: 5,
                                                          left: 5,
                                                        ),
                                                        width: (MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width) -
                                                            92,
                                                        color: Color(
                                                            int.parse(ncolor)),
                                                        child: new Text(
                                                          colorData.colorname,
                                                          style: TextStyle(
                                                              color: tcolor),
                                                        )));
                                              }).toList(),
                                              validator: (value) {
                                                _selectedColor = value!;
                                                if (_selectedColor!.colorid ==
                                                    "") {
                                                  return 'This field is required';
                                                }
                                              },
                                              onSaved: (newValue) {
                                                setState(() {
                                                  _selectedColor = newValue!;
                                                  ncdata.ccolor =
                                                      _selectedColor!.colorid
                                                          .toString();
                                                });
                                              },
                                              onChanged: (newValue) {
                                                setState(() {
                                                  _selectedColor = newValue!;
                                                  if (_selectedColor!.colorid !=
                                                      "") {
                                                    _selectedColor = newValue!;
                                                    ncdata.ccolor =
                                                        _selectedColor!.colorid
                                                            .toString();
                                                  }
                                                });
                                              }),
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _mileagecontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Mileage",
                                            prefixIcon: Icon(Icons.car_rental),
                                          ),
                                          readOnly: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _chassisnocontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Chassis No.",
                                            prefixIcon: Icon(Icons.car_rental),
                                          ),
                                          readOnly: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _countrycontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Country",
                                            prefixIcon: Icon(Icons.flag),
                                          ),
                                          readOnly: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _transmissioncontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Transmission",
                                            prefixIcon: Icon(Icons.settings),
                                          ),
                                          readOnly: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _dimensioncontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Dimensions",
                                            prefixIcon: Icon(Icons.car_rental),
                                          ),
                                          readOnly: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _wblcontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Wheelbase Length",
                                            prefixIcon: Icon(Icons.two_wheeler),
                                          ),
                                          readOnly: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _abscontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Anti Break System",
                                            prefixIcon: Icon(Icons.flag),
                                          ),
                                          readOnly: true,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        ClipRRect(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10.0)),
                                          child: Container(
                                            height: 340,
                                            width: MediaQuery.of(context)
                                                .size
                                                .width,
                                            padding: EdgeInsets.all(10.0),
                                            color: Colors.black.withOpacity(.4),
                                            child: _buildPictureWidget(),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 20),
                                          child: FractionallySizedBox(
                                            widthFactor: 0.40,
                                            child: RaisedButton(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(15),
                                                  side: BorderSide(
                                                      color: Colors
                                                          .blueGrey.shade900,
                                                      width: 3),
                                                ),
                                                color:
                                                    Color.fromRGBO(0, 0, 15, 1),
                                                textColor: Colors.white,
                                                child: new Text(
                                                  "Attach Images",
                                                  textAlign: TextAlign.center,
                                                  style:
                                                      TextStyle(fontSize: 12),
                                                ),
                                                onPressed: () {
                                                  _showfilepicker(context);
                                                }),
                                          ),
                                        ),
                                        new TextFormField(
                                          controller: _partscostcontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Cost of Parts",
                                            prefixIcon: Icon(Icons.money),
                                          ),
                                          readOnly: false,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _purchasingcostcontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Cost of Purchasing",
                                            prefixIcon: Icon(Icons.money),
                                          ),
                                          readOnly: false,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _shippingcontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Cost of Shipping",
                                            prefixIcon: Icon(Icons.money),
                                          ),
                                          readOnly: false,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 26)),
                                        new TextFormField(
                                          controller: _towingcostcontroller,
                                          decoration: new InputDecoration(
                                            labelText: "Cost of Towing",
                                            prefixIcon: Icon(Icons.money),
                                          ),
                                          readOnly: false,
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          keyboardType: TextInputType.text,
                                        ),
                                        new Padding(
                                            padding:
                                                const EdgeInsets.only(top: 43)),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding:
                                                  EdgeInsets.only(left: 15),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.28,
                                              height: 40,
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
                                                    "Submit",
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  ),
                                                  onPressed: () {
                                                    if (isButtonEnabled) {
                                                      final form =
                                                          _formkey.currentState;
                                                      if (form!.validate()) {
                                                        form.save();

                                                        if (imagelist.isEmpty) {
                                                          _showsnackbar(
                                                              "Please attach images of car",
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
                                                            _diagvisibility =
                                                                true;
                                                          });

                                                          int imagelistcount =
                                                              imagelist.length;
                                                          String _imageencoded =
                                                                  "",
                                                              _imagenames = "";
                                                          if (imagelistcount <
                                                              2) {
                                                            _imageencoded =
                                                                imageencodedlist
                                                                    .join("");
                                                            _imagenames =
                                                                imagenamelist
                                                                    .join("");
                                                          } else {
                                                            _imageencoded =
                                                                imageencodedlist
                                                                    .join(", ");
                                                            _imagenames =
                                                                imagenamelist
                                                                    .join(", ");
                                                          }

                                                          _uploadadmincar(
                                                              _imageencoded,
                                                              _imagenames);
                                                        }
                                                      }
                                                    }
                                                  }),
                                            ),
                                            Container(
                                              padding:
                                                  EdgeInsets.only(left: 15),
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.28,
                                              height: 40,
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
                                                    "Back",
                                                    style:
                                                        TextStyle(fontSize: 15),
                                                  ),
                                                  onPressed: () {
                                                    setState(() {
                                                      _vinvisibility = true;
                                                    });
                                                  }),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )),
                            ),
                          ),
                          Visibility(
                            visible: _vinvisibility,
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
                                            'Enter VIN Here',
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
                                          key: _vinformkey,
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
                                                  controller: _vincontroller,
                                                  decoration:
                                                      new InputDecoration(
                                                    labelText:
                                                        "Vehicle Identification Number",
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
                                                      _vincontroller.text =
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
                                                      MainAxisAlignment.center,
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
                                                            "Submit",
                                                            style: TextStyle(
                                                                fontSize: 12),
                                                          ),
                                                          onPressed: () {
                                                            final form =
                                                                _vinformkey
                                                                    .currentState;
                                                            if (form!
                                                                .validate()) {
                                                              form.save();

                                                              message =
                                                                  'Please wait, request is being processed...';

                                                              _showsnackbar(
                                                                  message, "");

                                                              getcardata(
                                                                  _vincontroller
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
}
