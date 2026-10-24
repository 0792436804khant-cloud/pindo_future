<?php

namespace Database\Seeders;

use App\Models\ExamExercise;
use App\Models\ExamPaper;
use Illuminate\Database\Seeder;

class ExamBankSeeder extends Seeder
{
    /**
     * Run the database seeds for Algerian National BEM & BAC Exam Banks.
     */
    public function run(): void
    {
        // 1. BAC 2024 - شعبة علوم تجريبية - مادة الرياضيات (الموضوع الأول)
        $bac2024Math = ExamPaper::firstOrCreate(
            ['exam_code' => 'BAC-2024-EXPSC-MATH-S1'],
            [
                'title' => 'بكالوريا 2024 - شعبة علوم تجريبية - مادة الرياضيات (الموضوع الأول)',
                'cycle' => 'bac',
                'stream' => 'experimental_sciences',
                'subject' => 'mathematics',
                'subject_name_ar' => 'الرياضيات',
                'year' => 2024,
                'session_type' => 'main',
                'option_number' => 1,
                'duration_minutes' => 210, // 3h 30m
                'coefficient' => 5,
                'total_score' => 20,
                'paper_pdf_url' => 'https://cdn.pindofuture.com/exams/bac2024_sc_math_s1.pdf',
                'solution_pdf_url' => 'https://cdn.pindofuture.com/exams/solutions/bac2024_sc_math_s1_corr.pdf',
                'description' => 'الموضوع الأول يحتوي على 4 تمارين: التمرين الأول في المتتاليات، الثاني في الاحتمالات، الثالث في الهندسة الفضائية، والرابع مسألة شاملة في الدوال العددية واللوغاريتمية.',
                'difficulty_level' => 'medium',
                'exercise_count' => 4,
                'is_published' => true,
            ]
        );

        ExamExercise::firstOrCreate(
            ['exam_paper_id' => $bac2024Math->id, 'exercise_number' => 1],
            [
                'title' => 'التمرين الأول (04.5 نقاط) - المتتاليات العددية',
                'topic' => 'المتتاليات العددية والتراجع',
                'points' => 4.50,
                'instructions' => 'لتكن المتتالية (u_n) المعرفة بحدها الأول u_0 = 1 ومن أجل كل عدد طبيعي n: u_(n+1) = (2u_n + 3)/(u_n + 4). 1) برهن بالتراجع أن 0 < u_n < 1. 2) ادرس رتابة المتتالية واستنتج تقاربها.',
                'official_marking_rubric' => [
                ['step' => 'البرهان بالتراجع على حصر المتتالية', 'points' => 1.25],
                ['step' => 'دراسة إشارة الفرق u_(n+1) - u_n واستنتاج التزايد', 'points' => 1.25],
                ['step' => 'مبرهنة التقارب وحساب النهاية', 'points' => 1.00],
                ['step' => 'المتتالية المساعدة v_n وحساب المجموع S_n', 'points' => 1.00],
            ],
            'solution_explanation' => 'استعمال البرهان بالتراجع بخطواته الثلاث، ثم دراسة إشارة الفرق u_(n+1)-u_n التي تثبت أن المتتالية متزايدة تماما ومحدودة من الأعلى بالعدد 1 فهي متقاربة.',
        ]);

        ExamExercise::firstOrCreate(
            ['exam_paper_id' => $bac2024Math->id, 'exercise_number' => 2],
            [
                'title' => 'التمرين الثاني (04.0 نقاط) - الاحتمالات والمتغير العشوائي',
                'topic' => 'الاحتمالات المشروطة وقانون الاحتمال',
                'points' => 4.00,
                'instructions' => 'يحتوي صندوق على 4 كريات بيضاء و 3 كريات حمراء لا نفرق بينها عند اللمس. نسحب عشوائيا وفي آن واحد كريتين من الصندوق.',
                'official_marking_rubric' => [
                    ['step' => 'حساب الحالات الممكنة C(7,2) = 21', 'points' => 0.75],
                    ['step' => 'حساب احتمال سحب كريتين من نفس اللون', 'points' => 1.00],
                    ['step' => 'تعيين قيم المتغير العشوائي X', 'points' => 0.75],
                    ['step' => 'جدول قانون الاحتمال وحساب الأمل الرياضياتي E(X)', 'points' => 1.50],
                ],
                'solution_explanation' => 'حساب التوافيقات C(n,p) وقانون الاحتمال والمتغير العشوائي X والأمل الرياضي.',
            ]
        );

        ExamExercise::firstOrCreate(
            ['exam_paper_id' => $bac2024Math->id, 'exercise_number' => 3],
            [
                'title' => 'التمرين الثالث (04.0 نقاط) - الهندسة في الفضاء',
                'topic' => 'المستويات والمستقيمات والجداء السلمي',
                'points' => 4.00,
                'instructions' => 'الفضاء منسوب إلى معلم متعامد ومتجانس (O; i, j, k). نعتبر النقط A, B, C والمستوي (P).',
                'official_marking_rubric' => [
                    ['step' => 'إثبات أن النقط A, B, C ليست على استقامة واحدة', 'points' => 1.00],
                    ['step' => 'تعيين معادلة ديكارتية للمستوي (ABC)', 'points' => 1.50],
                    ['step' => 'حساب المسافة بين نقطة ومستو والتقاطع', 'points' => 1.50],
                ],
                'solution_explanation' => 'التحقق من عدم ارتباط الشعاعين AB و AC، ثم إيجاد الشعاع الناظمي للمستوي.',
            ]
        );

        ExamExercise::firstOrCreate(
            ['exam_paper_id' => $bac2024Math->id, 'exercise_number' => 4],
            [
                'title' => 'التمرين الرابع (07.5 نقاط) - دراسة دالة لوغاريتمية وحساب التكامل',
                'topic' => 'الدوال اللوغاريتمية والبيان والتكامل',
                'points' => 7.50,
                'instructions' => 'الجزء الأول: نعتبر الدالة g(x) = 1 - x + ln(x). الجزء الثاني: الدالة f(x) = (x - 1)ln(x) / x. دراسة التغيرات، المستقيمات المقاربة، والتمثيل البياني وحساب المساحة.',
                'official_marking_rubric' => [
                    ['step' => 'دراسة تغيرات g(x) واستنتاج إشارتها', 'points' => 1.50],
                    ['step' => 'حساب النهايات لدالة f عند 0 و +مالانهاية', 'points' => 1.50],
                    ['step' => 'حساب المشتقة f\'(x) وجدول التغيرات', 'points' => 1.50],
                    ['step' => 'رسم المنحنى البياني (Cf)', 'points' => 1.50],
                    ['step' => 'المكاملة بالتجزئة وحساب مساحة الحيز', 'points' => 1.50],
                ],
                'solution_explanation' => 'استنتاج إشارة دالة مساعدة g(x) للتحكم في إشارة مشتقة f(x)، ورسم المنحنى بدقة مع المماس والمستقيم المقارب.',
            ]
        );

        // 2. BAC 2024 - شعبة رياضيات - العلوم الفيزيائية (الموضوع الأول)
        $bac2024Phys = ExamPaper::firstOrCreate(
            ['exam_code' => 'BAC-2024-MATH-PHYS-S1'],
            [
                'title' => 'بكالوريا 2024 - شعبة رياضيات - العلوم الفيزيائية (الموضوع الأول)',
                'cycle' => 'bac',
                'stream' => 'mathematics',
                'subject' => 'physics',
                'subject_name_ar' => 'العلوم الفيزيائية',
                'year' => 2024,
                'session_type' => 'main',
                'option_number' => 1,
                'duration_minutes' => 240, // 4 hours
                'coefficient' => 6,
                'total_score' => 20,
                'paper_pdf_url' => 'https://cdn.pindofuture.com/exams/bac2024_math_phys_s1.pdf',
                'solution_pdf_url' => 'https://cdn.pindofuture.com/exams/solutions/bac2024_math_phys_s1_corr.pdf',
                'description' => 'الموضوع الأول لشعبة الرياضيات: المتابعة الزمنية لتحول كيميائي، دراسة حركة قمر اصطناعي، والدارة الكهربائية RLC، والتمرين التجريبي في المعايرة.',
                'difficulty_level' => 'hard',
                'exercise_count' => 3,
                'is_published' => true,
            ]
        );

        ExamExercise::firstOrCreate(
            ['exam_paper_id' => $bac2024Phys->id, 'exercise_number' => 1],
            [
                'title' => 'التمرين الأول (06.0 نقاط) - الميكانيك وحركة الأقمار الاصطناعية',
                'topic' => 'قوانين نيوتن وحركة الكواكب والأقمار',
                'points' => 6.00,
                'instructions' => 'يدور قمر اصطناعي كتلته m حول الأرض بحركة دائرية منتظمة على ارتفاع h من سطح الأرض. بتطبيق القانون الثاني لنيوتن، أوجد عبارة السرعة المدارية والدور T.',
                'official_marking_rubric' => [
                    ['step' => 'المرجع العطالي المناسب والقوى المؤثرة', 'points' => 1.50],
                    ['step' => 'تطبيق القانون الثاني لنيوتن وإثبات الحركة الدائرية المنتظمة', 'points' => 2.00],
                    ['step' => 'عبارة الدور T وقانون كبلر الثالث T^2/r^3', 'points' => 1.50],
                    ['step' => 'استنتاج كتلة الأرض M_T والارتفاع h', 'points' => 1.00],
                ],
                'solution_explanation' => 'المرجع الجيو مركزي يعتبر عطاليا لدراسة حركة الأقمار. F = G*M_T*m/r^2 = m*v^2/r.',
            ]
        );

        // 3. BEM 2024 - شهادة التعليم المتوسط - مادة الرياضيات
        $bem2024Math = ExamPaper::firstOrCreate(
            ['exam_code' => 'BEM-2024-MATH-S1'],
            [
                'title' => 'شهادة التعليم المتوسط 2024 - مادة الرياضيات',
                'cycle' => 'bem',
                'stream' => null, // Unified
                'subject' => 'mathematics',
                'subject_name_ar' => 'الرياضيات',
                'year' => 2024,
                'session_type' => 'main',
                'option_number' => 1,
                'duration_minutes' => 120, // 2 hours
                'coefficient' => 4,
                'total_score' => 20,
                'paper_pdf_url' => 'https://cdn.pindofuture.com/exams/bem2024_math.pdf',
                'solution_pdf_url' => 'https://cdn.pindofuture.com/exams/solutions/bem2024_math_corr.pdf',
                'description' => 'موضوع شهادة التعليم المتوسط الرسمي دورة 2024: الجزء الأول (12 نقطة) يضم 4 تمارين في الجذور والنشر والتحليل، نظرية طالس، المعالم في المستوي، والدوال التآلفية. الجزء الثاني (8 نقاط) مسألة وضعية إدماجية.',
                'difficulty_level' => 'medium',
                'exercise_count' => 5,
                'is_published' => true,
            ]
        );

        ExamExercise::firstOrCreate(
            ['exam_paper_id' => $bem2024Math->id, 'exercise_number' => 1],
            [
                'title' => 'التمرين الأول (03.0 نقاط) - الحساب على الجذور والنشر والتحليل',
                'topic' => 'الأعداد والحساب الحرفي',
                'points' => 3.00,
                'instructions' => '1) اكتب A على الشكل a*sqrt(3) حيث a عدد صحيح: A = sqrt(108) - 3*sqrt(12) + sqrt(27). 2) انشر وبسط العبارة E = (2x - 3)^2 - (2x - 3)(x + 1). 3) حلل E إلى جداء عاملين من الدرجة الأولى.',
                'official_marking_rubric' => [
                    ['step' => 'تبسيط الجذور وكتابة A على الشكل 3*sqrt(3)', 'points' => 1.00],
                    ['step' => 'نشر وتبسيط المتطابقة الشهيرة والجداء', 'points' => 1.00],
                    ['step' => 'التحليل باستخراج العامل المشترك (2x - 3)', 'points' => 1.00],
                ],
                'solution_explanation' => 'تحليل الأعداد تحت الجذور إلى جداء بمربعات تامة 36*3 و 4*3 و 9*3، ثم نشر المتطابقة الشهيرة واستخراج العامل المشترك.',
            ]
        );

        ExamExercise::firstOrCreate(
            ['exam_paper_id' => $bem2024Math->id, 'exercise_number' => 5],
            [
                'title' => 'الجزء الثاني (08.0 نقاط) - الوضعية الإدماجية',
                'topic' => 'الرياضيات والحياة اليومية - الدوال والمساحات',
                'points' => 8.00,
                'instructions' => 'يمتلك فلاح قطعة أرض مستطيلة الشكل يريد تقسيمها وتهيئتها مع تسعيرة النقل والمضخات وفق صيغتين للدفع...',
                'official_marking_rubric' => [
                    ['step' => 'الترييض واختيار المجهول x', 'points' => 2.00],
                    ['step' => 'التعبير عن الصيغتين بدالتين f(x) و g(x)', 'points' => 2.50],
                    ['step' => 'التمثيل البياني للدالتين وقراءة نقطة التقاطع', 'points' => 2.50],
                    ['step' => 'الإجابة الدقيقة ونصح الفلاح بالخيار الأفضل', 'points' => 1.00],
                ],
                'solution_explanation' => 'نمذجة الوضعية بواسطة جملة معادلتين أو دوال تآلفية والمقارنة بين الصيغتين بيانيا وحسابيا.',
            ]
        );
    }
}
