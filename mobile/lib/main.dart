import 'package:flutter/material.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/entities/user.dart';
import 'features/auth/domain/usecases/delete_account_usecase.dart';
import 'features/auth/domain/usecases/get_current_user_usecase.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/domain/usecases/logout_usecase.dart';
import 'features/auth/domain/usecases/register_usecase.dart';
import 'features/auth/presentation/controllers/auth_controller.dart';
import 'features/auth/presentation/screens/dashboards/admin_dashboard_screen.dart';
import 'features/auth/presentation/screens/dashboards/parent_dashboard_screen.dart';
import 'features/auth/presentation/screens/dashboards/student_dashboard_screen.dart';
import 'features/auth/presentation/screens/dashboards/teacher_dashboard_screen.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Instantiate Clean Architecture Auth Dependencies
  final apiClient = ApiClient();
  final remoteDataSource = AuthRemoteDataSourceImpl(apiClient: apiClient);
  final localDataSource = AuthLocalDataSourceImpl();
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );

  final authController = AuthController(
    loginUseCase: LoginUseCase(authRepository),
    registerUseCase: RegisterUseCase(authRepository),
    getCurrentUserUseCase: GetCurrentUserUseCase(authRepository),
    logoutUseCase: LogoutUseCase(authRepository),
    deleteAccountUseCase: DeleteAccountUseCase(authRepository),
  );

  // Check persisted session on boot
  authController.checkAuthSession();

  runApp(PindoFutureApp(authController: authController));
}

class PindoFutureApp extends StatefulWidget {
  final AuthController authController;

  const PindoFutureApp({super.key, required this.authController});

  @override
  State<PindoFutureApp> createState() => _PindoFutureAppState();
}

class _PindoFutureAppState extends State<PindoFutureApp> {
  bool _hasSeenSplash = false;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authController,
      builder: (context, _) {
        return MaterialApp(
          title: 'Pindo Future',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          home: AnimatedSwitcher(
            duration: const Duration(milliseconds: 650),
            switchInCurve: Curves.easeInOutCubic,
            switchOutCurve: Curves.easeInOutCubic,
            child: !_hasSeenSplash
                ? SplashScreen(
                    key: const ValueKey('splash_screen'),
                    authController: widget.authController,
                    onFinished: () {
                      if (mounted) {
                        setState(() {
                          _hasSeenSplash = true;
                        });
                      }
                    },
                  )
                : _resolveRootScreen(widget.authController),
          ),
        );
      },
    );
  }

  Widget _resolveRootScreen(AuthController controller) {
    // 1. Initial boot / token verification
    if (controller.status == AuthStatus.initial) {
      return const Scaffold(
        backgroundColor: Color(0xFF070B14),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF2DD4BF)),
              SizedBox(height: 16),
              Text(
                'Connecting to Pindo Future SFU Gateway...',
                style: TextStyle(fontSize: 13, color: Colors.white60),
              ),
            ],
          ),
        ),
      );
    }

    // 2. Role-Based Routing for Authenticated User
    if (controller.isAuthenticated && controller.currentUser != null) {
      final user = controller.currentUser!;
      switch (user.role) {
        case UserRole.admin:
          return AdminDashboardScreen(
            user: user,
            authController: controller,
          );
        case UserRole.teacher:
          return TeacherDashboardScreen(
            user: user,
            authController: controller,
          );
        case UserRole.student:
          return StudentDashboardScreen(
            user: user,
            authController: controller,
          );
        case UserRole.parent:
          return ParentDashboardScreen(
            user: user,
            authController: controller,
          );
      }
    }

    // 3. Unauthenticated: Show Login Screen
    return LoginScreen(authController: controller);
  }
}
