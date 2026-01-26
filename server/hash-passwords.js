// Script để hash password cho user có plain text password
const db = require("./db");
const bcrypt = require("bcrypt");

async function hashExistingPasswords() {
  try {
    // Lấy tất cả users
    const [users] = await db.query("SELECT id, email, password FROM users");

    for (const user of users) {
      // Kiểm tra nếu password chưa được hash (bcrypt hash bắt đầu bằng $2)
      if (!user.password.startsWith("$2")) {
        console.log(`Hashing password cho user: ${user.email}`);

        const hashedPassword = await bcrypt.hash(user.password, 10);

        await db.query("UPDATE users SET password = ? WHERE id = ?", [
          hashedPassword,
          user.id,
        ]);

        console.log(`✅ Đã hash password cho: ${user.email}`);
      } else {
        console.log(`⏭️ ${user.email} - Password đã được hash rồi`);
      }
    }

    console.log("\n🎉 Hoàn thành!");
    process.exit(0);
  } catch (error) {
    console.error("❌ Lỗi:", error);
    process.exit(1);
  }
}

hashExistingPasswords();
