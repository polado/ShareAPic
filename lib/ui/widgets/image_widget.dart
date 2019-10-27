import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_a_pic/blocs/images_bloc.dart';
import 'package:share_a_pic/models/image_model.dart';
import 'package:share_a_pic/models/user_model.dart';

class ImageWidget extends StatefulWidget {
  final ImageModel image;
  final UserModel user;

  const ImageWidget({Key key, this.image, this.user}) : super(key: key);

  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  bool isAddComment = false;
  String _likeActive = 'show',
      _likeInActive = 'hide';
  String _commentsActive = 'show', _commentsInActive = 'hide';
  String _infoActive = 'show', _infoInActive = 'hide';
  bool isLike = false,
      isSend = false,
      isInfo = false;
  String likeType = 'like';
  TextEditingController _textEditingController = new TextEditingController();

  bool emoji = false;

  GlobalKey _dataKey = new GlobalKey();

  String emojiString = 'assets/like.flr';

  emojiLike() async {
    print('islike $isLike');
    setState(() {
      isLike = true;
    });
    await imagesBloc.setLike(widget.image.id, widget.user, likeType);
  }

  addComment() async {
    if (_textEditingController.text != null &&
        _textEditingController.text
            .trim()
            .isNotEmpty &&
        _textEditingController.text.trim() != ' ') {
      print('comment if');
      imagesBloc.setComment(
          widget.image.id, widget.user, _textEditingController.text.trim());
      setState(() {
        isSend = true;
        _textEditingController.clear();
      });
    } else {
      print('comment else');
      setState(() {
        isSend = false;
      });
    }
  }

  toggleLike() async {
    print('islike $isLike');
    if (isLike) {
      setState(() {
        isLike = false;
//        likeType = 'like';
      });
      await imagesBloc.deleteLike(widget.image.id, widget.user);
    } else {
      setState(() {
        isLike = true;
      });
      await imagesBloc.setLike(widget.image.id, widget.user, likeType);
    }
  }

  setInfo() {
    setState(() {
      isInfo = !isInfo;
    });
  }

  setComments() {
    setState(() {
      isAddComment = !isAddComment;
      if (isAddComment)
        isSend = false;
      else
        isSend = true;
    });
  }

  Widget emojiWidget = FlareActor(
    'assets/like.flr',
    fit: BoxFit.scaleDown,
    shouldClip: false,
  );

  Widget like() {
    print('like $isLike');
    return FlareActor(
      'assets/like.flr',
      fit: BoxFit.scaleDown,
      shouldClip: false,
      animation:
      isLike
          ? 'show'
          : 'hide',
    );
  }

  Widget love() {
    print('love $isLike');
    return FlareActor(
      'assets/love.flr',
      fit: BoxFit.scaleDown,
      shouldClip: false,
      animation: isLike
          ? 'show'
          : 'hide',
    );
  }

  Widget monkey() {
    return FlareActor(
      'assets/monkey.flr',
      fit: BoxFit.scaleDown,
      shouldClip: false,
      animation: isLike
          ? _likeActive
          : _likeInActive,
    );
  }

  @override
  Widget build(BuildContext context) {
    print('${widget.image.time.toString()}');
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          StreamBuilder(
              stream: Firestore.instance
                  .collection('users')
                  .document(widget.image.userID)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData) {
                  widget.image.user = new UserModel(snapshot.data);
                  return AppBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    titleSpacing: 0,
                    primary: false,
                    leading: Container(
                      alignment: AlignmentDirectional.bottomEnd,
                      height: 25,
                      width: 25,
                      margin: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(width: 1, color: Colors.white54),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: CachedNetworkImageProvider(
                              '${widget.image.user.photoUrl}'),
                        ),
                      ),
                    ),
                    title: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text('${widget.image.user.name}'),
                        Padding(padding: EdgeInsets.only(top: 5)),
                        Text(
                          '${DateFormat('dd/MM/yy hh:mm a')
                              .format(new DateTime.fromMillisecondsSinceEpoch(
                              widget.image.time
                                  .toDate()
                                  .millisecondsSinceEpoch))}',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      Container(
                        height: 50,
                        width: 50,
                        padding: EdgeInsets.all(4),
                        margin: EdgeInsets.all(2),
                        child: IconButton(
                          onPressed: () => setInfo(),
                          icon: FlareActor(
                            'assets/info.flr',
                            shouldClip: false,
                            animation: isInfo ? _infoActive : _infoInActive,
                          ),
                        ),
                      ),
                    ],
                  );
                } else
                  return AppBar(
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    title: Text(
                      'Loading user data',
                      textAlign: TextAlign.center,
                    ),
                  );
              }),
          Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: <Widget>[
                      ClipRRect(
                        key: _dataKey,
                        borderRadius: new BorderRadius.circular(0),
                        child: CachedNetworkImage(
                          imageUrl: widget.image.url,
                          errorWidget: (context, url, v) {
                            return Container(
                              height: 150,
                              child: Icon(Icons.error),
                            );
                          },
                          placeholder: (context, url) {
                            return Container(
                              height: 150,
                              child: Center(child: CircularProgressIndicator()),
                            );
                          },
                        ),
                      ),
                      Visibility(
                        visible: emoji,
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                  8)),
                          child: Padding(padding: EdgeInsets.all(8),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        emojiWidget = like();
                                        emojiString = 'assets/like.flr';
                                        likeType = 'like';
                                        emoji = false;
                                        emojiLike();
                                      });
                                    },
                                    icon: Container(
                                      height: 50,
                                      width: 50,
                                      child: FlareActor(
                                        'assets/like.flr',
                                        fit: BoxFit.scaleDown,
                                        shouldClip: false,
                                        animation:
                                        isLike
                                            ? 'show'
                                            : 'hide',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        emojiWidget = love();
                                        emojiString = 'assets/love.flr';
                                        likeType = 'love';
                                        emoji = false;
                                        emojiLike();
                                      });
                                    },
                                    icon: Container(
                                      height: 50,
                                      width: 50,
                                      child: FlareActor(
                                        'assets/love.flr',
                                        fit: BoxFit.scaleDown,
                                        shouldClip: false,
                                        animation:
                                        isLike
                                            ? 'show'
                                            : 'hide',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        emojiWidget = monkey();
                                        emojiString = 'assets/monkey.flr';
                                        likeType = 'monkey';
                                        emoji = false;
                                        emojiLike();
                                      });
                                    },
                                    icon: Container(
                                      height: 50,
                                      width: 50,
                                      child: FlareActor(
                                        'assets/monkey.flr',
                                        fit: BoxFit.scaleDown,
                                        shouldClip: false,
                                        animation:
                                        isLike
                                            ? 'show'
                                            : 'hide',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        emojiWidget = monkey();
                                        emojiString = 'assets/in_love.flr';
                                        likeType = 'in_love';
                                        emoji = false;
                                        emojiLike();
                                      });
                                    },
                                    icon: Container(
                                      height: 50,
                                      width: 50,
                                      child: FlareActor(
                                        'assets/in_love.flr',
                                        fit: BoxFit.scaleDown,
                                        shouldClip: false,
                                        animation:
                                        isLike
                                            ? 'show'
                                            : 'hide',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        emojiWidget = monkey();
                                        emojiString = 'assets/kiss.flr';
                                        likeType = 'kiss';
                                        emoji = false;
                                        emojiLike();
                                      });
                                    },
                                    icon: Container(
                                      height: 50,
                                      width: 50,
                                      child: FlareActor(
                                        'assets/kiss.flr',
                                        fit: BoxFit.scaleDown,
                                        shouldClip: false,
                                        animation:
                                        isLike
                                            ? 'show'
                                            : 'hide',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        emojiWidget = monkey();
                                        emojiString = 'assets/lips.flr';
                                        likeType = 'lips';
                                        emoji = false;
                                        emojiLike();
                                      });
                                    },
                                    icon: Container(
                                      height: 50,
                                      width: 50,
                                      child: FlareActor(
                                        'assets/lips.flr',
                                        fit: BoxFit.scaleDown,
                                        shouldClip: false,
                                        animation:
                                        isLike
                                            ? 'show'
                                            : 'hide',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        emojiWidget = monkey();
                                        emojiString = 'assets/smile.flr';
                                        likeType = 'smile';
                                        emoji = false;
                                        emojiLike();
                                      });
                                    },
                                    icon: Container(
                                      height: 50,
                                      width: 50,
                                      child: FlareActor(
                                        'assets/smile.flr',
                                        fit: BoxFit.scaleDown,
                                        shouldClip: false,
                                        animation:
                                        isLike
                                            ? 'show'
                                            : 'hide',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        emojiWidget = monkey();
                                        emojiString = 'assets/thinking.flr';
                                        likeType = 'thinking';
                                        emoji = false;
                                        emojiLike();
                                      });
                                    },
                                    icon: Container(
                                      height: 50,
                                      width: 50,
                                      child: FlareActor(
                                        'assets/thinking.flr',
                                        fit: BoxFit.scaleDown,
                                        shouldClip: false,
                                        animation:
                                        isLike
                                            ? 'show'
                                            : 'hide',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        emojiWidget = monkey();
                                        emojiString = 'assets/wink.flr';
                                        likeType = 'wink';
                                        emoji = false;
                                        emojiLike();
                                      });
                                    },
                                    icon: Container(
                                      height: 50,
                                      width: 50,
                                      child: FlareActor(
                                        'assets/wink.flr',
                                        fit: BoxFit.scaleDown,
                                        shouldClip: false,
                                        animation:
                                        isLike
                                            ? 'show'
                                            : 'hide',
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        emojiWidget = monkey();
                                        emojiString = 'assets/wow.flr';
                                        likeType = 'wow';
                                        emoji = false;
                                        emojiLike();
                                      });
                                    },
                                    icon: Container(
                                      height: 50,
                                      width: 50,
                                      child: FlareActor(
                                        'assets/wow.flr',
                                        fit: BoxFit.scaleDown,
                                        shouldClip: false,
                                        animation:
                                        isLike
                                            ? 'show'
                                            : 'hide',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: StreamBuilder(
                          stream: Firestore.instance
                              .collection('images')
                              .document(widget.image.id)
                              .collection('likes')
                              .orderBy('time', descending: true)
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasData) {
                              print(
                                  'data like ${snapshot.data.documents.toString()}');
                              if (snapshot.data.documents.length == 0) {
                                isLike = false;
                              }
                              else {
                                bool isLike = false;
                                snapshot.data.documents.forEach((d) {
                                  if (d.documentID == widget.user.userID) {
                                    isLike = true;
                                    switch (d.data['type']) {
                                      case 'like':
                                        likeType = 'like';
                                        break;
                                      case 'love':
                                        likeType = 'love';
                                        break;
                                      case 'monkey':
                                        likeType = 'monkey';
                                        break;
                                      case 'in_love':
                                        likeType = 'in_love';
                                        break;
                                      case 'kiss':
                                        likeType = 'kiss';
                                        break;
                                      case 'lips':
                                        likeType = 'lips';
                                        break;
                                      case 'smile':
                                        likeType = 'smile';
                                        break;
                                      case 'thinking':
                                        likeType = 'thinking';
                                        break;
                                      case 'wink':
                                        likeType = 'wink';
                                        break;
                                      case 'wow':
                                        likeType = 'wow';
                                        break;
                                    }
                                  }
                                });
                                this.isLike = isLike;
                              }
                              print('liketype $likeType');
                              switch (likeType) {
                                case 'like':
                                  emojiString = 'assets/like.flr';
                                  break;
                                case 'love':
                                  emojiString = 'assets/love.flr';
                                  break;
                                case 'monkey':
                                  emojiString = 'assets/monkey.flr';
                                  break;
                                case 'in_love':
                                  emojiString = 'assets/in_love.flr';
                                  break;
                                case 'kiss':
                                  emojiString = 'assets/kiss.flr';
                                  break;
                                case 'lips':
                                  emojiString = 'assets/lips.flr';
                                  break;
                                case 'smile':
                                  emojiString = 'assets/smile.flr';
                                  break;
                                case 'thinking':
                                  emojiString = 'assets/thinking.flr';
                                  break;
                                case 'wink':
                                  emojiString = 'assets/wink.flr';
                                  break;
                                case 'wow':
                                  emojiString = 'assets/wow.flr';
                                  break;
                              }
                              print('islike $isLike');
                              print('emojiwidget $likeType');
                              return GestureDetector(
                                onLongPress: () {
                                  setState(() {
                                    emoji = !emoji;
                                  });
                                },
                                child: FlatButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      if (emoji) emoji = false;
                                    });
                                    toggleLike();
                                  },
                                  icon: Container(
                                    height: 50,
                                    width: 50,
                                    child: FlareActor(
                                      emojiString,
                                      fit: BoxFit.scaleDown,
                                      shouldClip: false,
                                      animation:
                                      isLike
                                          ? 'show'
                                          : 'hide',
                                    ),
                                  ),
                                  label: Text(
                                    '${snapshot.data.documents.length}',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            } else
                              return Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder(
                          stream: Firestore.instance
                              .collection('images')
                              .document(widget.image.id)
                              .collection('comments')
                              .orderBy('time', descending: true)
                              .snapshots(), builder: (BuildContext context,
                            AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            return FlatButton.icon(
                              onPressed: () => setComments(),
                              icon: Container(
                                height: 50,
                                width: 50,
                                padding: EdgeInsets.all(4),
                                margin: EdgeInsets.all(2),
                                child: FlareActor(
                                  'assets/comments_white.flr',
                                  shouldClip: false,
                                  fit: BoxFit.scaleDown,
                                  animation: isAddComment
                                      ? _commentsActive
                                      : _commentsInActive,
                                ),
                              ),
                              label: Text('${snapshot.data.documents.length}',
                                textAlign: TextAlign.center,),
                            );
                          }
                          else
                            return Center(child: CircularProgressIndicator());
                        },),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: isAddComment,
                    child: commentInput(),
                  ),
                ],
              ),
              Visibility(
                  visible: isInfo,
                  child: panel()),
            ],
          ),
        ],
      ),
    );
  }

  Widget panel() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('images')
            .document(widget.image.id)
            .collection('likes')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (BuildContext context,
            AsyncSnapshot<QuerySnapshot> likeSnapshot) {
          if (likeSnapshot.hasData)
            return likeSnapshot.data.documents == null ||
                likeSnapshot.data.documents.length == 0 ?
            Card(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No Likes',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ) :
            Card(
              child: ListView.builder(
                shrinkWrap: true,
                padding: EdgeInsets.all(0),
                itemCount: likeSnapshot.data.documents.length,
                itemBuilder: (context, index) {
                  return Container(
                    child: StreamBuilder(
                      stream: Firestore.instance.collection('users')
                          .document(
                          likeSnapshot.data.documents[index].documentID)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                        if (userSnapshot.hasData) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  width: 50,
                                  height: 50,
                                  child: FlareActor(
                                    'assets/${likeSnapshot.data
                                        .documents[index]['type']}.flr',
                                    fit: BoxFit.scaleDown,
                                    shouldClip: false,
                                    animation:
                                    'show',
                                  ),
                                ),
                                Text(userSnapshot.data['name'],
                                  style: TextStyle(fontSize: 18),
                                ),
                                Expanded(
                                  child: Text(
                                    '${DateFormat('dd/MM/yy hh:mm a').format(
                                        new DateTime.fromMillisecondsSinceEpoch(
                                            likeSnapshot.data
                                                .documents[index]['time']
                                                .toDate()
                                                .millisecondsSinceEpoch))}',
                                    textAlign: TextAlign.end,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                                Padding(padding: EdgeInsets.only(right: 16)),
                              ],
                            ),
                          );
                        } else
                          return Center(child: CircularProgressIndicator());
                      },
                    ),
                  );
                },
              ),
            );
          else
            return Center(child: CircularProgressIndicator());
        });
  }

  Widget commentInput() {
    return Column(
      children: <Widget>[
        StreamBuilder(
            stream: Firestore.instance
                .collection('images')
                .document(widget.image.id)
                .collection('comments')
                .orderBy('time', descending: true)
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<QuerySnapshot> commentsSnapshot) {
              if (commentsSnapshot.hasData)
                return commentsSnapshot.data.documents == null ||
                    commentsSnapshot.data.documents.length == 0 ?
                Card(
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No Comments',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ) : ListView.builder(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(0),
                    itemCount: commentsSnapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      return Container(
                        child: StreamBuilder(
                          stream: Firestore.instance.collection('users')
                              .document(
                              commentsSnapshot.data.documents[index]['user'])
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<DocumentSnapshot> userSnapshot) {
                            if (userSnapshot.hasData) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Container(
                                      alignment: AlignmentDirectional.bottomEnd,
                                      height: 16,
                                      width: 16,
                                      margin: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            width: 1, color: Colors.white54),
                                        image: DecorationImage(
                                          fit: BoxFit.cover,
                                          image: CachedNetworkImageProvider(
                                              '${userSnapshot.data['photo']}'),
                                        ),
                                      ),
                                    ),
                                    Text('${commentsSnapshot.data
                                        .documents[index]['comment']}',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Expanded(
                                      child: Text(
                                        '${DateFormat('dd/MM/yy hh:mm a')
                                            .format(
                                            new DateTime
                                                .fromMillisecondsSinceEpoch(
                                                commentsSnapshot.data
                                                    .documents[index]['time']
                                                    .toDate()
                                                    .millisecondsSinceEpoch))}',
                                        textAlign: TextAlign.end,
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                    Padding(
                                        padding: EdgeInsets.only(right: 16)),
                                  ],
                                ),
                              );
                            } else
                              return Center(child: CircularProgressIndicator());
                          },
                        ),
                      );
                    }); else
                return Center(child: CircularProgressIndicator());
            }),
        Padding(
          padding: EdgeInsets.all(4),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    maxLines: 3,
                    minLines: 1,
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      hintText: 'Enter Comment',
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Card(
                clipBehavior: Clip.hardEdge,
                elevation: 0,
                margin: EdgeInsets.all(4),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
                child:
                Container(
                  height: 40,
                  width: 40,
                  padding: EdgeInsets.all(2),
                  margin: EdgeInsets.all(2),
                  child: IconButton(
                    onPressed: () {
                      print('comment send');
                      addComment();
                    },
                    icon: FlareActor(
                      'assets/send.flr',
                      shouldClip: false,
                      animation: isSend ? 'send' : 'open',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}