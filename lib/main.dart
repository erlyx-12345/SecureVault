import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'viewmodels/auth_viewmodel.dart';
import 'viewmodels/profile_viewmodel.dart';
import 'viewmodels/theme_viewmodel.dart';

import 'views/login_view.dart';
import 'views/register_view.dart';
import 'views/profile_view.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const SecureVaultApp());
}

class SecureVaultApp extends StatelessWidget {
  const SecureVaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
        ChangeNotifierProvider(
          create: (context) =>
              ProfileViewModel(authVM: context.read<AuthViewModel>()),
        ),
        ChangeNotifierProvider<ThemeViewModel>(
          create: (context) {
            final vm = ThemeViewModel();
            vm.loadTheme();
            return vm;
          },
        ),
      ],
      child: Consumer<ThemeViewModel>(
        builder: (context, themeVM, _) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: AppStrings.appName,
            theme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.light,
              scaffoldBackgroundColor: const Color(0xFFF7F7F7),
              primaryColor: AppColors.neonLime,
              secondaryHeaderColor: AppColors.darkOlive,
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: Color(0xFF2C2C2C)),
                labelLarge: TextStyle(color: Color(0xFF2C2C2C)),
                labelSmall: TextStyle(color: Color(0xFF757575)),
                bodySmall: TextStyle(color: Color(0xFF757575)),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: const Color(0xFFE8F5E9),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: const BorderSide(color: Color(0xFFC5E1A5), width: 1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: const BorderSide(color: Color(0xFFC5E1A5), width: 1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: const BorderSide(
                    color: AppColors.neonLime,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: const BorderSide(color: AppColors.error, width: 2),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonLime,
                  foregroundColor: const Color(0xFF2C2C2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.darkOlive,
                ),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFFE8F5E9),
                elevation: 0,
                iconTheme: IconThemeData(color: Color(0xFF2C2C2C)),
                titleTextStyle: TextStyle(
                  color: Color(0xFF2C2C2C),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              cardTheme: CardThemeData(
                color: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: Color(0xFFE0E0E0)),
                ),
              ),
            ),
            darkTheme: ThemeData(
              useMaterial3: true,
              brightness: Brightness.dark,
              scaffoldBackgroundColor: AppColors.darkBackground,
              primaryColor: AppColors.neonLime,
              secondaryHeaderColor: AppColors.darkOlive,
              textTheme: const TextTheme(
                bodyMedium: TextStyle(color: AppColors.textPrimary),
                labelLarge: TextStyle(color: AppColors.textPrimary),
                labelSmall: TextStyle(color: AppColors.textHint),
                bodySmall: TextStyle(color: AppColors.textHint),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: AppColors.charcoal,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 18,
                ),
                hintStyle: const TextStyle(color: AppColors.textHint),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: const BorderSide(color: AppColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: const BorderSide(
                    color: AppColors.borderFocus,
                    width: 2,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: const BorderSide(color: AppColors.error),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  borderSide: const BorderSide(color: AppColors.error, width: 2),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonLime,
                  foregroundColor: AppColors.darkBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.neonLime,
                ),
              ),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1A1A1A),
                elevation: 0,
                iconTheme: IconThemeData(color: AppColors.neonLime),
                titleTextStyle: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              cardTheme: CardThemeData(
                color: const Color(0xFF2A2A2A),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                  side: const BorderSide(color: AppColors.borderLight),
                ),
              ),
            ),
            themeMode: themeVM.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            home: const _AuthWrapper(),
            routes: {
              '/login': (_) => const LoginView(),
              '/register': (_) => const RegisterView(),
              '/profile': (_) => const ProfileView(),
            },
          );
        },
      ),
    );
  }
}

/// AuthWrapper handles routing based on authentication state
class _AuthWrapper extends StatefulWidget {
  const _AuthWrapper();

  @override
  State<_AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<_AuthWrapper> {
  @override
  void initState() {
    super.initState();

    // ✅ Delay initialization until after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAuth();
    });
  }

  void _initializeAuth() {
    context.read<AuthViewModel>().initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthViewModel>(
      builder: (context, authVM, _) {
        if (authVM.isLoading) {
          return Scaffold(
            body: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [AppColors.darkOlive, AppColors.neonLime],
                ),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.neonLime),
              ),
            ),
          );
        }

        if (authVM.isAuthenticated) {
          return const ProfileView();
        } else {
          return const LoginView();
        }
      },
    );
  }
}
