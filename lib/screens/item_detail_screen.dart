import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../widgets/polaroid_item_card.dart';

class ItemDetailScreen extends StatefulWidget {
  final Map<String, dynamic> item;
  final void Function(String id) onToggleFavorite;
  final void Function(String type, String value) onTagTap;

  // Para "recomendados" en Detalle (solo si es favorito)
  final List<Map<String, dynamic>> allItems;
  final String? activeTagType;
  final String? activeTagValue;

  const ItemDetailScreen({
    super.key,
    required this.item,
    required this.onToggleFavorite,
    required this.onTagTap,
    required this.allItems,
    required this.activeTagType,
    required this.activeTagValue,
  });

  @override
  State<ItemDetailScreen> createState() => _ItemDetailScreenState();
}

class _ItemDetailScreenState extends State<ItemDetailScreen> {
  bool _flipped = false;
  late bool _isFav;

  // ✅ estado visual del último tag tocado en Detalle
  String? _selectedTagType; // 'type' | 'age' | 'cond'
  String? _selectedTagValue;

  @override
  void initState() {
    super.initState();
    _isFav = (widget.item['fav'] as bool?) ?? false;
  }

  void _flip() => setState(() => _flipped = !_flipped);

  void _toggleFav() {
    final id = widget.item['id']?.toString();
    if (id == null) return;

    widget.onToggleFavorite(id);

    setState(() {
      _isFav = (widget.item['fav'] as bool?) ?? false;
    });
  }

  void _handleTagTap(String type, String value) {
    setState(() {
      _selectedTagType = type;
      _selectedTagValue = value;
    });
    widget.onTagTap(type, value);
  }

  List<Map<String, dynamic>> _computeRecommended() {
    final curId = widget.item['id']?.toString();
    final curType = widget.item['type']?.toString();
    final curAge = widget.item['age']?.toString();
    final curCond = widget.item['cond']?.toString();
    final curSize = widget.item['size']?.toString();

    final activeType = widget.activeTagType;
    final activeValue = widget.activeTagValue;

    int score(Map<String, dynamic> it) {
      int s = 0;
      if (curType != null && it['type']?.toString() == curType) s += 3;
      if (curAge != null && it['age']?.toString() == curAge) s += 2;
      if (curSize != null && it['size']?.toString() == curSize) s += 2;
      if (curCond != null && it['cond']?.toString() == curCond) s += 1;

      // Refuerzo: si venís de un filtro activo, empuja coincidencias
      if (activeType != null && activeValue != null) {
        if (it[activeType]?.toString() == activeValue) s += 2;
      }

      // Refuerzo: señales orgánicas (q)
      final q = (it['q'] is int) ? it['q'] as int : int.tryParse('${it['q']}') ?? 0;
      if (q >= 10) s += 1;

      return s;
    }

    final candidates = widget.allItems
        .where((it) => it['id']?.toString() != curId)
        .toList();

    candidates.sort((a, b) => score(b).compareTo(score(a)));

    final top = <Map<String, dynamic>>[];
    for (final it in candidates) {
      if (score(it) <= 0) continue;
      top.add(it);
      if (top.length == 3) break;
    }
    return top;
  }

  Widget _buildRecommendedSection() {
    if (!_isFav) return const SizedBox.shrink();

    final rec = _computeRecommended();
    if (rec.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'recomendados',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 210,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: rec.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final it = rec[i];

                return SizedBox(
                  width: 170,
                  child: PolaroidItemCard(
                    imageUrl: it['image'] as String,
                    priceText: it['price'] as String,
                    badgeText: it['badge'] as String?,
                    isFavorited: (it['fav'] as bool?) == true,
                    onFavoriteTap: () {
                      final rid = it['id']?.toString();
                      if (rid == null) return;
                      widget.onToggleFavorite(rid);
                      setState(() {}); // por si cambia un ícono mientras estás acá
                    },
                    typeText: it['type'] as String,
                    ageText: it['age'] as String,
                    conditionText: it['cond'] as String,
                    onTypeTap: () => _handleTagTap('type', it['type'] as String),
                    onAgeTap: () => _handleTagTap('age', it['age'] as String),
                    onConditionTap: () => _handleTagTap('cond', it['cond'] as String),
                    onOpen: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ItemDetailScreen(
                            item: it,
                            onToggleFavorite: widget.onToggleFavorite,
                            onTagTap: widget.onTagTap,
                            allItems: widget.allItems,
                            activeTagType: widget.activeTagType,
                            activeTagValue: widget.activeTagValue,
                          ),
                        ),
                      );
                      setState(() {
                        _isFav = (widget.item['fav'] as bool?) ?? false;
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    final String imageUrl = item['image'] as String;
    final String priceText = item['price'] as String;
    final String? badgeText = item['badge'] as String?;

    final String typeText = item['type'] as String;
    final String ageText = item['age'] as String;
    final String condText = item['cond'] as String;

    final String titleShort = item['title'] as String;
    final String statusText = item['status'] as String;
    final String sizeText = item['size'] as String;

    final int q = item['q'] as int;
    final String last = item['last'] as String;
    final String note = (item['note'] as String?) ?? '';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: FavoriteHeartButton(
              isFavorited: _isFav,
              onTap: _toggleFav,
              iconSize: 22,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _flip,
                child: TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0, end: _flipped ? 1 : 0),
                  duration: const Duration(milliseconds: 420),
                  curve: Curves.easeInOut,
                  builder: (context, v, _) {
                    final angle = v * math.pi;
                    final showBack = v > 0.5;

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateY(angle),
                      child: showBack
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(math.pi),
                              child: _BackFull(
                                titleShort: titleShort,
                                statusText: statusText,
                                badgeText: badgeText,
                                priceText: priceText,
                                ageText: ageText,
                                sizeText: sizeText,
                                questionsCount: q,
                                lastActivityText: last,
                                note: note,
                                recommended: _buildRecommendedSection(),
                              ),
                            )
                          : _FrontFull(
                              imageUrl: imageUrl,
                              badgeText: badgeText,
                              priceText: priceText,
                              typeText: typeText,
                              ageText: ageText,
                              condText: condText,
                              selectedTagType: _selectedTagType,
                              selectedTagValue: _selectedTagValue,
                              onTypeTap: () => _handleTagTap('type', typeText),
                              onAgeTap: () => _handleTagTap('age', ageText),
                              onCondTap: () => _handleTagTap('cond', condText),
                            ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FrontFull extends StatelessWidget {
  final String imageUrl;
  final String? badgeText;
  final String priceText;

  final String typeText;
  final String ageText;
  final String condText;

  final String? selectedTagType;
  final String? selectedTagValue;

  final VoidCallback onTypeTap;
  final VoidCallback onAgeTap;
  final VoidCallback onCondTap;

  const _FrontFull({
    required this.imageUrl,
    required this.badgeText,
    required this.priceText,
    required this.typeText,
    required this.ageText,
    required this.condText,
    required this.selectedTagType,
    required this.selectedTagValue,
    required this.onTypeTap,
    required this.onAgeTap,
    required this.onCondTap,
  });

  @override
  Widget build(BuildContext context) {
    const radius = 22.0;

    final selType = selectedTagType;
    final selVal = selectedTagValue;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(imageUrl, fit: BoxFit.cover),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      height: 84,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Colors.transparent, Colors.black54],
                        ),
                      ),
                    ),
                  ),
                  if (badgeText != null)
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: _PillWhite(text: badgeText!),
                    ),
                  Positioned(
                    right: 14,
                    bottom: 14,
                    child: _PillWhite(text: priceText, bold: true),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Tag(
                    text: typeText,
                    onTap: onTypeTap,
                    selected: selType == 'type' && selVal == typeText,
                  ),
                  _Tag(
                    text: ageText,
                    onTap: onAgeTap,
                    selected: selType == 'age' && selVal == ageText,
                  ),
                  _Tag(
                    text: condText,
                    onTap: onCondTap,
                    selected: selType == 'cond' && selVal == condText,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
              child: Row(
                children: [
                  Icon(Icons.touch_app_outlined,
                      size: 18, color: Colors.black.withOpacity(0.6)),
                  const SizedBox(width: 8),
                  Text(
                    'Tocá para ver info',
                    style: TextStyle(color: Colors.black.withOpacity(0.65)),
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

class _BackFull extends StatelessWidget {
  final String titleShort;
  final String statusText;

  final String? badgeText;
  final String priceText;

  final String ageText;
  final String sizeText;

  final int questionsCount;
  final String lastActivityText;

  final String note;

  final Widget recommended;

  const _BackFull({
    required this.titleShort,
    required this.statusText,
    required this.badgeText,
    required this.priceText,
    required this.ageText,
    required this.sizeText,
    required this.questionsCount,
    required this.lastActivityText,
    required this.note,
    required this.recommended,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    const sectionTitle = TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 0.6,
      height: 1.0,
    );

    final labelStyle = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w700,
      color: Colors.black.withOpacity(0.65),
      letterSpacing: 0.3,
      height: 1.0,
    );

    const valueStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w700,
      color: Colors.black87,
      height: 1.05,
    );

    final destino = (badgeText ?? '').trim();
    final bool isMoney = priceText.trim().startsWith('\$');
    final String precioVisible = isMoney ? priceText : '—';

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      titleShort,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: cs.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      statusText.toLowerCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Text('publicación', style: sectionTitle),
              const SizedBox(height: 12),
              Wrap(
                spacing: 18,
                runSpacing: 12,
                children: [
                  _Field(
                      label: 'destino',
                      value: destino.isEmpty ? '—' : destino,
                      labelStyle: labelStyle,
                      valueStyle: valueStyle),
                  _Field(
                      label: 'precio',
                      value: precioVisible,
                      labelStyle: labelStyle,
                      valueStyle: valueStyle),
                  _Field(
                      label: 'edad',
                      value: ageText,
                      labelStyle: labelStyle,
                      valueStyle: valueStyle),
                  _Field(
                      label: 'talle',
                      value: sizeText,
                      labelStyle: labelStyle,
                      valueStyle: valueStyle),
                ],
              ),
              const SizedBox(height: 16),
              const Text('señales orgánicas', style: sectionTitle),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.chat_bubble_outline,
                      label: 'consultas',
                      value: '$questionsCount',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MiniStat(
                      icon: Icons.history,
                      label: 'última actividad',
                      value: lastActivityText,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Text('nota', style: sectionTitle),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  note.isEmpty ? '—' : note,
                  style: const TextStyle(fontSize: 13, height: 1.25),
                ),
              ),
              // ✅ Recomendados (solo si es favorito)
              recommended,
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.touch_app_outlined,
                      size: 18, color: Colors.black.withOpacity(0.6)),
                  const SizedBox(width: 8),
                  Text('Tocá para volver',
                      style: TextStyle(color: Colors.black.withOpacity(0.65))),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* ---------------- UI helpers (idénticos al original) ---------------- */

class _Field extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle labelStyle;
  final TextStyle valueStyle;

  const _Field({
    required this.label,
    required this.value,
    required this.labelStyle,
    required this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: labelStyle),
          const SizedBox(height: 6),
          Text(value, style: valueStyle),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.black.withOpacity(0.65)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                      color: Colors.black.withOpacity(0.65),
                    )),
                const SizedBox(height: 6),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PillWhite extends StatelessWidget {
  final String text;
  final bool bold;

  const _PillWhite({required this.text, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: bold ? FontWeight.w900 : FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool selected;

  const _Tag({
    required this.text,
    required this.onTap,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? cs.primary.withOpacity(0.12) : Colors.black.withOpacity(0.04),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? cs.primary.withOpacity(0.55) : Colors.black.withOpacity(0.08),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check_circle, size: 16, color: cs.primary),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: selected ? cs.primary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
