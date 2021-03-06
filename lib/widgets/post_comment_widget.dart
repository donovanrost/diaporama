import 'package:bot_toast/bot_toast.dart';
import 'package:diaporama/states/global_state.dart';
import 'package:diaporama/utils/colors.dart';
import 'package:diaporama/widgets/post_comment_body.dart';
import 'package:draw/draw.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class PostCommentWidget extends StatefulWidget {
  final dynamic comment;
  final int level;

  const PostCommentWidget({Key key, this.comment, this.level})
      : super(key: key);

  @override
  _PostCommentWidgetState createState() => _PostCommentWidgetState();
}

class _PostCommentWidgetState extends State<PostCommentWidget> {
  // dynamic get _comment => widget.comment;
  dynamic _comment;
  int get _level => widget.level;

  final List<Color> commentBorderColor = [
    mediumGreyColor,
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
  ];

  bool _collapseChildren = false;
  bool _displayActionsBar = false;
  bool _displayCommentForm = false;

  TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _comment = widget.comment;
  }

  void _refreshComment() async {
    await _comment.refresh();
    setState(() {
      _comment = _comment;
    });
  }

  void _toggleCommentForm() {
    setState(() {
      _displayCommentForm = !_displayCommentForm;
    });
    _commentController.clear();
  }

  void _vote(VoteState vote) async {
    if (!Provider.of<GlobalState>(context, listen: false).hascredentials) {
      BotToast.showText(text: "Hey, you must be logged in to do that !");
      return;
    }
    if (vote != _comment.vote) {
      if (vote == VoteState.upvoted) {
        await _comment.upvote();
      } else if (vote == VoteState.downvoted) {
        await _comment.downvote();
      }
    } else {
      await _comment.clearVote();
    }
    _refreshComment();
    _toggleActionsBar();
  }

  void _toggleActionsBar() {
    setState(() {
      _displayActionsBar = !_displayActionsBar;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget widget;

    if (_comment is Comment) {
      widget = GestureDetector(
        onTap: () {
          setState(() {
            _collapseChildren = !_collapseChildren;
          });
        },
        onDoubleTap: () async {
          if (_comment.vote == VoteState.none) {
            await _comment.upvote(waitForResponse: true);
          } else if (_comment.vote == VoteState.upvoted) {
            await _comment.downvote(waitForResponse: true);
          } else if (_comment.vote == VoteState.downvoted) {
            await _comment.clearVote(waitForResponse: true);
          }
          _refreshComment();
        },
        onLongPress: _toggleActionsBar,
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(
                    width: 4.0,
                    color: _level < commentBorderColor.length
                        ? commentBorderColor[_level]
                        : Colors.grey,
                  ),
                ),
              ),
              child: Column(
                children: <Widget>[
                  PostCommentBody(
                    comment: _comment,
                  ),
                  if (_displayActionsBar)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: redditOrange, width: 2),
                            top: BorderSide(
                              color: redditOrange,
                              width: 2,
                            ),
                          ),
                          color: Colors.black12),
                      height: 35,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          InkWell(
                            borderRadius: BorderRadius.circular(25),
                            onTap: () async {
                              if (!_comment.saved) {
                                await _comment.save();
                              } else {
                                await _comment.unsave();
                              }
                              _refreshComment();
                              _toggleActionsBar();
                            },
                            child: Icon(
                              Icons.star,
                              color: _comment.saved ? redditOrange : blueColor,
                            ),
                          ),
                          InkWell(
                            onTap: _toggleCommentForm,
                            child: Icon(
                              Icons.reply,
                              color: blueColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _vote(VoteState.upvoted),
                            child: Icon(
                              Icons.arrow_upward,
                              color: _comment.vote == VoteState.upvoted
                                  ? redditOrange
                                  : blueColor,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _vote(VoteState.downvoted),
                            child: Icon(
                              Icons.arrow_downward,
                              color: _comment.vote == VoteState.downvoted
                                  ? redditOrange
                                  : blueColor,
                            ),
                          ),
                          GestureDetector(
                            child: Icon(
                              Icons.content_copy,
                              color: blueColor,
                            ),
                            onTap: () {
                              Clipboard.setData(
                                  ClipboardData(text: _comment.body));
                              BotToast.showText(text: "Copied to clipboard");
                              _toggleActionsBar();
                            },
                          ),
                        ],
                      ),
                    ),
                  if (_displayCommentForm)
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextFormField(
                            style: TextStyle(
                              color: lightGreyColor,
                            ),
                            controller: _commentController,
                            cursorColor: blueColor,
                            decoration: InputDecoration(
                              fillColor: darkGreyColor,
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: redditOrange, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: blueColor, width: 2),
                              ),
                            ),
                          ),
                          RaisedButton.icon(
                              onPressed: () async {
                                if (_commentController.text.isEmpty) return;
                                await _comment.reply(_commentController.text);
                                _refreshComment();
                                _toggleCommentForm();
                                _toggleActionsBar();
                                // TODO : Fix comment refreshing and insertion/rebuild
                              },
                              color: blueColor,
                              icon: Icon(
                                Icons.check,
                                color: lightGreyColor,
                              ),
                              label: Text(
                                "Submit",
                                style: TextStyle(color: lightGreyColor),
                              ))
                        ],
                      ),
                    ),
                  if (_collapseChildren)
                    Container(
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: lightGreyColor,
                      ),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                          color: blueColor,
                          borderRadius: BorderRadius.circular(5)),
                    )
                ],
              ),
            ),
            if (_comment.replies != null && !_collapseChildren)
              for (dynamic comment in _comment.replies.comments)
                if (comment is Comment)
                  PostCommentWidget(
                    comment: comment,
                    level: _level + 1,
                  ),
          ],
        ),
      );
    } else {
      return Container(child: Text("More Comments"));
    }

    return Container(
      padding: EdgeInsets.only(
        left: _level > 0 ? 4.0 : 0.0,
      ),
      child: widget,
    );
  }
}
