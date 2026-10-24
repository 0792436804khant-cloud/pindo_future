import 'dart:ui';
import 'package:flutter/material.dart';

/// Reusable Glassmorphism Container with blur, semi-transparent indigo/white
/// frosted glass background, rounded corners, and subtle white borders.
class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final double blurSigma;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Clip clipBehavior;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(20)),
    this.blurSigma = 16.0,
    this.gradient,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 1.2,
    this.boxShadow,
    this.padding,
    this.margin,
    this.clipBehavior = Clip.antiAlias,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? Colors.white.withValues(alpha: 0.22);
    final effectiveGradient = gradient ??
        LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withValues(alpha: 0.12),
            const Color(0xFF1E1B4B).withValues(alpha: 0.65), // Cosmic Indigo
            const Color(0xFF0F172A).withValues(alpha: 0.85), // Deep Navy Slate
          ],
          stops: const [0.0, 0.45, 1.0],
        );

    final effectiveShadow = boxShadow ??
        [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.18), // Subtle Indigo aura
            blurRadius: 24,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.42),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ];

    Widget current = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        gradient: backgroundColor == null ? effectiveGradient : null,
        borderRadius: borderRadius,
        border: Border.all(
          color: effectiveBorderColor,
          width: borderWidth,
        ),
        boxShadow: effectiveShadow,
      ),
      child: child,
    );

    if (blurSigma > 0) {
      current = ClipRRect(
        borderRadius: borderRadius,
        clipBehavior: clipBehavior,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: current,
        ),
      );
    }

    if (margin != null) {
      current = Padding(padding: margin!, child: current);
    }

    return current;
  }
}

/// Interactive button wrapper providing smooth micro-interaction feedback
/// by scaling down slightly on press/tap.
class GlassmorphicScaleButton extends StatefulWidget {
  final Widget? child;
  final Widget Function(BuildContext context, bool isPressed, bool isHovered)? builder;
  final VoidCallback? onPressed;
  final String? tooltip;
  final double pressedScale;
  final double hoverScale;
  final Duration duration;
  final Curve curve;

  const GlassmorphicScaleButton({
    super.key,
    this.child,
    this.builder,
    this.onPressed,
    this.tooltip,
    this.pressedScale = 0.90,
    this.hoverScale = 1.04,
    this.duration = const Duration(milliseconds: 110),
    this.curve = Curves.easeOutCubic,
  }) : assert(child != null || builder != null, 'Either child or builder must be provided.');

  @override
  State<GlassmorphicScaleButton> createState() => _GlassmorphicScaleButtonState();
}

class _GlassmorphicScaleButtonState extends State<GlassmorphicScaleButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (widget.onPressed == null) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final scale = _isPressed
        ? widget.pressedScale
        : (_isHovered && widget.onPressed != null ? widget.hoverScale : 1.0);

    Widget content = AnimatedScale(
      scale: scale,
      duration: widget.duration,
      curve: widget.curve,
      child: widget.builder != null
          ? widget.builder!(context, _isPressed, _isHovered)
          : widget.child!,
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      content = Tooltip(
        message: widget.tooltip!,
        waitDuration: const Duration(milliseconds: 400),
        child: content,
      );
    }

    return MouseRegion(
      cursor: widget.onPressed != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) {
        if (mounted && widget.onPressed != null) setState(() => _isHovered = true);
      },
      onExit: (_) {
        if (mounted) setState(() => _isHovered = false);
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.onPressed,
        child: content,
      ),
    );
  }
}

/// Ultra-modern Futuristic Capsule Button with neon glow, gradient border,
/// glassmorphic backdrop, and tactile micro-interaction press scaling.
/// Replaces classic flat or rectangular Material buttons.
class FuturisticCapsuleButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final IconData? trailingIcon;
  final VoidCallback? onPressed;
  final Color accentColor;
  final Color secondaryColor;
  final bool isPrimary;
  final bool isLoading;
  final double height;
  final double fontSize;
  final EdgeInsetsGeometry? padding;
  final bool isFullWidth;
  final bool withGlow;

  const FuturisticCapsuleButton({
    super.key,
    required this.text,
    this.icon,
    this.trailingIcon,
    this.onPressed,
    this.accentColor = const Color(0xFF00E5FF), // Bright Cyan
    this.secondaryColor = const Color(0xFF7C4DFF), // Electric Purple
    this.isPrimary = true,
    this.isLoading = false,
    this.height = 48.0,
    this.fontSize = 14.5,
    this.padding,
    this.isFullWidth = false,
    this.withGlow = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectivePadding = padding ?? const EdgeInsets.symmetric(horizontal: 22, vertical: 12);

    return GlassmorphicScaleButton(
      onPressed: isLoading ? null : onPressed,
      child: Container(
        height: height,
        width: isFullWidth ? double.infinity : null,
        padding: effectivePadding,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(height / 2),
          gradient: isPrimary
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor.withValues(alpha: 0.95),
                    secondaryColor.withValues(alpha: 0.90),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF311B92).withValues(alpha: 0.40),
                    const Color(0xFF7C4DFF).withValues(alpha: 0.20),
                    Colors.black.withValues(alpha: 0.50),
                  ],
                ),
          border: Border.all(
            color: isPrimary
                ? Colors.white.withValues(alpha: 0.35)
                : accentColor.withValues(alpha: 0.45),
            width: 1.4,
          ),
          boxShadow: withGlow
              ? [
                  BoxShadow(
                    color: (isPrimary ? accentColor : secondaryColor).withValues(alpha: 0.35),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: isFullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading) ...[
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isPrimary ? Colors.black87 : accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ] else if (icon != null) ...[
              Icon(
                icon,
                color: isPrimary ? Colors.black87 : accentColor,
                size: fontSize + 4,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                color: isPrimary ? Colors.black87 : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
                letterSpacing: 0.4,
              ),
            ),
            if (trailingIcon != null && !isLoading) ...[
              const SizedBox(width: 8),
              Icon(
                trailingIcon,
                color: isPrimary ? Colors.black87 : accentColor,
                size: fontSize + 2,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Futuristic Pill Badge with glowing aura
class FuturisticGlowBadge extends StatelessWidget {
  final String label;
  final IconData? icon;
  final Color color;

  const FuturisticGlowBadge({
    super.key,
    required this.label,
    this.icon,
    this.color = const Color(0xFF00E5FF),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.38), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.20),
            blurRadius: 10,
            spreadRadius: 0.5,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

