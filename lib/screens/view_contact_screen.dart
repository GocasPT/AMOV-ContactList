import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:io';
import '../models/contact.dart';

class ViewContactScreen extends StatefulWidget {
  final Contact contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ViewContactScreen({
    super.key,
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

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
            if (contact.birthday != null)
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