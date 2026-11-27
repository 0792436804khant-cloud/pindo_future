<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>بيندو فيوتشر | غرفة العمليات المركزية والتحكم الإداري</title>
    <!-- Tailwind CSS CDN -->
    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;800;900&family=JetBrains+Mono:wght@500;700&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Cairo', sans-serif;
            background-color: #070B14;
        }
        .font-mono {
            font-family: 'JetBrains Mono', monospace;
        }
        .glass-header {
            background: rgba(11, 17, 32, 0.88);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        }
        .glass-card {
            background: rgba(15, 23, 42, 0.65);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.07);
        }
        .glass-modal {
            background: rgba(10, 15, 28, 0.95);
            backdrop-filter: blur(24px);
            -webkit-backdrop-filter: blur(24px);
            border: 1px solid rgba(255, 255, 255, 0.12);
        }
        .pulse-emerald {
            box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7);
            animation: pulse-green 2s infinite;
        }
        @keyframes pulse-green {
            0% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
            70% { transform: scale(1); box-shadow: 0 0 0 8px rgba(16, 185, 129, 0); }
            100% { transform: scale(0.95); box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
        }
        /* Custom Scrollbars */
        ::-webkit-scrollbar { width: 6px; height: 6px; }
        ::-webkit-scrollbar-track { background: #070B14; }
        ::-webkit-scrollbar-thumb { background: #1E293B; border-radius: 9999px; }
        ::-webkit-scrollbar-thumb:hover { background: #334155; }
    </style>
</head>
<body class="min-h-screen text-slate-100 flex flex-col antialiased selection:bg-emerald-500 selection:text-slate-950">

    <!-- Top Navigation & Operations Telemetry Bar -->
    <header class="glass-header sticky top-0 z-40 px-6 py-3.5">
        <div class="max-w-7xl mx-auto flex flex-wrap items-center justify-between gap-4">
            
            <!-- Left: Brand & Room Title -->
            <div class="flex items-center space-x-4 space-x-reverse">
                <div class="flex items-center justify-center w-11 h-11 rounded-xl bg-gradient-to-tr from-emerald-500 to-teal-400 p-0.5 shadow-lg shadow-emerald-500/20">
                    <div class="w-full h-full bg-slate-950 rounded-[10px] flex items-center justify-center font-black text-emerald-400 text-lg">
                        PF
                    </div>
                </div>
                <div>
                    <div class="flex items-center space-x-2 space-x-reverse">
                        <h1 class="text-base font-extrabold tracking-tight text-white">غرفة العمليات المركزية | بيندو فيوتشر</h1>
                        <span class="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                            PROD v1.0
                        </span>
                    </div>
                    <div class="flex items-center space-x-3 space-x-reverse text-xs text-slate-400">
                        <span class="flex items-center space-x-1.5 space-x-reverse">
                            <span class="w-2 h-2 rounded-full bg-emerald-400 pulse-emerald"></span>
                            <span class="text-[11px] font-semibold text-slate-300">مباشر (Live Polling 3.5s)</span>
                        </span>
                        <span>•</span>
                        <span id="liveClock" class="font-mono text-[11px] text-slate-400">--:--:--</span>
                    </div>
                </div>
            </div>

            <!-- Center: Operational Health Badges (Reverse Proxy, DB, Storage) -->
            <div class="hidden lg:flex items-center space-x-2.5 space-x-reverse text-xs">
                <div id="badgeDb" class="px-3 py-1 rounded-lg bg-slate-900/90 border border-white/5 flex items-center space-x-2 space-x-reverse">
                    <span class="w-2 h-2 rounded-full bg-emerald-400"></span>
                    <span class="text-slate-300 font-semibold text-[11px]">قاعدة البيانات: متصلة</span>
                </div>
                <div id="badgeHttps" class="px-3 py-1 rounded-lg bg-slate-900/90 border border-white/5 flex items-center space-x-2 space-x-reverse">
                    <span class="w-2 h-2 rounded-full bg-emerald-400"></span>
                    <span class="text-slate-300 font-semibold text-[11px]">Reverse Proxy: TrustProxies</span>
                </div>
                <div id="badgeStorage" class="px-3 py-1 rounded-lg bg-slate-900/90 border border-white/5 flex items-center space-x-2 space-x-reverse">
                    <span class="w-2 h-2 rounded-full bg-emerald-400"></span>
                    <span class="text-slate-300 font-semibold text-[11px]">Storage Link: نشط</span>
                </div>
                <div id="badgeQueue" class="px-3 py-1 rounded-lg bg-slate-900/90 border border-white/5 flex items-center space-x-2 space-x-reverse">
                    <span class="w-2 h-2 rounded-full bg-cyan-400"></span>
                    <span class="text-slate-300 font-semibold text-[11px]">طابور الإشعارات: جاهز</span>
                </div>
            </div>

            <!-- Right: Sound Alerts Toggle & Admin Profile -->
            <div class="flex items-center space-x-3 space-x-reverse">
                <!-- Audio Chime Alert Toggle Button -->
                <button 
                    id="audioToggleBtn" 
                    onclick="toggleAudioAlerts()" 
                    class="px-3 py-1.5 rounded-xl bg-slate-900 hover:bg-slate-800 border border-white/10 text-xs font-semibold text-emerald-400 flex items-center space-x-1.5 space-x-reverse transition-all shadow-sm"
                    title="تفعيل/كتم الصفارات الصوتية التلقائية عند وصول وصولات أو طلبات توثيق جديدة"
                >
                    <span id="audioIcon">🔊</span>
                    <span id="audioLabel">الصوت مفعّل</span>
                </button>

                <!-- Admin User & Logout -->
                <div class="flex items-center space-x-3 space-x-reverse pr-2 border-r border-white/10">
                    <div class="text-left hidden sm:block">
                        <div class="text-xs font-bold text-white leading-tight">مسؤول النظام</div>
                        <div class="text-[10px] text-slate-400 font-mono">{{ $adminUser->email ?? 'admin@pindo.dz' }}</div>
                    </div>
                    <form action="{{ route('admin.logout') }}" method="POST">
                        @csrf
                        <button type="submit" class="p-2 rounded-xl bg-red-500/10 hover:bg-red-500/20 text-red-400 border border-red-500/20 transition-all text-xs font-bold flex items-center space-x-1 space-x-reverse" title="تسجيل الخروج">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/></svg>
                            <span class="hidden md:inline">خروج</span>
                        </button>
                    </form>
                </div>
            </div>
        </div>
    </header>

    <!-- Main Container -->
    <main class="max-w-7xl mx-auto w-full p-6 flex-1 flex flex-col gap-6">

        <!-- Navigation Tabs (SPA Mode) -->
        <div class="flex flex-wrap items-center justify-between gap-3 border-b border-white/10 pb-3">
            <div class="flex flex-wrap items-center gap-2">
                <button onclick="switchTab('overview')" id="tabBtn-overview" class="tab-btn px-4 py-2.5 rounded-xl text-xs font-extrabold transition-all bg-emerald-500 text-slate-950 shadow-lg shadow-emerald-500/20">
                    📊 المؤشرات العامة والمالية
                </button>
                <button onclick="switchTab('teachers')" id="tabBtn-teachers" class="tab-btn px-4 py-2.5 rounded-xl text-xs font-extrabold transition-all bg-slate-900/80 text-slate-400 hover:text-white border border-white/5 relative">
                    👨‍🏫 توثيق وفحص الأساتذة
                    <span id="badgeTeachersCount" class="hidden mr-1.5 px-2 py-0.5 rounded-full text-[10px] font-black bg-amber-500 text-slate-950">0</span>
                </button>
                <button onclick="switchTab('subscriptions')" id="tabBtn-subscriptions" class="tab-btn px-4 py-2.5 rounded-xl text-xs font-extrabold transition-all bg-slate-900/80 text-slate-400 hover:text-white border border-white/5 relative">
                    💳 اشتراكات ووصولات بريدي موب
                    <span id="badgeSubsCount" class="hidden mr-1.5 px-2 py-0.5 rounded-full text-[10px] font-black bg-cyan-400 text-slate-950">0</span>
                </button>
                <button onclick="switchTab('sessions')" id="tabBtn-sessions" class="tab-btn px-4 py-2.5 rounded-xl text-xs font-extrabold transition-all bg-slate-900/80 text-slate-400 hover:text-white border border-white/5">
                    🎥 الحصص المباشرة والقرصنة (LiveKit DRM)
                </button>
                <button onclick="switchTab('security')" id="tabBtn-security" class="tab-btn px-4 py-2.5 rounded-xl text-xs font-extrabold transition-all bg-slate-900/80 text-slate-400 hover:text-white border border-white/5">
                    🛡️ الرقابة وبصمة الإيصالات (Anti-Fraud)
                </button>
            </div>

            <!-- Manual Refresh Action Indicator -->
            <div class="flex items-center space-x-2 space-x-reverse text-xs text-slate-400 font-mono">
                <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
                <span id="lastSyncTime">Sync: 0s ago</span>
            </div>
        </div>

        <!-- TAB 1: OVERVIEW & TELEMETRY -->
        <section id="tab-overview" class="tab-content space-y-6">
            <!-- 6 KPI Bento Cards -->
            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4">
                <!-- Total Students -->
                <div class="glass-card rounded-2xl p-4 border border-white/5 relative overflow-hidden">
                    <div class="text-xs font-bold text-slate-400 mb-1">إجمالي الطلاب</div>
                    <div id="kpiStudents" class="text-2xl font-black text-white font-mono">--</div>
                    <div class="text-[10px] text-emerald-400 mt-1 font-semibold flex items-center space-x-1 space-x-reverse">
                        <span>↑ نمو متواصل</span>
                    </div>
                </div>

                <!-- Total Teachers -->
                <div class="glass-card rounded-2xl p-4 border border-white/5 relative overflow-hidden">
                    <div class="text-xs font-bold text-slate-400 mb-1">الأساتذة المعتمدين</div>
                    <div id="kpiTeachers" class="text-2xl font-black text-emerald-400 font-mono">--</div>
                    <div class="text-[10px] text-slate-400 mt-1">
                        من أصل <span id="kpiTotalTeachers">--</span> أستاذ مسجل
                    </div>
                </div>

                <!-- Active Live Sessions -->
                <div class="glass-card rounded-2xl p-4 border border-cyan-500/20 relative overflow-hidden bg-gradient-to-b from-cyan-500/5 to-transparent">
                    <div class="text-xs font-bold text-cyan-400 mb-1 flex items-center justify-between">
                        <span>الحصص الجارية الآن</span>
                        <span class="w-2 h-2 rounded-full bg-cyan-400 animate-ping"></span>
                    </div>
                    <div id="kpiActiveSessions" class="text-2xl font-black text-white font-mono">--</div>
                    <div class="text-[10px] text-cyan-300 mt-1">WebRTC SFU Rooms</div>
                </div>

                <!-- Gross Revenue (DZD) -->
                <div class="glass-card rounded-2xl p-4 border border-white/5 relative overflow-hidden">
                    <div class="text-xs font-bold text-slate-400 mb-1">إجمالي المعاملات</div>
                    <div id="kpiGrossRevenue" class="text-2xl font-black text-white font-mono">-- دج</div>
                    <div class="text-[10px] text-slate-400 mt-1">حجم التداولات الإجمالي</div>
                </div>

                <!-- Platform Commission (Live 15% + Library 10%) -->
                <div class="glass-card rounded-2xl p-4 border border-emerald-500/30 relative overflow-hidden bg-gradient-to-b from-emerald-500/10 to-transparent">
                    <div class="text-xs font-bold text-emerald-300 mb-1">عمولة المنصة الصافية</div>
                    <div id="kpiPlatformFee" class="text-2xl font-black text-emerald-400 font-mono">-- دج</div>
                    <div class="text-[10px] text-emerald-300 mt-1">
                        مباشر: <span id="kpiLivePlatformFee">0</span> • مكتبة: <span id="kpiLibraryPlatformFee">0</span> دج
                    </div>
                </div>

                <!-- Pending Subscriptions Queue -->
                <div class="glass-card rounded-2xl p-4 border border-amber-500/30 relative overflow-hidden bg-gradient-to-b from-amber-500/10 to-transparent">
                    <div class="text-xs font-bold text-amber-300 mb-1 flex items-center justify-between">
                        <span>وصولات معلقة</span>
                        <span id="kpiPendingSubsBadge" class="w-2 h-2 rounded-full bg-amber-400 animate-pulse"></span>
                    </div>
                    <div id="kpiPendingSubs" class="text-2xl font-black text-amber-300 font-mono">--</div>
                    <div class="text-[10px] text-amber-400 mt-1">بقيمة <span id="kpiPendingSubsSum">--</span> دج</div>
                </div>
            </div>

            <!-- Quick Action Grid -->
            <div class="grid grid-cols-1 lg:grid-cols-2 gap-6">
                <!-- Action Queue 1: Recent BaridiMob Receipts Awaiting Approval -->
                <div class="glass-card rounded-3xl p-6 border border-white/10">
                    <div class="flex items-center justify-between mb-4">
                        <div class="flex items-center space-x-2 space-x-reverse">
                            <span class="w-3 h-3 rounded-full bg-cyan-400"></span>
                            <h2 class="text-sm font-black text-white">آخر وصولات بريدي موب المعلقة (تحتاج فحص)</h2>
                        </div>
                        <button onclick="switchTab('subscriptions')" class="text-xs text-cyan-400 hover:underline font-bold">
                            عرض الكل ←
                        </button>
                    </div>
                    <div id="quickSubsContainer" class="space-y-3">
                        <div class="p-4 rounded-2xl bg-slate-900/50 text-center text-xs text-slate-500">جاري فحص الوصولات اللحظية...</div>
                    </div>
                </div>

                <!-- Action Queue 2: Recent Teacher Verification Applications -->
                <div class="glass-card rounded-3xl p-6 border border-white/10">
                    <div class="flex items-center justify-between mb-4">
                        <div class="flex items-center space-x-2 space-x-reverse">
                            <span class="w-3 h-3 rounded-full bg-amber-400"></span>
                            <h2 class="text-sm font-black text-white">طلبات توثيق الأساتذة (تحتاج مراجعة الشهادة)</h2>
                        </div>
                        <button onclick="switchTab('teachers')" class="text-xs text-amber-400 hover:underline font-bold">
                            عرض الكل ←
                        </button>
                    </div>
                    <div id="quickTeachersContainer" class="space-y-3">
                        <div class="p-4 rounded-2xl bg-slate-900/50 text-center text-xs text-slate-500">جاري فحص طلبات التوثيق...</div>
                    </div>
                </div>
            </div>
        </section>

        <!-- TAB 2: TEACHER KYC & VERIFICATION -->
        <section id="tab-teachers" class="tab-content hidden space-y-4">
            <div class="glass-card rounded-3xl p-6 border border-white/10">
                <div class="flex flex-wrap items-center justify-between gap-4 mb-6 pb-4 border-b border-white/10">
                    <div>
                        <h2 class="text-base font-black text-white">قائمة الأساتذة بانتظار الاعتماد والتوثيق الأكاديمي</h2>
                        <p class="text-xs text-slate-400 mt-1">
                            فحص الشهادات الجامعية، بطاقة التعريف الوطنية، والتخصص لضمان أعلى معايير الجودة الأكاديمية.
                        </p>
                    </div>
                    <div class="flex items-center space-x-2 space-x-reverse text-xs">
                        <span class="px-3 py-1.5 rounded-xl bg-amber-500/10 text-amber-400 border border-amber-500/20 font-bold font-mono">
                            <span id="teachersPendingCountText">0</span> ملفات معلقة
                        </span>
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-right text-xs">
                        <thead>
                            <tr class="border-b border-white/10 text-slate-400 font-bold">
                                <th class="pb-3 pr-4">الأستاذ والمعرّف</th>
                                <th class="pb-3 px-3">الولاية (Bilingual)</th>
                                <th class="pb-3 px-3">المادة والطور التعليمي</th>
                                <th class="pb-3 px-3">الشهادة / الهوية (معاينة مكبرة)</th>
                                <th class="pb-3 px-3">تاريخ التقديم</th>
                                <th class="pb-3 pl-4 text-center">الإجراء الفوري</th>
                            </tr>
                        </thead>
                        <tbody id="teachersTableBody" class="divide-y divide-white/5 text-slate-200">
                            <tr>
                                <td colspan="6" class="py-8 text-center text-slate-500">جاري تحميل طلبات التوثيق...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>

        <!-- TAB 3: SUBSCRIPTIONS & BARIDIMOB -->
        <section id="tab-subscriptions" class="tab-content hidden space-y-4">
            <div class="glass-card rounded-3xl p-6 border border-white/10">
                <div class="flex flex-wrap items-center justify-between gap-4 mb-6 pb-4 border-b border-white/10">
                    <div>
                        <h2 class="text-base font-black text-white">إدارة اشتراكات بريدي موب ومكافحة تكرار الوصولات</h2>
                        <p class="text-xs text-slate-400 mt-1">
                            فحص الوصل، مطابقة رقم العملية، منع استخدام نفس الإيصال (Idempotency Hash)، والتفعيل الآلي مع تاريخ الانتهاء ends_at.
                        </p>
                    </div>
                    <div class="flex items-center space-x-2 space-x-reverse text-xs">
                        <span class="px-3 py-1.5 rounded-xl bg-cyan-400/10 text-cyan-300 border border-cyan-400/20 font-bold font-mono">
                            RIP المعتمد: 00799999004147536876
                        </span>
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-right text-xs">
                        <thead>
                            <tr class="border-b border-white/10 text-slate-400 font-bold">
                                <th class="pb-3 pr-4">رقم الطلب والتلميذ</th>
                                <th class="pb-3 px-3">المقرر / الفوج</th>
                                <th class="pb-3 px-3">المبلغ ورقم العملية</th>
                                <th class="pb-3 px-3">صورة الوصل (معاينة وتكبير)</th>
                                <th class="pb-3 px-3">فحص الاحتيال (Anti-Fraud)</th>
                                <th class="pb-3 pl-4 text-center">الإجراء</th>
                            </tr>
                        </thead>
                        <tbody id="subsTableBody" class="divide-y divide-white/5 text-slate-200">
                            <tr>
                                <td colspan="6" class="py-8 text-center text-slate-500">جاري تحميل وصولات الدفع المعلقة...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>

        <!-- TAB 4: LIVE SESSIONS & SFU MONITOR -->
        <section id="tab-sessions" class="tab-content hidden space-y-4">
            <div class="glass-card rounded-3xl p-6 border border-white/10">
                <div class="flex flex-wrap items-center justify-between gap-4 mb-6 pb-4 border-b border-white/10">
                    <div>
                        <h2 class="text-base font-black text-white">مراقبة الحصص المباشرة وغرفة العمليات اللحظية (SFU Gateway)</h2>
                        <p class="text-xs text-slate-400 mt-1">
                            متابعة غرف LiveKit النشطة، عدد الحضور، حماية الـ DRM العتادية، وزر إيقاف الطوارئ (Kill-Switch).
                        </p>
                    </div>
                </div>

                <div class="overflow-x-auto">
                    <table class="w-full text-right text-xs">
                        <thead>
                            <tr class="border-b border-white/10 text-slate-400 font-bold">
                                <th class="pb-3 pr-4">معرّف الغرفة والحصة</th>
                                <th class="pb-3 px-3">الأستاذ المؤطر</th>
                                <th class="pb-3 px-3">المادة والطور</th>
                                <th class="pb-3 px-3">الحضور المتزامن</th>
                                <th class="pb-3 px-3">حماية القرصنة (DRM)</th>
                                <th class="pb-3 pl-4 text-center">زر الطوارئ</th>
                            </tr>
                        </thead>
                        <tbody id="sessionsTableBody" class="divide-y divide-white/5 text-slate-200">
                            <tr>
                                <td colspan="6" class="py-8 text-center text-slate-500">جاري فحص الحصص المباشرة النشطة...</td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </section>

        <!-- TAB 5: SECURITY & AUDIT RADAR -->
        <section id="tab-security" class="tab-content hidden space-y-6">
            <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                <!-- System Resilience Report -->
                <div class="glass-card rounded-3xl p-6 border border-white/10 space-y-4">
                    <h3 class="text-sm font-black text-white flex items-center space-x-2 space-x-reverse">
                        <span class="w-2.5 h-2.5 rounded-full bg-emerald-400"></span>
                        <span>تقرير استقرار وتحصين المنصة (Resilience Shield)</span>
                    </h3>
                    <div class="space-y-3 text-xs">
                        <div class="p-3 rounded-xl bg-slate-900/60 border border-white/5 flex items-center justify-between">
                            <span class="text-slate-300">توافقية Reverse Proxy و SSL (Railway/Traefik)</span>
                            <span class="px-2 py-0.5 rounded bg-emerald-500/10 text-emerald-400 font-mono font-bold">TrustProxies Active</span>
                        </div>
                        <div class="p-3 rounded-xl bg-slate-900/60 border border-white/5 flex items-center justify-between">
                            <span class="text-slate-300">وحدة التخزين العامة للوثائق (Storage Link)</span>
                            <span class="px-2 py-0.5 rounded bg-emerald-500/10 text-emerald-400 font-mono font-bold">Symlink Operational</span>
                        </div>
                        <div class="p-3 rounded-xl bg-slate-900/60 border border-white/5 flex items-center justify-between">
                            <span class="text-slate-300">نظام منع حجز المقاعد المزدوج (Atomic Seat Locking)</span>
                            <span class="px-2 py-0.5 rounded bg-emerald-500/10 text-emerald-400 font-mono font-bold">Pessimistic Lock Enabled</span>
                        </div>
                        <div class="p-3 rounded-xl bg-slate-900/60 border border-white/5 flex items-center justify-between">
                            <span class="text-slate-300">إنهاء الاشتراكات المنتهية تلقائياً (Auto-Expiry ends_at)</span>
                            <span class="px-2 py-0.5 rounded bg-cyan-400/10 text-cyan-300 font-mono font-bold">Dynamic Middleware Scope</span>
                        </div>
                        <div class="p-3 rounded-xl bg-slate-900/60 border border-white/5 flex items-center justify-between">
                            <span class="text-slate-300">مكافحة تكرار وصولات بريدي موب (Idempotency Hash)</span>
                            <span class="px-2 py-0.5 rounded bg-amber-500/10 text-amber-400 font-mono font-bold">SHA-256 Deduplication</span>
                        </div>
                    </div>
                </div>

                <!-- Live Command Trigger -->
                <div class="glass-card rounded-3xl p-6 border border-white/10 space-y-4">
                    <h3 class="text-sm font-black text-white flex items-center space-x-2 space-x-reverse">
                        <span class="w-2.5 h-2.5 rounded-full bg-cyan-400"></span>
                        <span>أدوات الصيانة الدورية المباشرة</span>
                    </h3>
                    <p class="text-xs text-slate-400 leading-relaxed">
                        يمكنك تنفيذ أوامر التدقيق الدوري للاشتراكات المنتهية ومزامنة عدادات الأفواج دون انقطاع الخدمة:
                    </p>
                    <div class="space-y-3">
                        <div class="p-4 rounded-2xl bg-slate-900/80 border border-white/5">
                            <div class="text-xs font-bold text-white mb-1">أمر تدقيق الاشتراكات (Artisan Expiry Audit)</div>
                            <code class="text-[11px] font-mono text-emerald-400 block p-2 rounded bg-black/50">php artisan pindo:expire-subscriptions</code>
                        </div>
                        <div class="p-4 rounded-2xl bg-slate-900/80 border border-white/5">
                            <div class="text-xs font-bold text-white mb-1">المطابقة ثنائية اللغة للولايات (Bilingual Wilaya Matcher)</div>
                            <span class="text-[11px] text-slate-400">مفعل تلقائياً لـ 58 ولاية (Adrar ↔ أدرار, Alger ↔ الجزائر, Constantine ↔ قسنطينة).</span>
                        </div>
                    </div>
                </div>
            </div>
        </section>

    </main>

    <!-- INTERACTIVE LIGHTBOX MODAL (Image Zoom & Inspection) -->
    <div id="lightboxModal" class="fixed inset-0 z-50 hidden flex items-center justify-center p-4 bg-black/85 backdrop-blur-md">
        <div class="glass-modal rounded-3xl max-w-3xl w-full p-6 relative overflow-hidden shadow-2xl flex flex-col max-h-[90vh]">
            <div class="flex items-center justify-between pb-3 border-b border-white/10 mb-4">
                <div>
                    <h3 id="lightboxTitle" class="text-sm font-black text-white">معاينة الوثيقة الرسمية بدقة كاملة</h3>
                    <p id="lightboxSubtitle" class="text-[11px] text-slate-400">انقر للتكبير وفحص التفاصيل</p>
                </div>
                <div class="flex items-center space-x-2 space-x-reverse">
                    <a id="lightboxDownloadBtn" href="#" target="_blank" class="px-3 py-1.5 rounded-xl bg-white/10 hover:bg-white/20 text-xs text-white font-semibold flex items-center space-x-1 space-x-reverse">
                        <svg class="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/></svg>
                        <span>فتح الرابط الأصلي</span>
                    </a>
                    <button onclick="closeLightbox()" class="p-1.5 rounded-xl bg-white/10 hover:bg-white/20 text-slate-300">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"/></svg>
                    </button>
                </div>
            </div>
            <div class="flex-1 overflow-auto flex items-center justify-center p-2 bg-slate-950/60 rounded-2xl min-h-[300px]">
                <img id="lightboxImg" src="" alt="Document Preview" class="max-h-[65vh] w-auto rounded-lg shadow-lg object-contain transition-transform duration-300 cursor-zoom-in" onclick="toggleZoom(this)">
            </div>
        </div>
    </div>

    <!-- REJECTION REASON MODAL (Structured Reject with Notification) -->
    <div id="rejectionModal" class="fixed inset-0 z-50 hidden flex items-center justify-center p-4 bg-black/80 backdrop-blur-sm">
        <div class="glass-modal rounded-3xl max-w-md w-full p-6 shadow-2xl space-y-4">
            <div class="flex items-center justify-between pb-3 border-b border-white/10">
                <h3 id="rejectionModalTitle" class="text-sm font-black text-red-400">إدخال سبب الرفض المسبب والإشعار</h3>
                <button onclick="closeRejectionModal()" class="text-slate-400 hover:text-white">✕</button>
            </div>
            <p class="text-xs text-slate-300 leading-relaxed">
                حدد سبب الرفض. سيتم إرسال هذا السبب كإشعار فوري وتوجيه للتلميذ أو الأستاذ لتصحيحه:
            </p>

            <!-- Quick Template Options -->
            <div class="space-y-2">
                <label class="block text-[11px] font-bold text-slate-400">أسباب نموذجية شائعة:</label>
                <div class="grid grid-cols-1 gap-1.5 text-xs">
                    <button type="button" onclick="setRejectionReason('صورة الوصل أو الشهادة غير واضحة أو تالفة، يرجى إعادة الرفع بدقة واضحة.')" class="p-2 rounded-lg bg-slate-900 hover:bg-slate-800 text-right text-slate-300 border border-white/5 text-[11px]">
                        • صورة الوصل أو الشهادة غير واضحة
                    </button>
                    <button type="button" onclick="setRejectionReason('رقم العملية البريدي (Tx Reference) غير مطابق للمبلغ أو تم استخدامه مسبقاً.')" class="p-2 rounded-lg bg-slate-900 hover:bg-slate-800 text-right text-slate-300 border border-white/5 text-[11px]">
                        • رقم العملية غير مطابق أو مستخدم مسبقاً
                    </button>
                    <button type="button" onclick="setRejectionReason('الشهادة الجامعية المرفقة لا تتوافق مع التخصص والمادة المختارة للتدريس.')" class="p-2 rounded-lg bg-slate-900 hover:bg-slate-800 text-right text-slate-300 border border-white/5 text-[11px]">
                        • الشهادة لا تطابق مادة التدريس
                    </button>
                </div>
            </div>

            <div>
                <label class="block text-xs font-bold text-slate-300 mb-1" for="customRejectionReason">نص السبب المخصص:</label>
                <textarea id="customRejectionReason" rows="3" class="w-full p-3 rounded-xl bg-slate-900 border border-white/10 text-white text-xs focus:ring-2 focus:ring-red-500 focus:outline-none placeholder-slate-500" placeholder="اكتب التفاصيل المطلوبة لتصحيح الملف..."></textarea>
            </div>

            <div class="flex items-center space-x-2 space-x-reverse pt-2">
                <button id="confirmRejectionBtn" onclick="submitRejection()" class="flex-1 py-2.5 rounded-xl bg-red-600 hover:bg-red-500 text-white font-black text-xs transition-all shadow-lg shadow-red-600/30">
                    تأكيد الرفض وإرسال التنبيه
                </button>
                <button onclick="closeRejectionModal()" class="px-4 py-2.5 rounded-xl bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs font-semibold">
                    إلغاء
                </button>
            </div>
        </div>
    </div>

    <!-- NOTIFICATION TOAST -->
    <div id="toast" class="fixed bottom-6 left-6 z-50 hidden max-w-sm px-4 py-3 rounded-2xl shadow-2xl text-xs font-bold transition-all transform translate-y-2 border"></div>

    <!-- CORE TELEMETRY JAVASCRIPT & AUDIO ENGINE -->
    <script>
        // State variables
        let audioAlertsEnabled = true;
        let lastKnownPendingTeachersCount = 0;
        let lastKnownPendingSubsCount = 0;
        let audioCtx = null;
        let lastSyncSeconds = 0;
        let activeRejectionTarget = null; // { type: 'teacher'|'subscription', id: number }

        // Initialize Audio Context on user interaction (resolves autoplay restrictions)
        function initAudio() {
            if (!audioCtx) {
                const AudioContext = window.AudioContext || window.webkitAudioContext;
                if (AudioContext) {
                    audioCtx = new AudioContext();
                }
            }
        }

        // Web Audio API Dual-Tone Chime Generator (No external MP3 needed!)
        function playChimeAlert() {
            if (!audioAlertsEnabled) return;
            try {
                initAudio();
                if (!audioCtx) return;
                if (audioCtx.state === 'suspended') {
                    audioCtx.resume();
                }

                const now = audioCtx.currentTime;
                // Tone 1: 587.33 Hz (D5)
                const osc1 = audioCtx.createOscillator();
                const gain1 = audioCtx.createGain();
                osc1.type = 'sine';
                osc1.frequency.setValueAtTime(587.33, now);
                gain1.gain.setValueAtTime(0.15, now);
                gain1.gain.exponentialRampToValueAtTime(0.001, now + 0.4);
                osc1.connect(gain1);
                gain1.connect(audioCtx.destination);
                osc1.start(now);
                osc1.stop(now + 0.4);

                // Tone 2: 880 Hz (A5)
                const osc2 = audioCtx.createOscillator();
                const gain2 = audioCtx.createGain();
                osc2.type = 'sine';
                osc2.frequency.setValueAtTime(880, now + 0.15);
                gain2.gain.setValueAtTime(0.2, now + 0.15);
                gain2.gain.exponentialRampToValueAtTime(0.001, now + 0.7);
                osc2.connect(gain2);
                gain2.connect(audioCtx.destination);
                osc2.start(now + 0.15);
                osc2.stop(now + 0.7);
            } catch (err) {
                console.warn('Audio alert error:', err);
            }
        }

        function toggleAudioAlerts() {
            initAudio();
            audioAlertsEnabled = !audioAlertsEnabled;
            const icon = document.getElementById('audioIcon');
            const label = document.getElementById('audioLabel');
            if (audioAlertsEnabled) {
                icon.textContent = '🔊';
                label.textContent = 'الصوت مفعّل';
                playChimeAlert();
                showToast('تم تفعيل التنبيهات الصوتية لغرفة العمليات', 'success');
            } else {
                icon.textContent = '🔇';
                label.textContent = 'الصوت مكتوم';
                showToast('تم كتم التنبيهات الصوتية', 'info');
            }
        }

        // Clock Update
        function updateClock() {
            const now = new Date();
            document.getElementById('liveClock').textContent = now.toLocaleTimeString('fr-DZ', { hour12: false });
            lastSyncSeconds++;
            document.getElementById('lastSyncTime').textContent = `Sync: ${lastSyncSeconds}s ago`;
        }
        setInterval(updateClock, 1000);

        // Tab Switching (SPA)
        function switchTab(tabName) {
            initAudio();
            document.querySelectorAll('.tab-content').forEach(el => el.classList.add('hidden'));
            document.querySelectorAll('.tab-btn').forEach(btn => {
                btn.classList.remove('bg-emerald-500', 'text-slate-950', 'shadow-lg', 'shadow-emerald-500/20');
                btn.classList.add('bg-slate-900/80', 'text-slate-400');
            });

            const targetTab = document.getElementById(`tab-${tabName}`);
            const targetBtn = document.getElementById(`tabBtn-${tabName}`);
            if (targetTab && targetBtn) {
                targetTab.classList.remove('hidden');
                targetBtn.classList.remove('bg-slate-900/80', 'text-slate-400');
                targetBtn.classList.add('bg-emerald-500', 'text-slate-950', 'shadow-lg', 'shadow-emerald-500/20');
            }
        }

        // Live Polling Engine (3.5 Seconds)
        async function fetchTelemetry() {
            try {
                const res = await fetch('{{ route("admin.api.telemetry") }}');
                if (!res.ok) throw new Error('Telemetry fetch failed');
                const data = await res.json();
                lastSyncSeconds = 0;

                // 1. Update KPIs
                const kpis = data.kpis;
                document.getElementById('kpiStudents').textContent = kpis.total_students;
                document.getElementById('kpiTeachers').textContent = kpis.verified_teachers;
                document.getElementById('kpiTotalTeachers').textContent = kpis.total_teachers;
                document.getElementById('kpiActiveSessions').textContent = kpis.active_sessions_count;
                document.getElementById('kpiGrossRevenue').textContent = Number(kpis.gross_revenue).toLocaleString('fr-DZ') + ' دج';
                document.getElementById('kpiPlatformFee').textContent = Number(kpis.platform_fee).toLocaleString('fr-DZ') + ' دج';
                const liveFeeEl = document.getElementById('kpiLivePlatformFee');
                const libFeeEl = document.getElementById('kpiLibraryPlatformFee');
                if (liveFeeEl) liveFeeEl.textContent = Number(kpis.live_platform_fee || 0).toLocaleString('fr-DZ');
                if (libFeeEl) libFeeEl.textContent = Number(kpis.library_platform_fee || 0).toLocaleString('fr-DZ');
                document.getElementById('kpiPendingSubs').textContent = kpis.pending_subscriptions_count;
                document.getElementById('kpiPendingSubsSum').textContent = Number(kpis.pending_subscriptions_sum).toLocaleString('fr-DZ');

                // 2. Chime Trigger on New Arrivals
                if (kpis.pending_teachers_count > lastKnownPendingTeachersCount || kpis.pending_subscriptions_count > lastKnownPendingSubsCount) {
                    playChimeAlert();
                }
                lastKnownPendingTeachersCount = kpis.pending_teachers_count;
                lastKnownPendingSubsCount = kpis.pending_subscriptions_count;

                // 3. Update Badges
                const badgeTeachers = document.getElementById('badgeTeachersCount');
                if (kpis.pending_teachers_count > 0) {
                    badgeTeachers.textContent = kpis.pending_teachers_count;
                    badgeTeachers.classList.remove('hidden');
                } else {
                    badgeTeachers.classList.add('hidden');
                }
                document.getElementById('teachersPendingCountText').textContent = kpis.pending_teachers_count;

                const badgeSubs = document.getElementById('badgeSubsCount');
                if (kpis.pending_subscriptions_count > 0) {
                    badgeSubs.textContent = kpis.pending_subscriptions_count;
                    badgeSubs.classList.remove('hidden');
                } else {
                    badgeSubs.classList.add('hidden');
                }

                // 4. Render Tables & Queues
                renderTeachers(data.pending_teachers);
                renderSubscriptions(data.pending_subscriptions);
                renderSessions(data.active_sessions);

            } catch (err) {
                console.error('Telemetry error:', err);
            }
        }

        // Render Teachers Table & Quick Queue
        function renderTeachers(teachers) {
            const tableBody = document.getElementById('teachersTableBody');
            const quickContainer = document.getElementById('quickTeachersContainer');

            if (!teachers || teachers.length === 0) {
                tableBody.innerHTML = `<tr><td colspan="6" class="py-8 text-center text-slate-500">لا توجد طلبات توثيق معلقة حالياً. جميع الأساتذة معتمدين ✅</td></tr>`;
                quickContainer.innerHTML = `<div class="p-4 rounded-2xl bg-slate-900/50 text-center text-xs text-slate-500">لا توجد طلبات توثيق معلقة ✅</div>`;
                return;
            }

            // Table Rows
            tableBody.innerHTML = teachers.map(t => `
                <tr class="hover:bg-white/5 transition-colors">
                    <td class="py-3.5 pr-4">
                        <div class="font-bold text-white text-xs">${t.name}</div>
                        <div class="text-[11px] text-slate-400 font-mono">${t.teacher_id} • ${t.email}</div>
                        ${t.phone ? `<a href="tel:${t.phone}" class="inline-flex items-center gap-1 mt-1 px-2 py-0.5 rounded-lg bg-emerald-500/10 border border-emerald-500/20 text-[10px] font-mono text-emerald-300 hover:bg-emerald-500/20" dir="ltr">📞 ${t.phone}</a>` : ''}
                    </td>
                    <td class="py-3.5 px-3">
                        <div class="font-semibold text-slate-200">${t.wilaya_ar}</div>
                        <div class="text-[10px] text-slate-400 font-mono">${t.wilaya_fr}</div>
                    </td>
                    <td class="py-3.5 px-3">
                        <div class="text-emerald-400 font-semibold">${t.subjects}</div>
                        <div class="text-[10px] text-slate-400">${t.academic_phase}</div>
                    </td>
                    <td class="py-3.5 px-3">
                        ${t.document_url
                            ? `<button onclick="openLightbox('${t.document_url}', 'شهادة الأستاذ: ${t.name}', '${t.subjects} - ${t.wilaya_ar}')" class="flex items-center space-x-2 space-x-reverse p-1 rounded-xl bg-slate-900 hover:bg-slate-800 border border-white/10 transition-all">
                                <img src="${t.document_url}" alt="Diploma" class="w-8 h-8 rounded-lg object-cover">
                                <span class="text-[11px] text-cyan-400 underline font-semibold pl-2">معاينة وتكبير 🔍</span>
                               </button>`
                            : `<span class="px-2.5 py-1 rounded-lg bg-slate-900/70 border border-white/5 text-[11px] text-slate-500">لم تُرفع وثيقة مصوّرة</span>`
                        }
                    </td>
                    <td class="py-3.5 px-3 font-mono text-[11px] text-slate-400">
                        ${t.created_at_human}
                    </td>
                    <td class="py-3.5 pl-4 text-center">
                        <div class="inline-flex items-center space-x-1.5 space-x-reverse">
                            <button onclick="approveTeacher(${t.id})" class="px-3 py-1.5 rounded-xl bg-emerald-500 hover:bg-emerald-400 text-slate-950 font-black text-[11px] shadow-sm transition-all">
                                ✓ اعتماد
                            </button>
                            <button onclick="openRejectionModal('teacher', ${t.id}, '${t.name}')" class="px-3 py-1.5 rounded-xl bg-red-500/15 hover:bg-red-500/25 text-red-400 border border-red-500/20 font-bold text-[11px] transition-all">
                                ✕ رفض مسبب
                            </button>
                        </div>
                    </td>
                </tr>
            `).join('');

            // Quick Overview List
            quickContainer.innerHTML = teachers.slice(0, 3).map(t => `
                <div class="p-3 rounded-2xl bg-slate-900/60 border border-white/5 flex items-center justify-between">
                    <div>
                        <div class="text-xs font-bold text-white">${t.name}</div>
                        <div class="text-[10px] text-slate-400">${t.subjects} • ${t.wilaya_ar}</div>
                    </div>
                    <button onclick="approveTeacher(${t.id})" class="px-3 py-1 rounded-lg bg-emerald-500 text-slate-950 text-[11px] font-extrabold hover:bg-emerald-400 transition-all">
                        اعتماد فوري
                    </button>
                </div>
            `).join('');
        }

        // Render Subscriptions Table & Quick Queue
        function renderSubscriptions(subs) {
            const tableBody = document.getElementById('subsTableBody');
            const quickContainer = document.getElementById('quickSubsContainer');

            if (!subs || subs.length === 0) {
                tableBody.innerHTML = `<tr><td colspan="6" class="py-8 text-center text-slate-500">لا توجد وصولات بريدي موب معلقة. كافة الاشتراكات مفعلة ✅</td></tr>`;
                quickContainer.innerHTML = `<div class="p-4 rounded-2xl bg-slate-900/50 text-center text-xs text-slate-500">لا توجد وصولات معلقة ✅</div>`;
                return;
            }

            tableBody.innerHTML = subs.map(s => `
                <tr class="hover:bg-white/5 transition-colors">
                    <td class="py-3.5 pr-4">
                        <div class="font-bold text-white text-xs">${s.student_name}</div>
                        <div class="text-[11px] text-slate-400 font-mono">${s.order_number}</div>
                        ${s.student_phone ? `<a href="tel:${s.student_phone}" class="inline-flex items-center gap-1 mt-1 px-2 py-0.5 rounded-lg bg-cyan-500/10 border border-cyan-500/20 text-[10px] font-mono text-cyan-300 hover:bg-cyan-500/20" dir="ltr">📞 ${s.student_phone}</a>` : ''}
                    </td>
                    <td class="py-3.5 px-3">
                        <div class="text-slate-200 font-semibold">${s.course_title}</div>
                        <div class="text-[10px] text-slate-400 font-mono">${s.submitted_at_human}</div>
                    </td>
                    <td class="py-3.5 px-3 font-mono">
                        <div class="text-emerald-400 font-extrabold text-xs">${Number(s.amount).toLocaleString('fr-DZ')} ${s.currency}</div>
                        <div class="text-[10px] text-slate-400">Tx: ${s.tx_reference}</div>
                    </td>
                    <td class="py-3.5 px-3">
                        ${s.receipt_image
                            ? `<button onclick="openLightbox('${s.receipt_image}', 'وصل بريدي موب - ${s.order_number}', 'المبلغ: ${s.amount} دج • التلميذ: ${s.student_name}')" class="flex items-center space-x-2 space-x-reverse p-1 rounded-xl bg-slate-900 hover:bg-slate-800 border border-white/10 transition-all">
                                <img src="${s.receipt_image}" alt="Receipt" class="w-8 h-8 rounded-lg object-cover">
                                <span class="text-[11px] text-cyan-300 underline font-semibold pl-2">معاينة الإيصال 📄</span>
                               </button>`
                            : `<span class="px-2.5 py-1 rounded-lg bg-slate-900/70 border border-white/5 text-[11px] text-slate-500">لا توجد صورة مرفقة</span>`
                        }
                    </td>
                    <td class="py-3.5 px-3">
                        ${s.is_fraud_suspect 
                            ? `<span class="px-2 py-0.5 rounded-full text-[10px] font-black bg-red-500/20 text-red-400 border border-red-500/30">⚠️ اشتباه تكرار الإيصال!</span>`
                            : `<span class="px-2 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">✓ بصمة إيصال فريدة</span>`
                        }
                    </td>
                    <td class="py-3.5 pl-4 text-center">
                        <div class="inline-flex items-center space-x-1.5 space-x-reverse">
                            <button onclick="approveSubscription(${s.id})" class="px-3 py-1.5 rounded-xl bg-cyan-400 hover:bg-cyan-300 text-slate-950 font-black text-[11px] shadow-sm transition-all">
                                ✓ تفعيل الاشتراك
                            </button>
                            <button onclick="openRejectionModal('subscription', ${s.id}, '${s.order_number}')" class="px-3 py-1.5 rounded-xl bg-red-500/15 hover:bg-red-500/25 text-red-400 border border-red-500/20 font-bold text-[11px] transition-all">
                                ✕ رفض الوصل
                            </button>
                        </div>
                    </td>
                </tr>
            `).join('');

            // Quick Overview List
            quickContainer.innerHTML = subs.slice(0, 3).map(s => `
                <div class="p-3 rounded-2xl bg-slate-900/60 border border-white/5 flex items-center justify-between">
                    <div>
                        <div class="text-xs font-bold text-white">${s.student_name} (${Number(s.amount).toLocaleString('fr-DZ')} دج)</div>
                        <div class="text-[10px] text-slate-400">${s.course_title}</div>
                    </div>
                    <button onclick="approveSubscription(${s.id})" class="px-3 py-1 rounded-lg bg-cyan-400 text-slate-950 text-[11px] font-extrabold hover:bg-cyan-300 transition-all">
                        تفعيل فوري
                    </button>
                </div>
            `).join('');
        }

        // Render Sessions Table
        function renderSessions(sessions) {
            const tableBody = document.getElementById('sessionsTableBody');
            if (!sessions || sessions.length === 0) {
                tableBody.innerHTML = `<tr><td colspan="6" class="py-8 text-center text-slate-500">لا توجد حصص بث مباشر نشطة حالياً.</td></tr>`;
                return;
            }

            tableBody.innerHTML = sessions.map(s => `
                <tr class="hover:bg-white/5 transition-colors">
                    <td class="py-3.5 pr-4">
                        <div class="font-bold text-white text-xs">${s.title}</div>
                        <div class="text-[10px] text-slate-400 font-mono">${s.session_uuid}</div>
                    </td>
                    <td class="py-3.5 px-3 font-semibold text-slate-200">
                        ${s.teacher_name}
                    </td>
                    <td class="py-3.5 px-3 text-cyan-400 font-semibold">
                        ${s.subject}
                    </td>
                    <td class="py-3.5 px-3 font-mono font-bold text-emerald-400">
                        ${s.student_count} تلميذ حاضر
                    </td>
                    <td class="py-3.5 px-3">
                        <span class="px-2 py-0.5 rounded text-[10px] font-bold bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
                            🔒 FLAG_SECURE Active
                        </span>
                    </td>
                    <td class="py-3.5 pl-4 text-center">
                        <button onclick="terminateSession(${s.id})" class="px-3 py-1.5 rounded-xl bg-red-600/20 hover:bg-red-600 text-red-400 hover:text-white border border-red-500/30 font-bold text-[11px] transition-all">
                            ⚠️ إنهاء فوري (Kill-Switch)
                        </button>
                    </td>
                </tr>
            `).join('');
        }

        // Actions: Approve Teacher
        async function approveTeacher(id) {
            initAudio();
            try {
                const res = await fetch(`/admin/api/teachers/${id}/approve`, {
                    method: 'POST',
                    headers: { 'X-CSRF-TOKEN': '{{ csrf_token() }}' }
                });
                const data = await res.json();
                showToast(data.message || 'تم اعتماد وتوثيق الأستاذ بنجاح', 'success');
                fetchTelemetry();
            } catch (err) {
                showToast('فشل تنفيذ العملية', 'error');
            }
        }

        // Actions: Approve Subscription
        async function approveSubscription(id) {
            initAudio();
            try {
                const res = await fetch(`/admin/api/subscriptions/${id}/approve`, {
                    method: 'POST',
                    headers: { 'X-CSRF-TOKEN': '{{ csrf_token() }}' }
                });
                const data = await res.json();
                showToast(data.message || 'تم تأكيد الوصل وتفعيل الاشتراك بنجاح', 'success');
                fetchTelemetry();
            } catch (err) {
                showToast('فشل تفعيل الاشتراك', 'error');
            }
        }

        // Actions: Terminate Live Session
        async function terminateSession(id) {
            if (!confirm('هل أنت متأكد من رغبتك في إيقاف هذه الحصة المباشرة فوراً وقطع اتصال جميع الطلاب والأستاذ؟')) return;
            try {
                const res = await fetch(`/admin/api/sessions/${id}/terminate`, {
                    method: 'POST',
                    headers: { 'X-CSRF-TOKEN': '{{ csrf_token() }}' }
                });
                const data = await res.json();
                showToast(data.message || 'تم إيقاف الحصة عبر زر الطوارئ', 'warning');
                fetchTelemetry();
            } catch (err) {
                showToast('فشل إيقاف الحصة', 'error');
            }
        }

        // Rejection Modal Handlers
        function openRejectionModal(type, id, label) {
            activeRejectionTarget = { type, id };
            const title = document.getElementById('rejectionModalTitle');
            title.textContent = type === 'teacher' ? `رفض ملف الأستاذ: ${label}` : `رفض وصل الدفع: ${label}`;
            document.getElementById('customRejectionReason').value = '';
            document.getElementById('rejectionModal').classList.remove('hidden');
        }

        function closeRejectionModal() {
            document.getElementById('rejectionModal').classList.add('hidden');
            activeRejectionTarget = null;
        }

        function setRejectionReason(text) {
            document.getElementById('customRejectionReason').value = text;
        }

        async function submitRejection() {
            if (!activeRejectionTarget) return;
            const reason = document.getElementById('customRejectionReason').value.trim();
            if (reason.length < 5) {
                alert('يرجى إدخال سبب واضح ومفصل (5 أحرف على الأقل)');
                return;
            }

            const { type, id } = activeRejectionTarget;
            const endpoint = type === 'teacher' ? `/admin/api/teachers/${id}/reject` : `/admin/api/subscriptions/${id}/reject`;

            try {
                const res = await fetch(endpoint, {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': '{{ csrf_token() }}'
                    },
                    body: JSON.stringify({ reason })
                });
                const data = await res.json();
                closeRejectionModal();
                showToast(data.message || 'تم الرفض وإرسال الإشعار', 'warning');
                fetchTelemetry();
            } catch (err) {
                showToast('فشل تسجيل الرفض', 'error');
            }
        }

        // Lightbox Functions
        let isZoomed = false;
        function openLightbox(url, title, subtitle) {
            document.getElementById('lightboxImg').src = url;
            document.getElementById('lightboxTitle').textContent = title;
            document.getElementById('lightboxSubtitle').textContent = subtitle;
            document.getElementById('lightboxDownloadBtn').href = url;
            isZoomed = false;
            document.getElementById('lightboxImg').style.transform = 'scale(1)';
            document.getElementById('lightboxModal').classList.remove('hidden');
        }

        function closeLightbox() {
            document.getElementById('lightboxModal').classList.add('hidden');
        }

        function toggleZoom(img) {
            isZoomed = !isZoomed;
            img.style.transform = isZoomed ? 'scale(1.8)' : 'scale(1)';
            img.style.cursor = isZoomed ? 'zoom-out' : 'zoom-in';
        }

        // Toast Messages
        function showToast(msg, type = 'success') {
            const toast = document.getElementById('toast');
            toast.textContent = msg;
            toast.className = 'fixed bottom-6 left-6 z-50 px-4 py-3 rounded-2xl shadow-2xl text-xs font-bold transition-all border';
            if (type === 'success') {
                toast.classList.add('bg-emerald-950', 'text-emerald-300', 'border-emerald-500/40');
            } else if (type === 'warning') {
                toast.classList.add('bg-amber-950', 'text-amber-300', 'border-amber-500/40');
            } else {
                toast.classList.add('bg-red-950', 'text-red-300', 'border-red-500/40');
            }
            toast.classList.remove('hidden', 'translate-y-2');
            setTimeout(() => {
                toast.classList.add('hidden');
            }, 3500);
        }

        // Start Telemetry Polling on Boot
        fetchTelemetry();
        setInterval(fetchTelemetry, 3500);

        // Click outside modals to close
        window.onclick = function(e) {
            const lb = document.getElementById('lightboxModal');
            if (e.target === lb) closeLightbox();
            const rm = document.getElementById('rejectionModal');
            if (e.target === rm) closeRejectionModal();
        }
    </script>
</body>
</html>
