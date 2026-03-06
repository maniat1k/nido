class Item {
  final String id;
  final String title;
  final String description;
  final double price;
  final String category;
  final String size;
  final String condition;
  final String sellerId;
  final List<String> imageUrls;
  final bool isFavorite;
  final String? brand;
  final String? color;
  final String? ageSuggested;
  final List<String> tags;
  final String? badge;
  final int inquiryCount;
  final String lastActivity;

  const Item({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.category,
    required this.size,
    required this.condition,
    required this.sellerId,
    required this.imageUrls,
    required this.isFavorite,
    this.brand,
    this.color,
    this.ageSuggested,
    this.tags = const [],
    this.badge,
    this.inquiryCount = 0,
    this.lastActivity = 'recién publicado',
  });

  String get imageUrl => imageUrls.first;

  Item copyWith({
    String? id,
    String? title,
    String? description,
    double? price,
    String? category,
    String? size,
    String? condition,
    String? sellerId,
    List<String>? imageUrls,
    bool? isFavorite,
    String? brand,
    bool clearBrand = false,
    String? color,
    bool clearColor = false,
    String? ageSuggested,
    bool clearAgeSuggested = false,
    List<String>? tags,
    String? badge,
    bool clearBadge = false,
    int? inquiryCount,
    String? lastActivity,
  }) {
    return Item(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      price: price ?? this.price,
      category: category ?? this.category,
      size: size ?? this.size,
      condition: condition ?? this.condition,
      sellerId: sellerId ?? this.sellerId,
      imageUrls: imageUrls ?? this.imageUrls,
      isFavorite: isFavorite ?? this.isFavorite,
      brand: clearBrand ? null : (brand ?? this.brand),
      color: clearColor ? null : (color ?? this.color),
      ageSuggested:
          clearAgeSuggested ? null : (ageSuggested ?? this.ageSuggested),
      tags: tags ?? this.tags,
      badge: clearBadge ? null : (badge ?? this.badge),
      inquiryCount: inquiryCount ?? this.inquiryCount,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }
}
