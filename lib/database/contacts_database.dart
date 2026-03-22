import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ContactsDatabase {
  static final ContactsDatabase instance = ContactsDatabase._init();
  static Database? _database;

  ContactsDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('contacts.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE contacts (
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL,
phone TEXT NOT NULL,
email TEXT NOT NULL,
photoPath TEXT,
createdAt TEXT NOT NULL
)
''');

    await db.execute('CREATE INDEX idx_name ON contacts (name)');
    await db.execute('CREATE INDEX idx_phone ON contacts (phone)');
  }
}