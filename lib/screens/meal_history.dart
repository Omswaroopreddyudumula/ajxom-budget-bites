import 'package:budget_bites/data/meal_database.dart';
import 'package:budget_bites/models/meal.dart';
import 'package:flutter/material.dart';
import 'package:budget_bites/screens/meal_editor.dart';
class MealHistory extends StatefulWidget { 
  const MealHistory({super.key});

  @override
  State<MealHistory> createState() => _MealHistoryState();
}

class _MealHistoryState extends State<MealHistory> {
  List<Meal> meals = [];
  Future<void> loadMeal() async {
    final meals = await MealDatabase.getMeals();
    setState(() {
      this.meals = meals;
    });
  }
  @override
  void initState() {
    super.initState();
    loadMeal();
  }
  //History Widget
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Purchase History'),
      ),
      body: ListView.builder(
        itemCount: meals.length, 
        itemBuilder: (BuildContext context, int index) {  
          final meal = meals[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(vertical: 8.0,),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.greenAccent,
                child: Text(
                  meal.id[0],//first meal entry
                  style: const TextStyle(color: Colors.black),
                ),
              ),
              title: Text(
                meal.mealName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle:Text(meal.venue),
              onTap: () {//edit meal
                _MealEditorState();

              },
              trailing: IconButton(
                icon:const Icon(Icons.delete, color: Colors.red),
                onPressed: () async{
                  final mealId = meal.id;
                  if (mealId == null) return;
                  await MealDatabase.deleteMeal(mealId);
                  await loadMeal();

                },
              ),
            ),
          ),
        },
      )
    );
  }
}