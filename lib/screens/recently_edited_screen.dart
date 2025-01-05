import 'package:flutter/material.dart';
import 'dart:io';
import '../models/contact.dart';

class RecentlyEditedScreen extends StatelessWidget {
  final List<Contact> recentlyEditedContacts;
  final Function(Contact) onViewContact;

  const RecentlyEditedScreen({
    super.key,
    required this.recentlyEditedContacts,
    required this.onViewContact,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recently Edited'),
      ),
      body: ListView.builder(
        itemCount: recentlyEditedContacts.length,
        itemBuilder: (context, index) {
          final contact = recentlyEditedContacts[index];
          return ListTile(
            leading: contact.picture != null
                ? CircleAvatar(
              backgroundImage: FileImage(File(contact.picture!)),
            )
                : CircleAvatar(child: Icon(Icons.person)),
            title: Text(contact.name),
            subtitle: Text(
                'Last edited: ${contact.lastEdited.toLocal().toString().split('.')[0]}'),
            onTap: () => onViewContact(contact),
          );
        },
      ),
    );
  }
}