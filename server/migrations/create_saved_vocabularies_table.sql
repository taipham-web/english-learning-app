-- Tạo bảng saved_vocabularies để lưu từ vựng yêu thích của user
CREATE TABLE IF NOT EXISTS saved_vocabularies (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    vocabulary_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Foreign keys
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (vocabulary_id) REFERENCES vocabularies(id) ON DELETE CASCADE,
    
    -- Đảm bảo mỗi user chỉ lưu 1 từ vựng 1 lần
    UNIQUE KEY unique_user_vocabulary (user_id, vocabulary_id)
);

-- Thêm index để tối ưu query
CREATE INDEX idx_saved_vocabularies_user_id ON saved_vocabularies(user_id);
CREATE INDEX idx_saved_vocabularies_vocabulary_id ON saved_vocabularies(vocabulary_id);
