import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_a_pic/models/user_model.dart';

class UserBloc {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel user = UserModel.empty();
  FirebaseUser firebaseUser;
  String userToken;

  updateToken(FirebaseUser user, String token) async {
    print('update token $token ${user.uid}');
    await Firestore.instance.collection('users').document(user.uid).updateData({
      'token': token,
    });
    return true;
  }

  emailPasswordLogin(String email, String password) async {
    try {
      AuthResult result = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      firebaseUser = user;
      userBloc.updateToken(user, userToken);
      print('login ${result.toString()}');
      return true;
    } catch (e) {
      print('errorss $e');
      return false;
    }
  }

  emailPasswordSignUp(String email, String password, String name) async {
    try {
      AuthResult result = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      FirebaseUser user = result.user;
      UserUpdateInfo info = new UserUpdateInfo();
      info.displayName = name;
      info.photoUrl =
          'https://firebasestorage.googleapis.com/v0/b/sendapic-82cc3.appspot.com/o/bestseller.jpg?alt=media&token=803e66c6-2be5-4b96-aa8b-c50c1d084045';
      user.updateProfile(info);
      await updateUser(user, name);
      print('sign up ${result.toString()}');
      return true;
    } catch (e) {
      print('errorss $e');
      return false;
    }
  }

  updateUser(FirebaseUser user, String name) async {
    final QuerySnapshot result = await Firestore.instance
        .collection('users')
        .where('id', isEqualTo: user.uid)
        .getDocuments();
    final List<DocumentSnapshot> documents = result.documents;
    if (documents.length == 0)
      await Firestore.instance.collection('users').document(user.uid).setData({
        'email': user.email,
        'name': name,
        'id': user.uid,
        'token': userToken,
        'photo':
            'https://firebasestorage.googleapis.com/v0/b/chat-app-368e8.appspot.com/o/avatar_icon_star_wars.jpg?alt=media&token=5725b940-8920-41b0-a898-18cd7f62de6d'
      });
    else
      await Firestore.instance
          .collection('users')
          .document(user.uid)
          .updateData({
        'token': userToken,
      });
    firebaseUser = user;
    return true;
  }
}

final userBloc = UserBloc();
