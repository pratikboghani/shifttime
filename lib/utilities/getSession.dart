import 'package:shared_preferences/shared_preferences.dart';
var data;
var userToken;

Future<String> loadSession(String key) async {
  final prefs = await SharedPreferences.getInstance();
  data = prefs.getString(key) ?? '';
return data;

}