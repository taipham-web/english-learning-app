import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../data/models/vocabulary_model.dart';
import '../../../../data/models/lesson_model.dart';
import '../../../../data/datasources/saved_vocabulary_service.dart';
import '../../../../data/datasources/learning_progress_service.dart';
import '../../../../core/utils/auth_storage.dart';
import 'vocabulary_quiz_page.dart';

class VocabularyLearningPage extends StatefulWidget {
  final LessonModel? lesson;
  final List<VocabularyModel> vocabularies;
  final String? customTitle;

  const VocabularyLearningPage({
    super.key,
    this.lesson,
    required this.vocabularies,
    this.customTitle,
  });

  String get title => customTitle ?? lesson?.title ?? 'Học từ vựng';

  @override
  State<VocabularyLearningPage> createState() => _VocabularyLearningPageState();
}

class _VocabularyLearningPageState extends State<VocabularyLearningPage>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SavedVocabularyService _savedVocabularyService =
      SavedVocabularyService();
  final LearningProgressService _learningProgressService =
      LearningProgressService();

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;
  late AnimationController _progressController;

  int _currentIndex = 0;
  bool _showMeaning = false;

  // Saved vocabularies state
  int? _userId;
  Set<int> _savedIds = {};
  bool _isLoadingSaved = true;

  // Gradient colors for cards
  final List<List<Color>> _cardGradients = [
    [const Color(0xFF667EEA), const Color(0xFF764BA2)],
    [const Color(0xFF11998E), const Color(0xFF38EF7D)],
    [const Color(0xFFF093FB), const Color(0xFFF5576C)],
    [const Color(0xFF4FACFE), const Color(0xFF00F2FE)],
    [const Color(0xFFFA709A), const Color(0xFFFEE140)],
    [const Color(0xFF6C63FF), const Color(0xFF5A52E0)],
  ];

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    _progressController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _loadUserAndSavedVocabularies();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio(widget.vocabularies[0].audioUrl);
      _progressController.forward();
    });
  }

  Future<void> _loadUserAndSavedVocabularies() async {
    final user = await AuthStorage.getUser();
    if (user != null && mounted) {
      setState(() {
        _userId = user.id;
      });
      _loadSavedIds();
    } else {
      setState(() {
        _isLoadingSaved = false;
      });
    }
  }

  Future<void> _loadSavedIds() async {
    if (_userId == null) return;

    final result = await _savedVocabularyService.getSavedIds(_userId!);
    if (mounted) {
      setState(() {
        _isLoadingSaved = false;
        if (result['success']) {
          _savedIds = Set<int>.from(result['savedIds'] ?? []);
        }
      });
    }
  }

  Future<void> _toggleSaveVocabulary(int vocabularyId) async {
    if (_userId == null) {
      _showSnackBar('Vui lòng đăng nhập để lưu từ vựng', Colors.orange);
      return;
    }

    final result = await _savedVocabularyService.toggleSave(
      _userId!,
      vocabularyId,
    );
    if (mounted) {
      if (result['success']) {
        setState(() {
          if (result['isSaved'] == true) {
            _savedIds.add(vocabularyId);
          } else {
            _savedIds.remove(vocabularyId);
          }
        });
        _showSnackBar(
          result['isSaved'] == true ? 'Đã lưu từ vựng' : 'Đã bỏ lưu',
          result['isSaved'] == true ? const Color(0xFF4CAF50) : Colors.grey,
        );
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    _flipController.dispose();
    _progressController.dispose();
    super.dispose();
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

  void _toggleCard() {
    setState(() {
      _showMeaning = !_showMeaning;
      if (_showMeaning) {
        _flipController.forward();
      } else {
        _flipController.reverse();
      }
    });
  }

  void _nextCard() {
    if (_currentIndex < widget.vocabularies.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _showCompletionDialog();
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  List<Color> _getCurrentGradient() {
    return _cardGradients[_currentIndex % _cardGradients.length];
  }

  void _showCompletionDialog() async {
    int? streak;
    final lesson = widget.lesson;
    final lessonId = lesson?.id;
    if (_userId != null && lessonId != null) {
      final result = await _learningProgressService.completeLesson(
        _userId!,
        lessonId,
      );
      if (result['success'] && result['data'] != null) {
        streak = result['data']['streak'];
      }
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success icon
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 24),

              // Title
              const Text(
                'Hoàn thành! 🎉',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 12),

              // Stats
              Text(
                'Bạn đã học xong ${widget.vocabularies.length} từ vựng',
                style: const TextStyle(fontSize: 16, color: Color(0xFF7C7C8A)),
                textAlign: TextAlign.center,
              ),

              // Streak badge
              if (streak != null && streak > 0) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF9800), Color(0xFFFFB74D)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.local_fire_department,
                        color: Colors.white,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Chuỗi: $streak ngày',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 8),
              const Text(
                'Sẵn sàng kiểm tra chưa?',
                style: TextStyle(color: Color(0xFF7C7C8A)),
              ),
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Thoát',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF7C7C8A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => VocabularyQuizPage(
                              lesson: widget.lesson,
                              vocabularies: widget.vocabularies,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.quiz_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Làm quiz',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentVocab = widget.vocabularies[_currentIndex];
    final isSaved = _savedIds.contains(currentVocab.id);
    final gradient = _getCurrentGradient();

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradient[0], gradient[1]],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(isSaved, currentVocab),
              _buildProgressBar(),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                      _showMeaning = false;
                      _flipController.reset();
                    });
                    _playAudio(widget.vocabularies[index].audioUrl);
                  },
                  itemCount: widget.vocabularies.length,
                  itemBuilder: (context, index) {
                    return _buildFlashcard(widget.vocabularies[index]);
                  },
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(bool isSaved, VocabularyModel currentVocab) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Close button
          GestureDetector(
            onTap: _showExitDialog,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 22,
              ),
            ),
          ),
          const Spacer(),

          // Title
          Text(
            widget.title,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const Spacer(),

          // Bookmark button
          if (!_isLoadingSaved && _userId != null)
            GestureDetector(
              onTap: () => _toggleSaveVocabulary(currentVocab.id!),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSaved
                      ? Colors.amber.withOpacity(0.3)
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSaved
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: isSaved ? Colors.amber : Colors.white,
                  size: 22,
                ),
              ),
            )
          else
            const SizedBox(width: 42),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Từ ${_currentIndex + 1} / ${widget.vocabularies.length}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${((_currentIndex + 1) / widget.vocabularies.length * 100).toInt()}%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress dots
          Row(
            children: List.generate(widget.vocabularies.length, (index) {
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(
                    right: index < widget.vocabularies.length - 1 ? 4 : 0,
                  ),
                  decoration: BoxDecoration(
                    color: index <= _currentIndex
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard(VocabularyModel vocab) {
    return GestureDetector(
      onTap: _toggleCard,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: AnimatedBuilder(
          animation: _flipAnimation,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(_flipAnimation.value * 3.14159),
              child: _flipAnimation.value < 0.5
                  ? _buildCardFront(vocab)
                  : Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()..rotateY(3.14159),
                      child: _buildCardBack(vocab),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildCardFront(VocabularyModel vocab) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Word
            Text(
              vocab.word,
              style: const TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
                letterSpacing: 1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Phonetic
            if (vocab.phonetic != null && vocab.phonetic!.isNotEmpty)
              Text(
                vocab.phonetic!,
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[500],
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 40),

            // Audio button
            GestureDetector(
              onTap: () => _playAudio(vocab.audioUrl),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getCurrentGradient(),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getCurrentGradient()[0].withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.volume_up_rounded,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // Hint
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5FA),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    color: Colors.grey[400],
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Nhấn để xem nghĩa',
                    style: TextStyle(color: Colors.grey[500], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(VocabularyModel vocab) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getCurrentGradient(),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: _getCurrentGradient()[0].withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Word (smaller)
            Text(
              vocab.word,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            if (vocab.phonetic != null && vocab.phonetic!.isNotEmpty)
              Text(
                vocab.phonetic!,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 24),

            // Divider
            Container(
              width: 80,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),

            // Meaning
            Text(
              vocab.meaning,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),

            // Audio button
            GestureDetector(
              onTap: () => _playAudio(vocab.audioUrl),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volume_up_rounded,
                  size: 32,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Row(
        children: [
          // Previous button
          Expanded(
            child: _buildNavButton(
              onPressed: _currentIndex > 0 ? _previousCard : null,
              icon: Icons.arrow_back_rounded,
              label: 'Trước',
              isOutlined: true,
            ),
          ),
          const SizedBox(width: 12),

          // Flip button
          Expanded(
            flex: 2,
            child: _buildNavButton(
              onPressed: _toggleCard,
              icon: _showMeaning
                  ? Icons.flip_to_front_rounded
                  : Icons.flip_to_back_rounded,
              label: _showMeaning ? 'Mặt trước' : 'Xem nghĩa',
              isOutlined: false,
              isPrimary: true,
            ),
          ),
          const SizedBox(width: 12),

          // Next button
          Expanded(
            child: _buildNavButton(
              onPressed: _nextCard,
              icon: _currentIndex < widget.vocabularies.length - 1
                  ? Icons.arrow_forward_rounded
                  : Icons.check_rounded,
              label: _currentIndex < widget.vocabularies.length - 1
                  ? 'Tiếp'
                  : 'Xong',
              isOutlined: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    bool isOutlined = false,
    bool isPrimary = false,
  }) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary
            ? Colors.white
            : isOutlined
            ? Colors.white.withOpacity(0.2)
            : Colors.white.withOpacity(0.15),
        foregroundColor: isPrimary ? _getCurrentGradient()[0] : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: isPrimary ? 8 : 0,
        shadowColor: isPrimary
            ? Colors.black.withOpacity(0.2)
            : Colors.transparent,
        disabledBackgroundColor: Colors.white.withOpacity(0.1),
        disabledForegroundColor: Colors.white.withOpacity(0.4),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (!isPrimary && label == 'Trước') Icon(icon, size: 18),
          if (isPrimary ||
              (!isPrimary &&
                  label != 'Trước' &&
                  label != 'Tiếp' &&
                  label != 'Xong'))
            Icon(icon, size: 20),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isPrimary ? FontWeight.bold : FontWeight.w600,
            ),
          ),
          if (!isPrimary && (label == 'Tiếp' || label == 'Xong'))
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Icon(icon, size: 18),
            ),
        ],
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: Colors.orange.shade400,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Thoát học?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Tiến trình học sẽ không được lưu.\nBạn có chắc muốn thoát?',
                style: TextStyle(color: Colors.grey[600], fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                      child: const Text(
                        'Tiếp tục học',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
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
                        backgroundColor: Colors.red.shade400,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Thoát',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
