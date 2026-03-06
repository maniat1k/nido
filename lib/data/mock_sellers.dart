import '../models/seller.dart';

const Seller nataliaSeller = Seller(
  id: 'natalia',
  name: 'Natalia',
  avatarUrl:
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?q=80&w=400&auto=format&fit=crop',
);

const Seller marciaSeller = Seller(
  id: 'marcia',
  name: 'Marcia',
  avatarUrl:
      'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=400&auto=format&fit=crop',
);

const Seller currentMockSeller = Seller(
  id: 'mi-perfil',
  name: 'Mi perfil',
  avatarUrl:
      'https://images.unsplash.com/photo-1544723795-3fb6469f5b39?q=80&w=400&auto=format&fit=crop',
);

const List<Seller> mockCatalogSellers = [
  nataliaSeller,
  marciaSeller,
];

const List<Seller> mockSellers = [
  ...mockCatalogSellers,
  currentMockSeller,
];

Seller sellerById(String id) {
  return mockSellers.firstWhere(
    (seller) => seller.id == id,
    orElse: () => mockSellers.first,
  );
}
