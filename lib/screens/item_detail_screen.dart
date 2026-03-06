import 'package:flutter/material.dart';

import '../data/mock_sellers.dart';
import '../models/item.dart';
import '../repositories/items_repository.dart';
import '../widgets/item_card.dart';
import '../widgets/tag_chip.dart';

class ItemDetailScreen extends StatefulWidget {
  final String itemId;
  final ItemsRepository repository;

  const ItemDetailScreen({
    super.key,
    required this.itemId,
    required this.repository,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _pageIndex = 0;
  bool _descriptionExpanded = false;

  String _formatPrice(double price) {
    if (price <= 0) return 'Consultar';
    final isInt = price == price.roundToDouble();
    return isInt ? '\$ ${price.toInt()}' : '\$ ${price.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.repository,
      builder: (context, _) {
        final item = widget.repository.getById(widget.itemId);
        if (item == null) {
          return const Scaffold(
            body: SafeArea(
              child: Center(child: Text('Producto no disponible')),
            ),
          );
        }

        final seller = sellerById(item.sellerId);
        final related = widget.repository.getRelatedItems(item, limit: 8);

        return Scaffold(
          backgroundColor: const Color(0xFFF8F5F0),
          body: SafeArea(
            child: Stack(
              children: [
                Column(
                  children: [
                    _DetailHeader(
                      onBack: () => Navigator.of(context).pop(),
                      onBackToHome: () =>
                          Navigator.of(context).popUntil((route) => route.isFirst),
                      onImageSelection: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ItemImageSelectionScreen(item: item),
                          ),
                        );
                      },
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 92),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _Gallery(
                              imageUrls: item.imageUrls,
                              height: MediaQuery.of(context).size.height * 0.40,
                              isFavorited: item.isFavorite,
                              onToggleFavorite: () => widget.repository.toggleFavorite(item.id),
                              onPageChanged: (index) => setState(() => _pageIndex = index),
                            ),
                            if (item.imageUrls.length > 1)
                              _Dots(count: item.imageUrls.length, index: _pageIndex),
                            const SizedBox(height: 12),
                            _ProductInfo(
                              item: item,
                              sellerName: seller.name,
                              priceLabel: _formatPrice(item.price),
                            ),
                            const SizedBox(height: 16),
                            _DetailTags(item: item),
                            const SizedBox(height: 12),
                            _SellerNote(
                              text: item.description,
                              expanded: _descriptionExpanded,
                              onToggle: () => setState(
                                () => _descriptionExpanded = !_descriptionExpanded,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _SocialSignals(
                              inquiryCount: item.inquiryCount,
                              lastActivity: item.lastActivity,
                            ),
                            const SizedBox(height: 18),
                            if (related.isNotEmpty)
                              _RecommendedSection(
                                items: related,
                                repository: widget.repository,
                                priceFormatter: _formatPrice,
                              ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                _StickyBottomBar(
                  onChat: () {},
                  onBuy: () {},
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onBackToHome;
  final VoidCallback onImageSelection;

  const _DetailHeader({
    required this.onBack,
    required this.onBackToHome,
    required this.onImageSelection,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F5F0),
        border: Border(bottom: BorderSide(color: Color(0xFFE2DED6))),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
          const SizedBox(width: 4),
          const Text(
            'Detalle',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          IconButton(
            tooltip: 'Ir al inicio',
            onPressed: onBackToHome,
            icon: const Icon(Icons.home_outlined),
          ),
          TextButton.icon(
            onPressed: onImageSelection,
            icon: const Icon(Icons.photo_library_outlined, size: 18),
            label: const Text('Imagenes'),
          ),
        ],
      ),
    );
  }
}

class ItemImageSelectionScreen extends StatefulWidget {
  final Item item;

  const ItemImageSelectionScreen({
    super.key,
    required this.item,
  });

  @override
  State<ItemImageSelectionScreen> createState() => _ItemImageSelectionScreenState();
}

class _ItemImageSelectionScreenState extends State<ItemImageSelectionScreen> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final urls = widget.item.imageUrls;

    return Scaffold(
      appBar: AppBar(title: const Text('Seleccion de imagen')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: urls.length,
                onPageChanged: (index) => setState(() => _pageIndex = index),
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      urls[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
              ),
            ),
            if (urls.length > 1)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _Dots(count: urls.length, index: _pageIndex),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Volver al detalle'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  final List<String> imageUrls;
  final double height;
  final bool isFavorited;
  final VoidCallback onToggleFavorite;
  final ValueChanged<int> onPageChanged;

  const _Gallery({
    required this.imageUrls,
    required this.height,
    required this.isFavorited,
    required this.onToggleFavorite,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrls.length == 1) {
      return _ImageCard(
        url: imageUrls.first,
        height: height,
        isFavorited: isFavorited,
        onToggleFavorite: onToggleFavorite,
      );
    }

    return SizedBox(
      height: height,
      child: PageView.builder(
        itemCount: imageUrls.length,
        onPageChanged: onPageChanged,
        itemBuilder: (context, index) => _ImageCard(
          url: imageUrls[index],
          height: height,
          isFavorited: isFavorited,
          onToggleFavorite: onToggleFavorite,
        ),
      ),
    );
  }
}

class _ImageCard extends StatelessWidget {
  final String url;
  final double height;
  final bool isFavorited;
  final VoidCallback onToggleFavorite;

  const _ImageCard({
    required this.url,
    required this.height,
    required this.isFavorited,
    required this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            color: Color(0x1A000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(999),
              ),
              child: FavoriteHeartButton(
                filled: isFavorited,
                onTap: onToggleFavorite,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  final int count;
  final int index;

  const _Dots({
    required this.count,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 6),
      child: Row(
        children: List.generate(count, (position) {
          final active = position == index;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(right: 6),
            width: active ? 10 : 6,
            height: 6,
            decoration: BoxDecoration(
              color: active ? const Color(0xFF1E1E1E) : const Color(0xFFB9B4AB),
              borderRadius: BorderRadius.circular(12),
            ),
          );
        }),
      ),
    );
  }
}

class _ProductInfo extends StatelessWidget {
  final Item item;
  final String sellerName;
  final String priceLabel;

  const _ProductInfo({
    required this.item,
    required this.sellerName,
    required this.priceLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            item.title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            priceLabel,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          _InfoRow(label: 'Talle', value: item.size),
          const SizedBox(height: 6),
          _InfoRow(label: 'Estado', value: item.condition),
          const SizedBox(height: 6),
          _InfoRow(label: 'Color', value: item.color ?? 'No especificado'),
          const SizedBox(height: 6),
          _InfoRow(label: 'Vendedora', value: sellerName),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 82,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, color: Color(0xFF6A645C)),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _DetailTags extends StatelessWidget {
  final Item item;

  const _DetailTags({required this.item});

  @override
  Widget build(BuildContext context) {
    final tags = <String>[
      item.category,
      if (item.ageSuggested != null && item.ageSuggested!.isNotEmpty)
        item.ageSuggested!,
      if (item.brand != null && item.brand!.isNotEmpty) item.brand!,
      ...item.tags,
    ];

    if (tags.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: tags.map((tag) => TagChip(label: tag)).toList(),
      ),
    );
  }
}

class _SellerNote extends StatelessWidget {
  final String text;
  final bool expanded;
  final VoidCallback onToggle;

  const _SellerNote({
    required this.text,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final trimmed = text.trim();
    final shouldTruncate = trimmed.length > 120;
    final displayText = (expanded || !shouldTruncate)
        ? trimmed
        : '${trimmed.substring(0, 120)}…';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF9F2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE6E0D5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Nota de la mamá',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6A645C),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              displayText.isEmpty ? 'Sin nota' : displayText,
              style: const TextStyle(fontSize: 14),
            ),
            if (shouldTruncate)
              GestureDetector(
                onTap: onToggle,
                child: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    expanded ? 'ver menos' : 'ver más',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF2A2A2A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SocialSignals extends StatelessWidget {
  final int inquiryCount;
  final String lastActivity;

  const _SocialSignals({
    required this.inquiryCount,
    required this.lastActivity,
  });

  @override
  Widget build(BuildContext context) {
    final label = inquiryCount == 1 ? 'consulta' : 'consultas';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 18,
            color: Color(0xFF6A645C),
          ),
          const SizedBox(width: 6),
          Text(
            '$inquiryCount $label · $lastActivity',
            style: const TextStyle(fontSize: 13, color: Color(0xFF6A645C)),
          ),
        ],
      ),
    );
  }
}

class _RecommendedSection extends StatelessWidget {
  final List<Item> items;
  final ItemsRepository repository;
  final String Function(double price) priceFormatter;

  const _RecommendedSection({
    required this.items,
    required this.repository,
    required this.priceFormatter,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Te puede interesar',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 170,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final item = items[index];
              return _MiniCard(
                item: item,
                priceLabel: priceFormatter(item.price),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ItemDetailScreen(
                        itemId: item.id,
                        repository: repository,
                      ),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (_, _) => const SizedBox(width: 12),
            itemCount: items.length,
          ),
        ),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  final Item item;
  final String priceLabel;
  final VoidCallback onTap;

  const _MiniCard({
    required this.item,
    required this.priceLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              color: Color(0x1A000000),
              offset: Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            Expanded(
              child: Image.network(
                item.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Text(
                priceLabel,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyBottomBar extends StatelessWidget {
  final VoidCallback onChat;
  final VoidCallback onBuy;

  const _StickyBottomBar({
    required this.onChat,
    required this.onBuy,
  });

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: Container(
        padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + bottom),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Color(0x1A000000),
              offset: Offset(0, -2),
            ),
          ],
          border: Border(top: BorderSide(color: Color(0xFFE6E0D5))),
        ),
        child: Row(
          children: [
            Expanded(
              child: _PrimaryButton(label: 'Chat', onPressed: onChat),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PrimaryButton(label: 'Comprar', onPressed: onBuy),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
