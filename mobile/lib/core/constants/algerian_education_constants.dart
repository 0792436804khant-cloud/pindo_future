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

  /// Academic Levels
  static const List<String> academicLevels = [
    '3AS BAC (السنة الثالثة ثانوي - بكالوريا)',
    '2AS (السنة الثانية ثانوي)',
    '1AS (السنة الأولى ثانوي)',
    '4AM BEM (السنة الرابعة متوسط - شهادة التعليم المتوسط)',
    '3AM (السنة الثالثة متوسط)',
    '2AM (السنة الثانية متوسط)',
    '1AM (السنة الأولى متوسط)',
    '5AP (السنة الخامسة ابتدائي)',
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

  /// Academic Subjects
  static const List<String> subjects = [
    'الرياضيات (Mathématiques)',
    'العلوم الفيزيائية (Physique-Chimie)',
    'علوم الطبيعة والحياة (Sciences de la Nature et de la Vie)',
    'اللغة العربية وآدابها (Langue Arabe)',
    'الفلسفة (Philosophie)',
    'اللغة الفرنسية (Français)',
    'اللغة الإنجليزية (Anglais)',
    'التاريخ والجغرافيا (Histoire-Géographie)',
    'العلوم الإسلامية (Sciences Islamiques)',
    'الاقتصاد والمناجمنت (Économie & Management)',
    'القانون (Droit)',
    'التسيير المحاسبي والمالي (Comptabilité & Finance)',
    'الهندسة المدنية (Génie Civil)',
    'الهندسة الميكانيكية (Génie Mécanique)',
    'الهندسة الكهربائية (Génie Électrique)',
    'هندسة الطرائق (Génie des Procédés)',
  ];

  static String getWilayaName(int? code) {
    if (code == null) return 'غير محدد';
    return wilayas[code] ?? 'ولاية $code';
  }
}
