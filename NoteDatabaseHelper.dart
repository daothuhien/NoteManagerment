import "package:app_02/BTNoteManagement/Model/Note.dart";
import "package:sqflite/sqflite.dart";
import 'package:path/path.dart';

class NoteDatabaseHelper {
  static final NoteDatabaseHelper instance = NoteDatabaseHelper._init();
  static Database? _database;

  NoteDatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notes_database.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        priority INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        modifiedAt TEXT NOT NULL,
        tags TEXT,
        color TEXT
      )
    ''');
    // Tạo sẵn dữ liệu mẫu
    await _insertSampleNotes(db);
  }

  Future _insertSampleNotes(Database db) async {
    final List<Map<String, dynamic>> sampleNotes = [
      {
        'title': 'Công thức nấu ăn',
        'content': 'Gà nướng mật ong, salad trộn, tráng miệng tiramisu.',
        'priority': 2,
        'createdAt': DateTime(2023, 10, 18, 14, 00).toIso8601String(),
        'modifiedAt': DateTime(2023, 10, 18, 14, 10).toIso8601String(),
        'tags': ["nấu ăn", "công thức", "gà nướng", "salad", "tiramisu"].join(','), // Truyền vào List<String>
        'color': '#FF800080', // Màu tím
      },
      {
        'title': 'Ghi chú công việc',
        'content': 'Hoàn thành báo cáo hàng tuần, gửi email cho khách hàng.',
        'priority': 1,
        'createdAt': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
        'modifiedAt': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
        'tags': ["công việc", "báo cáo"].join(','), // Truyền vào List<String>
        'color': '#FF0000FF', // Màu xanh dương
      },
    ];

    for (final noteData in sampleNotes) {

      await db.insert('notes', noteData);
    }
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }

  // CRUD Operations

  // Insert a new note
  Future<int> insertNote(Note note) async {
    final db = await instance.database;
    return await db.insert('notes', note.toMap());
  }

  // Get all notes
  Future<List<Note>> getAllNotes() async {
    final db = await instance.database;
    final result = await db.query('notes');

    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Get a note by ID
  Future<Note?> getNoteById(int id) async {
    final db = await instance.database;
    final maps = await db.query('notes', where: 'id = ?', whereArgs: [id]);

    if (maps.isNotEmpty) {
      return Note.fromMap(maps.first);
    }
    return null;
  }

  // Update a note
  Future<int> updateNote(Note note) async {
    final db = await instance.database;
    print('Updating note: ${note.toMap()}'); // In ra dữ liệu ghi chú
    final result = await db.update(
      'notes',
      note.toMap(),
      where: 'id = ?',
      whereArgs: [note.id],
    );
    print('Update result: $result'); // In ra kết quả cập nhật
    return result;
  }

  // Delete a note
  Future<int> deleteNote(int id) async {
    final db = await instance.database;
    return await db.delete('notes', where: 'id = ?', whereArgs: [id]);
  }

  // Get notes by priority
  Future<List<Note>> getNotesByPriority(int priority) async {
    final db = await instance.database;
    final result = await db.query('notes', where: 'priority = ?', whereArgs: [priority]);
    return result.map((map) => Note.fromMap(map)).toList();
  }

  // Search notes by query
  Future<List<Note>> searchNotes(String query) async {
    final db = await instance.database;
    final result = await db.query(
      'notes',
      where: 'title LIKE ? OR content LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return result.map((map) => Note.fromMap(map)).toList();
  }
}