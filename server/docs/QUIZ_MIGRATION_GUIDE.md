# Hướng dẫn chạy Migration cho Quiz

## ⚠️ Quan trọng: Thứ tự chạy migration

Bạn cần chạy migration theo đúng thứ tự sau:
1. **create_quiz_tables.sql** - Tạo tất cả bảng quiz (quizzes, questions, question_options, quiz_results, quiz_answer_details)

## Bước 1: Kết nối MySQL

```bash
mysql -u root -p
```

## Bước 2: Chọn database

```sql
USE english_learning_app;
-- Hoặc tên database của bạn
```

## Bước 3: Chạy migration

### ✅ Khuyến nghị: Chạy file migration hoàn chỉnh

```bash
# Từ thư mục server - Tạo TẤT CẢ bảng quiz cùng lúc
mysql -u root -p english_learning_app < migrations/create_quiz_tables.sql
```

### Cách 2: Copy và paste SQL vào MySQL console

1. Mở file `migrations/create_quiz_tables.sql`
2. Copy toàn bộ nội dung
3. Paste vào MySQL console và Enter

## Bước 4: Kiểm tra tables đã được tạo

```sql
-- Xem tất cả bảng quiz
SHOW TABLES LIKE '%quiz%';
SHOW TABLES LIKE '%question%';

-- Kiểm tra cấu trúc từng bảng
DESC quizzes;
DESC questions;
DESC question_options;
DESC quiz_results;
DESC quiz_answer_details;
```

## Bước 5: (Optional) Tạo dữ liệu mẫu

```sql
-- Tạo quiz mẫu cho lesson 1
INSERT INTO quizzes (lesson_id, title, description) 
VALUES (1, 'Kiểm tra từ vựng cơ bản', 'Bài kiểm tra 5 câu về từ vựng cơ bản');

-- Lấy quiz_id vừa tạo
SET @quiz_id = LAST_INSERT_ID();

-- Tạo câu hỏi 1
INSERT INTO questions (quiz_id, content, type, explanation) 
VALUES (@quiz_id, 'What does "hello" mean?', 'multiple_choice', 'Hello nghĩa là xin chào');

SET @q1_id = LAST_INSERT_ID();

-- Tạo các đáp án cho câu hỏi 1
INSERT INTO question_options (question_id, content, is_correct) VALUES
(@q1_id, 'Xin chào', 1),
(@q1_id, 'Tạm biệt', 0),
(@q1_id, 'Cảm ơn', 0),
(@q1_id, 'Xin lỗi', 0);

-- Tạo câu hỏi 2
INSERT INTO questions (quiz_id, content, type, explanation) 
VALUES (@quiz_id, 'What does "goodbye" mean?', 'multiple_choice', 'Goodbye nghĩa là tạm biệt');

SET @q2_id = LAST_INSERT_ID();

-- Tạo các đáp án cho câu hỏi 2
INSERT INTO question_options (question_id, content, is_correct) VALUES
(@q2_id, 'Xin chào', 0),
(@q2_id, 'Tạm biệt', 1),
(@q2_id, 'Cảm ơn', 0),
(@q2_id, 'Xin lỗi', 0);

-- Kiểm tra dữ liệu
SELECT * FROM quizzes WHERE id = @quiz_id;
SELECT * FROM questions WHERE quiz_id = @quiz_id;
SELECT * FROM question_options WHERE question_id IN (@q1_id, @q2_id);
```

## Bước 6: Test API

### Test lấy quiz theo lesson
```bash
curl http://localhost:5000/api/v1/quizzes/lesson/1
```

### Test submit quiz
```bash
curl -X POST http://localhost:5000/api/v1/quizzes/1/submit \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": 1,
    "answers": [
      {"question_id": 1, "selected_option_id": 1},
      {"question_id": 2, "selected_option_id": 5}
    ],
    "time_spent": 60
  }'
```

### Test lấy lịch sử
```bash
curl http://localhost:5000/api/v1/quizzes/results/user/1
```

## Troubleshooting

### Lỗi: Table already exists
```sql
-- Xóa bảng cũ nếu cần
DROP TABLE IF EXISTS quiz_answer_details;
DROP TABLE IF EXISTS quiz_results;
```

### Lỗi: Foreign key constraint fails
Đảm bảo các bảng `users`, `quizzes`, `questions`, `question_options` đã tồn tại trước khi chạy migration.

### Kiểm tra foreign keys
```sql
SELECT 
  TABLE_NAME,
  COLUMN_NAME,
  CONSTRAINT_NAME,
  REFERENCED_TABLE_NAME,
  REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'english_learning_app'
  AND TABLE_NAME IN ('quiz_results', 'quiz_answer_details');
```

## Rollback (Xóa tables)

```sql
-- Xóa theo thứ tự ngược lại (từ child đến parent)
DROP TABLE IF EXISTS quiz_answer_details;
DROP TABLE IF EXISTS quiz_results;
```

## Kiểm tra dữ liệu sau khi test

```sql
-- Xem kết quả quiz
SELECT 
  qr.*,
  u.username,
  q.title as quiz_title
FROM quiz_results qr
JOIN users u ON qr.user_id = u.id
JOIN quizzes q ON qr.quiz_id = q.id
ORDER BY qr.completed_at DESC;

-- Xem chi tiết câu trả lời
SELECT 
  qad.*,
  q.content as question,
  qo.content as selected_answer
FROM quiz_answer_details qad
JOIN questions q ON qad.question_id = q.id
LEFT JOIN question_options qo ON qad.selected_option_id = qo.id
WHERE qad.quiz_result_id = 1;
```
