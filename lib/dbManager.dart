import 'package:flutter/cupertino.dart';
import 'package:sqflite/sqflite.dart' as sql;

class DbManager{

  //create table
  static Future<void> createTable(sql.Database database) async{

    await database.execute(''' 
    CREATE TABLE workNote(
    id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
    workList TEXT,
    createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    )
    ''');
  }

  //initialize db
    static Future<sql.Database> db() async{
    return  sql.openDatabase(
      'workNotes.db',
      version: 1,
      onCreate: (sql.Database database, int version) async{
        await createTable(database);
      }
    );
    }

    //create tasks
    static Future<int> addTask(String? tasks) async{
    final db = await DbManager.db();
    final data = {'workList': tasks};
    final id = db.insert('workNote', data, conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
    }

    //all tasks
    static Future<List<Map<String, dynamic>>>getTasks() async{
    final db = await DbManager.db();
    return  db.query('workNote', orderBy: 'id');
    }

    //update tasks
    static Future<int> updateTask(int id, String tasks) async{
    final db = await DbManager.db();
    final data = {'workList': tasks, 'createdAt': DateTime.now().toString()};
    final result = await db.update('workNote', data, where: 'id = ?', whereArgs: [id]);
    return result;
    }

    //delete tasks
    static Future<void> deleteTasks(int id) async{
    final db = await DbManager.db();
    try{
      await db.delete('workNote', where: 'id = ?', whereArgs: [id]);
    }catch(error){
      debugPrint('something went wrong : $error');
    }
    }

}