import 'dart:math' as math;

import 'package:flutter/material.dart';

class PolaroidItemCard extends StatelessWidget {
  final String? badgeText; // Ej: "Nuevo", "Usado", "Oferta", etc. Si es null o vacío, no se muestra badge.
  final String imageUrl; 
  final String priceText; // Ej: "$1200", "Gratis", "A consultar", etc.
 
  // Estado de favorito (corazón), para mostrarlo lleno o vacío.
  final bool isFavorited; 
  final VoidCallback? onFavoriteTap; 

  final VoidCallback? onBadgeTap;
  final VoidCallback? onPriceTap;
  final bool badgeSelected;
  final bool priceSelected;

  final VoidCallback? onOpen;

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
    required this.isFocused,
    required this.onOpen,
  });

  @override
  Widget build(BuildContext context) {
    final overlayOpacity = isFocused ? 0.0 : 0.12;

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
        child: Stack(
          children: [
            // Imagen clickeable
            Positioned.fill(
              child: InkWell(
                onTap: onOpen,
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
            ),

            // ✅ FIX: overlay NO debe bloquear taps
            if (overlayOpacity > 0)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: true,
                  child: Container(
                    color: Colors.white.withValues(alpha:overlayOpacity),
                  ),
                ),
              ),

            // Badge + favorito
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Row(
                children: [
                  if (badgeText != null && badgeText!.trim().isNotEmpty)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: onBadgeTap,
                      child: _BadgePill(
                        text: badgeText!.trim(),
                        selected: badgeSelected,
                      ),
                    ),
                  const Spacer(),
                  FavoriteHeartButton(
                    filled: isFavorited,
                    onTap: onFavoriteTap,
                  ),
                ],
              ),
            ),

            // Precio
            Positioned(
              left: 10,
              bottom: 10,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onPriceTap,
                child: _PricePill(text: priceText, selected: priceSelected),
              ),
            ),
          ],
        ),
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

class BurstTagPill extends StatefulWidget {
  final String text;
  final bool selected;
  final VoidCallback? onTap;
  final double maxWidth;

  const BurstTagPill({
    super.key,
    required this.text,
    required this.selected,
    required this.onTap,
    this.maxWidth = 140,
  });

  @override
  State<BurstTagPill> createState() => _BurstTagPillState();
}

class _BurstTagPillState extends State<BurstTagPill>
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
    final sel = widget.selected;

    const accent = Color(0xFF6E3CBC);
    final bg = sel
        ? accent.withValues(alpha: 0.92)
        : Colors.black.withValues(alpha: 0.22);
    final border = sel ? accent.withValues(alpha: 0.78) : Colors.transparent;
    final fg = sel ? Colors.white : Colors.black87;

    final child = ConstrainedBox(
      constraints: BoxConstraints(minHeight: 26, maxWidth: widget.maxWidth),
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, _) {
          final s = 1.0 + (_pop.value * 0.12);
          return Stack(
            alignment: Alignment.center,
            children: [
              IgnorePointer(
                child: CustomPaint(
                  size: const Size(32, 32),
                  painter: _BurstDotsPainter(progress: _burst.value),
                ),
              ),
              Transform.scale(
                scale: s,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: border, width: 1.5),
                  ),
                  child: Text(
                    widget.text,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: fg,
                      height: 1.0,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    if (widget.onTap == null) return child;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: () {
        _trigger();
        widget.onTap?.call();
      },
      child: child,
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
