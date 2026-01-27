import 'package:flutter/material.dart';
import '../../../../data/datasources/lesson_service.dart';
import '../../../../data/models/lesson_model.dart';
import '../../../../data/models/topic_model.dart';
import '../../../../routes/app_router.dart';

class AdminTopicLessonsPage extends StatefulWidget {
  final TopicModel topic;

  const AdminTopicLessonsPage({super.key, required this.topic});

  @override
  State<AdminTopicLessonsPage> createState() => _AdminTopicLessonsPageState();
}

class _AdminTopicLessonsPageState extends State<AdminTopicLessonsPage> {
  final LessonService _lessonService = LessonService();
  List<LessonModel> _lessons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    setState(() => _isLoading = true);
    final result = await _lessonService.getLessonsByTopicId(widget.topic.id);
    if (mounted) {
      setState(() {
        if (result['success']) {
          _lessons = result['lessons'];
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quản lý Bài học',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            Text(
              widget.topic.name,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddLessonDialog(),
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Thêm bài học',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            )
          : _lessons.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadLessons,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _lessons.length,
                itemBuilder: (context, index) {
                  return _buildLessonCard(_lessons[index], index + 1);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.book_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Chưa có bài học nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút "Thêm bài học" để bắt đầu',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getLevelDisplay(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return '🟢 Beginner';
      case 'intermediate':
        return '🟡 Intermediate';
      case 'advanced':
        return '🔴 Advanced';
      default:
        return level;
    }
  }

  Widget _buildLessonCard(LessonModel lesson, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '$index',
              style: const TextStyle(
                color: Color(0xFF6C63FF),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          lesson.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Level tag
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _getLevelColor(lesson.level).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getLevelColor(lesson.level),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getLevelDisplay(lesson.level),
                      style: TextStyle(
                        color: _getLevelColor(lesson.level),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Độ khó: ${lesson.difficultyScore}/10',
                    style: TextStyle(color: Colors.grey[600], fontSize: 11),
                  ),
                ],
              ),
            ),
            if (lesson.content != null && lesson.content!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  lesson.content!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ),
            if (lesson.videoUrl != null && lesson.videoUrl!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.videocam, size: 16, color: Colors.blue[400]),
                    const SizedBox(width: 4),
                    Text(
                      'Có video bài giảng',
                      style: TextStyle(color: Colors.blue[400], fontSize: 12),
                    ),
                  ],
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, color: Colors.grey[600]),
          onSelected: (value) {
            if (value == 'edit') {
              _showEditLessonDialog(lesson);
            } else if (value == 'delete') {
              _showDeleteConfirmDialog(lesson);
            } else if (value == 'vocabulary') {
              Navigator.pushNamed(
                context,
                AppRouter.adminLessonVocabulary,
                arguments: {'lesson': lesson},
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'vocabulary',
              child: Row(
                children: [
                  Icon(Icons.translate, size: 20, color: Color(0xFF6C63FF)),
                  SizedBox(width: 8),
                  Text(
                    'Quản lý từ vựng',
                    style: TextStyle(color: Color(0xFF6C63FF)),
                  ),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Chỉnh sửa'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLessonDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final videoUrlController = TextEditingController();
    String selectedLevel = 'beginner';
    int difficultyScore = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Thêm bài học mới'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề bài học *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung bài học',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: videoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL video (Youtube, v.v.)',
                    border: OutlineInputBorder(),
                    hintText: 'https://...',
                  ),
                ),
                const SizedBox(height: 12),
                // Level dropdown
                DropdownButtonFormField<String>(
                  value: selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'Cấp độ',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'beginner',
                      child: Text('🟢 Beginner'),
                    ),
                    DropdownMenuItem(
                      value: 'intermediate',
                      child: Text('🟡 Intermediate'),
                    ),
                    DropdownMenuItem(
                      value: 'advanced',
                      child: Text('🔴 Advanced'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedLevel = value ?? 'beginner';
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Difficulty score slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Độ khó: $difficultyScore/10'),
                    Slider(
                      value: difficultyScore.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: '$difficultyScore',
                      onChanged: (value) {
                        setDialogState(() {
                          difficultyScore = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập tiêu đề bài học'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                await _addLesson(
                  titleController.text.trim(),
                  contentController.text.trim(),
                  videoUrlController.text.trim(),
                  selectedLevel,
                  difficultyScore,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
              ),
              child: const Text('Thêm', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditLessonDialog(LessonModel lesson) {
    final titleController = TextEditingController(text: lesson.title);
    final contentController = TextEditingController(text: lesson.content ?? '');
    final videoUrlController = TextEditingController(
      text: lesson.videoUrl ?? '',
    );
    String selectedLevel = lesson.level;
    // Clamp giá trị difficultyScore để đảm bảo nằm trong khoảng 1-10
    int difficultyScore = lesson.difficultyScore.clamp(1, 10);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Chỉnh sửa bài học'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Tiêu đề bài học *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung bài học',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: videoUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL video (Youtube, v.v.)',
                    border: OutlineInputBorder(),
                    hintText: 'https://...',
                  ),
                ),
                const SizedBox(height: 12),
                // Level dropdown
                DropdownButtonFormField<String>(
                  value: selectedLevel,
                  decoration: const InputDecoration(
                    labelText: 'Cấp độ',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'beginner',
                      child: Text('🟢 Beginner'),
                    ),
                    DropdownMenuItem(
                      value: 'intermediate',
                      child: Text('🟡 Intermediate'),
                    ),
                    DropdownMenuItem(
                      value: 'advanced',
                      child: Text('🔴 Advanced'),
                    ),
                  ],
                  onChanged: (value) {
                    setDialogState(() {
                      selectedLevel = value ?? 'beginner';
                    });
                  },
                ),
                const SizedBox(height: 12),
                // Difficulty score slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Độ khó: $difficultyScore/10'),
                    Slider(
                      value: difficultyScore.toDouble(),
                      min: 1,
                      max: 10,
                      divisions: 9,
                      label: '$difficultyScore',
                      onChanged: (value) {
                        setDialogState(() {
                          difficultyScore = value.toInt();
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vui lòng nhập tiêu đề bài học'),
                    ),
                  );
                  return;
                }
                Navigator.pop(context);
                await _updateLesson(
                  lesson.id,
                  titleController.text.trim(),
                  contentController.text.trim(),
                  videoUrlController.text.trim(),
                  selectedLevel,
                  difficultyScore,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
              ),
              child: const Text('Lưu', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmDialog(LessonModel lesson) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa bài học "${lesson.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteLesson(lesson.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _addLesson(
    String title,
    String content,
    String videoUrl,
    String level,
    int difficultyScore,
  ) async {
    final result = await _lessonService.createLesson(
      topicId: widget.topic.id,
      title: title,
      content: content.isEmpty ? null : content,
      videoUrl: videoUrl.isEmpty ? null : videoUrl,
      level: level,
      difficultyScore: difficultyScore,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
      if (result['success']) {
        _loadLessons();
      }
    }
  }

  Future<void> _updateLesson(
    int id,
    String title,
    String content,
    String videoUrl,
    String level,
    int difficultyScore,
  ) async {
    final result = await _lessonService.updateLesson(
      id: id,
      topicId: widget.topic.id,
      title: title,
      content: content.isEmpty ? null : content,
      videoUrl: videoUrl.isEmpty ? null : videoUrl,
      level: level,
      difficultyScore: difficultyScore,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
      if (result['success']) {
        _loadLessons();
      }
    }
  }

  Future<void> _deleteLesson(int id) async {
    final result = await _lessonService.deleteLesson(id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
      if (result['success']) {
        _loadLessons();
      }
    }
  }
}
