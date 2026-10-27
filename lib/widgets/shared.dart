import 'package:flutter/material.dart';
import '../domain/money.dart';
import '../models/meal.dart';
Future<bool> confirm(BuildContext context,String title,String message,{String action='Delete'}) async =>
  await showDialog<bool>(context:context,builder:(c)=>AlertDialog(title:Text(title),content:Text(message),actions:[
    TextButton(onPressed:()=>Navigator.pop(c,false),child:const Text('Cancel')),
    FilledButton(onPressed:()=>Navigator.pop(c,true),child:Text(action)),]))??false;
void feedback(BuildContext c,Object message){if(c.mounted)ScaffoldMessenger.of(c).showSnackBar(SnackBar(content:Text('$message')));}
class EmptyView extends StatelessWidget {
  final String title,message;final Widget? action;
  const EmptyView(this.title,this.message,{this.action,super.key});
  @override Widget build(BuildContext c)=>Center(child:Padding(padding:const EdgeInsets.all(28),child:Column(mainAxisSize:MainAxisSize.min,children:[
    const Icon(Icons.restaurant_menu_outlined,size:48),const SizedBox(height:16),Text(title,style:Theme.of(c).textTheme.titleLarge,textAlign:TextAlign.center),
    const SizedBox(height:8),Text(message,textAlign:TextAlign.center),if(action!=null)Padding(padding:const EdgeInsets.only(top:16),child:action),])));
}
class MealCard extends StatelessWidget {
  final Meal meal;final int budget;final VoidCallback onView,onEdit,onFavorite;
  const MealCard({required this.meal,required this.budget,required this.onView,required this.onEdit,required this.onFavorite,super.key});
  @override Widget build(BuildContext c)=>Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
    Row(children:[const CircleAvatar(child:Icon(Icons.lunch_dining)),const SizedBox(width:12),Expanded(child:Text(meal.mealName,style:Theme.of(c).textTheme.titleLarge)),
      IconButton(tooltip:meal.favorite?'Remove favorite':'Add favorite',onPressed:onFavorite,icon:Icon(meal.favorite?Icons.star:Icons.star_border))]),
    const SizedBox(height:12),Text('${meal.venue} • ${meal.cuisine}'),const SizedBox(height:8),
    Text(money(meal.totalPrice),style:Theme.of(c).textTheme.headlineSmall),
    Text(meal.totalPrice>budget?'Over budget by ${money(meal.totalPrice-budget)}':'Within your lunch budget'),
    const SizedBox(height:12),Wrap(spacing:8,children:[FilledButton.tonal(onPressed:onView,child:const Text('View meal')),TextButton(onPressed:onEdit,child:const Text('Edit meal'))]),])));
}
