import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:budget_bites/data/meal_database.dart';
import 'package:budget_bites/main.dart';
import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/purchase_log.dart';
import 'package:budget_bites/state/app_store.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('SQLite CRUD totals duplicate FK reopen and UI navigation', (
    tester,
  ) async {
    final path = join(await getDatabasesPath(), 'qa_notebook.db');
    await deleteDatabase(path);
    var repo = MealDatabase(databasePath: path);
    final id = await repo.addMeal(
      const Meal(
        mealName: 'QA receipt fixture',
        venue: 'Fictional QA cafe',
        entreePrice: 450,
      ),
    );
    expect((await repo.getMeals()).any((m) => m.id == id), isTrue);
    await repo.updateMeal(
      Meal(
        id: id,
        mealName: 'QA edited meal',
        venue: 'Fictional QA cafe',
        entreePrice: 500,
      ),
    );
    PurchaseLog row(int amount, String token, {int? rowId}) => PurchaseLog(
      id: rowId,
      mealId: id,
      actualPriceMinor: amount,
      purchasedAt: DateTime(2026, 1, 1),
      saveToken: token,
      note: 'QA fixture',
    );
    final a = await repo.addPurchase(row(450, 'qa-a'));
    final b = await repo.addPurchase(row(600, 'qa-b'));
    expect(await repo.addPurchase(row(450, 'qa-a')), a);
    expect(
      (await repo.getPurchases()).fold<int>(
        0,
        (s, l) => s + l.actualPriceMinor,
      ),
      1050,
    );
    await repo.updatePurchase(row(550, 'qa-b', rowId: b));
    expect(
      (await repo.getPurchases()).fold<int>(
        0,
        (s, l) => s + l.actualPriceMinor,
      ),
      1000,
    );
    await repo.deletePurchase(a);
    expect((await repo.getPurchases()).single.actualPriceMinor, 550);
    await expectLater(repo.deleteMeal(id), throwsStateError);
    await expectLater(
      repo.addPurchase(
        PurchaseLog(
          mealId: 999999,
          actualPriceMinor: 5,
          purchasedAt: DateTime(2026, 1),
          saveToken: 'orphan',
        ),
      ),
      throwsA(isA<DatabaseException>()),
    );
    await expectLater(
      repo.addPurchase(row(-1, 'invalid')),
      throwsArgumentError,
    );
    await repo.close();
    repo = MealDatabase(databasePath: path);
    expect((await repo.getPurchases()).single.actualPriceMinor, 550);
    final store = AppStore(repo);
    await store.load();
    await store.saveBudget(1250);
    await store.saveDark(true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    expect(prefs.getInt('budgetMinor'), 1250);
    expect(prefs.getBool('darkMode'), true);
    await tester.pumpWidget(BudgetBitesApp(store: store));
    await tester.pumpAndSettle();
    expect(find.textContaining('Your lunch budget: \$12.50'), findsOneWidget);
    await tester.tap(find.text('History'));
    await tester.pumpAndSettle();
    expect(find.text('\$5.50'), findsWidgets);
    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();
    expect(find.byType(Slider), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pumpAndSettle();
    final cleanup = MealDatabase(databasePath: path);
    await cleanup.deletePurchase(b);
    await cleanup.deleteMeal(id);
    expect((await cleanup.getPurchases()), isEmpty);
    await cleanup.close();
  });
  testWidgets('Version one REAL dollar rows migrate without losing IDs', (
    tester,
  ) async {
    final path = join(await getDatabasesPath(), 'qa_migration.db');
    await deleteDatabase(path);
    final old = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE meals (id INTEGER PRIMARY KEY, mealName TEXT, venue TEXT, entree TEXT, sides TEXT, other TEXT, entreePrice REAL, sidesPrice REAL, otherPrice REAL,totalPrice REAL)',
        );
        await db.insert('meals', {
          'id': 17,
          'mealName': 'Old meal',
          'venue': 'Old venue',
          'entree': 'Wrap',
          'sides': '',
          'other': '',
          'entreePrice': 4.5,
          'sidesPrice': 2.0,
          'otherPrice': 0.0,
          'totalPrice': 6.5,
        });
      },
    );
    await old.close();
    final repo = MealDatabase(databasePath: path);
    final m = (await repo.getMeals()).single;
    expect(m.id, 17);
    expect(m.totalPrice, 650);
    expect(m.mealName, 'Old meal');
    expect(await repo.getPurchases(), isEmpty);
    await repo.close();
  });
}
