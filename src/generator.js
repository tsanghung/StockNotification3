const fs = require("fs");

/**
 * 產生每日晨報 HTML
 */
function generateMorningReportHTML(stocks, news) {
  const dateStr = new Date().toLocaleDateString("zh-TW", {
    year: "numeric",
    month: "long",
    day: "numeric",
    weekday: "long",
    timeZone: "Asia/Taipei"
  });

  const stockCards = stocks.map(s => `
    <div class="card stock-card">
      <div class="symbol">${s.symbol}</div>
      <div class="name">${s.name}</div>
      <div class="price">${s.price}</div>
      <div class="change ${parseFloat(s.change.replace(/,/g, '')) >= 0 ? "up" : "down"}">
        ${s.change} (${s.change_percent})
      </div>
    </div>
  `).join("");

  // 定義新聞區塊及其對應的類別
  const recapCategories = {
    US_Market_Recap: "美股盤後回顧",
    TW_Market_Pre: "台股盤前重點"
  };

  const focusCategories = {
    Politics_Economy: "國內外政經",
    AI_Trends: "AI 產業趨勢"
  };

  const generateNewsGrid = (categories) => {
    return Object.entries(categories).map(([cat, label]) => {
      const items = news.filter(n => n.category === cat);
      const listItems = items.length > 0 ? items.map(n => `
        <li>
          <a href="${n.source_url}" target="_blank">
            <span class="news-title">${n.title}</span>
            <span class="news-time">${n.publish_time ? new Date(n.publish_time).toLocaleTimeString("zh-TW", { hour: "2-digit", minute: "2-digit", timeZone: "Asia/Taipei" }) : ""}</span>
          </a>
        </li>
      `).join("") : "<li>目前無重大更新</li>";

      return `
        <div class="news-section">
          <h3>${label}</h3>
          <ul>${listItems}</ul>
        </div>
      `;
    }).join("");
  };

  const recapSections = generateNewsGrid(recapCategories);
  const focusSections = generateNewsGrid(focusCategories);

  const htmlContent = `
<!DOCTYPE html>
<html lang="zh-TW">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>每日晨報 - ${dateStr}</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;600;800&family=Outfit:wght@400;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg: #0f172a;
            --card-bg: rgba(30, 41, 59, 0.7);
            --text: #f8fafc;
            --accent: #38bdf8;
            /* 顏色顯示設定：採用台股慣例（紅漲綠跌） */
            --up-color: #ef4444;   /* 紅色 */
            --down-color: #22c55e; /* 綠色 */
            --green: #22c55e;
            --red: #ef4444;
        }
        body {
            background-color: var(--bg);
            color: var(--text);
            font-family: 'Outfit', 'Inter', sans-serif;
            margin: 0;
            padding: 20px;
            line-height: 1.6;
            background: linear-gradient(135deg, #0f172a 0%, #1e293b 100%);
            min-height: 100vh;
        }
        .container {
            max-width: 1000px;
            margin: 0 auto;
        }
        header {
            text-align: center;
            margin-bottom: 40px;
            padding: 40px 0;
        }
        h1 {
            font-size: 3rem;
            margin: 0;
            background: linear-gradient(to right, #38bdf8, #818cf8);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            font-weight: 800;
        }
        .date {
            font-size: 1.2rem;
            color: #94a3b8;
            margin-top: 10px;
        }
        .section-title {
            font-size: 1.5rem;
            border-left: 4px solid var(--accent);
            padding-left: 15px;
            margin: 40px 0 20px;
            font-weight: 700;
        }
        /* 股市卡片區域 */
        .stock-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(180px, 1fr));
            gap: 20px;
            margin-bottom: 40px;
        }
        .card {
            background: var(--card-bg);
            backdrop-filter: blur(12px);
            -webkit-backdrop-filter: blur(12px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            border-radius: 20px;
            padding: 20px;
            box-shadow: 0 8px 32px 0 rgba(0, 0, 0, 0.3);
            transition: transform 0.3s ease;
        }
        .card:hover {
            transform: translateY(-5px);
        }
        .stock-card .symbol {
            font-size: 0.8rem;
            color: #94a3b8;
            font-weight: 600;
        }
        .stock-card .name {
            font-size: 1.1rem;
            margin: 5px 0;
            font-weight: 700;
        }
        .stock-card .price {
            font-size: 1.5rem;
            font-weight: 800;
            margin: 10px 0;
        }
        .up { color: var(--red); }
        .down { color: var(--green); }

        /* 新聞區域 */
        .news-container {
            display: grid;
            grid-template-columns: 1fr;
            gap: 30px;
            margin-bottom: 40px;
        }
        .news-section h3 {
            color: var(--accent);
            margin-bottom: 15px;
        }
        .news-section ul {
            list-style: none;
            padding: 0;
        }
        .news-section li {
            background: var(--card-bg);
            margin-bottom: 10px;
            border-radius: 12px;
            transition: background 0.3s;
        }
        .news-section li:hover {
            background: rgba(56, 189, 248, 0.1);
        }
        .news-section a {
            text-decoration: none;
            color: var(--text);
            display: block;
            padding: 15px;
        }
        .news-title {
            display: block;
            font-size: 1rem;
            font-weight: 600;
        }
        .news-time {
            font-size: 0.8rem;
            color: #64748b;
            margin-top: 5px;
            display: block;
        }
        footer {
            text-align: center;
            margin-top: 80px;
            padding: 20px;
            color: #475569;
            font-size: 0.9rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>每日晨報</h1>
            <div class="date">${dateStr}</div>
        </header>

        <div class="section-title">今日股市動態</div>
        <div class="stock-grid">
            ${stockCards}
        </div>

        <div class="section-title">盤勢重點回顧</div>
        <div class="news-container">
            ${recapSections}
        </div>

        <div class="section-title">焦點新聞</div>
        <div class="news-container">
            ${focusSections}
        </div>

        <footer>
            &copy; 2026 Simon Morning Report. Generated by Antigravity.
        </footer>
    </div>
</body>
</html>
  `;
  
  if (!fs.existsSync("public")) fs.mkdirSync("public");
  fs.writeFileSync("public/index.html", htmlContent);
  console.log("HTML 報表已生成於 public/index.html");
}

module.exports = { generateMorningReportHTML };
