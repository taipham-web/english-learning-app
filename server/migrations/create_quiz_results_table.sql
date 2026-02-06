-- Migration: Create quiz_results table
-- Purpose: Store user quiz attempt results and history

CREATE TABLE IF NOT EXISTS quiz_results (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id INT NOT NULL,
  quiz_id INT NOT NULL,
  score INT NOT NULL DEFAULT 0,
  total_questions INT NOT NULL,
  percentage DECIMAL(5,2) NOT NULL,
  time_spent INT DEFAULT NULL COMMENT 'Time spent in seconds',
  completed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  -- Foreign keys
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  FOREIGN KEY (quiz_id) REFERENCES quizzes(id) ON DELETE CASCADE,
  
  -- Indexes for better query performance
  INDEX idx_user_id (user_id),
  INDEX idx_quiz_id (quiz_id),
  INDEX idx_completed_at (completed_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Optional: Create a table to store detailed answers for each question
CREATE TABLE IF NOT EXISTS quiz_answer_details (
  id INT AUTO_INCREMENT PRIMARY KEY,
  quiz_result_id INT NOT NULL,
  question_id INT NOT NULL,
  selected_option_id INT DEFAULT NULL,
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  
  FOREIGN KEY (quiz_result_id) REFERENCES quiz_results(id) ON DELETE CASCADE,
  FOREIGN KEY (question_id) REFERENCES questions(id) ON DELETE CASCADE,
  FOREIGN KEY (selected_option_id) REFERENCES question_options(id) ON DELETE SET NULL,
  
  INDEX idx_quiz_result_id (quiz_result_id),
  INDEX idx_question_id (question_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
