import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io' as Io;
import 'package:dio/dio.dart';
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

void main() => runApp(AddWorkAdmin());

class AddWorkAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainAddWorkAdmin(),
    );
  }
}

class MainAddWorkAdmin extends StatefulWidget {
  @override
  State createState() => new AddWorkAdminState();
}

enum AppState {
  free,
  picked,
  cropped,
}

class AddWorkAdminState extends State<MainAddWorkAdmin>
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
  late TextEditingController _fnamecontroller,
      _lnamecontroller,
      _titlecontroller,
      _pwordcontroller,
      _uidcontroller,
      _emailcontroller,
      _contactcontroller;
  bool isButtonEnabled = true, _diagvisibility = false;
  File? galleryfile, camerafile;
  String _imgfile = '', _finalfile = '';
  bool _autovalidatename = false;
  String base64image = '';
  final _formkey = GlobalKey<FormState>();
  final _key = GlobalKey<FormFieldState>();
  late ScrollController _scrollController;

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
    loadimg();
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

  String _serveresponse = '';

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
        final bytes = Io.File(galleryfile!.path).readAsBytesSync();
        _imgfile = galleryfile.toString().split('/').last.split('r').last;
        base64image = base64Encode(bytes);
        _finalfile = _imgfile.substring(0, _imgfile.indexOf('\''));
        appstate = AppState.cropped;
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

  createadmin(_firstname, _lastname, _title, galleryfile, _contact, _email,
      _userid, _password) async {
    // _showsnackbar(Fp.basename(galleryfile.path).toString() + "\n" + _email, "Okay");
    var url = "http://www.emkapp.com/emkapp/api/workadmin.php";
    var bdata = {
      "uid": _uidcontroller.text,
      "pw": _pwordcontroller.text,
      "title": _title,
      "firstname": _fnamecontroller.text,
      "lastname": _lastname,
      "email": _email,
      "contact": _contact,
      "imgname": Fp.basename(galleryfile.path).toString(),
      "img": base64image,
      "operation": "",
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
        _fnamecontroller.clear();
        _lnamecontroller.clear();
        _titlecontroller.clear();
        _pwordcontroller.clear();
        _uidcontroller.clear();
        _emailcontroller.clear();
        _contactcontroller.clear();
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
                                          controller: _pwordcontroller,
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
                                                          _password);
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
