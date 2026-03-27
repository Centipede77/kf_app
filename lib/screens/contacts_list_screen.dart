import 'dart:io';

import 'package:flutter/material.dart';

import '../models/contact.dart';
import '../repository/contact_repository.dart';
import 'add_edit_contact_screen.dart';
import 'contact_detail_screen.dart';

enum ContactPhotoFilter { all, withPhoto, withoutPhoto }

class ContactsListScreen extends StatefulWidget {
  const ContactsListScreen({super.key});

  @override
  State<ContactsListScreen> createState() => _ContactsListScreenState();
}

class _ContactsListScreenState extends State<ContactsListScreen> {
  final ContactRepository _repo = ContactRepository();
  final TextEditingController _searchController = TextEditingController();

  List<Contact> _contacts = [];
  bool _isLoading = true;
  String _searchQuery = '';
  ContactPhotoFilter _photoFilter = ContactPhotoFilter.all;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() {
      _isLoading = true;
    });

    bool? hasPhoto;
    switch (_photoFilter) {
      case ContactPhotoFilter.all:
        hasPhoto = null;
        break;
      case ContactPhotoFilter.withPhoto:
        hasPhoto = true;
        break;
      case ContactPhotoFilter.withoutPhoto:
        hasPhoto = false;
        break;
    }

    final contacts = await _repo.getFilteredContacts(
      query: _searchQuery,
      hasPhoto: hasPhoto,
    );

    if (!mounted) return;

    setState(() {
      _contacts = contacts;
      _isLoading = false;
    });
  }

  Future<void> _openAddScreen() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddEditContactScreen(),
      ),
    );

    if (result == true) {
      await _loadContacts();
    }
  }

  Future<void> _openDetails(Contact contact) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ContactDetailScreen(contact: contact),
      ),
    );

    if (result == true) {
      await _loadContacts();
    }
  }

  Future<void> _editContact(Contact contact) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditContactScreen(contact: contact),
      ),
    );

    if (result == true) {
      await _loadContacts();
    }
  }

  Future<void> _deleteContact(Contact contact) async {
    final confirmed = await _confirmDelete();
    if (!confirmed) return;

    await _repo.delete(contact);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Контакт "${contact.name}" видалено'),
      ),
    );

    await _loadContacts();
  }

  Future<bool> _confirmDelete() async {
    final result = await showDialog<bool>(
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

    return result ?? false;
  }

  String _filterLabel(ContactPhotoFilter filter) {
    switch (filter) {
      case ContactPhotoFilter.all:
        return 'Усі';
      case ContactPhotoFilter.withPhoto:
        return 'З фото';
      case ContactPhotoFilter.withoutPhoto:
        return 'Без фото';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Контакти'),
        actions: [
          PopupMenuButton<ContactPhotoFilter>(
            initialValue: _photoFilter,
            onSelected: (value) {
              setState(() {
                _photoFilter = value;
              });
              _loadContacts();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ContactPhotoFilter.all,
                child: Text('Усі контакти'),
              ),
              const PopupMenuItem(
                value: ContactPhotoFilter.withPhoto,
                child: Text('Тільки з фото'),
              ),
              const PopupMenuItem(
                value: ContactPhotoFilter.withoutPhoto,
                child: Text('Тільки без фото'),
              ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddScreen,
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Пошук за ім’ям або телефоном',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                              _loadContacts();
                            },
                            icon: const Icon(Icons.clear),
                          )
                        : null,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _loadContacts();
                  },
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Chip(
                    label: Text('Фільтр: ${_filterLabel(_photoFilter)}'),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_contacts.isEmpty) {
      final hasSearch = _searchQuery.trim().isNotEmpty;
      final hasFilter = _photoFilter != ContactPhotoFilter.all;

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            hasSearch || hasFilter
                ? 'Нічого не знайдено за поточними умовами'
                : 'Контактів поки немає',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _contacts.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final contact = _contacts[index];
        return ListTile(
          leading: _ContactAvatar(photoPath: contact.photoPath),
          title: Text(contact.name),
          subtitle: Text(contact.phone),
          onTap: () => _openDetails(contact),
          trailing: PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'edit') {
                _editContact(contact);
              } else if (value == 'delete') {
                _deleteContact(contact);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'edit',
                child: Text('Редагувати'),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Text('Видалити'),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ContactAvatar extends StatelessWidget {
  final String? photoPath;

  const _ContactAvatar({required this.photoPath});

  @override
  Widget build(BuildContext context) {
    if (photoPath == null || photoPath!.trim().isEmpty) {
      return const CircleAvatar(
        child: Icon(Icons.person),
      );
    }

    final file = File(photoPath!);
    if (!file.existsSync()) {
      return const CircleAvatar(
        child: Icon(Icons.person_off),
      );
    }

    return CircleAvatar(
      backgroundImage: FileImage(file),
    );
  }
}