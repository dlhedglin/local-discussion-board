import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:myapp/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'alias.dart';

class NewPost extends StatefulWidget {
  GlobalKey gKey;
  NewPost({Key key}) : super(key: key);
  // This widget is the root of your application.
  @override
  _NewPostState createState() => _NewPostState();
}

class _NewPostState extends State<NewPost> {
  String body;
  String title;
  String name;
  List<DocumentSnapshot> userDocs;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GeoPoint _position;
  final Alias alias = Alias();

  void getLocation() async {
    Position pos = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _position = GeoPoint(pos.latitude, pos.longitude);
  }

  void getAlias() async {
    name = await alias.getAlias();
  }

  @override
  initState() {
    getLocation();
    getAlias();
    super.initState();
  }

  Widget _buildBodyField() {
    return TextFormField(
      keyboardType: TextInputType.multiline,
      maxLines: null,
      decoration: InputDecoration(
        hintText: "Body",
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
      decoration: InputDecoration(
        hintText: "Title",
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
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _buildTitleField(),
          _buildBodyField(),
          RaisedButton(
            color: Colors.white,
            child: Text('Create'),
            onPressed: () {
              if (!_formKey.currentState.validate()) {
                return;
              }
              _formKey.currentState.save();
              Firestore.instance.collection('posts').add(
                {
                  'title': title,
                  'body': body,
                  'alias': name,
                  'location': _position,
                  'date': Timestamp.now(),
                  'score': 0,
                },
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text("Create a post", style: TextStyle(color: Colors.black),),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.blueAccent,
        padding: EdgeInsets.all(25),
        child: Center(
          child: _buildPostForm(),
        ),
      ),
    );
  }
}
