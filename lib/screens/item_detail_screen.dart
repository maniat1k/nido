import 'package:flutter/material.dart';
import '../widgets/polaroid_item_card.dart';

class NidoItem {
  final String id;
  final String? title;
  final String price;
  final String size;
  final String color;
  final String note; // max 200
  final List<String> imageUrls;
  final int inquiryCount;
  final List<NidoItem> recommended;

  const NidoItem({
    required this.id,
    this.title,
    required this.price,
    required this.size,
    required this.color,
    required this.note,
    required this.imageUrls,
    required this.inquiryCount,
    this.recommended = const [],
  });
}

class ItemDetailScreen extends StatefulWidget {
  final NidoItem item;
  final VoidCallback onBack;
  final VoidCallback onBackToHome;
  final ValueChanged<NidoItem> onBackToImageSelection;
  final void Function(String itemId) onToggleFavorite;
  final ValueChanged<NidoItem> onChat;
  final ValueChanged<NidoItem> onBuy;
  final ValueChanged<NidoItem> onOpenRecommended;
  final bool isFavorited;

  final bool isChatLoading;
  final bool isBuyLoading;
  final bool isChatEnabled;
  final bool isBuyEnabled;

  const ItemDetailScreen({
    super.key,
    required this.item,
    required this.onBack,
    required this.onBackToHome,
    required this.onBackToImageSelection,
    required this.onToggleFavorite,
    required this.onChat,
    required this.onBuy,
    required this.onOpenRecommended,
    this.isFavorited = false,
    this.isChatLoading = false,
    this.isBuyLoading = false,
    this.isChatEnabled = true,
    this.isBuyEnabled = true,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  int _pageIndex = 0;
  bool _noteExpanded = false;
  late bool _isFav;

  @override
  void initState() {
    super.initState();
    _isFav = widget.isFavorited;
  }

  void _toggleFavorite() {
    setState(() => _isFav = !_isFav);
    widget.onToggleFavorite(widget.item.id);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final media = MediaQuery.of(context);
    final galleryHeight = media.size.height * 0.40;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5F0),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _DetailHeader(
                  title: 'Detalle',
                  onBack: widget.onBack,
                  onBackToHome: widget.onBackToHome,
                  onImageSelection: () =>
                      widget.onBackToImageSelection(widget.item),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 92),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Gallery(
                          imageUrls: item.imageUrls,
                          height: galleryHeight,
                          isFavorited: _isFav,
                          onToggleFavorite: _toggleFavorite,
                          onPageChanged: (i) => setState(() => _pageIndex = i),
                        ),
                        if (item.imageUrls.length > 1)
                          _Dots(
                            count: item.imageUrls.length,
                            index: _pageIndex,
                          ),
                        const SizedBox(height: 12),
                        _ProductInfo(item: item),
                        const SizedBox(height: 16),
                        _SellerNote(
                          text: item.note,
                          expanded: _noteExpanded,
                          onToggle: () =>
                              setState(() => _noteExpanded = !_noteExpanded),
                        ),
                        const SizedBox(height: 12),
                        _SocialSignals(inquiryCount: item.inquiryCount),
                        const SizedBox(height: 18),
                        if (item.recommended.isNotEmpty)
                          _RecommendedSection(
                            items: item.recommended,
                            onOpen: widget.onOpenRecommended,
                          ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            _StickyBottomBar(
              isChatLoading: widget.isChatLoading,
              isBuyLoading: widget.isBuyLoading,
              isChatEnabled: widget.isChatEnabled,
              isBuyEnabled: widget.isBuyEnabled,
              onChat: () => widget.onChat(item),
              onBuy: () => widget.onBuy(item),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onBackToHome;
  final VoidCallback onImageSelection;

  const _DetailHeader({
    required this.title,
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
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2DED6)),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: onBack,
          ),
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
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
  final NidoItem item;
  final VoidCallback onOpenDetail;

  const ItemImageSelectionScreen({
    super.key,
    required this.item,
    required this.onOpenDetail,
  });

  @override
  State<ItemImageSelectionScreen> createState() => _ItemImageSelectionScreenState();
}

class _ItemImageSelectionScreenState extends State<ItemImageSelectionScreen> {
  int _pageIndex = 0;

  @override
  Widget build(BuildContext context) {
    final urls = widget.item.imageUrls.isNotEmpty
        ? widget.item.imageUrls
        : ['https://via.placeholder.com/800x1000.png?text=Sin+foto'];

    return Scaffold(
      appBar: AppBar(title: const Text('Seleccion de imagen')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                itemCount: urls.length,
                onPageChanged: (i) => setState(() => _pageIndex = i),
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
                  onPressed: widget.onOpenDetail,
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
    final safeUrls = imageUrls.isNotEmpty
        ? imageUrls
        : ['https://via.placeholder.com/800x1000.png?text=Sin+foto'];

    if (safeUrls.length == 1) {
      return _ImageCard(
        url: safeUrls.first,
        height: height,
        isFavorited: isFavorited,
        onToggleFavorite: onToggleFavorite,
      );
    }

    return SizedBox(
      height: height,
      child: PageView.builder(
        itemCount: safeUrls.length,
        onPageChanged: onPageChanged,
        itemBuilder: (context, index) => _ImageCard(
          url: safeUrls[index],
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
        children: List.generate(count, (i) {
          final active = i == index;
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
  final NidoItem item;

  const _ProductInfo({required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.title != null && item.title!.trim().isNotEmpty)
            Text(
              item.title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          const SizedBox(height: 6),
          Text(
            item.price,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _InfoRow(label: 'Talle', value: item.size),
          const SizedBox(height: 6),
          _InfoRow(label: 'Color', value: item.color),
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
          width: 64,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF6A645C),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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

  const _SocialSignals({required this.inquiryCount});

  @override
  Widget build(BuildContext context) {
    final label = inquiryCount == 1 ? 'consulta' : 'consultas';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          const Icon(Icons.chat_bubble_outline,
              size: 18, color: Color(0xFF6A645C)),
          const SizedBox(width: 6),
          Text(
            '$inquiryCount $label',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6A645C),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecommendedSection extends StatelessWidget {
  final List<NidoItem> items;
  final ValueChanged<NidoItem> onOpen;

  const _RecommendedSection({
    required this.items,
    required this.onOpen,
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 170,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, i) {
              final item = items[i];
              return _MiniPolaroid(
                item: item,
                onTap: () => onOpen(item),
              );
            },
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemCount: items.length,
          ),
        ),
      ],
    );
  }
}

class _MiniPolaroid extends StatelessWidget {
  final NidoItem item;
  final VoidCallback onTap;

  const _MiniPolaroid({
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final img = item.imageUrls.isNotEmpty
        ? item.imageUrls.first
        : 'https://via.placeholder.com/300x400.png?text=Sin+foto';

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
                img,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
              child: Text(
                item.price,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StickyBottomBar extends StatelessWidget {
  final bool isChatLoading;
  final bool isBuyLoading;
  final bool isChatEnabled;
  final bool isBuyEnabled;
  final VoidCallback onChat;
  final VoidCallback onBuy;

  const _StickyBottomBar({
    required this.isChatLoading,
    required this.isBuyLoading,
    required this.isChatEnabled,
    required this.isBuyEnabled,
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
          border: Border(
            top: BorderSide(color: Color(0xFFE6E0D5)),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: _PrimaryButton(
                label: 'Chat',
                isLoading: isChatLoading,
                isEnabled: isChatEnabled,
                onPressed: onChat,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PrimaryButton(
                label: 'Comprar',
                isLoading: isBuyLoading,
                isEnabled: isBuyEnabled,
                onPressed: onBuy,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = !isEnabled || isLoading;
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E1E1E),
          disabledBackgroundColor: const Color(0xFFB5B0A7),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
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
