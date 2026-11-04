/// A listing is one item a student offers for sale.
enum ListingStatus { available, sold }

class Listing {
  const Listing({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.condition,
    required this.location,
    required this.description,
    required this.sellerId,
    required this.sellerName,
    required this.createdAt,
    this.status = ListingStatus.available,
  });

  final String id;
  final String title;
  final double price;
  final String category;
  final String condition;
  final String location;
  final String description;
  final String sellerId;
  final String sellerName;
  final DateTime createdAt;
  final ListingStatus status;

  bool get isSold => status == ListingStatus.sold;

  /// Returns a copy with a new status (used by "Mark as sold").
  Listing copyWith({ListingStatus? status}) {
    return Listing(
      id: id,
      title: title,
      price: price,
      category: category,
      condition: condition,
      location: location,
      description: description,
      sellerId: sellerId,
      sellerName: sellerName,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }

  /// Converts the listing to a map so it can be saved (and later sent to Firestore).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'category': category,
      'condition': condition,
      'location': location,
      'description': description,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'createdAt': createdAt.toIso8601String(),
      'status': status.name,
    };
  }

  factory Listing.fromMap(Map<String, dynamic> map) {
    return Listing(
      id: map['id'] as String,
      title: map['title'] as String,
      price: (map['price'] as num).toDouble(),
      category: map['category'] as String,
      condition: map['condition'] as String,
      location: map['location'] as String,
      description: map['description'] as String,
      sellerId: map['sellerId'] as String,
      sellerName: map['sellerName'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      status: map['status'] == 'sold' ? ListingStatus.sold : ListingStatus.available,
    );
  }
}
