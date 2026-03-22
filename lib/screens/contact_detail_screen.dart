import 'dart:io';
import 'package:flutter/material.dart';
import '../models/contact.dart';

class ContactDetailScreen extends StatelessWidget {
  final Contact contact;

  ContactDetailScreen({required this.contact});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(contact.name)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: contact.photoPath != null
                  ? FileImage(File(contact.photoPath!))
                  : null,
              child: contact.photoPath == null
                  ? Icon(Icons.person, size: 60)
                  : null,
            ),

            SizedBox(height: 20),

            Text("Телефон: ${contact.phone}"),
            Text("Email: ${contact.email}"),
            Text("Створено: ${contact.createdAt}"),
          ],
        ),
      ),
    );
  }
}