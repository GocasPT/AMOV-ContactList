import 'package:flutter/cupertino.dart';

import '../../services/storage_service.dart';
import '../contact.dart';

class ContactViewModel extends ChangeNotifier {
  List<Contact> _contactsList = [];
  List<Contact> _recentlyEditedContacts = [];
  final Set<String> _expandedCards = {};

  // Getters
  List<Contact> get contactsList => _contactsList;
  List<Contact> get recentlyEditedContacts => _recentlyEditedContacts;
  Set<String> get expandedCards => _expandedCards;
  bool get isEmpty => _contactsList.isEmpty;

  ContactViewModel() {
    loadData();
  }

  Future<void> loadData() async {
    final contacts = await StorageService.loadContacts();
    final recentContacts = await StorageService.loadRecentlyEdited();
    _contactsList = List<Contact>.from(contacts);
    _recentlyEditedContacts = List<Contact>.from(recentContacts);
    notifyListeners();
  }

  void toggleCard(String contactId) {
    if (_expandedCards.contains(contactId)) {
      _expandedCards.remove(contactId);
    } else {
      _expandedCards.add(contactId);
    }
    notifyListeners();
  }

  void updateRecentlyEdited(Contact contact) async {
    _recentlyEditedContacts.removeWhere(
          (c) => c.name == contact.name && c.phone == contact.phone,
    );

    _recentlyEditedContacts.insert(0, contact);

    if (_recentlyEditedContacts.length > 10) {
      _recentlyEditedContacts = _recentlyEditedContacts.sublist(0, 10);
    }

    await StorageService.saveRecentlyEdited(_recentlyEditedContacts);
    notifyListeners();
  }

  void removeRecentlyEdited(Contact contact) async {
    _recentlyEditedContacts.removeWhere(
          (c) => c.name == contact.name && c.phone == contact.phone,
    );

    await StorageService.saveRecentlyEdited(_recentlyEditedContacts);
    notifyListeners();
  }

  Future<void> addContact(Contact contact) async {
    _contactsList.add(contact);
    updateRecentlyEdited(contact);
    await StorageService.saveContacts(_contactsList);
    notifyListeners();
  }

  Future<void> updateContact(Contact oldContact, Contact updatedContact) async {
    final index = _contactsList.indexOf(oldContact);
    _contactsList[index] = updatedContact;
    updateRecentlyEdited(updatedContact);
    await StorageService.saveContacts(_contactsList);
    notifyListeners();
  }

  Future<void> deleteContact(Contact contact) async {
    _contactsList.remove(contact);
    removeRecentlyEdited(contact);
    await StorageService.saveContacts(_contactsList);
    notifyListeners();
  }
}