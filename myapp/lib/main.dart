import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'newPost.dart';
import 'viewPost.dart';
import 'post.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:device_info/device_info.dart';

void main() => runApp(MaterialApp(
      title: 'Home',
      home: MyApp(),
    ));

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  DeviceInfoPlugin deviceInfo;
  AndroidDeviceInfo androidInfo;
  StreamSubscription<Position> positionStream;
  String body = "";
  String name;
  String email;
  List<DocumentSnapshot> userDocs;
  Map<String, int> votes = new Map();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
  Position _position;
  List<Placemark> placemark;

  void getLocation() async {
    positionStream = Geolocator()
        .getPositionStream(locationOptions)
        .listen((Position position) {
      print(position == null
          ? 'Unknown'
          : position.latitude.toString() +
              ', ' +
              position.longitude.toString());
      _position = position;
    });
  }

  Widget _buildUserView() {
    if (userDocs == null) {
      return Center(
        child: Text('Loading users'),
      );
    }
    return ListView.builder(
      itemCount: userDocs.length,
      itemBuilder: (BuildContext context, int index) {
        final myColors = [
          Colors.cyan,
          Colors.pink[300],
          Colors.green,
          Colors.red,
          Colors.blue,
          Colors.purple
        ];
        final myIcons = [
          Icons.cloud,
          Icons.audiotrack,
          Icons.brush,
          Icons.bubble_chart,
          Icons.color_lens
        ];
        myIcons.shuffle();
        myColors.shuffle();
        final timePosted = userDocs[index].data['date'].toDate();
        int totalVotes = votes[userDocs[index].documentID];
        return Card(
            child: ListTile(
          title: Text(userDocs[index].data['title']),
          subtitle: Row(
            // mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(
                icon: Icon(Icons.keyboard_arrow_down),
                iconSize: 30,
                onPressed: () {
                  Firestore.instance
                      .collection('votes')
                      .where('deviceId', isEqualTo: androidInfo.androidId)
                      .where('postId', isEqualTo: userDocs[index].documentID)
                      .getDocuments()
                      .then((QuerySnapshot snapshot) {
                    if (snapshot.documents.length > 0) {
                      for (var doc in snapshot.documents) {
                        Firestore.instance
                            .collection('votes')
                            .document(doc.documentID)
                            .delete();
                      }
                    }
                    Firestore.instance.collection('votes').add({
                      'postId': userDocs[index].documentID,
                      'deviceId': androidInfo.androidId,
                      'type': 'downvote'
                    });
                  });
                  setState(() {
                    
                  });
                },
              ),
              Text(totalVotes.toString()),
              IconButton(
                icon: Icon(Icons.keyboard_arrow_up),
                iconSize: 30,
                onPressed: () {
                  Firestore.instance
                      .collection('votes')
                      .where('deviceId', isEqualTo: androidInfo.androidId)
                      .where('postId', isEqualTo: userDocs[index].documentID)
                      .getDocuments()
                      .then((QuerySnapshot snapshot) {
                    if (snapshot.documents.length > 0) {
                      for (var doc in snapshot.documents) {
                        Firestore.instance
                            .collection('votes')
                            .document(doc.documentID)
                            .delete();
                      }
                    }
                    Firestore.instance.collection('votes').add({
                      'postId': userDocs[index].documentID,
                      'deviceId': androidInfo.androidId,
                      'type': 'upvote'
                    });
                  });
                  setState(() {});
                },
              ),
              Text(
                timeago.format(timePosted),
                textAlign: TextAlign.end,
              ),
            ],
          ),
          // isThreeLine: true,
          leading: CircleAvatar(
            backgroundColor: myColors.first,
            child: Icon(
              myIcons.first,
              color: Colors.white,
            ),
          ),
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => PostView(
                        post: Post(
                          userDocs[index].data['title'],
                            userDocs[index].data['body'],
                            userDocs[index].documentID,
                            votes[userDocs[index].documentID],
                            timeago.format(timePosted),
                            ))));
          },
        ));
      },
    );
  }

  getPosts() async {
    final List<DocumentSnapshot> localPosts = [];
    Position position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    await Firestore.instance
        .collection('posts')
        .orderBy('date', descending: true)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      userDocs = snapshot.documents.toList();
    });
    for (var item in userDocs) {
      double distanceInMeters = await Geolocator().distanceBetween(
          position.latitude,
          position.longitude,
          item.data['location'].latitude,
          item.data['location'].longitude);
      if (distanceInMeters < 30000) {
        localPosts.add(item);
      }
    }
    userDocs = localPosts;
    int upvotes, downvotes;
    for (var item in userDocs) {
      await Firestore.instance
          .collection('votes')
          .where('postId', isEqualTo: item.documentID)
          .where('type', isEqualTo: 'upvote')
          .getDocuments()
          .then((QuerySnapshot snapshot) {
            upvotes = snapshot.documents.length;
        // print(votes[item.documentID]);
      });
      await Firestore.instance
          .collection('votes')
          .where('postId', isEqualTo: item.documentID)
          .where('type', isEqualTo: 'downvote')
          .getDocuments()
          .then((QuerySnapshot snapshot) {
            downvotes = snapshot.documents.length;
        // print(votes[item.documentID]);
      });
      votes[item.documentID] = upvotes - downvotes;
    }
    setState(() {});
  }
  getDeviceInfo() async {
    deviceInfo = DeviceInfoPlugin();
    androidInfo = await deviceInfo.androidInfo;
  }

  @override
  initState() {
    super.initState();
    getLocation();
    getPosts();
    getDeviceInfo();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.refresh),
                  color: Colors.white,
                  onPressed: () {
                    getPosts();
                    setState(() {});
                  },
                ),
                IconButton(
                    icon: Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewPost(
                                    location: GeoPoint(_position.latitude,
                                        _position.longitude),
                                  )));
                      getPosts();
                      setState(() {});
                    }),
              ],
            ),
            body: Container(
              padding: EdgeInsets.all(5),
              child: Column(
                children: <Widget>[
                  // _buildUserForm(),
                  Expanded(child: _buildUserView()),
                  // Text(_position.toString()),
                  // Text(placemark == null ? 'Unknown' : placemark[0].locality),
                ],
              ),
            )));
  }
}
