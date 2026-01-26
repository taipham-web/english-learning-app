import 'package:flutter/material.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/topics/presentation/pages/topics_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/admin/presentation/pages/admin_home_page.dart';
import '../features/admin/presentation/pages/admin_topics_page.dart';

class AppRouter {
  static const String login = '/';
  static const String register = '/register';
  static const String home = '/home';
  static const String topics = '/topics';
  static const String profile = '/profile';

  // Admin routes
  static const String adminHome = '/admin';
  static const String adminTopics = '/admin/topics';
  static const String adminLessons = '/admin/lessons';
  static const String adminQuizzes = '/admin/quizzes';
  static const String adminUsers = '/admin/users';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case home:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(builder: (_) => HomePage(user: args?['user']));
      case topics:
        return MaterialPageRoute(builder: (_) => const TopicsPage());
      case profile:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProfilePage(userId: args['userId']),
        );

      // Admin routes
      case adminHome:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AdminHomePage(user: args?['user']),
        );
      case adminTopics:
        return MaterialPageRoute(builder: (_) => const AdminTopicsPage());
      case adminLessons:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Quản lý Bài học - Đang phát triển')),
          ),
        );
      case adminQuizzes:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Quản lý Bài kiểm tra - Đang phát triển')),
          ),
        );
      case adminUsers:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Quản lý Người dùng - Đang phát triển')),
          ),
        );

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
