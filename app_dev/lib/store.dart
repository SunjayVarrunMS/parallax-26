// saves data on the device (shared_preferences) so it is still there after a restart.
// every key starts with 'parallax:' so we can find and clear our own data.

import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String storePrefix = 'parallax:';

// one saved record, like a registration or an order
typedef Json = Map<String, dynamic>;

// goes up by one when the current screen should load again
final ValueNotifier<int> reloadCount = ValueNotifier<int>(0);

late SharedPreferences _prefs;

// call this once before the app starts
Future<void> initStore() async {
  _prefs = await SharedPreferences.getInstance();
}

dynamic readStore(String key, dynamic fallback) {
  try {
    final raw = _prefs.getString(key);
    if (raw == null) {
      return fallback;
    }
    return jsonDecode(raw);
  } catch (error) {
    return fallback;
  }
}

void writeStore(String key, dynamic value) {
  _prefs.setString(key, jsonEncode(value));
}

// read a saved list of records (an empty list if nothing is saved)
List<Json> readList(String key) {
  final raw = readStore(key, <dynamic>[]) as List<dynamic>;
  return raw.map((item) => Json.from(item as Map<dynamic, dynamic>)).toList();
}

// makeId('reg') -> "reg_k3j9x2"
String makeId(String prefix) {
  final random = Random().nextInt(2176782336).toRadixString(36).padLeft(6, '0');
  return '${prefix}_$random';
}

// remove everything this app has saved
void resetDemoData() {
  final keys = _prefs.getKeys().where((key) => key.startsWith(storePrefix)).toList();
  for (final key in keys) {
    _prefs.remove(key);
  }
}
