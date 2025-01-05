import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/contact.dart';
import '../models/viewmodels/contact_viewmodel.dart';
import '../services/navigation_service.dart';
import '../widgets/contact_card.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  Widget _buildEmptyState(BuildContext context, ContactViewModel viewModel) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.contacts_outlined, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No contacts yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600]),
          ),
          SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _createContact(context, viewModel),
            icon: Icon(Icons.add),
            label: Text('Add your first contact'),
          ),
        ],
      ),
    );
  }

  void _createContact(BuildContext context, ContactViewModel viewModel) {
    NavigationService.navigateToCreateContact(
      context,
          (contact) async {
        await viewModel.addContact(contact);
        if(context.mounted) NavigationService.pop(context);
      },
    );
  }

  void _editContact(BuildContext context, ContactViewModel viewModel, Contact contact) {
    NavigationService.navigateToCreateContact(
      context,
          (updatedContact) async {
        await viewModel.updateContact(contact, updatedContact);
        if(context.mounted) NavigationService.pop(context);
        if(context.mounted) NavigationService.pop(context);
      },
      contact: contact,
    );
  }

  void _viewContact(BuildContext context, ContactViewModel viewModel, Contact contact) {
    NavigationService.navigateToViewContact(
      context,
      contact,
          () => _editContact(context, viewModel, contact),
          () async {
        await viewModel.deleteContact(contact);
        if(context.mounted) NavigationService.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContactViewModel>(
      builder: (context, viewModel, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Contacts'),
            actions: [
              TextButton.icon(
                onPressed: () => NavigationService.navigateToRecentlyEdited(
                  context,
                  viewModel.recentlyEditedContacts,
                      (contact) => _viewContact(context, viewModel, contact),
                ),
                icon: Icon(Icons.history, color: Colors.white),
                label: Text('Recent', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          body: viewModel.isEmpty
              ? _buildEmptyState(context, viewModel)
              : ListView.builder(
            itemCount: viewModel.contactsList.length,
            itemBuilder: (context, index) {
              final contact = viewModel.contactsList[index];
              final contactId = '${contact.name}_${contact.phone}';

              return ContactCard(
                contact: contact,
                isExpanded: viewModel.expandedCards.contains(contactId),
                onToggle: () => viewModel.toggleCard(contactId),
                onTap: () => _viewContact(context, viewModel, contact),
              );
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _createContact(context, viewModel),
            tooltip: 'Add Contact',
            child: Icon(Icons.add),
          ),
        );
      },
    );
  }
}