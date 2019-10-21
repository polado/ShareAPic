import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_a_pic/blocs/images_bloc.dart';
import 'package:share_a_pic/models/user_model.dart';
import 'package:toast/toast.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;

  const ProfilePage({Key key, this.user}) : super(key: key);

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  TextEditingController nameController = new TextEditingController();
  File selectedImage;
  UserModel user = UserModel.empty();

  @override
  void initState() {
    super.initState();
    print('profile ${widget.user}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        leading: IconButton(
            icon: Icon(Icons.clear), onPressed: () => Navigator.pop(context)),
        actions: <Widget>[
          IconButton(icon: Icon(Icons.check), onPressed: () => submit()),
        ],
      ),
      body: StreamBuilder(
          stream: Firestore.instance
              .collection('users')
              .document(widget.user.userID)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (snapshot.hasData) {
              user = UserModel(snapshot.data);
              nameController.text = user.name;
              return ListView(
                children: <Widget>[
                  profilePic(),
                  name(),
                ],
              );
            } else
              return Center(child: CircularProgressIndicator());
          }),
    );
  }

  Widget profilePic() {
    return Container(
      alignment: AlignmentDirectional.center,
      height: 75,
      width: 75,
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: InkWell(
        onTap: () {
          selectImage();
        },
        child: Container(
          alignment: AlignmentDirectional.bottomEnd,
          height: 75,
          width: 75,
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.white54),
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.cover,
              image: selectedImage == null
                  ? CachedNetworkImageProvider('${user.photoUrl}')
                  : FileImage(selectedImage),
            ),
          ),
        ),
      ),
    );
  }

  Widget name() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'Full Name',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          Padding(padding: EdgeInsets.only(top: 4)),
          TextField(
            controller: nameController,
            decoration: InputDecoration(
              hintText: 'Enter name here.',
              border: UnderlineInputBorder(),
              focusedBorder: UnderlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  void selectImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      selectedImage = image;
    });
  }

  submit() async {
    Toast.show('Updating your data', context,
        backgroundColor: Theme.of(context).accentColor,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER,
        textColor: Colors.black,
        backgroundRadius: 8);
    bool d =
        await imagesBloc.updateImage(user, nameController.text, selectedImage);
    print('donr $d');
    Toast.show('Updated', context,
        backgroundColor: Theme.of(context).accentColor,
        duration: Toast.LENGTH_LONG,
        gravity: Toast.CENTER,
        textColor: Colors.black,
        backgroundRadius: 8);
    if (d) Navigator.pop(context);
  }
}
