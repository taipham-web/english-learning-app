import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../data/datasources/saved_vocabulary_service.dart';
import '../presentation/pages/vocabulary_learning_page.dart';
import '../../../core/utils/auth_storage.dart';

class SavedVocabulariesPage extends StatefulWidget {
  const SavedVocabulariesPage({super.key});

  @override
  State<SavedVocabulariesPage> createState() => _SavedVocabulariesPageState();
}

class _SavedVocabulariesPageState extends State<SavedVocabulariesPage>
    with SingleTickerProviderStateMixin {
  final SavedVocabularyService _savedVocabularyService =
      SavedVocabularyService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<SavedVocabularyItem> _savedVocabularies = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _userId;
  bool _hasChanges = false; // Track if any vocabulary was unsaved

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _loadUserAndVocabularies();
  }

  Future<void> _loadUserAndVocabularies() async {
    final user = await AuthStorage.getUser();
    if (user != null && mounted) {
      setState(() {
        _userId = user.id;
      });
      _loadSavedVocabularies();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Vui lòng đăng nhập để xem từ vựng đã lưu';
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadSavedVocabularies() async {
    if (_userId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _savedVocabularyService.getSavedVocabularies(_userId!);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (result['success']) {
          _savedVocabularies = result['savedVocabularies'];
          _animationController.forward();
        } else {
          _errorMessage = result['message'];
        }
      });
    }
  }

  Future<void> _playAudio(String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) {
      _showSnackBar('Không có audio cho từ này', Colors.orange);
      return;
    }

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      if (mounted) {
        _showSnackBar('Không thể phát audio', Colors.red);
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
      ),
    );
  }

  Future<void> _unsaveVocabulary(SavedVocabularyItem item) async {
    if (_userId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.bookmark_remove_rounded,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(width: 12),
            const Text('Bỏ lưu từ này?'),
          ],
        ),
        content: RichText(
          text: TextSpan(
            style: TextStyle(color: Colors.grey[700], fontSize: 16),
            children: [
              const TextSpan(text: 'Bạn có muốn bỏ lưu từ '),
              TextSpan(
                text: '"${item.word}"',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF),
                ),
              ),
              const TextSpan(text: '?'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Bỏ lưu'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await _savedVocabularyService.unsaveVocabulary(
        _userId!,
        item.vocabularyId,
      );

      if (mounted) {
        if (result['success']) {
          setState(() {
            _savedVocabularies.removeWhere(
              (v) => v.vocabularyId == item.vocabularyId,
            );
            _hasChanges = true; // Mark that changes were made
          });
          _showSnackBar('Đã bỏ lưu "${item.word}"', const Color(0xFF4CAF50));
        } else {
          _showSnackBar(result['message'] ?? 'Lỗi không xác định', Colors.red);
        }
      }
    }
  }

  void _startLearning() {
    if (_savedVocabularies.isEmpty) {
      _showSnackBar('Không có từ vựng nào để học!', Colors.orange);
      return;
    }

    final vocabularies = _savedVocabularies
        .map((item) => item.toVocabularyModel())
        .toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VocabularyLearningPage(
          vocabularies: vocabularies,
          customTitle: 'Từ vựng đã lưu',
        ),
      ),
    );
  }

  int _getUniqueLessonsCount() {
    final lessonIds = _savedVocabularies
        .where((v) => v.lessonId != null)
        .map((v) => v.lessonId)
        .toSet();
    return lessonIds.length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FE),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      floatingActionButton: _savedVocabularies.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _startLearning,
              backgroundColor: const Color(0xFF6C63FF),
              elevation: 8,
              icon: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 28,
              ),
              label: const Text(
                'Học Flashcard',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context, _hasChanges),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Từ vựng đã lưu',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Ôn tập và củng cố từ vựng',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              // Quick learn button in header
              if (_savedVocabularies.isNotEmpty)
                GestureDetector(
                  onTap: _startLearning,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.school_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // Stats row
          Row(
            children: [
              _buildStatCard(
                icon: Icons.bookmark_rounded,
                value: '${_savedVocabularies.length}',
                label: 'Từ đã lưu',
              ),
              const SizedBox(width: 12),
              _buildStatCard(
                icon: Icons.book_rounded,
                value: '${_getUniqueLessonsCount()}',
                label: 'Bài học',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isLoading ? '...' : value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6C63FF)),
            SizedBox(height: 16),
            Text(
              'Đang tải từ vựng...',
              style: TextStyle(color: Color(0xFF7C7C8A)),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.red.shade300,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red[700], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadSavedVocabularies,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_savedVocabularies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_border_rounded,
                size: 64,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Chưa có từ vựng nào được lưu',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Hãy nhấn vào biểu tượng bookmark khi học từ vựng để lưu lại!',
                style: TextStyle(color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => Navigator.pushNamed(context, '/topics'),
              icon: const Icon(Icons.school_rounded),
              label: const Text('Bắt đầu học ngay'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: RefreshIndicator(
        onRefresh: _loadSavedVocabularies,
        color: const Color(0xFF6C63FF),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
          itemCount: _savedVocabularies.length,
          itemBuilder: (context, index) {
            return _buildVocabularyCard(_savedVocabularies[index], index);
          },
        ),
      ),
    );
  }

  Widget _buildVocabularyCard(SavedVocabularyItem item, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: () => _playAudio(item.audioUrl),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Audio button
                  GestureDetector(
                    onTap: () => _playAudio(item.audioUrl),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF6C63FF), Color(0xFF5A52E0)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF6C63FF).withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Word info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.word,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A1A2E),
                          ),
                        ),
                        if (item.phonetic != null &&
                            item.phonetic!.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.phonetic!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          item.meaning,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF4A4A5A),
                          ),
                        ),
                        if (item.lessonTitle != null) ...[
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C63FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.book_rounded,
                                  size: 12,
                                  color: const Color(
                                    0xFF6C63FF,
                                  ).withOpacity(0.8),
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    item.lessonTitle!,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: const Color(
                                        0xFF6C63FF,
                                      ).withOpacity(0.8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Unsave button
                  GestureDetector(
                    onTap: () => _unsaveVocabulary(item),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.bookmark_rounded,
                        color: Colors.amber,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
