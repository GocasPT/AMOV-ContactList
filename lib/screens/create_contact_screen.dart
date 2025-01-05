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
  String? nameError;
  String? phoneError;

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

    // Add listeners to clear errors when text changes
    nameController.addListener(() {
      if (nameError != null) {
        setState(() {
          nameError = null;
        });
      }
    });

    phoneController.addListener(() {
      if (phoneError != null) {
        setState(() {
          phoneError = null;
        });
      }
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.dispose();
  }

  bool _validateInputs() {
    bool isValid = true;
    setState(() {
      nameError = null;
      phoneError = null;

      if (nameController.text.trim().isEmpty) {
        nameError = 'Name is required';
        isValid = false;
      }

      if (phoneController.text.trim().isEmpty) {
        phoneError = 'Phone number is required';
        isValid = false;
      }
    });
    return isValid;
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching location: $e')),
        );
      }
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? errorText,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.blue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        errorText: errorText,
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.contact != null ? "Edit Contact" : "Create Contact",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        border: Border.all(color: Colors.blue, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: image == null
                            ? Icon(Icons.add_a_photo,
                            size: 40, color: Colors.blue[300])
                            : Image.file(
                          File(image!.path),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: nameController,
                          label: 'Name',
                          icon: Icons.person,
                          errorText: nameError,
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: phoneController,
                          label: 'Phone',
                          icon: Icons.phone,
                          errorText: phoneError,
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 16),
                        _buildTextField(
                          controller: emailController,
                          label: 'Email',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        InkWell(
                          onTap: () => _selectBirthday(context),
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              children: [
                                Icon(Icons.cake, color: Colors.blue),
                                SizedBox(width: 12),
                                Text(
                                  birthday != null
                                      ? 'Birthday: ${birthday!.toLocal().toString().split(' ')[0]}'
                                      : 'Select Birthday',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: _getCurrentLocation,
                            icon: Icon(Icons.location_on),
                            label: Text('Add Current Location'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        if (latitude != null && longitude != null) ...[
                          SizedBox(height: 16),
                          Center(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                              ),
                              child: Text(
                                'Location: Lat ${latitude!.toStringAsFixed(4)}, Long ${longitude!.toStringAsFixed(4)}',
                                style: TextStyle(color: Colors.grey[700]),
                              ),
                            ),
                          ),
                        ],
                        if (selectedLocation != null) ...[
                          SizedBox(height: 16),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: SizedBox(
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
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_validateInputs()) {
                        final contact = Contact(
                          name: nameController.text.trim(),
                          phone: phoneController.text.trim(),
                          email: emailController.text.trim(),
                          birthday: birthday,
                          picture: image?.path,
                          latitude: latitude,
                          longitude: longitude,
                        );
                        widget.onSave(contact);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please fill in all required fields'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            action: SnackBarAction(
                              label: 'OK',
                              textColor: Colors.white,
                              onPressed: () {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                              },
                            ),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      widget.contact != null ? 'Update Contact' : 'Save Contact',
                      style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}