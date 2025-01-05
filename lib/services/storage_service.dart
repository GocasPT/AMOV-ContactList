import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/contact.dart';

class StorageService {
  static Future<List<Contact>> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? contactsJson = prefs.getString('contacts');
    if (contactsJson != null) {
      List<dynamic> contactList = json.decode(contactsJson);
      return contactList
          .map((contactJson) => Contact.fromJson(contactJson))
          .toList();
    }
    return [];
  }

  static Future<void> saveContacts(List<Contact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> contactJsonList =
    contacts.map((contact) => contact.toJson()).toList();
    await prefs.setString('contacts', json.encode(contactJsonList));
  }

  static Future<List<Contact>> loadRecentlyEdited() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recentJson = prefs.getString('recent_contacts');
    if (recentJson != null) {
      List<dynamic> recentList = json.decode(recentJson);
      return recentList
          .map((contactJson) => Contact.fromJson(contactJson))
          .toList();
    }
    return [];
  }

  static Future<void> saveRecentlyEdited(List<Contact> contacts) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> recentJsonList =
    contacts.map((contact) => contact.toJson()).toList();
    await prefs.setString('recent_contacts', json.encode(recentJsonList));
  }
}