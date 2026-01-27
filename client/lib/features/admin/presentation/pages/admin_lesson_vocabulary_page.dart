import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../../data/datasources/vocabulary_service.dart';
import '../../../../data/models/lesson_model.dart';
import '../../../../data/models/vocabulary_model.dart';

class AdminLessonVocabularyPage extends StatefulWidget {
  final LessonModel lesson;

  const AdminLessonVocabularyPage({super.key, required this.lesson});

  @override
  State<AdminLessonVocabularyPage> createState() =>
      _AdminLessonVocabularyPageState();
}

class _AdminLessonVocabularyPageState extends State<AdminLessonVocabularyPage> {
  final VocabularyService _vocabularyService = VocabularyService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<VocabularyModel> _vocabularies = [];
  bool _isLoading = true;
  int? _playingIndex;

  @override
  void initState() {
    super.initState();
    _loadVocabularies();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _loadVocabularies() async {
    setState(() => _isLoading = true);
    final result = await _vocabularyService.getVocabulariesByLessonId(
      widget.lesson.id,
    );
    if (mounted) {
      setState(() {
        if (result['success']) {
          _vocabularies = result['vocabularies'];
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _playAudio(String url, int index) async {
    try {
      setState(() => _playingIndex = index);
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) {
          setState(() => _playingIndex = null);
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() => _playingIndex = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể phát âm thanh: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
              'Quản lý Từ vựng',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 18,
              ),
            ),
            Text(
              widget.lesson.title,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            tooltip: 'Thêm nhiều từ',
            onPressed: () => _showBulkAddDialog(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVocabularyDialog(),
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Thêm từ vựng',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6C63FF)),
            )
          : _vocabularies.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadVocabularies,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _vocabularies.length,
                itemBuilder: (context, index) {
                  return _buildVocabularyCard(_vocabularies[index], index);
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
          Icon(Icons.translate_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Chưa có từ vựng nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Nhấn nút "Thêm từ vựng" để bắt đầu',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildVocabularyCard(VocabularyModel vocabulary, int index) {
    final bool isPlaying = _playingIndex == index;

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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Word icon
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF6C63FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      vocabulary.word.isNotEmpty
                          ? vocabulary.word[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
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
                              vocabulary.word,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF2D3142),
                              ),
                            ),
                          ),
                          // Audio button
                          if (vocabulary.audioUrl != null &&
                              vocabulary.audioUrl!.isNotEmpty)
                            GestureDetector(
                              onTap: () =>
                                  _playAudio(vocabulary.audioUrl!, index),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isPlaying
                                      ? const Color(0xFF6C63FF)
                                      : const Color(
                                          0xFF6C63FF,
                                        ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  isPlaying
                                      ? Icons.volume_up
                                      : Icons.volume_up_outlined,
                                  color: isPlaying
                                      ? Colors.white
                                      : const Color(0xFF6C63FF),
                                  size: 20,
                                ),
                              ),
                            ),
                        ],
                      ),
                      // Phonetic
                      if (vocabulary.phonetic != null &&
                          vocabulary.phonetic!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            vocabulary.phonetic!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      // Meaning
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          vocabulary.meaning,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Menu button
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditVocabularyDialog(vocabulary);
                    } else if (value == 'delete') {
                      _showDeleteConfirmDialog(vocabulary);
                    }
                  },
                  itemBuilder: (context) => [
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
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddVocabularyDialog() {
    final wordController = TextEditingController();
    final meaningController = TextEditingController();
    final phoneticController = TextEditingController();
    final audioUrlController = TextEditingController();
    bool isLookingUp = false;
    List<String> definitions = [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.add_circle, color: Color(0xFF6C63FF)),
              const SizedBox(width: 8),
              const Text('Thêm từ vựng mới'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Word field with lookup button
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: wordController,
                        decoration: const InputDecoration(
                          labelText: 'Từ tiếng Anh *',
                          border: OutlineInputBorder(),
                          hintText: 'Nhập từ tiếng Anh',
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (_) async {
                          if (wordController.text.trim().isNotEmpty) {
                            setDialogState(() => isLookingUp = true);
                            final result = await _vocabularyService.lookupWord(
                              wordController.text.trim(),
                            );
                            setDialogState(() {
                              isLookingUp = false;
                              if (result['success']) {
                                phoneticController.text =
                                    result['phonetic'] ?? '';
                                audioUrlController.text =
                                    result['audioUrl'] ?? '';
                                definitions = List<String>.from(
                                  result['definitions'] ?? [],
                                );
                              }
                            });
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isLookingUp
                          ? null
                          : () async {
                              if (wordController.text.trim().isNotEmpty) {
                                setDialogState(() => isLookingUp = true);
                                final result = await _vocabularyService
                                    .lookupWord(wordController.text.trim());
                                setDialogState(() {
                                  isLookingUp = false;
                                  if (result['success']) {
                                    phoneticController.text =
                                        result['phonetic'] ?? '';
                                    audioUrlController.text =
                                        result['audioUrl'] ?? '';
                                    definitions = List<String>.from(
                                      result['definitions'] ?? [],
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(result['message']),
                                        backgroundColor: Colors.orange,
                                      ),
                                    );
                                  }
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                      ),
                      child: isLookingUp
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.search, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Nhấn nút tìm kiếm để tra từ điển tự động',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                // Show definitions from dictionary
                if (definitions.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📖 Định nghĩa từ Dictionary API:',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ...definitions.map(
                          (def) => Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: GestureDetector(
                              onTap: () {
                                meaningController.text = def.replaceAll(
                                  RegExp(r'^\([^)]+\)\s*'),
                                  '',
                                );
                              },
                              child: Text(
                                '• $def',
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Nhấn vào định nghĩa để chọn',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                TextField(
                  controller: meaningController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Nghĩa tiếng Việt *',
                    border: OutlineInputBorder(),
                    hintText: 'Nhập nghĩa của từ',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneticController,
                  decoration: const InputDecoration(
                    labelText: 'Phiên âm',
                    border: OutlineInputBorder(),
                    hintText: '/fəˈnetɪk/',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: audioUrlController,
                  decoration: InputDecoration(
                    labelText: 'URL giọng đọc',
                    border: const OutlineInputBorder(),
                    hintText: 'https://...',
                    suffixIcon: audioUrlController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.play_circle_outline),
                            onPressed: () async {
                              try {
                                await _audioPlayer.play(
                                  UrlSource(audioUrlController.text),
                                );
                              } catch (e) {
                                // ignore
                              }
                            },
                          )
                        : null,
                  ),
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
                if (wordController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập từ tiếng Anh')),
                  );
                  return;
                }
                if (meaningController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập nghĩa của từ')),
                  );
                  return;
                }
                Navigator.pop(context);
                await _addVocabulary(
                  wordController.text.trim(),
                  meaningController.text.trim(),
                  phoneticController.text.trim(),
                  audioUrlController.text.trim(),
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

  void _showBulkAddDialog() {
    final textController = TextEditingController();
    List<VocabularyModel> previewVocabularies = [];
    bool isProcessing = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.playlist_add, color: Color(0xFF6C63FF)),
              const SizedBox(width: 8),
              const Text('Thêm nhiều từ vựng'),
            ],
          ),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.9,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nhập danh sách từ (mỗi dòng một từ):',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: textController,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText:
                          'apple\nbanana\norange\n...\n\nHoặc: apple - quả táo\nbanana - quả chuối',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isProcessing
                              ? null
                              : () async {
                                  final lines = textController.text
                                      .split('\n')
                                      .where((line) => line.trim().isNotEmpty)
                                      .toList();

                                  if (lines.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          'Vui lòng nhập danh sách từ',
                                        ),
                                      ),
                                    );
                                    return;
                                  }

                                  setDialogState(() {
                                    isProcessing = true;
                                    previewVocabularies = [];
                                  });

                                  for (final line in lines) {
                                    String word;
                                    String? meaning;

                                    // Check if line has format "word - meaning"
                                    if (line.contains(' - ')) {
                                      final parts = line.split(' - ');
                                      word = parts[0].trim();
                                      meaning = parts
                                          .sublist(1)
                                          .join(' - ')
                                          .trim();
                                    } else {
                                      word = line.trim();
                                    }

                                    // Lookup from dictionary
                                    final result = await _vocabularyService
                                        .lookupWord(word);

                                    if (result['success']) {
                                      setDialogState(() {
                                        previewVocabularies.add(
                                          VocabularyModel(
                                            lessonId: widget.lesson.id,
                                            word: word,
                                            meaning:
                                                meaning ??
                                                (result['definitions'] as List?)
                                                    ?.firstOrNull
                                                    ?.replaceAll(
                                                      RegExp(r'^\([^)]+\)\s*'),
                                                      '',
                                                    ) ??
                                                '',
                                            phonetic: result['phonetic'],
                                            audioUrl: result['audioUrl'],
                                          ),
                                        );
                                      });
                                    } else {
                                      setDialogState(() {
                                        previewVocabularies.add(
                                          VocabularyModel(
                                            lessonId: widget.lesson.id,
                                            word: word,
                                            meaning: meaning ?? '',
                                            phonetic: null,
                                            audioUrl: null,
                                          ),
                                        );
                                      });
                                    }
                                  }

                                  setDialogState(() => isProcessing = false);
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C63FF),
                          ),
                          icon: isProcessing
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.search, color: Colors.white),
                          label: Text(
                            isProcessing
                                ? 'Đang tra cứu...'
                                : 'Tra cứu từ điển',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Preview list
                  if (previewVocabularies.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 8),
                    Text(
                      'Xem trước (${previewVocabularies.length} từ):',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: const BoxConstraints(maxHeight: 200),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: previewVocabularies.length,
                        itemBuilder: (context, index) {
                          final vocab = previewVocabularies[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: vocab.meaning.isEmpty
                                  ? Colors.orange.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: vocab.meaning.isEmpty
                                    ? Colors.orange
                                    : Colors.green,
                                width: 0.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      vocab.word,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                    ),
                                    if (vocab.phonetic != null &&
                                        vocab.phonetic!.isNotEmpty)
                                      Text(
                                        ' ${vocab.phonetic}',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 13,
                                        ),
                                      ),
                                    const Spacer(),
                                    if (vocab.audioUrl != null &&
                                        vocab.audioUrl!.isNotEmpty)
                                      const Icon(
                                        Icons.volume_up,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 16),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        _showEditPreviewDialog(
                                          vocab,
                                          index,
                                          previewVocabularies,
                                          setDialogState,
                                        );
                                      },
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        size: 16,
                                        color: Colors.red,
                                      ),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        setDialogState(() {
                                          previewVocabularies.removeAt(index);
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                if (vocab.meaning.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Text(
                                      vocab.meaning,
                                      style: TextStyle(
                                        color: Colors.grey[700],
                                        fontSize: 13,
                                      ),
                                    ),
                                  )
                                else
                                  const Padding(
                                    padding: EdgeInsets.only(top: 4),
                                    child: Text(
                                      '⚠️ Cần nhập nghĩa',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 13,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
            ),
            if (previewVocabularies.isNotEmpty)
              ElevatedButton(
                onPressed: () async {
                  // Check all vocabs have meaning
                  final missingMeaning = previewVocabularies
                      .where((v) => v.meaning.isEmpty)
                      .toList();
                  if (missingMeaning.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${missingMeaning.length} từ chưa có nghĩa. Vui lòng bổ sung!',
                        ),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  Navigator.pop(context);
                  await _addBulkVocabularies(previewVocabularies);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                ),
                child: Text(
                  'Thêm ${previewVocabularies.length} từ',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showEditPreviewDialog(
    VocabularyModel vocab,
    int index,
    List<VocabularyModel> previewList,
    StateSetter setParentState,
  ) {
    final wordController = TextEditingController(text: vocab.word);
    final meaningController = TextEditingController(text: vocab.meaning);
    final phoneticController = TextEditingController(
      text: vocab.phonetic ?? '',
    );
    final audioUrlController = TextEditingController(
      text: vocab.audioUrl ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sửa từ vựng'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: wordController,
                decoration: const InputDecoration(
                  labelText: 'Từ tiếng Anh',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: meaningController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Nghĩa tiếng Việt *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneticController,
                decoration: const InputDecoration(
                  labelText: 'Phiên âm',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: audioUrlController,
                decoration: const InputDecoration(
                  labelText: 'URL giọng đọc',
                  border: OutlineInputBorder(),
                ),
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
            onPressed: () {
              Navigator.pop(context);
              setParentState(() {
                previewList[index] = VocabularyModel(
                  lessonId: widget.lesson.id,
                  word: wordController.text.trim(),
                  meaning: meaningController.text.trim(),
                  phonetic: phoneticController.text.trim().isEmpty
                      ? null
                      : phoneticController.text.trim(),
                  audioUrl: audioUrlController.text.trim().isEmpty
                      ? null
                      : audioUrlController.text.trim(),
                );
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
            ),
            child: const Text('Lưu', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditVocabularyDialog(VocabularyModel vocabulary) {
    final wordController = TextEditingController(text: vocabulary.word);
    final meaningController = TextEditingController(text: vocabulary.meaning);
    final phoneticController = TextEditingController(
      text: vocabulary.phonetic ?? '',
    );
    final audioUrlController = TextEditingController(
      text: vocabulary.audioUrl ?? '',
    );
    bool isLookingUp = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text('Chỉnh sửa từ vựng'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: wordController,
                        decoration: const InputDecoration(
                          labelText: 'Từ tiếng Anh *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: isLookingUp
                          ? null
                          : () async {
                              if (wordController.text.trim().isNotEmpty) {
                                setDialogState(() => isLookingUp = true);
                                final result = await _vocabularyService
                                    .lookupWord(wordController.text.trim());
                                setDialogState(() {
                                  isLookingUp = false;
                                  if (result['success']) {
                                    phoneticController.text =
                                        result['phonetic'] ?? '';
                                    audioUrlController.text =
                                        result['audioUrl'] ?? '';
                                  }
                                });
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                      ),
                      child: isLookingUp
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.search, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: meaningController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Nghĩa tiếng Việt *',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneticController,
                  decoration: const InputDecoration(
                    labelText: 'Phiên âm',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: audioUrlController,
                  decoration: const InputDecoration(
                    labelText: 'URL giọng đọc',
                    border: OutlineInputBorder(),
                  ),
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
                if (wordController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập từ tiếng Anh')),
                  );
                  return;
                }
                if (meaningController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Vui lòng nhập nghĩa của từ')),
                  );
                  return;
                }
                Navigator.pop(context);
                await _updateVocabulary(
                  vocabulary.id!,
                  wordController.text.trim(),
                  meaningController.text.trim(),
                  phoneticController.text.trim(),
                  audioUrlController.text.trim(),
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

  void _showDeleteConfirmDialog(VocabularyModel vocabulary) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Xác nhận xóa'),
        content: Text('Bạn có chắc muốn xóa từ "${vocabulary.word}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Hủy', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteVocabulary(vocabulary.id!);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _addVocabulary(
    String word,
    String meaning,
    String phonetic,
    String audioUrl,
  ) async {
    final result = await _vocabularyService.createVocabulary(
      lessonId: widget.lesson.id,
      word: word,
      meaning: meaning,
      phonetic: phonetic.isEmpty ? null : phonetic,
      audioUrl: audioUrl.isEmpty ? null : audioUrl,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
      if (result['success']) {
        _loadVocabularies();
      }
    }
  }

  Future<void> _addBulkVocabularies(List<VocabularyModel> vocabularies) async {
    final result = await _vocabularyService.createMultipleVocabularies(
      lessonId: widget.lesson.id,
      vocabularies: vocabularies,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
      if (result['success']) {
        _loadVocabularies();
      }
    }
  }

  Future<void> _updateVocabulary(
    int id,
    String word,
    String meaning,
    String phonetic,
    String audioUrl,
  ) async {
    final result = await _vocabularyService.updateVocabulary(
      id: id,
      lessonId: widget.lesson.id,
      word: word,
      meaning: meaning,
      phonetic: phonetic.isEmpty ? null : phonetic,
      audioUrl: audioUrl.isEmpty ? null : audioUrl,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
      if (result['success']) {
        _loadVocabularies();
      }
    }
  }

  Future<void> _deleteVocabulary(int id) async {
    final result = await _vocabularyService.deleteVocabulary(id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: result['success'] ? Colors.green : Colors.red,
        ),
      );
      if (result['success']) {
        _loadVocabularies();
      }
    }
  }
}
