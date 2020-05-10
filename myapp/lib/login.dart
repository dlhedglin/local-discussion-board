import 'package:flutter/material.dart';
import 'alias.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final Alias alias = Alias();
  String curName;
  String name;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  initState() {
    super.initState();
    getCurAlias();
  }

  getCurAlias() async {
    curName = await alias.getAlias();
    setState(() {});
    print(curName);
  }

  Widget _buildAliasField() {
    return TextFormField(
      decoration: InputDecoration(
        hintText: "Alias",
        fillColor: Colors.white,
        filled: true,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white, width: 2.0),
          borderRadius: BorderRadius.circular(10)

        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.pink, width: 2.0),
          borderRadius: BorderRadius.circular(10)
        ),
      ),
      validator: (String value) {
        if (value.isEmpty) {
          return 'Alias is required';
        }
      },
      onSaved: (String value) {
        name = value;
      },
    );
  }

  Widget _buildAliasForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          _buildAliasField(),
          RaisedButton(
            color: Colors.white,
            child: Text('Change'),
            onPressed: () async {
              if (!_formKey.currentState.validate()) {
                return;
              }
              _formKey.currentState.save();
              await alias.setAlias(name);
              curName = await alias.getAlias();
              setState(() {});
              // Navigator.pop(context);
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
        title: Text('Set Alias', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: Container(
        color: Colors.blueAccent,
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Text("Current Alias: $curName"),
              _buildAliasForm(),
            ],
          ),
        ),
      ),
    );
  }
}
