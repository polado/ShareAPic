import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:rxdart/rxdart.dart';
import 'package:share_a_pic/models/image_model.dart';
import 'package:share_a_pic/models/user_model.dart';

import 'repository.dart';

class ImagesBloc {
  final _repository = Repository();
  final _imagesFetcher = PublishSubject<List<ImageModel>>();

  List<ImageModel> images = new List();

  Observable<List<ImageModel>> get allImages => _imagesFetcher.stream;

  getImages() async {
    List<ImageModel> images = await _repository.getImages();
    print('ImagesBloc getImages ${images.toString()}');
    this.images = images;
    _imagesFetcher.sink.add(images);
  }

  setLike(String imageID, UserModel user) async {
    Timestamp time = Timestamp.now();
    await Firestore.instance
        .collection('images')
        .document(imageID)
        .collection('likes')
        .document(user.userID)
        .setData({'user': user.userID, 'time': time});
  }

  deleteLike(String imageID, UserModel user) async {
    await Firestore.instance
        .collection('images')
        .document(imageID)
        .collection('likes')
        .document(user.userID)
        .delete();
  }

  setLove(String imageID, UserModel user) async {
    Timestamp time = Timestamp.now();
    await Firestore.instance
        .collection('images')
        .document(imageID)
        .collection('loves')
        .document(user.userID)
        .setData({'user': user.userID, 'time': time});
  }

  deleteLove(String imageID, UserModel user) async {
    await Firestore.instance
        .collection('images')
        .document(imageID)
        .collection('loves')
        .document(user.userID)
        .delete();
  }

  postImage(UserModel user, image) async {
    Timestamp time = Timestamp.now();
    StorageUploadTask task = FirebaseStorage.instance
        .ref()
        .child('post/${user.userID}-${time.toString()}')
        .putFile(image);
    StorageTaskSnapshot snapshot = await task.onComplete;
    String url = await snapshot.ref.getDownloadURL();
    print('pathh $url');
    await Firestore.instance
        .collection('images')
        .document()
        .setData({'time': time, 'url': url, 'user': user.userID});
//    images.insert(
//        0, new ImageModel.raw(time: time, url: url, userID: user.uid));
//    _imagesFetcher.sink.add(images);

    return true;
  }

  updateImage(UserModel user, String name, image) async {
    if (image != null) {
      StorageUploadTask task = FirebaseStorage.instance
          .ref()
          .child('profile-img-${user.userID}')
          .putFile(image);
      StorageTaskSnapshot snapshot = await task.onComplete;
      String url = await snapshot.ref.getDownloadURL();
      await Firestore.instance
          .collection('users')
          .document(user.userID)
          .setData({'photo': url, 'email': user.email, 'name': name});
    } else {
      await Firestore.instance
          .collection('users')
          .document(user.userID)
          .setData({'photo': user.photoUrl, 'email': user.email, 'name': name});
    }
    return true;
  }

  updateName(UserModel user, String name) async {
    await Firestore.instance
        .collection('users')
        .document(user.userID)
        .setData({'photo': user.photoUrl, 'email': user.email, 'name': name});
    return true;
  }

  dispose() {
    _imagesFetcher.close();
  }
}

final imagesBloc = ImagesBloc();
