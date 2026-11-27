import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ShareTripLocalStore {
  static const _chatPrefix = 'sharetrip_chat_';
  static const _driverProfileKey = 'sharetrip_driver_profile';

  static Future<void> saveDriverProfile(Map<String, String> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_driverProfileKey, jsonEncode(profile));
  }

  static Future<Map<String, dynamic>?> getDriverProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_driverProfileKey);
    if (raw == null) return null;
    return Map<String, dynamic>.from(jsonDecode(raw) as Map);
  }

  static Future<void> addMessage(String conversationId, Map<String, dynamic> message) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_chatPrefix$conversationId';
    final messages = (jsonDecode(prefs.getString(key) ?? '[]') as List)
        .map((item) => Map<String, dynamic>.from(item as Map)).toList();
    messages.add(message);
    await prefs.setString(key, jsonEncode(messages));
  }

  static Future<List<Map<String, dynamic>>> getMessages(String conversationId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_chatPrefix$conversationId') ?? '[]';
    return (jsonDecode(raw) as List)
        .map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  static Future<Map<String, List<Map<String, dynamic>>>> getAllChats() async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, List<Map<String, dynamic>>>{};
    for (final key in prefs.getKeys().where((key) => key.startsWith(_chatPrefix))) {
      final id = key.substring(_chatPrefix.length);
      final raw = prefs.getString(key);
      if (raw == null) continue;
      result[id] = (jsonDecode(raw) as List)
          .map((item) => Map<String, dynamic>.from(item as Map)).toList();
    }
    return result;
  }
  static const _vehiclesKey = 'sharetrip_driver_vehicles';
  static const _driverNotificationsKey = 'sharetrip_driver_notifications';

  static Future<List<Map<String, dynamic>>> getDriverVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_vehiclesKey) ?? '[]';
    return (jsonDecode(raw) as List).map((v) => Map<String, dynamic>.from(v as Map)).toList();
  }

  static Future<void> saveDriverVehicles(List<Map<String, dynamic>> vehicles) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_vehiclesKey, jsonEncode(vehicles));
  }

  static Future<List<Map<String, dynamic>>> getDriverNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_driverNotificationsKey) ?? '[]';
    return (jsonDecode(raw) as List).map((v) => Map<String, dynamic>.from(v as Map)).toList();
  }

  static Future<void> addDriverNotification(String title, String message) async {
    final items = await getDriverNotifications();
    items.insert(0, {'title': title, 'message': message, 'time': DateTime.now().toIso8601String(), 'read': false});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_driverNotificationsKey, jsonEncode(items));
  }

  static Future<void> markDriverNotificationsRead() async {
    final items = await getDriverNotifications();
    for (final item in items) { item['read'] = true; }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_driverNotificationsKey, jsonEncode(items));
  }
}
