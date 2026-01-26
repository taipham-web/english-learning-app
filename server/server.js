// server/server.js
const express = require("express");
const cors = require("cors");

const app = express();
const PORT = process.env.PORT || 5000;

// === ROUTES ===
const authRoutes = require("./src/routes/auth.routes");
const topicRoutes = require("./src/routes/topic.routes");
const userRoutes = require("./src/routes/user.routes");
const lessonRoutes = require("./src/routes/lesson.routes");
const statsRoutes = require("./src/routes/stats.routes");

// === MIDDLEWARE ===
app.use(cors());
app.use(express.json());

// === API ROUTES (RESTful) ===
// Base URL: /api/v1
app.use("/api/v1/auth", authRoutes); // Auth: login, register
app.use("/api/v1/topics", topicRoutes); // Topics: CRUD
app.use("/api/v1/users", userRoutes); // Users: profile
app.use("/api/v1/lessons", lessonRoutes); // Lessons: CRUD
app.use("/api/v1/stats", statsRoutes); // Stats: dashboard

// Backwards compatibility - old API routes (có thể xóa sau)
app.use("/api", authRoutes); // /api/login, /api/register

// Health check
app.get("/api/health", (req, res) => {
  res.json({ status: "OK", message: "Server is running!" });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({ success: false, message: "Route not found" });
});

// Error handler
app.use((err, req, res, next) => {
  console.error("Server Error:", err);
  res.status(500).json({ success: false, message: "Internal server error" });
});

app.listen(PORT, () => {
  console.log(`🚀 Server chạy tại http://localhost:${PORT}`);
  console.log(`📚 API Docs:`);
  console.log(`   - Auth: POST /api/v1/auth/login, /api/v1/auth/register`);
  console.log(`   - Topics: GET/POST/PUT/DELETE /api/v1/topics`);
  console.log(`   - Lessons: GET/POST/PUT/DELETE /api/v1/lessons`);
});
