import 'package:flutter/material.dart';
import 'dart:io';
import '../models/contact.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onTap;

  const ContactCard({super.key,
    required this.contact,
    required this.isExpanded,
    required this.onToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: contact.picture != null
                ? CircleAvatar(backgroundImage: FileImage(File(contact.picture!)))
                : CircleAvatar(child: Icon(Icons.person)),
            title: Text(contact.name),
            trailing: IconButton(
              icon: Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
              onPressed: onToggle,
            ),
            onTap: onTap,
          ),
          if (isExpanded)
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone: ${contact.phone}'),
                  Text('Email: ${contact.email}'),
                  if (contact.birthday != null)
                    Text('Birthday: ${contact.birthday!.toLocal()}'),
                  if (contact.latitude != null && contact.longitude != null)
                    Text(
                        'Location: ${contact.latitude?.toStringAsFixed(2)}, ${contact.longitude?.toStringAsFixed(2)}'),
                  SizedBox(height: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }
}