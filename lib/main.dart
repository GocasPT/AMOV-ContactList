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

  Contact({
    required this.name,
    required this.phone,
    required this.email,
    this.birthday,
    this.picture,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'birthday': birthday?.toIso8601String(),
      'picture': picture,
      'latitude': latitude,
      'longitude': longitude,
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
    });
    saveContacts();
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

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contact.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            contact.picture != null
                ? Image.file(File(contact.picture!), height: 100, width: 100, fit: BoxFit.cover)
                : Container(
              height: 100,
              width: 100,
              color: Colors.grey[300],
              child: Icon(Icons.person),
            ),
            SizedBox(height: 20),
            Text("Name: ${contact.name}"),
            Text("Phone: ${contact.phone}"),
            Text("Email: ${contact.email}"),
            Text("Birthday: ${contact.birthday ?? 'N/A'}"),
            SizedBox(height: 20),
            contact.latitude != null && contact.longitude != null
                ? Expanded(
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
            )
                : Text("Location: Not available"),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: widget.onEdit,
                  child: Text('Edit Contact'),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: widget.onDelete,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: Text('Delete Contact'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}