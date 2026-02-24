import 'dart:math' as math;

import 'package:flutter/material.dart';

class PolaroidItemCard extends StatefulWidget {
  final String? badgeText;
  final String imageUrl;
  final String priceText;

  final bool isFavorited;
  final VoidCallback? onFavoriteTap;

  final VoidCallback? onBadgeTap;
  final VoidCallback? onPriceTap;
  final bool badgeSelected;
  final bool priceSelected;

  /// ✅ Se dispara SOLO cuando el usuario toca el REVERSO.
  final VoidCallback? onOpenBack;

  /// Datos que aparecen en el reverso (metadata).
  final String? backTitle;
  final String? backSize;
  final int? backInquiries;

  /// true = ítem “activo / enfocado”
  /// false = ítem atenuado
  final bool isFocused;

  const PolaroidItemCard({
    super.key,
    required this.badgeText,
    required this.imageUrl,
    required this.priceText,
    required this.isFavorited,
    required this.onFavoriteTap,
    this.onBadgeTap,
    this.onPriceTap,
    this.badgeSelected = false,
    this.priceSelected = false,
    this.onOpenBack,
    this.backTitle,
    this.backSize,
    this.backInquiries,
    required this.isFocused,
  });

  @override
  State<PolaroidItemCard> createState() => _PolaroidItemCardState();
}

class _PolaroidItemCardState extends State<PolaroidItemCard> {
  bool _flipped = false;

  void _toggleFlip() => setState(() => _flipped = !_flipped);

  @override
  Widget build(BuildContext context) {
    final overlayOpacity = widget.isFocused ? 0.0 : 0.12;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              blurRadius: 18,
              offset: const Offset(0, 10),
              color: Colors.black.withValues(alpha: 0.08),
            ),
          ],
        ),
        child: _FlipCard(
          flipped: _flipped,
          front: Stack(
            children: [
              Positioned.fill(
                child: InkWell(
                  onTap: _toggleFlip,
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: Colors.black.withValues(alpha: 0.06),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
              ),
              if (overlayOpacity > 0)
                Positioned.fill(
                  child: IgnorePointer(
                    ignoring: true,
                    child: Container(
                      color: Colors.white.withValues(alpha: overlayOpacity),
                    ),
                  ),
                ),
              Positioned(
                top: 10,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    if (widget.badgeText != null &&
                        widget.badgeText!.trim().isNotEmpty)
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.onBadgeTap,
                        child: _BadgePill(
                          text: widget.badgeText!.trim(),
                          selected: widget.badgeSelected,
                        ),
                      ),
                    const Spacer(),
                    FavoriteHeartButton(
                      filled: widget.isFavorited,
                      onTap: widget.onFavoriteTap,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 10,
                bottom: 10,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: widget.onPriceTap,
                  child:
                      _PricePill(text: widget.priceText, selected: widget.priceSelected),
                ),
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: _FlipHint(onTap: _toggleFlip),
              ),
            ],
          ),
          back: _BackCard(
            title: widget.backTitle ?? 'Artículo',
            size: widget.backSize ?? '—',
            inquiries: widget.backInquiries ?? 0,
            onBack: _toggleFlip,
            onOpen: widget.onOpenBack,
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
    const dur = Duration(milliseconds: 420);

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

class _BackCard extends StatelessWidget {
  final String title;
  final String size;
  final int inquiries;
  final VoidCallback onBack;
  final VoidCallback? onOpen;

  const _BackCard({
    required this.title,
    required this.size,
    required this.inquiries,
    required this.onBack,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.flip),
                    onPressed: onBack,
                    tooltip: 'Volver al frente',
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Reverso',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _BackRow(label: 'Talle', value: size),
              _BackRow(label: 'Consultas', value: '$inquiries'),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Abrir detalle',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BackRow extends StatelessWidget {
  final String label;
  final String value;

  const _BackRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.black.withValues(alpha: 0.55),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _FlipHint extends StatelessWidget {
  final VoidCallback onTap;
  const _FlipHint({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: Colors.black.withValues(alpha: 0.12)),
        ),
        child: const Icon(Icons.flip, size: 16),
      ),
    );
  }
}

class FavoriteHeartButton extends StatefulWidget {
  final bool filled;
  final VoidCallback? onTap;
  final double iconSize;

  const FavoriteHeartButton({
    super.key,
    required this.filled,
    required this.onTap,
    this.iconSize = 22,
  });

  @override
  State<FavoriteHeartButton> createState() => _FavoriteHeartButtonState();
}

class _FavoriteHeartButtonState extends State<FavoriteHeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  late final Animation<double> _pop = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.0, 0.35, curve: Curves.easeOutBack),
  );

  late final Animation<double> _burst = CurvedAnimation(
    parent: _c,
    curve: const Interval(0.05, 0.95, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  void _trigger() => _c.forward(from: 0);

  @override
  Widget build(BuildContext context) {
    final filled = widget.filled;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        _trigger();
        widget.onTap?.call();
      },
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final s = 1.0 + (_pop.value * 0.20);
            return Stack(
              alignment: Alignment.center,
              children: [
                IgnorePointer(
                  child: CustomPaint(
                    size: const Size(40, 40),
                    painter: _BurstDotsPainter(progress: _burst.value),
                  ),
                ),
                Transform.scale(
                  scale: s,
                  child: Icon(
                    filled ? Icons.favorite : Icons.favorite_border,
                    size: widget.iconSize,
                    color: filled ? const Color(0xFF6E3CBC) : Colors.black87,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BurstDotsPainter extends CustomPainter {
  final double progress;
  const _BurstDotsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    const dots = 7;
    final maxR = size.shortestSide * 1.1;
    final alpha = (1.0 - progress).clamp(0.0, 1.0);

    paint.color = const Color(0xFF6E3CBC).withValues(alpha: 0.65 * alpha);

    for (int i = 0; i < dots; i++) {
      final a = (i / dots) * math.pi * 2;
      final r = (0.25 + 0.75 * progress) * maxR;
      final p = center + Offset(math.cos(a) * r, math.sin(a) * r);
      final dotSize = (1.0 - progress) * 2.2 + 1.1;
      canvas.drawCircle(p, dotSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BurstDotsPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _PricePill extends StatelessWidget {
  final String text;
  final bool selected;
  const _PricePill({required this.text, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF6E3CBC).withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected
              ? const Color(0xFF6E3CBC)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: selected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final String text;
  final bool selected;
  const _BadgePill({required this.text, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF6E3CBC).withValues(alpha: 0.92)
            : Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: selected
              ? const Color(0xFF6E3CBC)
              : Colors.black.withValues(alpha: 0.08),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 12,
          color: selected ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
