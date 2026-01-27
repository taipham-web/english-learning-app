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

class _SavedVocabulariesPageState extends State<SavedVocabulariesPage> {
  final SavedVocabularyService _savedVocabularyService =
      SavedVocabularyService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<SavedVocabularyItem> _savedVocabularies = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _userId;

  @override
  void initState() {
    super.initState();
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
        } else {
          _errorMessage = result['message'];
        }
      });
    }
  }

  Future<void> _playAudio(String? audioUrl) async {
    if (audioUrl == null || audioUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có audio cho từ này'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(audioUrl));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể phát audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _unsaveVocabulary(SavedVocabularyItem item) async {
    if (_userId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn có muốn bỏ lưu từ "${item.word}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã bỏ lưu "${item.word}"'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Lỗi không xác định'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _startLearning() {
    if (_savedVocabularies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không có từ vựng nào để học!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Convert to VocabularyModel list
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Từ vựng đã lưu'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          if (_savedVocabularies.isNotEmpty)
            IconButton(
              onPressed: _startLearning,
              icon: const Icon(Icons.play_arrow),
              tooltip: 'Học flashcard',
            ),
        ],
      ),
      body: _buildBody(),
      floatingActionButton: _savedVocabularies.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _startLearning,
              backgroundColor: Colors.deepPurple,
              icon: const Icon(Icons.school, color: Colors.white),
              label: const Text(
                'Học Flashcard',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.deepPurple),
            SizedBox(height: 16),
            Text('Đang tải từ vựng đã lưu...'),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadSavedVocabularies,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_savedVocabularies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có từ vựng nào được lưu',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy nhấn vào biểu tượng bookmark\nkhi học từ vựng để lưu lại!',
              style: TextStyle(color: Colors.grey[500]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadSavedVocabularies,
      child: Column(
        children: [
          // Stats header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.deepPurple, Colors.deepPurple.shade300],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.bookmark,
                  label: 'Đã lưu',
                  value: '${_savedVocabularies.length}',
                ),
                _buildStatItem(
                  icon: Icons.category,
                  label: 'Bài học',
                  value: '${_getUniqueLessonsCount()}',
                ),
              ],
            ),
          ),

          // Vocabulary list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _savedVocabularies.length,
              itemBuilder: (context, index) {
                return _buildVocabularyCard(_savedVocabularies[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12),
        ),
      ],
    );
  }

  int _getUniqueLessonsCount() {
    final lessonIds = _savedVocabularies
        .where((v) => v.lessonId != null)
        .map((v) => v.lessonId)
        .toSet();
    return lessonIds.length;
  }

  Widget _buildVocabularyCard(SavedVocabularyItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _playAudio(item.audioUrl),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Audio button
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  onPressed: () => _playAudio(item.audioUrl),
                  icon: Icon(
                    Icons.volume_up,
                    color: Colors.deepPurple.shade400,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Word info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.word,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (item.phonetic != null && item.phonetic!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.phonetic!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(item.meaning, style: const TextStyle(fontSize: 15)),
                    if (item.lessonTitle != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.lessonTitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Unsave button
              IconButton(
                onPressed: () => _unsaveVocabulary(item),
                icon: const Icon(Icons.bookmark, color: Colors.amber),
                tooltip: 'Bỏ lưu',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
