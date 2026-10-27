import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/meal.dart';
import '../models/purchase_log.dart';

/// Data-layer connection owner. Builds on A.J. Orea's original CRUD boundary.
class MealDatabase {
  Database? _db;
  Future<Database>? _opening;
  final String? databasePath;
  MealDatabase({this.databasePath});
  Future<Database> get database async {
    if(_db!=null) return _db!;
    return _opening??=_open();
  }
  Future<Database> _open() async {
    try {
      _db=await openDatabase(databasePath??join(await getDatabasesPath(),'meal_favs.db'),
        version:2,onConfigure:(db)=>db.execute('PRAGMA foreign_keys = ON'),
        onCreate:(db,version) async {await _schema(db);await _seed(db);},
        onUpgrade:(db,oldVersion,newVersion) async {
          if(oldVersion<2){
            // Preserve the v1 rows, converting REAL dollar fields into cents.
            await db.execute('ALTER TABLE meals RENAME TO meals_v1');
            await _schema(db);
            await db.execute('''INSERT INTO meals
              (id,mealName,venue,cuisine,entree,sides,other,entreePrice,sidesPrice,otherPrice,favorite)
              SELECT id,mealName,venue,'Other',entree,sides,other,
              CAST(ROUND(entreePrice*100) AS INTEGER),
              CAST(ROUND(sidesPrice*100) AS INTEGER),
              CAST(ROUND(otherPrice*100) AS INTEGER),0 FROM meals_v1''');
            await db.execute('DROP TABLE meals_v1');
          }
        });
      return _db!;
    } finally {_opening=null;}
  }
  Future<void> _schema(DatabaseExecutor db) async {
    await db.execute('''CREATE TABLE meals (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      mealName TEXT NOT NULL CHECK(length(trim(mealName))>0),
      venue TEXT NOT NULL CHECK(length(trim(venue))>0),
      cuisine TEXT NOT NULL, entree TEXT NOT NULL, sides TEXT NOT NULL, other TEXT NOT NULL,
      entreePrice INTEGER NOT NULL CHECK(typeof(entreePrice)='integer' AND entreePrice BETWEEN 0 AND 999999),
      sidesPrice INTEGER NOT NULL CHECK(typeof(sidesPrice)='integer' AND sidesPrice BETWEEN 0 AND 999999),
      otherPrice INTEGER NOT NULL CHECK(typeof(otherPrice)='integer' AND otherPrice BETWEEN 0 AND 999999),
      favorite INTEGER NOT NULL DEFAULT 0 CHECK(favorite IN (0,1)))''');
    await db.execute('''CREATE TABLE purchase_logs (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      mealId INTEGER NOT NULL REFERENCES meals(id) ON DELETE RESTRICT,
      purchasedAt INTEGER NOT NULL,
      actualPriceMinor INTEGER NOT NULL CHECK(typeof(actualPriceMinor)='integer' AND actualPriceMinor BETWEEN 0 AND 999999),
      note TEXT NOT NULL DEFAULT '', saveToken TEXT NOT NULL UNIQUE)''');
    await db.execute('CREATE INDEX purchase_meal_date ON purchase_logs(mealId,purchasedAt,id)');
  }
  Future<void> _seed(Database db) async {
    for(final meal in [
      const Meal(mealName:'Campus wrap',venue:'Fictional campus cafe',cuisine:'Vegetarian',entree:'Veggie wrap',entreePrice:450,favorite:true),
      const Meal(mealName:'Study bowl',venue:'Fictional library stop',cuisine:'Rice bowls',entree:'Rice bowl',entreePrice:600),
    ]){await db.insert('meals',meal.toMap()..remove('id'));}
  }
  Future<List<Meal>> getMeals() async => (await (await database).query('meals',orderBy:'mealName COLLATE NOCASE,id')).map(Meal.fromMap).toList();
  Future<int> addMeal(Meal meal) async {
    _validateMeal(meal);return (await database).insert('meals',meal.toMap()..remove('id'));
  }
  Future<int> updateMeal(Meal meal) async {
    _validateMeal(meal);
    if(meal.id==null) throw ArgumentError('Missing meal ID.');
    return (await database).update('meals',meal.toMap()..remove('id'),where:'id = ?',whereArgs:[meal.id]);
  }
  void _validateMeal(Meal m){
    if(m.mealName.trim().isEmpty||m.venue.trim().isEmpty) throw ArgumentError('Name and venue are required.');
    if([m.entreePrice,m.sidesPrice,m.otherPrice].any((v)=>v<0||v>999999)) throw ArgumentError('Invalid price.');
  }
  Future<int> linkedCount(int id) async => Sqflite.firstIntValue(await (await database).rawQuery('SELECT COUNT(*) FROM purchase_logs WHERE mealId = ?',[id]))??0;
  Future<void> deleteMeal(int id) async {
    if(await linkedCount(id)>0) throw StateError('This meal has purchases. Delete or move its purchases in History first.');
    await (await database).delete('meals',where:'id = ?',whereArgs:[id]);
  }
  Future<List<PurchaseLog>> getPurchases() async => (await (await database).query('purchase_logs',orderBy:'purchasedAt DESC,id DESC')).map(PurchaseLog.fromMap).toList();
  void _validateLog(PurchaseLog l){
    if(l.actualPriceMinor<0||l.actualPriceMinor>999999||l.saveToken.isEmpty) throw ArgumentError('Invalid purchase.');
    if(l.purchasedAt.isAfter(DateTime.now())) throw ArgumentError('Purchase time cannot be in the future.');
  }
  Future<int> addPurchase(PurchaseLog log) async {
    _validateLog(log);final db=await database;
    return db.transaction((txn) async {
      final existing=await txn.query('purchase_logs',columns:['id'],where:'saveToken = ?',whereArgs:[log.saveToken]);
      if(existing.isNotEmpty) return existing.first['id'] as int;
      return txn.insert('purchase_logs',log.toMap()..remove('id'));
    });
  }
  Future<void> updatePurchase(PurchaseLog log) async {
    _validateLog(log);if(log.id==null) throw ArgumentError('Missing purchase ID.');
    await (await database).update('purchase_logs',log.toMap()..remove('id'),where:'id = ?',whereArgs:[log.id]);
  }
  Future<void> deletePurchase(int id) async => (await database).delete('purchase_logs',where:'id = ?',whereArgs:[id]);
  Future<void> close() async {final db=_db;_db=null;await db?.close();}
}
