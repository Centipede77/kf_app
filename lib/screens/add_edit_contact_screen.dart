import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/contact.dart';
import '../repository/contact_repository.dart';

class AddEditContactScreen extends StatefulWidget {
  final Contact? contact;

  const AddEditContactScreen({super.key, this.contact});

  @override
  State<AddEditContactScreen> createState() => _AddEditContactScreenState();
}

class _AddEditContactScreenState extends State<AddEditContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final ContactRepository _repo = ContactRepository();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;

  File? _imageFile;
  bool _removeCurrentPhoto = false;
  bool _isSaving = false;

  bool get _isEdit => widget.contact != null;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phone ?? '');
    _emailController = TextEditingController(text: widget.contact?.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
        _removeCurrentPhoto = false;
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _imageFile = null;
      _removeCurrentPhoto = true;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();
    final email = _emailController.text.trim();

    try {
      if (!_isEdit) {
        final contact = Contact(
          name: name,
          phone: phone,
          email: email,
          photoPath: null,
          createdAt: DateTime.now(),
        );

        await _repo.insert(contact, _imageFile);
      } else {
        final oldContact = widget.contact!;
        final updatedContact = oldContact.copyWith(
          name: name,
          phone: phone,
          email: email,
        );

        await _repo.update(
          oldContact,
          updatedContact,
          _imageFile,
          removePhoto: _removeCurrentPhoto,
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Введіть $fieldName';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Введіть email';
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Введіть коректний email';
    }

    return null;
  }

  ImageProvider? _buildImageProvider() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    }

    final existingPath = widget.contact?.photoPath;
    if (_removeCurrentPhoto ||
        existingPath == null ||
        existingPath.trim().isEmpty) {
      return null;
    }

    final file = File(existingPath);
    if (!file.existsSync()) {
      return null;
    }

    return FileImage(file);
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _buildImageProvider();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Редагувати контакт' : 'Додати контакт'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 56,
                        backgroundImage: imageProvider,
                        child: imageProvider == null
                            ? const Icon(Icons.add_a_photo, size: 36)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Обрати фото'),
                        ),
                        if (_isEdit &&
                            (_imageFile != null ||
                                (widget.contact?.photoPath != null &&
                                    !_removeCurrentPhoto)))
                          TextButton.icon(
                            onPressed: _removePhoto,
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Видалити фото'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Ім’я',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
                validator: (value) => _validateRequired(value, 'ім’я'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Телефон',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                validator: (value) => _validateRequired(value, 'телефон'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                child: Text(
                  _isSaving
                      ? 'Збереження...'
                      : _isEdit
                          ? 'Зберегти зміни'
                          : 'Додати контакт',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}