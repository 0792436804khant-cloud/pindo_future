<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>بيندو فيوتشر | مركز التحكم الإداري الآمن</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;900&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Cairo', sans-serif;
            background-color: #070B14;
        }
        .glass-panel {
            background: rgba(15, 23, 42, 0.75);
            backdrop-filter: blur(16px);
            -webkit-backdrop-filter: blur(16px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        .ambient-glow {
            position: absolute;
            width: 450px;
            height: 450px;
            border-radius: 50%;
            filter: blur(120px);
            pointer-events: none;
            opacity: 0.25;
        }
    </style>
</head>
<body class="min-h-screen text-slate-100 flex items-center justify-center p-4 relative overflow-hidden">
    <!-- Ambient Lighting Effects -->
    <div class="ambient-glow bg-emerald-500 top-[-100px] right-[-100px]"></div>
    <div class="ambient-glow bg-cyan-600 bottom-[-100px] left-[-100px]"></div>

    <div class="w-full max-w-md relative z-10">
        <!-- Brand Header -->
        <div class="text-center mb-8">
            <div class="inline-flex items-center justify-center w-16 h-16 rounded-2xl bg-gradient-to-tr from-emerald-500 to-teal-400 p-0.5 shadow-xl shadow-emerald-500/20 mb-4">
                <div class="w-full h-full bg-slate-950 rounded-[14px] flex items-center justify-center">
                    <span class="text-2xl font-black text-transparent bg-clip-text bg-gradient-to-r from-emerald-400 to-teal-200">PF</span>
                </div>
            </div>
            <h1 class="text-2xl font-black tracking-tight text-white">بيندو فيوتشر | Pindo Future</h1>
            <p class="text-xs font-semibold text-emerald-400 mt-1 uppercase tracking-wider">نظام الرقابة والتحكم المركزي (Operations Portal)</p>
        </div>

        <!-- Login Card -->
        <div class="glass-panel rounded-3xl p-8 shadow-2xl shadow-black/80">
            <div class="flex items-center justify-between mb-6 pb-4 border-b border-white/10">
                <div class="flex items-center space-x-2 space-x-reverse">
                    <span class="w-2.5 h-2.5 rounded-full bg-emerald-400 animate-pulse"></span>
                    <span class="text-xs font-bold text-slate-300">بوابة الدخول المحمية</span>
                </div>
                <span class="text-[11px] font-mono px-2 py-0.5 rounded-full bg-white/5 text-slate-400 border border-white/5">SSL / HTTPS Enforced</span>
            </div>

            <?php if($errors->any()): ?>
                <div class="mb-5 p-3.5 rounded-xl bg-red-500/10 border border-red-500/30 text-red-400 text-xs font-semibold leading-relaxed">
                    <?php echo e($errors->first()); ?>

                </div>
            <?php endif; ?>

            <form action="<?php echo e(route('admin.login.submit')); ?>" method="POST" class="space-y-4">
                <?php echo csrf_field(); ?>
                <div>
                    <label class="block text-xs font-bold text-slate-300 mb-1.5" for="email">البريد الإلكتروني للإدارة</label>
                    <input 
                        type="email" 
                        name="email" 
                        id="email" 
                        required 
                        autocomplete="username"
                        value="<?php echo e(old('email')); ?>"
                        class="w-full px-4 py-3 rounded-xl bg-slate-900/80 border border-white/10 text-white placeholder-slate-500 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent transition-all"
                        placeholder="admin@pindofuture.com"
                    >
                </div>

                <div>
                    <div class="flex items-center justify-between mb-1.5">
                        <label class="block text-xs font-bold text-slate-300" for="password">كلمة المرور المشفرة</label>
                        <span class="text-[11px] text-slate-500">2048-bit Hash</span>
                    </div>
                    <input 
                        type="password" 
                        name="password" 
                        id="password" 
                        required 
                        autocomplete="current-password"
                        class="w-full px-4 py-3 rounded-xl bg-slate-900/80 border border-white/10 text-white placeholder-slate-500 text-sm focus:outline-none focus:ring-2 focus:ring-emerald-500 focus:border-transparent transition-all font-mono"
                        placeholder="••••••••••••"
                    >
                </div>

                <div class="flex items-center justify-between py-1">
                    <label class="inline-flex items-center space-x-2 space-x-reverse cursor-pointer">
                        <input type="checkbox" name="remember" class="rounded bg-slate-900 border-white/20 text-emerald-500 focus:ring-emerald-500 focus:ring-offset-0 w-4 h-4">
                        <span class="text-xs text-slate-400 select-none">تذكر الجلسة الآمنة</span>
                    </label>
                    <span class="text-[11px] text-emerald-400/80 font-semibold">Protected Access</span>
                </div>

                <button 
                    type="submit" 
                    class="w-full mt-2 py-3.5 px-4 rounded-xl bg-gradient-to-r from-emerald-500 to-teal-500 hover:from-emerald-400 hover:to-teal-400 text-slate-950 font-black text-sm shadow-lg shadow-emerald-500/25 transition-all transform active:scale-[0.99] flex items-center justify-center space-x-2 space-x-reverse"
                >
                    <span>فتح لوحة القيادة المركزية</span>
                    <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14 5l7 7m0 0l-7 7m7-7H3"/></svg>
                </button>
            </form>

            <!-- Security Footnote -->
            <div class="mt-8 pt-4 border-t border-white/5 text-center">
                <p class="text-[11px] text-slate-500 leading-relaxed">
                    منصة محمية بنظام التحقق المتعدد ومعالجة الوكلاء المعكوسين (TrustProxies). محاولات الدخول غير المصرح بها مسجلة تلقائياً.
                </p>
            </div>
        </div>
    </div>
</body>
</html>
<?php /**PATH C:\Users\Tech-Space\Downloads\38833FF26BA1D.UnigramPreview_g9c9v27vpyspw!App\pindo_future (1)\pindo_future\backend\resources\views/admin/login.blade.php ENDPATH**/ ?>