import 'package:flutter/material.dart';

/// Official Brand Logo Widget for Pindo Future Educational Platform
class PindoBrandLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool isVertical;
  final Color textColor;
  final bool withGlow;
  final double fontSize;
  final String? heroTag;

  const PindoBrandLogo({
    super.key,
    this.size = 40,
    this.showText = true,
    this.isVertical = false,
    this.textColor = Colors.white,
    this.withGlow = true,
    this.fontSize = 20,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    Widget iconWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.23),
        boxShadow: withGlow
            ? [
                BoxShadow(
                  color: const Color(0xFF2DD4BF).withValues(alpha: 0.28),
                  blurRadius: size * 0.45,
                  spreadRadius: 1,
                  offset: const Offset(0, 2),
                ),
                BoxShadow(
                  color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                  blurRadius: size * 0.55,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.23),
        child: Image.asset(
          'assets/images/pindo_logo_badge.png',
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Elegant fallback if asset bundle is still reloading
            return Container(
              color: const Color(0xFF0F172A),
              child: Center(
                child: Text(
                  'P',
                  style: TextStyle(
                    color: const Color(0xFF2DD4BF),
                    fontSize: size * 0.55,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    if (heroTag != null) {
      iconWidget = Hero(tag: heroTag!, child: iconWidget);
    }

    if (!showText) {
      return iconWidget;
    }

    final typography = RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.3,
        ),
        children: [
          TextSpan(
            text: 'Pindo ',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const TextSpan(
            text: 'Future',
            style: TextStyle(
              color: Color(0xFF2DD4BF), // Official Glowing Cyan
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    if (isVertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          iconWidget,
          SizedBox(height: size * 0.2),
          typography,
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        iconWidget,
        SizedBox(width: size * 0.28),
        typography,
      ],
    );
  }
}
