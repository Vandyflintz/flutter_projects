import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'addnewworkadmin.dart';
import 'allworkadminscontainer.dart';
import 'login.dart';

void main() => runApp(WorkAdmin());

class WorkAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);

    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainWorkAdmin(),
    );
  }
}

class MainWorkAdmin extends StatefulWidget {
  @override
  State createState() => new WorkAdminState();
}

class WorkAdminState extends State<MainWorkAdmin>
    with TickerProviderStateMixin {
  late AnimationController _iconanimcontroller;
  late Animation<double> _iconanim;
  late ProgressDialog pr;
  var _scrollController, _tabController;
  int bottomSelectedIndex = 0;
  @override
  void initState() {
    super.initState();
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
  bool isButtonEnabled = true;
  String user = '', password = '', message = '';

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

  List<BottomNavigationBarItem> buildBottomNavBarItems() {
    return [
      BottomNavigationBarItem(
          backgroundColor: Colors.transparent,
          icon: new Icon(Icons.person_add),
          title: new Text(
            'Add Admin',
            style: new TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
                color: Colors.white),
          )),
      BottomNavigationBarItem(
        backgroundColor: Colors.transparent,
        icon: new Icon(Icons.people),
        title: new Text(
          'All Admins',
          style: new TextStyle(
              fontWeight: FontWeight.w400, fontSize: 14.0, color: Colors.white),
        ),
      ),
      BottomNavigationBarItem(
          backgroundColor: Colors.transparent,
          icon: Icon(Icons.logout),
          title: Text(
            'Log Out',
            style: new TextStyle(
                fontWeight: FontWeight.w400,
                fontSize: 14.0,
                color: Colors.white),
          )),
    ];
  }

  PageController pageController = PageController(
    initialPage: 0,
    keepPage: true,
  );

  void pageChanged(int index) {
    setState(() {
      bottomSelectedIndex = index;
    });
  }

  void bottomTapped(int index) {
    setState(() {
      bottomSelectedIndex = index;
      pageController.animateToPage(index,
          duration: Duration(milliseconds: 500), curve: Curves.ease);
    });
  }

  Widget buildPageView() {
    return PageView(
        controller: pageController,
        onPageChanged: (index) {
          pageChanged(index);
        },
        children: <Widget>[MainAddWorkAdmin(), MainAllWorkAdmins()]);
  }

  @override
  void dispose() {
    // _animcon.dispose();
    _iconanimcontroller.dispose();
    super.dispose();
  }

  _showlogoutdialog(BuildContext context) {
    Widget cancelbtn = FlatButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop(context);
      },
      child: Text("Cancel"),
    );
    Widget continuebtn = FlatButton(
      onPressed: () {
        Navigator.of(context, rootNavigator: true).pop(context);
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
            (Route<dynamic> route) => false);
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
                      child: Container(
                        width: MediaQuery.of(context).size.width * 1,
                        height: MediaQuery.of(context).size.height * 1,
                        decoration: new BoxDecoration(
                            color: Colors.black.withOpacity(0.4)),
                        child: buildPageView(),
                      )),
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color.fromRGBO(0, 0, 12, 1).withOpacity(.5),
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.amber[100],
        currentIndex: bottomSelectedIndex,
        onTap: (index) {
          if (index == 2) {
            _showlogoutdialog(context);
          } else {
            bottomTapped(index);
          }
        },
        items: buildBottomNavBarItems(),
      ),
    );
  }
}
