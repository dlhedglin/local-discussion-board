import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'viewPost.dart';
import 'post.dart';
import 'loading.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:device_info/device_info.dart';
import 'home.dart';
import 'customTile.dart';

void main() => runApp(MaterialApp(
      title: 'Home',
      home: Home(),
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
  List<DocumentSnapshot> userDocs = [];
  Map<String, int> votes = new Map();
  Map<String, int> numReplies = new Map();

  var locationOptions =
      LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);
  Position _position;
  List<Placemark> placemark;

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Future<Null> refreshList() async {
    await getLocation();
    await getPosts();
    setState(() {});
    return null;
  }

  void getLocation() async {
    _position = await Geolocator()
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    // print(_position);
    placemark = await Geolocator()
        .placemarkFromCoordinates(_position.latitude, _position.longitude);
  }


  Widget _buildUserView() {
    if (userDocs == null) {
      return Container(
        color: Colors.blueAccent,
        child: Center(
          child: Loading(),
        ),
      );
    }
    return ListView.builder(
      itemCount: userDocs.length,
      itemBuilder: (BuildContext context, int index) {
        DocumentSnapshot post = userDocs[index];
        final timePosted = userDocs[index].data['date'].toDate();
        int totalVotes = userDocs[index].data['score'];
        String title = userDocs[index].data['title'];
        String user = userDocs[index].data['alias'] == null
            ? "Anon"
            : userDocs[index].data['alias'];

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PostView(
                  post: Post(
                    userDocs[index].data['title'],
                    userDocs[index].data['body'],
                    userDocs[index].documentID,
                    userDocs[index].data['score'],
                    timeago.format(timePosted),
                    user,
                    numReplies[post.documentID],
                  ),
                ),
              ),
            ).then((value) {
              setState(() {
              });
            });
          },
          child: Card(
            child: CustomListItem(
              title: title,
              user: user,
              timestamp: timeago.format(timePosted),
              score: totalVotes,
              docID: userDocs[index].documentID,
              replies: numReplies[post.documentID],
              
            ),
          ),
        );
      },
    );
  }

  getPosts() async {
    final List<DocumentSnapshot> localPosts = [];
    await Firestore.instance
        .collection('posts')
        .orderBy('date', descending: true)
        .getDocuments()
        .then((QuerySnapshot snapshot) {
      userDocs = snapshot.documents.toList();
    });
    print(_position);
    for (var item in userDocs) {
      try {
        double distanceInMeters = await Geolocator().distanceBetween(
            _position.latitude,
            _position.longitude,
            item.data['location'].latitude,
            item.data['location'].longitude);
        if (distanceInMeters < 30000) {
          localPosts.add(item);
        }
      } catch (e) {
        print(e);
      }
    }
    userDocs = localPosts;
    for (var item in userDocs) {
      await Firestore.instance
          .collection('posts')
          .document(item.documentID)
          .collection('replies')
          .getDocuments()
          .then(
        (QuerySnapshot snapshot) {
          numReplies[item.documentID] = snapshot.documents.toList().length;
        },
      );
    }
    setState(() {});
  }

  getDeviceInfo() async {
    deviceInfo = DeviceInfoPlugin();
    androidInfo = await deviceInfo.androidInfo;
  }

  @override
  initState() {
    userDocs = null;
    getLocation();
    getPosts();
    getDeviceInfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String posString = "Unknown";
    if (placemark != null) {
      posString =
          placemark[0].locality + ", " + placemark[0].administrativeArea;
    }
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true,
          title: Row(
            children: <Widget>[
              Icon(
                Icons.place,
                color: Colors.black,
              ),
              Text(posString, style: TextStyle(color: Colors.black)),
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
        body: Container(
          color: Colors.blueAccent,
          padding: EdgeInsets.symmetric(vertical: 15, horizontal: 5),
          child: Column(
            children: <Widget>[
              Expanded(
                child: RefreshIndicator(
                  child: _buildUserView(),
                  onRefresh: refreshList,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MyButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // The InkWell wraps the custom flat button widget.
    return InkWell(
      // When the user taps the button, show a snackbar.
      onTap: () {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('Tap'),
        ));
      },
      child: Container(
        padding: EdgeInsets.all(12.0),
        child: Text('Flat Button'),
      ),
    );
  }
}
