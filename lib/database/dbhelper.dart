import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../model/foods.dart';

class DbHelper {
  static Database _db;

  DbHelper._();

  static final DbHelper getDb = DbHelper._();

  factory DbHelper() => getDb;

  Future<Database> get database async {
    if (_db != null) return _db;

    _db = await initDb();
    return _db;
  }

  initDb() async {
    var dbPath = await getDatabasesPath();
    String path = join(dbPath, "favorite.db");

    return await openDatabase(path,
        version: 1,
        onOpen: (db) => {},
        onCreate: (db, i) async {
          await db.execute(
              "Create table favorite(idMeal varchar(10) primary key,strMeal text,strMealThumb text,strCategory text)");
        });
  }

  insertFavorite(Foods f) async {
    final db = await database;
    var result = await db.rawQuery("Insert into favorite values(?,?,?,?)",
        [f.id, f.name, f.img, f.category]);
    return result;
  }

  Future<List<Foods>> getFavorite(String category) async {
    final db = await database;
    var res = await db
        .query("favorite", where: "strCategory=?", whereArgs: [category]);
    List<Foods> food = [];
    for (int x = 0; x < res.length; x++) {
      food.add(Foods(res[x]["idMeal"], res[x]["strMeal"],
          res[x]["strMealThumb"], res[x]["strCategory"]));
    }
    return food;
  }

  Future<bool> getFavoriteById(String id) async {
    final db = await database;
    var res = await db.query("favorite", where: "idMeal=?", whereArgs: [id]);
    if (res.length > 0) {
      return true;
    } else {
      return false;
    }
  }

  delete(String id) async {
    final db = await database;
    var res = db.delete("favorite", where: "idMeal=?", whereArgs: [id]);
    return res;
  }
}
