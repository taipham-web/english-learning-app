import 'package:flutter/material.dart';
import 'core/themes/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/utils/auth_storage.dart';
import 'data/models/user_model.dart';
import 'routes/app_router.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/navigation/presentation/pages/main_navigation_page.dart';
import 'features/admin/presentation/pages/admin_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialPage() async {
    try {
      final isLoggedIn = await AuthStorage.isLoggedIn();
      if (isLoggedIn) {
        final user = await AuthStorage.getUser();
        if (user != null) {
          if (user.role == 'admin') {
            return AdminHomePage(user: user);
          } else {
            return MainNavigationPage(user: user);
          }
        }
      }
    } catch (e) {
      debugPrint('Error checking auth: $e');
    }
    return const LoginPage();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.light,
      onGenerateRoute: AppRouter.generateRoute,
      home: FutureBuilder<Widget>(
        future: _getInitialPage(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Splash screen đơn giản
            return Scaffold(
              backgroundColor: const Color(0xFF6C63FF),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.school,
                        size: 60,
                        color: Color(0xFF6C63FF),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'English App',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const CircularProgressIndicator(color: Colors.white),
                  ],
                ),
              ),
            );
          }
          return snapshot.data ?? const LoginPage();
        },
      ),
    );
  }
}
