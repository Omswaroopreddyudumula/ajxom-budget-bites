import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/meal_database.dart';
import '../models/meal.dart';
import '../models/purchase_log.dart';
class AppStore extends ChangeNotifier {
  final MealDatabase repository;
  List<Meal> meals=[];
  List<PurchaseLog> purchases=[];
  int budget=1000;
  bool dark=false, busy=false, loaded=false;
  String? error;
  bool _closed=false;
  AppStore(this.repository);
  void _notify(){if(!_closed) notifyListeners();}
  Future<void> load() async {
    busy=true;error=null;_notify();
    try {
      final prefs=await SharedPreferences.getInstance();
      budget=(prefs.getInt('budgetMinor')??1000).clamp(0,3000);
      dark=prefs.getBool('darkMode')??false;
      await refresh();loaded=true;
    } catch(e){error='Unable to load your notebook. Retry. Details: $e';}
    finally{busy=false;_notify();}
  }
  Future<void> refresh() async {
    meals=await repository.getMeals();purchases=await repository.getPurchases();_notify();
  }
  Future<void> saveBudget(int value) async {
    final prefs=await SharedPreferences.getInstance();
    if(!await prefs.setInt('budgetMinor',value)) throw StateError('Budget could not be saved. Retry.');
    budget=value;_notify();
  }
  Future<void> saveDark(bool value) async {
    final prefs=await SharedPreferences.getInstance();
    if(!await prefs.setBool('darkMode',value)) throw StateError('Display preference could not be saved.');
    dark=value;_notify();
  }
  Meal? meal(int id){for(final m in meals){if(m.id==id)return m;}return null;}
  @override void dispose(){_closed=true;super.dispose();}
}
