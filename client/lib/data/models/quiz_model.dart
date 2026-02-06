class QuizModel {
  final int id;
  final int lessonId;
  final String title;
  final String? description;
  final int passingScore;
  final int timeLimit; // in seconds
  final List<QuizQuestion> questions;

  QuizModel({
    required this.id,
    required this.lessonId,
    required this.title,
    this.description,
    this.passingScore = 70,
    this.timeLimit = 600,
    required this.questions,
  });

  factory QuizModel.fromJson(Map<String, dynamic> json) {
    return QuizModel(
      id: json['id'] as int,
      lessonId: json['lesson_id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      passingScore: json['passing_score'] as int? ?? 70,
      timeLimit: json['time_limit'] as int? ?? 600,
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lesson_id': lessonId,
      'title': title,
      'description': description,
      'passing_score': passingScore,
      'time_limit': timeLimit,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

class QuizQuestion {
  final int id;
  final int quizId;
  final String content;
  final String type; // 'multiple_choice', 'true_false', etc.
  final String? explanation;
  final List<QuizOption> options;

  QuizQuestion({
    required this.id,
    required this.quizId,
    required this.content,
    required this.type,
    this.explanation,
    required this.options,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'] as int,
      quizId: json['quiz_id'] as int,
      content: json['content'] as String,
      type: json['type'] as String? ?? 'multiple_choice',
      explanation: json['explanation'] as String?,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((o) => QuizOption.fromJson(o as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quiz_id': quizId,
      'content': content,
      'type': type,
      'explanation': explanation,
      'options': options.map((o) => o.toJson()).toList(),
    };
  }
}

class QuizOption {
  final int id;
  final int questionId;
  final String content;
  final bool isCorrect;

  QuizOption({
    required this.id,
    required this.questionId,
    required this.content,
    required this.isCorrect,
  });

  factory QuizOption.fromJson(Map<String, dynamic> json) {
    return QuizOption(
      id: json['id'] as int,
      questionId: json['question_id'] as int,
      content: json['content'] as String,
      isCorrect: (json['is_correct'] == 1 || json['is_correct'] == true),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_id': questionId,
      'content': content,
      'is_correct': isCorrect,
    };
  }
}

class QuizSubmission {
  final int userId;
  final List<QuizAnswer> answers;
  final int? timeSpent; // in seconds

  QuizSubmission({required this.userId, required this.answers, this.timeSpent});

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'answers': answers.map((a) => a.toJson()).toList(),
      'time_spent': timeSpent,
    };
  }
}

class QuizAnswer {
  final int questionId;
  final int selectedOptionId;

  QuizAnswer({required this.questionId, required this.selectedOptionId});

  Map<String, dynamic> toJson() {
    return {'question_id': questionId, 'selected_option_id': selectedOptionId};
  }
}

class QuizResult {
  final int resultId;
  final int score;
  final int totalQuestions;
  final double percentage;
  final bool passed;

  QuizResult({
    required this.resultId,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    required this.passed,
  });

  factory QuizResult.fromJson(Map<String, dynamic> json) {
    return QuizResult(
      resultId: json['result_id'] as int,
      score: json['score'] as int,
      totalQuestions: json['total_questions'] as int,
      percentage: double.parse(json['percentage'].toString()),
      passed: json['passed'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'result_id': resultId,
      'score': score,
      'total_questions': totalQuestions,
      'percentage': percentage,
      'passed': passed,
    };
  }
}

class QuizHistory {
  final int id;
  final int userId;
  final int quizId;
  final int score;
  final int totalQuestions;
  final double percentage;
  final int? timeSpent;
  final DateTime completedAt;
  final String? quizTitle;
  final int? lessonId;
  final String? lessonTitle;

  QuizHistory({
    required this.id,
    required this.userId,
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.percentage,
    this.timeSpent,
    required this.completedAt,
    this.quizTitle,
    this.lessonId,
    this.lessonTitle,
  });

  factory QuizHistory.fromJson(Map<String, dynamic> json) {
    return QuizHistory(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      quizId: json['quiz_id'] as int,
      score: json['score'] as int,
      totalQuestions: json['total_questions'] as int,
      percentage: double.parse(json['percentage'].toString()),
      timeSpent: json['time_spent'] as int?,
      completedAt: DateTime.parse(json['completed_at'] as String),
      quizTitle: json['quiz_title'] as String?,
      lessonId: json['lesson_id'] as int?,
      lessonTitle: json['lesson_title'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'quiz_id': quizId,
      'score': score,
      'total_questions': totalQuestions,
      'percentage': percentage,
      'time_spent': timeSpent,
      'completed_at': completedAt.toIso8601String(),
      'quiz_title': quizTitle,
      'lesson_id': lessonId,
      'lesson_title': lessonTitle,
    };
  }
}

class QuizStats {
  final int totalAttempts;
  final double averageScore;
  final double bestScore;
  final int passedCount;

  QuizStats({
    required this.totalAttempts,
    required this.averageScore,
    required this.bestScore,
    required this.passedCount,
  });

  factory QuizStats.fromJson(Map<String, dynamic> json) {
    return QuizStats(
      totalAttempts: json['total_attempts'] as int,
      averageScore: double.parse(json['average_score']?.toString() ?? '0'),
      bestScore: double.parse(json['best_score']?.toString() ?? '0'),
      passedCount: json['passed_count'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_attempts': totalAttempts,
      'average_score': averageScore,
      'best_score': bestScore,
      'passed_count': passedCount,
    };
  }
}
