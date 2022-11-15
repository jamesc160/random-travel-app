import 'dart:developer';
import 'package:sqflite/sqflite.dart';

import '../model/blog.dart';

class DataBaseService {
  static const _dbName = 'blog.db';
  static const _tableName = 'artical';
  static DataBaseService get instance => DataBaseService._internal();
  static Database? _database;
  DataBaseService._internal();

  Future<Database> _init() async {
    _database =
        await openDatabase(_dbName, version: 1, onCreate: (db, version) {
      log('created');
      db.execute('''
    CREATE TABLE $_tableName (
      id INTEGER NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      title TEXT NOT NULL,
      date TEXT NOT NULL,
      body TEXT NOT NULL,
      image TEXT
    );
  ''');
    });
    return _database!;
  }

  Future<bool> insert(Blog blog) async {
    _database ??= await _init();
    final rows = await _database!.insert(_tableName, blog.toMap());
    return rows > 0;
  }

  Future<List<Blog>> getBlogs() async {
    _database ??= await _init();
    final data = await _database!.query(_tableName);
    if (data.isNotEmpty) {
      return data.map((e) => Blog.fromMap(e)).toList();
    }
    return [];
  }

  Future<bool> deleteBlog(Blog blog) async {
    _database ??= await _init();
    final deleted = await _database!
        .delete(_tableName, where: 'id = ?', whereArgs: [blog.id]);
    return deleted > 0;
  }

  Future<bool> updateBlog(
      {required int? oldBlogId, required Blog newBlog}) async {
    _database ??= await _init();
    final updated = await _database!.update(_tableName, newBlog.toMap(),
        where: 'id = ?', whereArgs: [oldBlogId]);
    return updated > 0;
  }

  Future<bool> clearAllBlogs() async {
    _database ??= await _init();
    final deleted = await _database!.delete(_tableName);
    return deleted > 0;
  }

  deleteDb() async {
    deleteDatabase(_dbName);
  }
}
