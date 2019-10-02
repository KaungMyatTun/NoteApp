import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:note_app/models/note.dart';


class DatabaseHelper{
  static DatabaseHelper _databaseHelper; // singleton databasehelper
  static Database _database;

  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colPriority = 'priority';
  
  String colDate = 'date';
  
  DatabaseHelper._createInstance(); // named constructor to create instance of databasehelper
  
  factory DatabaseHelper(){
    if(_databaseHelper == null) {
      _databaseHelper = DatabaseHelper
          ._createInstance(); // this is excuted only once, singleton object
    }
    return _databaseHelper;
  }

  Future<Database> get database async{
    if(_database == null){
      _database  = await initializeDatabase();
    }
    return _database;
  }

  Future<Database> initializeDatabase() async{
    // get the directory path for both android and ios to store databse
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';

    // open / create the database at a given path
    var notesDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  void _createDb(Database db, int newVersion) async{
    await db.execute('CREATE TABLE $noteTable ($colId INTEGER PRIMARY KEY AUTOINCREMENT, $colTitle TEXT, $colDescription TEXT, $colPriority INTEGER, $colDate TEXT)');
  }

  // Fetch Operation : Get all note objects from database
  Future<List<Map<String, dynamic>>> getNoteMapList() async{
    Database db = await this.database;
    //var result = await db.rawQuery('SELECT * from $noteTable order by $colPriority ASC');
    var result = await db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  // insert operation : insert a note object to a database
  Future<int> insertNote(Note note) async{
    Database db = await this.database;
    var result = await db.insert(noteTable, note.toMap());
    return result;
  }

  // update operation : update a note object and save it to databse
  Future<int> updateNote(Note note) async{
    var db = await this.database;
    var result = await db.update(noteTable, note.toMap(), where: '$colId = ?', whereArgs: [note.id]);
    return result;
  }

  // delete operation : delete a note object from database
  Future<int> deletNote(int id) async{
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $noteTable WHERE $colId = $id');
    return result;
  }

  // get number of note objects in database
  Future<int> getCount() async{
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT(*) FROM $noteTable');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // get the map list and convert it to note list
  Future<List<Note>> getNoteList() async{
    var noteMapList = await getNoteMapList();
    int count = noteMapList.length;

    List<Note> noteList = List<Note>();
    for(int i = 0; i < count ; i++){
      noteList.add(Note.fromMapObject(noteMapList[i]));
    }

    return noteList;
  }
}