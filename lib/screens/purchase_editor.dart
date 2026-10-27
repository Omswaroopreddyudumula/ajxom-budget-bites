import 'package:flutter/material.dart';
import '../domain/lunch_lens.dart';
import '../domain/money.dart';
import '../models/purchase_log.dart';
import '../state/app_store.dart';
import '../widgets/shared.dart';
class PurchaseEditor extends StatefulWidget {
  final AppStore store; final int? mealId;final PurchaseLog? log;
  const PurchaseEditor({required this.store,this.mealId,this.log,super.key});
  @override State<PurchaseEditor> createState()=>_PurchaseEditorState();
}
class _PurchaseEditorState extends State<PurchaseEditor>{
  final _form=GlobalKey<FormState>();
  final amount=TextEditingController(),note=TextEditingController();
  late DateTime date;
  late String token;
  int? mealId;
  bool saving=false,started=false,dismissed=false;
  @override void initState(){super.initState();mealId=widget.log?.mealId??widget.mealId;
    date=widget.log?.purchasedAt??DateTime.now();token=widget.log?.saveToken??'purchase-${DateTime.now().microsecondsSinceEpoch}';
    amount.text=moneyInput(widget.log?.actualPriceMinor??widget.store.meal(mealId??-1)?.totalPrice??0);
    note.text=widget.log?.note??'';started=widget.log!=null||widget.mealId==null;}
  @override void dispose(){amount.dispose();note.dispose();super.dispose();}
  Future<void> chooseDate() async {
    final picked=await showDatePicker(context:context,initialDate:date,firstDate:DateTime(2000),lastDate:DateTime.now());
    if(picked==null||!mounted)return;
    final time=await showTimePicker(context:context,initialTime:TimeOfDay.fromDateTime(date));
    if(time==null||!mounted)return;
    final value=DateTime(picked.year,picked.month,picked.day,time.hour,time.minute);
    if(value.isAfter(DateTime.now())){feedback(context,'Choose a time in the past.');return;}
    setState(()=>date=value);
  }
  Future<void> save() async {
    if(saving||!_form.currentState!.validate())return;
    final value=parseMoney(amount.text);
    if(value>widget.store.budget && !await confirm(context,'Above your budget','This purchase is ${money(value-widget.store.budget)} over your lunch budget. Save it anyway?',action:'Save anyway'))return;
    if(!mounted)return;setState(()=>saving=true);
    try {
      final log=PurchaseLog(id:widget.log?.id,mealId:mealId!,actualPriceMinor:value,purchasedAt:date,note:note.text.trim(),saveToken:token);
      if(log.id==null){await widget.store.repository.addPurchase(log);}else{await widget.store.repository.updatePurchase(log);}
      await widget.store.refresh();if(mounted){feedback(context,'Purchase saved: ${money(value)}');Navigator.pop(context,true);}
    }catch(e){if(mounted)feedback(context,'Purchase could not be saved. Retry with this draft. $e');}
    finally{if(mounted)setState(()=>saving=false);}
  }
  Future<void> reset() async {
    if(await confirm(context,'Reset draft?','Discard this unsaved draft? Saved purchase history stays unchanged.',action:'Reset') && mounted){setState((){started=false;amount.text=moneyInput(widget.store.meal(mealId??-1)?.totalPrice??0);note.clear();dismissed=false;});}
  }
  Widget helper(){
    LunchEstimate? estimate;
    try{estimate=estimateLunch(widget.store.purchases,mealId??-1,date);}catch(e){return Text('$e');}
    if(dismissed)return TextButton(onPressed:()=>setState(()=>dismissed=false),child:const Text('Show Lunch Lens'));
    return Card(child:Padding(padding:const EdgeInsets.all(16),child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Text('Lunch Lens',style:Theme.of(context).textTheme.titleLarge),const Text('Local rule-based estimate • not a trained model'),const SizedBox(height:8),
      if(estimate==null)const Text('Not enough history. Record three earlier purchases of this meal to see an estimate.')
      else ...[Text(money(estimate.mean),style:Theme.of(context).textTheme.headlineMedium),
        Text('Mean of the 3 most recent earlier purchases: ${estimate.inputs.map((l)=>money(l.actualPriceMinor)).join(', ')}.'),
        Text('${localDate(estimate.inputs.last.purchasedAt)} to ${localDate(estimate.inputs.first.purchasedAt)}. Last-price baseline: ${money(estimate.baseline)}.'),
        const Text('A planning guide, not a guaranteed price. Enter the actual amount yourself.')],
      TextButton(onPressed:()=>setState(()=>dismissed=true),child:const Text('Not now')),
    ])));
  }
  @override Widget build(BuildContext c)=>ListenableBuilder(listenable:widget.store,builder:(c,_) {
    final meal=widget.store.meal(mealId??-1);
    return Scaffold(appBar:AppBar(title:Text(widget.log!=null?'Edit purchase':'Meal activity')),
      body:Align(alignment:Alignment.topCenter,child:ConstrainedBox(constraints:const BoxConstraints(maxWidth:680),child:Form(key:_form,child:ListView(padding:const EdgeInsets.all(20),children:[
        if(widget.store.meals.isEmpty)const Text('Add a meal before recording a purchase.'),
        DropdownButtonFormField<int>(initialValue:mealId,decoration:const InputDecoration(labelText:'Meal'),isExpanded:true,
          items:[for(final m in widget.store.meals)DropdownMenuItem(value:m.id,child:Text(m.mealName))],
          onChanged:saving?null:(v)=>setState((){mealId=v;dismissed=false;}),validator:(v)=>v==null?'Choose a meal.':null),
        const SizedBox(height:16),if(meal!=null)Text('${meal.venue} • Catalog estimate ${money(meal.totalPrice)}'),const SizedBox(height:12),helper(),
        const SizedBox(height:12),Text(widget.log!=null?'Correct saved receipt':started?'Planning • enter your actual purchase':'Ready to plan',style:Theme.of(c).textTheme.titleMedium),
        if(!started)Padding(padding:const EdgeInsets.symmetric(vertical:12),child:FilledButton(onPressed:()=>setState(()=>started=true),child:const Text('Start plan'))),
        if(started)...[
          const SizedBox(height:16),TextFormField(key:const Key('purchase-amount'),controller:amount,keyboardType:const TextInputType.numberWithOptions(decimal:true),decoration:const InputDecoration(labelText:'Actual amount (USD)'),validator:(v){try{parseMoney(v??'');return null;}on FormatException catch(e){return e.message;}}),
          const SizedBox(height:16),OutlinedButton.icon(onPressed:saving?null:chooseDate,icon:const Icon(Icons.calendar_today_outlined),label:Text('${localDate(date)} ${TimeOfDay.fromDateTime(date).format(c)} • Change date/time')),
          const SizedBox(height:16),TextFormField(controller:note,decoration:const InputDecoration(labelText:'Receipt note (optional)'),maxLength:500,maxLines:2),
          const SizedBox(height:16),FilledButton.icon(onPressed:saving||meal==null?null:save,icon:const Icon(Icons.check),label:Text(saving?'Saving...':widget.log==null?'Save purchase and finish':'Save correction')),
          if(widget.log==null)TextButton(onPressed:saving?null:reset,child:const Text('Reset draft')),
        ],TextButton(onPressed:saving?null:()=>Navigator.pop(c),child:const Text('Cancel / Back')),
      ])))));
  });
}
