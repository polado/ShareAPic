import 'package:email_validator/email_validator.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:share_a_pic/blocs/user_bloc.dart';
import 'package:toast/toast.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  double _radius = 80;

  String email = '', password = '';
  bool _obscureText = true;
  bool _loginState = false;

  bool dayOrNight = false;
  bool switchDayOrNight = false;

  void changeLoginState(bool value) => setState(() {
        _loginState = value;
      });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_loginState ? 'Sign Up' : 'Login')),
      body: body(),
    );
  }

  String animation = 'night_idle';

  getAnimation() async {
    print('switchdayornight $switchDayOrNight $dayOrNight');

    if (switchDayOrNight && dayOrNight) {
      setState(() {
        animation = 'switch_day';

        _loginState = true;
        switchDayOrNight = false;
      });
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        animation = 'day_idle';
      });
    } else if (!switchDayOrNight && dayOrNight) {
      setState(() {
        _loginState = true;
        animation = 'day_idle';
      });
    } else if (switchDayOrNight && !dayOrNight) {
      setState(() {
        animation = 'switch_night';

        _loginState = false;
        switchDayOrNight = false;
      });
      await Future.delayed(Duration(milliseconds: 500));
      setState(() {
        animation = 'night_idle';
      });
    } else {
      setState(() {
        _loginState = false;
        animation = 'night_idle';
      });
    }
  }

  Widget body() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 36, vertical: 16),
      child: Form(
        key: formKey,
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    'Sign Up or Login?',
                    textAlign: TextAlign.center,
                    style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Expanded(
                  child: SizedBox(
                    child: GestureDetector(
                      child: FlareActor(
                        'assets/switch_day_night_theme.flr',
                        animation: animation,
                      ),
                      onTap: () {
                        dayOrNight = !dayOrNight;
                        switchDayOrNight = !switchDayOrNight;
                        getAnimation();
                      },
                    ),
                    height: 50,
                  ),
                ),
              ],
            ),
//            SwitchListTile(
//              value: _loginState,
//              onChanged: changeLoginState,
//              title: new Text('Sign Up or Login?',
//                  style: new TextStyle(fontWeight: FontWeight.bold)),
//            ),
            Padding(padding: EdgeInsets.only(top: 24)),
            TextFormField(
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_radius)),
                  labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              validator: (String value) {
                if (value.isEmpty)
                  return 'Please enter email';
                else if (!EmailValidator.validate(value, true))
                  return 'Please enter valid email';
                return null;
              },
              onSaved: (String value) {
                setState(() {
                  email = value;
                });
              },
            ),
            Padding(padding: EdgeInsets.only(top: 16)),
            TextFormField(
              obscureText: _obscureText,
              decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                      icon: Icon(
                        Icons.remove_red_eye,
                        color: _obscureText
                            ? Colors.grey
                            : Theme.of(context).accentColor,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      }),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(_radius)),
                  labelText: 'Password'),
              validator: (String value) {
                if (value.isEmpty) return 'Please enter password';
                return null;
              },
              onSaved: (String value) {
                setState(() {
                  password = value;
                });
              },
            ),
            Padding(padding: EdgeInsets.only(top: 36)),
            Container(
              width: MediaQuery.of(context).size.width,
              decoration:
                  BoxDecoration(borderRadius: BorderRadius.circular(_radius)),
              child: RaisedButton(
                elevation: 5,
                padding: EdgeInsets.all(16),
                color: Theme.of(context).accentColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(_radius)),
                textColor: Colors.white,
                child: Text(
                  _loginState ? 'Sign Up' : 'Login',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  _loginState ? _signUp() : _login();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _validate() {
    if (formKey.currentState.validate()) {
      formKey.currentState.save();
      return true;
    }
    return false;
  }

  Future<void> _signUp() async {
    if (_validate()) {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal,
          isDismissible: false,
          showLogs: false);
      pr.style(
          progressWidget: Center(child: CircularProgressIndicator()),
          message: 'Creating your account...',
          borderRadius: 8);
      pr.show();

      bool res = await userBloc.emailPasswordSignUp(
          email, password, 'Man Has No Name');
      pr.dismiss();
      if (!res)
        Toast.show('Something went wrong', context,
            backgroundColor: Theme
                .of(context)
                .accentColor,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
            textColor: Colors.black,
            backgroundRadius: 80);
    }
  }

  Future<void> _login() async {
    if (_validate()) {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal,
          isDismissible: false,
          showLogs: false);
      pr.style(
          progressWidget: Center(child: CircularProgressIndicator()),
          message: 'Loging in...',
          borderRadius: 8);
      pr.show();
//        Toast.show('Loging in...', context,
//            backgroundColor: Theme.of(context).accentColor,
//            duration: Toast.LENGTH_LONG,
//            gravity: Toast.CENTER,
//            textColor: Colors.black,
//            backgroundRadius: 8);
      bool res = await userBloc.emailPasswordLogin(email, password);
      pr.dismiss();
      if (!res)
        Toast.show('User data not found!', context,
            backgroundColor: Theme.of(context).accentColor,
            duration: Toast.LENGTH_LONG,
            gravity: Toast.CENTER,
            textColor: Colors.black,
            backgroundRadius: 80);
      }
  }
}
