<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?php echo e($teacher ? $teacher->name . ' | Pindo Future' : 'صفحة الأستاذ | Pindo Future'); ?></title>
    <link rel="icon" type="image/png" href="/images/pindo_logo_badge.png">
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;800;900&display=swap" rel="stylesheet">
    <style>
        body { background-color: #050814; color: #F8FAFC; font-family: 'Cairo', sans-serif; }
        .glass-card {
            background: linear-gradient(145deg, rgba(15, 23, 42, 0.8), rgba(9, 13, 28, 0.94));
            backdrop-filter: blur(18px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
    </style>
</head>
<body class="min-h-screen antialiased flex flex-col">
    <header class="border-b border-white/10 bg-slate-950/80 backdrop-blur-xl px-4 py-3.5">
        <div class="max-w-5xl mx-auto flex items-center justify-between">
            <a href="/" class="flex items-center gap-2.5">
                <img src="/images/pindo_logo_badge.png" alt="Pindo Future" class="w-9 h-9 rounded-xl">
                <span class="font-black text-base text-white">Pindo <span class="text-cyan-400">Future</span></span>
            </a>
            <a href="/app/" class="px-4 py-2 rounded-xl bg-cyan-400 text-slate-950 font-black text-xs hover:bg-cyan-300 transition-all">
                فتح التطبيق ←
            </a>
        </div>
    </header>

    <main class="flex-1 max-w-5xl w-full mx-auto px-4 py-12">
        <?php if(!$teacher): ?>
            <div class="glass-card rounded-3xl p-10 text-center space-y-4">
                <div class="text-4xl">🔎</div>
                <h1 class="text-2xl font-black text-white">لم يتم العثور على صفحة الأستاذ (<?php echo e($teacherId); ?>)</h1>
                <p class="text-sm text-slate-400">قد يكون المعرف غير صحيح أو لم يقم الأستاذ بتفعيل منصته بعد.</p>
                <a href="/" class="inline-block px-6 py-3 rounded-xl bg-cyan-400 text-slate-950 font-black text-xs">العودة إلى الرئيسية</a>
            </div>
        <?php else: ?>
            <div class="glass-card rounded-3xl p-8 space-y-6">
                <div class="flex flex-col sm:flex-row sm:items-center justify-between gap-4 border-b border-white/10 pb-6">
                    <div>
                        <div class="flex items-center gap-2">
                            <h1 class="text-2xl sm:text-3xl font-black text-white"><?php echo e($teacher->name); ?></h1>
                            <?php if($teacher->is_verified): ?>
                                <span class="px-2.5 py-0.5 rounded-full bg-cyan-500/20 text-cyan-300 border border-cyan-400/30 text-xs font-extrabold">✓ أستاذ معتمد</span>
                            <?php endif; ?>
                        </div>
                        <p class="text-sm text-cyan-300 font-bold mt-1"><?php echo e($teacher->teacherPlatform?->headline ?? 'أستاذ تعليم إلكتروني عبر منصة Pindo Future'); ?></p>
                        <div class="text-xs font-mono text-slate-400 mt-1">ID: <?php echo e($teacher->teacher_id); ?></div>
                    </div>
                    <a href="/app/" class="px-6 py-3 rounded-xl bg-gradient-to-r from-cyan-400 to-emerald-400 text-slate-950 font-black text-xs text-center">
                        الانضمام عبر التطبيق ←
                    </a>
                </div>

                <?php if($teacher->teacherPlatform?->bio): ?>
                    <p class="text-sm text-slate-300 leading-relaxed"><?php echo e($teacher->teacherPlatform->bio); ?></p>
                <?php endif; ?>

                <div>
                    <h2 class="text-lg font-black text-white mb-4">الأفواج التعليمية النشطة (<?php echo e($cohorts->count()); ?>)</h2>
                    <?php if($cohorts->isEmpty()): ?>
                        <div class="rounded-2xl bg-slate-900/70 border border-white/5 p-6 text-center text-xs text-slate-400">
                            لم يقم الأستاذ بنشر أفواج نشطة بعد.
                        </div>
                    <?php else: ?>
                        <div class="grid grid-cols-1 sm:grid-cols-2 gap-4">
                            <?php $__currentLoopData = $cohorts; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $cohort): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                                <div class="rounded-2xl bg-slate-900/80 border border-white/10 p-5 space-y-2">
                                    <div class="flex items-center justify-between">
                                        <span class="font-extrabold text-sm text-white"><?php echo e($cohort->name); ?></span>
                                        <span class="text-xs font-mono font-bold text-amber-400"><?php echo e(number_format((float)$cohort->monthly_price, 0)); ?> دج</span>
                                    </div>
                                    <div class="text-xs text-cyan-300"><?php echo e($cohort->subject); ?> • <?php echo e($cohort->academic_level); ?></div>
                                    <div class="text-[11px] text-slate-400 font-mono"><?php echo e($cohort->cohort_code); ?></div>
                                </div>
                            <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
                        </div>
                    <?php endif; ?>
                </div>
            </div>
        <?php endif; ?>
    </main>
</body>
</html>
<?php /**PATH C:\Users\Tech-Space\Downloads\38833FF26BA1D.UnigramPreview_g9c9v27vpyspw!App\pindo_future (1)\pindo_future\backend\resources\views/site/teacher.blade.php ENDPATH**/ ?>