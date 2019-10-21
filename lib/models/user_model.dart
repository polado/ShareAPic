import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String email;
  String name;
  String userID;
  String photoUrl;

  UserModel(DocumentSnapshot snapshot) {
    email = snapshot['email'];
    name = snapshot['name'];
    photoUrl = snapshot['photo'];
    userID = snapshot.documentID;
  }
  UserModel.empty();
}
