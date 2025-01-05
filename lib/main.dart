import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/viewmodels/contact_viewmodel.dart';
import 'screens/main_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ContactViewModel(),
      child: ContactsApp(),
    ),
  );
}

class ContactsApp extends StatelessWidget {
  const ContactsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Contact List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainScreen(),
    );
  }
}