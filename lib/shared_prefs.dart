import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs {
  SharedPrefs._();

  static final _instance = SharedPrefs._();

  factory SharedPrefs() => _instance;
  late final SharedPreferences _prefs;

  final fcmKey = 'fcm';

  init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  String? get fcm => _prefs.getString(fcmKey);

  Future setFCM(String fcm) async {
    await _prefs.setString(fcmKey, fcm);
  }

  //delete fcm from local storage
  Future deleteFCM() async {
    await _prefs.remove(fcmKey);
  }
}
