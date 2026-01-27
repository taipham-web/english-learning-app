import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../data/models/vocabulary_model.dart';
import '../../../../data/models/lesson_model.dart';

class VocabularyQuizPage extends StatefulWidget {
  final LessonModel? lesson;
  final List<VocabularyModel> vocabularies;
  final String? customTitle;

  const VocabularyQuizPage({
    super.key,
    this.lesson,
    required this.vocabularies,
    this.customTitle,
  });

  String get title => customTitle ?? lesson?.title ?? 'Kiểm tra từ vựng';

  @override
  State<VocabularyQuizPage> createState() => _VocabularyQuizPageState();
}

class _VocabularyQuizPageState extends State<VocabularyQuizPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final Random _random = Random();

  late List<QuizQuestion> _questions;
  int _currentQuestionIndex = 0;
  int _correctAnswers = 0;
  int? _selectedAnswerIndex;
  bool _hasAnswered = false;

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _generateQuestions() {
    _questions = [];
    final vocabList = List<VocabularyModel>.from(widget.vocabularies);
    vocabList.shuffle(_random);

    // Take up to 10 questions
    final questionCount = min(10, vocabList.length);

    for (int i = 0; i < questionCount; i++) {
      final correctVocab = vocabList[i];

      // Generate wrong options
      final wrongOptions =
          widget.vocabularies.where((v) => v.id != correctVocab.id).toList()
            ..shuffle(_random);

      final options = [correctVocab, ...wrongOptions.take(3)];
      options.shuffle(_random);

      final correctIndex = options.indexOf(correctVocab);

      // Randomly choose question type
      final questionType = _random.nextBool()
          ? QuestionType.wordToMeaning
          : QuestionType.listenToWord;

      _questions.add(
        QuizQuestion(
          vocabulary: correctVocab,
          options: options,
          correctIndex: correctIndex,
          type: questionType,
        ),
      );
    }
  }

  Future<void> _playAudio(String? url) async {
    if (url != null && url.isNotEmpty) {
      try {
        await _audioPlayer.stop();
        await _audioPlayer.play(UrlSource(url));
      } catch (e) {
        debugPrint('Error playing audio: $e');
      }
    }
  }

  void _selectAnswer(int index) {
    if (_hasAnswered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _hasAnswered = true;

      if (index == _questions[_currentQuestionIndex].correctIndex) {
        _correctAnswers++;
      }
    });

    // Auto advance after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = null;
        _hasAnswered = false;
      });

      // Auto play audio for listen questions
      if (_questions[_currentQuestionIndex].type == QuestionType.listenToWord) {
        _playAudio(_questions[_currentQuestionIndex].vocabulary.audioUrl);
      }
    } else {
      _showResultDialog();
    }
  }

  void _showResultDialog() {
    final percentage = (_correctAnswers / _questions.length * 100).toInt();
    final isPassed = percentage >= 70;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Result icon
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isPassed ? Colors.green.shade50 : Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                isPassed ? Icons.emoji_events : Icons.sentiment_satisfied,
                size: 64,
                color: isPassed ? Colors.amber : Colors.orange,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              isPassed ? 'Xuất sắc! 🎉' : 'Cố gắng thêm! 💪',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            // Score
            Text(
              '$_correctAnswers/${_questions.length} câu đúng',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),

            // Percentage
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isPassed ? Colors.green : Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '$percentage%',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Message
            Text(
              isPassed
                  ? 'Bạn đã nắm vững từ vựng bài này!'
                  : 'Hãy học lại và thử lại nhé!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _currentQuestionIndex = 0;
                        _correctAnswers = 0;
                        _selectedAnswerIndex = null;
                        _hasAnswered = false;
                        _generateQuestions();
                      });
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Làm lại'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Hoàn thành'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => _showExitDialog(),
        ),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress bar
          _buildProgressBar(),

          // Question area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Question card
                  _buildQuestionCard(question),

                  const SizedBox(height: 24),

                  // Options
                  Expanded(child: _buildOptions(question)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Container(
      color: const Color(0xFF6C63FF),
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Câu ${_currentQuestionIndex + 1}/${_questions.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: Colors.greenAccent,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_correctAnswers',
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / _questions.length,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(QuizQuestion question) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Question type icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                question.type == QuestionType.listenToWord
                    ? Icons.headphones
                    : Icons.translate,
                size: 32,
                color: const Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 16),

            // Question text
            Text(
              question.type == QuestionType.listenToWord
                  ? 'Nghe và chọn từ đúng'
                  : 'Chọn nghĩa đúng của từ',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Word or audio
            if (question.type == QuestionType.listenToWord) ...[
              GestureDetector(
                onTap: () => _playAudio(question.vocabulary.audioUrl),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.volume_up, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Text(
                        'Phát âm thanh',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              Text(
                question.vocabulary.word,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D2D2D),
                ),
              ),
              if (question.vocabulary.phonetic != null)
                Text(
                  question.vocabulary.phonetic!,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOptions(QuizQuestion question) {
    return ListView.builder(
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final option = question.options[index];
        final isSelected = _selectedAnswerIndex == index;
        final isCorrect = index == question.correctIndex;

        Color? backgroundColor;
        Color? borderColor;
        Color textColor = const Color(0xFF2D2D2D);

        if (_hasAnswered) {
          if (isCorrect) {
            backgroundColor = Colors.green.shade50;
            borderColor = Colors.green;
            textColor = Colors.green.shade700;
          } else if (isSelected && !isCorrect) {
            backgroundColor = Colors.red.shade50;
            borderColor = Colors.red;
            textColor = Colors.red.shade700;
          }
        } else if (isSelected) {
          backgroundColor = const Color(0xFF6C63FF).withOpacity(0.1);
          borderColor = const Color(0xFF6C63FF);
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: _hasAnswered ? null : () => _selectAnswer(index),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor ?? Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Option letter
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color:
                          borderColor?.withOpacity(0.2) ?? Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        String.fromCharCode(65 + index), // A, B, C, D
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: borderColor ?? Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Option text
                  Expanded(
                    child: Text(
                      question.type == QuestionType.listenToWord
                          ? option.word
                          : option.meaning,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: textColor,
                      ),
                    ),
                  ),

                  // Result icon
                  if (_hasAnswered && (isCorrect || isSelected))
                    Icon(
                      isCorrect ? Icons.check_circle : Icons.cancel,
                      color: isCorrect ? Colors.green : Colors.red,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Thoát bài kiểm tra?'),
        content: const Text(
          'Kết quả sẽ không được lưu. Bạn có chắc muốn thoát?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tiếp tục'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Thoát', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

enum QuestionType { wordToMeaning, listenToWord }

class QuizQuestion {
  final VocabularyModel vocabulary;
  final List<VocabularyModel> options;
  final int correctIndex;
  final QuestionType type;

  QuizQuestion({
    required this.vocabulary,
    required this.options,
    required this.correctIndex,
    required this.type,
  });
}
