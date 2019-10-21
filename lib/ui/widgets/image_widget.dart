import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share_a_pic/blocs/images_bloc.dart';
import 'package:share_a_pic/models/image_model.dart';
import 'package:share_a_pic/models/user_model.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class ImageWidget extends StatefulWidget {
  final ImageModel image;
  final UserModel user;

  const ImageWidget({Key key, this.image, this.user}) : super(key: key);

  @override
  _ImageWidgetState createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  bool isAddComment = false, isLove = false;
  String _heartActive = 'love', _heartInActive = 'unlove';
  String _likeActive = 'like', _likeInActive = 'dislike';
  String _commentsActive = 'show', _commentsInActive = 'hide';
  String _infoActive = 'show', _infoInActive = 'hide';
  bool isHeart = false, isLike = false, isSend = false, isInfo = false;

  PanelController _panelController = new PanelController();

  GlobalKey _dataKey = new GlobalKey();

  setHeart() async {
    if (isHeart) {
      setState(() {
        isHeart = false;
      });
      await imagesBloc.deleteLove(widget.image.id, widget.user);
    } else {
      setState(() {
        isHeart = true;
      });
      await imagesBloc.setLove(widget.image.id, widget.user);
    }
  }

  setLike() async {
    print('islike $isLike');
    if (isLike) {
      setState(() {
        isLike = false;
      });
      await imagesBloc.deleteLike(widget.image.id, widget.user);
    } else {
      setState(() {
        isLike = true;
      });
      await imagesBloc.setLike(widget.image.id, widget.user);
    }
  }

  setInfo() {
    setState(() {
      isInfo = !isInfo;
      if (isInfo)
        _panelController.open();
      else
        _panelController.close();
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
                          '${DateFormat('dd/MM/yy hh:mm a').format(new DateTime.fromMillisecondsSinceEpoch(widget.image.time.toDate().millisecondsSinceEpoch))}',
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Expanded(
                        child: StreamBuilder(
                          stream: Firestore.instance
                              .collection('images')
                              .document(widget.image.id)
                              .collection('likes')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasData) {
                              print(
                                  'data like ${snapshot.data.documents.toString()}');
                              if (snapshot.data.documents.length == 0)
                                isLike = false;
                              else {
                                bool like = false;
                                snapshot.data.documents.forEach((d) {
                                  if (d.documentID == widget.user.userID)
                                    like = true;
                                });
                                isLike = like;
                              }
                              return FlatButton.icon(
                                onPressed: () => setLike(),
                                icon: Container(
                                    height: 50,
                                    width: 50,
                                    child: FlareActor(
                                      'assets/thumb_up_white.flr',
                                      fit: BoxFit.scaleDown,
                                      shouldClip: false,
                                      animation:
                                          isLike ? _likeActive : _likeInActive,
                                    )),
                                label: Text(
                                  '${snapshot.data.documents.length}',
                                  textAlign: TextAlign.center,
                                ),
                              );
                            } else
                              return Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 50,
                          width: 50,
                          padding: EdgeInsets.all(4),
                          margin: EdgeInsets.all(2),
                          child: IconButton(
                            onPressed: () => setComments(),
                            icon: FlareActor(
                              'assets/comments_white.flr',
                              shouldClip: false,
                              animation: isAddComment
                                  ? _commentsActive
                                  : _commentsInActive,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: StreamBuilder(
                          stream: Firestore.instance
                              .collection('images')
                              .document(widget.image.id)
                              .collection('loves')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data.documents.length == 0)
                                isHeart = false;
                              else {
                                bool love = false;
                                snapshot.data.documents.forEach((d) {
                                  if (d.documentID == widget.user.userID)
                                    love = true;
                                });
                                isHeart = love;
                              }
                              return FlatButton.icon(
                                onPressed: () => setHeart(),
                                icon: Container(
                                    height: 50,
                                    width: 50,
                                    child: FlareActor(
                                      'assets/love_white.flr',
                                      fit: BoxFit.scaleDown,
                                      shouldClip: false,
                                      animation: isHeart
                                          ? _heartActive
                                          : _heartInActive,
                                    )),
                                label: Text(
                                  '${snapshot.data.documents.length}',
                                  textAlign: TextAlign.center,
                                ),
                              );
                            } else
                              return Center(child: CircularProgressIndicator());
                          },
                        ),
                      ),
                    ],
                  ),
                  Visibility(
                    visible: isAddComment,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: TextField(
                              maxLines: 3,
                              minLines: 1,
                              decoration: InputDecoration(
                                hintText: 'Enter Comment',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 50,
                          width: 50,
                          padding: EdgeInsets.all(4),
                          margin: EdgeInsets.all(2),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                isSend = !isSend;
                              });
                            },
                            icon: FlareActor(
                              'assets/send.flr',
                              shouldClip: false,
                              animation: isSend ? 'send' : 'open',
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              FractionallySizedBox(
                child: SlidingUpPanel(
                  minHeight: 0,
                  maxHeight: 300,
                  defaultPanelState: PanelState.CLOSED,
                  controller: _panelController,
                  isDraggable: false,
                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  panel: Container(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  double getHeight() {
    final RenderBox renderBoxRed = _dataKey.currentContext.findRenderObject();
    final sizeRed = renderBoxRed.size.height;
    return sizeRed;
  }
}
