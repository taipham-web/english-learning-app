// server/db.js
const mysql = require("mysql2");

// Tạo kết nối (Connection Pool)
const pool = mysql.createPool({
  host: "localhost", // Địa chỉ database (thường là localhost)
  user: "root", // Tên đăng nhập MySQL (XAMPP thường là root)
  password: "123456", // Mật khẩu MySQL (XAMPP thường để trống)
  database: "english_app", // Tên database bạn vừa tạo
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0,
});

// Export dạng promise để dùng async/await
module.exports = pool.promise();
