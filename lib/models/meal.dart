/// Extends A.J. Orea's meal model with explicit integer-cent prices.
class Meal {
  final int? id;
  final String mealName, venue, cuisine, entree, sides, other;
  final int entreePrice, sidesPrice, otherPrice;
  final bool favorite;
  int get totalPrice => entreePrice + sidesPrice + otherPrice;
  const Meal({
    this.id,
    required this.mealName,
    required this.venue,
    this.cuisine = 'Other',
    this.entree = '',
    this.sides = '',
    this.other = '',
    required this.entreePrice,
    this.sidesPrice = 0,
    this.otherPrice = 0,
    this.favorite = false,
  });
  Map<String, Object?> toMap() => {
    'id': id,
    'mealName': mealName,
    'venue': venue,
    'cuisine': cuisine,
    'entree': entree,
    'sides': sides,
    'other': other,
    'entreePrice': entreePrice,
    'sidesPrice': sidesPrice,
    'otherPrice': otherPrice,
    'favorite': favorite ? 1 : 0,
  };
  factory Meal.fromMap(Map<String, Object?> m) => Meal(
    id: m['id'] as int,
    mealName: m['mealName'] as String,
    venue: m['venue'] as String,
    cuisine: m['cuisine'] as String,
    entree: m['entree'] as String,
    sides: m['sides'] as String,
    other: m['other'] as String,
    entreePrice: m['entreePrice'] as int,
    sidesPrice: m['sidesPrice'] as int,
    otherPrice: m['otherPrice'] as int,
    favorite: m['favorite'] == 1,
  );
  Meal withFavorite(bool value) => Meal(
    id: id,
    mealName: mealName,
    venue: venue,
    cuisine: cuisine,
    entree: entree,
    sides: sides,
    other: other,
    entreePrice: entreePrice,
    sidesPrice: sidesPrice,
    otherPrice: otherPrice,
    favorite: value,
  );
}
