import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbConfig {
  DbConfig._();

  static const String TABLE_NOTE = "notes";
  static const String COL_TITLE = "title";
  static const String COL_DESCRIPTION = "description";
  static const String COL_DATE_TIME = "date_time";
  static const String COL_SR_NO = "sr_no";

  Database? myDB;
  static getInstance() {
    return DbConfig._();
  }

  // db open or not else created

  Future<Database> getDB() async {
    var dbRef = myDB ?? await openDB();
    return dbRef;
  }

  // Check and create the table if not exists
  Future<void> checkAndCreateTable(Database db) async {
    var result = await db.rawQuery(
        'SELECT name FROM sqlite_master WHERE type="table" AND name="notes"');
    if (result.isEmpty) {
      // Table doesn't exist, so create it
      await db.execute(
          "CREATE TABLE $TABLE_NOTE ($COL_SR_NO INTEGER PRIMARY KEY AUTOINCREMENT, $COL_TITLE TEXT, $COL_DESCRIPTION TEXT,$COL_DATE_TIME TEXT)");
    }
  }

  Future<Database> openDB() async {
    Directory appdir = await getApplicationDocumentsDirectory();

    String dbPath = join(appdir.path, "noteDB.db");

    var db = await openDatabase(dbPath, onCreate: (db, version) {
      db.execute(
          "create table $TABLE_NOTE ($COL_SR_NO integer primary key autoincrement,$COL_TITLE text,$COL_DESCRIPTION text,$COL_DATE_TIME TEXT)");
    }, version: 1);
    // Ensure the table exists, if not, create it
    await checkAndCreateTable(db);
    return db;
  }

  // all queries

  Future<bool> addNote(
      {required String title,
      required String desc,
      required String datetime}) async {
    var db = await getDB();
    int rowsAffected = await db.insert(TABLE_NOTE,
        {COL_TITLE: title, COL_DESCRIPTION: desc, COL_DATE_TIME: datetime});
    return rowsAffected > 0;
  }

  Future<List<Map<String, dynamic>>> getAllNotes() async {
    var db = await getDB();

    Future<List<Map<String, dynamic>>> mData = db.query(
      TABLE_NOTE,
    );
    return mData;
  }

  Future<bool> updateNote(
      {required int sno,
      required String title,
      required String desc,
      required String datetime}) async {
    var db = await getDB();
    int rowsAffected = await db.update(TABLE_NOTE,
        {COL_TITLE: title, COL_DESCRIPTION: desc, COL_DATE_TIME: datetime},
        where: '$COL_SR_NO = ?', whereArgs: [sno]);
    return rowsAffected > 0;
  }

  Future<bool> delete({required int sno}) async {
    var db = await getDB();
    int rowsAffected = await db.delete(TABLE_NOTE, where: "$COL_SR_NO = $sno");

    return rowsAffected > 0;
  }
}
