class NidoItem {
  final String id;
  final String imageUrl;
  final List<String> imageUrls;
  final String price;
  final String? badge;
  final String type;
  final String age;
  final String condition;
  final String title;
  final String status;
  final String size;
  final String color;
  final int inquiryCount;
  final String lastActivity;
  final bool isFavorite;
  final String note;
  final List<NidoItem> recommended;

  const NidoItem({
    required this.id,
    required this.imageUrl,
    required this.imageUrls,
    required this.price,
    required this.badge,
    required this.type,
    required this.age,
    required this.condition,
    required this.title,
    required this.status,
    required this.size,
    required this.color,
    required this.inquiryCount,
    required this.lastActivity,
    required this.isFavorite,
    required this.note,
    this.recommended = const [],
  });

  NidoItem copyWith({
    String? id,
    String? imageUrl,
    List<String>? imageUrls,
    String? price,
    String? badge,
    String? type,
    String? age,
    String? condition,
    String? title,
    String? status,
    String? size,
    String? color,
    int? inquiryCount,
    String? lastActivity,
    bool? isFavorite,
    String? note,
    List<NidoItem>? recommended,
  }) {
    return NidoItem(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      price: price ?? this.price,
      badge: badge ?? this.badge,
      type: type ?? this.type,
      age: age ?? this.age,
      condition: condition ?? this.condition,
      title: title ?? this.title,
      status: status ?? this.status,
      size: size ?? this.size,
      color: color ?? this.color,
      inquiryCount: inquiryCount ?? this.inquiryCount,
      lastActivity: lastActivity ?? this.lastActivity,
      isFavorite: isFavorite ?? this.isFavorite,
      note: note ?? this.note,
      recommended: recommended ?? this.recommended,
    );
  }
}
