import 'package:flutter/material.dart';
import '../../../../data/models/lesson_model.dart';
import '../../../../data/models/quiz_model.dart';
import '../../../../data/datasources/quiz_service.dart';

class AdminQuizEditorPage extends StatefulWidget {
  final LessonModel lesson;

  const AdminQuizEditorPage({super.key, required this.lesson});

  @override
  State<AdminQuizEditorPage> createState() => _AdminQuizEditorPageState();
}

class _AdminQuizEditorPageState extends State<AdminQuizEditorPage> {
  final QuizService _quizService = QuizService();
  final _formKey = GlobalKey<FormState>();

  // Quiz info
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  int _passingScore = 70;
  int _timeLimit = 600; // 10 minutes in seconds

  // Questions
  List<QuestionData> _questions = [];
  bool _isLoading = true;
  bool _isSaving = false;
  int? _existingQuizId;

  @override
  void initState() {
    super.initState();
    _titleController.text = '${widget.lesson.title} - Quiz';
    _loadExistingQuiz();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingQuiz() async {
    setState(() => _isLoading = true);

    final result = await _quizService.getQuizByLessonId(widget.lesson.id);

    if (mounted) {
      if (result['success'] && result['quiz'] != null) {
        final quiz = result['quiz'] as QuizModel;
        setState(() {
          _existingQuizId = quiz.id;
          _titleController.text = quiz.title;
          _descriptionController.text = quiz.description ?? '';
          _passingScore = quiz.passingScore;
          _timeLimit = quiz.timeLimit;
          _questions = quiz.questions.map((q) {
            // Extract option contents
            final optionContents = q.options.map((o) => o.content).toList();

            // Find the correct answer (the option letter A, B, C, D)
            final correctIndex = q.options.indexWhere((o) => o.isCorrect);
            final correctAnswer = correctIndex >= 0
                ? String.fromCharCode(65 + correctIndex) // A, B, C, D
                : '';

            return QuestionData(
              id: q.id,
              questionText: q.content,
              questionType: q.type,
              options: optionContents,
              correctAnswer: correctAnswer,
            );
          }).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _addQuestion(); // Add first empty question
        });
      }
    }
  }

  void _addQuestion() {
    setState(() {
      _questions.add(
        QuestionData(
          questionText: '',
          questionType: 'multiple_choice',
          options: ['', '', '', ''],
          correctAnswer: '',
        ),
      );
    });
  }

  void _removeQuestion(int index) {
    setState(() {
      _questions.removeAt(index);
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng điền đầy đủ thông tin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng thêm ít nhất 1 câu hỏi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate all questions
    for (int i = 0; i < _questions.length; i++) {
      final q = _questions[i];
      if (q.questionText.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Câu hỏi ${i + 1}: Vui lòng nhập nội dung câu hỏi'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      if (q.correctAnswer.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Câu hỏi ${i + 1}: Vui lòng chọn đáp án đúng'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      for (int j = 0; j < q.options.length; j++) {
        if (q.options[j].trim().isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Câu hỏi ${i + 1}: Vui lòng điền đáp án ${String.fromCharCode(65 + j)}',
              ),
              backgroundColor: Colors.orange,
            ),
          );
          return;
        }
      }
    }

    setState(() => _isSaving = true);

    // Convert questions to server format
    final questionsForServer = _questions.map((q) {
      // Find the index of the correct answer (A=0, B=1, C=2, D=3)
      final correctIndex = q.correctAnswer.isNotEmpty
          ? q.correctAnswer.codeUnitAt(0) -
                65 // 'A' = 65 in ASCII
          : -1;

      return {
        'content': q.questionText.trim(),
        'type': q.questionType,
        'options': q.options.asMap().entries.map((entry) {
          return {
            'content': entry.value.trim(),
            'is_correct': entry.key == correctIndex,
          };
        }).toList(),
      };
    }).toList();

    final result = _existingQuizId != null
        ? await _quizService.updateQuiz(
            quizId: _existingQuizId!,
            lessonId: widget.lesson.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            passingScore: _passingScore,
            timeLimit: _timeLimit,
            questions: questionsForServer,
          )
        : await _quizService.createQuiz(
            lessonId: widget.lesson.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            questions: questionsForServer,
          );

    if (mounted) {
      setState(() => _isSaving = false);

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _existingQuizId != null
                  ? 'Cập nhật quiz thành công!'
                  : 'Tạo quiz thành công!',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Có lỗi xảy ra'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _existingQuizId != null ? 'Chỉnh sửa Quiz' : 'Tạo Quiz mới',
          style: const TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save, color: Color(0xFF6C63FF)),
              onPressed: _saveQuiz,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
              ),
            )
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildLessonInfo(),
                  const SizedBox(height: 24),
                  _buildQuizSettings(),
                  const SizedBox(height: 24),
                  _buildQuestionsSection(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
      floatingActionButton: _isLoading
          ? null
          : FloatingActionButton.extended(
              onPressed: _addQuestion,
              backgroundColor: const Color(0xFF6C63FF),
              icon: const Icon(Icons.add),
              label: const Text('Thêm câu hỏi'),
            ),
    );
  }

  Widget _buildLessonInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bài học',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 8),
          Text(
            widget.lesson.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (widget.lesson.topicName != null) ...[
            const SizedBox(height: 4),
            Text(
              widget.lesson.topicName!,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuizSettings() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin Quiz',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Tiêu đề Quiz',
              prefixIcon: const Icon(Icons.title),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập tiêu đề';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: InputDecoration(
              labelText: 'Mô tả (tùy chọn)',
              prefixIcon: const Icon(Icons.description),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Điểm đạt (%)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '$_passingScore%',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: () {
                                  if (_passingScore > 0) {
                                    setState(() => _passingScore -= 5);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: () {
                                  if (_passingScore < 100) {
                                    setState(() => _passingScore += 5);
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thời gian (phút)',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '${_timeLimit ~/ 60}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6C63FF),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: () {
                                  if (_timeLimit > 60) {
                                    setState(() => _timeLimit -= 60);
                                  }
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, size: 20),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed: () {
                                  setState(() => _timeLimit += 60);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Câu hỏi',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_questions.length}',
                style: const TextStyle(
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_questions.isEmpty)
          Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(Icons.quiz_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'Chưa có câu hỏi',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhấn nút + để thêm câu hỏi',
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          )
        else
          ...List.generate(_questions.length, (index) {
            return _buildQuestionCard(index);
          }),
      ],
    );
  }

  Widget _buildQuestionCard(int index) {
    final question = _questions[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'Câu ${index + 1}',
                  style: const TextStyle(
                    color: Color(0xFF6C63FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: () => _removeQuestion(index),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            initialValue: question.questionText,
            decoration: InputDecoration(
              labelText: 'Nội dung câu hỏi',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 2,
            onChanged: (value) {
              question.questionText = value;
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Đáp án',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(4, (optionIndex) {
            final optionLetter = String.fromCharCode(65 + optionIndex);
            final isCorrect = question.correctAnswer == optionLetter;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Radio<String>(
                    value: optionLetter,
                    groupValue: question.correctAnswer,
                    onChanged: (value) {
                      setState(() {
                        question.correctAnswer = value!;
                      });
                    },
                    activeColor: const Color(0xFF6C63FF),
                  ),
                  Expanded(
                    child: TextFormField(
                      initialValue: question.options[optionIndex],
                      decoration: InputDecoration(
                        labelText: 'Đáp án $optionLetter',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: isCorrect,
                        fillColor: isCorrect
                            ? const Color(0xFF6C63FF).withOpacity(0.1)
                            : null,
                      ),
                      onChanged: (value) {
                        question.options[optionIndex] = value;
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class QuestionData {
  int? id;
  String questionText;
  String questionType;
  List<String> options;
  String correctAnswer;

  QuestionData({
    this.id,
    required this.questionText,
    required this.questionType,
    required this.options,
    required this.correctAnswer,
  });
}
