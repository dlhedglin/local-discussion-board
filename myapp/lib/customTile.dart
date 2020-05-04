import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomListItem extends StatelessWidget {
  const CustomListItem({
    this.title,
    this.user,
    this.timestamp,
    this.score,
    this.docID,
    this.body,
    this.replies,
  });

  final String title;
  final String user;
  final String timestamp;
  final int score;
  final String docID;
  final String body;
  final int replies;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: _VideoDescription(
              title: title,
              user: user,
              timestamp: timestamp,
              score: score,
              docID: docID,
              body: body,
              replies : replies,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoDescription extends StatefulWidget {
  _VideoDescription({
    Key key,
    this.title,
    this.user,
    this.timestamp,
    this.score,
    this.docID,
    this.body,
    this.replies
  }) : super(key: key);

  String title;
  String user;
  String timestamp;
  int score;
  String docID;
  String body;
  int replies;

  @override
  __VideoDescriptionState createState() => __VideoDescriptionState();
}

class __VideoDescriptionState extends State<_VideoDescription> {
  _incrementScore() async {
    widget.score += 1;
    await Firestore.instance
        .collection('posts')
        .document(widget.docID)
        .updateData(
      {"score": widget.score},
    );
    setState(() {});
  }

  _decrementScore() async {
    widget.score -= 1;
    await Firestore.instance
        .collection('posts')
        .document(widget.docID)
        .updateData(
      {"score": widget.score},
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            widget.title,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14.0,
            ),
          ),
          Text(
            widget.body == null ? "" : widget.body,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 13.0,
            ),
          ),
          // const Padding(padding: EdgeInsets.symmetric(vertical: 2.0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                widget.user,
                style: const TextStyle(fontSize: 13.0),
              ),
              // const Padding(padding: EdgeInsets.symmetric(horizontal: 10)),
              Text(
                widget.timestamp,
                style: const TextStyle(fontSize: 13.0),
              ),
              Text(
                widget.replies.toString() + " Replies",
                style: const TextStyle(fontSize: 13.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                    ),
                    iconSize: 30,
                    onPressed: _decrementScore,
                  ),
                  Text("${widget.score}"),
                  IconButton(
                    icon: Icon(
                      Icons.keyboard_arrow_up,
                    ),
                    iconSize: 30,
                    onPressed: _incrementScore,
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
