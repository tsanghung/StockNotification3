const { chromium } = require("playwright");
const fs = require("fs");

async function deepDebug() {
  const browser = await chromium.launch({ headless: true });
  // 使用真實瀏覽器的 User-Agent
  const context = await browser.newContext({
    userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
  });
  const page = await context.newPage();
  
  const symbols = ["^DJI", "TSM"];
  for (const symbol of symbols) {
    console.log(`正在深入偵錯 ${symbol}...`);
    try {
      await page.goto(`https://finance.yahoo.com/quote/${symbol}`, { waitUntil: "networkidle", timeout: 45000 });
      await page.waitForTimeout(5000); // 等待 JS 渲染
      
      await page.screenshot({ path: `debug_${symbol.replace('^', '')}.png` });
      const html = await page.content();
      fs.writeFileSync(`debug_${symbol.replace('^', '')}.html`, html);
      
      const price = await page.evaluate((s) => {
        // 嘗試多種可能的選擇器
        const selectors = [
          `fin-streamer[data-symbol="${s}"][data-field="regularMarketPrice"]`,
          'fin-streamer[data-field="regularMarketPrice"]',
          '.priceText',
          '[data-test="qsp-price"]'
        ];
        for (const sel of selectors) {
          const el = document.querySelector(sel);
          if (el && el.innerText.trim()) return { selector: sel, value: el.innerText.trim() };
        }
        return null;
      }, symbol);
      
      console.log(`${symbol} 結果:`, price);
    } catch (e) {
      console.error(`${symbol} 偵錯出錯:`, e.message);
    }
  }
  
  await browser.close();
}

deepDebug();
