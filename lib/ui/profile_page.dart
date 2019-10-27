import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:share_a_pic/models/image_model.dart';
import 'package:share_a_pic/models/user_model.dart';
import 'package:share_a_pic/ui/widgets/image_widget.dart';

class ProfilePage extends StatefulWidget {
  final UserModel user;

  const ProfilePage({Key key, this.user}) : super(key: key);
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  List<ImageModel> images = new List();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(),
    );
  }

  Widget body() {
    return Container(
      child: StreamBuilder(
          stream: Firestore.instance
              .collection("images")
              .where('user', isEqualTo: widget.user.userID)
              .orderBy('time', descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return Container(
                  child: ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      padding: EdgeInsets.only(bottom: 80),
                      itemBuilder: (context, index) =>
                          ImageWidget(
                            image:
                            new ImageModel(snapshot.data.documents[index]),
                            user: widget.user,
                          ))
              );
            } else {
              return Center(child: CircularProgressIndicator());
            }
          }),
    );
  }
}
