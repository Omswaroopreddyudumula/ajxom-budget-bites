import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
Future<Database> openMealDatabase() async {
  return openDatabase(
    join(await getDatabasesPath(), 'meal_favs.db'),
    version: 1,
    onCreate: (db, version) => db.execute('''
      CREATE TABLE meals (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mealName TEXT NOT NULL,
        Venue TEXT NOT NULL,
        entree TEXT NOT NULL,
        sides TEXT NOT NULL,
        other TEXT NOT NULL,
        entreePrice INTEGER NOT NULL,
        sidesPrice INTEGER NOT NULL,
        otherPrice INTEGER NOT NULL,
        totalPrice INTEGER NOT NULL
      )
    '''),
  );
}