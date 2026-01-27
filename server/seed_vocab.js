const db = require("./db"); // Sử dụng db.js ở root
const axios = require("axios");

// === CẤU HÌNH ===
const LESSON_ID = 2; // Bạn muốn nạp từ vào bài học nào? (VD: Bài 1)
const WORD_LIST = [
  // Các môn thể thao
  { word: "football", meaning: "Bóng đá" },
  { word: "soccer", meaning: "Bóng đá (cách gọi Mỹ)" },
  { word: "basketball", meaning: "Bóng rổ" },
  { word: "volleyball", meaning: "Bóng chuyền" },
  { word: "badminton", meaning: "Cầu lông" },
  { word: "tennis", meaning: "Quần vợt" },
  { word: "swimming", meaning: "Bơi lội" },
  { word: "baseball", meaning: "Bóng chày" },
  { word: "golf", meaning: "Môn gôn" },
  { word: "boxing", meaning: "Quyền anh" },

  // Người chơi & Vai trò
  { word: "athlete", meaning: "Vận động viên" },
  { word: "coach", meaning: "Huấn luyện viên" },
  { word: "referee", meaning: "Trọng tài" },
  { word: "goalkeeper", meaning: "Thủ môn" },
  { word: "opponent", meaning: "Đối thủ" },
  { word: "spectator", meaning: "Khán giả" },

  // Dụng cụ & Địa điểm
  { word: "stadium", meaning: "Sân vận động" },
  { word: "gym", meaning: "Phòng tập thể hình" },
  { word: "racket", meaning: "Cây vợt" },
  { word: "whistle", meaning: "Còi (trọng tài)" },
  { word: "medal", meaning: "Huy chương" },
  { word: "trophy", meaning: "Cúp vô địch" },

  // Hành động & Thuật ngữ
  { word: "match", meaning: "Trận đấu" },
  { word: "tournament", meaning: "Giải đấu" },
  { word: "championship", meaning: "Giải vô địch" },
  { word: "score", meaning: "Tỉ số / Ghi bàn" },
  { word: "victory", meaning: "Chiến thắng" },
  { word: "defeat", meaning: "Thất bại" },
];

// Hàm lấy dữ liệu từ Dictionary API
async function fetchWordData(word) {
  try {
    const response = await axios.get(
      `https://api.dictionaryapi.dev/api/v2/entries/en/${word}`,
    );
    const data = response.data[0];

    // Lấy phonetic (ưu tiên cái có text)
    const phonetic =
      data.phonetic ||
      (data.phonetics.find((p) => p.text)
        ? data.phonetics.find((p) => p.text).text
        : "");

    // Lấy audio (ưu tiên giọng Mỹ hoặc Anh)
    const audioObj = data.phonetics.find((p) => p.audio && p.audio !== "");
    const audio_url = audioObj ? audioObj.audio : null;

    return { phonetic, audio_url };
  } catch (error) {
    console.log(`⚠️ Không tìm thấy data cho từ: ${word}`);
    return { phonetic: "", audio_url: null };
  }
}

// Hàm chạy chính
async function seedVocab() {
  console.log("🚀 Bắt đầu nạp dữ liệu...");

  for (const item of WORD_LIST) {
    console.log(`Processing: ${item.word}...`);

    // 1. Gọi API lấy phonetic & audio
    const extraData = await fetchWordData(item.word);

    // 2. Lưu vào MySQL
    try {
      await db.query(
        "INSERT INTO vocabularies (lesson_id, word, meaning, phonetic, audio_url) VALUES (?, ?, ?, ?, ?)",
        [
          LESSON_ID,
          item.word,
          item.meaning,
          extraData.phonetic,
          extraData.audio_url,
        ],
      );
      console.log(`✅ Đã lưu: ${item.word}`);
    } catch (err) {
      console.error(`❌ Lỗi lưu DB: ${item.word}`, err.message);
    }
  }

  console.log("🎉 Hoàn tất!");
  process.exit();
}

seedVocab();
