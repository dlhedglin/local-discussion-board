import 'package:shared_preferences/shared_preferences.dart';

class Alias {
  Future getAlias() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('alias');
  }
  
  setAlias(String alias) async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('alias', alias);
  }
}
