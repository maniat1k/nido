class Seller {
  final String id;
  final String name;
  final String? avatarUrl;

  const Seller({
    required this.id,
    required this.name,
    this.avatarUrl,
  });
}
