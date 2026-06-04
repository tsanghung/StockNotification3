const YahooFinance = require('yahoo-finance2').default;
const { chromium } = require('playwright');
const yahooFinance = new YahooFinance();

/**
 * 抓取股市數據，包含 Yahoo Finance 與網頁爬取
 */
async function fetchStockData() {
  const symbols = [
    { name: "道瓊工業指數", symbol: "^DJI" },
    { name: "S&P 500 指數", symbol: "^GSPC" },
    { name: "NASDAQ 指數", symbol: "^IXIC" },
    { name: "費城半導體指數", symbol: "^SOX" },
    { name: "台積電 ADR", symbol: "TSM" },
  ];

  const results = [];

  // 1. 抓取標準 Yahoo Finance 數據
  try {
    for (const item of symbols) {
      console.log(`正在抓取 ${item.name} (${item.symbol})...`);
      const quote = await yahooFinance.quote(item.symbol);
      
      if (quote) {
        results.push({
          name: item.name,
          symbol: item.symbol,
          price: quote.regularMarketPrice.toLocaleString(),
          change: quote.regularMarketChange.toFixed(2),
          change_percent: (quote.regularMarketChangePercent).toFixed(2) + "%",
        });
      }
    }
  } catch (error) {
    console.error("Yahoo Finance 抓取錯誤:", error);
  }

  // 2. 抓取台指期現貨 (WTX00) - 需網頁爬取
  console.log("正在抓取 台指期現貨 (WTX00)...");
  let browser;
  try {
    browser = await chromium.launch({ headless: true });
    const page = await browser.newPage();
    await page.goto('https://tw.stock.yahoo.com/future/WTX00', { waitUntil: 'domcontentloaded', timeout: 30000 });
    await page.waitForSelector('span.Fz\\(32px\\)', { timeout: 10000 });
    
    const txData = await page.evaluate(() => {
      const price = document.querySelector('span.Fz\\(32px\\)')?.innerText;
      const changeSpans = Array.from(document.querySelectorAll('span.Fz\\(20px\\)'));
      const amount = changeSpans[0]?.innerText || "0";
      const percent = changeSpans[1]?.innerText || "0%";
      
      const isUp = changeSpans[0]?.closest('.C\\(\\$c-trend-up\\)') !== null;
      const isDown = changeSpans[0]?.closest('.C\\(\\$c-trend-down\\)') !== null;
      
      // 移除百分比的括號
      const cleanPercent = percent.replace(/[()]/g, '');
      
      return { 
        price, 
        change: (isDown ? "-" : (isUp ? "+" : "")) + amount, 
        percent: cleanPercent 
      };
    });

    if (txData.price) {
      results.push({
        name: "台指期現貨",
        symbol: "WTX00",
        price: txData.price,
        change: txData.change,
        change_percent: txData.percent,
      });
    }
  } catch (error) {
    console.error("台指期現貨抓取錯誤:", error.message);
  } finally {
    if (browser) await browser.close();
  }

  return results;
}

module.exports = { fetchStockData };
