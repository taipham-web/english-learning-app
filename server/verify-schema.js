const db = require("./db");

async function verifySchema() {
  try {
    console.log("🔍 Verifying quizzes table schema...\n");

    const [columns] = await db.query("DESCRIBE quizzes");

    console.log("Columns in 'quizzes' table:");
    console.log("─".repeat(80));
    columns.forEach((col) => {
      console.log(
        `${col.Field.padEnd(20)} | ${col.Type.padEnd(20)} | ${col.Null.padEnd(5)} | ${col.Default || "NULL"}`
      );
    });
    console.log("─".repeat(80));

    // Check if passing_score and time_limit exist
    const hasPassingScore = columns.some((col) => col.Field === "passing_score");
    const hasTimeLimit = columns.some((col) => col.Field === "time_limit");

    console.log("\n✅ Schema verification:");
    console.log(`   - passing_score column: ${hasPassingScore ? "EXISTS" : "MISSING"}`);
    console.log(`   - time_limit column: ${hasTimeLimit ? "EXISTS" : "MISSING"}`);

    if (hasPassingScore && hasTimeLimit) {
      console.log("\n🎉 All required columns are present!");
    } else {
      console.log("\n⚠️  Some columns are missing. Please run the migration.");
    }

    process.exit(0);
  } catch (error) {
    console.error("❌ Error:", error.message);
    process.exit(1);
  }
}

verifySchema();
