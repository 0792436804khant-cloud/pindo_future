import 'package:flutter/material.dart';
import '../../domain/entities/classroom_stage_mode.dart';

class ClassroomStageSwitcher extends StatelessWidget {
  final ClassroomStageMode currentMode;
  final ValueChanged<ClassroomStageMode> onModeChanged;
  final bool isScreenShareActive;

  const ClassroomStageSwitcher({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
    this.isScreenShareActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildStagePill(
            mode: ClassroomStageMode.camera,
            icon: Icons.videocam,
            label: 'Webcam',
          ),
          const SizedBox(width: 4),
          _buildStagePill(
            mode: ClassroomStageMode.whiteboard,
            icon: Icons.draw,
            label: 'Whiteboard',
          ),
          const SizedBox(width: 4),
          _buildStagePill(
            mode: ClassroomStageMode.screenShare,
            icon: Icons.screen_share,
            label: 'Screen Share',
            isSpecialActive: isScreenShareActive,
          ),
        ],
      ),
    );
  }

  Widget _buildStagePill({
    required ClassroomStageMode mode,
    required IconData icon,
    required String label,
    bool isSpecialActive = false,
  }) {
    final isSelected = currentMode == mode;

    return InkWell(
      onTap: () => onModeChanged(mode),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0D9488)
              : (isSpecialActive ? const Color(0xFF2563EB).withValues(alpha: 0.2) : Colors.transparent),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF0D9488)
                : (isSpecialActive ? const Color(0xFF3B82F6) : Colors.transparent),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? Colors.white
                  : (isSpecialActive ? const Color(0xFF60A5FA) : Colors.white70),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected
                    ? Colors.white
                    : (isSpecialActive ? const Color(0xFF93C5FD) : Colors.white70),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
