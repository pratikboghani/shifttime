import 'package:shared_preferences/shared_preferences.dart';
Future<String> loadSession(String key) async {
  final prefs = await SharedPreferences.getInstance();
  var data = prefs.getString(key) ?? '';
return data;

}