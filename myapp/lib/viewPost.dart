import 'package:flutter/material.dart';
import 'post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:device_info/device_info.dart';
import 'customTile.dart';
import 'loading.dart';

class PostView extends StatefulWidget {
  final Post post;
  PostView({Key key, @required this.post}) : super(key: key);
  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  DeviceInfoPlugin deviceInfo;
  AndroidDeviceInfo androidInfo;
  String text;
  int numReplies = 0;
  List<DocumentSnapshot> replies;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int score;

  getPostInfo() async {
    await Firestore.instance
        .collection('posts')
        .document(widget.post.ID)
        .get()
        .then(
          (DocumentSnapshot snapshot) {},
        );
  }

  getScore() {
    score = widget.post.votes;
  }

  getDeviceInfo() async {
    deviceInfo = DeviceInfoPlugin();
    androidInfo = await deviceInfo.androidInfo;
  }

  Widget _buildReplyView() {
    if (replies == null) {
      return Center(
        child: Loading(),
      );
    }
    return ListView.builder(
        itemCount: replies.length,
        itemBuilder: (BuildContext context, int index) {
          final timePosted = replies[index].data['date'].toDate();
          return Card(
              child: ListTile(
            title: Text(replies[index].data['text'] == null ? "" : replies[index].data['text']),
            subtitle: Row(children: <Widget>[Text(timeago.format(timePosted))]),
          ));
        });
  }

  getReplies() async {
    await Firestore.instance
        .collection('posts')
        .document(widget.post.ID)
        .collection('replies')
        .orderBy('date')
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      replies = snapshot.documents.toList();
    });
    numReplies = replies.length;
    setState(() {});
  }

  Widget _buildTextField() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: "Reply",
        fillColor: Colors.white,
        filled: true,
        enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 2.0),
            borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.pink, width: 2.0),
            borderRadius: BorderRadius.circular(10)),
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Text is required';
        }
      },
      onSaved: (String value) {
        text = value;
      },
    );
  }

  Widget _buildPostForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildTextField(),
          RaisedButton(
            color: Colors.white,
            child: Text('Submit'),
            onPressed: () {
              if (!_formKey.currentState.validate()) {
                return;
              }
              _formKey.currentState.save();
              Firestore.instance
                  .collection('posts')
                  .document(widget.post.ID)
                  .collection('replies')
                  .add({
                'text': text,
                'date': Timestamp.now(),
                'PostId': widget.post.ID,
              });
              getReplies();
            },
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    getScore();
    getReplies();
    getDeviceInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(widget.post.title, style: TextStyle(color: Colors.black),),
      ),
      body: Container(
        color: Colors.blueAccent,
        child: Column(
          children: <Widget>[
            Container(
              color: Colors.white,
              child: CustomListItem(
                title: widget.post.title,
                user: widget.post.user,
                timestamp: widget.post.timestamp,
                score: widget.post.votes,
                docID: widget.post.ID,
                body: widget.post.body,
                replies: numReplies,
              ),
            ),
            Expanded(
              child: _buildReplyView(),
            ),
            _buildPostForm(),
          ],
        ),
      ),
    );
  }
}
