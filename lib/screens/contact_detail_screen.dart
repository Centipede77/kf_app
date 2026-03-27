import 'dart:io';

import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../repository/contact_repository.dart';
import 'add_edit_contact_screen.dart';

class ContactDetailScreen extends StatefulWidget {
  final Contact contact;

  const ContactDetailScreen({super.key, required this.contact});

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  final ContactRepository _repo = ContactRepository();

  late Contact _contact;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
  }

  Future<void> _editContact() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditContactScreen(contact: _contact),
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _deleteContact() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Видалити контакт?'),
          content: const Text('Цю дію не можна скасувати.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Скасувати'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Видалити'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _repo.delete(_contact);

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = _buildImageProvider(_contact.photoPath);

    return Scaffold(
      appBar: AppBar(
        title: Text(_contact.name),
        actions: [
          IconButton(
            onPressed: _editContact,
            icon: const Icon(Icons.edit),
          ),
          IconButton(
            onPressed: _deleteContact,
            icon: const Icon(Icons.delete),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Center(
              child: CircleAvatar(
                radius: 64,
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? const Icon(Icons.person, size: 64)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            _InfoTile(
              title: 'Ім’я',
              value: _contact.name,
              icon: Icons.badge_outlined,
            ),
            _InfoTile(
              title: 'Телефон',
              value: _contact.phone,
              icon: Icons.phone_outlined,
            ),
            _InfoTile(
              title: 'Email',
              value: _contact.email,
              icon: Icons.email_outlined,
            ),
            _InfoTile(
              title: 'Створено',
              value: _formatDate(_contact.createdAt),
              icon: Icons.calendar_today_outlined,
            ),
            _InfoTile(
              title: 'Фото',
              value: _contact.photoPath == null ? 'Немає' : 'Додано',
              icon: Icons.photo_outlined,
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _buildImageProvider(String? photoPath) {
    if (photoPath == null || photoPath.trim().isEmpty) {
      return null;
    }

    final file = File(photoPath);
    if (!file.existsSync()) {
      return null;
    }

    return FileImage(file);
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$day.$month.$year $hour:$minute';
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(value),
      ),
    );
  }
}