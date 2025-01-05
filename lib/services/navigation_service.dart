import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../screens/create_contact_screen.dart';
import '../screens/view_contact_screen.dart';
import '../screens/recently_edited_screen.dart';

class NavigationService {
  static Future<void> navigateToCreateContact(
      BuildContext context,
      Function(Contact) onSave,
      {Contact? contact}
      ) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateContactScreen(
          onSave: onSave,
          contact: contact,
        ),
      ),
    );
  }

  static Future<void> navigateToViewContact(
      BuildContext context,
      Contact contact,
      VoidCallback onEdit,
      VoidCallback onDelete,
      ) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewContactScreen(
          contact: contact,
          onEdit: onEdit,
          onDelete: onDelete,
        ),
      ),
    );
  }

  static Future<void> navigateToRecentlyEdited(
      BuildContext context,
      List<Contact> recentlyEditedContacts,
      Function(Contact) onViewContact,
      ) {
    return Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecentlyEditedScreen(
          recentlyEditedContacts: recentlyEditedContacts,
          onViewContact: onViewContact,
        ),
      ),
    );
  }

  static void pop(BuildContext context) {
    if(context.mounted) Navigator.pop(context);
  }
}