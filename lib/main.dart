import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:share_a_pic/ui/login_page.dart';
import 'package:share_a_pic/ui/main_page.dart';

import 'blocs/user_bloc.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        primaryColorBrightness: Brightness.dark,
        brightness: Brightness.dark,
      ),
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  String token;

  @override
  void initState() {
    super.initState();

    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.getToken().then((token) {
      print('token $token');
      this.token = token;
    });

    _firebaseMessaging.subscribeToTopic('images');

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("msg onMessage: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print('msg on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('msg on launch $message');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<FirebaseUser>(
      stream: FirebaseAuth.instance.onAuthStateChanged,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          FirebaseUser user = snapshot.data;
          if (user == null) {
            return LoginPage();
          }
          userBloc.userToken = token;
          userBloc.firebaseUser = user;
          userBloc.updateToken(user, token);
          return MainPage(user: user);
        } else {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
