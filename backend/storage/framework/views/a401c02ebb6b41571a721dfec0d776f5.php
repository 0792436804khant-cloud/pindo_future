<!DOCTYPE html>
<html lang="ar" dir="rtl" class="scroll-smooth">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Pindo Future | مستقبل التعليم في الجزائر — Future Generation of Education DZ</title>
    <meta name="description" content="بيندو فيوتشر (Pindo Future) — المنظومة التعليمية الجزائرية المتكاملة لبث الدروس المباشرة بتقنية WebRTC والسبورة الذكية وبنك امتحانات BEM/BAC وحماية DRM ومراقبة الأولياء.">
    <meta name="theme-color" content="#070B14">
    <link rel="icon" type="image/png" href="/images/pindo_logo_badge.png">
    <link rel="apple-touch-icon" href="/images/pindo_logo_badge.png">

    <script src="https://cdn.tailwindcss.com"></script>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Cairo:wght@400;600;700;800;900&family=Plus+Jakarta+Sans:wght@500;700;800&family=JetBrains+Mono:wght@500;700&display=swap" rel="stylesheet">

    <script>
        tailwind.config = {
            theme: {
                extend: {
                    fontFamily: {
                        arabic: ['Cairo', 'sans-serif'],
                        sans: ['Cairo', 'Plus Jakarta Sans', 'sans-serif'],
                        mono: ['JetBrains Mono', 'monospace'],
                    },
                    colors: {
                        cosmic: {
                            950: '#050814',
                            900: '#070B14',
                            850: '#0B1120',
                            800: '#0F172A',
                        }
                    }
                }
            }
        }
    </script>

    <style>
        body {
            background-color: #050814;
            color: #F8FAFC;
            font-family: 'Cairo', 'Plus Jakarta Sans', sans-serif;
            overflow-x: hidden;
        }
        .glass-nav {
            background: rgba(5, 8, 20, 0.80);
            backdrop-filter: blur(20px);
            -webkit-backdrop-filter: blur(20px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        }
        .glass-card {
            background: linear-gradient(145deg, rgba(15, 23, 42, 0.78), rgba(9, 13, 28, 0.92));
            backdrop-filter: blur(18px);
            -webkit-backdrop-filter: blur(18px);
            border: 1px solid rgba(255, 255, 255, 0.09);
            transition: transform 0.25s ease, border-color 0.25s ease, box-shadow 0.25s ease;
        }
        .glass-card:hover {
            border-color: rgba(34, 211, 238, 0.35);
            box-shadow: 0 18px 45px -15px rgba(34, 211, 238, 0.16);
        }
        .hero-mesh {
            background-image:
                radial-gradient(circle at 18% 20%, rgba(124, 58, 237, 0.22), transparent 42%),
                radial-gradient(circle at 82% 18%, rgba(6, 182, 212, 0.20), transparent 40%),
                radial-gradient(circle at 50% 80%, rgba(16, 185, 129, 0.12), transparent 45%);
        }
        .grid-pattern {
            background-size: 48px 48px;
            background-image:
                linear-gradient(to right, rgba(255, 255, 255, 0.03) 1px, transparent 1px),
                linear-gradient(to bottom, rgba(255, 255, 255, 0.03) 1px, transparent 1px);
        }
        .gradient-text {
            background: linear-gradient(120deg, #FFFFFF 0%, #22D3EE 45%, #A78BFA 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
        }
        .pulse-dot {
            box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7);
            animation: pulseDot 2s infinite;
        }
        @keyframes pulseDot {
            0% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.7); }
            70% { box-shadow: 0 0 0 9px rgba(16, 185, 129, 0); }
            100% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
        }
        @keyframes floatSlow {
            0%, 100% { transform: translateY(0px); }
            50% { transform: translateY(-8px); }
        }
        .float-slow {
            animation: floatSlow 5s ease-in-out infinite;
        }
    </style>
</head>
<body class="antialiased selection:bg-cyan-400 selection:text-slate-950">

    <!-- 1. Sticky Glassmorphic Navigation -->
    <header class="glass-nav sticky top-0 z-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex items-center justify-between h-18 py-3 gap-4">
                <!-- Brand -->
                <a href="/" class="flex items-center gap-3 shrink-0 group">
                    <img src="/images/pindo_logo_badge.png" alt="Pindo Future" class="w-11 h-11 rounded-2xl shadow-lg shadow-cyan-500/20 border border-white/15 group-hover:scale-105 transition-transform">
                    <div>
                        <div class="flex items-center gap-2">
                            <span class="font-black text-lg tracking-tight text-white">Pindo <span class="text-cyan-400">Future</span></span>
                            <span class="hidden sm:inline-flex px-2 py-0.5 text-[10px] font-extrabold rounded-full bg-cyan-500/15 text-cyan-300 border border-cyan-400/25">DZ</span>
                        </div>
                        <p class="text-[11px] font-bold text-slate-400" data-i18n="brand_sub">مستقبل التعليم في الجزائر</p>
                    </div>
                </a>

                <!-- Desktop Navigation Links -->
                <nav class="hidden lg:flex items-center gap-7 text-xs font-bold text-slate-300">
                    <a href="#features" class="hover:text-cyan-300 transition-colors" data-i18n="nav_features">المميزات</a>
                    <a href="#roles" class="hover:text-cyan-300 transition-colors" data-i18n="nav_roles">التلميذ • الأستاذ • الولي</a>
                    <a href="#security" class="hover:text-cyan-300 transition-colors" data-i18n="nav_security">الحماية والبث</a>
                    <a href="#payments" class="hover:text-cyan-300 transition-colors" data-i18n="nav_payments">الدفع الجزائري</a>
                    <a href="#exams" class="hover:text-cyan-300 transition-colors" data-i18n="nav_exams">بنك BEM &amp; BAC</a>
                    <a href="#download" class="hover:text-cyan-300 transition-colors" data-i18n="nav_download">التحميل</a>
                    <a href="#faq" class="hover:text-cyan-300 transition-colors" data-i18n="nav_faq">الأسئلة الشائعة</a>
                </nav>

                <!-- Right Actions: Language Switcher & Launch App -->
                <div class="flex items-center gap-2.5">
                    <!-- Language Switcher -->
                    <div class="flex items-center bg-slate-900/90 border border-white/10 rounded-xl p-1 text-[11px] font-extrabold">
                        <button onclick="setSiteLang('ar')" id="lang-ar" class="px-2 py-1 rounded-lg bg-cyan-500 text-slate-950 transition-all">AR</button>
                        <button onclick="setSiteLang('en')" id="lang-en" class="px-2 py-1 rounded-lg text-slate-400 hover:text-white transition-all">EN</button>
                        <button onclick="setSiteLang('fr')" id="lang-fr" class="px-2 py-1 rounded-lg text-slate-400 hover:text-white transition-all">FR</button>
                    </div>

                    <a href="/app/" class="px-4 py-2.5 rounded-xl bg-gradient-to-r from-cyan-400 via-teal-400 to-emerald-400 hover:brightness-110 text-slate-950 font-black text-xs shadow-lg shadow-cyan-500/25 transition-all flex items-center gap-1.5">
                        <span data-i18n="nav_open_app">دخول المنصة</span>
                        <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M13 7l5 5m0 0l-5 5m5-5H6"/></svg>
                    </a>
                </div>
            </div>
        </div>
    </header>

    <!-- 2. Hero Section: Future Generation of Education DZ -->
    <section class="relative hero-mesh grid-pattern pt-14 pb-20 lg:pt-20 lg:pb-28 overflow-hidden border-b border-white/5">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 relative z-10">
            <?php if(session('download_notice')): ?>
                <div class="mb-6 p-4 rounded-2xl bg-amber-500/15 border border-amber-400/30 text-amber-200 text-xs font-bold text-center">
                    <?php echo e(session('download_notice')); ?>

                </div>
            <?php endif; ?>

            <div class="grid grid-cols-1 lg:grid-cols-12 gap-12 items-center">
                <!-- Text Column -->
                <div class="lg:col-span-7 space-y-7 text-center lg:text-start">
                    <!-- Flagship Badge -->
                    <div class="inline-flex flex-wrap items-center justify-center lg:justify-start gap-2.5 px-4 py-1.5 rounded-full bg-slate-900/80 border border-cyan-400/30 shadow-lg shadow-cyan-500/10">
                        <span class="w-2.5 h-2.5 rounded-full bg-emerald-400 pulse-dot"></span>
                        <span class="text-xs font-extrabold text-cyan-300 tracking-wide" data-i18n="hero_badge">
                            مستقبل التعليم في الجزائر • Future Generation of Education DZ
                        </span>
                    </div>

                    <!-- Main Title -->
                    <h1 class="text-4xl sm:text-5xl lg:text-6xl font-black leading-[1.15] tracking-tight">
                        <span class="gradient-text" data-i18n="hero_title_1">مستقبل التعليم في الجزائر</span>
                        <br>
                        <span class="text-white text-2xl sm:text-4xl lg:text-4xl font-extrabold block mt-3 opacity-95" data-i18n="hero_title_2">
                            Future Generation of Education DZ
                        </span>
                    </h1>

                    <!-- Subtitle -->
                    <p class="text-slate-300 text-base sm:text-lg leading-relaxed max-w-2xl mx-auto lg:mx-0" data-i18n="hero_subtitle">
                        منصة <strong class="text-white">Pindo Future</strong> هي الجيل الجديد من التعليم الرقمي التفاعلي عبر 58 ولاية جزائرية: قاعات بث مباشر فائقة السرعة، سبورة ذكية متجهة، أفواج دراسية مستقلة، بنك امتحانات <span class="text-cyan-300 font-bold">BEM &amp; BAC</span>، درع حماية متكامل ضد القرصنة، ودفع إلكتروني جزائري 100% عبر <span class="text-amber-400 font-bold">BaridiMob</span> و<span class="text-amber-400 font-bold">Edahabia</span> و<span class="text-amber-400 font-bold">CCP</span>.
                    </p>

                    <!-- Primary CTAs -->
                    <div class="flex flex-wrap items-center justify-center lg:justify-start gap-4 pt-2">
                        <a href="/app/" class="px-7 py-4 rounded-2xl bg-gradient-to-r from-cyan-400 via-teal-400 to-emerald-400 hover:brightness-110 text-slate-950 font-black text-sm shadow-2xl shadow-cyan-500/30 transition-all transform hover:-translate-y-0.5 flex items-center gap-2.5">
                            <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M14.752 11.168l-3.197-2.132A1 1 0 0010 9.87v4.263a1 1 0 001.555.832l3.197-2.132a1 1 0 000-1.664z"/><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z"/></svg>
                            <span data-i18n="hero_cta_web">فتح التطبيق الآن (ويب / آيفون / حاسوب)</span>
                        </a>

                        <a href="<?php echo e($apkAvailable ? '/download/android' : '#download'); ?>" class="px-6 py-4 rounded-2xl bg-slate-900/90 hover:bg-slate-800 border border-white/15 hover:border-violet-400/50 text-white font-extrabold text-sm transition-all flex items-center gap-2.5">
                            <svg class="w-5 h-5 text-emerald-400" fill="currentColor" viewBox="0 0 24 24"><path d="M17.523 15.3414c-.5511 0-.9993-.4486-.9993-.9997s.4483-.9993.9993-.9993c.5511 0 .9993.4483.9993.9993.0001.5511-.4482.9997-.9993.9997m-11.046 0c-.5511 0-.9993-.4486-.9993-.9997s.4482-.9993.9993-.9993c.5511 0 .9993.4483.9993.9993 0 .5511-.4483.9997-.9993.9997m11.4045-6.02l1.9973-3.4592a.416.416 0 00-.1521-.5676.416.416 0 00-.5676.1521l-2.0223 3.503C15.5902 8.2439 13.8533 7.8508 12 7.8508s-3.5902.3931-5.1367 1.0989L4.841 5.4467a.4161.4161 0 00-.5677-.1521.4157.4157 0 00-.1521.5676l1.9973 3.4592C2.6889 11.1867.3432 14.6589 0 18.761h24c-.3435-4.1021-2.6892-7.5743-6.1185-9.4396"/></svg>
                            <span data-i18n="hero_cta_apk">تحميل تطبيق الأندرويد (APK)</span>
                            <span class="px-2 py-0.5 rounded-md bg-emerald-500/15 text-emerald-300 text-[10px] font-mono"><?php echo e($apkSizeMb); ?> MB</span>
                        </a>
                    </div>

                    <!-- Live Honest Platform Telemetry Strip -->
                    <div class="grid grid-cols-2 sm:grid-cols-4 gap-3 pt-4 max-w-2xl mx-auto lg:mx-0">
                        <div class="glass-card rounded-2xl p-3.5 text-center">
                            <div class="text-xl font-black text-cyan-300 font-mono">58</div>
                            <div class="text-[11px] font-bold text-slate-400 mt-0.5" data-i18n="stat_wilayas">ولاية جزائرية مدعومة</div>
                        </div>
                        <div class="glass-card rounded-2xl p-3.5 text-center">
                            <div class="text-xl font-black text-violet-300 font-mono">30K</div>
                            <div class="text-[11px] font-bold text-slate-400 mt-0.5" data-i18n="stat_sfu">طاقة البث التفاعلي</div>
                        </div>
                        <div class="glass-card rounded-2xl p-3.5 text-center">
                            <div class="text-xl font-black text-emerald-300 font-mono"><?php echo e($totalExamsCount); ?></div>
                            <div class="text-[11px] font-bold text-slate-400 mt-0.5" data-i18n="stat_exams">مواضيع BEM &amp; BAC</div>
                        </div>
                        <div class="glass-card rounded-2xl p-3.5 text-center">
                            <div class="text-xl font-black text-amber-300 font-mono">DZD</div>
                            <div class="text-[11px] font-bold text-slate-400 mt-0.5" data-i18n="stat_pay">بريدي موب والذهبية</div>
                        </div>
                    </div>
                </div>

                <!-- Visual Interactive Showcase Card -->
                <div class="lg:col-span-5">
                    <div class="relative float-slow">
                        <!-- Ambient Glow -->
                        <div class="absolute -inset-4 bg-gradient-to-tr from-violet-600/30 via-cyan-500/20 to-emerald-500/20 rounded-[36px] blur-2xl"></div>

                        <!-- Glass Device Frame -->
                        <div class="relative glass-card rounded-[30px] p-5 border border-white/15 shadow-2xl">
                            <!-- Top Window Header -->
                            <div class="flex items-center justify-between pb-4 mb-4 border-b border-white/10">
                                <div class="flex items-center gap-2.5">
                                    <img src="/images/pindo_logo_badge.png" alt="Logo" class="w-8 h-8 rounded-xl">
                                    <div>
                                        <div class="text-xs font-black text-white">Pindo Future Classroom</div>
                                        <div class="text-[10px] font-mono text-emerald-400 flex items-center gap-1">
                                            <span class="w-1.5 h-1.5 rounded-full bg-emerald-400"></span>
                                            LiveKit WebRTC • DRM Active
                                        </div>
                                    </div>
                                </div>
                                <span class="px-2.5 py-1 rounded-lg bg-red-500/15 text-red-300 border border-red-500/30 text-[10px] font-extrabold">
                                    LIVE SFU
                                </span>
                            </div>

                            <!-- Simulated Interactive Whiteboard + Classroom Stage -->
                            <div class="rounded-2xl bg-slate-950/90 border border-white/10 p-4 space-y-3 relative overflow-hidden">
                                <!-- Watermark Overlay Preview -->
                                <div class="absolute top-3 left-3 px-2 py-0.5 rounded bg-white/5 border border-white/10 text-[9px] font-mono text-cyan-300/80 select-none">
                                    🔒 DRM 4-Vector Shield • FLAG_SECURE
                                </div>

                                <div class="pt-5 pb-2 flex items-center justify-between">
                                    <div>
                                        <div class="text-[11px] font-bold text-cyan-400">السبورة الرقمية التفاعلية</div>
                                        <div class="text-sm font-black text-white mt-0.5">بث حي عالي الدقة + رسم متجه 50ms</div>
                                    </div>
                                </div>

                                <!-- Vector Math Curve SVG -->
                                <div class="rounded-xl bg-[#070D1D] border border-cyan-500/20 p-3">
                                    <svg viewBox="0 0 320 90" class="w-full h-20">
                                        <defs>
                                            <linearGradient id="curveGrad" x1="0" y1="0" x2="1" y2="0">
                                                <stop offset="0%" stop-color="#22D3EE"/>
                                                <stop offset="100%" stop-color="#A78BFA"/>
                                            </linearGradient>
                                        </defs>
                                        <line x1="20" y1="75" x2="300" y2="75" stroke="rgba(255,255,255,0.12)" stroke-width="1"/>
                                        <line x1="40" y1="10" x2="40" y2="85" stroke="rgba(255,255,255,0.12)" stroke-width="1"/>
                                        <path d="M 40 70 Q 120 15, 190 50 T 295 18" fill="none" stroke="url(#curveGrad)" stroke-width="3" stroke-linecap="round"/>
                                        <circle cx="190" cy="50" r="4.5" fill="#22D3EE"/>
                                        <text x="198" y="47" fill="#94A3B8" font-size="10" font-family="monospace">f(x) = e^x - 1</text>
                                    </svg>
                                </div>

                                <!-- 3 Feature Pills inside mockup -->
                                <div class="grid grid-cols-3 gap-2 pt-1">
                                    <div class="rounded-xl bg-white/5 p-2.5 text-center border border-white/5">
                                        <div class="text-xs font-black text-emerald-400">رادار الولي</div>
                                        <div class="text-[10px] text-slate-400">متابعة الحضور</div>
                                    </div>
                                    <div class="rounded-xl bg-white/5 p-2.5 text-center border border-white/5">
                                        <div class="text-xs font-black text-amber-400">BaridiMob</div>
                                        <div class="text-[10px] text-slate-400">توثيق بالبصمة</div>
                                    </div>
                                    <div class="rounded-xl bg-white/5 p-2.5 text-center border border-white/5">
                                        <div class="text-xs font-black text-violet-400">BEM &amp; BAC</div>
                                        <div class="text-[10px] text-slate-400">محاكاة مؤقتة</div>
                                    </div>
                                </div>
                            </div>

                            <!-- Live Server Status Footer inside Card -->
                            <div class="mt-4 flex items-center justify-between text-[11px] px-1">
                                <span class="text-slate-400 font-semibold flex items-center gap-1.5">
                                    <span class="w-2 h-2 rounded-full <?php echo e($dbOnline ? 'bg-emerald-400' : 'bg-amber-400'); ?>"></span>
                                    <?php echo e($dbOnline ? 'الخادم السحابي متصل ونشط' : 'وضع التشغيل الاحتياطي'); ?>

                                </span>
                                <span class="font-mono text-cyan-300 font-bold">v1.0.0 Cloud</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- 3. Omnichannel Banner (Works on Every Device) -->
    <section id="features" class="py-12 border-b border-white/5 bg-slate-950/60">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-8">
                <p class="text-xs font-extrabold text-cyan-400 uppercase tracking-widest mb-2" data-i18n="omni_tag">OMNICHANNEL EDUCATION PLATFORM</p>
                <h2 class="text-2xl sm:text-3xl font-black text-white" data-i18n="omni_title">تعلّم وعلّم من أي جهاز وفي أي وقت</h2>
            </div>

            <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
                <div class="glass-card rounded-2xl p-5 flex items-start gap-4">
                    <div class="w-11 h-11 rounded-xl bg-emerald-500/15 border border-emerald-500/30 flex items-center justify-center shrink-0 text-emerald-400 text-xl">📱</div>
                    <div>
                        <h3 class="font-extrabold text-sm text-white" data-i18n="dev_android_t">هواتف وتابلت أندرويد</h3>
                        <p class="text-xs text-slate-400 mt-1 leading-relaxed" data-i18n="dev_android_d">تطبيق أصلي سريع ومشفر بتقنية R8 وحماية عتادية FLAG_SECURE ضد التصوير.</p>
                    </div>
                </div>
                <div class="glass-card rounded-2xl p-5 flex items-start gap-4">
                    <div class="w-11 h-11 rounded-xl bg-cyan-500/15 border border-cyan-500/30 flex items-center justify-center shrink-0 text-cyan-400 text-xl">🍏</div>
                    <div>
                        <h3 class="font-extrabold text-sm text-white" data-i18n="dev_ios_t">أجهزة iPhone و iPad</h3>
                        <p class="text-xs text-slate-400 mt-1 leading-relaxed" data-i18n="dev_ios_d">تجربة تطبيق ويب متكاملة (PWA) على Safari مع إمكانية التثبيت الفوري على الشاشة الرئيسية.</p>
                    </div>
                </div>
                <div class="glass-card rounded-2xl p-5 flex items-start gap-4">
                    <div class="w-11 h-11 rounded-xl bg-violet-500/15 border border-violet-500/30 flex items-center justify-center shrink-0 text-violet-400 text-xl">💻</div>
                    <div>
                        <h3 class="font-extrabold text-sm text-white" data-i18n="dev_pc_t">الحواسيب Windows و Mac</h3>
                        <p class="text-xs text-slate-400 mt-1 leading-relaxed" data-i18n="dev_pc_d">شاشة عرض مسرحية واسعة للسبورة الذكية وبث الأساتذة ومراجعة الوصولات.</p>
                    </div>
                </div>
                <div class="glass-card rounded-2xl p-5 flex items-start gap-4">
                    <div class="w-11 h-11 rounded-xl bg-amber-500/15 border border-amber-500/30 flex items-center justify-center shrink-0 text-amber-400 text-xl">🇩🇿</div>
                    <div>
                        <h3 class="font-extrabold text-sm text-white" data-i18n="dev_dz_t">متوافق مع 58 ولاية</h3>
                        <p class="text-xs text-slate-400 mt-1 leading-relaxed" data-i18n="dev_dz_d">بحث ذكي ثنائي اللغة بالعربية والفرنسية حسب الولاية، الطور الدراسي، والشعبة.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- 4. Interactive 3-Role Workspace Explorer (Student • Teacher • Parent) -->
    <section id="roles" class="py-20 relative">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center max-w-3xl mx-auto mb-12">
                <span class="px-3 py-1 rounded-full bg-violet-500/15 border border-violet-400/30 text-violet-300 text-xs font-extrabold" data-i18n="roles_badge">منظومة ثلاثية متكاملة</span>
                <h2 class="text-3xl sm:text-4xl font-black text-white mt-4" data-i18n="roles_title">فضاء مخصص ومستقل لكل فرد في العملية التعليمية</h2>
                <p class="text-slate-400 text-sm sm:text-base mt-3" data-i18n="roles_sub">اختر دورك لاستكشاف الأدوات المصممة خصيصاً لك داخل منصة Pindo Future</p>
            </div>

            <!-- Interactive Role Tabs -->
            <div class="flex flex-wrap justify-center gap-3 mb-10">
                <button onclick="switchRoleTab('student')" id="tab-btn-student" class="role-tab px-6 py-3.5 rounded-2xl bg-gradient-to-r from-cyan-400 to-teal-400 text-slate-950 font-black text-sm shadow-lg shadow-cyan-500/25 transition-all">
                    🎓 التلميذ والطالب (Student)
                </button>
                <button onclick="switchRoleTab('teacher')" id="tab-btn-teacher" class="role-tab px-6 py-3.5 rounded-2xl bg-slate-900 border border-white/10 text-slate-300 hover:text-white font-extrabold text-sm transition-all">
                    👨‍🏫 الأستاذ المعتمد (Teacher)
                </button>
                <button onclick="switchRoleTab('parent')" id="tab-btn-parent" class="role-tab px-6 py-3.5 rounded-2xl bg-slate-900 border border-white/10 text-slate-300 hover:text-white font-extrabold text-sm transition-all">
                    🛡️ ولي الأمر (Parent Oversight)
                </button>
            </div>

            <!-- Role Panels -->
            <div id="role-panel-student" class="role-panel glass-card rounded-3xl p-8 lg:p-10 grid grid-cols-1 lg:grid-cols-2 gap-8 items-center">
                <div class="space-y-5">
                    <span class="text-xs font-extrabold text-cyan-400">Pillar 1 • Pillar 2 • Pillar 3</span>
                    <h3 class="text-2xl sm:text-3xl font-black text-white">مسار التلميذ نحو التفوق من 0 الى الامتياز</h3>
                    <p class="text-slate-300 text-sm leading-relaxed">
                        انضم إلى أفواج أساتذتك المعتمدين في كافة الأطوار (الابتدائي، المتوسط، الثانوي، والجامعي)، احضر الحصص المباشرة وتفاعل بالسبورة والمحادثة، وراجع دروسك من المكتبة الرقمية المحمية في أي وقت.
                    </p>
                    <ul class="space-y-3 text-xs sm:text-sm text-slate-200">
                        <li class="flex items-center gap-2.5"><span class="text-cyan-400 font-black">✓</span> استكشاف الأفواج والأساتذة حسب المادة، الشعبة، والولاية.</li>
                        <li class="flex items-center gap-2.5"><span class="text-cyan-400 font-black">✓</span> جدول الحصص الزمني الكامل وسجل الحضور من أول يوم اشتراك.</li>
                        <li class="flex items-center gap-2.5"><span class="text-cyan-400 font-black">✓</span> محاكاة مؤقتة لامتحانات البكالوريا والبيام الرسمية مع سلم التنقيط الوزاري.</li>
                        <li class="flex items-center gap-2.5"><span class="text-cyan-400 font-black">✓</span> محادثات جماعية منظمة لكل فوج لتبادل التمارين والملفات PDF.</li>
                    </ul>
                    <div class="pt-2">
                        <a href="/app/" class="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-cyan-400 text-slate-950 font-black text-xs hover:bg-cyan-300 transition-all">
                            سجّل كتلميذ الآن ←
                        </a>
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div class="rounded-2xl bg-slate-900/90 border border-white/10 p-5 space-y-2">
                        <div class="text-2xl">🎥</div>
                        <div class="font-extrabold text-sm text-white">بث مباشر HD</div>
                        <p class="text-xs text-slate-400">صوت وصورة نقية مع رفع اليد والمشاركة الصوتية.</p>
                    </div>
                    <div class="rounded-2xl bg-slate-900/90 border border-white/10 p-5 space-y-2">
                        <div class="text-2xl">📚</div>
                        <div class="font-extrabold text-sm text-white">المكتبة المحمية</div>
                        <p class="text-xs text-slate-400">تسجيلات الحصص وملفات التمارين مرتبة حسب الفوج.</p>
                    </div>
                    <div class="rounded-2xl bg-slate-900/90 border border-white/10 p-5 space-y-2">
                        <div class="text-2xl">⏱️</div>
                        <div class="font-extrabold text-sm text-white">محاكي الامتحانات</div>
                        <p class="text-xs text-slate-400">مواضيع رسمية مؤقتة وتقييم ذاتي دقيق.</p>
                    </div>
                    <div class="rounded-2xl bg-slate-900/90 border border-white/10 p-5 space-y-2">
                        <div class="text-2xl">💳</div>
                        <div class="font-extrabold text-sm text-white">اشتراك بريدي موب</div>
                        <p class="text-xs text-slate-400">رفع وصل التحويل وتفعيل تلقائي بعد المراجعة.</p>
                    </div>
                </div>
            </div>

            <div id="role-panel-teacher" class="role-panel hidden glass-card rounded-3xl p-8 lg:p-10 grid grid-cols-1 lg:grid-cols-2 gap-8 items-center">
                <div class="space-y-5">
                    <span class="text-xs font-extrabold text-violet-400">Teacher Independent Studio</span>
                    <h3 class="text-2xl sm:text-3xl font-black text-white">منصتك التعليمية المستقلة بشارة التوثيق الرسمية</h3>
                    <p class="text-slate-300 text-sm leading-relaxed">
                        أنشئ أفواجك الدراسية الخاصة، حدد تسعيرتك الشهرية بالدينار الجزائري، شارك رابطك الخاص مع تلاميذك عبر الـ 58 ولاية، وأدر حضورهم وأرباحك بكل احترافية وخصوصية.
                    </p>
                    <ul class="space-y-3 text-xs sm:text-sm text-slate-200">
                        <li class="flex items-center gap-2.5"><span class="text-violet-400 font-black">✓</span> شارة الأستاذ المعتمد بعد مراجعة الشهادات في غرفة العمليات.</li>
                        <li class="flex items-center gap-2.5"><span class="text-violet-400 font-black">✓</span> استوديو القصص التفاعلية (صور، فيديو، ونص) لعرض نتائج المتفوقين.</li>
                        <li class="flex items-center gap-2.5"><span class="text-violet-400 font-black">✓</span> سبورة رقمية متجهة مع حفظ اللقطات وتوزيعها على التلاميذ.</li>
                        <li class="flex items-center gap-2.5"><span class="text-violet-400 font-black">✓</span> سحب الأرباح مباشرة عبر BaridiMob أو الحساب البريدي CCP.</li>
                    </ul>
                    <div class="pt-2">
                        <a href="/app/" class="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-violet-500 text-white font-black text-xs hover:bg-violet-400 transition-all">
                            افتح فضاءك كأستاذ ←
                        </a>
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div class="rounded-2xl bg-slate-900/90 border border-white/10 p-5 space-y-2">
                        <div class="text-2xl">🏫</div>
                        <div class="font-extrabold text-sm text-white">إدارة الأفواج</div>
                        <p class="text-xs text-slate-400">تحديد السعة، البرنامج الأسبوعي، ومقار العمل.</p>
                    </div>
                    <div class="rounded-2xl bg-slate-900/90 border border-white/10 p-5 space-y-2">
                        <div class="text-2xl">🏆</div>
                        <div class="font-extrabold text-sm text-white">لوحة الشرف</div>
                        <p class="text-xs text-slate-400">نشر علامات المتفوقين ونتائج البكالوريا والبيام.</p>
                    </div>
                    <div class="rounded-2xl bg-slate-900/90 border border-white/10 p-5 space-y-2">
                        <div class="text-2xl">📊</div>
                        <div class="font-extrabold text-sm text-white">محفظة DZD</div>
                        <p class="text-xs text-slate-400">تتبع فوري لصافي الأرباح وطلبات التحويل.</p>
                    </div>
                    <div class="rounded-2xl bg-slate-900/90 border border-white/10 p-5 space-y-2">
                        <div class="text-2xl">🔗</div>
                        <div class="font-extrabold text-sm text-white">رابط خاص للأستاذ</div>
                        <p class="text-xs text-slate-400">صفحة تعريفية احترافية قابلة للمشاركة المباشرة.</p>
                    </div>
                </div>
            </div>

            <div id="role-panel-parent" class="role-panel hidden glass-card rounded-3xl p-8 lg:p-10 grid grid-cols-1 lg:grid-cols-2 gap-8 items-center">
                <div class="space-y-5">
                    <span class="text-xs font-extrabold text-emerald-400">Guardian Oversight Engine</span>
                    <h3 class="text-2xl sm:text-3xl font-black text-white">رادار ولي الأمر: طمأنينة كاملة ومتابعة لحظية</h3>
                    <p class="text-slate-300 text-sm leading-relaxed">
                        اربط حسابك بحساب ابنك عبر رمز العائلة السري، وتابع حضوره، انضباطه، ملاحظات أساتذته، وجدول حصصه أولاً بأول من هاتفك.
                    </p>
                    <ul class="space-y-3 text-xs sm:text-sm text-slate-200">
                        <li class="flex items-center gap-2.5"><span class="text-emerald-400 font-black">✓</span> رادار الغياب والتأخر (تنبيه خلال 15 دقيقة من بداية الحصة).</li>
                        <li class="flex items-center gap-2.5"><span class="text-emerald-400 font-black">✓</span> سجل دقيق لمدة بقاء الابن داخل قاعة البث المباشر بالدقائق.</li>
                        <li class="flex items-center gap-2.5"><span class="text-emerald-400 font-black">✓</span> استلام وتأكيد قراءة ملاحظات الأساتذة وتقارير المستوى.</li>
                        <li class="flex items-center gap-2.5"><span class="text-emerald-400 font-black">✓</span> دفع وتجديد اشتراكات الأبناء مباشرة من بوابة الولي.</li>
                    </ul>
                    <div class="pt-2">
                        <a href="/app/" class="inline-flex items-center gap-2 px-6 py-3 rounded-xl bg-emerald-400 text-slate-950 font-black text-xs hover:bg-emerald-300 transition-all">
                            دخول بوابة ولي الأمر ←
                        </a>
                    </div>
                </div>
                <div class="grid grid-cols-2 gap-4">
                    <div class="rounded-2xl bg-slate-900/90 border border-white/10 p-5 space-y-2">
                        <div class="text-2xl">📡</div>
                        <div class="font-extrabold text-sm text-white">رادار الغياب 15د</div>
                        <p class="text-xs text-slate-400">تنبيه فوري في حالة عدم التحاق الابن بالحصة.</p>
                    </div>
                    <div class="rounded-2xl bg-slate-900/90 border border-white/10 p-5 space-y-2">
                        <div class="text-2xl">🔐</div>
                        <div class="font-extrabold text-sm text-white">ربط بكود العائلة</div>
                        <p class="text-xs text-slate-400">ربط آمن برمز التلميذ الفريد أو بريده.</p>
                    </div>
                    <div class="rounded-2xl bg-slate-900/90 border border-white/10 p-5 space-y-2">
                        <div class="text-2xl">📝</div>
                        <div class="font-extrabold text-sm text-white">ملاحظات الأساتذة</div>
                        <p class="text-xs text-slate-400">تواصل شفاف حول سلوك ومستوى التلميذ.</p>
                    </div>
                    <div class="rounded-2xl bg-slate-900/90 border border-white/10 p-5 space-y-2">
                        <div class="text-2xl">🧾</div>
                        <div class="font-extrabold text-sm text-white">دفع مباشر</div>
                        <p class="text-xs text-slate-400">إدارة اشتراكات الأبناء بأمان عبر بريدي موب.</p>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- 5. Anti-Piracy & Infrastructure Fortress -->
    <section id="security" class="py-20 bg-slate-950/70 border-y border-white/5">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="grid grid-cols-1 lg:grid-cols-12 gap-10 items-center">
                <div class="lg:col-span-5 space-y-5">
                    <span class="px-3 py-1 rounded-full bg-emerald-500/15 border border-emerald-400/30 text-emerald-300 text-xs font-extrabold">Anti-Piracy &amp; Zero-Trust DRM</span>
                    <h2 class="text-3xl font-black text-white leading-snug">حصن تقني متقدم لحماية محتوى الأساتذة من التسريب والقرصنة</h2>
                    <p class="text-slate-300 text-sm leading-relaxed">
                        صُممت منصة Pindo Future لحماية جهد الأستاذ ومحتواه المدفوع بأعلى المعايير الهندسية على أندرويد، آيفون، والويب.
                    </p>
                    <div class="space-y-3 pt-2">
                        <div class="glass-card rounded-2xl p-4 flex items-center gap-3.5">
                            <span class="text-2xl">🛡️</span>
                            <div>
                                <div class="font-extrabold text-sm text-white">درع FLAG_SECURE و iOS Secure Layer</div>
                                <div class="text-xs text-slate-400">منع لقطات الشاشة وتطبيقات التصوير الخارجي أثناء البث والتسجيلات.</div>
                            </div>
                        </div>
                        <div class="glass-card rounded-2xl p-4 flex items-center gap-3.5">
                            <span class="text-2xl">💧</span>
                            <div>
                                <div class="font-extrabold text-sm text-white">علامة مائية ديناميكية رباعية الأبعاد</div>
                                <div class="text-xs text-slate-400">تطبع رقم الطالب واسمه وتوقيت المشاهدة بشكل متحرك لمنع إعادة النشر.</div>
                            </div>
                        </div>
                        <div class="glass-card rounded-2xl p-4 flex items-center gap-3.5">
                            <span class="text-2xl">⚡</span>
                            <div>
                                <div class="font-extrabold text-sm text-white">غرفة عمليات إدارية لحظية + Kill-Switch</div>
                                <div class="text-xs text-slate-400">مراقبة مستمرة للحصص وتوثيق الأساتذة مع تشفير Sanctum Token.</div>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Algerian Payment Ecosystem Card -->
                <div id="payments" class="lg:col-span-7">
                    <div class="glass-card rounded-3xl p-8 border border-amber-400/25 relative overflow-hidden">
                        <div class="absolute top-0 left-0 w-48 h-48 bg-amber-500/10 blur-3xl pointer-events-none"></div>
                        <div class="flex flex-wrap items-center justify-between gap-4 mb-6">
                            <div>
                                <span class="text-xs font-extrabold text-amber-400">100% Algerian Payment Ecosystem</span>
                                <h3 class="text-2xl font-black text-white mt-1">دفع محلي آمن بالدينار الجزائري (DZD)</h3>
                            </div>
                            <span class="px-3 py-1 rounded-xl bg-amber-500/15 border border-amber-400/30 text-amber-300 text-xs font-mono font-bold">SHA-256 Anti-Fraud</span>
                        </div>

                        <div class="grid grid-cols-1 sm:grid-cols-3 gap-4 mb-6">
                            <div class="rounded-2xl bg-slate-900/90 border border-amber-400/20 p-4 text-center">
                                <div class="text-amber-400 font-black text-lg">BaridiMob</div>
                                <div class="text-xs text-slate-400 mt-1">تحويل فوري عبر RIP الرسمي ورفع الوصل</div>
                            </div>
                            <div class="rounded-2xl bg-slate-900/90 border border-cyan-400/20 p-4 text-center">
                                <div class="text-cyan-400 font-black text-lg">Edahabia</div>
                                <div class="text-xs text-slate-400 mt-1">الدفع بالبطاقة الذهبية لبريد الجزائر</div>
                            </div>
                            <div class="rounded-2xl bg-slate-900/90 border border-emerald-400/20 p-4 text-center">
                                <div class="text-emerald-400 font-black text-lg">CCP</div>
                                <div class="text-xs text-slate-400 mt-1">دفع بريدي موثق وتحويل مستحقات الأساتذة</div>
                            </div>
                        </div>

                        <div class="rounded-2xl bg-slate-950/80 border border-white/10 p-5 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
                            <div>
                                <div class="text-xs font-bold text-slate-400">نظام حماية ضد تكرار الوصولات وتمديد الصلاحية التلقائي</div>
                                <div class="text-sm font-extrabold text-white mt-1">يتم فحص بصمة كل وصل تلقائياً لضمان حقوق التلميذ والأستاذ.</div>
                            </div>
                            <a href="/app/" class="shrink-0 px-5 py-2.5 rounded-xl bg-amber-400 hover:bg-amber-300 text-slate-950 font-black text-xs transition-all">
                                اشترك الآن
                            </a>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- 6. Live National Exam Bank Preview (Fetched Live from PostgreSQL) -->
    <section id="exams" class="py-20">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="flex flex-col sm:flex-row sm:items-end justify-between gap-4 mb-10">
                <div>
                    <span class="px-3 py-1 rounded-full bg-cyan-500/15 border border-cyan-400/30 text-cyan-300 text-xs font-extrabold">Official Exam Simulator</span>
                    <h2 class="text-3xl font-black text-white mt-3">بنك الفروض والامتحانات الوطنية (BEM &amp; BAC)</h2>
                    <p class="text-slate-400 text-sm mt-1">نماذج حقيقية محمّلة مباشرة من قاعدة بيانات المنصة مع التصحيح وسلم التنقيط</p>
                </div>
                <a href="/app/" class="px-5 py-2.5 rounded-xl bg-slate-900 border border-cyan-400/30 text-cyan-300 hover:bg-cyan-500/10 text-xs font-extrabold transition-all self-start">
                    بدء محاكاة امتحان في التطبيق ←
                </a>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-5">
                <?php $__empty_1 = true; $__currentLoopData = $examPapers; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $paper): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); $__empty_1 = false; ?>
                    <div class="glass-card rounded-3xl p-6 flex flex-col justify-between space-y-4">
                        <div>
                            <div class="flex items-center justify-between gap-2 mb-3">
                                <span class="px-2.5 py-1 rounded-lg text-[11px] font-black uppercase <?php echo e($paper->cycle === 'bac' ? 'bg-violet-500/20 text-violet-300 border border-violet-400/30' : 'bg-emerald-500/20 text-emerald-300 border border-emerald-400/30'); ?>">
                                    <?php echo e(strtoupper($paper->cycle)); ?> <?php echo e($paper->year); ?>

                                </span>
                                <span class="font-mono text-[11px] text-slate-400"><?php echo e($paper->duration_minutes); ?> د • معامل <?php echo e($paper->coefficient); ?></span>
                            </div>
                            <h3 class="font-extrabold text-base text-white leading-snug"><?php echo e($paper->title); ?></h3>
                            <p class="text-xs text-cyan-300 font-bold mt-2"><?php echo e($paper->subject_name_ar); ?></p>
                        </div>
                        <div class="pt-3 border-t border-white/10 flex items-center justify-between">
                            <span class="font-mono text-[11px] text-slate-500"><?php echo e($paper->exam_code); ?></span>
                            <a href="/app/" class="text-xs font-black text-cyan-400 hover:text-cyan-300">فتح المحاكي ←</a>
                        </div>
                    </div>
                <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); if ($__empty_1): ?>
                    <div class="col-span-3 glass-card rounded-3xl p-8 text-center text-slate-400 text-sm">
                        سيتم عرض مواضيع بنك الامتحانات هنا فور توفرها.
                    </div>
                <?php endif; ?>
            </div>
        </div>
    </section>

    <!-- 7. Download & Install Center -->
    <section id="download" class="py-20 bg-slate-950/75 border-y border-white/5">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center max-w-2xl mx-auto mb-12">
                <span class="px-3 py-1 rounded-full bg-emerald-500/15 border border-emerald-400/30 text-emerald-300 text-xs font-extrabold">Get Pindo Future</span>
                <h2 class="text-3xl sm:text-4xl font-black text-white mt-3">حمّل التطبيق أو افتحه مباشرة على جهازك</h2>
                <p class="text-slate-400 text-sm mt-2">نسخة رسمية ومجانية التحميل، جاهزة لتسجيل الأساتذة والتلاميذ والأولياء</p>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-3 gap-6">
                <!-- Android APK -->
                <div class="glass-card rounded-3xl p-7 flex flex-col justify-between space-y-6 border-emerald-500/20">
                    <div class="space-y-3">
                        <div class="w-12 h-12 rounded-2xl bg-emerald-500/15 border border-emerald-500/30 flex items-center justify-center text-2xl">🤖</div>
                        <h3 class="text-xl font-black text-white">تطبيق الأندرويد (APK)</h3>
                        <p class="text-xs text-slate-400 leading-relaxed">
                            لهواتف سامسونغ، شاومي، أوبو، ريلمي والتابلت. يتضمن حماية FLAG_SECURE العتادية وتشفير الكود.
                        </p>
                    </div>
                    <div class="space-y-2.5">
                        <a href="/download/android" class="w-full py-3.5 px-4 rounded-xl bg-emerald-400 hover:bg-emerald-300 text-slate-950 font-black text-xs flex items-center justify-center gap-2 transition-all shadow-lg shadow-emerald-500/20">
                            <span>تحميل الحزمة الموقعة (<?php echo e($apkSizeMb); ?> MB)</span>
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" stroke-width="2.5" d="M4 16v1a3 3 0 003 3h10a3 3 0 003-3v-1m-4-4l-4 4m0 0l-4-4m4 4V4"/></svg>
                        </a>
                        <div class="text-center text-[11px] font-mono text-slate-500">Android 7.0+ • Signed Production Release</div>
                    </div>
                </div>

                <!-- iPhone / iPad PWA -->
                <div class="glass-card rounded-3xl p-7 flex flex-col justify-between space-y-6 border-cyan-500/20">
                    <div class="space-y-3">
                        <div class="w-12 h-12 rounded-2xl bg-cyan-500/15 border border-cyan-500/30 flex items-center justify-center text-2xl">🍏</div>
                        <h3 class="text-xl font-black text-white">آيفون وآيباد (iOS PWA)</h3>
                        <p class="text-xs text-slate-400 leading-relaxed">
                            افتح المنصة في متصفح <strong>Safari</strong> ثم اضغط على أيقونة المشاركة واختر <strong>«إضافة إلى الشاشة الرئيسية»</strong> ليظهر كتطبيق أصلي.
                        </p>
                    </div>
                    <div class="space-y-2.5">
                        <a href="/app/" class="w-full py-3.5 px-4 rounded-xl bg-cyan-400 hover:bg-cyan-300 text-slate-950 font-black text-xs flex items-center justify-center gap-2 transition-all shadow-lg shadow-cyan-500/20">
                            <span>تشغيل على الآيفون والآيباد ←</span>
                        </a>
                        <div class="text-center text-[11px] font-mono text-slate-500">Safari PWA • iPhone &amp; iPad Ready</div>
                    </div>
                </div>

                <!-- Desktop & Web -->
                <div class="glass-card rounded-3xl p-7 flex flex-col justify-between space-y-6 border-violet-500/20">
                    <div class="space-y-3">
                        <div class="w-12 h-12 rounded-2xl bg-violet-500/15 border border-violet-500/30 flex items-center justify-center text-2xl">💻</div>
                        <h3 class="text-xl font-black text-white">الحاسوب والويب (PC / Mac)</h3>
                        <p class="text-xs text-slate-400 leading-relaxed">
                            يعمل على Chrome و Edge و Firefox بوضع الشاشة العريضة لإلقاء الدروس على السبورة أو المتابعة بدقة عالية.
                        </p>
                    </div>
                    <div class="space-y-2.5">
                        <a href="/app/" class="w-full py-3.5 px-4 rounded-xl bg-violet-500 hover:bg-violet-400 text-white font-black text-xs flex items-center justify-center gap-2 transition-all shadow-lg shadow-violet-500/20">
                            <span>دخول منصة الحاسوب ←</span>
                        </a>
                        <div class="text-center text-[11px] font-mono text-slate-500">Windows • macOS • Linux Browsers</div>
                    </div>
                </div>
            </div>
        </div>
    </section>

    <!-- 8. Interactive FAQ Accordion -->
    <section id="faq" class="py-20">
        <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="text-center mb-12">
                <span class="px-3 py-1 rounded-full bg-white/5 border border-white/10 text-slate-300 text-xs font-extrabold">الأسئلة الشائعة</span>
                <h2 class="text-3xl font-black text-white mt-3">كل ما تحتاج معرفته حول Pindo Future</h2>
            </div>

            <div class="space-y-3.5">
                <?php
                    $faqs = [
                        ['q' => 'كيف يسجل التلميذ أو الأستاذ أو ولي الأمر حساباً جديداً؟', 'a' => 'افتح التطبيق عبر زر "دخول المنصة" أو عبر تطبيق الأندرويد، ثم اختر تبويب "إنشاء حساب جديد (Create Account)" وحدد دورك (تلميذ، أستاذ، أو ولي أمر). يمكن لولي الأمر ربط حساب ابنه مباشرة برمز التلميذ أو بريده الإلكتروني.'],
                        ['q' => 'كيف تتم عملية الدفع والاشتراك عبر BaridiMob و CCP؟', 'a' => 'عند اختيار التلميذ لأي باقة أو فوج، يظهر رقم الحساب البريدي الرسمي (RIP) للمنصة. يقوم التلميذ بالتحويل عبر بريدي موب ويرفع صورة الوصل، لتراجعه الإدارة وتفعّل اشتراكه فوراً لمدة 30 يوماً مع حماية منع تكرار الوصولات.'],
                        ['q' => 'كيف يحصل الأستاذ على شارة التوثيق الرسمية؟', 'a' => 'بعد التسجيل كأستاذ، يرفع الأستاذ وثائقه (بطاقة التعريف والشهادة الجامعية أو الكفاءة) من فضائه، لتقوم الإدارة عبر غرفة العمليات المركزية بمراجعتها واعتماده فوراً أو إرسال ملاحظة تصحيح واضحة.'],
                        ['q' => 'كيف تحمي المنصة الدروس المباشرة والتسجيلات من السرقة؟', 'a' => 'تستخدم المنصة درع FLAG_SECURE على الأندرويد لمنع لقطات وتسجيل الشاشة، وطبقة حماية خاصة على الـ iOS والويب، إضافة إلى علامة مائية رباعية متحركة تعرض هوية الطالب ومعلوماته باستمرار.'],
                        ['q' => 'هل يعمل التطبيق على الآيفون والكمبيوتر بدون متجر App Store؟', 'a' => 'نعم، يعمل التطبيق بشكل كامل وسلس عبر المتصفح على iPhone و iPad و Windows و Mac من خلال الرابط /app/ مع دعم التثبيت كـ PWA على الشاشة الرئيسية.'],
                    ];
                ?>

                <?php $__currentLoopData = $faqs; $__env->addLoop($__currentLoopData); foreach($__currentLoopData as $idx => $faq): $__env->incrementLoopIndices(); $loop = $__env->getLastLoop(); ?>
                    <div class="glass-card rounded-2xl overflow-hidden">
                        <button onclick="toggleFaq(<?php echo e($idx); ?>)" class="w-full px-6 py-4 text-start flex items-center justify-between gap-4 font-extrabold text-sm text-white hover:text-cyan-300 transition-colors">
                            <span><?php echo e($faq['q']); ?></span>
                            <span id="faq-icon-<?php echo e($idx); ?>" class="text-cyan-400 font-mono text-lg transition-transform">+</span>
                        </button>
                        <div id="faq-body-<?php echo e($idx); ?>" class="hidden px-6 pb-5 text-xs sm:text-sm text-slate-300 leading-relaxed border-t border-white/5 pt-3">
                            <?php echo e($faq['a']); ?>

                        </div>
                    </div>
                <?php endforeach; $__env->popLoop(); $loop = $__env->getLastLoop(); ?>
            </div>
        </div>
    </section>

    <!-- 9. Footer -->
    <footer class="bg-cosmic-950 border-t border-white/10 pt-14 pb-10">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
            <div class="grid grid-cols-1 md:grid-cols-4 gap-8 pb-10 border-b border-white/10">
                <div class="md:col-span-2 space-y-4">
                    <div class="flex items-center gap-3">
                        <img src="/images/pindo_logo_badge.png" alt="Pindo Future" class="w-10 h-10 rounded-xl">
                        <div>
                            <div class="font-black text-lg text-white">Pindo <span class="text-cyan-400">Future</span></div>
                            <div class="text-xs font-bold text-cyan-300">مستقبل التعليم في الجزائر • Future Generation of Education DZ</div>
                        </div>
                    </div>
                    <p class="text-xs text-slate-400 max-w-md leading-relaxed">
                        منظومة تعليمية جزائرية شاملة تجمع بين البث التفاعلي المباشر، السبورة الذكية، إدارة الأفواج، الحماية من القرصنة، والرقابة الأسرية عبر الـ 58 ولاية.
                    </p>
                </div>

                <div>
                    <h4 class="font-extrabold text-xs text-white uppercase tracking-wider mb-4">روابط سريعة</h4>
                    <ul class="space-y-2.5 text-xs text-slate-400">
                        <li><a href="/app/" class="hover:text-cyan-300 transition-colors">تطبيق الويب (Web / PWA)</a></li>
                        <li><a href="/download/android" class="hover:text-cyan-300 transition-colors">تحميل تطبيق أندرويد (APK)</a></li>
                        <li><a href="#exams" class="hover:text-cyan-300 transition-colors">بنك امتحانات BEM &amp; BAC</a></li>
                        <li><a href="/privacy" class="hover:text-cyan-300 transition-colors">سياسة الخصوصية وشروط الاستخدام</a></li>
                    </ul>
                </div>

                <div>
                    <h4 class="font-extrabold text-xs text-white uppercase tracking-wider mb-4">الإدارة والنظام</h4>
                    <ul class="space-y-2.5 text-xs text-slate-400">
                        <li><a href="/admin/login" class="hover:text-emerald-400 transition-colors">لوحة التحكم المركزية (/admin)</a></li>
                        <li><a href="/api/v1/health" class="hover:text-cyan-300 transition-colors font-mono">API Health Status</a></li>
                        <li class="text-slate-500">Algeria • 58 Wilayas 🇩🇿</li>
                    </ul>
                </div>
            </div>

            <div class="pt-6 flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-slate-500">
                <div>© <?php echo e(date('Y')); ?> Pindo Future DZ. جميع الحقوق محفوظة — Future Generation of Education DZ.</div>
                <div class="font-mono text-[11px] text-slate-500">Powered by Laravel Cloud • LiveKit WebRTC • Flutter</div>
            </div>
        </div>
    </footer>

    <script>
        // Interactive Role Switcher
        function switchRoleTab(role) {
            document.querySelectorAll('.role-panel').forEach(p => p.classList.add('hidden'));
            document.getElementById('role-panel-' + role).classList.remove('hidden');

            const styles = {
                student: 'bg-gradient-to-r from-cyan-400 to-teal-400 text-slate-950 font-black shadow-lg shadow-cyan-500/25',
                teacher: 'bg-gradient-to-r from-violet-500 to-indigo-500 text-white font-black shadow-lg shadow-violet-500/25',
                parent:  'bg-gradient-to-r from-emerald-400 to-teal-400 text-slate-950 font-black shadow-lg shadow-emerald-500/25'
            };

            ['student', 'teacher', 'parent'].forEach(r => {
                const btn = document.getElementById('tab-btn-' + r);
                btn.className = 'role-tab px-6 py-3.5 rounded-2xl text-sm transition-all ' +
                    (r === role ? styles[r] : 'bg-slate-900 border border-white/10 text-slate-300 hover:text-white font-extrabold');
            });
        }

        // FAQ Accordion
        function toggleFaq(idx) {
            const body = document.getElementById('faq-body-' + idx);
            const icon = document.getElementById('faq-icon-' + idx);
            const isHidden = body.classList.contains('hidden');
            body.classList.toggle('hidden');
            icon.textContent = isHidden ? '−' : '+';
        }

        // AR / EN / FR Instant Translations
        const i18n = {
            ar: {
                dir: 'rtl',
                brand_sub: 'مستقبل التعليم في الجزائر',
                nav_features: 'المميزات',
                nav_roles: 'التلميذ • الأستاذ • الولي',
                nav_security: 'الحماية والبث',
                nav_payments: 'الدفع الجزائري',
                nav_exams: 'بنك BEM & BAC',
                nav_download: 'التحميل',
                nav_faq: 'الأسئلة الشائعة',
                nav_open_app: 'دخول المنصة',
                hero_badge: 'مستقبل التعليم في الجزائر • Future Generation of Education DZ',
                hero_title_1: 'مستقبل التعليم في الجزائر',
                hero_title_2: 'Future Generation of Education DZ',
                hero_cta_web: 'فتح التطبيق الآن (ويب / آيفون / حاسوب)',
                hero_cta_apk: 'تحميل تطبيق الأندرويد (APK)',
                stat_wilayas: 'ولاية جزائرية مدعومة',
                stat_sfu: 'طاقة البث التفاعلي',
                stat_exams: 'مواضيع BEM & BAC',
                stat_pay: 'بريدي موب والذهبية',
                omni_title: 'تعلّم وعلّم من أي جهاز وفي أي وقت',
                roles_badge: 'منظومة ثلاثية متكاملة',
                roles_title: 'فضاء مخصص ومستقل لكل فرد في العملية التعليمية',
                roles_sub: 'اختر دورك لاستكشاف الأدوات المصممة خصيصاً لك داخل منصة Pindo Future'
            },
            en: {
                dir: 'ltr',
                brand_sub: 'Future Generation of Education DZ',
                nav_features: 'Features',
                nav_roles: 'Student • Teacher • Parent',
                nav_security: 'DRM & LiveKit',
                nav_payments: 'Payments DZD',
                nav_exams: 'BEM & BAC Bank',
                nav_download: 'Download',
                nav_faq: 'FAQ',
                nav_open_app: 'Launch App',
                hero_badge: 'Future Generation of Education DZ • 58 Algerian Wilayas',
                hero_title_1: 'Future Generation of Education DZ',
                hero_title_2: 'مستقبل التعليم في الجزائر',
                hero_cta_web: 'Launch Web App (iPhone / PC / Web)',
                hero_cta_apk: 'Download Android APK',
                stat_wilayas: 'Algerian Wilayas',
                stat_sfu: 'SFU Live Capacity',
                stat_exams: 'BEM & BAC Papers',
                stat_pay: 'BaridiMob & CCP',
                omni_title: 'Learn & Teach Anywhere, On Any Device',
                roles_badge: 'Unified 3-Role Ecosystem',
                roles_title: 'Dedicated Workspaces for Students, Teachers & Parents',
                roles_sub: 'Switch roles below to explore Pindo Future capabilities'
            },
            fr: {
                dir: 'ltr',
                brand_sub: 'Future Generation of Education DZ',
                nav_features: 'Fonctionnalités',
                nav_roles: 'Élève • Prof • Parent',
                nav_security: 'Sécurité DRM',
                nav_payments: 'Paiement DZD',
                nav_exams: 'Banque BEM & BAC',
                nav_download: 'Télécharger',
                nav_faq: 'FAQ',
                nav_open_app: 'Ouvrir l’App',
                hero_badge: 'L’Avenir de l’Éducation en Algérie • Future Generation of Education DZ',
                hero_title_1: 'L’Avenir de l’Éducation en Algérie',
                hero_title_2: 'Future Generation of Education DZ',
                hero_cta_web: 'Ouvrir l’App Web (iPhone / PC / Tablet)',
                hero_cta_apk: 'Télécharger APK Android',
                stat_wilayas: 'Wilayas Couvertes',
                stat_sfu: 'Capacité Live SFU',
                stat_exams: 'Sujets BEM & BAC',
                stat_pay: 'BaridiMob & CCP',
                omni_title: 'Apprenez et Enseignez sur Tous Vos Appareils',
                roles_badge: 'Écosystème Unifié en 3 Espaces',
                roles_title: 'Un Espace Dédié pour Chaque Acteur Éducatif',
                roles_sub: 'Sélectionnez votre profil pour découvrir les outils Pindo Future'
            }
        };

        function setSiteLang(lang) {
            const dict = i18n[lang] || i18n.ar;
            document.documentElement.lang = lang;
            document.documentElement.dir = dict.dir;

            document.querySelectorAll('[data-i18n]').forEach(el => {
                const key = el.getAttribute('data-i18n');
                if (dict[key]) el.textContent = dict[key];
            });

            ['ar', 'en', 'fr'].forEach(l => {
                const btn = document.getElementById('lang-' + l);
                btn.className = l === lang
                    ? 'px-2 py-1 rounded-lg bg-cyan-500 text-slate-950 transition-all'
                    : 'px-2 py-1 rounded-lg text-slate-400 hover:text-white transition-all';
            });
        }
    </script>
</body>
</html>
<?php /**PATH C:\Users\Tech-Space\Downloads\38833FF26BA1D.UnigramPreview_g9c9v27vpyspw!App\pindo_future (1)\pindo_future\backend\resources\views/site/home.blade.php ENDPATH**/ ?>