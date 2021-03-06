import 'package:diaporama/utils/colors.dart';
import 'package:flutter/material.dart';
import 'package:draw/draw.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class CommentWidget extends StatefulWidget {
  CommentWidget(this.post, this.level);

  final dynamic post;
  final int level;

  @override
  _CommentWidgetState createState() =>
      _CommentWidgetState(this.post, this.level);
}

class _CommentWidgetState extends State<CommentWidget> {
  _CommentWidgetState(this.post, this.level);

  dynamic post;
  int score;
  bool actionsVisibility = false;

  bool upvoted = false;
  bool downvoted = false;
  int level;

  final List<Color> commentBorderColor = [
    mediumGreyColor,
    Colors.blue,
    Colors.red,
    Colors.orange,
    Colors.yellow,
    Colors.green,
  ];

  @override
  Widget build(BuildContext context) {
    if (post is MoreComments) {
      return InkWell(
        onTap: () {},
        child: Container(
          padding: EdgeInsets.only(left: 8.0 * this.level, right: 8.0),
          child: Text("More comments..."),
        ),
      );
    } else if (post is Comment) {
      score = post.score;
      return InkWell(
        // onLongPress: () {
        //   if (!post.reddit.auth.userAgent.contains("anon")) {
        //     setState(() {
        //       actionsVisibility = !actionsVisibility;
        //     });
        //   } else {
        //     Scaffold.of(context).showSnackBar(SnackBar(
        //         content: Text("You must be logged in for comment actions!")));
        //   }
        // },
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                            color: level < 6
                                ? commentBorderColor[level]
                                : Colors.grey,
                            width: 3),
                      ),
                    ),
                    padding: EdgeInsets.only(left: 5.0),
                    margin: EdgeInsets.only(
                        // top: 8.0,
                        // bottom: 8.0,
                        left: 8.0 * this.level,
                        right: 8.0),
                    child: Column(children: [
                      //The top row which contains the author, flair and score
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: <Widget>[
                          //The post's author
                          Text(
                            post.author,
                            style: TextStyle(
                                fontSize: 12.0,
                                color: lightGreyColor,
                                decoration: TextDecoration.underline,
                                decorationColor: redditOrange,
                                fontWeight: FontWeight.bold),
                          ),
                          //The post's author's flair text
                          Builder(
                            builder: (ctx) {
                              if (post.authorFlairText != null) {
                                return Container(
                                  margin: EdgeInsets.only(left: 8.0),
                                  child: Container(
                                    padding: EdgeInsets.all(3.0),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(10.0),
                                      ),
                                      color: Colors.grey,
                                    ),
                                    child: Text(
                                      post.authorFlairText,
                                      style: TextStyle(
                                        fontSize: 8.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return Container(width: 0.0, height: 0.0);
                              }
                            },
                          ),
                          //The score of the post
                          Expanded(
                            child: Container(
                              alignment: Alignment.centerRight,
                              padding: EdgeInsets.only(right: 8.0),
                              child: Text(
                                score.toString(),
                                style: TextStyle(
                                  fontSize: 10.0,
                                  fontStyle: FontStyle.italic,
                                  color: lightGreyColor,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      //The actual comment body
                      Container(
                          margin: EdgeInsets.only(top: 8.0, bottom: 2.0),
                          alignment: Alignment.centerLeft,
                          child: MarkdownBody(
                            data: post.body,
                            onTapLink: (link) => launch(link),
                            styleSheet: MarkdownStyleSheet.fromTheme(ThemeData(
                              textTheme: TextTheme(
                                body1: TextStyle(
                                  fontSize: 12.0,
                                  fontFamily: "Raleway",
                                  color: lightGreyColor,
                                ),
                              ),
                            )),
                          )),
                    ]),
                  ),
                ),
              ],
            ),
            Builder(
              builder: (ctx) {
                if (actionsVisibility) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      //Upvote
                      InkWell(
                        child: Container(
                          margin: EdgeInsets.all(10.0),
                          child: upvoted
                              ? Icon(
                                  Icons.arrow_upward,
                                  color: Colors.orange,
                                )
                              : Icon(Icons.arrow_upward, color: Colors.grey),
                        ),
                        onTap: () {
                          if (upvoted) {
                            setState(() {
                              score--;
                              post.downvote();
                              downvoted = true;
                            });
                          } else {
                            setState(() {
                              score++;
                              post.upvote();
                              upvoted = true;
                            });
                          }
                        },
                      ),
                      //Downvote
                      InkWell(
                        child: Container(
                          margin: EdgeInsets.all(10.0),
                          child: downvoted
                              ? Icon(
                                  Icons.arrow_downward,
                                  color: Colors.purple,
                                )
                              : Icon(Icons.arrow_downward),
                        ),
                        onTap: () {
                          if (downvoted) {
                            setState(() {
                              score++;
                              post.upvote();
                              upvoted = true;
                            });
                          } else {
                            setState(() {
                              score--;
                              post.downvote();
                              downvoted = true;
                            });
                          }
                        },
                      ),
                      //Favorite
                      InkWell(
                        child: Container(
                          margin: EdgeInsets.all(10.0),
                          child: post.saved
                              ? Icon(Icons.star, color: Colors.amber)
                              : Icon(Icons.star),
                        ),
                        onTap: () {
                          if (post.saved)
                            post.unsave();
                          else
                            post.save();
                        },
                      ),
                      //Reply
                      InkWell(
                        child: Container(
                          margin: EdgeInsets.all(10.0),
                          child: Icon(Icons.reply),
                        ),
                        onTap: () {
                          Scaffold.of(context).showSnackBar(
                              SnackBar(content: Text("Coming soon!")));
                        },
                      ),
                    ],
                  );
                } else
                  return Container(width: 0.0, height: 0.0);
              },
            ),
            //Item seperator
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: mediumGreyColor,
                  width: 0.20,
                  style: BorderStyle.solid,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(width: 0.0, height: 0.0);
    }
  }
}
