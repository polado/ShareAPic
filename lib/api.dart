import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:share_a_pic/models/image_model.dart';
import 'package:share_a_pic/models/user_model.dart';

class FireBaseAPi {
  Future<List<ImageModel>> getImages() async {
    print('api getimages');
    QuerySnapshot result = await Firestore.instance
        .collection("images")
        .orderBy('time')
        .getDocuments();
    List<DocumentSnapshot> images = result.documents;
    print('api getimages ${images.length}');
    List<ImageModel> list = new List();
    for (int i = 0; i < images.length; i++) {
      ImageModel image = new ImageModel(images[i]);
      image.user = await getUser(image.userID);
      list.add(image);
      print('${list.length}');
    }
//    images.forEach((i) async {
//      ImageModel image = new ImageModel(i);
//      image.user = await getUser(image.userID);
//      list.add(image);
//      print('${list.length}');
//    });
    list = list.reversed.toList();
    print('api getimages ${list.toString()}');
    return list;
  }

  Future<UserModel> getUser(String uid) async {
    print('api getuser $uid');
    DocumentSnapshot snapshot =
        await Firestore.instance.collection('users').document(uid).get();
    UserModel user = new UserModel(snapshot);
    return user;
  }
}
