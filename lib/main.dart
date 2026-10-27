import 'package:flutter/material.dart';
import 'data/meal_database.dart';
import 'state/app_store.dart';
import 'screens/home.dart';
void main(){WidgetsFlutterBinding.ensureInitialized();runApp(BudgetBitesApp(store:AppStore(MealDatabase())));}
class BudgetBitesApp extends StatefulWidget {
  final AppStore store;
  const BudgetBitesApp({required this.store,super.key});
  @override State<BudgetBitesApp> createState()=>_BudgetBitesAppState();
}
class _BudgetBitesAppState extends State<BudgetBitesApp> {
  @override void initState(){super.initState();widget.store.load();}
  @override Widget build(BuildContext context)=>ListenableBuilder(listenable:widget.store,builder:(c,_)=>MaterialApp(
    title:'Budget Bites',debugShowCheckedModeBanner:false,
    themeMode:widget.store.dark?ThemeMode.dark:ThemeMode.light,
    theme:ThemeData(colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xff176452)),useMaterial3:true,
      inputDecorationTheme:const InputDecorationTheme(border:OutlineInputBorder())),
    darkTheme:ThemeData(colorScheme:ColorScheme.fromSeed(seedColor:const Color(0xff61bea2),brightness:Brightness.dark),useMaterial3:true,
      inputDecorationTheme:const InputDecorationTheme(border:OutlineInputBorder())),
    home:HomeScreen(store:widget.store)));
  @override void dispose(){widget.store.dispose();widget.store.repository.close();super.dispose();}
}
