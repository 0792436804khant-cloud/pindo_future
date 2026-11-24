import 'package:flutter/material.dart';
import '../../services/cohort_chat_service.dart';
import 'cohort_chat_room_modal.dart';

class CohortChatsHubModal extends StatefulWidget {
  final String currentUserName;
  final String currentUserRole; // 'teacher' or 'student'

  const CohortChatsHubModal({
    super.key,
    this.currentUserName = 'الأستاذ محمد أمين بن عيسى',
    this.currentUserRole = 'teacher',
  });

  static Future<void> show(
    BuildContext context, {
    String currentUserName = 'الأستاذ محمد أمين بن عيسى',
    String currentUserRole = 'teacher',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CohortChatsHubModal(
        currentUserName: currentUserName,
        currentUserRole: currentUserRole,
      ),
    );
  }

  @override
  State<CohortChatsHubModal> createState() => _CohortChatsHubModalState();
}

class _CohortChatsHubModalState extends State<CohortChatsHubModal> {
  final CohortChatService _chatService = CohortChatService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  static const Color _brightCyan = Color(0xFF00E5FF);
  static const Color _electricPurple = Color(0xFF7C4DFF);
  static const Color _deepIndigo = Color(0xFF311B92);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final summaries = _chatService.getAllCohortSummaries().where((c) {
      if (_searchQuery.isEmpty) return true;
      return c.cohortName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.subject.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: _brightCyan.withValues(alpha: 0.35), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.7),
            blurRadius: 30,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle
          const SizedBox(height: 10),
          Center(
            child: Container(
              width: 44,
              height: 4.5,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: _brightCyan.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(color: _brightCyan.withValues(alpha: 0.4)),
                  ),
                  child: const Icon(Icons.forum_rounded, color: _brightCyan, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'محادثات الأفواج والدردشة 💬',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'غرف المجموعات التفاعلية المرتبطة بكل فوج والحصص المباشرة',
                        style: TextStyle(color: Colors.white60, fontSize: 11.5),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Search Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white12),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'ابحث باسم الفوج أو المادة...',
                  hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                  prefixIcon: Icon(Icons.search_rounded, color: _brightCyan, size: 20),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Colors.white12, height: 1),

          // Cohort Chats List
          Expanded(
            child: summaries.isEmpty
                ? Center(
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'لم يتم العثور على أي محادثات مطابقة لـ «$_searchQuery»'
                          : 'لا توجد محادثات أفواج نشطة حالياً — انضم إلى فوج أو أنشئ فوجاً لتفعيل المحادثة.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white54, fontSize: 13),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: summaries.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final item = summaries[index];
                      return _buildCohortChatTile(item);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCohortChatTile(CohortSummary item) {
    return InkWell(
      onTap: () {
        CohortChatRoomModal.show(
          context,
          cohortId: item.cohortId,
          cohortName: item.cohortName,
          academicLevel: item.academicLevel,
          currentUserName: widget.currentUserName,
          currentUserRole: widget.currentUserRole,
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: item.unreadCount > 0 ? _brightCyan.withValues(alpha: 0.4) : Colors.white12,
            width: item.unreadCount > 0 ? 1.2 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                const CircleAvatar(
                  radius: 24,
                  backgroundColor: _deepIndigo,
                  child: Icon(Icons.groups_rounded, color: _brightCyan, size: 24),
                ),
                if (item.isLiveNow)
                  Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Color(0xFF10B981),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.sensors_rounded, size: 10, color: Colors.white),
                  ),
              ],
            ),
            const SizedBox(width: 14),

            // Cohort Info & Last message
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          item.cohortName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.lastMessageTime != null)
                        Text(
                          item.lastMessageTime!,
                          style: TextStyle(
                            color: item.unreadCount > 0 ? _brightCyan : Colors.white38,
                            fontSize: 11,
                            fontWeight: item.unreadCount > 0 ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: _electricPurple.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.subject,
                          style: const TextStyle(color: _electricPurple, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${item.membersCount} عضواً',
                        style: const TextStyle(color: Colors.white38, fontSize: 10.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.lastMessageText != null
                              ? '${item.lastMessageSender != null ? "${item.lastMessageSender}: " : ""}${item.lastMessageText}'
                              : 'انقر لفتح المحادثة ومشاركة الدروس والروابط',
                          style: TextStyle(
                            color: item.unreadCount > 0 ? Colors.white : Colors.white60,
                            fontSize: 12,
                            fontWeight: item.unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (item.unreadCount > 0)
                        Container(
                          margin: const EdgeInsets.only(right: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: const BoxDecoration(
                            color: _brightCyan,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${item.unreadCount}',
                            style: const TextStyle(color: Colors.black, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
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
