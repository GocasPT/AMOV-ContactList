import 'contact.dart';

class ContactsList {
  final List<Contact> _contacts = [];

  void addContact(Contact contact) {
    _contacts.add(contact);
  }

  List<Contact> getContacts() {
    return List.unmodifiable(_contacts);
  }

  void clearAll() {
    _contacts.clear();
  }
}