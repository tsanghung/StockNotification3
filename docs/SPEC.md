
SPEC_FOR_AI.md
專案全域背景 (Global Context)
專案名稱：Daily Morning Report (每日晨報自動化系統)
核心目標：每日上午 6 點自動抓取美股指數、政經新聞與 AI 產業動態，翻譯並彙整為深色主題的互動式 HTML 單頁簡報，最終透過 LINE Messaging API 推播 GitHub Pages 網址。
技術棧 (Tech Stack)：
資料模型與 Schema (Data Architecture)
TypeScript
// 美股指數資料模型
interface StockData {
  name: string;           // 股名/股號
  price: number;          // 最新股價
  change: number;         // 漲跌
  change_percent: string; // 漲跌幅（%）
}

// 新聞與趨勢資料模型
interface NewsItem {
  title: string;          // 中文標題
  source_url: string;     // 來源網址
  category: "Politics_Economy" | "AI_Trends";
  publish_time: string;   // 發布時間（確保為過去 24 小時內）
}
核心模組規格 (Module Specifications)
模組 1：股市動態爬蟲 (Stock Scraper)
進入點：fetch_yahoo_finance()
輸入：無。
輸出：List[StockData]
商務邏輯規則：
模組 2：新聞與 AI 趨勢搜尋 (News Search & Translation)
進入點：search_and_translate_news()
輸入：各領域的關鍵字陣列。
輸出：List[NewsItem]
商務邏輯規則：
模組 3：介面生成與靜態化 (HTML Generator)
進入點：generate_morning_report_html(stocks, news)
輸入：模組 1 與模組 2 的輸出陣列。
輸出：產出 public/index.html 檔案。
商務邏輯規則：
模組 4：自動化部署與推播 (Deploy & Notify)
進入點：push_line_message(url)
輸入：GitHub Pages 部署完成後的固定網址。
輸出：HTTP 狀態碼 200。
商務邏輯規則：
開發規範與自動化 (Implementation Guidelines)
目錄結構：
GitHub Actions 排程設定：
風險與邊界情況 (Risk & Edge Cases)
API 限流 (Rate Limit)：搜尋與翻譯 API 若遇到 HTTP 429 錯誤，必須實作 Exponential Backoff 重試機制。
零搜尋結果：若特定關鍵字在 24 小時內無任何新聞，HTML 對應區塊需顯示「過去 24 小時無重大更新」，以維持版面完整性。
網頁載入超時：Playwright 抓取 Yahoo 股價時需設定 Timeout 為 30 秒，超時則直接抓取前一日靜態快取資料並於介面上標註警告。