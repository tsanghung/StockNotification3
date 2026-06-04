require("dotenv").config();
const { fetchStockData } = require("./src/scraper");
const { fetchAndTranslateNews } = require("./src/news");
const { generateMorningReportHTML } = require("./src/generator");
const { pushLineMessage } = require("./src/notifier");

async function main() {
  console.log("🚀 開始執行每日晨報自動化流程...");
  
  try {
    // 1. 抓取股市數據
    console.log("\n[1/4] 正在抓取股市數據...");
    const stocks = await fetchStockData();
    
    // 2. 抓取並翻譯新聞
    console.log("\n[2/4] 正在抓取並翻譯新聞...");
    const news = await fetchAndTranslateNews();
    
    // 3. 產生 HTML 報表
    console.log("\n[3/4] 正在產生 HTML 報表...");
    generateMorningReportHTML(stocks, news);
    
    // 4. 發送 LINE 通知 (測試階段可先關閉或針對使用者發送)
    if (process.env.LINE_CHANNEL_ACCESS_TOKEN) {
      console.log("\n[4/4] 正在發送 LINE 通知...");
      // 假設 GitHub Pages 網址如下 (使用者之後可調整)
      const githubPagesUrl = "https://tsanghung.github.io/StockNotification2/";
      await pushLineMessage(githubPagesUrl);
    } else {
      console.log("\n[4/4] 跳過 LINE 通知 (未設定 TOKEN)");
    }
    
    console.log("\n✨ 任務圓滿完成！");
  } catch (error) {
    console.error("\n❌ 流程熱行失敗:", error);
  }
}

main();
