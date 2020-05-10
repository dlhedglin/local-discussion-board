import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'alias.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

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
  String url;
  List<DocumentSnapshot> userDocs;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  GeoPoint _position;
  final Alias alias = Alias();
  File _image;
  String fileName;
  StorageReference storageRef;
  StorageUploadTask uploadTask;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
      print(_image);
    });
  }

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
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildTitleField(),
            _buildBodyField(),
            Center(
              child: _image == null
                  ? Text('No image selected.')
                  : Image.file(_image),
            ),
            FloatingActionButton(
              onPressed: getImage,
              tooltip: 'Pick Image',
              child: Icon(Icons.add_a_photo),
            ),
            RaisedButton(
              color: Colors.white,
              child: Text('Create'),
              onPressed: () async {
                getLocation();
                getAlias();
                if (!_formKey.currentState.validate()) {
                  return;
                }
                _formKey.currentState.save();
                if(_image != null){
                  storageRef =
                      FirebaseStorage.instance.ref().child(_image.toString());
                  uploadTask = storageRef.putFile(_image);
                  final StorageTaskSnapshot downloadUrl =
                      (await uploadTask.onComplete);
                  url = (await downloadUrl.ref.getDownloadURL());
                }
                Firestore.instance.collection('posts').add(
                  {
                    'title': title,
                    'body': body,
                    'alias': name,
                    'location': _position,
                    'date': Timestamp.now(),
                    'score': 0,
                    'image': url,
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.black),
        backgroundColor: Colors.white,
        title: Text(
          "Create a post",
          style: TextStyle(color: Colors.black),
        ),
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
