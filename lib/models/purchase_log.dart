class PurchaseLog {
  final int? id;
  final int mealId, actualPriceMinor;
  final DateTime purchasedAt;
  final String note, saveToken;
  const PurchaseLog({this.id,required this.mealId,required this.actualPriceMinor,
    required this.purchasedAt,this.note='',required this.saveToken});
  Map<String,Object?> toMap()=>{'id':id,'mealId':mealId,
    'actualPriceMinor':actualPriceMinor,'purchasedAt':purchasedAt.millisecondsSinceEpoch,
    'note':note,'saveToken':saveToken};
  factory PurchaseLog.fromMap(Map<String,Object?> m)=>PurchaseLog(id:m['id'] as int,
    mealId:m['mealId'] as int,actualPriceMinor:m['actualPriceMinor'] as int,
    purchasedAt:DateTime.fromMillisecondsSinceEpoch(m['purchasedAt'] as int),
    note:m['note'] as String,saveToken:m['saveToken'] as String);
}
