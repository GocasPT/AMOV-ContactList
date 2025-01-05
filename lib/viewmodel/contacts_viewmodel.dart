import '../model/contact.dart';
import '../model/contact_list.dart';

class ContactsViewModel {
  final ContactsList contactsList;
  Contact? currentContact;

  String name = '';
  String phone = '';
  String email = '';
  //DateTime? birthday;
  //String? picture;

  ContactsViewModel({required this.contactsList});

  void createContact() {
    currentContact = null;
    name = '';
    phone = '';
    email = '';
    //birthday = null;
    //picture = null;
  }

  void selectContact(Contact contact) {
    currentContact = contact;
    name = contact.name;
    phone = contact.phoneNumber;
    email = contact.email;
    //birthday = contact.birthday;
    //picture = contact.picture?.path;
  }

  void updateContactDetails(String name, String phone, String email) {
    this.name = name;
    this.phone = phone;
    this.email = email;
  }

  bool saveContact() {
    if (name.isEmpty || phone.isEmpty || email.isEmpty) {
      return false;
    }

    if (currentContact == null) {
      contactsList.addContact(
        Contact(
          name: name,
          email: email,
          phoneNumber: phone,
        ),
      );
    } else {
      currentContact!
        ..name = name
        ..email = email
        ..phoneNumber = phone;
    }

    return true;
  }
}