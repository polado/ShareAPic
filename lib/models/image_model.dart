import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_a_pic/models/user_model.dart';

class ImageModel {
  Timestamp time;
  String url;
  String userID;
  String id;

  UserModel user = new UserModel.empty();

  ImageModel(DocumentSnapshot snapshot) {
    time = snapshot['time'];
    url = snapshot['url'];
    userID = snapshot['user'];
    id = snapshot.documentID;
  }

  ImageModel.raw({this.time, this.url, this.userID});
}
