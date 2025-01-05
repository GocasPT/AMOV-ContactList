import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/contact.dart';
import '../services/location_service.dart';

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
      if (latitude != null && longitude != null) {
        selectedLocation = LatLng(latitude!, longitude!);
      }
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

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        image = pickedFile;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await LocationService.getCurrentLocation();
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
                onPressed: _getCurrentLocation,
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
              if (selectedLocation != null)
                Container(
                  height: 200,
                  width: double.infinity,
                  child: GoogleMap(
                    onMapCreated: _onMapCreated,
                    initialCameraPosition: CameraPosition(
                      target: selectedLocation!,
                      zoom: 14,
                    ),
                    markers: {
                      Marker(
                        markerId: MarkerId('selected-location'),
                        position: selectedLocation!,
                      ),
                    },
                    onTap: _onTapMap,
                  ),
                ),
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
