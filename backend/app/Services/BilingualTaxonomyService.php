<?php

namespace App\Services;

class BilingualTaxonomyService
{
    /**
     * Complete Algerian 58 Wilayas mapping (Code => [Arabic, French]).
     */
    public const WILAYAS = [
        1 => ['Adrar', 'أدرار'],
        2 => ['Chlef', 'الشلف'],
        3 => ['Laghouat', 'الأغواط'],
        4 => ['Oum El Bouaghi', 'أم البواقي'],
        5 => ['Batna', 'باتنة'],
        6 => ['Béjaïa', 'بجاية'],
        7 => ['Biskra', 'بسكرة'],
        8 => ['Béchar', 'بشار'],
        9 => ['Blida', 'البليدة'],
        10 => ['Bouira', 'البويرة'],
        11 => ['Tamanrasset', 'تمنراست'],
        12 => ['Tébessa', 'تبسة'],
        13 => ['Tlemcen', 'تلمسان'],
        14 => ['Tiaret', 'تيارت'],
        15 => ['Tizi Ouzou', 'تيزي وزو'],
        16 => ['Alger', 'الجزائر العاصمة'],
        17 => ['Djelfa', 'الجلفة'],
        18 => ['Jijel', 'جيجل'],
        19 => ['Sétif', 'سطيف'],
        20 => ['Saïda', 'سعيدة'],
        21 => ['Skikda', 'سكيكدة'],
        22 => ['Sidi Bel Abbès', 'سيدي بلعباس'],
        23 => ['Annaba', 'عنابة'],
        24 => ['Guelma', 'قالمة'],
        25 => ['Constantine', 'قسنطينة'],
        26 => ['Médéa', 'المدية'],
        27 => ['Mostaganem', 'مستغانم'],
        28 => ['M\'Sila', 'المسيلة'],
        29 => ['Mascara', 'معسكر'],
        30 => ['Ouargla', 'ورقلة'],
        31 => ['Oran', 'وهران'],
        32 => ['El Bayadh', 'البيض'],
        33 => ['Illizi', 'إليزي'],
        34 => ['Bordj Bou Arréridj', 'برج بوعريريج'],
        35 => ['Boumerdès', 'بومرداس'],
        36 => ['El Tarf', 'الطارف'],
        37 => ['Tindouf', 'تندوف'],
        38 => ['Tissemsilt', 'تيسمسيلت'],
        39 => ['El Oued', 'الوادي'],
        40 => ['Khenchela', 'خنشلة'],
        41 => ['Souk Ahras', 'سوق أهراس'],
        42 => ['Tipaza', 'تيبازة'],
        43 => ['Mila', 'ميلة'],
        44 => ['Aïn Defla', 'عين الدفلى'],
        45 => ['Naâma', 'النعامة'],
        46 => ['Aïn Témouchent', 'عين تموشنت'],
        47 => ['Ghardaïa', 'غرداية'],
        48 => ['Relizane', 'غليزان'],
        49 => ['Timimoun', 'تيميمون'],
        50 => ['Bordj Badji Mokhtar', 'برج باجي مختار'],
        51 => ['Ouled Djellal', 'أولاد جلال'],
        52 => ['Béni Abbès', 'بني عباس'],
        53 => ['In Salah', 'عين صالح'],
        54 => ['In Guezzam', 'عين قزام'],
        55 => ['Touggourt', 'تقرت'],
        56 => ['Djanet', 'جانت'],
        57 => ['El M\'Ghair', 'المغير'],
        58 => ['El Meniaa', 'المنيعة'],
    ];

    /**
     * Academic Subjects Bilingual Synonyms.
     */
    public const SUBJECTS = [
        'mathematics' => ['الرياضيات', 'Mathématiques', 'Maths', 'رياضيات'],
        'physics' => ['العلوم الفيزيائية', 'Physique-Chimie', 'Physique', 'فيزياء'],
        'natural_sciences' => ['علوم الطبيعة والحياة', 'Sciences de la Vie et de la Terre', 'Sciences', 'علوم'],
        'arabic_literature' => ['اللغة العربية وآدابها', 'Langue Arabe', 'عربية', 'أدب عربي'],
        'french' => ['اللغة الفرنسية', 'Français', 'فرنسية'],
        'english' => ['اللغة الإنجليزية', 'Anglais', 'إنجليزية'],
        'philosophy' => ['الفلسفة', 'Philosophie', 'فلسفة'],
        'history_geography' => ['التاريخ والجغرافيا', 'Histoire-Géographie', 'اجتماعيات', 'تاريخ وجغرافيا'],
        'islamic_sciences' => ['العلوم الإسلامية', 'Sciences Islamiques', 'تربية إسلامية', 'علوم إسلامية'],
        'computer_science' => ['الإعلام الآلي', 'Informatique', 'معلوماتية'],
        'economics_management' => ['الاقتصاد والمناجمنت', 'Économie et Gestion', 'تسيير واقتصاد'],
        'civil_engineering' => ['الهندسة المدنية', 'Génie Civil', 'مدنية'],
        'mechanical_engineering' => ['الهندسة الميكانيكية', 'Génie Mécanique', 'ميكانيك'],
        'electrical_engineering' => ['الهندسة الكهربائية', 'Génie Électrique', 'كهرباء'],
    ];

    /**
     * Resolve Wilaya Code or Name across both Arabic and French.
     */
    public static function resolveWilaya(string|int $query): ?array
    {
        if (is_numeric($query) && isset(self::WILAYAS[(int)$query])) {
            return [
                'code' => (int)$query,
                'french' => self::WILAYAS[(int)$query][0],
                'arabic' => self::WILAYAS[(int)$query][1],
            ];
        }

        $cleanQuery = mb_strtolower(trim((string)$query));
        foreach (self::WILAYAS as $code => $names) {
            if (mb_strtolower($names[0]) === $cleanQuery || mb_strtolower($names[1]) === $cleanQuery) {
                return ['code' => $code, 'french' => $names[0], 'arabic' => $names[1]];
            }
        }

        // Fuzzy partial match
        foreach (self::WILAYAS as $code => $names) {
            if (str_contains(mb_strtolower($names[0]), $cleanQuery) || str_contains(mb_strtolower($names[1]), $cleanQuery)) {
                return ['code' => $code, 'french' => $names[0], 'arabic' => $names[1]];
            }
        }

        return null;
    }

    /**
     * Expand search query into bilingual variants for database matching.
     */
    public static function expandSearchVariants(string $term): array
    {
        $termLower = mb_strtolower(trim($term));
        $variants = [$term];

        // 1. Check Wilayas
        $wilaya = self::resolveWilaya($termLower);
        if ($wilaya) {
            $variants[] = (string)$wilaya['code'];
            $variants[] = $wilaya['french'];
            $variants[] = $wilaya['arabic'];
        }

        // 2. Check Subjects
        foreach (self::SUBJECTS as $key => $synonyms) {
            $matched = false;
            foreach ($synonyms as $synonym) {
                if (str_contains(mb_strtolower($synonym), $termLower) || str_contains($termLower, mb_strtolower($synonym))) {
                    $matched = true;
                    break;
                }
            }
            if ($matched) {
                $variants = array_merge($variants, $synonyms);
            }
        }

        return array_values(array_unique($variants));
    }
}
