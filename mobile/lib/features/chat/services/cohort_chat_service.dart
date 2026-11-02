import '../domain/entities/cohort_chat_message.dart';

class CohortSummary {
  final String cohortId;
  final String cohortName;
  final String subject;
  final String academicLevel;
  final String? lastMessageText;
  final String? lastMessageTime;
  final String? lastMessageSender;
  final int unreadCount;
  final int membersCount;
  final bool isLiveNow;

  const CohortSummary({
    required this.cohortId,
    required this.cohortName,
    required this.subject,
    required this.academicLevel,
    this.lastMessageText,
    this.lastMessageTime,
    this.lastMessageSender,
    this.unreadCount = 0,
    this.membersCount = 42,
    this.isLiveNow = false,
  });
}

class CohortChatService {
  static final CohortChatService _instance = CohortChatService._internal();
  factory CohortChatService() => _instance;

  CohortChatService._internal() {
    _initPreSeededMessages();
  }

  final Map<String, List<CohortChatMessage>> _messagesByCohort = {};

  void _initPreSeededMessages() {
    const mathCohortId = 'COHORT_BAC27_MATH';
    const mathCohortName = 'فوج النخبة للبكالوريا — الرياضيات (شعبة علوم تجريبية ورياضي)';

    _messagesByCohort[mathCohortId] = [
      CohortChatMessage(
        id: 'm1',
        cohortId: mathCohortId,
        cohortName: mathCohortName,
        senderId: 'TCH_01',
        senderName: 'الأستاذ محمد أمين بن عيسى',
        senderRole: 'teacher',
        text: 'مرحباً بجميع طلبة فوج النخبة للبكالوريا 2026 🎯 تم إنشاء وتفعيل غرفة المحادثة الرسمية لفوجنا. هنا نتبادل الأسئلة، الملخصات، وروابط الحصص التفاعلية المباشرة.',
        isPinned: true,
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
        reactions: const ['❤️', '🔥', '👏'],
      ),
      CohortChatMessage(
        id: 'm2',
        cohortId: mathCohortId,
        cohortName: mathCohortName,
        senderId: 'TCH_01',
        senderName: 'الأستاذ محمد أمين بن عيسى',
        senderRole: 'teacher',
        text: 'إليكم السلسلة النموذجية رقم 03 في المتتاليات العددية والبرهان بالتراجع مع سلم التنقيط المعتمد:',
        messageType: 'file',
        fileName: 'سلسلة_تمارين_المتتاليات_والدوال_العددية_BAC26.pdf',
        fileSizeBytes: 2450000,
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        reactions: const ['👍', '❤️'],
      ),
      CohortChatMessage(
        id: 'm3',
        cohortId: mathCohortId,
        cohortName: mathCohortName,
        senderId: 'STU_01',
        senderName: 'كريم بلقاسم',
        senderRole: 'student',
        text: 'السلام عليكم يا أستاذ، شكراً جزيلاً على السلسلة! بالنسبة للتمرين الثاني السؤال 3 (دراسة اتجاه التغير)، هل الأفضل دراسة إشارة الفرق أم بالتراجع؟',
        timestamp: DateTime.now().subtract(const Duration(hours: 2, minutes: 30)),
      ),
      CohortChatMessage(
        id: 'm4',
        cohortId: mathCohortId,
        cohortName: mathCohortName,
        senderId: 'TCH_01',
        senderName: 'الأستاذ محمد أمين بن عيسى',
        senderRole: 'teacher',
        text: 'وعليكم السلام يا كريم. كلاهما صحيح، لكن دراسة إشارة الفرق U(n+1) - U(n) أسرع وأضمن للوقت، ونستعين فيها بحصر الدالة المرافقة. وسنشرحها بالتفصيل في لايف اليوم إن شاء الله 📐',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        reactions: const ['🔥', '👍'],
      ),
      CohortChatMessage(
        id: 'm5',
        cohortId: mathCohortId,
        cohortName: mathCohortName,
        senderId: 'TCH_01',
        senderName: 'الأستاذ محمد أمين بن عيسى',
        senderRole: 'teacher',
        text: 'رابط القاعة التفاعلية المباشرة لحصة اليوم المخصصة لحل المسائل الرسمية:',
        messageType: 'link',
        linkUrl: 'https://pindofuture.com/live/SES_MATH_BAC_01',
        linkTitle: 'غرفة البث المباشر: حل المسائل النموذجية والامتحانات الرسمية',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        reactions: const ['🔥', '❤️'],
      ),
      CohortChatMessage(
        id: 'm6',
        cohortId: mathCohortId,
        cohortName: mathCohortName,
        senderId: 'STU_02',
        senderName: 'مريم بن زينة',
        senderRole: 'student',
        text: 'جاهزون للحصة يا أستاذ ومعنا كراس التمارين جاهز 🌟',
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        reactions: const ['👏'],
      ),
    ];

    // Physics Cohort
    const physCohortId = 'SES_CURIE_01';
    const physCohortName = 'فوج التفوق في العلوم الفيزيائية والكيمياء';
    _messagesByCohort[physCohortId] = [
      CohortChatMessage(
        id: 'p1',
        cohortId: physCohortId,
        cohortName: physCohortName,
        senderId: 'TCH_02',
        senderName: 'الأستاذة كريمة بلقاسم',
        senderRole: 'teacher',
        text: 'أهلاً بكم في غرفة محادثة فوج الفيزياء. موعد حصتنا القادمة يوم الأربعاء على 17:30.',
        isPinned: true,
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        reactions: const ['👍'],
      ),
      CohortChatMessage(
        id: 'p2',
        cohortId: physCohortId,
        cohortName: physCohortName,
        senderId: 'TCH_02',
        senderName: 'الأستاذة كريمة بلقاسم',
        senderRole: 'teacher',
        text: 'تم رفع ملخص قوانين نيوتن وحركة الكواكب والأقمار الاصطناعية في مكتبة الفوج.',
        messageType: 'file',
        fileName: 'ملخص_الميكانيكا_وقوانين_نيوتن_2026.pdf',
        fileSizeBytes: 1850000,
        timestamp: DateTime.now().subtract(const Duration(hours: 3)),
        reactions: const ['❤️'],
      ),
    ];

    // 1AS Cohort
    const sciCohortId = 'COHORT_1AS_SCI';
    const sciCohortName = 'الفوج النموذجي — أولى ثانوي جذع مشترك علوم';
    _messagesByCohort[sciCohortId] = [
      CohortChatMessage(
        id: 's1',
        cohortId: sciCohortId,
        cohortName: sciCohortName,
        senderId: 'TCH_01',
        senderName: 'الأستاذ محمد أمين بن عيسى',
        senderRole: 'teacher',
        text: 'أعزائي طلبة السنة أولى ثانوي، مرحباً بكم في فوج الرياضيات. استعدوا للفرض الأول الأسبوع القادم.',
        timestamp: DateTime.now().subtract(const Duration(hours: 6)),
        reactions: const ['👍'],
      ),
    ];
  }

  String _normalizeCohortId(String id) {
    if (id == '1' || id == 'COHORT_BAC27_MATH' || id.contains('BAC')) return 'COHORT_BAC27_MATH';
    if (id == '2' || id == 'COHORT_1AS_SCI') return 'COHORT_1AS_SCI';
    if (id.contains('CURIE') || id.contains('PHYS')) return 'SES_CURIE_01';
    return id;
  }

  List<CohortChatMessage> getMessages(String cohortId, {String? cohortName}) {
    final key = _normalizeCohortId(cohortId);
    if (!_messagesByCohort.containsKey(key)) {
      _messagesByCohort[key] = [
        CohortChatMessage(
          id: 'init_${DateTime.now().millisecondsSinceEpoch}',
          cohortId: key,
          cohortName: cohortName ?? 'محادثة الفوج',
          senderId: 'SYS',
          senderName: 'منظومة بيندو الذكية',
          senderRole: 'admin',
          text: 'تم إنشاء الغرفة بنجاح. أي تلميذ ينضم لهذا الفوج يرتبط تلقائياً بهذه المحادثة المفتوحة والحصص المباشرة.',
          timestamp: DateTime.now(),
        ),
      ];
    }
    return List.unmodifiable(_messagesByCohort[key]!);
  }

  void sendMessage(CohortChatMessage message) {
    final key = _normalizeCohortId(message.cohortId);
    if (!_messagesByCohort.containsKey(key)) {
      _messagesByCohort[key] = [];
    }
    _messagesByCohort[key]!.add(message);
  }

  void addReaction(String cohortId, String messageId, String emoji) {
    final key = _normalizeCohortId(cohortId);
    final list = _messagesByCohort[key];
    if (list == null) return;

    final index = list.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final msg = list[index];
      final current = List<String>.from(msg.reactions);
      if (current.contains(emoji)) {
        current.remove(emoji);
      } else {
        current.add(emoji);
      }
      list[index] = msg.copyWith(reactions: current);
    }
  }

  void togglePin(String cohortId, String messageId) {
    final key = _normalizeCohortId(cohortId);
    final list = _messagesByCohort[key];
    if (list == null) return;

    final index = list.indexWhere((m) => m.id == messageId);
    if (index != -1) {
      final msg = list[index];
      list[index] = msg.copyWith(isPinned: !msg.isPinned);
    }
  }

  int getUnreadCount(String cohortId) {
    final key = _normalizeCohortId(cohortId);
    if (key == 'COHORT_BAC27_MATH') return 3;
    if (key == 'SES_CURIE_01') return 1;
    return 0;
  }

  int getTotalUnreadCount() {
    return 4; // Sum of active unread messages
  }

  List<CohortSummary> getAllCohortSummaries() {
    return const [
      CohortSummary(
        cohortId: 'COHORT_BAC27_MATH',
        cohortName: 'فوج النخبة للبكالوريا — الرياضيات (شعبة علوم تجريبية ورياضي)',
        subject: 'الرياضيات',
        academicLevel: 'ثالثة ثانوي',
        lastMessageText: 'جاهزون للحصة يا أستاذ ومعنا كراس التمارين جاهز 🌟',
        lastMessageTime: 'منذ 20 د',
        lastMessageSender: 'مريم بن زينة',
        unreadCount: 3,
        membersCount: 42,
        isLiveNow: true,
      ),
      CohortSummary(
        cohortId: 'SES_CURIE_01',
        cohortName: 'فوج التفوق في العلوم الفيزيائية والكيمياء',
        subject: 'العلوم الفيزيائية',
        academicLevel: 'ثالثة ثانوي',
        lastMessageText: 'تم رفع ملخص قوانين نيوتن وحركة الكواكب والأقمار الاصطناعية...',
        lastMessageTime: 'منذ 3 ساعات',
        lastMessageSender: 'الأستاذة كريمة بلقاسم',
        unreadCount: 1,
        membersCount: 38,
        isLiveNow: false,
      ),
      CohortSummary(
        cohortId: 'COHORT_1AS_SCI',
        cohortName: 'الفوج النموذجي — أولى ثانوي جذع مشترك علوم',
        subject: 'الرياضيات',
        academicLevel: 'أولى ثانوي',
        lastMessageText: 'أعزائي طلبة السنة أولى ثانوي، مرحباً بكم في فوج الرياضيات...',
        lastMessageTime: 'منذ 6 ساعات',
        lastMessageSender: 'الأستاذ محمد أمين بن عيسى',
        unreadCount: 0,
        membersCount: 23,
        isLiveNow: false,
      ),
    ];
  }
}
