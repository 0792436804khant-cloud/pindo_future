<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ExamPaper;
use App\Models\ExamSimulation;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ExamBankController extends Controller
{
    /**
     * List all published official exam papers with Algerian curriculum filters.
     */
    public function index(Request $request): JsonResponse
    {
        $query = ExamPaper::query()->published();

        if ($request->filled('cycle')) {
            $query->cycle($request->input('cycle'));
        }

        if ($request->filled('stream')) {
            $query->stream($request->input('stream'));
        }

        if ($request->filled('subject')) {
            $query->subject($request->input('subject'));
        }

        if ($request->filled('year')) {
            $query->year((int) $request->input('year'));
        }

        if ($request->filled('search')) {
            $search = '%' . trim($request->input('search')) . '%';
            $query->where(function ($q) use ($search) {
                $q->where('title', 'like', $search)
                  ->orWhere('description', 'like', $search)
                  ->orWhere('subject_name_ar', 'like', $search);
            });
        }

        $sortBy = $request->input('sort_by', 'year');
        $sortOrder = $request->input('sort_order', 'desc');

        if (in_array($sortBy, ['year', 'views_count', 'downloads_count', 'created_at'])) {
            $query->orderBy($sortBy, $sortOrder === 'asc' ? 'asc' : 'desc');
        } else {
            $query->orderBy('year', 'desc');
        }

        // Secondary order by option number and id
        $query->orderBy('option_number', 'asc')->orderBy('id', 'desc');

        $perPage = min((int) $request->input('per_page', 15), 50);
        $exams = $query->paginate($perPage);

        return response()->json([
            'status' => 'success',
            'data' => $exams->items(),
            'pagination' => [
                'current_page' => $exams->currentPage(),
                'last_page' => $exams->lastPage(),
                'per_page' => $exams->perPage(),
                'total' => $exams->total(),
            ],
            'meta' => [
                'applied_filters' => [
                    'cycle' => $request->input('cycle'),
                    'stream' => $request->input('stream'),
                    'subject' => $request->input('subject'),
                    'year' => $request->input('year'),
                ],
            ],
        ]);
    }

    /**
     * Retrieve single exam paper with exercises and official solution metadata.
     */
    public function show(int|string $id, Request $request): JsonResponse
    {
        $exam = ExamPaper::with('exercises')->published()->find($id);

        if (!$exam) {
            return response()->json([
                'status' => 'error',
                'message' => 'موضوع الامتحان غير موجود أو غير منشور حالياً.',
            ], 404);
        }

        // Increment view count quietly
        $exam->increment('views_count');

        $userSimulations = [];
        if ($request->user()) {
            $userSimulations = ExamSimulation::where('user_id', $request->user()->id)
                ->where('exam_paper_id', $exam->id)
                ->orderBy('created_at', 'desc')
                ->take(5)
                ->get();
        }

        return response()->json([
            'status' => 'success',
            'data' => [
                'exam' => $exam,
                'exercises' => $exam->exercises,
                'has_official_solution' => !empty($exam->solution_pdf_url),
                'user_simulations' => $userSimulations,
            ],
        ]);
    }

    /**
     * Available educational subjects & streams metadata in Algerian curriculum.
     */
    public function subjects(): JsonResponse
    {
        return response()->json([
            'status' => 'success',
            'data' => [
                'cycles' => [
                    [
                        'id' => 'bem',
                        'name_ar' => 'شهادة التعليم المتوسط (BEM)',
                        'level' => '4AM (الرابعة متوسط)',
                        'streams' => [],
                        'subjects' => [
                            ['id' => 'mathematics', 'name_ar' => 'الرياضيات', 'coefficient' => 4],
                            ['id' => 'arabic', 'name_ar' => 'اللغة العربية', 'coefficient' => 5],
                            ['id' => 'physics', 'name_ar' => 'العلوم الفيزيائية والتكنولوجيا', 'coefficient' => 2],
                            ['id' => 'natural_sciences', 'name_ar' => 'علوم الطبيعة والحياة', 'coefficient' => 2],
                            ['id' => 'french', 'name_ar' => 'اللغة الفرنسية', 'coefficient' => 3],
                            ['id' => 'english', 'name_ar' => 'اللغة الإنجليزية', 'coefficient' => 2],
                            ['id' => 'history_geography', 'name_ar' => 'التاريخ والجغرافيا', 'coefficient' => 3],
                            ['id' => 'islamic_education', 'name_ar' => 'التربية الإسلامية', 'coefficient' => 2],
                            ['id' => 'civil_education', 'name_ar' => 'التربية المدنية', 'coefficient' => 1],
                        ],
                    ],
                    [
                        'id' => 'bac',
                        'name_ar' => 'شهادة البكالوريا (BAC)',
                        'level' => '3AS (الثالثة ثانوي)',
                        'streams' => [
                            [
                                'id' => 'experimental_sciences',
                                'name_ar' => 'شعبة علوم تجريبية',
                                'subjects' => [
                                    ['id' => 'natural_sciences', 'name_ar' => 'علوم الطبيعة والحياة', 'coefficient' => 6],
                                    ['id' => 'physics', 'name_ar' => 'العلوم الفيزيائية', 'coefficient' => 5],
                                    ['id' => 'mathematics', 'name_ar' => 'الرياضيات', 'coefficient' => 5],
                                    ['id' => 'arabic', 'name_ar' => 'اللغة العربية وآدابها', 'coefficient' => 3],
                                    ['id' => 'philosophy', 'name_ar' => 'الفلسفة', 'coefficient' => 2],
                                    ['id' => 'french', 'name_ar' => 'اللغة الفرنسية', 'coefficient' => 2],
                                    ['id' => 'english', 'name_ar' => 'اللغة الإنجليزية', 'coefficient' => 2],
                                    ['id' => 'history_geography', 'name_ar' => 'التاريخ والجغرافيا', 'coefficient' => 2],
                                    ['id' => 'islamic_education', 'name_ar' => 'العلوم الإسلامية', 'coefficient' => 2],
                                ],
                            ],
                            [
                                'id' => 'mathematics',
                                'name_ar' => 'شعبة رياضيات',
                                'subjects' => [
                                    ['id' => 'mathematics', 'name_ar' => 'الرياضيات', 'coefficient' => 7],
                                    ['id' => 'physics', 'name_ar' => 'العلوم الفيزيائية', 'coefficient' => 6],
                                    ['id' => 'arabic', 'name_ar' => 'اللغة العربية وآدابها', 'coefficient' => 3],
                                    ['id' => 'philosophy', 'name_ar' => 'الفلسفة', 'coefficient' => 2],
                                    ['id' => 'french', 'name_ar' => 'اللغة الفرنسية', 'coefficient' => 2],
                                    ['id' => 'english', 'name_ar' => 'اللغة الإنجليزية', 'coefficient' => 2],
                                    ['id' => 'history_geography', 'name_ar' => 'التاريخ والجغرافيا', 'coefficient' => 2],
                                    ['id' => 'islamic_education', 'name_ar' => 'العلوم الإسلامية', 'coefficient' => 2],
                                ],
                            ],
                            [
                                'id' => 'math_technical',
                                'name_ar' => 'شعبة تقني رياضي',
                                'subjects' => [
                                    ['id' => 'engineering', 'name_ar' => 'التكنولوجيا (هندسة ميكانيكية/كهربائية/مدنية/طرائق)', 'coefficient' => 7],
                                    ['id' => 'mathematics', 'name_ar' => 'الرياضيات', 'coefficient' => 6],
                                    ['id' => 'physics', 'name_ar' => 'العلوم الفيزيائية', 'coefficient' => 6],
                                    ['id' => 'arabic', 'name_ar' => 'اللغة العربية وآدابها', 'coefficient' => 3],
                                    ['id' => 'philosophy', 'name_ar' => 'الفلسفة', 'coefficient' => 2],
                                ],
                            ],
                            [
                                'id' => 'management_economics',
                                'name_ar' => 'شعبة تسيير واقتصاد',
                                'subjects' => [
                                    ['id' => 'accounting', 'name_ar' => 'التسيير المحاسبي والمالي', 'coefficient' => 6],
                                    ['id' => 'economics', 'name_ar' => 'الاقتصاد والمناجمنت', 'coefficient' => 5],
                                    ['id' => 'mathematics', 'name_ar' => 'الرياضيات', 'coefficient' => 5],
                                    ['id' => 'law', 'name_ar' => 'القانون', 'coefficient' => 2],
                                    ['id' => 'arabic', 'name_ar' => 'اللغة العربية وآدابها', 'coefficient' => 3],
                                    ['id' => 'history_geography', 'name_ar' => 'التاريخ والجغرافيا', 'coefficient' => 4],
                                ],
                            ],
                            [
                                'id' => 'literature_philosophy',
                                'name_ar' => 'شعبة آداب وفلسفة',
                                'subjects' => [
                                    ['id' => 'philosophy', 'name_ar' => 'الفلسفة', 'coefficient' => 6],
                                    ['id' => 'arabic', 'name_ar' => 'اللغة العربية وآدابها', 'coefficient' => 6],
                                    ['id' => 'history_geography', 'name_ar' => 'التاريخ والجغرافيا', 'coefficient' => 4],
                                    ['id' => 'french', 'name_ar' => 'اللغة الفرنسية', 'coefficient' => 3],
                                    ['id' => 'english', 'name_ar' => 'اللغة الإنجليزية', 'coefficient' => 3],
                                ],
                            ],
                            [
                                'id' => 'foreign_languages',
                                'name_ar' => 'شعبة لغات أجنبية',
                                'subjects' => [
                                    ['id' => 'third_language', 'name_ar' => 'اللغة الأجنبية الثالثة (إسبانية/ألمانية/إيطالية)', 'coefficient' => 5],
                                    ['id' => 'french', 'name_ar' => 'اللغة الفرنسية', 'coefficient' => 5],
                                    ['id' => 'english', 'name_ar' => 'اللغة الإنجليزية', 'coefficient' => 5],
                                    ['id' => 'arabic', 'name_ar' => 'اللغة العربية وآدابها', 'coefficient' => 5],
                                    ['id' => 'history_geography', 'name_ar' => 'التاريخ والجغرافيا', 'coefficient' => 2],
                                    ['id' => 'philosophy', 'name_ar' => 'الفلسفة', 'coefficient' => 2],
                                ],
                            ],
                        ],
                    ],
                ],
                'available_years' => range(2025, 2015),
            ],
        ]);
    }

    /**
     * Start a new timed mock exam simulation for the authenticated student.
     */
    public function startSimulation(int|string $id, Request $request): JsonResponse
    {
        $exam = ExamPaper::published()->find($id);

        if (!$exam) {
            return response()->json([
                'status' => 'error',
                'message' => 'موضوع الامتحان المحدد غير موجود.',
            ], 404);
        }

        // Check if there is already an in_progress simulation for this student on this paper
        $existingSimulation = ExamSimulation::where('user_id', $request->user()->id)
            ->where('exam_paper_id', $exam->id)
            ->where('status', 'in_progress')
            ->first();

        if ($existingSimulation) {
            return response()->json([
                'status' => 'success',
                'message' => 'تم استئناف جلسة المحاكاة الحالية بنجاح.',
                'data' => [
                    'simulation' => $existingSimulation->load('examPaper'),
                    'is_resumed' => true,
                ],
            ]);
        }

        $simulation = ExamSimulation::create([
            'user_id' => $request->user()->id,
            'exam_paper_id' => $exam->id,
            'started_at' => now(),
            'time_spent_seconds' => 0,
            'completed_exercises' => [],
            'status' => 'in_progress',
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'بدأت جلسة المحاكاة المؤقتة للامتحان بنجاح. بالتوفيق!',
            'data' => [
                'simulation' => $simulation->load('examPaper'),
                'is_resumed' => false,
            ],
        ], 201);
    }

    /**
     * Update in-flight simulation progress (time spent, completed exercises checklist).
     */
    public function updateSimulationProgress(int|string $simulationId, Request $request): JsonResponse
    {
        $simulation = ExamSimulation::where('user_id', $request->user()->id)->find($simulationId);

        if (!$simulation) {
            return response()->json([
                'status' => 'error',
                'message' => 'جلسة المحاكاة غير موجودة أو لا تملك صلاحية الوصول إليها.',
            ], 404);
        }

        if ($simulation->status !== 'in_progress') {
            return response()->json([
                'status' => 'error',
                'message' => 'لا يمكن تعديل جلسة محاكاة مكتملة أو ملغاة.',
            ], 422);
        }

        $validator = Validator::make($request->all(), [
            'time_spent_seconds' => 'nullable|integer|min:0',
            'completed_exercises' => 'nullable|array',
            'student_notes' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'بيانات التحديث غير صالحة.',
                'errors' => $validator->errors(),
            ], 422);
        }

        if ($request->has('time_spent_seconds')) {
            $simulation->time_spent_seconds = (int) $request->input('time_spent_seconds');
        }

        if ($request->has('completed_exercises')) {
            $simulation->completed_exercises = $request->input('completed_exercises');
        }

        if ($request->has('student_notes')) {
            $simulation->student_notes = $request->input('student_notes');
        }

        $simulation->save();

        return response()->json([
            'status' => 'success',
            'message' => 'تم حفظ تقدم المحاكاة بنجاح.',
            'data' => $simulation,
        ]);
    }

    /**
     * Finish simulation session and register self-assessment score according to ministerial rubric.
     */
    public function finishSimulation(int|string $simulationId, Request $request): JsonResponse
    {
        $simulation = ExamSimulation::with('examPaper')->where('user_id', $request->user()->id)->find($simulationId);

        if (!$simulation) {
            return response()->json([
                'status' => 'error',
                'message' => 'جلسة المحاكاة غير موجودة أو لا تملك صلاحية الوصول إليها.',
            ], 404);
        }

        $validator = Validator::make($request->all(), [
            'self_assessment_score' => 'nullable|numeric|min:0|max:20',
            'time_spent_seconds' => 'nullable|integer|min:0',
            'completed_exercises' => 'nullable|array',
            'student_notes' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'status' => 'error',
                'message' => 'سلم التنقيط المدخل غير صالح (يجب أن يكون بين 0 و 20).',
                'errors' => $validator->errors(),
            ], 422);
        }

        if ($request->has('time_spent_seconds')) {
            $simulation->time_spent_seconds = (int) $request->input('time_spent_seconds');
        }

        if ($request->has('completed_exercises')) {
            $simulation->completed_exercises = $request->input('completed_exercises');
        }

        if ($request->has('student_notes')) {
            $simulation->student_notes = $request->input('student_notes');
        }

        if ($request->has('self_assessment_score')) {
            $simulation->self_assessment_score = (float) $request->input('self_assessment_score');
        }

        $simulation->ended_at = now();
        $simulation->status = 'completed';
        $simulation->save();

        return response()->json([
            'status' => 'success',
            'message' => 'تهانينا! اكتملت محاكاة الامتحان بنجاح، ويمكنك الآن مراجعة سلم التنقيط الوزاري.',
            'data' => [
                'simulation' => $simulation,
                'exam_paper' => $simulation->examPaper,
                'solution_url' => $simulation->examPaper->solution_pdf_url,
            ],
        ]);
    }

    /**
     * Retrieve student's personal simulation history and performance metrics.
     */
    public function mySimulations(Request $request): JsonResponse
    {
        $user = $request->user();

        $simulations = ExamSimulation::with(['examPaper' => function ($query) {
            $query->select('id', 'title', 'cycle', 'stream', 'subject_name_ar', 'year', 'duration_minutes');
        }])
            ->where('user_id', $user->id)
            ->orderBy('created_at', 'desc')
            ->paginate(15);

        $totalCompleted = ExamSimulation::where('user_id', $user->id)
            ->where('status', 'completed')
            ->count();

        $averageScore = ExamSimulation::where('user_id', $user->id)
            ->where('status', 'completed')
            ->whereNotNull('self_assessment_score')
            ->avg('self_assessment_score');

        $totalSecondsSpent = ExamSimulation::where('user_id', $user->id)
            ->sum('time_spent_seconds');

        return response()->json([
            'status' => 'success',
            'data' => $simulations->items(),
            'pagination' => [
                'current_page' => $simulations->currentPage(),
                'last_page' => $simulations->lastPage(),
                'total' => $simulations->total(),
            ],
            'metrics' => [
                'total_simulations_completed' => $totalCompleted,
                'average_score' => $averageScore ? round($averageScore, 2) : null,
                'total_study_minutes' => round($totalSecondsSpent / 60),
            ],
        ]);
    }
}
