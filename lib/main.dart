import 'package:flutter/material.dart';
import 'model/contact.dart';
import 'model/contact_list.dart';
import 'viewmodel/contacts_viewmodel.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ContactsScreen(),
    );
  }
}

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ContactsList contactsList = ContactsList();
  late ContactsViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = ContactsViewModel(contactsList: contactsList);
  }

  void _navigateToContactForm([Contact? contact]) {
    if (contact != null) {
      viewModel.selectContact(contact);
    } else {
      viewModel.createContact();
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContactFormScreen(
          onSave: (String name, String phone, String email) {
            viewModel.updateContactDetails(name, phone, email);
            if(viewModel.saveContact()) {
              setState(() {});
              Navigator.pop(context);
            }
          },
          contact: contact,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Contacts List')),
      body: ListView.builder(
        itemCount: contactsList.getContacts().length,
        itemBuilder: (context, index) {
          final contact = contactsList.getContacts()[index];
          return ListTile(
            title: Text(contact.name),
            subtitle: Text(contact.phoneNumber),
            onTap: () => _navigateToContactForm(contact),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToContactForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}

class ContactFormScreen extends StatefulWidget {
  final void Function(String name, String phone, String email) onSave;
  final Contact? contact;

  const ContactFormScreen({
    super.key,
    required this.onSave,
    this.contact,
  });

  @override
  State<ContactFormScreen> createState() => _ContactFormScreenState();
}

class _ContactFormScreenState extends State<ContactFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phoneNumber ?? '');
    _emailController = TextEditingController(text: widget.contact?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Contact'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) => value == null || value.isEmpty
                    ? 'Name is required'
                    : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty
                    ? 'Phone number is required'
                    : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value == null || value.isEmpty
                    ? 'Email is required'
                    : null,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                        widget.onSave(
                          _nameController.text,
                          _phoneController.text,
                          _emailController.text,
                        );
                      },
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
