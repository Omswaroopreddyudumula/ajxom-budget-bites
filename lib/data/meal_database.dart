import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:budget_bites/models/meal.dart';
class MealDatabase{
  static Future<Database> _openMealDatabase() async {
    return openDatabase(
      join(await getDatabasesPath(), 'meal_favs.db'),
      version: 1,
      onCreate: (Database db, int version) async { 
        await db.execute('''
          CREATE TABLE meals (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            mealName TEXT NOT NULL,
            venue TEXT NOT NULL,
            entree TEXT NOT NULL,
            sides TEXT NOT NULL,
            other TEXT NOT NULL,
            entreePrice REAL NOT NULL,
            sidesPrice REAL NOT NULL,
            otherPrice REAL NOT NULL,
            totalPrice REAL,
          )
        ''');
      //initial rows
        await db.insert('meals',{
          'mealName': 'Spicy go-to', 
          'venue': 'Chick-fil-A', 
          'entree': 'Spicy Deluxe Chicken Sandwich', 
          'sides': ' Large Fries', 
          'other': 'sweet tea', 
          'entreePrice': 7.14, 
          'sidesPrice': 2, 
          'otherPrice': 3, 
        },);
      }
    );

  }
  static Future<List<Meal>> getMeals() async {
    final db = await _openMealDatabase();
    final result = await db.query('meals');
    return result.map((row) => Meal.fromMap(row)).toList();
  }
  static Future<int> addMeal(Meal meal) async {
    final db = await _openMealDatabase();
    return await db.insert('meals', meal.toMap());
  }
  static Future<int> updateMeal(Meal meal) async {
    final db = await _openMealDatabase();
    return await db.update(
      'meals', 
      meal.toMap(), 
      where: 'id = ?', 
      whereArgs: [meal.id]
    );
  }

  static Future<int> deleteMeal(int id) async {
    final db = await _openMealDatabase();
    return await db.delete('meals', where: 'id = ?', whereArgs: [id]);
  }
}