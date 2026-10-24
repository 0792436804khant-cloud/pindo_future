import 'package:flutter/material.dart';

class CourseVisualHelper {
  static List<Color> getGradientForCategory(String? category) {
    final cat = (category ?? '').toLowerCase().trim();
    if (cat.contains('computer') || cat.contains('code') || cat.contains('tech') || cat.contains('software')) {
      return const [Color(0xFF1E3A8A), Color(0xFF2563EB)]; // Deep Blue
    } else if (cat.contains('math') || cat.contains('crypto') || cat.contains('algo')) {
      return const [Color(0xFF581C87), Color(0xFF7E22CE)]; // Royal Purple
    } else if (cat.contains('science') || cat.contains('physics') || cat.contains('bio')) {
      return const [Color(0xFF0F766E), Color(0xFF0D9488)]; // Teal
    } else if (cat.contains('business') || cat.contains('finance') || cat.contains('econ')) {
      return const [Color(0xFF9A3412), Color(0xFFEA580C)]; // Warm Orange/Amber
    } else if (cat.contains('art') || cat.contains('design') || cat.contains('media')) {
      return const [Color(0xFF9D174D), Color(0xFFDB2777)]; // Rose
    }
    return const [Color(0xFF312E81), Color(0xFF4F46E5)]; // Indigo
  }

  static IconData getIconForCategory(String? category) {
    final cat = (category ?? '').toLowerCase().trim();
    if (cat.contains('computer') || cat.contains('code') || cat.contains('tech') || cat.contains('software')) {
      return Icons.terminal_rounded;
    } else if (cat.contains('math') || cat.contains('crypto') || cat.contains('algo')) {
      return Icons.functions_rounded;
    } else if (cat.contains('science') || cat.contains('physics') || cat.contains('bio')) {
      return Icons.biotech_rounded;
    } else if (cat.contains('business') || cat.contains('finance') || cat.contains('econ')) {
      return Icons.trending_up_rounded;
    } else if (cat.contains('art') || cat.contains('design') || cat.contains('media')) {
      return Icons.palette_rounded;
    }
    return Icons.school_rounded;
  }
}
