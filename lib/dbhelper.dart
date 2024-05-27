import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqliteflutter/QuotesDataModel.dart';

class Dbhelper {

  static const NEW_DB_VERSION = 2;

  Future<Database> initDb() async {
    final databasesPath = await getDatabasesPath();
        final path = join(databasesPath, "quotes.db");
        var db = await openDatabase(path);
        print("PATH $path ${await db.getVersion()}");
    try{
        //if database does not exist yet it will return version 0
        if (await db.getVersion() < NEW_DB_VERSION) {

          db.close();

          //delete the old database so you can copy the new one
          await deleteDatabase(path);

          try {
            await Directory(dirname(path)).create(recursive: true);
          } catch (e) {
            print("object $e");
          }

          //copy db from assets to database folder
          ByteData data = await rootBundle.load("assets/quotes.db");
          List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
          await File(path).writeAsBytes(bytes, flush: true);

          //open the newly created db 
          db = await openDatabase(path);

          //set the new version to the copied db so you do not need to do it manually on your bundled database.db
          db.setVersion(NEW_DB_VERSION);

        }
    }
    catch(e){
      print("EERRR $e");
    }
        return db;        
  }

  // Future retrieveQuotes() async {
  //   final Database db = org_db;
  //

  //
  //   // Convert the List<Map<String, dynamic> into a List<Dog>.
  //   // return List.generate(maps.length, (i) {
  //   //   return Quotes(
  //   //     id: maps[i]['id'],
  //   //     quotes: maps[i]['quotes'],
  //   //     favourites: maps[i]['favourites'],
  //   //   );
  //   // });
  // }

  Future<List<Quotes>> getQuotes() async {
    final Database db = await initDb();
    List<Map> list = await db.rawQuery('SELECT * FROM quotes');
    List<Quotes> quotes = [];
    // try {
    //   print("quotes data: $list");
    // } catch (e) {
    //   print("err $e");
    // }
    for (int i = 0; i < list.length; i++) {
      quotes.add(Quotes(
          id: list[i]["id"],
          quotes: list[i]["quotes"],
          favourites: list[i]["favourites"],
          lock: list[i]["lock"]));
    }
    return quotes;
  }

  Future<List<Quotes>> getFavQuotes() async {
    final Database db = await initDb();
    List<Map> list =
        await db.rawQuery('SELECT * FROM quotes WHERE favourites = 1');
    List<Quotes> quotes = [];
    for (int i = 0; i < list.length; i++) {
      quotes.add(Quotes(
          id: list[i]["id"],
          quotes: list[i]["quotes"],
          favourites: list[i]["favourites"],
          lock: list[i]["lock"]));
    }
    return quotes;
  }

  Future<void> updateFav(int fav, int id) async {
    final Database db = await initDb();
    await db.rawQuery('UPDATE quotes SET favourites = $fav WHERE id = $id');
  }

  Future<void> updateLock(int lock, int id) async {
    final Database db = await initDb();
    await db.rawQuery('UPDATE quotes SET lock = $lock WHERE id = $id');
  }

  Future<void> addQuote(String quote) async {
    final Database db = await initDb();
    await db.rawInsert(
        'INSERT INTO quotes(quotes,favourites) VALUES(?,?)', [quote, 0]);
  }

  Future<void> deleteQuote(int id) async {
    final Database db = await initDb();
    await db.rawDelete('DELETE FROM quotes WHERE ID = $id');
  }
}
