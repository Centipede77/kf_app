import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/contact.dart';
import '../repository/contact_repository.dart';

class AddEditContactScreen extends StatefulWidget {
  final Contact? contact; // null → додати, не null → редагувати

  AddEditContactScreen({this.contact});

  @override
  State<AddEditContactScreen> createState() =>
      _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final repo = ContactRepository();

  String name = '';
  String phone = '';
  String email = '';
  File? image;

  @override
  void initState() {
    super.initState();

    if (widget.contact != null) {
      name = widget.contact!.name;
      phone = widget.contact!.phone;
      email = widget.contact!.email;
    }
  }

  Future pickImage() async {
    final picked =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        image = File(picked.path);
      });
    }
  }

  void save() async {
    print("SAVE CLICKED"); // debug

    if (!_formKey.currentState!.validate()) {
      print("VALIDATION FAILED");
      return;
    }

    _formKey.currentState!.save();
    print("DATA: $name $phone $email");

    if (widget.contact == null) {
      // Додавання нового контакту
      final contact = Contact(
        name: name,
        phone: phone,
        email: email,
        createdAt: DateTime.now(),
      );

      await repo.insert(contact, image);
    } else {
      // Редагування існуючого контакту
      final updated = widget.contact!.copyWith(
        name: name,
        phone: phone,
        email: email,
      );

      await repo.update(updated, image);
    }

    Navigator.pop(context, true); // повертаємо результат
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.contact != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? "Редагувати контакт" : "Додати контакт"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: image != null
                      ? FileImage(image!)
                      : widget.contact?.photoPath != null
                          ? FileImage(File(widget.contact!.photoPath!))
                          : null,
                  child: image == null &&
                          widget.contact?.photoPath == null
                      ? Icon(Icons.add_a_photo, size: 40)
                      : null,
                ),
              ),
              SizedBox(height: 20),

              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: "Ім'я"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Введіть ім'я" : null,
                onSaved: (v) => name = v!,
              ),
              SizedBox(height: 10),

              TextFormField(
                initialValue: phone,
                decoration: InputDecoration(labelText: "Телефон"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Введіть телефон" : null,
                onSaved: (v) => phone = v!,
              ),
              SizedBox(height: 10),

              TextFormField(
                initialValue: email,
                decoration: InputDecoration(labelText: "Email"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Введіть email" : null,
                onSaved: (v) => email = v!,
              ),
              SizedBox(height: 20),

              ElevatedButton(
                onPressed: save,
                child: Text(isEdit ? "Зберегти зміни" : "Додати контакт"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}