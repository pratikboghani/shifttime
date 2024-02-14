import 'package:shared_preferences/shared_preferences.dart';

Future<void> setSession(key, value) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setString(key, value);
}