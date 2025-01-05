import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(ContactsApp());

class Contact {
  String name;
  String phone;
  String email;
  DateTime? birthday;
  String? picture;

  Contact({
    required this.name,
    required this.phone,
    required this.email,
    this.birthday,
    this.picture,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'birthday': birthday?.toIso8601String(),
      'picture': picture,
    };
  }

  static Contact fromJson(Map<String, dynamic> json) {
    return Contact(
      name: json['name'],
      phone: json['phone'],
      email: json['email'],
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'])
          : null,
      picture: json['picture'],
    );
  }
}

class ContactsApp extends StatelessWidget {
  const ContactsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Contacts',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List<Contact> contactsList = [];

  @override
  void initState() {
    super.initState();
    loadContacts();
  }

  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? contactsJson = prefs.getString('contacts');
    if (contactsJson != null) {
      List<dynamic> contactList = json.decode(contactsJson);
      setState(() {
        contactsList = contactList
            .map((contactJson) => Contact.fromJson(contactJson))
            .toList();
      });
    }
  }

  Future<void> saveContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> contactJsonList =
    contactsList.map((contact) => contact.toJson()).toList();
    await prefs.setString('contacts', json.encode(contactJsonList));
  }

  void createContact() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateContactScreen(
          onSave: (contact) {
            setState(() {
              contactsList.add(contact);
            });
            saveContacts();
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
          onSave: (updatedContact) {
            setState(() {
              final index = contactsList.indexOf(contact);
              contactsList[index] = updatedContact;
            });
            saveContacts();
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
      ),
      body: ListView.builder(
        itemCount: contactsList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(contactsList[index].name),
            onTap: () => viewContact(contactsList[index]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createContact,
        child: Icon(Icons.add),
      ),
    );
  }
}

class CreateContactScreen extends StatefulWidget {
  final Function(Contact) onSave;
  final Contact? contact;

  const CreateContactScreen({super.key, required this.onSave, this.contact});

  @override
  State<CreateContactScreen> createState() => _CreateContactScreenState();
}

class _CreateContactScreenState extends State<CreateContactScreen> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  DateTime? birthday;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      nameController = TextEditingController(text: widget.contact!.name);
      phoneController = TextEditingController(text: widget.contact!.phone);
      emailController = TextEditingController(text: widget.contact!.email);
      birthday = widget.contact!.birthday;
    } else {
      nameController = TextEditingController();
      phoneController = TextEditingController();
      emailController = TextEditingController();
    }
  }


  Future<void> _selectBirthday(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: birthday ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != birthday) {
      setState(() {
        birthday = picked;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.contact != null ? "Edit Contact" : "Create Contact")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text(
                  birthday != null
                      ? 'Birthday: ${birthday!.toLocal()}'
                      : 'Select Birthday',
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectBirthday(context),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final contact = Contact(
                  name: nameController.text,
                  phone: phoneController.text,
                  email: emailController.text,
                  birthday: birthday,
                );
                widget.onSave(contact);
              },
              child: Text(widget.contact != null ? 'Update Contact' : 'Save Contact'),
            ),
          ],
        ),
      ),
    );
  }
}

class ViewContactScreen extends StatefulWidget {
  final Contact contact;
  final VoidCallback onEdit;

  const ViewContactScreen({super.key, required this.contact, required this.onEdit});

  @override
  State<ViewContactScreen> createState() => _ViewContactScreenState();
}

class _ViewContactScreenState extends State<ViewContactScreen> {
  late Contact contact;

  @override
  void initState() {
    super.initState();
    contact = widget.contact;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contact.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Name: ${contact.name}"),
            Text("Phone: ${contact.phone}"),
            Text("Email: ${contact.email}"),
            Text("Birthday: ${contact.birthday != null ? contact.birthday!.toLocal().toString().split(' ')[0] : 'N/A'}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: widget.onEdit,
              child: Text('Edit Contact'),
            ),
          ],
        ),
      ),
    );
  }
}