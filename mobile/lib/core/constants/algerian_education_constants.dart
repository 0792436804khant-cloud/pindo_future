/// Constants representing the Algerian National Education System
/// Covering 58 Wilayas, Academic Cycles, Secondary Streams (الشعب), and Subjects.
class AlgerianEducationConstants {
  /// The 58 Algerian Wilayas
  static const Map<int, String> wilayas = {
    1: '01 - أدرار (Adrar)',
    2: '02 - الشلف (Chlef)',
    3: '03 - الأغواط (Laghouat)',
    4: '04 - أم البواقي (Oum El Bouaghi)',
    5: '05 - باتنة (Batna)',
    6: '06 - بجاية (Béjaïa)',
    7: '07 - بسكرة (Biskra)',
    8: '08 - بشار (Béchar)',
    9: '09 - البليدة (Blida)',
    10: '10 - البويرة (Bouira)',
    11: '11 - تمنراست (Tamanrasset)',
    12: '12 - تبسة (Tébessa)',
    13: '13 - تلمسان (Tlemcen)',
    14: '14 - تيارت (Tiaret)',
    15: '15 - تيزي وزو (Tizi Ouzou)',
    16: '16 - الجزائر العاصمة (Alger)',
    17: '17 - الجلفة (Djelfa)',
    18: '18 - جيجل (Jijel)',
    19: '19 - سطيف (Sétif)',
    20: '20 - سعيدة (Saïda)',
    21: '21 - سكيكدة (Skikda)',
    22: '22 - سيدي بلعباس (Sidi Bel Abbès)',
    23: '23 - عنابة (Annaba)',
    24: '24 - قالمة (Guelma)',
    25: '25 - قسنطينة (Constantine)',
    26: '26 - المدية (Médéa)',
    27: '27 - مستغانم (Mostaganem)',
    28: '28 - المسيلة (M\'Sila)',
    29: '29 - معسكر (Mascara)',
    30: '30 - ورقلة (Ouargla)',
    31: '31 - وهران (Oran)',
    32: '32 - البيض (El Bayadh)',
    33: '33 - إليزي (Illizi)',
    34: '34 - برج بوعريريج (Bordj Bou Arréridj)',
    35: '35 - بومرداس (Boumerdès)',
    36: '36 - الطارف (El Tarf)',
    37: '37 - تندوف (Tindouf)',
    38: '38 - تسمسيلت (Tissemsilt)',
    39: '39 - الوادي (El Oued)',
    40: '40 - خنشلة (Khenchela)',
    41: '41 - سوق أهراس (Souk Ahras)',
    42: '42 - تيبازة (Tipaza)',
    43: '43 - ميلة (Mila)',
    44: '44 - عين الدفلى (Aïn Defla)',
    45: '45 - النعامة (Naâma)',
    46: '46 - عين تموشنت (Aïn Témouchent)',
    47: '47 - غرداية (Ghardaïa)',
    48: '48 - غليزان (Relizane)',
    49: '49 - تيميمون (Timimoun)',
    50: '50 - برج باجي مختار (Bordj Badji Mokhtar)',
    51: '51 - أولاد جلال (Ouled Djellal)',
    52: '52 - بني عباس (Béni Abbès)',
    53: '53 - عين صالح (In Salah)',
    54: '54 - عين قزام (In Guezzam)',
    55: '55 - تقرت (Touggourt)',
    56: '56 - جانت (Djanet)',
    57: '57 - المغير (El M\'Ghair)',
    58: '58 - المنيعة (El Meniaa)',
  };

  /// Full Academic Levels (All Algerian Educational Years)
  static const List<String> academicLevels = [
    '3AS BAC (السنة الثالثة ثانوي - بكالوريا)',
    '2AS (السنة الثانية ثانوي)',
    '1AS (السنة الأولى ثانوي)',
    '4AM BEM (السنة الرابعة متوسط - شهادة التعليم المتوسط)',
    '3AM (السنة الثالثة متوسط)',
    '2AM (السنة الثانية متوسط)',
    '1AM (السنة الأولى متوسط)',
    '5AP (السنة الخامسة ابتدائي)',
    '4AP (السنة الرابعة ابتدائي)',
    '3AP (السنة الثالثة ابتدائي)',
    '2AP (السنة الثانية ابتدائي)',
    '1AP (السنة الأولى ابتدائي)',
    'L1 (السنة الأولى ليسانس)',
    'L2 (السنة الثانية ليسانس)',
    'L3 (السنة الثالثة ليسانس)',
    'Master / Engineer (ماستر وهندسة)',
  ];

  /// Concise Arabic cohort year labels paired with registration year codes
  static const Map<String, String> yearCodeToCohortLabel = {
    '1AP': 'أولى ابتدائي (1AP)',
    '2AP': 'ثانية ابتدائي (2AP)',
    '3AP': 'ثالثة ابتدائي (3AP)',
    '4AP': 'رابعة ابتدائي (4AP)',
    '5AP': 'خامسة ابتدائي (5AP)',
    '1AM': 'أولى متوسط (1AM)',
    '2AM': 'ثانية متوسط (2AM)',
    '3AM': 'ثالثة متوسط (3AM)',
    '4AM (BEM)': 'رابعة متوسط (BEM)',
    '1AS': 'أولى ثانوي (1AS)',
    '2AS': 'ثانية ثانوي (2AS)',
    '3AS (BAC)': 'ثالثة ثانوي (BAC)',
    'L1': 'أولى جامعي ليسانس (L1)',
    'L2': 'ثانية جامعي ليسانس (L2)',
    'L3': 'ثالثة جامعي ليسانس (L3)',
    'Master / Engineer': 'ماستر / هندسة (Master)',
    // Alternate labels from TeacherProfileEditorModal
    '5th Year Primary (5AP)': 'خامسة ابتدائي (5AP)',
    '4th Middle School (BEM)': 'رابعة متوسط (BEM)',
    '1st Year Secondary (1AS)': 'أولى ثانوي (1AS)',
    '2nd Year Secondary (2AS)': 'ثانية ثانوي (2AS)',
    '3rd Year Secondary (BAC)': 'ثالثة ثانوي (BAC)',
    'License & University (L1-L3)': 'التعليم الجامعي (L1-L3)',
  };

  /// All cohort level options (in clean Arabic order)
  static const List<String> allCohortYearLabels = [
    'ثالثة ثانوي (BAC)',
    'ثانية ثانوي (2AS)',
    'أولى ثانوي (1AS)',
    'رابعة متوسط (BEM)',
    'ثالثة متوسط (3AM)',
    'ثانية متوسط (2AM)',
    'أولى متوسط (1AM)',
    'خامسة ابتدائي (5AP)',
    'رابعة ابتدائي (4AP)',
    'ثالثة ابتدائي (3AP)',
    'ثانية ابتدائي (2AP)',
    'أولى ابتدائي (1AP)',
    'أولى جامعي ليسانس (L1)',
    'ثانية جامعي ليسانس (L2)',
    'ثالثة جامعي ليسانس (L3)',
    'ماستر / هندسة (Master)',
  ];

  /// Secondary Education Academic Streams (شعب البكالوريا)
  static const List<String> secondaryStreams = [
    'علوم تجريبية (Sciences Expérimentales)',
    'رياضيات (Mathématiques)',
    'تقني رياضي (Technique Mathématique)',
    'تسيير واقتصاد (Gestion et Économie)',
    'آداب وفلسفة (Lettres et Philosophie)',
    'لغات أجنبية (Langues Étrangères)',
  ];

  /// Full bilingual Academic Subjects list
  static const List<String> subjects = [
    'الرياضيات (Mathématiques)',
    'العلوم الفيزيائية (Physique-Chimie)',
    'علوم الطبيعة والحياة (Sciences de la Nature et de la Vie)',
    'اللغة العربية وآدابها (Langue Arabe)',
    'التاريخ والجغرافيا - الاجتماعيات (Histoire-Géographie)',
    'العلوم الإسلامية / التربية الإسلامية (Sciences Islamiques)',
    'الفلسفة (Philosophie)',
    'اللغة الفرنسية (Français)',
    'اللغة الإنجليزية (Anglais)',
    'الإعلام الآلي / المعلوماتية (Informatique)',
    'التربية المدنية (Éducation Civique)',
    'التربية العلمية والتكنولوجية (Sciences & Technologie)',
    'الاقتصاد والمناجمنت (Économie & Management)',
    'القانون (Droit)',
    'التسيير المحاسبي والمالي (Comptabilité & Finance)',
    'الهندسة المدنية (Génie Civil)',
    'الهندسة الميكانيكية (Génie Mécanique)',
    'الهندسة الكهربائية (Génie Électrique)',
    'هندسة الطرائق (Génie des Procédés)',
    'اللغة الأمازيغية (Tamazight)',
    'اللغة الإسبانية / الألمانية / الإيطالية (3ème Langue)',
  ];

  /// Complete Arabic subject names used in Cohort Creation & Teacher Profiles
  static const List<String> arabicSubjects = [
    'الرياضيات',
    'الفيزياء والكيمياء',
    'العلوم الطبيعية',
    'اللغة العربية',
    'التاريخ والجغرافيا (الاجتماعيات)',
    'العلوم الإسلامية / التربية الإسلامية',
    'الفلسفة',
    'اللغة الفرنسية',
    'اللغة الإنجليزية',
    'الإعلام الآلي',
    'التربية المدنية',
    'التربية العلمية والتكنولوجية',
    'التسيير المحاسبي والمالي',
    'الاقتصاد والمناجمنت',
    'القانون',
    'الهندسة المدنية',
    'الهندسة الميكانيكية',
    'الهندسة الكهربائية',
    'هندسة الطرائق',
    'اللغة الأمازيغية',
    'اللغة الإسبانية / الألمانية / الإيطالية',
  ];

  /// Maps teacher's selected registration/profile years to canonical cohort dropdown labels.
  /// Returns ONLY matching years if [teachingYears] is non-empty.
  static List<String> resolveTeacherCohortYears(List<String> teachingYears) {
    if (teachingYears.isEmpty) {
      return List<String>.from(allCohortYearLabels);
    }

    final resolved = <String>[];
    for (final raw in teachingYears) {
      final cleaned = raw.trim();
      if (cleaned.isEmpty) continue;

      if (yearCodeToCohortLabel.containsKey(cleaned)) {
        final label = yearCodeToCohortLabel[cleaned]!;
        if (!resolved.contains(label)) resolved.add(label);
        continue;
      }

      // Partial code match (e.g. "3AS", "BEM", "4AM", "L1", "ثالثة ثانوي")
      final matched = allCohortYearLabels.where((lbl) =>
          lbl.toLowerCase().contains(cleaned.toLowerCase()) ||
          cleaned.toLowerCase().contains(lbl.split('(').first.trim().toLowerCase()));
      if (matched.isNotEmpty) {
        for (final m in matched) {
          if (!resolved.contains(m)) resolved.add(m);
        }
      } else if (!resolved.contains(cleaned)) {
        resolved.add(cleaned);
      }
    }

    return resolved.isEmpty ? List<String>.from(allCohortYearLabels) : resolved;
  }

  /// Resolves streams appropriate for a selected cohort year/level.
  static List<String> streamsForYearLabel(String yearLabel) {
    final lower = yearLabel.toLowerCase();
    if (lower.contains('ابتدائي') || lower.contains('ap')) {
      return const ['تعليم ابتدائي عام'];
    }
    if (lower.contains('متوسط') || lower.contains('am') || lower.contains('bem')) {
      return const ['تعليم متوسط عام'];
    }
    if (lower.contains('أولى ثانوي') || lower.contains('1as')) {
      return const [
        'جذع مشترك علوم وتكنولوجيا',
        'جذع مشترك آداب',
      ];
    }
    if (lower.contains('ليسانس') ||
        lower.contains('ماستر') ||
        lower.contains('l1') ||
        lower.contains('l2') ||
        lower.contains('l3') ||
        lower.contains('master') ||
        lower.contains('جامعي')) {
      return const [
        'تخصص جامعي (LMD)',
        'إعلام آلي ورياضيات',
        'علوم وتكنولوجيا / هندسة',
        'علوم طبيعية وطبية',
        'علوم اقتصادية وتجارية',
        'آداب ولغات وحقوق',
      ];
    }
    return const [
      'علوم تجريبية',
      'رياضيات',
      'تقني رياضي',
      'تسيير واقتصاد',
      'آداب وفلسفة',
      'لغات أجنبية',
    ];
  }

  /// Returns complete Arabic subjects tailored for a selected Algerian academic year.
  static List<String> subjectsForYearLabel(String yearLabel) {
    final lower = yearLabel.toLowerCase();
    if (lower.contains('ابتدائي') || lower.contains('ap')) {
      return const [
        'الرياضيات',
        'اللغة العربية',
        'اللغة الفرنسية',
        'اللغة الإنجليزية',
        'التربية العلمية والتكنولوجية',
        'التربية الإسلامية',
        'التاريخ والجغرافيا (الاجتماعيات)',
        'التربية المدنية',
        'اللغة الأمازيغية',
      ];
    }
    if (lower.contains('متوسط') || lower.contains('am') || lower.contains('bem')) {
      return const [
        'الرياضيات',
        'الفيزياء والكيمياء',
        'العلوم الطبيعية',
        'اللغة العربية',
        'التاريخ والجغرافيا (الاجتماعيات)',
        'التربية الإسلامية',
        'التربية المدنية',
        'اللغة الفرنسية',
        'اللغة الإنجليزية',
        'الإعلام الآلي',
        'اللغة الأمازيغية',
      ];
    }
    return List<String>.from(arabicSubjects);
  }

  static String getWilayaName(int? code) {
    if (code == null) return 'غير محدد';
    return wilayas[code] ?? 'ولاية $code';
  }
}
