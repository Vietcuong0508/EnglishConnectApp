/* eslint-disable max-len */
const functions = require("firebase-functions");
const express = require("express");
const axios = require("axios");
const cors = require("cors");

const app = express();
app.use(cors({origin: true}));
app.use(express.json());

app.get("/translate", async (req, res) => {
  try {
    // --- SỬA ĐỔI QUAN TRỌNG: Dùng process.env cho Gen 2 ---
    const googleKey = process.env.GOOGLE_KEY;

    // Log kiểm tra (chỉ in 5 ký tự đầu để bảo mật)
    if (googleKey) {
      console.log("✅ Config loaded via .env: " + googleKey.substring(0, 5) + "...");
    } else {
      console.error("❌ CRITICAL ERROR: GOOGLE_KEY not found in process.env");
      return res.status(500).json({
        error: "Configuration Error",
        detail: "Missing GOOGLE_KEY in .env file",
      });
    }
    // -------------------------------------------------------

    const text = req.query.q;
    if (!text) {
      return res.status(400).json({error: "Missing query parameter ?q="});
    }

    const url = "https://translation.googleapis.com/language/translate/v2?key=" + googleKey;
    const body = {
      q: text,
      source: "en",
      target: "vi",
      format: "text",
    };

    const response = await axios.post(url, body, {timeout: 10000});

    let translatedText = null;
    // Check an toàn kiểu cũ
    if (response && response.data && response.data.data && response.data.data.translations) {
      if (response.data.data.translations.length > 0) {
        translatedText = response.data.data.translations[0].translatedText;
      }
    }

    return res.json({result: translatedText});
  } catch (err) {
    console.error("❌ Translate API Error:", err.message);
    // Lấy chi tiết lỗi từ Google nếu có
    const detail = err.response && err.response.data ? err.response.data : err.toString();
    return res.status(500).json({
      error: "translate_error",
      detail: detail,
    });
  }
});

// Export
exports.api = functions.https.onRequest(app);
