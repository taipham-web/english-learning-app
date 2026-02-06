const db = require("./db");

async function addColumns() {
  try {
    // Check if columns already exist
    const [columns] = await db.query("DESCRIBE quizzes");
    const columnNames = columns.map((col) => col.Field);

    if (!columnNames.includes("passing_score")) {
      console.log("🔄 Adding passing_score column...");
      await db.query(`
        ALTER TABLE quizzes 
        ADD COLUMN passing_score INT DEFAULT 70 
        COMMENT 'Minimum percentage to pass the quiz' 
        AFTER description
      `);
      console.log("✅ passing_score column added");
    } else {
      console.log("ℹ️  passing_score column already exists");
    }

    if (!columnNames.includes("time_limit")) {
      console.log("🔄 Adding time_limit column...");
      await db.query(`
        ALTER TABLE quizzes 
        ADD COLUMN time_limit INT DEFAULT 600 
        COMMENT 'Time limit in seconds' 
        AFTER passing_score
      `);
      console.log("✅ time_limit column added");
    } else {
      console.log("ℹ️  time_limit column already exists");
    }

    console.log("\n🎉 Migration completed successfully!");
    process.exit(0);
  } catch (error) {
    console.error("❌ Migration failed:", error.message);
    process.exit(1);
  }
}

addColumns();
