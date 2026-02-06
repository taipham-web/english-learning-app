# Quiz API Documentation

## Base URL
```
http://localhost:5000/api/v1/quizzes
```

## Endpoints

### 1. Lấy Quiz theo Lesson ID
**GET** `/lesson/:lessonId`

Lấy bài kiểm tra của một bài học cụ thể.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 1,
    "lesson_id": 5,
    "title": "Kiểm tra từ vựng cơ bản",
    "description": "Bài kiểm tra 10 câu",
    "questions": [
      {
        "id": 1,
        "quiz_id": 1,
        "content": "What does 'apple' mean?",
        "type": "multiple_choice",
        "explanation": "Apple nghĩa là quả táo",
        "options": [
          {
            "id": 1,
            "question_id": 1,
            "content": "Quả táo",
            "is_correct": 1
          },
          {
            "id": 2,
            "question_id": 1,
            "content": "Quả cam",
            "is_correct": 0
          }
        ]
      }
    ]
  }
}
```

---

### 2. Lấy Quiz theo ID
**GET** `/:id`

Lấy thông tin chi tiết của một quiz.

**Response:** Tương tự endpoint 1

---

### 3. Submit Kết Quả Quiz
**POST** `/:quizId/submit`

Nộp bài làm và nhận kết quả.

**Request Body:**
```json
{
  "user_id": 1,
  "answers": [
    {
      "question_id": 1,
      "selected_option_id": 1
    },
    {
      "question_id": 2,
      "selected_option_id": 5
    }
  ],
  "time_spent": 120
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "result_id": 15,
    "score": 8,
    "total_questions": 10,
    "percentage": "80.00",
    "passed": true
  },
  "message": "Chúc mừng! Bạn đã đạt yêu cầu"
}
```

---

### 4. Lấy Lịch Sử Làm Bài
**GET** `/results/user/:userId`

Lấy lịch sử làm bài của user.

**Query Parameters:**
- `quiz_id` (optional): Lọc theo quiz cụ thể

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 15,
      "user_id": 1,
      "quiz_id": 1,
      "score": 8,
      "total_questions": 10,
      "percentage": 80.00,
      "time_spent": 120,
      "completed_at": "2026-02-04T15:30:00.000Z",
      "quiz_title": "Kiểm tra từ vựng cơ bản",
      "lesson_id": 5,
      "lesson_title": "Từ vựng về trái cây"
    }
  ]
}
```

---

### 5. Lấy Điểm Cao Nhất
**GET** `/:quizId/best-score/:userId`

Lấy điểm cao nhất của user cho một quiz.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": 15,
    "user_id": 1,
    "quiz_id": 1,
    "score": 10,
    "total_questions": 10,
    "percentage": 100.00,
    "time_spent": 95,
    "completed_at": "2026-02-04T15:30:00.000Z"
  }
}
```

---

### 6. Lấy Thống Kê Quiz
**GET** `/stats/user/:userId`

Lấy thống kê tổng quan về quiz của user.

**Response:**
```json
{
  "success": true,
  "data": {
    "total_attempts": 25,
    "average_score": 75.50,
    "best_score": 100.00,
    "passed_count": 20
  }
}
```

---

### 7. Tạo Quiz Mới (Admin)
**POST** `/`

Tạo bài kiểm tra mới.

**Request Body:**
```json
{
  "lesson_id": 5,
  "title": "Kiểm tra từ vựng cơ bản",
  "description": "Bài kiểm tra 10 câu",
  "questions": [
    {
      "content": "What does 'apple' mean?",
      "type": "multiple_choice",
      "explanation": "Apple nghĩa là quả táo",
      "options": [
        {
          "content": "Quả táo",
          "is_correct": true
        },
        {
          "content": "Quả cam",
          "is_correct": false
        },
        {
          "content": "Quả chuối",
          "is_correct": false
        },
        {
          "content": "Quả nho",
          "is_correct": false
        }
      ]
    }
  ]
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "quizId": 1,
    "message": "Quiz created successfully"
  }
}
```

---

### 8. Xóa Quiz
**DELETE** `/:id`

Xóa một bài kiểm tra.

**Response:**
```json
{
  "success": true,
  "message": "Đã xóa bài kiểm tra"
}
```

---

## Database Schema

### Table: `quizzes`
```sql
CREATE TABLE quizzes (
  id INT AUTO_INCREMENT PRIMARY KEY,
  lesson_id INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (lesson_id) REFERENCES lessons(id) ON DELETE CASCADE
);
```

### Table: `questions`
```sql
CREATE TABLE questions (
  id INT AUTO_INCREMENT PRIMARY KEY,
  quiz_id INT NOT NULL,
  content TEXT NOT NULL,
  type VARCHAR(50) DEFAULT 'multiple_choice',
  explanation TEXT,
  FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE
);
```

### Table: `question_options`
```sql
CREATE TABLE question_options (
  id INT AUTO_INCREMENT PRIMARY KEY,
  question_id INT NOT NULL,
  content TEXT NOT NULL,
  is_correct BOOLEAN DEFAULT FALSE,
  FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE
);
```

### Table: `quiz_results`
```sql
CREATE TABLE quiz_results (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  quiz_id INT NOT NULL,
  score INT NOT NULL DEFAULT 0,
  total_questions INT NOT NULL,
  percentage DECIMAL(5,2) NOT NULL,
  time_spent INT DEFAULT NULL,
  completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE
);
```

### Table: `quiz_answer_details`
```sql
CREATE TABLE quiz_answer_details (
  id INT AUTO_INCREMENT PRIMARY KEY,
  quiz_result_id INT NOT NULL,
  question_id INT NOT NULL,
  selected_option_id INT DEFAULT NULL,
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  FOREIGN KEY (quiz_result_id) REFERENCES quiz_results(id) ON DELETE CASCADE,
  FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
  FOREIGN KEY (selected_option_id) REFERENCES question_options(id) ON DELETE SET NULL
);
```

---

## Usage Examples

### Flutter/Dart Example
```dart
import 'package:your_app/data/datasources/quiz_service.dart';
import 'package:your_app/data/models/quiz_model.dart';

final quizService = QuizService();

// Lấy quiz
final result = await quizService.getQuizByLessonId(5);
if (result['success']) {
  QuizModel quiz = result['quiz'];
  print('Quiz: ${quiz.title}');
}

// Submit quiz
final submission = QuizSubmission(
  userId: 1,
  answers: [
    QuizAnswer(questionId: 1, selectedOptionId: 1),
    QuizAnswer(questionId: 2, selectedOptionId: 5),
  ],
  timeSpent: 120,
);

final submitResult = await quizService.submitQuiz(
  quizId: 1,
  submission: submission,
);

if (submitResult['success']) {
  QuizResult result = submitResult['result'];
  print('Score: ${result.score}/${result.totalQuestions}');
  print('Percentage: ${result.percentage}%');
  print('Passed: ${result.passed}');
}
```

### JavaScript/Axios Example
```javascript
import axios from 'axios';

const API_BASE = 'http://localhost:5000/api/v1/quizzes';

// Lấy quiz
const getQuiz = async (lessonId) => {
  const response = await axios.get(`${API_BASE}/lesson/${lessonId}`);
  return response.data;
};

// Submit quiz
const submitQuiz = async (quizId, userId, answers, timeSpent) => {
  const response = await axios.post(`${API_BASE}/${quizId}/submit`, {
    user_id: userId,
    answers: answers,
    time_spent: timeSpent,
  });
  return response.data;
};
```

---

## Error Handling

All endpoints return consistent error responses:

```json
{
  "success": false,
  "message": "Error description here"
}
```

Common HTTP Status Codes:
- `200` - Success
- `201` - Created
- `400` - Bad Request (missing parameters)
- `404` - Not Found
- `500` - Internal Server Error
