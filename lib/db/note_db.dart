import 'package:flutter_sqflite/model/note_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class NoteDB {
  static final NoteDB instance = NoteDB._initDB();

  static Database? _database;

  NoteDB._initDB();

  Future<Database> get dataBase async {
    if(_database != null) return _database!;

    _database = await _initDB('notes.db');

    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }


  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY';
    const textType = 'TEXT NOT NULL';

    await db.execute(
      'CREATE TABLE tableNotes (id $idType, title $textType, description $textType, date $textType)'
    );
  }

  Future<NoteModel> readNote(int id) async {
    final db = await instance.dataBase;

    final result = await db.query(
      'tableNotes',
      // columns: NoteMode,
      where: 'id = ?',
      whereArgs: [id]
    );

    if(result.isNotEmpty) {
      return NoteModel.fromJson(result.first);
    } else {
      throw Exception('$id is not found');
    }
  }

  Future<List<NoteModel>> readAllNotes() async {
    final db = await instance.dataBase;
    final result =  await db.query('tableNotes');

    return result.map((e) => NoteModel.fromJson(e)).toList();
  }

  Future<NoteModel> createNote(NoteModel data) async {
    final db = await instance.dataBase;
    final id = await db.insert('tableNotes', data.toJson());

    return data.copyWith(id: id);
  }

  Future<int> removeNote(int id) async {
    final db = await instance.dataBase;

    final result = await db.delete(
      'tableNotes',
      where: 'id = ?',
      whereArgs: [id]
    );

    return result;
  }

  Future<int> updateNote(NoteModel note) async {
    final db = await instance.dataBase;

    final result = await db.update(
      'tableNotes',
      note.toJson(),
      where: 'id = ?',
      whereArgs: [note.id]
    );

    return result;
  }

  Future close() async {
    final db = await instance.dataBase;
    db.close();
  }
}
