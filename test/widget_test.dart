import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:budget_bites/main.dart';
import 'package:budget_bites/data/meal_database.dart';
import 'package:budget_bites/models/meal.dart';
import 'package:budget_bites/models/purchase_log.dart';
import 'package:budget_bites/state/app_store.dart';

class FakeDatabase extends MealDatabase {
  List<Meal> meals = [
    const Meal(
      id: 1,
      mealName: 'Test wrap',
      venue: 'Test venue',
      entreePrice: 450,
    ),
  ];
  bool fail = false;
  @override
  Future<List<Meal>> getMeals() async => meals;
  @override
  Future<List<PurchaseLog>> getPurchases() async => [];
  @override
  Future<int> addMeal(Meal m) async {
    if (fail) throw StateError('Injected write failure');
    meals.add(m);
    return 2;
  }

  @override
  Future<void> close() async {}
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('Navigation shows History and persisted preference controls', (
    t,
  ) async {
    await t.binding.setSurfaceSize(const Size(900, 2400));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(BudgetBitesApp(store: AppStore(FakeDatabase())));
    await t.pumpAndSettle();
    expect(find.text('Test wrap'), findsOneWidget);
    await t.tap(find.text('History'));
    await t.pumpAndSettle();
    expect(find.text('No purchases yet'), findsOneWidget);
    await t.tap(find.text('Settings'));
    await t.pumpAndSettle();
    expect(find.byType(Slider), findsOneWidget);
  });
  testWidgets('Editor validation and write failure preserve draft', (t) async {
    final db = FakeDatabase()..fail = true;
    await t.binding.setSurfaceSize(const Size(900, 2400));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(BudgetBitesApp(store: AppStore(db)));
    await t.pumpAndSettle();
    await t.tap(find.text('Add meal'));
    await t.pumpAndSettle();
    await t.tap(find.text('Save meal'));
    await t.pumpAndSettle();
    expect(find.text('This field is required.'), findsNWidgets(2));
    await t.enterText(find.byKey(const ValueKey('meal-field-0')), 'Draft meal');
    await t.enterText(
      find.byKey(const ValueKey('meal-field-1')),
      'Local venue',
    );
    await t.tap(find.text('Save meal'));
    await t.pumpAndSettle();
    expect(find.textContaining('Your draft is retained'), findsOneWidget);
    expect(find.text('Draft meal'), findsOneWidget);
  });
  testWidgets('Helper no-data and dismiss do not save a purchase', (t) async {
    await t.binding.setSurfaceSize(const Size(900, 2400));
    addTearDown(() => t.binding.setSurfaceSize(null));
    await t.pumpWidget(BudgetBitesApp(store: AppStore(FakeDatabase())));
    await t.pumpAndSettle();
    await t.ensureVisible(find.text('View meal'));
    await t.tap(find.text('View meal'));
    await t.pumpAndSettle();
    expect(find.textContaining('Not enough history'), findsOneWidget);
    await t.tap(find.text('Not now'));
    await t.pumpAndSettle();
    expect(find.text('Show Lunch Lens'), findsOneWidget);
    expect(find.text('Start plan'), findsOneWidget);
  });
}
