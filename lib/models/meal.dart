class Meal {
  int? id;
  String mealName;
  String venue;
  String entree;
  String sides;
  String other;
  int entreePrice;
  int sidesPrice;
  int otherPrice;
  int get totalPrice => entreePrice + sidesPrice + otherPrice;
  set totalPrice(int value) {
    // This setter is intentionally left empty to prevent external modification of totalPrice.
  }

   Meal({
    this.id,
    required this.mealName,
    required this.venue,
    required this.entree,
    required this.sides,
    required this.other,
    required this.entreePrice,
    required this.sidesPrice,
    required this.otherPrice, required int totalPrice,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'mealName': mealName,
      'venue': venue,
      'entree': entree,
      'sides': sides,
      'other': other,
      'entreePrice': entreePrice,
      'sidesPrice': sidesPrice,
      'otherPrice': otherPrice,
      'totalPrice': totalPrice,
    };
  }
  factory Meal.fromMap(Map<String, dynamic> map) => Meal(
    id: map['id'] as int,
    mealName: map['mealName'] as String,
    venue: map['venue'] as String,
    entree: map['entree'] as String,
    sides: map['sides'] as String,
    other: map['other'] as String,
    entreePrice: map['entreePrice'] as int,
    sidesPrice: map['sidesPrice'] as int,
    otherPrice: map['otherPrice'] as int,
    totalPrice: map['totalPrice'] as int,
  );

}