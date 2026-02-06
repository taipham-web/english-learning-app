// Test Quiz API Endpoints
// Chạy file này với: node test-quiz-api.js

const axios = require('axios');

const API_BASE = 'http://localhost:5000/api/v1';

// Test data
const testUserId = 1;
const testLessonId = 1;
let testQuizId = null;

async function testQuizAPI() {
  console.log('🧪 Bắt đầu test Quiz API...\n');

  try {
    // Test 1: Tạo quiz mới
    console.log('📝 Test 1: Tạo quiz mới');
    const createResponse = await axios.post(`${API_BASE}/quizzes`, {
      lesson_id: testLessonId,
      title: 'Kiểm tra từ vựng cơ bản',
      description: 'Bài kiểm tra 3 câu về từ vựng cơ bản',
      questions: [
        {
          content: 'What does "hello" mean?',
          type: 'multiple_choice',
          explanation: 'Hello nghĩa là xin chào',
          options: [
            { content: 'Xin chào', is_correct: true },
            { content: 'Tạm biệt', is_correct: false },
            { content: 'Cảm ơn', is_correct: false },
            { content: 'Xin lỗi', is_correct: false },
          ],
        },
        {
          content: 'What does "goodbye" mean?',
          type: 'multiple_choice',
          explanation: 'Goodbye nghĩa là tạm biệt',
          options: [
            { content: 'Xin chào', is_correct: false },
            { content: 'Tạm biệt', is_correct: true },
            { content: 'Cảm ơn', is_correct: false },
            { content: 'Xin lỗi', is_correct: false },
          ],
        },
        {
          content: 'What does "thank you" mean?',
          type: 'multiple_choice',
          explanation: 'Thank you nghĩa là cảm ơn',
          options: [
            { content: 'Xin chào', is_correct: false },
            { content: 'Tạm biệt', is_correct: false },
            { content: 'Cảm ơn', is_correct: true },
            { content: 'Xin lỗi', is_correct: false },
          ],
        },
      ],
    });

    if (createResponse.data.success) {
      testQuizId = createResponse.data.data.quizId;
      console.log('✅ Tạo quiz thành công! Quiz ID:', testQuizId);
    } else {
      console.log('❌ Tạo quiz thất bại:', createResponse.data.message);
      return;
    }

    // Test 2: Lấy quiz theo lesson ID
    console.log('\n📖 Test 2: Lấy quiz theo lesson ID');
    const getByLessonResponse = await axios.get(
      `${API_BASE}/quizzes/lesson/${testLessonId}`
    );

    if (getByLessonResponse.data.success) {
      const quiz = getByLessonResponse.data.data;
      console.log('✅ Lấy quiz thành công!');
      console.log(`   - Title: ${quiz.title}`);
      console.log(`   - Số câu hỏi: ${quiz.questions.length}`);
    } else {
      console.log('❌ Lấy quiz thất bại:', getByLessonResponse.data.message);
    }

    // Test 3: Lấy quiz theo ID
    console.log('\n📖 Test 3: Lấy quiz theo ID');
    const getByIdResponse = await axios.get(
      `${API_BASE}/quizzes/${testQuizId}`
    );

    if (getByIdResponse.data.success) {
      console.log('✅ Lấy quiz theo ID thành công!');
    } else {
      console.log('❌ Lấy quiz theo ID thất bại');
    }

    // Test 4: Submit quiz với điểm cao (3/3)
    console.log('\n📤 Test 4: Submit quiz (điểm cao - 3/3)');
    const quiz = getByIdResponse.data.data;
    const correctAnswers = quiz.questions.map((q) => {
      const correctOption = q.options.find((opt) => opt.is_correct === 1);
      return {
        question_id: q.id,
        selected_option_id: correctOption.id,
      };
    });

    const submitResponse1 = await axios.post(
      `${API_BASE}/quizzes/${testQuizId}/submit`,
      {
        user_id: testUserId,
        answers: correctAnswers,
        time_spent: 60,
      }
    );

    if (submitResponse1.data.success) {
      const result = submitResponse1.data.data;
      console.log('✅ Submit thành công!');
      console.log(`   - Điểm: ${result.score}/${result.total_questions}`);
      console.log(`   - Phần trăm: ${result.percentage}%`);
      console.log(`   - Đạt yêu cầu: ${result.passed ? 'Có' : 'Không'}`);
    } else {
      console.log('❌ Submit thất bại:', submitResponse1.data.message);
    }

    // Test 5: Submit quiz với điểm thấp (1/3)
    console.log('\n📤 Test 5: Submit quiz (điểm thấp - 1/3)');
    const wrongAnswers = quiz.questions.map((q, index) => {
      if (index === 0) {
        // Câu đầu đúng
        const correctOption = q.options.find((opt) => opt.is_correct === 1);
        return {
          question_id: q.id,
          selected_option_id: correctOption.id,
        };
      } else {
        // Các câu còn lại sai
        const wrongOption = q.options.find((opt) => opt.is_correct === 0);
        return {
          question_id: q.id,
          selected_option_id: wrongOption.id,
        };
      }
    });

    const submitResponse2 = await axios.post(
      `${API_BASE}/quizzes/${testQuizId}/submit`,
      {
        user_id: testUserId,
        answers: wrongAnswers,
        time_spent: 45,
      }
    );

    if (submitResponse2.data.success) {
      const result = submitResponse2.data.data;
      console.log('✅ Submit thành công!');
      console.log(`   - Điểm: ${result.score}/${result.total_questions}`);
      console.log(`   - Phần trăm: ${result.percentage}%`);
      console.log(`   - Đạt yêu cầu: ${result.passed ? 'Có' : 'Không'}`);
    }

    // Test 6: Lấy lịch sử làm bài
    console.log('\n📜 Test 6: Lấy lịch sử làm bài của user');
    const historyResponse = await axios.get(
      `${API_BASE}/quizzes/results/user/${testUserId}`
    );

    if (historyResponse.data.success) {
      const history = historyResponse.data.data;
      console.log(`✅ Lấy lịch sử thành công! Tổng: ${history.length} lần làm`);
      history.slice(0, 3).forEach((item, index) => {
        console.log(
          `   ${index + 1}. ${item.quiz_title}: ${item.score}/${item.total_questions} (${item.percentage}%)`
        );
      });
    } else {
      console.log('❌ Lấy lịch sử thất bại');
    }

    // Test 7: Lấy điểm cao nhất
    console.log('\n🏆 Test 7: Lấy điểm cao nhất của user cho quiz này');
    const bestScoreResponse = await axios.get(
      `${API_BASE}/quizzes/${testQuizId}/best-score/${testUserId}`
    );

    if (bestScoreResponse.data.success) {
      const bestScore = bestScoreResponse.data.data;
      if (bestScore) {
        console.log('✅ Lấy điểm cao nhất thành công!');
        console.log(`   - Điểm: ${bestScore.score}/${bestScore.total_questions}`);
        console.log(`   - Phần trăm: ${bestScore.percentage}%`);
      } else {
        console.log('⚠️  Chưa có lịch sử làm bài');
      }
    } else {
      console.log('❌ Lấy điểm cao nhất thất bại');
    }

    // Test 8: Lấy thống kê quiz
    console.log('\n📊 Test 8: Lấy thống kê quiz của user');
    const statsResponse = await axios.get(
      `${API_BASE}/quizzes/stats/user/${testUserId}`
    );

    if (statsResponse.data.success) {
      const stats = statsResponse.data.data;
      console.log('✅ Lấy thống kê thành công!');
      console.log(`   - Tổng số lần làm: ${stats.total_attempts}`);
      console.log(`   - Điểm trung bình: ${stats.average_score?.toFixed(2)}%`);
      console.log(`   - Điểm cao nhất: ${stats.best_score}%`);
      console.log(`   - Số lần đạt yêu cầu: ${stats.passed_count}`);
    } else {
      console.log('❌ Lấy thống kê thất bại');
    }

    console.log('\n✨ Hoàn thành tất cả tests!');
  } catch (error) {
    console.error('\n❌ Lỗi khi test API:');
    if (error.response) {
      console.error('   - Status:', error.response.status);
      console.error('   - Message:', error.response.data.message);
    } else {
      console.error('   -', error.message);
    }
  }
}

// Chạy tests
console.log('⚠️  Lưu ý: Đảm bảo server đang chạy tại http://localhost:5000');
console.log('⚠️  Và đã chạy migration cho quiz_results table\n');

testQuizAPI();
