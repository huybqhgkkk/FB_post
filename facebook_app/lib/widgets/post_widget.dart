import 'package:facebook_app/data/model/post.dart';
import 'package:facebook_app/data/repository/user_repository_impl.dart';
import 'package:facebook_app/view/profile_friend.dart';
import 'package:facebook_app/view/profile_me.dart';
import 'package:facebook_app/viewmodel/home_view_model.dart';
import 'package:facebook_app/widgets/edit_post.dart';
import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:facebook_app/widgets/photo_grid.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'comment_widget.dart';
import 'black_background_image.dart';
import 'post_detail.dart';
import 'package:facebook_app/ultils/string_ext.dart';
import 'package:meta/meta.dart';
import 'dart:ui' as ui;
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart' as intl;


class PostWidget extends StatelessWidget {
  final Post post;
  final HomeProvide provide;
  VideoPlayerController controller;
  Future<void> initializeVideoPlayerFuture;

  PostWidget createState() => PostWidget();

  PostWidget({this.post, this.provide});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Container(
            color: Colors.grey[400],
            width: MediaQuery.of(context).size.width,
            height: 11.0,
          ),
          Container(
              padding: EdgeInsets.all(15),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          if (post.owner.id == UserRepositoryImpl.currentUser.id) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ProfileMe()),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfileFriend(post.owner)),
                            );
                          }
                        },
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(post.owner.avatar),
                          radius: 20.0,
                        ),
                      ),
                      SizedBox(width: 7.0),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                            onTap: () {
                              if (post.owner.id ==
                                  UserRepositoryImpl.currentUser.id) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ProfileMe()),
                                );
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ProfileFriend(post.owner)),
                                );
                              }
                            },
                            child: Row(
                              children: [
                                Text(
                                    post.owner.firstName + ' ' + post.owner.lastName,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold, fontSize: 17.0)),
                                SizedBox(
                                  width: 5.0,
                                ),
                                Icon(
                                  Icons.check_circle,
                                  size: 15,
                                  color: Colors.blueAccent,
                                )
                              ],
                            ),
                          ),
                          SizedBox(height: 5.0),
                          Text(fix(post.modified))
                        ],
                      ),
                    ],
                  ),
                  buildMenu(context),
                ],
              )
          ),
          SizedBox(height: 5.0),
          GestureDetector(
            // onTap: () {
            //   showMaterialModalBottomSheet(
            //       context: context,
            //       builder: (context) => CreateCommentWidget(
            //             provide: provide,
            //             post: post,
            //           ));
            // },
            child: ExpandableText(
              post.described.getMyText(),
              trimLines: 2,
            ),

            // child: Padding(
            //   padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            //   child: Container(
            //       alignment: Alignment.centerLeft,
            //       child: Linkify(
            //         onOpen: (link) async {
            //           if (await canLaunch(link.url)) {
            //             await launch(link.url);
            //           } else {
            //             throw 'Could not launch $link';
            //           }
            //         },
            //         text:post.described.getMyText(),
            //         //textAlign: TextAlign.left,
            //         linkStyle: TextStyle( fontSize: 15.0,color: Colors.black),
            //       ),
            //           //Text(post.described.getMyText(), style: TextStyle(fontSize: 15.0)
            //           )
            // ),
          ),
          SizedBox(height: 10.0),
          buildImages(context),
          buildVideos(context),
          SizedBox(height: 10.0),
          // Container(
          //   padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //     children: <Widget>[
          //       Row(
          //         children: <Widget>[
          //           Icon(FontAwesomeIcons.thumbsUp,
          //               size: 12.0, color: Colors.blue),
          //           Text(' ${post.likes.length}'),
          //         ],
          //       ),
          //       Row(
          //         children: <Widget>[
          //           GestureDetector(
          //             onTap: () {
          //               showMaterialModalBottomSheet(
          //                 context: context,
          //                 backgroundColor: Colors.transparent,
          //                 builder: (context) => CreateCommentWidget(
          //                   provide: provide,
          //                   post: post,
          //                 ),
          //               );
          //             },
          //             child: Text('${post.comments.length} comments'),
          //           ),
          //
          //           // Text('${post.shares} shares'), // so luong share
          //         ],
          //       ),
          //     ],
          //   ),
          // ),
          Divider(height: 20.0),
          // buildBottom(context, post),
        ],
      ),
    );
  }

  Visibility buildImages(BuildContext context) {
    if (post.images.length == 1) {
      return Visibility(
        visible: true,
        child: GestureDetector(
            onTap: () {
              showMaterialModalBottomSheet(
                  context: context,
                  builder: (context) => BlackBackgroundScreen(
                      provide: provide, post: post, index: 0));
            },
            child: Image.network(post.images[0])),
      );
    } else if (post.images.length % 2 == 0) {
      return Visibility(
        visible: post.images.length > 0,
        child: PhotoGrid(
          imageUrls: post.images,
          onImageClicked: (i) => showMaterialModalBottomSheet(
              context: context,
              builder: (context) => BlackBackgroundScreen(
                  provide: provide, post: post, index: i)),
          maxImages: 4,
        ),
      );
    } else if (post.images.length == 3) {
      return Visibility(
          visible: true,
          child: Row(
            children: [
              GestureDetector(
                onTap: () {
                  showMaterialModalBottomSheet(
                      context: context,
                      builder: (context) => BlackBackgroundScreen(
                          provide: provide, post: post, index: 0));
                },
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height / 2,
                    width: MediaQuery.of(context).size.width / 2 - 4,
                    child: Image.network(post.images[0], fit: BoxFit.cover),
                  ),
                ),
              ),
              Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      showMaterialModalBottomSheet(
                          context: context,
                          builder: (context) => BlackBackgroundScreen(
                              provide: provide, post: post, index: 1));
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 4,
                        width: MediaQuery.of(context).size.width / 2 - 4,
                        child: Image.network(post.images[1], fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      showMaterialModalBottomSheet(
                          context: context,
                          builder: (context) => BlackBackgroundScreen(
                              provide: provide, post: post, index: 2));
                    },
                    child: Container(
                      height: MediaQuery.of(context).size.height / 4,
                      width: MediaQuery.of(context).size.width / 2 - 4,
                      child: Image.network(post.images[2], fit: BoxFit.cover),
                    ),
                  ),
                ],
              ),
            ],
          ));
    }
  }

  // buildBottom(BuildContext context, Post post) {
  //   if (provide.checkFriend(post.owner.id))
  //     return buildBottomLikeFriend(context);
  //   return buildBottomLikeNoFriend(context);
  // }

  // buildBottomLikeFriend(BuildContext context) {
  //   return Container(
  //     padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: <Widget>[
  //         FlatButton(
  //           onPressed: () => {provide.updateLike(post)},
  //           Row
  //             // Replace with a Row for horizontal icon + text
  //             children: <Widget>[
  //               Icon(FontAwesomeIcons.thumbsUp,
  //                   size: 20.0,
  //                   color: !post.isLiked ? Colors.grey : Colors.blue),
  //               SizedBox(width: 5.0),
  //               Text(
  //                 'Like',
  //                 style: TextStyle(
  //                     fontSize: 14,
  //                     color: !post.isLiked ? Colors.grey : Colors.blue),
  //               )
  //             ],
  //           ),
  //         ),
  //         FlatButton(
  //           onPressed: () => {
  //             showMaterialModalBottomSheet(
  //               context: context,
  //               backgroundColor: Colors.transparent,
  //               builder: (context) => CreateCommentWidget(
  //                 provide: provide,
  //                 post: post,
  //               ),
  //             )
  //           },
  //           child: Row(
  //             // Replace with a Row for horizontal icon + text
  //             children: <Widget>[
  //               Icon(FontAwesomeIcons.commentAlt,
  //                   size: 20.0, color: Colors.grey),
  //               SizedBox(width: 5.0),
  //               Text('Comment',
  //                   style: TextStyle(fontSize: 14.0, color: Colors.grey)),
  //             ],
  //           ),
  //         ),
  //         Row(
  //           children: <Widget>[
  //             Icon(FontAwesomeIcons.share, size: 15.0, color: Colors.grey),
  //             SizedBox(width: 5.0),
  //             Text('Share',
  //                 style: TextStyle(fontSize: 14.0, color: Colors.grey)),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // buildBottomLikeNoFriend(BuildContext context) {
  //   return Container(
  //     padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
  //     child: Row(
  //       mainAxisAlignment: MainAxisAlignment.spaceAround,
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: <Widget>[
  //         FlatButton(
  //           onPressed: () => {provide.updateLike(post)},
  //           child: Row(
  //             // Replace with a Row for horizontal icon + text
  //             children: <Widget>[
  //               Icon(FontAwesomeIcons.thumbsUp,
  //                   size: 20.0,
  //                   color: !post.isLiked ? Colors.grey : Colors.blue),
  //               SizedBox(width: 5.0),
  //               Text(
  //                 'Like',
  //                 style: TextStyle(
  //                     fontSize: 14,
  //                     color: !post.isLiked ? Colors.grey : Colors.blue),
  //               )
  //             ],
  //           ),
  //         ),
  //         Row(
  //           children: <Widget>[
  //             Icon(FontAwesomeIcons.share, size: 20.0, color: Colors.grey),
  //             SizedBox(width: 5.0),
  //             Text('Share',
  //                 style: TextStyle(fontSize: 14.0, color: Colors.grey)),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  String fix(String text1) {
    var now = (new DateTime.now()).millisecondsSinceEpoch;
    var format = new DateFormat('yyyy-MM-dd HH:mm:ss');
    DateTime baiDang = format.parse(text1);
    var timeago = baiDang.millisecondsSinceEpoch;
    var timeagov1 = (now - timeago) / 1000;
    timeagov1 = (timeagov1 / 60 + 1);
    if (timeagov1 < 60) {
      String a = timeagov1.toStringAsFixed(0);
      return "$a ph??t";
    } else if (timeagov1 < 60 * 24) {
      String a = (timeagov1 / 60).toStringAsFixed(0);
      return "$a gi???";
    } else if (timeagov1 < 60 * 24 * 30) {
      String a = (timeagov1 / (60 * 24)).toStringAsFixed(0);
      return "$a ng??y";
    } else {
      return "1 th??ng tr?????c";
    }
  }

  Visibility buildVideos(BuildContext context) {
    bool isVisible = post.video.url.isNotEmpty;
    if (isVisible) {
      controller = VideoPlayerController.network(post.video.url);
      initializeVideoPlayerFuture = controller.initialize();
      controller.setLooping(true);
      FloatingActionButton(
        onPressed: () {
          if (controller.value.isPlaying) {
            controller.pause();
          } else {
            controller.play();
          }
        },
        child: Icon(
          controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
        ),
      );
    }
    return Visibility(
      visible: isVisible,
      child: FutureBuilder(
        future: initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the VideoPlayerController has finished initialization, use
            // the data it provides to limit the aspect ratio of the video.
            return AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              // Use the VideoPlayer widget to display the video.
              child: VideoPlayer(controller),
            );
          } else {
            // If the VideoPlayerController is still initializing, show a
            // loading spinner.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
  Visibility buildMenu(BuildContext context){
    return  Visibility(
      visible: post.owner.id == UserRepositoryImpl.currentUser.id,
      child: PopupMenuButton<String>(
        onSelected: (String value) {
          showMaterialModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => EditPostWidget(
                provide: provide,
                post: post
            ),
          );
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'Value1',
            child: Text('Ch???nh s???a'),
          ),
        ],
      ),
    );
  }
}

class ExpandableText extends StatefulWidget {
  const ExpandableText(
      this.text, {
        Key key,
        this.trimLines = 2,
      })  : assert(text != null),
        super(key: key);

  final String text;
  final int trimLines;

  @override
  ExpandableTextState createState() => ExpandableTextState();
}

class ExpandableTextState extends State<ExpandableText> {
  bool _readMore = true;
  void _onTapLink() {
    setState(() => _readMore = !_readMore);
  }

  @override
  Widget build(BuildContext context) {
    final DefaultTextStyle defaultTextStyle = DefaultTextStyle.of(context);
    final colorClickableText = Colors.blue;
    final widgetColor = Colors.black;
    TextSpan link = TextSpan(
        text: _readMore ? "... read more" : " read less",
        style: TextStyle(
          color: colorClickableText,
        ),
        recognizer: TapGestureRecognizer()..onTap = _onTapLink
    );
    Widget result = LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        assert(constraints.hasBoundedWidth);
        final double maxWidth = constraints.maxWidth;
        // Create a TextSpan with data
        final text = TextSpan(
          text: widget.text,
        );
        // Layout and measure link
        TextPainter textPainter = TextPainter(
          text: link,
          textDirection: ui.TextDirection.rtl,//better to pass this from master widget if ltr and rtl both supported
          maxLines: widget.trimLines,
          ellipsis: '...',
        );
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final linkSize = textPainter.size;
        // Layout and measure text
        textPainter.text = text;
        textPainter.layout(minWidth: constraints.minWidth, maxWidth: maxWidth);
        final textSize = textPainter.size;
        // Get the endIndex of data
        int endIndex;
        final pos = textPainter.getPositionForOffset(Offset(
          textSize.width - linkSize.width,
          textSize.height,
        ));
        endIndex = textPainter.getOffsetBefore(pos.offset);
        var textSpan;
        if (textPainter.didExceedMaxLines) {
          textSpan = TextSpan(
            text: _readMore
                ? widget.text.substring(0, endIndex)
                : widget.text,
            style: TextStyle(
              color: widgetColor,
            ),
            children: <TextSpan>[link],
          );
        } else {
          textSpan = TextSpan(
            text: widget.text,
          );
        }
        return RichText(
          softWrap: true,
          overflow: TextOverflow.clip,
          text: textSpan,
        );
      },
    );
    return result;
  }
}
