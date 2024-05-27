class Quotes {
  late int id;
  late String quotes;
  late int favourites;
  late int lock;

  Quotes({required this.id, required this.quotes, required this.favourites, required this.lock});

  Quotes.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    quotes = map['quotes'];
    favourites = map['favourites'];
    lock = map['lock'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'quotes': quotes,
      'favourites': favourites,
      'lock': lock,
    };
  }
}
