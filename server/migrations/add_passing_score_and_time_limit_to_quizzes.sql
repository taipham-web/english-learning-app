-- Migration: Add passing_score and time_limit columns to quizzes table
-- Purpose: Add quiz settings for passing score and time limit

-- Add passing_score column (default 70%)
ALTER TABLE quizzes 
ADD COLUMN passing_score INT DEFAULT 70 COMMENT 'Minimum percentage to pass the quiz' 
AFTER description;

-- Add time_limit column (default 600 seconds = 10 minutes)
ALTER TABLE quizzes 
ADD COLUMN time_limit INT DEFAULT 600 COMMENT 'Time limit in seconds' 
AFTER passing_score;

-- Verify the changes
DESCRIBE quizzes;
