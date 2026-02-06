# Hướng dẫn sử dụng Quiz UI

## 📱 Các trang đã tạo

### 1. **QuizPage** - Trang làm bài kiểm tra
**File:** `lib/features/topics/presentation/pages/quiz_page.dart`

**Tính năng:**
- ✅ Tải quiz từ backend theo lesson ID
- ✅ Hiển thị câu hỏi và đáp án
- ✅ Đếm thời gian làm bài
- ✅ Thanh tiến trình
- ✅ Animation khi chọn đáp án
- ✅ Hiển thị đáp án đúng/sai
- ✅ Tự động submit kết quả lên server
- ✅ Dialog kết quả với thống kê
- ✅ Chức năng làm lại

**Cách sử dụng:**
```dart
import 'package:your_app/features/topics/presentation/pages/quiz_page.dart';

// Navigate to quiz page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => QuizPage(
      lessonId: 1,
      lessonTitle: 'Từ vựng cơ bản',
      userId: currentUserId,
    ),
  ),
);
```

### 2. **QuizHistoryPage** - Trang lịch sử làm bài
**File:** `lib/features/topics/presentation/pages/quiz_history_page.dart`

**Tính năng:**
- ✅ Thống kê tổng quan (tổng số lần, điểm TB, cao nhất, đạt yêu cầu)
- ✅ Danh sách lịch sử làm bài
- ✅ Hiển thị điểm, thời gian, ngày làm
- ✅ Pull to refresh
- ✅ Empty state khi chưa có lịch sử

**Cách sử dụng:**
```dart
import 'package:your_app/features/topics/presentation/pages/quiz_history_page.dart';

// Navigate to history page
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => QuizHistoryPage(
      userId: currentUserId,
    ),
  ),
);
```

---

## 🔧 Tích hợp vào ứng dụng

### Bước 1: Thêm dependency (nếu chưa có)

Mở `pubspec.yaml` và thêm:

```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  intl: ^0.18.1  # Cho format ngày tháng
```

Chạy:
```bash
flutter pub get
```

### Bước 2: Tích hợp vào Lesson Detail Page

Thêm nút "Làm bài kiểm tra" vào trang chi tiết bài học:

```dart
// Trong LessonDetailPage hoặc tương tự
ElevatedButton.icon(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizPage(
          lessonId: lesson.id,
          lessonTitle: lesson.title,
          userId: currentUser.id, // Lấy từ auth state
        ),
      ),
    );
  },
  icon: const Icon(Icons.quiz),
  label: const Text('Làm bài kiểm tra'),
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF6C63FF),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
  ),
)
```

### Bước 3: Thêm vào Navigation/Menu

Thêm mục "Lịch sử làm bài" vào menu hoặc profile:

```dart
ListTile(
  leading: const Icon(Icons.history, color: Color(0xFF6C63FF)),
  title: const Text('Lịch sử làm bài'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuizHistoryPage(
          userId: currentUser.id,
        ),
      ),
    );
  },
)
```

---

## 🎨 Customization

### Thay đổi màu sắc

Tìm và thay thế các màu trong code:

```dart
// Màu chính
const Color(0xFF6C63FF) // Purple
const Color(0xFF4CAF50) // Green (đúng)
Colors.red // Red (sai)
Colors.orange // Orange (chưa đạt)

// Background
const Color(0xFFF8F9FE) // Light purple background
```

### Thay đổi điều kiện đạt yêu cầu

Mặc định là 70%, có thể thay đổi:

```dart
// Trong QuizPage
final isPassed = item.percentage >= 70; // Thay 70 thành giá trị khác
```

### Thay đổi số câu hỏi hiển thị

Backend sẽ trả về tất cả câu hỏi, bạn có thể giới hạn:

```dart
// Trong _loadQuiz()
if (result['success']) {
  setState(() {
    _quiz = result['quiz'];
    // Giới hạn 10 câu đầu tiên
    _quiz!.questions = _quiz!.questions.take(10).toList();
    _isLoading = false;
  });
}
```

---

## 📊 Flow hoạt động

### Quiz Flow:
1. User mở Lesson Detail
2. Click "Làm bài kiểm tra"
3. `QuizPage` tải quiz từ API: `GET /api/v1/quizzes/lesson/:lessonId`
4. User trả lời từng câu hỏi
5. Sau câu cuối, tự động submit: `POST /api/v1/quizzes/:quizId/submit`
6. Hiển thị kết quả
7. User có thể:
   - Làm lại (reset và làm lại)
   - Hoàn thành (quay về)

### History Flow:
1. User mở menu/profile
2. Click "Lịch sử làm bài"
3. `QuizHistoryPage` tải:
   - Stats: `GET /api/v1/quizzes/stats/user/:userId`
   - History: `GET /api/v1/quizzes/results/user/:userId`
4. Hiển thị danh sách
5. Pull to refresh để cập nhật

---

## 🐛 Troubleshooting

### Lỗi: "Chưa có bài kiểm tra cho bài học này"
**Nguyên nhân:** Lesson chưa có quiz trong database

**Giải pháp:**
1. Tạo quiz cho lesson bằng API:
```bash
curl -X POST http://localhost:5000/api/v1/quizzes \
  -H "Content-Type: application/json" \
  -d '{
    "lesson_id": 1,
    "title": "Kiểm tra từ vựng",
    "questions": [...]
  }'
```

2. Hoặc ẩn nút "Làm bài kiểm tra" nếu chưa có quiz:
```dart
FutureBuilder(
  future: _quizService.getQuizByLessonId(lesson.id),
  builder: (context, snapshot) {
    if (snapshot.data?['success'] == true) {
      return ElevatedButton(...); // Hiện nút
    }
    return const SizedBox.shrink(); // Ẩn nút
  },
)
```

### Lỗi: "Lỗi kết nối"
**Nguyên nhân:** Server chưa chạy hoặc URL sai

**Giải pháp:**
1. Kiểm tra server đang chạy: `npm run dev`
2. Kiểm tra URL trong `quiz_service.dart`:
```dart
static const String _baseUrl = 'http://10.0.2.2:5000/api/v1'; // Android emulator
// Hoặc
static const String _baseUrl = 'http://localhost:5000/api/v1'; // iOS simulator
```

### Lỗi: intl package not found
**Giải pháp:**
```bash
flutter pub add intl
flutter pub get
```

---

## 💡 Gợi ý cải tiến

1. **Thêm âm thanh:**
```dart
import 'package:audioplayers/audioplayers.dart';

final AudioPlayer _audioPlayer = AudioPlayer();

// Khi đúng
_audioPlayer.play(AssetSource('sounds/correct.mp3'));

// Khi sai
_audioPlayer.play(AssetSource('sounds/wrong.mp3'));
```

2. **Thêm haptic feedback:**
```dart
import 'package:flutter/services.dart';

// Khi chọn đáp án
HapticFeedback.lightImpact();

// Khi đúng
HapticFeedback.heavyImpact();
```

3. **Thêm confetti khi đạt điểm cao:**
```dart
import 'package:confetti/confetti.dart';

// Khi percentage >= 90
_confettiController.play();
```

4. **Lưu offline:**
```dart
import 'package:shared_preferences/shared_preferences.dart';

// Cache quiz để làm offline
final prefs = await SharedPreferences.getInstance();
await prefs.setString('quiz_${lessonId}', jsonEncode(quiz.toJson()));
```

---

## 📸 Screenshots

### QuizPage
- Header với timer và nút thoát
- Progress bar
- Question card với badge loại câu hỏi
- Options với animation
- Result dialog với stats

### QuizHistoryPage
- Stats card với gradient
- History list với status badge
- Empty state
- Pull to refresh

---

## ✅ Checklist tích hợp

- [ ] Thêm `intl` package vào `pubspec.yaml`
- [ ] Import `quiz_page.dart` vào lesson detail
- [ ] Thêm nút "Làm bài kiểm tra"
- [ ] Import `quiz_history_page.dart` vào menu/profile
- [ ] Thêm mục "Lịch sử làm bài"
- [ ] Test với quiz có sẵn trong database
- [ ] Test với lesson chưa có quiz
- [ ] Test submit và xem kết quả
- [ ] Test xem lịch sử
- [ ] Test pull to refresh

---

**Hoàn thành! Quiz UI đã sẵn sàng sử dụng! 🎉**
