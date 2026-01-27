import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../data/models/vocabulary_model.dart';
import '../../../../data/models/lesson_model.dart';
import '../../../../data/datasources/saved_vocabulary_service.dart';
import '../../../../core/utils/auth_storage.dart';
import 'vocabulary_quiz_page.dart';

class VocabularyLearningPage extends StatefulWidget {
  final LessonModel? lesson;
  final List<VocabularyModel> vocabularies;
  final String? customTitle; // Cho saved vocabularies page

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
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final SavedVocabularyService _savedVocabularyService =
      SavedVocabularyService();

  int _currentIndex = 0;
  bool _showMeaning = false;
  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  // Saved vocabularies state
  int? _userId;
  Set<int> _savedIds = {};
  bool _isLoadingSaved = true;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(_flipController);

    // Load user and saved vocabularies
    _loadUserAndSavedVocabularies();

    // Auto play audio for first word
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _playAudio(widget.vocabularies[0].audioUrl);
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng đăng nhập để lưu từ vựng'),
          backgroundColor: Colors.orange,
        ),
      );
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Thành công'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
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
  void dispose() {
    _pageController.dispose();
    _audioPlayer.dispose();
    _flipController.dispose();
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Completed all words - go to quiz
      _showCompletionDialog();
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Hoàn thành! 🎉'),
          ],
        ),
        content: Text(
          'Bạn đã học xong ${widget.vocabularies.length} từ vựng.\nSẵn sàng kiểm tra chưa?',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Học lại sau'),
          ),
          ElevatedButton(
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Làm bài kiểm tra'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentVocab = widget.vocabularies[_currentIndex];
    final isSaved = _savedIds.contains(currentVocab.id);

    return Scaffold(
      backgroundColor: const Color(0xFF6C63FF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => _showExitDialog(),
        ),
        title: Text(widget.title, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          // Bookmark button
          if (!_isLoadingSaved && _userId != null)
            IconButton(
              icon: Icon(
                isSaved ? Icons.bookmark : Icons.bookmark_border,
                color: isSaved ? Colors.amber : Colors.white,
              ),
              onPressed: () => _toggleSaveVocabulary(currentVocab.id!),
              tooltip: isSaved ? 'Bỏ lưu' : 'Lưu từ vựng',
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          _buildProgressBar(),

          // Flashcard area
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                  _showMeaning = false;
                  _flipController.reset();
                });
                // Auto play audio when page changes
                _playAudio(widget.vocabularies[index].audioUrl);
              },
              itemCount: widget.vocabularies.length,
              itemBuilder: (context, index) {
                return _buildFlashcard(widget.vocabularies[index]);
              },
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Từ ${_currentIndex + 1}/${widget.vocabularies.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
              Text(
                '${((_currentIndex + 1) / widget.vocabularies.length * 100).toInt()}%',
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / widget.vocabularies.length,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlashcard(VocabularyModel vocab) {
    return GestureDetector(
      onTap: _toggleCard,
      child: Padding(
        padding: const EdgeInsets.all(20),
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
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Container(
        width: double.infinity,
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
                color: Color(0xFF2D2D2D),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // Phonetic
            if (vocab.phonetic != null && vocab.phonetic!.isNotEmpty)
              Text(
                vocab.phonetic!,
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 32),

            // Audio button
            GestureDetector(
              onTap: () => _playAudio(vocab.audioUrl),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C63FF).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volume_up,
                  size: 40,
                  color: Color(0xFF6C63FF),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app, color: Colors.grey[400], size: 20),
                const SizedBox(width: 8),
                Text(
                  'Nhấn để xem nghĩa',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(VocabularyModel vocab) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      color: const Color(0xFF6C63FF),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Word (smaller)
            Text(
              vocab.word,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),

            // Phonetic
            if (vocab.phonetic != null && vocab.phonetic!.isNotEmpty)
              Text(
                vocab.phonetic!,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white60,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const SizedBox(height: 32),

            // Divider
            Container(
              width: 60,
              height: 3,
              decoration: BoxDecoration(
                color: Colors.white30,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 32),

            // Meaning
            Text(
              vocab.meaning,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            // Audio button
            GestureDetector(
              onTap: () => _playAudio(vocab.audioUrl),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.volume_up,
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
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Previous button
            Expanded(
              child: ElevatedButton(
                onPressed: _currentIndex > 0 ? _previousCard : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, size: 20),
                    SizedBox(width: 4),
                    Text('Trước', style: TextStyle(fontSize: 13)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Flip button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _toggleCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _showMeaning ? Icons.flip_to_front : Icons.flip_to_back,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _showMeaning ? 'Mặt trước' : 'Xem nghĩa',
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Next button
            Expanded(
              child: ElevatedButton(
                onPressed: _nextCard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentIndex < widget.vocabularies.length - 1
                          ? 'Tiếp'
                          : 'Xong',
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      _currentIndex < widget.vocabularies.length - 1
                          ? Icons.arrow_forward
                          : Icons.check,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Thoát học?'),
        content: const Text(
          'Tiến trình học của bạn sẽ không được lưu. Bạn có chắc muốn thoát?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tiếp tục học'),
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
