import 'package:flutter/material.dart';
import 'package:myapp/newPost.dart';
import 'login.dart';
import 'newPost.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'main.dart';

class Home extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _HomeState();
  }
}

class _HomeState extends State<Home> {
  int _page = 0;
  // GlobalKey _bottomNavigationKey = GlobalKey();
  GlobalKey globalKey = new GlobalKey(debugLabel: 'btm_app_bar');

  final List<Widget> _children = [
    MyApp(), // view posts
    SignIn(),
    NewPost(),
  ];
  
  void changeTab(int index) {
    setState(() {
      _page = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _children[_page],
      bottomNavigationBar: CurvedNavigationBar(
        key: globalKey,
        onTap: (index) {
          setState(() {
            print(_page);
            _page = index;
          });
        },
        index: _page, // this will be set when a new tab is tapped
        items: [
          Icon(Icons.home, size: 30),
          Icon(Icons.alternate_email, size: 30),
          Icon(Icons.add, size: 30),
          // Icon(Icons.refresh, size: 30),
        ],
      ),
    );
  }
}
