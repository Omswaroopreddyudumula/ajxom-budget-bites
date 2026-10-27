import 'package:flutter/material.dart';
import '../domain/money.dart';
import '../models/meal.dart';
import '../state/app_store.dart';
import '../widgets/shared.dart';
const cuisines=['Vegetarian','Rice bowls','Sandwiches','Other'];
class MealEditor extends StatefulWidget {
  final AppStore store; final Meal? meal;
  const MealEditor({required this.store,this.meal,super.key});
  @override State<MealEditor> createState()=>_MealEditorState();
}
class _MealEditorState extends State<MealEditor>{
  final _form=GlobalKey<FormState>();
  late final List<TextEditingController> fields;
  late String cuisine;
  bool saving=false;
  @override void initState(){super.initState();final m=widget.meal;
    fields=[m?.mealName??'',m?.venue??'',m?.entree??'',moneyInput(m?.entreePrice??0),m?.sides??'',moneyInput(m?.sidesPrice??0),m?.other??'',moneyInput(m?.otherPrice??0)].map((v)=>TextEditingController(text:v)).toList();
    cuisine=m?.cuisine??'Other';}
  @override void dispose(){for(final c in fields){c.dispose();}super.dispose();}
  Future<void> save() async {
    if(saving||!_form.currentState!.validate())return;
    setState(()=>saving=true);
    try {
      final m=Meal(id:widget.meal?.id,mealName:fields[0].text.trim(),venue:fields[1].text.trim(),cuisine:cuisine,
        entree:fields[2].text.trim(),entreePrice:parseMoney(fields[3].text),sides:fields[4].text.trim(),sidesPrice:parseMoney(fields[5].text),
        other:fields[6].text.trim(),otherPrice:parseMoney(fields[7].text),favorite:widget.meal?.favorite??false);
      if(m.id==null){await widget.store.repository.addMeal(m);}else{await widget.store.repository.updateMeal(m);}
      await widget.store.refresh();if(mounted)Navigator.pop(context,true);
    } catch(e){if(mounted)feedback(context,'Meal was not saved. Your draft is retained. $e');}
    finally{if(mounted)setState(()=>saving=false);}
  }
  @override Widget build(BuildContext c)=>Scaffold(appBar:AppBar(title:Text(widget.meal==null?'Add meal':'Edit meal')),
    body:Align(alignment:Alignment.topCenter,child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:640),child:Form(key:_form,child:ListView(padding:const EdgeInsets.all(20),children:[
      Text('Your personal menu',style:Theme.of(c).textTheme.headlineSmall),const SizedBox(height:8),
      const Text('Enter your own venue notes and estimated prices. These are not live listings.'),const SizedBox(height:20),
      for(int i=0;i<fields.length;i++)Padding(padding:const EdgeInsets.only(bottom:16),child:TextFormField(
        controller:fields[i],key:ValueKey('meal-field-$i'),maxLength:i.isOdd && i>1?null:100,
        keyboardType:[3,5,7].contains(i)?const TextInputType.numberWithOptions(decimal:true):TextInputType.text,
        decoration:InputDecoration(labelText:['Meal name','Venue note','Entree','Entree price (USD)','Side','Side price (USD)','Other item','Other price (USD)'][i]),
        validator:(v){if(i<2 && (v??'').trim().isEmpty)return 'This field is required.';
          if([3,5,7].contains(i)){try{parseMoney(v??'');}on FormatException catch(e){return e.message;}}return null;})),
      DropdownButtonFormField<String>(initialValue:cuisine,decoration:const InputDecoration(labelText:'Cuisine'),items:[for(final v in cuisines)DropdownMenuItem(value:v,child:Text(v))],onChanged:(v)=>setState(()=>cuisine=v!)),
      const SizedBox(height:20),FilledButton.icon(onPressed:saving?null:save,icon:const Icon(Icons.save_outlined),label:Text(saving?'Saving...':'Save meal')),
      TextButton(onPressed:saving?null:()=>Navigator.pop(c),child:const Text('Cancel')),
    ])))));
}
