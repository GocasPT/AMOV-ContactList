import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../services/storage_service.dart';
import '../widgets/contact_card.dart';
import 'create_contact_screen.dart';
import 'view_contact_screen.dart';
import 'recently_edited_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Contact> contactsList = [];
  List<Contact> recentlyEditedContacts = [];
  Set<String> expandedCards = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final contacts = await StorageService.loadContacts();
    final recentContacts = await StorageService.loadRecentlyEdited();
    setState(() {
      contactsList = contacts;
      recentlyEditedContacts = recentContacts;
    });
  }

  void toggleCard(String contactId) {
    setState(() {
      if (expandedCards.contains(contactId)) {
        expandedCards.remove(contactId);
      } else {
        expandedCards.add(contactId);
      }
    });
  }

  void updateRecentlyEdited(Contact contact) async {
    setState(() {
      recentlyEditedContacts.removeWhere(
            (c) => c.name == contact.name && c.phone == contact.phone,
      );

      recentlyEditedContacts.insert(0, contact);

      if (recentlyEditedContacts.length > 10) {
        recentlyEditedContacts = recentlyEditedContacts.sublist(0, 10);
      }
    });

    await StorageService.saveRecentlyEdited(recentlyEditedContacts);
  }

  void removeRecentlyEdited(Contact contact) async {
    setState(() {
      recentlyEditedContacts.removeWhere(
            (c) => c.name == contact.name && c.phone == contact.phone,
      );
    });

    await StorageService.saveRecentlyEdited(recentlyEditedContacts);
  }

  void createContact() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateContactScreen(
          onSave: (contact) async {
            setState(() {
              contactsList.add(contact);
              updateRecentlyEdited(contact);
            });
            await StorageService.saveContacts(contactsList);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void editContact(Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateContactScreen(
          onSave: (updatedContact) async {
            setState(() {
              final index = contactsList.indexOf(contact);
              contactsList[index] = updatedContact;
              updateRecentlyEdited(updatedContact);
            });
            await StorageService.saveContacts(contactsList);
            Navigator.pop(context);
            Navigator.pop(context);
          },
          contact: contact,
        ),
      ),
    );
  }

  void viewContact(Contact contact) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ViewContactScreen(
          contact: contact,
          onEdit: () => editContact(contact),
          onDelete: () async {
            await deleteContact(contact);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  Future<void> deleteContact(Contact contact) async {
    setState(() {
      contactsList.remove(contact);
      removeRecentlyEdited(contact);
    });
    await StorageService.saveContacts(contactsList);
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search contacts...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onChanged: (value) {
          // Implement search functionality if needed
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.contacts_outlined,
            size: 64,
            color: Colors.grey,
          ),
          SizedBox(height: 16),
          Text(
            'No contacts yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: createContact,
            icon: Icon(Icons.add),
            label: Text('Add your first contact'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecentlyEditedScreen(
                    recentlyEditedContacts: recentlyEditedContacts,
                    onViewContact: viewContact,
                  ),
                ),
              );
            },
            icon: Icon(Icons.history, color: Colors.white),
            label: Text(
              'Recent',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: contactsList.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
              itemCount: contactsList.length,
              itemBuilder: (context, index) {
                final contact = contactsList[index];
                final String contactId = '${contact.name}_${contact.phone}';

                return ContactCard(
                  contact: contact,
                  isExpanded: expandedCards.contains(contactId),
                  onToggle: () => toggleCard(contactId),
                  onTap: () => viewContact(contact),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createContact,
        tooltip: 'Add Contact',
        child: Icon(Icons.add)
      ),
    );
  }
}