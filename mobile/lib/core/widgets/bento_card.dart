import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

/// Modern Bento Box Card with:
/// 1. Asymmetric Hero or Compact Square/Rectangular presentation
/// 2. Interactive spring scale-down animation on press and hold
/// 3. Subtle rotating animated gradient border (glowing edge)
/// 4. Soft glowing aura (multi-layer box shadow) behind the icon
class BentoCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color accentColor;
  final Color secondaryAccent;
  final bool isHero;
  final String? badgeText;
  final Color? badgeColor;
  final Widget? extraContent;
  final Widget? trailing;
  final double? height;
  final BorderRadius borderRadius;
  final bool animateBorder;

  const BentoCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
    this.accentColor = const Color(0xFF00E5FF),
    this.secondaryAccent = const Color(0xFF7C4DFF),
    this.isHero = false,
    this.badgeText,
    this.badgeColor,
    this.extraContent,
    this.trailing,
    this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(22)),
    this.animateBorder = true,
  });

  @override
  State<BentoCard> createState() => _BentoCardState();
}

class _BentoCardState extends State<BentoCard>
    with TickerProviderStateMixin {
  late final AnimationController _scaleController;
  late final AnimationController _borderController;
  late final Animation<double> _scaleAnimation;

  bool _isHovered = false;

  @override
  void initState() {
    super.initState();

    // Spring scale controller
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      reverseDuration: const Duration(milliseconds: 320),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: Curves.easeInCubic,
        reverseCurve: Curves.elasticOut,
      ),
    );

    // Continuous subtle rotating neon border
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    );

    if (widget.animateBorder) {
      _borderController.repeat();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _borderController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) {
    _scaleController.forward();
  }

  void _handleTapUp(TapUpDetails _) {
    _scaleController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.onTap != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: widget.onTap != null ? _handleTapDown : null,
        onTapUp: widget.onTap != null ? _handleTapUp : null,
        onTapCancel: widget.onTap != null ? _handleTapCancel : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([_scaleAnimation, _borderController]),
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              alignment: Alignment.center,
              child: _buildCardBody(),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardBody() {
    final angle = _borderController.value * 2 * math.pi;

    // Outer container with animated glowing edge gradient border
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: widget.borderRadius,
        boxShadow: [
          // Ambient shadow
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
          // Dynamic accent aura
          BoxShadow(
            color: widget.accentColor.withValues(
              alpha: _isHovered ? 0.32 : 0.16,
            ),
            blurRadius: _isHovered ? 26 : 18,
            spreadRadius: _isHovered ? 1.5 : 0.5,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: widget.animateBorder
            ? SweepGradient(
                center: Alignment.center,
                startAngle: 0.0,
                endAngle: 2 * math.pi,
                transform: GradientRotation(angle),
                colors: [
                  widget.accentColor.withValues(alpha: 0.75),
                  widget.secondaryAccent.withValues(alpha: 0.40),
                  Colors.white.withValues(alpha: 0.15),
                  widget.accentColor.withValues(alpha: 0.10),
                  widget.secondaryAccent.withValues(alpha: 0.65),
                  widget.accentColor.withValues(alpha: 0.75),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  widget.accentColor.withValues(alpha: 0.45),
                  widget.secondaryAccent.withValues(alpha: 0.25),
                ],
              ),
      ),
      padding: const EdgeInsets.all(1.4), // 1.4px glowing edge border
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16.0, sigmaY: 16.0),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: widget.borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1E1B4B).withValues(alpha: 0.88), // Cosmic Deep Indigo
                  const Color(0xFF0F172A).withValues(alpha: 0.92), // Midnight Slate
                  Colors.black.withValues(alpha: 0.95),
                ],
                stops: const [0.0, 0.55, 1.0],
              ),
            ),
            padding: EdgeInsets.all(widget.isHero ? 20.0 : 16.0),
            child: widget.isHero ? _buildHeroContent() : _buildCompactContent(),
          ),
        ),
      ),
    );
  }

  // Large Asymmetric Hero Card Content
  Widget _buildHeroContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildGlowingIcon(size: 46, iconSize: 24),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.badgeText != null) ...[
                    _buildPillBadge(
                      widget.badgeText!,
                      widget.badgeColor ?? widget.accentColor,
                    ),
                    const SizedBox(height: 5),
                  ],
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
            if (widget.trailing != null)
              widget.trailing!
            else if (widget.onTap != null)
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.16),
                  ),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: widget.accentColor,
                  size: 18,
                ),
              ),
          ],
        ),
        if (widget.subtitle != null) ...[
          const SizedBox(height: 12),
          Text(
            widget.subtitle!,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
        if (widget.extraContent != null) ...[
          const SizedBox(height: 14),
          widget.extraContent!,
        ],
      ],
    );
  }

  // Compact Square/Bento Card Content
  Widget _buildCompactContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGlowingIcon(size: 40, iconSize: 20),
            if (widget.badgeText != null)
              _buildPillBadge(
                widget.badgeText!,
                widget.badgeColor ?? widget.accentColor,
              )
            else if (widget.onTap != null)
              Icon(
                Icons.arrow_outward_rounded,
                color: widget.accentColor.withValues(alpha: 0.7),
                size: 16,
              ),
          ],
        ),
        const SizedBox(height: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
                height: 1.25,
              ),
            ),
            if (widget.subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                widget.subtitle!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 11.5,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
        if (widget.extraContent != null) ...[
          const SizedBox(height: 8),
          widget.extraContent!,
        ],
      ],
    );
  }

  // Requirement 4: Soft glowing aura (multi-layer box shadow) behind the icons
  Widget _buildGlowingIcon({required double size, required double iconSize}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: widget.accentColor.withValues(alpha: 0.16),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.65),
          width: 1.5,
        ),
        boxShadow: [
          // Soft concentrated aura
          BoxShadow(
            color: widget.accentColor.withValues(alpha: 0.55),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 0),
          ),
          // Ambient wider aura
          BoxShadow(
            color: widget.secondaryAccent.withValues(alpha: 0.35),
            blurRadius: 28,
            spreadRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          widget.icon,
          color: Colors.white,
          size: iconSize,
        ),
      ),
    );
  }

  Widget _buildPillBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.50),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 8,
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// Standalone Glowing Icon with Aura (multi-layer box shadow)
class BentoIconAura extends StatelessWidget {
  final IconData icon;
  final Color color;
  final double size;
  final double? iconSize;
  final double padding;
  final BoxShape shape;

  const BentoIconAura({
    super.key,
    required this.icon,
    this.color = const Color(0xFF00E5FF),
    this.size = 22,
    this.iconSize,
    this.padding = 10,
    this.shape = BoxShape.circle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : BorderRadius.circular(14),
        color: color.withValues(alpha: 0.16),
        border: Border.all(
          color: color.withValues(alpha: 0.65),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.50),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 28,
            spreadRadius: 4,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: color,
        size: iconSize ?? size,
      ),
    );
  }
}
