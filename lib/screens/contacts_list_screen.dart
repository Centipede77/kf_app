import 'dart:io';
import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../repository/contact_repository.dart';
import 'add_edit_contact_screen.dart';

class ContactsListScreen extends StatefulWidget {
  @override
  State<ContactsListScreen> createState() =>
      _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  final repo = ContactRepository();
  List<Contact> contacts = [];

  @override
  void initState() {
    super.initState();
    load();
  }

  void load() async {
    contacts = await repo.getAll();
    setState(() {});
  }

  void delete(Contact c) async {
    await repo.delete(c);
    load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Контакти")),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final res = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditContactScreen(),
            ),
          );
          if (res == true) load();
        },
        child: Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: contacts.length,
        itemBuilder: (_, i) {
          final c = contacts[i];

          return ListTile(
            leading: CircleAvatar(
              backgroundImage: c.photoPath != null
                  ? FileImage(File(c.photoPath!))
                  : null,
              child: c.photoPath == null
                  ? Icon(Icons.person)
                  : null,
            ),
            title: Text(c.name),
            subtitle: Text(c.phone),

            onTap: () async {
              final res = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      AddEditContactScreen(contact: c),
                ),
              );
              if (res == true) load();
            },

            onLongPress: () => delete(c),
          );
        },
      ),
    );
  }
}