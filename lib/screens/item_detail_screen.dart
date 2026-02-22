import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../widgets/polaroid_item_card.dart';

class ItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback onToggleFavorite;

  /// Toggle del filtro global.
  final void Function(String type, String value) onTagTap;

  final String? activeTagType;
  final String? activeTagValue;

  const ItemDetailScreen({
    super.key,
    required this.item,
    required this.onToggleFavorite,
    required this.onTagTap,
    this.activeTagType,
    this.activeTagValue,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _flipped = false;
  late bool _isFav;

  String? _activeTagType;
  String? _activeTagValue;

  @override
  void initState() {
    super.initState();
    _isFav = (widget.item['fav'] as bool?) ?? false;
    _activeTagType = widget.activeTagType;
    _activeTagValue = widget.activeTagValue;
  }

  void _toggleFav() {
    setState(() => _isFav = !_isFav);
    widget.onToggleFavorite();
  }

  void _toggleFlip() {
    setState(() => _flipped = !_flipped);
  }

  void _tapTag(String type, String value) {
    setState(() {
      if (_activeTagType == type && _activeTagValue == value) {
        _activeTagType = null;
        _activeTagValue = null;
      } else {
        _activeTagType = type;
        _activeTagValue = value;
      }
    });
    widget.onTagTap(type, value);
  }

  @override
  Widget build(BuildContext context) {
    final it = widget.item;

    final type = (it['type'] as String?) ?? '';
    final age = (it['age'] as String?) ?? '';
    final cond = (it['cond'] as String?) ?? '';
    final badge = it['badge'] as String?;
    final imageUrl = (it['image'] as String?) ?? '';
    final price = (it['price'] as String?) ?? '—';

    final typeSelected = _activeTagType == 'type' && _activeTagValue == type;
    final ageSelected = _activeTagType == 'age' && _activeTagValue == age;
    final condSelected = _activeTagType == 'cond' && _activeTagValue == cond;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        actions: [
          IconButton(
            tooltip: 'Cambiar vista',
            onPressed: _toggleFlip,
            icon: const Icon(Icons.flip_camera_android_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FavoriteHeartButton(
              filled: _isFav,
              onTap: _toggleFav,
              iconSize: 22,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleFlip, // ✅ tap en la imagen también hace flip
            child: _FlipCard(
              flipped: _flipped,
              front: _FrontCard(
                imageUrl: imageUrl,
                badgeText: badge,
                priceText: price,
                typeText: type,
                ageText: age,
                conditionText: cond,
                typeSelected: typeSelected,
                ageSelected: ageSelected,
                conditionSelected: condSelected,
                onTypeTap: () => _tapTag('type', type),
                onAgeTap: () => _tapTag('age', age),
                onConditionTap: () => _tapTag('cond', cond),
              ),
              back: _BackCard(
                title: (it['title'] as String?) ?? 'Artículo',
                status: (it['status'] as String?) ?? '—',
                size: (it['size'] as String?) ?? '—',
                questions: (it['q'] as int?) ?? 0,
                lastActivity: (it['last'] as String?) ?? '—',
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FlipCard extends StatelessWidget {
  final bool flipped;
  final Widget front;
  final Widget back;

  const _FlipCard({
    required this.flipped,
    required this.front,
    required this.back,
  });

  @override
  Widget build(BuildContext context) {
    const dur = Duration(milliseconds: 450);

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: flipped ? 1 : 0),
      duration: dur,
      curve: Curves.easeInOut,
      builder: (context, t, _) {
        final angle = t * math.pi;
        final isBack = t > 0.5;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: isBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: back,
                )
              : front,
        );
      },
    );
  }
}

class _FrontCard extends StatelessWidget {
  final String imageUrl;
  final String? badgeText;
  final String priceText;

  final String typeText;
  final String ageText;
  final String conditionText;

  final bool typeSelected;
  final bool ageSelected;
  final bool conditionSelected;

  final VoidCallback onTypeTap;
  final VoidCallback onAgeTap;
  final VoidCallback onConditionTap;

  const _FrontCard({
    required this.imageUrl,
    required this.badgeText,
    required this.priceText,
    required this.typeText,
    required this.ageText,
    required this.conditionText,
    required this.typeSelected,
    required this.ageSelected,
    required this.conditionSelected,
    required this.onTypeTap,
    required this.onAgeTap,
    required this.onConditionTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 1,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  color: Colors.black.withValues(alpha: 0.06),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported_outlined),
                ),
              ),
            ),

            // Capa de degradado para mejorar legibilidad de textos
            Positioned.fill(
              child: IgnorePointer(
                ignoring: true,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.55, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.55), 
                      ],
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  if (badgeText != null && badgeText!.trim().isNotEmpty)
                    _Pill(text: badgeText!.trim()),
                  const Spacer(),
                ],
              ),
            ),

            Positioned(
              left: 10,
              bottom: 52,
              child: _Pill(text: priceText),
            ),

            Positioned(
              left: 10,
              right: 10,
              bottom: 10,
              child: Row(
                children: [
                  Expanded(
                    child: BurstTagPill(
                      text: typeText,
                      selected: typeSelected,
                      onTap: onTypeTap,
                      maxWidth: 130,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BurstTagPill(
                      text: ageText,
                      selected: ageSelected,
                      onTap: onAgeTap,
                      maxWidth: 130,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BurstTagPill(
                      text: conditionText,
                      selected: conditionSelected,
                      onTap: onConditionTap,
                      maxWidth: 130,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackCard extends StatelessWidget {
  final String title;
  final String status;
  final String size;
  final int questions;
  final String lastActivity;

  const _BackCard({
    required this.title,
    required this.status,
    required this.size,
    required this.questions,
    required this.lastActivity,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.all(16),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style:
                    const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
              const SizedBox(height: 10),
              _Row(label: 'Estado', value: status),
              _Row(label: 'Talle', value: size),
              _Row(label: 'Consultas', value: '$questions'),
              _Row(label: 'Última actividad', value: lastActivity),
            ],
          ),
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;

  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.55),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
        ),
      ),
    );
  }
}