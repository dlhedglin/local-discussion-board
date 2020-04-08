import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NewPost extends StatefulWidget {
  final GeoPoint location;
  NewPost({Key key, @required this.location}) : super(key: key);
  // This widget is the root of your application.
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  String body;
  String title;
  List<DocumentSnapshot> userDocs;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Widget _buildBodyField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Body'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Body is required';
        }
      },
      onSaved: (String value) {
        body = value;
      },
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Title'),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Title is required';
        }
      },
      onSaved: (String value) {
        title = value;
      },
    );
  }

  Widget _buildPostForm() {
    return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildTitleField(),
            _buildBodyField(),
            RaisedButton(
              child: Text('Submit'),
              onPressed: () {
                if (!_formKey.currentState.validate()) {
                  return;
                }
                _formKey.currentState.save();
                Firestore.instance.collection('posts').add({
                  'title': title,
                  'body': body,
                  'location': widget.location,
                  'date': Timestamp.now(),
                });
                Navigator.pop(context);
              },
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("New Post"),
          centerTitle: true,
        ),
        body: Center(
          child: _buildPostForm(),
        ));
  }
}
