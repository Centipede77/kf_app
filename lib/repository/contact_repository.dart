import 'dart:io';

import '../database/contacts_database.dart';
import '../models/contact.dart';
import '../services/photo_manager.dart';

class ContactRepository {
  final ContactsDatabase _db = ContactsDatabase.instance;
  final PhotoManager _photoManager = PhotoManager();

  Future<int> insert(Contact contact, File? photoFile) async {
    final db = await _db.database;

    String? photoPath;
    if (photoFile != null) {
      photoPath = await _photoManager.savePhoto(photoFile);
    }

    final contactToSave = contact.copyWith(photoPath: photoPath);

    return db.insert('contacts', contactToSave.toMap());
  }

  Future<int> update(
    Contact oldContact,
    Contact updatedContact,
    File? newPhotoFile, {
    bool removePhoto = false,
  }) async {
    final db = await _db.database;

    String? photoPath = oldContact.photoPath;

    if (removePhoto) {
      await _photoManager.deletePhoto(oldContact.photoPath);
      photoPath = null;
    }

    if (newPhotoFile != null) {
      await _photoManager.deletePhoto(photoPath);
      photoPath = await _photoManager.savePhoto(newPhotoFile);
    }

    final contactToSave = updatedContact.copyWith(photoPath: photoPath);

    return db.update(
      'contacts',
      contactToSave.toMap(),
      where: 'id = ?',
      whereArgs: [oldContact.id],
    );
  }

  Future<List<Contact>> getAll() async {
    final db = await _db.database;

    final maps = await db.query(
      'contacts',
      orderBy: 'name ASC',
    );

    return maps.map((e) => Contact.fromMap(e)).toList();
  }

  Future<int> delete(Contact contact) async {
    final db = await _db.database;

    await _photoManager.deletePhoto(contact.photoPath);

    return db.delete(
      'contacts',
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<List<Contact>> searchByName(String query) async {
    final db = await _db.database;

    final maps = await db.query(
      'contacts',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );

    return maps.map((e) => Contact.fromMap(e)).toList();
  }

  Future<List<Contact>> searchByPhone(String query) async {
    final db = await _db.database;

    final maps = await db.query(
      'contacts',
      where: 'phone LIKE ?',
      whereArgs: ['%$query%'],
      orderBy: 'name ASC',
    );

    return maps.map((e) => Contact.fromMap(e)).toList();
  }

  Future<List<Contact>> search(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return getAll();
    }

    final db = await _db.database;

    final maps = await db.query(
      'contacts',
      where: 'name LIKE ? OR phone LIKE ?',
      whereArgs: ['%$trimmed%', '%$trimmed%'],
      orderBy: 'name ASC',
    );

    return maps.map((e) => Contact.fromMap(e)).toList();
  }

  Future<List<Contact>> getContactsWithPhotos() async {
    final db = await _db.database;

    final maps = await db.query(
      'contacts',
      where: 'photoPath IS NOT NULL AND photoPath != ?',
      whereArgs: [''],
      orderBy: 'name ASC',
    );

    return maps.map((e) => Contact.fromMap(e)).toList();
  }

  Future<List<Contact>> getContactsWithoutPhotos() async {
    final db = await _db.database;

    final maps = await db.query(
      'contacts',
      where: 'photoPath IS NULL OR photoPath = ?',
      whereArgs: [''],
      orderBy: 'name ASC',
    );

    return maps.map((e) => Contact.fromMap(e)).toList();
  }

  Future<List<Contact>> getFilteredContacts({
    String query = '',
    bool? hasPhoto,
  }) async {
    final db = await _db.database;

    final conditions = <String>[];
    final args = <dynamic>[];

    final trimmedQuery = query.trim();
    if (trimmedQuery.isNotEmpty) {
      conditions.add('(name LIKE ? OR phone LIKE ?)');
      args.add('%$trimmedQuery%');
      args.add('%$trimmedQuery%');
    }

    if (hasPhoto == true) {
      conditions.add('photoPath IS NOT NULL AND photoPath != ?');
      args.add('');
    } else if (hasPhoto == false) {
      conditions.add('(photoPath IS NULL OR photoPath = ?)');
      args.add('');
    }

    final maps = await db.query(
      'contacts',
      where: conditions.isEmpty ? null : conditions.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'name ASC',
    );

    return maps.map((e) => Contact.fromMap(e)).toList();
  }
}