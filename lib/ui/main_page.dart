import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:share_a_pic/blocs/images_bloc.dart';
import 'package:share_a_pic/models/user_model.dart';
import 'package:share_a_pic/ui/edit_profile_page.dart';
import 'package:share_a_pic/ui/home_page.dart';
import 'package:share_a_pic/ui/profile_page.dart';

class MainPage extends StatefulWidget {
  final FirebaseUser user;

  const MainPage({Key key, this.user}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  UserModel user = UserModel.empty();

  PageController _pageController =
      new PageController(initialPage: 0, keepPage: true);

  String _title = 'Home';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$_title'),
        centerTitle: true,
        actions: <Widget>[
          menu(),
        ],
      ),
      extendBody: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Expanded(
              child: IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
                    _pageController.animateToPage(0,
                        duration: Duration(milliseconds: 100),
                        curve: Curves.easeInOut);
                    setState(() {
                      _title = 'Home';
                    });
                  }),
            ),
            Expanded(
                child: Divider(
              color: Colors.transparent,
            )),
            Expanded(
              child: IconButton(
                  icon: Icon(Icons.account_circle),
                  onPressed: () {
                    _pageController.animateToPage(1,
                        duration: Duration(milliseconds: 100),
                        curve: Curves.easeInOut);
                    setState(() {
                      _title = 'Profile';
                    });
                  }),
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(builder: (BuildContext context) {
        return FloatingActionButton(
          onPressed: () {
//            Scaffold.of(context)
//                .showSnackBar(new SnackBar(content: new Text('Hello!')));
            selectImage(context);
          },
          child: Icon(Icons.add_photo_alternate),
        );
      }),
      body: body(),
    );
  }

  Widget body() {
    return Container(
      child: StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(widget.user.uid)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              user = UserModel(snapshot.data);
              return PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageController,
                children: <Widget>[
                  HomePage(user: user),
                  ProfilePage(user: user),
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }

  Widget menu() {
    return PopupMenuButton<int>(
      padding: EdgeInsets.all(0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      onSelected: (value) {
        switch (value) {
          case 1:
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EditProfilePage(
                          user: user,
                        )));
            break;
          case 2:
            break;
          case 3:
            _logout();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Row(
            children: <Widget>[
              IconButton(icon: Icon(Icons.account_circle), onPressed: null),
              Expanded(child: Text("Edit Profile"))
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: <Widget>[
              IconButton(icon: Icon(Icons.settings), onPressed: null),
              Expanded(child: Text("Settings"))
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: <Widget>[
              IconButton(icon: Icon(Icons.exit_to_app), onPressed: null),
              Expanded(child: Text("Logout"))
            ],
          ),
        ),
      ],
    );
  }

  selectImage(BuildContext context) async {
    print('uploading ${widget.user.toString()}');
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    print('uploading img $image');
    ProgressDialog pr = new ProgressDialog(context,
        type: ProgressDialogType.Normal,
        isDismissible: false,
        showLogs: false);
    pr.style(
        progressWidget: Center(child: CircularProgressIndicator()),
        message: 'Uploading...',
        borderRadius: 8);
    if (image != null) {
      pr.show();
      await imagesBloc.postImage(user, image);
      pr.dismiss();
    }
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      print(e);
    }
  }
}
