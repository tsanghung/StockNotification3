const axios = require("axios");

/**
 * 透過 LINE Messaging API 發送通知
 */
async function pushLineMessage(url) {
  const token = (process.env.LINE_CHANNEL_ACCESS_TOKEN || "").trim();
  const userId = (process.env.LINE_USER_ID || "").trim();

  if (!token || !userId) {
    console.error("錯誤：未設定 LINE_CHANNEL_ACCESS_TOKEN 或 LINE_USER_ID");
    return;
  }

  const message = {
    to: userId,
    messages: [
      {
        type: "text",
        text: `☀️ Simon哥，早安！\n您今日的「每日晨報」已經產生囉！\n\n查看完整報表：\n${url}`
      }
    ]
  };

  try {
    const response = await axios.post("https://api.line.me/v2/bot/message/push", message, {
      headers: {
        "Content-Type": "application/json",
        Authorization: `Bearer ${token}`
      }
    });
    console.log("LINE 通知發送成功！");
    return response.status;
  } catch (error) {
    console.error("LINE 通知發送失敗:", error.response ? error.response.data : error.message);
    throw error;
  }
}

module.exports = { pushLineMessage };
