import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(ContactsApp());

class Contact {
  String name;
  String phone;
  String email;
  DateTime? birthday;
  String? picture;
  double? latitude;
  double? longitude;
  DateTime lastEdited;

  Contact({
    required this.name,
    required this.phone,
    required this.email,
    this.birthday,
    this.picture,
    this.latitude,
    this.longitude,
    DateTime? lastEdited,
  }) : lastEdited = lastEdited ?? DateTime.now();

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'birthday': birthday?.toIso8601String(),
      'picture': picture,
      'latitude': latitude,
      'longitude': longitude,
      'lastEdited': lastEdited.toIso8601String(),
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
      latitude: json['latitude'],
      longitude: json['longitude'],
      lastEdited: DateTime.parse(json['lastEdited']),
    );
  }
}

class ContactsApp extends StatelessWidget {
  const ContactsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contacts',
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
  List<Contact> recentlyEditedContacts = [];
  Set<String> expandedCards = {};

  @override
  void initState() {
    super.initState();
    loadContacts();
    loadRecentlyEdited();
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

  Future<void> loadRecentlyEdited() async {
    final prefs = await SharedPreferences.getInstance();
    final String? recentJson = prefs.getString('recent_contacts');
    if (recentJson != null) {
      List<dynamic> recentList = json.decode(recentJson);
      setState(() {
        recentlyEditedContacts = recentList
            .map((contactJson) => Contact.fromJson(contactJson))
            .toList();
      });
    }
  }

  Future<void> saveRecentlyEdited() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> recentJsonList =
    recentlyEditedContacts.map((contact) => contact.toJson()).toList();
    await prefs.setString('recent_contacts', json.encode(recentJsonList));
  }

  void updateRecentlyEdited(Contact contact) {
    setState(() {
      recentlyEditedContacts.removeWhere((c) =>
      c.name == contact.name && c.phone == contact.phone
      );

      recentlyEditedContacts.insert(0, contact);

      if (recentlyEditedContacts.length > 10) {
        recentlyEditedContacts = recentlyEditedContacts.sublist(0, 10);
      }
    });

    saveRecentlyEdited();
  }

  void removeRecentlyEdited(Contact contact) {
    setState(() {
      recentlyEditedContacts.removeWhere((c) =>
      c.name == contact.name && c.phone == contact.phone
      );
    });

    saveRecentlyEdited();
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
              updateRecentlyEdited(contact);
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
              updateRecentlyEdited(updatedContact);
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
          onDelete: () {
            deleteContact(contact);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  void deleteContact(Contact contact) {
    setState(() {
      contactsList.remove(contact);
      removeRecentlyEdited(contact);
    });
    saveContacts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Contacts'),
        actions: [
          TextButton(
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
            child: Text('Recently Edited'),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: contactsList.length,
        itemBuilder: (context, index) {
          final contact = contactsList[index];
          return buildContactCard(contact);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createContact,
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildContactCard(Contact contact) {
    final String contactId = '${contact.name}_${contact.phone}';
    final bool isExpanded = expandedCards.contains(contactId);

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
              onPressed: () => toggleCard(contactId),
            ),
            onTap: () => viewContact(contact),
          ),
          if (isExpanded)
            Container(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phone: ${contact.phone}'),
                  Text('Email: ${contact.email}'),
                  if (contact.birthday != null) Text('Birthday: ${contact.birthday!.toLocal()}'),
                  if (contact.latitude != null && contact.longitude != null)
                    Text('Location: ${contact.latitude?.toStringAsFixed(2)}, ${contact.longitude?.toStringAsFixed(2)}'),
                  SizedBox(height: 8),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

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
            subtitle: Text('Last edited: ${contact.lastEdited}'),
          );
        },
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
  XFile? image;
  double? latitude;
  double? longitude;

  final ImagePicker _picker = ImagePicker();
  late GoogleMapController mapController;
  LatLng? selectedLocation;

  @override
  void initState() {
    super.initState();
    if (widget.contact != null) {
      nameController = TextEditingController(text: widget.contact!.name);
      phoneController = TextEditingController(text: widget.contact!.phone);
      emailController = TextEditingController(text: widget.contact!.email);
      birthday = widget.contact!.birthday;
      image = widget.contact!.picture != null
          ? XFile(widget.contact!.picture!)
          : null;
      latitude = widget.contact!.latitude;
      longitude = widget.contact!.longitude;
      selectedLocation = LatLng(latitude!, longitude!);
    } else {
      nameController = TextEditingController();
      phoneController = TextEditingController();
      emailController = TextEditingController();
    }
  }

  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
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

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = pickedFile;
      });
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  void _onTapMap(LatLng position) {
    setState(() {
      selectedLocation = position;
      latitude = position.latitude;
      longitude = position.longitude;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.contact != null ? "Edit Contact" : "Create Contact"),
      ),
      body: SingleChildScrollView(
        child: Padding(
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
                        ? 'Birthday: ${birthday!.toLocal().toString().split(' ')[0]}'
                        : 'Select Birthday',
                  ),
                  IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectBirthday(context),
                  ),
                ],
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: image == null
                    ? Container(
                  height: 100,
                  width: 100,
                  color: Colors.grey[300],
                  child: Icon(Icons.add_a_photo),
                )
                    : Image.file(
                  File(image!.path),
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final position = await getCurrentLocation();
                    if (position != null) {
                      setState(() {
                        latitude = position.latitude;
                        longitude = position.longitude;
                        selectedLocation = LatLng(latitude!, longitude!);
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error fetching location: $e')),
                    );
                  }
                },
                child: Text('Add Current Location'),
              ),
              if (latitude != null && longitude != null)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'Location: Lat $latitude, Long $longitude',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              SizedBox(height: 20),
              selectedLocation != null
                  ? Container(
                height: 200,
                width: double.infinity,
                child: GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: selectedLocation!,
                    zoom: 14,
                  ),
                  markers: selectedLocation != null
                      ? {
                    Marker(
                      markerId: MarkerId('selected-location'),
                      position: selectedLocation!,
                    ),
                  }
                      : {},
                  onTap: _onTapMap,
                ),
              )
                  : Container(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  final contact = Contact(
                    name: nameController.text,
                    phone: phoneController.text,
                    email: emailController.text,
                    birthday: birthday,
                    picture: image?.path,
                    latitude: latitude,
                    longitude: longitude,
                  );
                  widget.onSave(contact);
                },
                child: Text(widget.contact != null ? 'Update Contact' : 'Save Contact'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ViewContactScreen extends StatefulWidget {
  final Contact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ViewContactScreen({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete});

  @override
  State<ViewContactScreen> createState() => _ViewContactScreenState();
}

class _ViewContactScreenState extends State<ViewContactScreen> {
  late Contact contact;
  GoogleMapController? mapController;

  @override
  void initState() {
    super.initState();
    contact = widget.contact;
  }

  Widget _buildContactInfo() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow(Icons.person, "Name", contact.name),
            _buildInfoRow(Icons.phone, "Phone", contact.phone),
            _buildInfoRow(Icons.email, "Email", contact.email),
            _buildInfoRow(Icons.cake, "Birthday", contact.birthday.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (contact.latitude == null || contact.longitude == null) {
      return Card(
        elevation: 4,
        child: Container(
          height: 200,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text("Location not available",
                  style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 4,
      child: SizedBox(
        height: 200,
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(contact.latitude!, contact.longitude!),
            zoom: 14,
          ),
          markers: {
            Marker(
              markerId: MarkerId(contact.name),
              position: LatLng(contact.latitude!, contact.longitude!),
              infoWindow: InfoWindow(title: contact.name),
            ),
          },
          onMapCreated: (GoogleMapController controller) {
            mapController = controller;
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.onEdit,
            icon: Icon(Icons.edit),
            label: Text('Edit Contact'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: widget.onDelete,
            icon: Icon(Icons.delete),
            label: Text('Delete Contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    Widget profileImage = SizedBox(
      width: isLandscape ? 200 : double.infinity,
      height: isLandscape ? MediaQuery.of(context).size.height * 0.4 : 200,
      child: Card(
        elevation: 4,
        child: contact.picture != null
            ? Image.file(
          File(contact.picture!),
          fit: BoxFit.cover,
        )
            : Container(
          color: Colors.grey[200],
          child: Icon(
            Icons.person,
            size: isLandscape ? 64 : 80,
            color: Colors.grey[400],
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Contact Details"),
        elevation: 0,
      ),
      body: SafeArea(
        child: isLandscape
            ? Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: profileImage,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildContactInfo(),
                    SizedBox(height: 16),
                    _buildMap(),
                    SizedBox(height: 16),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              profileImage,
              SizedBox(height: 16),
              _buildContactInfo(),
              SizedBox(height: 16),
              _buildMap(),
              SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }
}