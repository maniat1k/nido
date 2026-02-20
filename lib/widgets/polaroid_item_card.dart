import 'dart:math' as math;

import 'package:flutter/material.dart';

class PolaroidItemCard extends StatelessWidget {
  final String? badgeText; // Donación / Trueque / Venta...
  final String imageUrl;
  final String priceText; // "$ 490" o "—"

  final bool isFavorited;
  final VoidCallback? onFavoriteTap;

  // Footer pills
  final String typeText;
  final String ageText;
  final String conditionText;

  // taps en tags
  final VoidCallback? onTypeTap;
  final VoidCallback? onAgeTap;
  final VoidCallback? onConditionTap;

  // abrir detalle
  final VoidCallback? onOpen;

  // foco visual
  final bool isFocused;

  const PolaroidItemCard({
    super.key,
    required this.imageUrl,
    required this.priceText,
    this.badgeText,
    this.isFavorited = false,
    this.onFavoriteTap,
    this.typeText = 'Body',
    this.ageText = '0–3m',
    this.conditionText = 'Usado',
    this.onTypeTap,
    this.onAgeTap,
    this.onConditionTap,
    this.onOpen,
    this.isFocused = false,
  });

  @override
  Widget build(BuildContext context) {
    const radius = 18.0;
    final cs = Theme.of(context).colorScheme;

    final borderColor =
        isFocused ? cs.primary.withOpacity(0.55) : Colors.transparent;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(radius),
        onTap: onOpen,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor, width: 2),
            boxShadow: const [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(0, 6),
                color: Color(0x14000000),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.black12,
                            alignment: Alignment.center,
                            child: const Icon(Icons.image_not_supported_outlined,
                                size: 40),
                          );
                        },
                      ),

                      // degradé suave para legibilidad de pills
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          height: 64,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black54],
                            ),
                          ),
                        ),
                      ),

                      // badge abajo izq
                      if (badgeText != null)
                        Positioned(
                          left: 12,
                          bottom: 12,
                          child: _BadgePill(text: badgeText!),
                        ),

                      // corazón arriba der (con micro-efecto)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: FavoriteHeartButton(
                          isFavorited: isFavorited,
                          onTap: onFavoriteTap,
                        ),
                      ),

                      // precio abajo der
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: _PricePill(text: priceText),
                      ),
                    ],
                  ),
                ),

                // Footer: chips compactos con wrap
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.local_offer_outlined,
                          size: 16, color: Colors.black54),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _MetaPill(text: typeText, onTap: onTypeTap),
                            _MetaPill(text: ageText, onTap: onAgeTap),
                            _MetaPill(
                                text: conditionText, onTap: onConditionTap),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FavoriteHeartButton extends StatefulWidget {
  final bool isFavorited;
  final VoidCallback? onTap;
  final double iconSize;

  const FavoriteHeartButton({
    super.key,
    required this.isFavorited,
    required this.onTap,
    this.iconSize = 20,
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

  void _trigger() {
    _c.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final filled = widget.isFavorited;

    return Material(
      color: Colors.white.withOpacity(0.92),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: widget.onTap == null
            ? null
            : () {
                _trigger();
                widget.onTap?.call();
              },
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: SizedBox(
            width: widget.iconSize,
            height: widget.iconSize,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) {
                final s = 1.0 + (_pop.value * 0.25);
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    IgnorePointer(
                      child: CustomPaint(
                        size: Size(widget.iconSize, widget.iconSize),
                        painter: _HeartBurstPainter(progress: _burst.value),
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
        ),
      ),
    );
  }
}

class _HeartBurstPainter extends CustomPainter {
  final double progress;
  const _HeartBurstPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.fill;

    const dots = 7;
    final maxR = size.shortestSide * 1.1;
    final alpha = (1.0 - progress).clamp(0.0, 1.0);

    paint.color = const Color(0xFF6E3CBC).withOpacity(0.65 * alpha);

    for (int i = 0; i < dots; i++) {
      final a = (i / dots) * math.pi * 2;
      final r = (0.25 + 0.75 * progress) * maxR;
      final p = center + Offset(math.cos(a) * r, math.sin(a) * r);
      final dotSize = (1.0 - progress) * 3.0 + 1.1;
      canvas.drawCircle(p, dotSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _HeartBurstPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _PricePill extends StatelessWidget {
  final String text;

  const _PricePill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _BadgePill extends StatelessWidget {
  final String text;

  const _BadgePill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _MetaPill({required this.text, this.onTap});

  @override
  Widget build(BuildContext context) {
    final pill = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 24, maxWidth: 120),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.06),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            height: 1.0,
          ),
        ),
      ),
    );

    if (onTap == null) return pill;

    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: pill,
    );
  }
}
