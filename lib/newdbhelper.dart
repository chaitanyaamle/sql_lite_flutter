import 'dart:async';
import 'dart:io' as io;
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'QuotesDataModel.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class NewDBHelper {
  static Database?_db;

  Future<Database?> get db async {
    if (_db != null) return _db;
    _db = await initDb();
    return _db;
  }

  initDb() async {
    io.Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "quotes.db");
    bool dbExists = await io.File(path).exists();

    if (!dbExists) {
      ByteData data = await rootBundle.load(join("assets", "quotes.db"));
      List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);


      await io.File(path).writeAsBytes(bytes, flush: true);
    }

    var theDb = await openDatabase(path,version: 1);
    return theDb;
  }

  Future<List<Quotes>> getQuotes() async {
    var dbClient = await db;
    List<Map> list = await dbClient!.rawQuery('SELECT * FROM quotes');
    List<Quotes> quotes = [];
    for (int i = 0; i < list.length; i++) {
      quotes.add(Quotes(id: list[i]["id"], quotes: list[i]["quotes"], favourites: list[i]["favourites"], lock: list[i]["lock"]));
    }
    return quotes;
  }
}