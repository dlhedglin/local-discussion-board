import 'package:flutter/material.dart';
import 'post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostView extends StatefulWidget {
  final Post post;
  PostView({Key key, @required this.post}) : super(key: key);
  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  String text;
  int numReplies = 0;
  List<DocumentSnapshot> replies;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();


  Widget _buildReplyView(){
    if (replies == null) {
      return Center(
        child: Text('Loading Replies'),
      );
    }
    return ListView.builder(
      itemCount: replies.length,
      itemBuilder: (BuildContext context, int index) {
        final timePosted = replies[index].data['date'].toDate();
        
        return Card(child: ListTile(
          leading: CircleAvatar(),
          title: Text(replies[index].data['text']),
          subtitle: Row(children: <Widget>[
            Text(timeago.format(timePosted))
          ]),
        ));
      }
    );
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
    setState(() {
      
    });
    print(replies.length);
  }
  Widget _buildTextField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Reply'),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildTextField(),
            RaisedButton(
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
        ));
  }

  @override
  void initState() {
    getReplies();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // Use the Todo to create the UI.
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.post.title),
        ),
        body: Column(children: <Widget>[
          Card(
              child: ListTile(
            title: Text(widget.post.title),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_down),
                  iconSize: 30,
                  onPressed: () {},
                ),
                Text(widget.post.votes.toString()),
                IconButton(
                  icon: Icon(Icons.keyboard_arrow_up),
                  iconSize: 30,
                  onPressed: () {},
                ),
                Text(numReplies.toString() + ' Replies'),
                Text(widget.post.timestamp),
              ],
            ),
          )),
          Expanded(child: _buildReplyView()),
          _buildPostForm(),
        ]));
  }
}
