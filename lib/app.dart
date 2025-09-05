import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

/* Core screens */
import 'screens/splash_screen.dart';
import 'screens/start_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';

/* Avatar picker */
import 'screens/profile/avatar_screen.dart';

/* Onboarding & misc */
import 'screens/onboarding/PracticeSiteScreen.dart';
import 'screens/onboarding/StudyPlansScreen.dart';
import 'screens/onboarding/learn_screen.dart';
import 'screens/onboarding/ai_screen.dart';
import 'screens/AI/resume_screen.dart';
import 'screens/AI/interview_screen.dart';
import 'screens/AI/interview_loader_screen.dart';

/* Main shell with bottom navigation */
import 'main_shell.dart';

import 'package:camera/camera.dart';

class AptiPrepApp extends StatefulWidget {
  final List<CameraDescription> cameras;

  const AptiPrepApp({super.key, required this.cameras});

  @override
  State<AptiPrepApp> createState() => _AptiPrepAppState();
}

class _AptiPrepAppState extends State<AptiPrepApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _setTheme(bool isDark) =>
      setState(() => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AptiPrep',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,

      initialRoute: SplashScreen.routeName,

      routes: {
        SplashScreen.routeName: (_) => const SplashScreen(),
        StartScreen.routeName: (_) => const StartScreen(),

        /* Auth */
        LoginScreen.routeName: (_) => const LoginScreen(),
        RegisterScreen.routeName: (_) => const RegisterScreen(),
        ForgotPasswordScreen.routeName: (_) => const ForgotPasswordScreen(),

        /* AI */
        ResumeScreen.routeName: (_) => const ResumeScreen(),
        InterviewLoaderScreen.routeName: (_) => const InterviewLoaderScreen(),
        '/interview': (_) => InterviewScreen(cameras: widget.cameras),

        /* Main shell (bottom nav) */
        MainShell.routeName:
            (_) => MainShell(
              onThemeChanged: _setTheme,
              initialIsDark: _themeMode == ThemeMode.dark,
            ),

        /* Onboarding / Practice */
        PracticeSiteScreen.routeName: (_) => const PracticeSiteScreen(),
        LearnScreen.routeName: (_) => const LearnScreen(),
        StudyPlansScreen.routeName: (_) => const StudyPlansScreen(),
        AiScreen.routeName: (_) => const AiScreen(),

        /* Avatar picker */
        AvatarScreen.routeName: (_) => const AvatarScreen(),
      },
    );
  }
}
