import 'package:flutter/material.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/topics/presentation/pages/topics_page.dart';
import '../features/topics/presentation/pages/topic_lessons_page.dart';
import '../features/topics/presentation/pages/lesson_detail_page.dart';
import '../features/topics/pages/saved_vocabularies_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/admin/presentation/pages/admin_home_page.dart';
import '../features/admin/presentation/pages/admin_topics_page.dart';
import '../features/admin/presentation/pages/admin_topic_lessons_page.dart';
import '../features/admin/presentation/pages/admin_lesson_vocabulary_page.dart';
import '../data/models/topic_model.dart';
import '../data/models/lesson_model.dart';

class AppRouter {
  static const String login = '/';
  static const String register = '/register';
  static const String home = '/home';
  static const String topics = '/topics';
  static const String profile = '/profile';
  static const String savedVocabularies = '/saved-vocabularies';

  // Admin routes
  static const String adminHome = '/admin';
  static const String adminTopics = '/admin/topics';
  static const String adminTopicLessons = '/admin/topic-lessons';
  static const String adminLessons = '/admin/lessons';
  static const String adminLessonVocabulary = '/admin/lesson-vocabulary';
  static const String adminQuizzes = '/admin/quizzes';
  static const String adminUsers = '/admin/users';

  // Student routes
  static const String topicLessons = '/topic-lessons';
  static const String lessonDetail = '/lesson-detail';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginPage());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterPage());
      case home:
        dynamic user;
        if (settings.arguments is Map<String, dynamic>) {
          user = (settings.arguments as Map<String, dynamic>)['user'];
        } else {
          user = settings.arguments;
        }
        return MaterialPageRoute(builder: (_) => HomePage(user: user));
      case savedVocabularies:
        return MaterialPageRoute(builder: (_) => const SavedVocabulariesPage());
      case topics:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => TopicsPage(userLevel: args?['userLevel'] as String?),
        );
      case profile:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ProfilePage(userId: args['userId']),
        );

      // Admin routes
      case adminHome:
        dynamic user;
        if (settings.arguments is Map<String, dynamic>) {
          user = (settings.arguments as Map<String, dynamic>)['user'];
        } else {
          user = settings.arguments;
        }
        return MaterialPageRoute(builder: (_) => AdminHomePage(user: user));
      case adminTopics:
        return MaterialPageRoute(builder: (_) => const AdminTopicsPage());
      case adminTopicLessons:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              AdminTopicLessonsPage(topic: args['topic'] as TopicModel),
        );
      case adminLessons:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Quản lý Bài học - Đang phát triển')),
          ),
        );
      case adminLessonVocabulary:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              AdminLessonVocabularyPage(lesson: args['lesson'] as LessonModel),
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

      // Student routes
      case topicLessons:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => TopicLessonsPage(
            topic: args['topic'] as TopicModel,
            userLevel: args['userLevel'] as String?,
          ),
        );
      case lessonDetail:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) =>
              LessonDetailPage(lesson: args['lesson'] as LessonModel),
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
