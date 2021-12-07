import 'dart:async';
import 'dart:convert';
import 'dart:io' as Io;
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter_filereader/flutter_filereader.dart';
import 'package:audio_manager/audio_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:marquee/marquee.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as Fp;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record_mp3/record_mp3.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

import 'helperclass.dart';
import 'lockscreen.dart';
import 'login.dart';

//import 'package:file_picker_example/src/file_picker_demo.dart';
void main() {
  runApp(ComMessages());
}

class ComMessages extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return MaterialApp(
      title: 'EM-KAPP',
      debugShowCheckedModeBanner: false,
      home: MainComMessages(),
    );
  }
}

class MainComMessages extends StatefulWidget {
  MainComMessages({Key? key}) : super(key: key);

  @override
  State createState() => _ComMessagesState();
}

class _ComMessagesState extends State<MainComMessages>
    with TickerProviderStateMixin {
  String base64image = '';
  File? galleryfile, camerafile, emptygalleryfile;
  FilePickerResult? fpresult;
  int i = 0;
  bool isPlayingMsg = false,
      isRecording = false,
      isSending = false,
      isTimerRecording = false,
      _playervisible = false,
      _uploadcommentvisible = false;
  TextEditingController _ucomcon = new TextEditingController();

  List<bool> isSelectedPlaying = [],
      isPictureDownloaded = [],
      isAudioDownloaded = [],
      isDocumentDownloaded = [],
      isVideoDownloaded = [];

  String minsStr = "00", secsStr = "00", _uimg = "", _uaudio = "";
  bool pressed = false,
      _obscuretext = false,
      _visibility = false,
      _headmenuvisible = true;
  int uindex = 0;
  String recordFilePath = "",
      _mediafilepath = "",
      _mediatype = "",
      _filename = "";

  List serverresponse = [],
      secondserverresponse = [],
      searchserverresponse = [],
      workersresponse = [],
      secondworkersresponse = [],
      searchworkersresponse = [],
      messagesresponse = [],
      secondmessagesresponse = [],
      searchmessagesresponse = [],
      filteredaudio = [],
      filteredimage = [],
      filtereddocument = [];
  Duration _duration = new Duration(), _durationone = new Duration();
  Duration _position = new Duration(), _positionone = new Duration();
  AudioPlayer? advancedPlayer, advancedPlayerOne;
  AudioCache? audioCache, audioCacheOne;
  late SnackBar snackBar;
  Stream<int>? timerStream;
  StreamSubscription<int>? timerSubscription;
  String user = '', userid = '', _imgname = '', _nimgdir = '', _passw = '';
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
      uid = '';
  bool _clearbtnvisibility = false,
      _searchbtnvisibility = true,
      _mclearbtnvisibility = false,
      _msearchbtnvisibility = true,
      _wclearbtnvisibility = false,
      _wsearchbtnvisibility = true,
      _searchwidgetvisibility = false;
  late AnimationController _animcon;
  Directory? _appDir, _appDirFolder;
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
      iseditable = true,
      _resendwidgetvisibility = false,
      _allmessagesvisible = true,
      _allworkersvisible = false,
      _submessagesvisible = false,
      _submenuVisible = false,
      _filterformvisible = false,
      _cartvisibility = false,
      _sendbtnvisibility = false,
      _recordbtnvisibility = true,
      flag = true,
      _timervisibility = false;

  late AnimationController _iconanimcontroller, _fabcon;
  Future<List<OpenSelectedChat>>? _future;
  Future<List<AllMessageWorkers>>? _wfuture;
  Future<List<AllChatWorkers>>? _cwfuture;
  late Animation<double> _iconanim;
  late Directory _imgdir;
  String _imgfile = '', _finalfile = '';
  TextEditingController _messagecon = new TextEditingController();
  GlobalKey<FormState> _messageformkey = GlobalKey<FormState>();
  TextEditingController _searchcon = new TextEditingController();
  TextEditingController _msearchcon = new TextEditingController();
  GlobalKey<FormState> _searchformkey = GlobalKey<FormState>();
  TextEditingController _wsearchcon = new TextEditingController();
  GlobalKey<FormState> _wsearchformkey = GlobalKey<FormState>();
  GlobalKey<FormState> _msearchformkey = GlobalKey<FormState>();
  ScrollController _mscrollController =
      ScrollController(keepScrollOffset: true);

  final ImagePicker _picker = ImagePicker();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  ScrollController _scrollController = ScrollController(keepScrollOffset: true);
  String _selectedid = "", _selectedusername = "", _selectedimg = "";
  PlayMode? playMode;
  var audioManagerInstance = AudioManager.instance;
  bool showVol = false;

  bool isPlaying = false;
  double _slider = 0;

  @override
  void dispose() {
    _animcon.dispose();
    advancedPlayer!.dispose();
    advancedPlayerOne!.dispose();
    // _iconanimcontroller.dispose();
    _messagecon.dispose();
    _searchcon.dispose();
    _msearchcon.dispose();
    _ucomcon.dispose();
    super.dispose();
  }

  PlayerState _playerState = PlayerState.STOPPED,
      _playerStateOne = PlayerState.STOPPED;
  bool isMediaPlaying = false, isMediaPlayingOne = false;
  bool? seekDone;
  bool get _isPlaying => _playerState == PlayerState.PLAYING;
  @override
  void initState() {
    getuserconfig();
    loaddir();

    advancedPlayer = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
    audioCache = AudioCache(fixedPlayer: advancedPlayer);
    advancedPlayer!.onPlayerError.listen((event) {
      print('audio player error : $event');
      setState(() {
        _playerState = PlayerState.STOPPED;
      });
    });
    advancedPlayer!.onDurationChanged.listen((Duration d) {
      print('Max duration: $d');
      setState(() => _duration = d);
    });
    advancedPlayer!.onAudioPositionChanged.listen((Duration p) {
      print('Current position: $p');
      setState(() => _position = p);
    });

    advancedPlayer!.onPlayerCompletion.listen((event) {
      setState(() {
        _position = _duration;
        _playerState = PlayerState.COMPLETED;
        isSelectedPlaying[uindex] = false;
        isMediaPlaying = false;
      });
    });
    advancedPlayerOne = AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);
    audioCacheOne = AudioCache(fixedPlayer: advancedPlayerOne);
    advancedPlayerOne!.onPlayerError.listen((event) {
      print('audio player error : $event');
      setState(() {
        _playerStateOne = PlayerState.STOPPED;
      });
    });
    advancedPlayerOne!.onDurationChanged.listen((Duration d) {
      print('Max duration: $d');
      setState(() => _durationone = d);
    });
    advancedPlayerOne!.onAudioPositionChanged.listen((Duration p) {
      print('Current position: $p');
      setState(() => _positionone = p);
    });

    advancedPlayerOne!.onPlayerCompletion.listen((event) {
      setState(() {
        _positionone = _durationone;
        _playerStateOne = PlayerState.COMPLETED;
        isMediaPlayingOne = false;
      });
    });
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
    super.initState();
    _animcon.forward();
    setupAudio();
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
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      if (_mscrollController.hasClients) {
        _mscrollController.animateTo(
            _mscrollController.position.maxScrollExtent,
            duration: Duration(seconds: 1),
            curve: Curves.easeInOut);
      }
    });
  }

  _playPause() async {
    if (_playerState == PlayerState.PLAYING) {
      setState(() {
        advancedPlayer!.pause();
        isMediaPlaying = false;
        _playerState = PlayerState.PAUSED;
        isSelectedPlaying[uindex] = true;
      });
    } else if (_playerState == PlayerState.PAUSED) {
      setState(() {
        advancedPlayer!.resume();
        isMediaPlaying = true;
        _playerState = PlayerState.PLAYING;
        isSelectedPlaying[uindex] = false;
      });
    } else if (_playerState == PlayerState.COMPLETED) {
      setState(() {
        advancedPlayer!.play(_appDirFolder!.path + _curaudio, isLocal: true);
        isMediaPlaying = true;
        _playerState = PlayerState.PLAYING;
        isSelectedPlaying[uindex] = false;
      });
    }
  }

  _playPauseFunc() async {
    if (_playerStateOne == PlayerState.PLAYING) {
      setState(() {
        advancedPlayerOne!.pause();
        isMediaPlayingOne = false;
        _playerStateOne = PlayerState.PAUSED;
      });
    } else if (_playerStateOne == PlayerState.PAUSED) {
      setState(() {
        advancedPlayerOne!.resume();
        isMediaPlayingOne = true;
        _playerStateOne = PlayerState.PLAYING;
      });
    } else if (_playerStateOne == PlayerState.COMPLETED) {
      setState(() {
        advancedPlayerOne!.play(_mediafilepath, isLocal: true);
        isMediaPlayingOne = true;
        _playerStateOne = PlayerState.PLAYING;
      });
    } else {
      setState(() {
        isMediaPlayingOne = true;
        advancedPlayerOne!.play(_mediafilepath, isLocal: true);
        isMediaPlayingOne = true;
        _playerStateOne = PlayerState.PLAYING;
      });
    }
  }

  seekToSecond(int second) {
    Duration newDuration = Duration(seconds: second);

    advancedPlayer!.seek(newDuration);
  }

  seekToSecondOne(int second) {
    Duration newDuration = Duration(seconds: second);

    advancedPlayerOne!.seek(newDuration);
  }

  void setupAudio() {
    audioManagerInstance.onEvents((events, args) {
      switch (events) {
        case AudioManagerEvents.start:
          _slider = 0;
          break;
        case AudioManagerEvents.seekComplete:
          _slider = audioManagerInstance.position.inMilliseconds /
              audioManagerInstance.duration.inMilliseconds;
          setState(() {});
          break;
        case AudioManagerEvents.playstatus:
          isPlaying = audioManagerInstance.isPlaying;
          setState(() {});
          break;
        case AudioManagerEvents.timeupdate:
          _slider = audioManagerInstance.position.inMilliseconds /
              audioManagerInstance.duration.inMilliseconds;
          audioManagerInstance.updateLrc(args["position"].toString());
          setState(() {});
          break;
        case AudioManagerEvents.ended:
          _slider = 0;
          audioManagerInstance.release();
          isSelectedPlaying[uindex] = false;
          audioManagerInstance.updateLrc(args["position"].toString());
          setState(() {});
          break;
        default:
          break;
      }
    });
  }

  String _formatDuration(Duration d) {
    if (d == null) return "--:--";
    int minute = d.inMinutes;
    int second = (d.inSeconds > 60) ? (d.inSeconds % 60) : d.inSeconds;
    String format = ((minute < 10) ? "0$minute" : "$minute") +
        ":" +
        ((second < 10) ? "0$second" : "$second");
    return format;
  }

  Widget songProgress(BuildContext context) {
    var style = TextStyle(color: Colors.black);
    return Row(
      children: <Widget>[
        Text(
          _formatDuration(audioManagerInstance.position),
          style: style,
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbColor: Colors.blueAccent,
                  overlayColor: Colors.blue,
                  thumbShape: RoundSliderThumbShape(
                    disabledThumbRadius: 5,
                    enabledThumbRadius: 5,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  activeTrackColor: Colors.blueAccent,
                  inactiveTrackColor: Colors.grey,
                ),
                child: Slider(
                    value: _position.inSeconds.toDouble(),
                    min: 0.0,
                    max: _duration.inSeconds.toDouble(),
                    onChanged: (double value) {
                      setState(() {
                        seekToSecond(value.toInt());
                        value = value;
                      });
                    })),
          ),
        ),
        Text(
          _formatDuration(audioManagerInstance.duration),
          style: style,
        ),
      ],
    );
  }

  Widget sliderProgress(BuildContext context) {
    var style = TextStyle(color: Colors.black);
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 5),
            child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 2,
                  thumbColor: Colors.blueAccent,
                  overlayColor: Colors.blue,
                  thumbShape: RoundSliderThumbShape(
                    disabledThumbRadius: 5,
                    enabledThumbRadius: 5,
                  ),
                  overlayShape: RoundSliderOverlayShape(
                    overlayRadius: 10,
                  ),
                  activeTrackColor: Colors.blueAccent,
                  inactiveTrackColor: Colors.grey,
                ),
                child: Slider(
                    value: _positionone.inSeconds.toDouble(),
                    min: 0.0,
                    max: _durationone.inSeconds.toDouble(),
                    onChanged: (double value) {
                      setState(() {
                        seekToSecondOne(value.toInt());
                        value = value;
                      });
                    })),
          ),
        ),
      ],
    );
  }

  Widget bottomPanel() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Color.fromRGBO(0, 0, 15, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.all(15),
            width: 55,
            height: 55,
            decoration: BoxDecoration(
                border:
                    Border.all(color: Color.fromRGBO(0, 0, 15, 1), width: 2),
                borderRadius: BorderRadius.circular(65),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: CachedNetworkImageProvider(
                      "http://www.emkapp.com/emkapp/imgdata/" + _uimg),
                )),
          ),
          Flexible(
            child: Column(children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 5, bottom: 5),
                child: Flexible(
                  child: Container(
                    height: 40,
                    child: Text(_uaudio,
                        maxLines: 1,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'serif',
                            overflow: TextOverflow.ellipsis)),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Transform(
                      transform: Matrix4.translationValues(-30, 0, 0),
                      child: Padding(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        child: songProgress(context),
                      ),
                    ),
                  ),
                  Transform(
                    transform: Matrix4.translationValues(-30, 0, 0),
                    child: CircleAvatar(
                      radius: 20,
                      child: Center(
                        child: IconButton(
                          onPressed: () async {
                            //audioManagerInstance.playOrPause();
                            _playPause();
                            setState(() {
                              isSelectedPlaying[uindex] =
                                  !isSelectedPlaying[uindex];
                            });
                          },
                          padding: const EdgeInsets.all(0.0),
                          icon: Icon(
                            isMediaPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    /*CircleAvatar(
                      child: Center(
                        child: IconButton(
                            icon: Icon(
                              Icons.fast_rewind,
                              color: Colors.white,
                            ),
                            onPressed: () => audioManagerInstance.previous()),
                      ),
                      backgroundColor: Colors.blueGrey.withOpacity(0.3),
                    ),*/

                    /*CircleAvatar(
                      backgroundColor: Colors.blueGrey.withOpacity(0.3),
                      child: Center(
                        child: IconButton(
                            icon: Icon(
                              Icons.fast_forward_sharp,
                              color: Colors.white,
                            ),
                            onPressed: () => audioManagerInstance.next()),
                      ),
                    ),*/
                  ],
                ),
              ),
            ]),
          ),
          Container(
            width: 50,
            child: Align(
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _slider = 0;
                    _playerState = PlayerState.COMPLETED;
                    advancedPlayer!.stop();
                    _playervisible = false;
                    isSelectedPlaying[uindex] = false;
                  });
                },
                child: Icon(
                  Icons.power_settings_new_rounded,
                  color: Colors.white,
                  size: 35,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget mPlayer() {
    return Container(
      width: MediaQuery.of(context).size.width,
      color: Color.fromRGBO(0, 0, 15, 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(left: 15, right: 15),
                    child: sliderProgress(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 25),
                    child: CircleAvatar(
                      radius: 30,
                      child: Center(
                        child: IconButton(
                          onPressed: () async {
                            //audioManagerInstance.playOrPause();
                            _playPauseFunc();
                          },
                          padding: const EdgeInsets.all(0.0),
                          icon: Icon(
                            isMediaPlayingOne ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
          ),
        ],
      ),
    );
  }

  loaddir() async {
    String _foldername = "EmkappData";
    _appDir = await getApplicationDocumentsDirectory();
    _appDirFolder = Directory('${_appDir!.path}/$_foldername/');
    var files = _appDirFolder!.listSync();
    String dfiles = "";
    for (final i in files) {
      if (i.toString().contains(".png")) {
        dfiles += i.toString();
      }
    }
    var ffiles = files.where((i) => i.toString().contains(".png")).toList();
    print("all files : " + ffiles.toString());
    //_showsnackbar("all files : " + dfiles.toString(), "Okay");
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
      print("User ID : " + uid);
      await _getusermessages(uid);
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

      Future.delayed(Duration(seconds: 0), () {
        if (gfile != null) {
          cropimage();
        }
      });
    }
  }

  cameravideo() async {
    // ignore: deprecated_member_use
    XFile? gfile = await _picker.pickVideo(source: ImageSource.camera);
    if (gfile != null) {
      galleryfile = File(gfile.path);
    }
    if (galleryfile != null) {
      if (galleryfile!.lengthSync() > 60000000) {
        _showsnackbar("File size cannot be greater than 60MB", "Close");
      } else {
        final bytes = Io.File(galleryfile!.path).readAsBytesSync();
        _imgfile = galleryfile.toString().split('/').last.split('r').last;
        base64image = base64Encode(bytes);
        _finalfile = _imgfile.substring(0, _imgfile.indexOf('\''));
        setState(() {
          _mediafilepath = galleryfile!.path;
          _mediatype = "video";
        });
        Directory? tempdir = await getApplicationDocumentsDirectory();
        String _foldername = "EmkappData";
        String tempPath = '${tempdir!.path}/$_foldername/';
        List<int> bytesone = await File(galleryfile!.path).readAsBytes();
        var filename = Fp.basename(File(galleryfile!.path).path).toString();
        var filepath = tempPath + '$filename';

        await File(filepath).writeAsBytes(bytesone);
        var genfile = await genThumbnail(filepath);
        setState(() {
          _uploadcommentvisible = true;
          _mediaWidget(_mediatype);
        });
      }
    }
  }

  generateThumbnail() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final uint8list = await VideoThumbnail.thumbnailData(
      video: _mediafilepath,
      imageFormat: ImageFormat.JPEG,
      maxWidth:
          128, // specify the width of the thumbnail, let the height auto-scaled to keep the source aspect ratio
      quality: 85,
    );
    setState(() {});
    return uint8list;
    //return Image.memory(uint8list!);
  }

  genThumbnail(String fpath) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();
    final filename = await VideoThumbnail.thumbnailData(
        video: fpath,
        imageFormat: ImageFormat.PNG,
        maxWidth: 0,
        quality: 75,
        timeMs: 5000);
    setState(() {
      imgbytes = filename;
    });
    var nfilename = Fp.basename(File(fpath).path).toString();

    var pos = nfilename.lastIndexOf(".");
    String thumbnailname =
        (pos != -1) ? nfilename.substring(0, pos) : nfilename;

    final file =
        await new File('${_appDirFolder!.path}$thumbnailname.png').create();
    file.writeAsBytesSync(filename!);
    //return Image.memory(filename);
  }

  galleryvideo() async {
    // ignore: deprecated_member_use
    XFile? gfile = await _picker.pickVideo(source: ImageSource.gallery);
    if (gfile != null) {
      galleryfile = File(gfile.path);
    }
    if (galleryfile != null) {
      if (galleryfile!.lengthSync() > 60000000) {
        _showsnackbar("File size cannot be greater than 60MB", "Close");
      } else {
        final bytes = Io.File(galleryfile!.path).readAsBytesSync();
        _imgfile = galleryfile.toString().split('/').last.split('r').last;
        base64image = base64Encode(bytes);
        _finalfile = _imgfile.substring(0, _imgfile.indexOf('\''));
        setState(() {
          _mediafilepath = galleryfile!.path;
          _mediatype = "video";
        });
        Directory? tempdir = await getApplicationDocumentsDirectory();
        String _foldername = "EmkappData";
        String tempPath = '${tempdir!.path}/$_foldername/';
        List<int> bytesone = await File(galleryfile!.path).readAsBytes();
        var filename = Fp.basename(File(galleryfile!.path).path).toString();
        var filepath = tempPath + '$filename';

        //var ext = genfile. .split(".").last;
        await File(filepath).writeAsBytes(bytesone);
        var genfile = await genThumbnail(filepath);
        setState(() {
          _uploadcommentvisible = true;
          _mediaWidget(_mediatype);
        });
      }
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
        _mediafilepath = galleryfile!.path;
        _mediatype = "picture";
      });
      Directory? tempdir = await getApplicationDocumentsDirectory();
      String _foldername = "EmkappData";
      String tempPath = '${tempdir!.path}/$_foldername/';
      List<int> bytes = await File(galleryfile!.path).readAsBytes();
      var filename = Fp.basename(File(galleryfile!.path).path).toString();
      var filepath = tempPath + '/$filename';
      File(filepath).writeAsBytes(bytes);
      setState(() {
        _uploadcommentvisible = true;
      });
    }
  }

  Stream<int> stopWatchStream() {
    StreamController<int>? streamController;
    Timer? timer;
    Duration timerInterval = Duration(seconds: 1);
    int counter = 0;

    void stopTimer() {
      if (timer != null) {
        timer!.cancel();
        timer = null;
        counter = 0;
        streamController!.close();
      }
    }

    void pauseTimer() {
      if (timer != null) {
        timer!.cancel();
      }
    }

    void tick(_) {
      counter++;
      streamController!.add(counter);
      if (!flag) {
        stopTimer();
      }
      if (int.parse(minsStr) > 59) {
        stopTimer();
        _showsnackbar("Time limit exceeded", "Close");
        RecordMp3.instance.pause();
      }
    }

    void startTimer() {
      timer = Timer.periodic(timerInterval, tick);
    }

    streamController = StreamController<int>(
        onListen: startTimer,
        onCancel: stopTimer,
        onResume: startTimer,
        onPause: pauseTimer);

    return streamController.stream;
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

  Future<List<AllMessageWorkers>>? _mfuture;
  Future<List<AllMessageWorkers>> fetchmessagewithworkers() async {
    return serverresponse
        .map((e) => new AllMessageWorkers.fromJson(e))
        .toList();
  }

  Future<List<AllMessageWorkers>> searchmessagewithworkers() async {
    return searchserverresponse
        .map((e) => new AllMessageWorkers.fromJson(e))
        .toList();
  }

  Future<List<OpenSelectedChat>> fetchselectedchat() async {
    return messagesresponse
        .map((e) => new OpenSelectedChat.fromJson(e))
        .toList();
  }

  Future<List<OpenSelectedChat>> searchselectedchat() async {
    return searchmessagesresponse
        .map((e) => new OpenSelectedChat.fromJson(e))
        .toList();
  }

  Future<List<AllChatWorkers>> fetchchatworkers() async {
    return workersresponse.map((e) => new AllChatWorkers.fromJson(e)).toList();
  }

  Future<List<AllChatWorkers>> searchchatworkers() async {
    return searchworkersresponse
        .map((e) => new AllChatWorkers.fromJson(e))
        .toList();
  }

  _getworkers(String sid) async {
    var url = 'http://www.emkapp.com/emkapp/api/messages.php';
    var bdata = {"getworkers": "", "uid": sid};
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
      if (jsonDecode(response.data).toString().contains("no records found")) {
        setState(() {
          _diagvisibility = false;
          _allWorkersWidget();
          _allworkersvisible = false;
        });
        _showsnackbar("No worker data available", "Close");
      } else {
        setState(() {
          workersresponse = json.decode(response.data);
          secondworkersresponse = json.decode(response.data);
          _diagvisibility = false;
          _cwfuture = fetchchatworkers();
          _allWorkersWidget();
          _allworkersvisible = true;
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

  _getusermessages(uid) async {
    var url = 'http://www.emkapp.com/emkapp/api/messages.php';
    var bdata = {"getmessages": "", "uid": uid};
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
      if (jsonDecode(response.data).toString().contains("no records found")) {
        setState(() {
          _diagvisibility = false;
          _allMessagesWidget();
        });
      } else {
        setState(() {
          serverresponse = json.decode(response.data);
          secondserverresponse = json.decode(response.data);
          _diagvisibility = false;
          _wfuture = fetchmessagewithworkers();
          _allMessagesWidget();
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

  int daysBetween(DateTime from, DateTime to) {
    from = DateTime(from.year, from.month, from.day);
    to = DateTime(to.year, to.month, to.day);
    return (to.difference(from).inHours / 24).round();
  }

  _updateselectedchat(String sid, String sname, String simg) async {
    var url = "http://www.emkapp.com/emkapp/api/messages.php";
    var sbdata = {"updateread": "true", "receipient": uid, "sender": sid};
    FormData sfdata = FormData.fromMap(sbdata);
    BaseOptions options = new BaseOptions(
      baseUrl: "http://www.emkapp.com/emkapp",
      connectTimeout: 15000,
      receiveTimeout: 3000,
    );

    Dio dio = new Dio(options);
    try {
      var sresponse = await dio.post(url, data: sfdata);

      print(sresponse.data);

      if (jsonDecode(sresponse.data).toString().contains("successful")) {
        print("Success");
      } else {
        _showsnackbar(
            "Error : " + jsonDecode(sresponse.data).toString(), "Close");
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

  _fetchselectedchat(String sid, String sname, String simg) async {
    _updateselectedchat(sid, sname, simg);
    setState(() {
      _submessagesvisible = true;
      _headmenuvisible = false;
      _diagvisibility = true;
      isPictureDownloaded = [];
      isAudioDownloaded = [];
      isDocumentDownloaded = [];
      isVideoDownloaded = [];
      messagesresponse = [];
      _future = fetchselectedchat();
    });
    var url = "http://www.emkapp.com/emkapp/api/messages.php";
    var bdata = {"getchats": "true", "receipient": sid, "sender": uid};
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

      if (jsonDecode(response.data).toString().contains("no records found")) {
        setState(() {
          _diagvisibility = false;
        });
      } else {
        setState(() {
          messagesresponse = json.decode(response.data);
          secondmessagesresponse = json.decode(response.data);
          _diagvisibility = false;
          _selectedChatWidget();
          filteredaudio = messagesresponse
              .where((el) => el["messagetype"] == "audio")
              .toList();
          filteredimage = messagesresponse
              .where((el) => el["messagetype"] == "picture")
              .toList();
          filtereddocument = messagesresponse
              .where((el) => el["messagetype"] == "document")
              .toList();
          isPictureDownloaded =
              List<bool>.generate(messagesresponse.length, (index) => false);
          isAudioDownloaded =
              List<bool>.generate(messagesresponse.length, (index) => false);
          isDocumentDownloaded =
              List<bool>.generate(messagesresponse.length, (index) => false);
          isVideoDownloaded =
              List<bool>.generate(messagesresponse.length, (index) => false);
          isSelectedPlaying =
              List<bool>.generate(messagesresponse.length, (index) => false);
          _future = fetchselectedchat();

          if (_mscrollController.hasClients) {
            _mscrollController.animateTo(
                _mscrollController.position.maxScrollExtent,
                duration: Duration(seconds: 1),
                curve: Curves.easeInOut);
          }
        });
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

  _scrolltobottom() {
    setState(() {
      _mscrollController.animateTo(_mscrollController.position.maxScrollExtent,
          duration: Duration(seconds: 1), curve: Curves.linear);
    });
  }

  double scrollpixels = 0;

  _fetchimage(
      bool pictureDownloaded, String message, int index, double pixels) async {
    setState(() {
      isPictureDownloaded[index] = !pictureDownloaded;
      scrollpixels = pixels;
    });
    var url = 'http://www.emkapp.com/emkapp/chat_media/pics/' + message;
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
    var filepath = _appDirFolder!.path + message;
    print(filepath);
    try {
      var response = await dio.get(url);

      File dfile = File(filepath);
      var rawfile = dfile.openSync(mode: FileMode.write);
      rawfile.writeFromSync(response.data);
      await rawfile.close();
      setState(() {
        isPictureDownloaded[index] = !pictureDownloaded;
        _selectedChatWidget();
      });
    } catch (ex) {
      _showsnackbar("Error : " + ex.toString(), "Close");
      setState(() {
        isPictureDownloaded[index] = !pictureDownloaded;
      });
    }
  }

  _fetchvideo(
      bool videoDownloaded, String message, int index, double pixels) async {
    setState(() {
      isVideoDownloaded[index] = !videoDownloaded;
      scrollpixels = pixels;
    });
    var url = 'http://www.emkapp.com/emkapp/chat_media/video/' + message;
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
    var filepath = _appDirFolder!.path + message;
    print(filepath);
    try {
      var response = await dio.get(url);

      File dfile = File(filepath);
      var rawfile = dfile.openSync(mode: FileMode.write);
      rawfile.writeFromSync(response.data);
      await rawfile.close();

      var genfile = await genThumbnail(filepath);
      setState(() {
        isVideoDownloaded[index] = !videoDownloaded;
        _selectedChatWidget();
      });
    } catch (ex) {
      _showsnackbar("Error : " + ex.toString(), "Close");
      setState(() {
        isVideoDownloaded[index] = !videoDownloaded;
      });
    }
  }

  _fetchaudio(
      bool audioDownloaded, String message, int index, double pixels) async {
    setState(() {
      isAudioDownloaded[index] = !audioDownloaded;
      scrollpixels = pixels;
    });
    var url = 'http://www.emkapp.com/emkapp/chat_media/audio/' + message;
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
    var filepath = _appDirFolder!.path + message;
    print(filepath);
    try {
      var response = await dio.get(url);

      File dfile = File(filepath);
      var rawfile = dfile.openSync(mode: FileMode.write);
      rawfile.writeFromSync(response.data);
      await rawfile.close();
      setState(() {
        isAudioDownloaded[index] = !audioDownloaded;
        _selectedChatWidget();
      });
    } catch (ex) {
      _showsnackbar("Error : " + ex.toString(), "Close");
      setState(() {
        isAudioDownloaded[index] = !audioDownloaded;
      });
    }
  }

  _scrolltocurrentposition() {
    if (scrollpixels < 1) {
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        if (_mscrollController.hasClients) {
          _mscrollController.animateTo(
              _mscrollController.position.maxScrollExtent,
              duration: Duration(seconds: 1),
              curve: Curves.easeInOut);
        }
      });
    } else {
      SchedulerBinding.instance!.addPostFrameCallback((_) {
        if (_mscrollController.hasClients) {
          _mscrollController.animateTo(scrollpixels,
              duration: Duration(seconds: 1), curve: Curves.easeInOut);
        }
      });
    }
  }

  _fetchdocument(
      bool documentDownloaded, String message, int index, double pixels) async {
    setState(() {
      isDocumentDownloaded[index] = !documentDownloaded;
      scrollpixels = pixels;
    });
    var url = 'http://www.emkapp.com/emkapp/chat_media/documents/' + message;
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
    var filepath = _appDirFolder!.path + message;
    print(filepath);
    try {
      var response = await dio.get(url);

      File dfile = File(filepath);
      var rawfile = dfile.openSync(mode: FileMode.write);
      rawfile.writeFromSync(response.data);
      await rawfile.close();
      setState(() {
        isDocumentDownloaded[index] = !documentDownloaded;
        _selectedChatWidget();
      });
    } catch (ex) {
      _showsnackbar("Error : " + ex.toString(), "Close");
      setState(() {
        isDocumentDownloaded[index] = !documentDownloaded;
      });
    }
  }

  Widget _selectedChatWidget() {
    var datawidget;

    if (messagesresponse.isEmpty) {
      datawidget = Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black.withOpacity(.9),
        child: Align(
          alignment: Alignment.center,
          child: Text("Start a new conversation",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Color.fromRGBO(255, 255, 255, 1),
              )),
        ),
      );
    } else {
      datawidget = SingleChildScrollView(
          physics: ScrollPhysics(),
          controller: _mscrollController,
          child: Column(
            children: [
              FutureBuilder<List<OpenSelectedChat>>(
                  future: _future,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<OpenSelectedChat>> snapshot) {
                    //print("list items : " + carresponse.toString());
                    Widget newsListSliver;
                    if (snapshot.hasData) {
                      newsListSliver = ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            OpenSelectedChat item = snapshot.data![index];
                            if (index + 1 == snapshot.data!.length) {
                              _scrolltocurrentposition();
                            }
                            //isChecked = List<bool>.generate(roledata.length, (index) => false);
                            var _formatter = NumberFormat.compactCurrency(
                                decimalDigits: 2, symbol: '');
                            String fdate = "";
                            DateTime curdate = DateTime.now();
                            var formattedcurrentdate =
                                DateFormat('yyyy-MM-dd hh:mm:ss')
                                    .format(curdate);
                            DateTime todate =
                                new DateFormat('yyyy-MM-dd hh:mm:ss')
                                    .parse(formattedcurrentdate);
                            DateTime fromdate =
                                new DateFormat('yyyy-MM-dd hh:mm:ss')
                                    .parse(item.mtime);

                            var result = daysBetween(fromdate, todate);
                            if (result < 1 && fromdate.day == todate.day) {
                              fdate = DateFormat('hh:mm a').format(
                                  DateFormat('yyyy-MM-dd hh:mm:ss')
                                      .parse(item.mtime));
                            } else if ((result < 1 &&
                                    fromdate.day != todate.day) ||
                                (result > 0 && result < 2)) {
                              fdate = "Yesterday";
                            } else if (result > 1 && result < 8) {
                              fdate = DateFormat('EEEE').format(
                                  DateFormat('yyyy-MM-dd hh:mm:ss')
                                      .parse(item.mtime));
                            } else {
                              fdate = DateFormat('dd/MM/yyyy').format(
                                  DateFormat('yyyy-MM-dd hh:mm:ss')
                                      .parse(item.mtime));
                            }

                            print(formattedcurrentdate +
                                " - " +
                                todate.day.toString() +
                                " : " +
                                fromdate.day.toString() +
                                "\n\n" +
                                fdate.toString());
                            String msgcount = "";

                            var curWidget;
                            if (item.messagetype == "txtmsg") {
                              if (item.sender != uid) {
                                curWidget = Align(
                                  alignment: Alignment.topLeft,
                                  child: IntrinsicWidth(
                                    child: Container(
                                      padding: EdgeInsets.all(10.0),
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.75),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Color.fromRGBO(0, 0, 13, 1)),
                                      child: Column(
                                        children: <Widget>[
                                          Text(
                                            item.message,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16),
                                          ),
                                          Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                fdate,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(.6),
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 11),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                curWidget = Align(
                                  alignment: Alignment.topRight,
                                  child: IntrinsicWidth(
                                    child: Container(
                                      constraints: BoxConstraints(
                                          maxWidth: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.75),
                                      padding: EdgeInsets.all(10.0),
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Color.fromRGBO(0, 0, 13, 1)),
                                      child: Column(
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                bottom: 5),
                                            child: Text(
                                              item.message,
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16),
                                            ),
                                          ),
                                          Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                fdate,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(.6),
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 11),
                                              )),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }

                            if (item.messagetype == "picture") {
                              var picwidget;

                              if (File(_appDirFolder!.path + "/" + item.message)
                                  .existsSync()) {
                                picwidget = GestureDetector(
                                  onTap: () {
                                    OpenFile.open(
                                        _appDirFolder!.path + item.message);
                                  },
                                  child: Container(
                                      width: double.infinity,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.30,
                                      decoration: BoxDecoration(
                                          border: Border.all(
                                              color:
                                                  Color.fromRGBO(0, 0, 13, 1),
                                              width: 3),
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: FileImage(File(
                                                _appDirFolder!.path +
                                                    item.message)),
                                          ))),
                                );
                              } else {
                                picwidget = Container(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.30,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color.fromRGBO(
                                                    73, 73, 73, 1),
                                                width: 3),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: ExactAssetImage(
                                                  'assets/images/nature_0095.jpg'),
                                            )),
                                      ),
                                      ClipRect(
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 15.0, sigmaY: 15.0),
                                            child: Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              decoration: new BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _fetchimage(
                                              isPictureDownloaded[index],
                                              item.message,
                                              index,
                                              _mscrollController
                                                  .position.pixels);
                                        },
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                              width: 65,
                                              height: 65,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(65)),
                                                  color: Color.fromRGBO(
                                                      0, 0, 15, 1)),
                                              child: Icon(
                                                Icons.file_download,
                                                size: 40,
                                                color: Colors.white,
                                              )),
                                        ),
                                      ),
                                      Visibility(
                                        visible: isPictureDownloaded[index],
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            width: 65,
                                            height: 65,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(65)),
                                                color: Color.fromRGBO(
                                                    0, 0, 15, 1)),
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Colors.white),
                                              strokeWidth: 5,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                              if (item.sender != uid) {
                                curWidget = Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    padding: EdgeInsets.all(10.0),
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Color.fromRGBO(0, 0, 13, 1)),
                                    child: Column(
                                      children: [
                                        picwidget,
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                item.submessage,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(1),
                                                    fontFamily: 'serif',
                                                    fontSize: 14),
                                              ),
                                            )),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                fdate,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(.6),
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 11),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                curWidget = Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    padding: EdgeInsets.all(10.0),
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Color.fromRGBO(0, 0, 13, 1)),
                                    child: Column(
                                      children: [
                                        picwidget,
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                item.submessage,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(1),
                                                    fontFamily: 'serif',
                                                    fontSize: 14),
                                              ),
                                            )),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                fdate,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(.6),
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 11),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }
                            if (item.messagetype == "video") {
                              var picwidget;

                              if (File(_appDirFolder!.path + "/" + item.message)
                                  .existsSync()) {
                                var pos = item.message.lastIndexOf(".");
                                String thumbnail = (pos != -1)
                                    ? item.message.substring(0, pos)
                                    : item.message;

                                picwidget = GestureDetector(
                                  onTap: () {
                                    OpenFile.open(
                                        _appDirFolder!.path + item.message);
                                  },
                                  child: Stack(
                                    children: [
                                      Container(
                                          width: double.infinity,
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.30,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color.fromRGBO(
                                                      0, 0, 13, 1),
                                                  width: 3),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: FileImage(File(
                                                    _appDirFolder!.path +
                                                        thumbnail +
                                                        ".png")),
                                              ))),
                                      Container(
                                        width: double.infinity,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.30,
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                              width: 65,
                                              height: 65,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(65)),
                                                  color: Color.fromRGBO(
                                                      0, 0, 15, 1)),
                                              child: Icon(
                                                Icons.play_circle,
                                                size: 65,
                                                color: Colors.white,
                                              )),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                picwidget = Container(
                                  width: double.infinity,
                                  height:
                                      MediaQuery.of(context).size.height * 0.30,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Color.fromRGBO(
                                                    73, 73, 73, 1),
                                                width: 3),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            image: DecorationImage(
                                              fit: BoxFit.fill,
                                              image: ExactAssetImage(
                                                  'assets/images/nature_0095.jpg'),
                                            )),
                                      ),
                                      ClipRect(
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          child: BackdropFilter(
                                            filter: ImageFilter.blur(
                                                sigmaX: 15.0, sigmaY: 15.0),
                                            child: Container(
                                              width: double.infinity,
                                              height: double.infinity,
                                              decoration: new BoxDecoration(
                                                color: Colors.black
                                                    .withOpacity(0.4),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          _fetchvideo(
                                              isVideoDownloaded[index],
                                              item.message,
                                              index,
                                              _mscrollController
                                                  .position.pixels);
                                        },
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Container(
                                              padding: EdgeInsets.only(
                                                  left: 5, right: 11),
                                              height: 65,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(65)),
                                                  color: Color.fromRGBO(
                                                      0, 0, 15, 1)),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.file_download,
                                                    size: 40,
                                                    color: Colors.white,
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          right: 5)),
                                                  Text(
                                                    item.fsize,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 18),
                                                  )
                                                ],
                                              )),
                                        ),
                                      ),
                                      Visibility(
                                        visible: isVideoDownloaded[index],
                                        child: Container(
                                          width: double.infinity,
                                          height: double.infinity,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color.fromRGBO(
                                                      73, 73, 73, 1),
                                                  width: 3),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              image: DecorationImage(
                                                fit: BoxFit.fill,
                                                image: ExactAssetImage(
                                                    'assets/images/nature_0095.jpg'),
                                              )),
                                          child: Align(
                                            alignment: Alignment.center,
                                            child: Container(
                                              padding: EdgeInsets.all(4),
                                              width: 65,
                                              height: 65,
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(65)),
                                                  color: Color.fromRGBO(
                                                      0, 0, 15, 1)),
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                        Colors.white),
                                                strokeWidth: 5,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              }
                              if (item.sender != uid) {
                                curWidget = Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    padding: EdgeInsets.all(10.0),
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Color.fromRGBO(0, 0, 13, 1)),
                                    child: Column(
                                      children: [
                                        picwidget,
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                item.submessage,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(1),
                                                    fontFamily: 'serif',
                                                    fontSize: 14),
                                              ),
                                            )),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                fdate,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(.6),
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 11),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else {
                                curWidget = Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    padding: EdgeInsets.all(10.0),
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Color.fromRGBO(0, 0, 13, 1)),
                                    child: Column(
                                      children: [
                                        picwidget,
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                item.submessage,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(1),
                                                    fontFamily: 'serif',
                                                    fontSize: 14),
                                              ),
                                            )),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                fdate,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(.6),
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 11),
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              }
                            }
                            if (item.messagetype == "audio") {
                              var audiowidget;

                              if (File(_appDirFolder!.path + "/" + item.message)
                                  .existsSync()) {
                                String upic = "";
                                if (item.sender != uid) {
                                  upic = _selectedimg;
                                } else {
                                  upic = _imgname;
                                }
                                audiowidget = Container(
                                    child: Row(children: [
                                  GestureDetector(
                                    onTap: () {
                                      if (item.sender != uid) {
                                        _uimg = _selectedimg;
                                      } else {
                                        _uimg = _imgname;
                                      }
                                      openPlayer(
                                          index,
                                          item.message,
                                          isSelectedPlaying[index],
                                          _mscrollController.position.pixels);
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 65,
                                          height: 65,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color.fromRGBO(
                                                      0, 0, 15, 1),
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(65),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: CachedNetworkImageProvider(
                                                    "http://www.emkapp.com/emkapp/imgdata/" +
                                                        upic),
                                              )),
                                        ),
                                        Container(
                                            alignment: Alignment.center,
                                            width: 65,
                                            height: 65,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(.5),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(65)),
                                            ),
                                            child: Icon(
                                              isSelectedPlaying[index]
                                                  ? Icons
                                                      .pause_circle_filled_rounded
                                                  : Icons
                                                      .play_circle_fill_rounded,
                                              size: 45,
                                              color:
                                                  Colors.white.withOpacity(.7),
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(right: 5)),
                                  Flexible(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.message,
                                          maxLines: 1,
                                          style: TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              color: Colors.white,
                                              fontFamily: 'serif',
                                              fontSize: 15),
                                        ),
                                      ],
                                    ),
                                  )
                                ]));
                              } else {
                                String upic = "";
                                if (item.sender != uid) {
                                  upic = _selectedimg;
                                } else {
                                  upic = _imgname;
                                }
                                audiowidget = Container(
                                    child: Row(children: [
                                  GestureDetector(
                                    onTap: () {
                                      _fetchaudio(
                                          isAudioDownloaded[index],
                                          item.message,
                                          index,
                                          _mscrollController.position.pixels);
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 65,
                                          height: 65,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Color.fromRGBO(
                                                      0, 0, 15, 1),
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(65),
                                              image: DecorationImage(
                                                fit: BoxFit.cover,
                                                image: CachedNetworkImageProvider(
                                                    "http://www.emkapp.com/emkapp/imgdata/" +
                                                        upic),
                                              )),
                                        ),
                                        Container(
                                            alignment: Alignment.center,
                                            width: 65,
                                            height: 65,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(.5),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(65)),
                                            ),
                                            child: Icon(
                                              Icons
                                                  .download_for_offline_rounded,
                                              size: 45,
                                              color:
                                                  Colors.white.withOpacity(.7),
                                            )),
                                        Visibility(
                                          visible: isAudioDownloaded[index],
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            width: 65,
                                            height: 65,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(65)),
                                                color: Color.fromRGBO(
                                                    0, 0, 15, 1)),
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Colors.white),
                                              strokeWidth: 5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(right: 5)),
                                  Flexible(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.message,
                                          maxLines: 1,
                                          style: TextStyle(
                                              overflow: TextOverflow.ellipsis,
                                              color: Colors.white,
                                              fontFamily: 'serif',
                                              fontSize: 15),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 4, bottom: 4),
                                          child: Divider(
                                            height: 1,
                                            color: Colors.white.withOpacity(.1),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            item.fsize,
                                            textAlign: TextAlign.justify,
                                            maxLines: 1,
                                            style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                color: Colors.blue,
                                                fontFamily: 'serif',
                                                fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ]));
                              }

                              if (item.sender != uid) {
                                curWidget = Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                      padding: EdgeInsets.all(5.0),
                                      width: MediaQuery.of(context).size.width *
                                          0.75,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10)),
                                          color: Color.fromRGBO(0, 0, 13, 1)),
                                      child: Flexible(
                                        child: Column(children: [
                                          audiowidget,
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                top: 4, bottom: 4),
                                            child: Divider(
                                              height: 1,
                                              color:
                                                  Colors.white.withOpacity(.4),
                                            ),
                                          ),
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 5.0),
                                              child: Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(
                                                  item.submessage,
                                                  style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(1),
                                                      fontFamily: 'serif',
                                                      fontSize: 14),
                                                ),
                                              )),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                child: Text(
                                                  fdate,
                                                  style: TextStyle(
                                                      color: Colors.white
                                                          .withOpacity(.6),
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 11),
                                                )),
                                          ),
                                        ]),
                                      )),
                                );
                              } else {
                                curWidget = Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    padding: EdgeInsets.all(5.0),
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Color.fromRGBO(0, 0, 13, 1)),
                                    child: Flexible(
                                      child: Column(children: [
                                        audiowidget,
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 4, bottom: 4),
                                          child: Divider(
                                            height: 1,
                                            color: Colors.white.withOpacity(.4),
                                          ),
                                        ),
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                item.submessage,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(1),
                                                    fontFamily: 'serif',
                                                    fontSize: 14),
                                              ),
                                            )),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                fdate,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(.6),
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 11),
                                              )),
                                        ),
                                      ]),
                                    ),
                                  ),
                                );
                              }
                            }
                            if (item.messagetype == "document") {
                              var docwidget;
                              var fIcon;
                              var fextension = item.message.split(".").last;
                              if (fextension == "ppt" || fextension == "pptx") {
                                fIcon = "pptx.png";
                              }
                              if (fextension == "xls" || fextension == "xlsx") {
                                fIcon = "xlsx.png";
                              }
                              if (fextension == "doc" || fextension == "docx") {
                                fIcon = "docx.png";
                              }
                              if (fextension == "pdf") {
                                fIcon = "pdfx.png";
                              }
                              if (File(_appDirFolder!.path + "/" + item.message)
                                  .existsSync()) {
                                docwidget = Container(
                                    child: Row(children: [
                                  GestureDetector(
                                    onTap: () async {
                                      final _oresult = await OpenFile.open(
                                          _appDirFolder!.path + item.message);
                                      if (!_oresult.message.contains("done")) {
                                        _showsnackbar(_oresult.message, "Okay");
                                      }
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 65,
                                          height: 65,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade900,
                                            border: Border.all(
                                                color: Colors.grey.shade900,
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(65),
                                          ),
                                        ),
                                        Container(
                                            alignment: Alignment.center,
                                            width: 65,
                                            height: 65,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(.5),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(65)),
                                            ),
                                            child: Image.asset(
                                              'assets/images/' + fIcon,
                                              height: 35,
                                              width: 35,
                                            )),
                                      ],
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(right: 5)),
                                  Flexible(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            item.message,
                                            maxLines: 1,
                                            style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                color: Colors.white,
                                                fontFamily: 'serif',
                                                fontSize: 15),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ]));
                              } else {
                                docwidget = Container(
                                    child: Row(children: [
                                  GestureDetector(
                                    onTap: () {
                                      _fetchdocument(
                                          isDocumentDownloaded[index],
                                          item.message,
                                          index,
                                          _mscrollController.position.pixels);
                                    },
                                    child: Stack(
                                      children: [
                                        Container(
                                          width: 65,
                                          height: 65,
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade900,
                                            border: Border.all(
                                                color:
                                                    Color.fromRGBO(0, 0, 15, 1),
                                                width: 2),
                                            borderRadius:
                                                BorderRadius.circular(65),
                                          ),
                                        ),
                                        Container(
                                            alignment: Alignment.center,
                                            width: 65,
                                            height: 65,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(.0),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(65)),
                                            ),
                                            child: Image.asset(
                                              'assets/images/' + fIcon,
                                              height: 35,
                                              width: 35,
                                            )),
                                        Container(
                                            alignment: Alignment.bottomCenter,
                                            width: 65,
                                            height: 65,
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.0),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(65)),
                                            ),
                                            child: Icon(
                                              Icons
                                                  .download_for_offline_rounded,
                                              size: 20,
                                              color:
                                                  Colors.white.withOpacity(.7),
                                            )),
                                        Visibility(
                                          visible: isDocumentDownloaded[index],
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            width: 65,
                                            height: 65,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(65)),
                                                color: Color.fromRGBO(
                                                    0, 0, 15, 1)),
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation(
                                                      Colors.white),
                                              strokeWidth: 5,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(padding: EdgeInsets.only(right: 5)),
                                  Flexible(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            item.message,
                                            maxLines: 1,
                                            style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                color: Colors.white,
                                                fontFamily: 'serif',
                                                fontSize: 15),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 4, bottom: 4),
                                          child: Divider(
                                            height: 1,
                                            color: Colors.white.withOpacity(.1),
                                          ),
                                        ),
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            item.fsize,
                                            textAlign: TextAlign.justify,
                                            maxLines: 1,
                                            style: TextStyle(
                                                overflow: TextOverflow.ellipsis,
                                                color: Colors.blue,
                                                fontFamily: 'serif',
                                                fontSize: 13),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                ]));
                              }
                              if (item.sender != uid) {
                                curWidget = Align(
                                  alignment: Alignment.topLeft,
                                  child: Container(
                                    padding: EdgeInsets.all(5.0),
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Color.fromRGBO(0, 0, 13, 1)),
                                    child: Flexible(
                                      child: Column(children: [
                                        docwidget,
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 4, bottom: 4),
                                          child: Divider(
                                            height: 1,
                                            color: Colors.white.withOpacity(.4),
                                          ),
                                        ),
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                item.submessage,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(1),
                                                    fontFamily: 'serif',
                                                    fontSize: 14),
                                              ),
                                            )),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                fdate,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(.6),
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 11),
                                              )),
                                        ),
                                      ]),
                                    ),
                                  ),
                                );
                              } else {
                                curWidget = Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    padding: EdgeInsets.all(5.0),
                                    width: MediaQuery.of(context).size.width *
                                        0.75,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(10)),
                                        color: Color.fromRGBO(0, 0, 13, 1)),
                                    child: Flexible(
                                      child: Column(children: [
                                        docwidget,
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 4, bottom: 4),
                                          child: Divider(
                                            height: 1,
                                            color: Colors.white.withOpacity(.4),
                                          ),
                                        ),
                                        Padding(
                                            padding:
                                                const EdgeInsets.only(top: 5.0),
                                            child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                item.submessage,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(1),
                                                    fontFamily: 'serif',
                                                    fontSize: 14),
                                              ),
                                            )),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 5.0),
                                          child: Align(
                                              alignment: Alignment.bottomRight,
                                              child: Text(
                                                fdate,
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withOpacity(.6),
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 11),
                                              )),
                                        ),
                                      ]),
                                    ),
                                  ),
                                );
                              }
                            }
                            return Padding(
                              padding: EdgeInsets.only(top: 5),
                              child: curWidget,
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

  Widget _allMessagesWidget() {
    var datawidget;
    if (serverresponse.isEmpty) {
      datawidget = Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.black.withOpacity(.9),
        child: Align(
          alignment: Alignment.center,
          child: Text("Start a new conversation",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: Color.fromRGBO(255, 255, 255, 1),
              )),
        ),
      );
    } else {
      datawidget = Column(
        children: [
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
            width: MediaQuery.of(context).size.width,
            color: Color.fromRGBO(0, 0, 12, 1),
            child: Form(
              key: _msearchformkey,
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
                            controller: _msearchcon,
                            readOnly: false,
                            maxLines: 1,
                            decoration: new InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.all(5),
                                hintText: "Search",
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
                                _mclearbtnvisibility = false;
                                _msearchbtnvisibility = true;
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
                          visible: _mclearbtnvisibility,
                          child: new GestureDetector(
                            onTap: () {
                              setState(() {
                                _mclearbtnvisibility = false;
                                _msearchbtnvisibility = true;
                                _msearchcon.text = "";
                                _msearchformkey.currentState!.reset();
                                _wfuture = fetchmessagewithworkers();
                                _msearchcon.clear();
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
                          visible: _msearchbtnvisibility,
                          child: new GestureDetector(
                            onTap: () {
                              final form = _msearchformkey.currentState;
                              if (form!.validate()) {
                                form.save();
                                searchserverresponse = secondserverresponse
                                    .where((i) =>
                                        i["username"]
                                            .toString()
                                            .toLowerCase()
                                            .contains(_msearchcon.text
                                                .toString()
                                                .toLowerCase()) ||
                                        i["lastmessage"]
                                            .toString()
                                            .toLowerCase()
                                            .contains(_msearchcon.text
                                                .toString()
                                                .toLowerCase()))
                                    .toList();
                                setState(() {
                                  _wfuture = searchmessagewithworkers();
                                  _mclearbtnvisibility = true;
                                  _msearchbtnvisibility = false;
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
                physics: ScrollPhysics(),
                controller: _scrollController,
                child: Column(
                  children: [
                    FutureBuilder<List<AllMessageWorkers>>(
                        future: _wfuture,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<AllMessageWorkers>> snapshot) {
                          //print("list items : " + carresponse.toString());
                          Widget newsListSliver;
                          if (snapshot.hasData) {
                            newsListSliver = ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                controller: _scrollController,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  AllMessageWorkers item =
                                      snapshot.data![index];
                                  bool msgcountvisible;
                                  if (int.parse(item.msgcount) < 1) {
                                    msgcountvisible = false;
                                  } else {
                                    msgcountvisible = true;
                                  }
                                  var _formatter = NumberFormat.compactCurrency(
                                      decimalDigits: 2, symbol: '');
                                  String fdate = "";
                                  DateTime curdate = DateTime.now();
                                  var formattedcurrentdate =
                                      DateFormat('yyyy-MM-dd hh:mm:ss')
                                          .format(curdate);
                                  DateTime todate =
                                      new DateFormat('yyyy-MM-dd hh:mm:ss')
                                          .parse(formattedcurrentdate);
                                  DateTime fromdate =
                                      new DateFormat('yyyy-MM-dd hh:mm:ss')
                                          .parse(item.timeofmsg);

                                  var result = daysBetween(fromdate, todate);
                                  if (result < 1 &&
                                      fromdate.day == todate.day) {
                                    fdate = DateFormat('hh:mm a').format(
                                        DateFormat('yyyy-MM-dd hh:mm:ss')
                                            .parse(item.timeofmsg));
                                  } else if ((result < 1 &&
                                          fromdate.day != todate.day) ||
                                      (result > 0 && result < 2)) {
                                    fdate = "Yesterday";
                                  } else if (result > 1 && result < 8) {
                                    fdate = DateFormat('EEEE').format(
                                        DateFormat('yyyy-MM-dd hh:mm:ss')
                                            .parse(item.timeofmsg));
                                  } else {
                                    fdate = DateFormat('dd/MM/yyyy').format(
                                        DateFormat('yyyy-MM-dd hh:mm:ss')
                                            .parse(item.timeofmsg));
                                  }

                                  print(formattedcurrentdate +
                                      " - " +
                                      todate.day.toString() +
                                      " : " +
                                      fromdate.day.toString() +
                                      "\n\n" +
                                      fdate.toString());
                                  String msgcount = "";
                                  if (int.parse(item.msgcount) < 1000) {
                                    msgcount = item.msgcount;
                                  } else {
                                    msgcount = _formatter
                                        .format(int.parse(item.msgcount));
                                  }

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedid = item.uid;
                                        _selectedusername = item.username;
                                        _selectedimg = item.img;
                                      });
                                      _fetchselectedchat(
                                          item.uid, item.username, item.img);
                                    },
                                    child: Container(
                                      height: 90,
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  width: 1,
                                                  color: Colors.white)),
                                          gradient: LinearGradient(
                                            colors: <Color>[
                                              Color.fromRGBO(0, 0, 0, .7),
                                              Colors.grey.shade900
                                                  .withOpacity(.7)
                                            ],
                                            begin: Alignment(-1.0, -1),
                                            end: Alignment(-1.0, 1),
                                          )),
                                      padding: EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              Container(
                                                width: 70,
                                                height: 70,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Color.fromRGBO(
                                                            73, 73, 73, 1),
                                                        width: 3),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            70),
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: CachedNetworkImageProvider(
                                                          "http://www.emkapp.com/emkapp/imgdata/" +
                                                              item.img),
                                                    )),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    178,
                                                padding: EdgeInsets.only(
                                                    left: 10, top: 10),
                                                height: 90,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(item.username,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 15,
                                                            color:
                                                                Color.fromRGBO(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    1),
                                                          )),
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 4)),
                                                    Flexible(
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                            item.lastmessage,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 2,
                                                            textAlign: TextAlign
                                                                .justify,
                                                            style: TextStyle(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      1),
                                                            )),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.only(
                                                  left: 5, top: 7),
                                              child: Column(
                                                children: [
                                                  Align(
                                                    alignment: Alignment.center,
                                                    child: Text(fdate,
                                                        textAlign:
                                                            TextAlign.left,
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 15,
                                                          color:
                                                              Colors.amber[100],
                                                        )),
                                                  ),
                                                  Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 7)),
                                                  new Visibility(
                                                      visible: msgcountvisible,
                                                      child: Container(
                                                        width: 32,
                                                        padding:
                                                            EdgeInsets.all(4),
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          35.0)),
                                                          color:
                                                              Colors.amber[50],
                                                        ),
                                                        child: Align(
                                                          alignment:
                                                              Alignment.center,
                                                          child: Text(msgcount,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .black,
                                                                  fontSize:
                                                                      14)),
                                                        ),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
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
                        height: 100,
                        width: MediaQuery.of(this.context).size.width)
                  ],
                )),
          ),
        ],
      );
    }

    return datawidget;
  }

  Future<bool> checkPermission() async {
    if (!await Permission.microphone.isGranted) {
      PermissionStatus status = await Permission.microphone.request();
      if (status != PermissionStatus.granted) {
        return false;
      }
    }
    return true;
  }

  Future<String> getFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/EmkappData";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    DateTime curdate = DateTime.now();
    String fdate = DateFormat("yyyyMMddHHmmss").format(curdate);
    return sdPath + "/rec$uid$fdate.mp3";
  }

  Future<String> getDocFilePath() async {
    Directory storageDirectory = await getApplicationDocumentsDirectory();
    String sdPath = storageDirectory.path + "/EmkappData";
    var d = Directory(sdPath);
    if (!d.existsSync()) {
      d.createSync(recursive: true);
    }
    DateTime curdate = DateTime.now();
    String fdate = DateFormat("yyyyMMddHHmmss").format(curdate);
    return sdPath + "/rec$uid$fdate.mp3";
  }

  void startRecord() async {
    bool hasPermission = await checkPermission();
    if (hasPermission) {
      recordFilePath = await getFilePath();

      RecordMp3.instance.start(recordFilePath, (type) {
        setState(() {});
      });
      print("Timer started");
      timerStream = stopWatchStream();
      timerSubscription = timerStream!.listen((int newTick) {
        setState(() {
          print("New tick : " + newTick.toString());
          minsStr = ((newTick / 60) % 60).floor().toString().padLeft(2, '0');
          secsStr = (newTick % 60).floor().toString().padLeft(2, '0');
        });
      });

      setState(() {
        _timervisibility = true;
        isRecording = true;
        isTimerRecording = true;
        iseditable = false;
      });
    } else {}
    setState(() {});
  }

  _sendtextmessage() async {
    //_messagecon
    var url = "http://www.emkapp.com/emkapp/api/messages.php";
    var bdata = {
      "insertchat": "true",
      "message": _messagecon.text,
      "receipient": _selectedid,
      "sender": uid
    };
    //print("path : " + _mediafilepath);
    FormData fdata = FormData.fromMap(bdata);
    setState(() {
      _diagvisibility = true;
    });

    BaseOptions options = new BaseOptions(
      baseUrl: "http://www.emkapp.com/emkapp",
      connectTimeout: 15000,
      receiveTimeout: 300000,
    );

    Dio dio = new Dio(options);
    try {
      var response = await dio.post(url, data: fdata);

      print(response.data);
      if (response.data.toString().contains("successfully")) {
        setState(() {
          scrollpixels = 0;
          _diagvisibility = false;
          _messagecon.clear();
          _sendbtnvisibility = false;
          _recordbtnvisibility = true;
        });

        _fetchselectedchat(_selectedid, _selectedusername, _selectedimg);
      } else {
        setState(() {
          _diagvisibility = false;
        });
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

  _uploadFile() async {
    List<int> bytes = File(_mediafilepath).readAsBytesSync();
    base64image = base64Encode(bytes);
    var filename = Fp.basename(File(_mediafilepath).path).toString();
    var url = "http://www.emkapp.com/emkapp/api/media_uploads.php";
    var bdata = {
      "messagetype": _mediatype,
      "mfile": base64image,
      "mname": filename,
      "receipient": _selectedid,
      "sender": uid,
      "desc": _ucomcon.text
    };
    //print("path : " + _mediafilepath);
    FormData fdata = FormData.fromMap(bdata);
    setState(() {
      _diagvisibility = true;
    });

    BaseOptions options = new BaseOptions(
      baseUrl: "http://www.emkapp.com/emkapp",
      connectTimeout: 15000,
      receiveTimeout: 300000,
    );

    Dio dio = new Dio(options);
    try {
      var response = await dio.post(url, data: fdata);

      print(response.data);
      if (response.data.toString().contains("successfully")) {
        setState(() {
          scrollpixels = 0;
          _diagvisibility = false;
          _resendwidgetvisibility = false;
          _ucomcon.clear();
          _uploadcommentvisible = false;
        });

        _fetchselectedchat(_selectedid, _selectedusername, _selectedimg);
      } else {
        setState(() {
          _resendwidgetvisibility = true;
          _diagvisibility = false;
        });
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

  void stopRecord() async {
    bool s = RecordMp3.instance.stop() || RecordMp3.instance.pause();
    if (s) {
      RecordMp3.instance.stop();
      setState(() {
        isSending = true;
        _mediafilepath = recordFilePath;
        _mediatype = "audio";
      });
      Directory? tempdir = await getExternalStorageDirectory();
      String tempPath = tempdir!.path;
      List<int> bytes = await File(_mediafilepath).readAsBytes();
      var filename = Fp.basename(File(_mediafilepath).path).toString();
      var filepath = tempPath + '/$filename';
      File(filepath).writeAsBytes(bytes);

      setState(() {
        _uploadcommentvisible = true;
        isPlayingMsg = false;
      });
    }
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
                    galleryvideo();
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
                    cameravideo();
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

  Widget _mainMessagesWidget() {
    var datawidget;
    datawidget = Container(
        width: MediaQuery.of(context).size.width * 1,
        height: MediaQuery.of(context).size.height * 1,
        padding: const EdgeInsets.only(bottom: 0),
        decoration: new BoxDecoration(
            image: new DecorationImage(
          image: new ExactAssetImage('assets/images/1.jpg'),
          fit: BoxFit.fill,
        )),
        child: new BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 1,
            height: MediaQuery.of(context).size.height * 1,
            decoration: new BoxDecoration(color: Colors.black.withOpacity(0.5)),
            child: Stack(
              children: [
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          left: 10, right: 10, bottom: 10, top: 10),
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
                                      readOnly: !iseditable,
                                      maxLines: 1,
                                      decoration: new InputDecoration(
                                          isDense: true,
                                          contentPadding: EdgeInsets.all(5),
                                          hintText: "Search",
                                          hintStyle: TextStyle(
                                              color: Colors.grey.shade600),
                                          filled: true,
                                          fillColor: Colors.grey.shade900,
                                          enabledBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color: Colors.grey.shade800,
                                                  width: 2),
                                              borderRadius:
                                                  BorderRadius.circular(10))),
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
                                          _searchwidgetvisibility = false;

                                          _searchformkey.currentState!.reset();
                                          _future = fetchselectedchat();
                                          scrollpixels = 0;
                                          _searchcon.clear();
                                          _searchcon.text = "";
                                        });
                                      },
                                      child: Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[900],
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(35))),
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
                                        final form =
                                            _searchformkey.currentState;
                                        if (form!.validate()) {
                                          form.save();
                                          searchmessagesresponse =
                                              secondmessagesresponse
                                                  .where((i) =>
                                                      i["message"]
                                                          .toString()
                                                          .toLowerCase()
                                                          .contains(_searchcon
                                                              .text) ||
                                                      i["message"]
                                                          .toString()
                                                          .contains(
                                                              _searchcon.text))
                                                  .toList();
                                          setState(() {
                                            _future = searchselectedchat();
                                            _clearbtnvisibility = true;
                                            _searchbtnvisibility = false;
                                            _searchwidgetvisibility = true;
                                            scrollpixels = 0;
                                          });
                                        }
                                      },
                                      child: Container(
                                        height: 35,
                                        width: 35,
                                        decoration: BoxDecoration(
                                            color: Colors.grey[900],
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(35))),
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
                    Stack(
                      children: [
                        PreferredSize(
                          preferredSize: Size(0, 0),
                          child: Container(
                            color: Color.fromRGBO(0, 0, 12, 1),
                            child: Container(
                              width: MediaQuery.of(context).size.width,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 7.0, bottom: 7.0),
                                child: AppBar(
                                  actions: <Widget>[
                                    PopupMenuButton(
                                      icon: RotatedBox(
                                          quarterTurns: -1,
                                          child: Icon(
                                            Icons.attachment,
                                            size: 30,
                                          )),
                                      color: Color.fromRGBO(0, 0, 13, 1),
                                      itemBuilder: (context) => [
                                        PopupMenuItem<int>(
                                            value: 0,
                                            child: Row(
                                              children: [
                                                new IconButton(
                                                  icon: Icon(Icons
                                                      .camera_alt_outlined),
                                                  onPressed: () {},
                                                ),
                                                Text("Camera",
                                                    style: TextStyle(
                                                        color: Colors.white))
                                              ],
                                            )),
                                        PopupMenuItem<int>(
                                            value: 1,
                                            child: Row(
                                              children: [
                                                new IconButton(
                                                  icon:
                                                      Icon(Icons.photo_library),
                                                  onPressed: () {},
                                                ),
                                                Text("Gallery",
                                                    style: TextStyle(
                                                        color: Colors.white))
                                              ],
                                            )),
                                        PopupMenuItem<int>(
                                            value: 4,
                                            child: Row(
                                              children: [
                                                new IconButton(
                                                  icon:
                                                      Icon(Icons.video_library),
                                                  onPressed: () {},
                                                ),
                                                Text("Video",
                                                    style: TextStyle(
                                                        color: Colors.white))
                                              ],
                                            )),
                                        PopupMenuItem<int>(
                                            value: 2,
                                            child: Row(
                                              children: [
                                                new IconButton(
                                                  icon: Icon(Icons.book),
                                                  onPressed: () {},
                                                ),
                                                Text("Document",
                                                    style: TextStyle(
                                                        color: Colors.white))
                                              ],
                                            )),
                                        PopupMenuItem<int>(
                                            value: 3,
                                            child: Row(
                                              children: [
                                                new IconButton(
                                                  icon: Icon(Icons.refresh),
                                                  onPressed: () {},
                                                ),
                                                Text("Refresh",
                                                    style: TextStyle(
                                                        color: Colors.white))
                                              ],
                                            )),
                                      ],
                                      onSelected: (value) async {
                                        if (value == 4) {
                                          _showfilepicker(context);
                                        }
                                        if (value == 0) {
                                          var status =
                                              await Permission.photos.status;
                                          if (status.isGranted) {
                                          } else if (status.isDenied) {
                                          } else {
                                            showDialog(
                                                context: context,
                                                builder: (BuildContext
                                                        context) =>
                                                    CupertinoAlertDialog(
                                                      title: Text(
                                                          'Camera Permission'),
                                                      content: Text(
                                                          'App requires the use of camera to get images via camera'),
                                                      actions: <Widget>[
                                                        CupertinoDialogAction(
                                                          child: Text('Okay'),
                                                          onPressed: () =>
                                                              Navigator.of(
                                                                      context)
                                                                  .pop(),
                                                        ),
                                                        CupertinoDialogAction(
                                                          child:
                                                              Text('Settings'),
                                                          onPressed: () =>
                                                              openAppSettings(),
                                                        ),
                                                      ],
                                                    ));
                                          }
                                          XFile? gfile =
                                              await _picker.pickImage(
                                                  source: ImageSource.camera);
                                          if (gfile != null) {
                                            galleryfile = File(gfile.path);
                                          }
                                          if (galleryfile != null) {
                                            final bytes =
                                                Io.File(galleryfile!.path)
                                                    .readAsBytesSync();
                                            _imgfile = galleryfile
                                                .toString()
                                                .split('/')
                                                .last
                                                .split('r')
                                                .last;
                                            base64image = base64Encode(bytes);
                                            _finalfile = _imgfile.substring(
                                                0, _imgfile.indexOf('\''));

                                            Future.delayed(Duration(seconds: 0),
                                                () {
                                              if (gfile != null) {
                                                cropimage();
                                              }
                                            });
                                          }
                                        }
                                        if (value == 1) {
                                          galleryimage();
                                        }

                                        if (value == 2) {
                                          fpresult = await FilePicker.platform
                                              .pickFiles(
                                                  type: FileType.custom,
                                                  allowedExtensions: [
                                                'pdf',
                                                'doc',
                                                'docx',
                                                'xls',
                                                'xlsx',
                                                'ppt',
                                                'pptx'
                                              ]);
                                          if (fpresult != null) {
                                            File pickedfile = File(
                                                fpresult!.files.single.path!);
                                            Directory? tempdir =
                                                await getApplicationDocumentsDirectory();
                                            String _foldername = "EmkappData";
                                            String tempPath =
                                                '${tempdir!.path}/$_foldername/';
                                            List<int> bytes = await File(
                                                    fpresult!
                                                        .files.single.path!)
                                                .readAsBytes();
                                            var filename = Fp.basename(File(
                                                        fpresult!
                                                            .files.single.path!)
                                                    .path)
                                                .toString();
                                            var filepath =
                                                tempPath + '/$filename';
                                            File(filepath).writeAsBytes(bytes);
                                            setState(() {
                                              isSending = true;
                                              _mediafilepath =
                                                  fpresult!.files.single.path!;
                                              _mediatype = "document";
                                              _uploadcommentvisible = true;
                                            });
                                          }
                                        }
                                        if (value == 3) {
                                          _fetchselectedchat(_selectedid,
                                              _selectedusername, _selectedimg);
                                        }
                                      },
                                    ),
                                  ],
                                  primary: false,
                                  leading: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _submessagesvisible = false;
                                        _headmenuvisible = true;
                                        scrollpixels = 0;
                                      });
                                      _getusermessages(uid);
                                    },
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: Colors.white,
                                      size: 27,
                                    ),
                                  ),
                                  titleSpacing: 0,
                                  title: Container(
                                    width: MediaQuery.of(context).size.width,
                                    transform:
                                        Matrix4.translationValues(0, 0, 0),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 5.0, bottom: 5.0),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Container(
                                          padding: EdgeInsets.only(
                                              top: 5, bottom: 5),
                                          height: 70,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          color: Color.fromRGBO(0, 0, 12, 1),
                                          child: Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  _showsnackbar(
                                                      _selectedimg, "Close");
                                                },
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: Container(
                                                    width: 55,
                                                    height: 55,
                                                    decoration: BoxDecoration(
                                                        border: Border.all(
                                                            color:
                                                                Color.fromRGBO(
                                                                    73,
                                                                    73,
                                                                    73,
                                                                    1),
                                                            width: 2),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(70),
                                                        image: DecorationImage(
                                                          fit: BoxFit.cover,
                                                          image: CachedNetworkImageProvider(
                                                              "http://www.emkapp.com/emkapp/imgdata/" +
                                                                  _selectedimg),
                                                        )),
                                                  ),
                                                ),
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 10)),
                                              Align(
                                                alignment: Alignment.centerLeft,
                                                child: Text(_selectedusername,
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        color: Color.fromRGBO(
                                                            255, 255, 255, 1),
                                                        fontSize: 18)),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  backgroundColor: Color.fromRGBO(0, 0, 12, 1),
                                  centerTitle: true,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Visibility(
                            visible: _playervisible, child: bottomPanel()),
                      ],
                    ),
                    Expanded(
                        child: Container(
                      width: MediaQuery.of(context).size.width,
                      child: _selectedChatWidget(),
                    )),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Align(
                        alignment: FractionalOffset.bottomCenter,
                        child: Container(
                          padding: EdgeInsets.only(
                              left: 10, right: 10, bottom: 10, top: 10),
                          width: MediaQuery.of(context).size.width,
                          color: Color.fromRGBO(0, 0, 12, 1),
                          child: Form(
                            key: _messageformkey,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width - 70,
                                    child: FocusScope(
                                      child: Focus(
                                        onFocusChange: (value) {
                                          //print("Focus : $value");
                                          //  _showsnackbar(
                                          //    "Focus : $value", "Okay");
                                        },
                                        child: new TextFormField(
                                          textInputAction: TextInputAction.none,
                                          style: TextStyle(color: Colors.black),
                                          controller: _messagecon,
                                          readOnly: !iseditable,
                                          minLines: 1,
                                          maxLines: 5,
                                          decoration: new InputDecoration(
                                              isDense: true,
                                              contentPadding: EdgeInsets.all(5),
                                              hintText: "",
                                              filled: true,
                                              fillColor: Colors.white,
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10))),
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'This field is required';
                                            } else {
                                              return null;
                                            }
                                          },
                                          onChanged: (value) {
                                            if (value.length > 0) {
                                              setState(() {
                                                _sendbtnvisibility = true;
                                                _recordbtnvisibility = false;
                                              });
                                            } else {
                                              setState(() {
                                                _sendbtnvisibility = false;
                                                _recordbtnvisibility = true;
                                              });
                                            }
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
                                        visible: _sendbtnvisibility,
                                        child: new GestureDetector(
                                          onTap: () {
                                            _sendtextmessage();
                                          },
                                          child: Container(
                                            height: 35,
                                            width: 35,
                                            decoration: BoxDecoration(
                                                color: Colors.grey[900],
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(35))),
                                            child: Icon(
                                              Icons.send,
                                              size: 20,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: _recordbtnvisibility,
                                        child: new GestureDetector(
                                          onTap: () {
                                            if (isRecording.toString() ==
                                                "false") {
                                              startRecord();
                                            } else {
                                              timerSubscription!.cancel();
                                              timerStream = null;
                                              stopRecord();
                                              setState(() {
                                                isRecording = false;
                                                isTimerRecording = false;
                                                minsStr = "00";
                                                secsStr = "00";
                                                _timervisibility = false;
                                                iseditable = true;
                                              });
                                            }
                                          },
                                          child: Container(
                                            height: 35,
                                            width: 35,
                                            decoration: BoxDecoration(
                                                color: Colors.grey[900],
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(35))),
                                            child: Icon(
                                              Icons.mic,
                                              size: 20,
                                              color: isRecording
                                                  ? Colors.black12
                                                  : Colors.white,
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
                      ),
                    )
                  ],
                ),
                Positioned(
                    bottom: 58,
                    left: MediaQuery.of(context).size.width * 0.5 - 100,
                    right: MediaQuery.of(context).size.width * 0.5 - 100,
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Visibility(
                        visible: _timervisibility,
                        child: Container(
                          width: 180,
                          height: 50,
                          padding: EdgeInsets.only(left: 15, right: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  if (isTimerRecording.toString() == "true") {
                                    setState(() {
                                      timerSubscription!.pause();
                                      isTimerRecording = false;
                                      RecordMp3.instance.pause();
                                    });
                                  } else {
                                    setState(() {
                                      timerSubscription!.resume();
                                      isTimerRecording = true;
                                      RecordMp3.instance.resume();
                                    });
                                  }
                                },
                                child: Icon(
                                  isTimerRecording
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 30,
                                  color: Colors.greenAccent,
                                ),
                              ),
                              Text(
                                "$minsStr : $secsStr",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontFamily: 'serif',
                                  fontWeight: FontWeight.w700,
                                  color: Color.fromRGBO(255, 255, 255, 1),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  timerSubscription!.cancel();
                                  timerStream = null;
                                  setState(() {
                                    isRecording = false;
                                    isTimerRecording = false;
                                    minsStr = '00';
                                    secsStr = '00';
                                    stopRecord();
                                    iseditable = true;
                                    _timervisibility = false;
                                  });
                                },
                                child: Icon(
                                  Icons.cancel,
                                  size: 30,
                                  color: Colors.redAccent,
                                ),
                              )
                            ],
                          ),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(50)),
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Colors.grey.shade900.withOpacity(.89),
                                  Color.fromRGBO(0, 0, 0, .89),
                                ],
                                begin: Alignment(-1.0, -1),
                                end: Alignment(-1.0, 1),
                              )),
                        ),
                      ),
                    )),
                Visibility(
                    visible: _resendwidgetvisibility,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height,
                      color: Colors.black.withOpacity(.8),
                      child: Center(
                        child: Container(
                          width: 300,
                          height: 200,
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              gradient: LinearGradient(
                                colors: <Color>[
                                  Color.fromRGBO(237, 236, 240, 1),
                                  Color.fromRGBO(206, 205, 219, 1),
                                ],
                                begin: Alignment(-1.0, -1),
                                end: Alignment(-1.0, 1),
                              )),
                          child: Column(
                            children: [
                              Container(
                                width: double.infinity,
                                height: 50,
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                  colors: <Color>[
                                    Colors.grey.shade900.withOpacity(.89),
                                    Color.fromRGBO(0, 0, 0, .89),
                                  ],
                                  begin: Alignment(-1.0, -1),
                                  end: Alignment(-1.0, 1),
                                )),
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    "Message",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 23,
                                      fontFamily: 'serif',
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                    ),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 44.0, bottom: 24.0),
                                child: Text(
                                  "Oops, error sending message. 🥲",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: 'serif',
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(7.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      child: Container(
                                        width: 100,
                                        height: 38,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12.0)),
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
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              side: BorderSide(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.09),
                                                  width: 3),
                                            ),
                                            color: Color.fromRGBO(0, 0, 0, 0.0),
                                            textColor: Colors.white,
                                            child: Container(
                                              child: new Text(
                                                'Retry',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'serif',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                            ),
                                            onPressed: () {
                                              _uploadFile();
                                              setState(() {});
                                            }),
                                      ),
                                    ),
                                    ClipRRect(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10.0)),
                                      child: Container(
                                        width: 100,
                                        height: 38,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12.0)),
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
                                              borderRadius:
                                                  BorderRadius.circular(15),
                                              side: BorderSide(
                                                  color: Color.fromRGBO(
                                                      0, 0, 0, 0.09),
                                                  width: 3),
                                            ),
                                            color: Color.fromRGBO(0, 0, 0, 0.0),
                                            textColor: Colors.white,
                                            child: Container(
                                              child: new Text(
                                                'Cancel',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'serif',
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18),
                                              ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _resendwidgetvisibility = false;
                                              });
                                            }),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    )),
                Visibility(
                    visible: _uploadcommentvisible, child: _uploadFormWidget()),
              ],
            ),
          ),
        ));
    return datawidget;
  }

  var imgbytes;
  Widget _mediaWidget(String mtype) {
    var datawidget;
    if (mtype.isEmpty) {
      datawidget = Container(
        width: double.infinity,
        height: double.infinity,
      );
    }
    // _mediafilepath = fpresult!.files.single.path!;
    // _mediatype = "document";
    if (mtype == "audio") {
      datawidget = Container(
        alignment: Alignment.center,
        width: double.infinity,
        height: double.infinity,
        child: mPlayer(),
      );
    }
    if (mtype == "video") {
      var pos =
          Fp.basename(File(_mediafilepath).path).toString().lastIndexOf(".");
      String thumbnail = (pos != -1)
          ? Fp.basename(File(_mediafilepath).path).toString().substring(0, pos)
          : Fp.basename(File(_mediafilepath).path).toString();
      datawidget = Stack(
        children: [
          Image.file(File(_appDirFolder!.path + thumbnail + ".png"),
              height: double.infinity, width: double.infinity),
          Container(
              height: double.infinity,
              width: double.infinity,
              alignment: Alignment.center,
              child: GestureDetector(
                onTap: () {
                  OpenFile.open(_mediafilepath);
                },
                child: Container(
                    width: 65,
                    height: 65,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(65)),
                        color: Color.fromRGBO(0, 0, 15, 1)),
                    child: Icon(
                      Icons.play_circle,
                      size: 65,
                      color: Colors.white,
                    )),
              ))
        ],
      );
    }
    if (mtype == "picture") {
      datawidget = new Image.file(File(_mediafilepath),
          height: double.infinity, width: double.infinity);
    }
    if (mtype == "document") {
      var fIcon;
      var fextension =
          Fp.basename(File(_mediafilepath).path).toString().split(".").last;
      if (fextension == "ppt" || fextension == "pptx") {
        fIcon = "pptx.png";
      }
      if (fextension == "xls" || fextension == "xlsx") {
        fIcon = "xlsx.png";
      }
      if (fextension == "doc" || fextension == "docx") {
        fIcon = "docx.png";
      }
      if (fextension == "pdf") {
        fIcon = "pdfx.png";
      }
      print("Document : " + _mediafilepath);
      datawidget = Container(
        alignment: Alignment.center,
        height: double.infinity,
        width: double.infinity,
        child: GestureDetector(
          onTap: () async {
            final _oresult = await OpenFile.open(_mediafilepath);
            if (!_oresult.message.contains("done")) {
              _showsnackbar(_oresult.message, "Okay");
            }
          },
          child: Image.asset("assets/images/" + fIcon,
              height: double.infinity * 0.5, width: double.infinity * 0.5),
        ),
      );
    }
    return datawidget;
  }

  Widget _uploadFormWidget() {
    var datawidget;
    datawidget = ListView(
      shrinkWrap: true,
      children: [
        Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(20),
            color: Colors.black.withOpacity(.89),
            child: Center(
              child: Flexible(
                child: Container(
                  width: double.infinity,
                  height: 491,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                      gradient: LinearGradient(
                        colors: <Color>[
                          Color.fromRGBO(237, 236, 240, 1),
                          Color.fromRGBO(206, 205, 219, 1),
                        ],
                        begin: Alignment(-1.0, -1),
                        end: Alignment(-1.0, 1),
                      )),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                            gradient: LinearGradient(
                          colors: <Color>[
                            Colors.grey.shade900.withOpacity(.89),
                            Color.fromRGBO(0, 0, 0, .89),
                          ],
                          begin: Alignment(-1.0, -1),
                          end: Alignment(-1.0, 1),
                        )),
                        child: Align(
                          alignment: Alignment.center,
                          child: Text(
                            "Description Box",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 23,
                              fontFamily: 'serif',
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(255, 255, 255, 1),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 300,
                        width: double.infinity,
                        color: Colors.black,
                        child: _mediaWidget(_mediatype),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
                        child: new TextFormField(
                          controller: _ucomcon,
                          decoration: new InputDecoration(
                            labelText: "Enter description here (optional)",
                            prefixIcon: Icon(Icons.description),
                          ),
                          keyboardType: TextInputType.text,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(7.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              child: Container(
                                width: 150,
                                height: 38,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
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
                                          color: Color.fromRGBO(0, 0, 0, 0.09),
                                          width: 3),
                                    ),
                                    color: Color.fromRGBO(0, 0, 0, 0.0),
                                    textColor: Colors.white,
                                    child: Container(
                                      child: new Text(
                                        'Send',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'serif',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ),
                                    onPressed: () {
                                      _uploadFile();
                                      setState(() {});
                                    }),
                              ),
                            ),
                            ClipRRect(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                              child: Container(
                                width: 150,
                                height: 38,
                                decoration: const BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(12.0)),
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
                                          color: Color.fromRGBO(0, 0, 0, 0.09),
                                          width: 3),
                                    ),
                                    color: Color.fromRGBO(0, 0, 0, 0.0),
                                    textColor: Colors.white,
                                    child: Container(
                                      child: new Text(
                                        'Discard',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: 'serif',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _uploadcommentvisible = false;
                                      });
                                    }),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )),
      ],
    );
    return datawidget;
  }

  Widget _allWorkersWidget() {
    var datawidget;
    if (workersresponse.isEmpty) {
      datawidget = Container();
    } else {
      datawidget = Column(
        children: [
          Stack(
            children: [
              Container(
                padding:
                    EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
                width: MediaQuery.of(context).size.width,
                color: Colors.grey.shade900,
                height: 50,
              ),
              Container(
                padding:
                    EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
                width: MediaQuery.of(context).size.width,
                color: Colors.black.withOpacity(.6),
                height: 50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: MediaQuery.of(context).size.width - 50,
                        child: Text(
                          'New Chat',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _cwfuture = fetchchatworkers();
                            _allworkersvisible = false;
                            _wsearchcon.clear();
                          });
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: Colors.grey.shade900,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30))),
                          child: Icon(
                            Icons.power_settings_new,
                            color: Colors.redAccent.withOpacity(.5),
                            size: 25,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
            width: MediaQuery.of(context).size.width,
            color: Color.fromRGBO(0, 0, 12, 1),
            child: Form(
              key: _wsearchformkey,
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
                            controller: _wsearchcon,
                            readOnly: false,
                            maxLines: 1,
                            decoration: new InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.all(5),
                                hintText: "Search",
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
                                _wclearbtnvisibility = false;
                                _wsearchbtnvisibility = true;
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
                          visible: _wclearbtnvisibility,
                          child: new GestureDetector(
                            onTap: () {
                              setState(() {
                                _wclearbtnvisibility = false;
                                _wsearchbtnvisibility = true;
                                _wsearchcon.text = "";
                                _wsearchformkey.currentState!.reset();
                                _cwfuture = fetchchatworkers();
                                _wsearchcon.clear();
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
                          visible: _wsearchbtnvisibility,
                          child: new GestureDetector(
                            onTap: () {
                              final form = _wsearchformkey.currentState;
                              if (form!.validate()) {
                                form.save();
                                searchworkersresponse = secondworkersresponse
                                    .where((i) =>
                                        i["username"]
                                            .toString()
                                            .toLowerCase()
                                            .contains(_wsearchcon.text) ||
                                        i["username"]
                                            .toString()
                                            .contains(_wsearchcon.text))
                                    .toList();
                                setState(() {
                                  _cwfuture = searchchatworkers();
                                  _wclearbtnvisibility = true;
                                  _wsearchbtnvisibility = false;
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
                physics: ScrollPhysics(),
                controller: _scrollController,
                child: Column(
                  children: [
                    FutureBuilder<List<AllChatWorkers>>(
                        future: _cwfuture,
                        builder: (BuildContext context,
                            AsyncSnapshot<List<AllChatWorkers>> snapshot) {
                          //print("list items : " + carresponse.toString());
                          Widget newsListSliver;
                          if (snapshot.hasData) {
                            newsListSliver = ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                controller: _scrollController,
                                itemCount: snapshot.data!.length,
                                itemBuilder: (BuildContext context, int index) {
                                  AllChatWorkers item = snapshot.data![index];

                                  return GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _selectedid = item.uid;
                                        _selectedusername = item.username;
                                        _selectedimg = item.img;
                                        _allworkersvisible = false;
                                      });
                                      _fetchselectedchat(
                                          item.uid, item.username, item.img);
                                    },
                                    child: Container(
                                      margin: EdgeInsets.only(bottom: 4),
                                      height: 60,
                                      decoration: BoxDecoration(
                                          border: Border(
                                              bottom: BorderSide(
                                                  width: .5,
                                                  color: Colors.white
                                                      .withOpacity(.4))),
                                          gradient: LinearGradient(
                                            colors: <Color>[
                                              Color.fromRGBO(0, 0, 0, 1),
                                              Colors.grey.shade900
                                                  .withOpacity(1)
                                            ],
                                            begin: Alignment(-1.0, -1),
                                            end: Alignment(-1.0, 1),
                                          )),
                                      padding: EdgeInsets.all(10.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: <Widget>[
                                          Row(
                                            children: [
                                              Container(
                                                width: 41,
                                                height: 41,
                                                decoration: BoxDecoration(
                                                    border: Border.all(
                                                        color: Color.fromRGBO(
                                                            73, 73, 73, 1),
                                                        width: 1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                    image: DecorationImage(
                                                      fit: BoxFit.cover,
                                                      image: CachedNetworkImageProvider(
                                                          "http://www.emkapp.com/emkapp/imgdata/" +
                                                              item.img),
                                                    )),
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                    178,
                                                padding: EdgeInsets.only(
                                                    left: 10, top: 2),
                                                height: 70,
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: [
                                                    Align(
                                                      alignment:
                                                          Alignment.centerLeft,
                                                      child: Text(item.username,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 15,
                                                            color:
                                                                Color.fromRGBO(
                                                                    255,
                                                                    255,
                                                                    255,
                                                                    1),
                                                          )),
                                                    ),
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                top: 2)),
                                                    Flexible(
                                                      child: Align(
                                                        alignment: Alignment
                                                            .centerLeft,
                                                        child: Text(
                                                            item.channel,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            textAlign: TextAlign
                                                                .justify,
                                                            style: TextStyle(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      .6),
                                                            )),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
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
                        height: 100,
                        width: MediaQuery.of(this.context).size.width)
                  ],
                )),
          ),
        ],
      );
    }

    return Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        color: Colors.grey.shade900,
        child: datawidget);
  }

  Widget _buildSBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      backgroundColor: Color.fromRGBO(0, 0, 13, 1),
      actions: <Widget>[
        PopupMenuButton(
          icon: Icon(Icons.more_vert),
          color: Color.fromRGBO(0, 0, 13, 1),
          itemBuilder: (context) => [
            PopupMenuItem<int>(
                value: 0,
                child: Row(
                  children: [
                    new IconButton(
                      icon: Icon(Icons.border_color),
                      onPressed: () {},
                    ),
                    Text("New Message", style: TextStyle(color: Colors.white))
                  ],
                )),
            PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    new IconButton(
                      icon: Icon(Icons.refresh),
                      onPressed: () {
                        setState(() {
                          _getusermessages(uid);
                        });
                      },
                    ),
                    Text("Refresh", style: TextStyle(color: Colors.white))
                  ],
                )),
          ],
          onSelected: (value) {
            if (value == 1) {
              _getusermessages(uid);
            }
            if (value == 0) {
              _getworkers(uid);
            }
          },
        ),
      ],
    );
  }

  scrolltoposition() {
    setState(() {
      _mscrollController.animateTo(_mscrollController.position.maxScrollExtent,
          duration: Duration(seconds: 1), curve: Curves.linear);
    });
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
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(50),
          child: Container(
              child: Visibility(
                  visible: _headmenuvisible, child: _buildSBar(this.context)))),
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
                    Visibility(
                        visible: _allmessagesvisible,
                        child: _allMessagesWidget()),
                    Visibility(
                        visible: _submessagesvisible,
                        child: _mainMessagesWidget()),
                    Visibility(
                        visible: _allworkersvisible,
                        child: _allWorkersWidget()),
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

  String _curaudio = "";
  openPlayer(int index, String message, bool selectedPlaying, double pixels) {
    setState(() {
      _uaudio = message;
      uindex = index;
      _playervisible = true;
      scrollpixels = pixels;
    });

    if (message == _curaudio) {
      if (_playerState == PlayerState.COMPLETED) {
        setState(() {
          isMediaPlaying = true;
          isSelectedPlaying[index] = true;
          advancedPlayer!.play(_appDirFolder!.path + message, isLocal: true);
          _playerState = PlayerState.PLAYING;
        });
      } else if (_playerState == PlayerState.PAUSED) {
        setState(() {
          isMediaPlaying = true;
          isSelectedPlaying[index] = true;
          advancedPlayer!.resume();
          _playerState = PlayerState.PLAYING;
        });
      } else if (_playerState == PlayerState.PLAYING) {
        setState(() {
          isMediaPlaying = false;
          isSelectedPlaying[index] = false;
          advancedPlayer!.pause();
          _playerState = PlayerState.PAUSED;
        });
      }
    } else {
      setState(() {
        isMediaPlaying = true;
        isSelectedPlaying[index] = true;
        advancedPlayer!.play(_appDirFolder!.path + message, isLocal: true);
        _playerState = PlayerState.PLAYING;
        _curaudio = message;
      });
    }

    //advancedPlayer!.play(_appDirFolder!.path + message, isLocal: true);
    //audioCache!.play("file://" + _appDirFolder!.path + message);
    for (var i = 0; i < isSelectedPlaying.length; i++) {
      if (i != index) {
        setState(() {
          isSelectedPlaying[i] = false;
        });
      }
    }
  }
}
