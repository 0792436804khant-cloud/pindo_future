import 'package:flutter/material.dart';
import '../controllers/classroom_controller.dart';

class RaisedHandsDialog extends StatelessWidget {
  final ClassroomController controller;

  const RaisedHandsDialog({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final raisedHands = controller.raisedHands;

    return Dialog(
      backgroundColor: const Color(0xFF1E293B),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 380,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.front_hand, color: Color(0xFFF59E0B), size: 24),
                const SizedBox(width: 10),
                const Text(
                  'Raised Hands Queue',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white60, size: 20),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '${raisedHands.length} student(s) requested speaking permission',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
            const SizedBox(height: 16),
            const Divider(color: Color(0xFF334155), height: 1),
            const SizedBox(height: 12),

            // Queue List
            if (raisedHands.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.check_circle_outline, color: Color(0xFF10B981), size: 36),
                      SizedBox(height: 8),
                      Text(
                        'No raised hands in the queue',
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 280),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: raisedHands.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final request = raisedHands[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F172A),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                            child: Text(
                              request.participantName.isNotEmpty ? request.participantName[0].toUpperCase() : '?',
                              style: const TextStyle(color: Color(0xFFF59E0B), fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  request.participantName,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  'Requested at ${request.timestamp.hour.toString().padLeft(2, '0')}:${request.timestamp.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              controller.lowerHand(request.participantIdentity);
                            },
                            icon: const Icon(Icons.arrow_downward, size: 14, color: Colors.white70),
                            label: const Text('Dismiss', style: TextStyle(color: Colors.white70, fontSize: 11)),
                            style: TextButton.styleFrom(
                              backgroundColor: const Color(0xFF334155),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
