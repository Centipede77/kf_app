import 'dart:io';
import '../models/contact.dart';
import '../database/contacts_database.dart';
import '../services/photo_manager.dart';

class ContactRepository {
  final _db = ContactsDatabase.instance;
  final _photo = PhotoManager();

  Future<int> insert(Contact contact, File? photoFile) async {
    final db = await _db.database;

    String? photoPath;
    if (photoFile != null) {
      photoPath = await _photo.savePhoto(photoFile);
    }

    final newContact = contact.copyWith(photoPath: photoPath);

    return db.insert('contacts', newContact.toMap());
  }

  Future<int> update(Contact contact, File? newPhoto) async {
    final db = await _db.database;

    String? photoPath = contact.photoPath;

    if (newPhoto != null) {
      await _photo.deletePhoto(contact.photoPath);
      photoPath = await _photo.savePhoto(newPhoto);
    }

    final updated = contact.copyWith(photoPath: photoPath);

    return db.update(
      'contacts',
      updated.toMap(),
      where: 'id = ?',
      whereArgs: [contact.id],
    );
  }

  Future<List<Contact>> getAll() async {
    final db = await _db.database;

    final maps = await db.query('contacts', orderBy: 'name');

    return maps.map((e) => Contact.fromMap(e)).toList();
  }

  Future<int> delete(Contact contact) async {
    final db = await _db.database;

    await _photo.deletePhoto(contact.photoPath);

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
    );

    return maps.map((e) => Contact.fromMap(e)).toList();
  }
}