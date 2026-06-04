const axios = require("axios");
const xml2js = require("xml2js");
const translate = require("google-translate-api-next");
const { chromium } = require("playwright");

/**
 * 抓取新聞並翻譯
 * 來源：RSS (Yahoo Finance, Google News) + Scraper (Yahoo Finance TW)
 */
async function fetchAndTranslateNews() {
  const rssFeeds = [
    { name: "國際政經", url: "https://finance.yahoo.com/news/rssindex", category: "Politics_Economy", lang: "en" },
    { name: "AI 趨勢", url: "https://news.google.com/rss/search?q=AI&hl=en-US&gl=US&ceid=US:en", category: "AI_Trends", lang: "en" },
  ];

  const results = [];
  const parser = new xml2js.Parser();

  // 1. 抓取 RSS 源
  for (const feed of rssFeeds) {
    console.log(`正在抓取 RSS ${feed.name} 源...`);
    try {
      const response = await axios.get(feed.url, { timeout: 10000 });
      const xml = response.data;
      const parsed = await parser.parseStringPromise(xml);
      const items = parsed.rss.channel[0].item.slice(0, 8);
      
      for (const item of items) {
        const title = item.title[0];
        const link = item.link[0];
        const pubDate = item.pubDate ? item.pubDate[0] : "";
        
        let translatedTitle = title;
        if (feed.lang === "en") {
          try {
            const res = await translate(title, { to: "zh-TW" });
            translatedTitle = res.text;
          } catch (trError) {
            console.warn(`翻譯失敗: ${title}`);
          }
        }

        results.push({
          title: translatedTitle,
          source_url: link,
          category: feed.category,
          publish_time: pubDate,
          lang: feed.lang
        });
      }
    } catch (error) {
      console.error(`RSS 抓取 ${feed.name} 失敗:`, error.message);
    }
  }

  // 2. 抓取 Yahoo 奇摩股市 (台股盤勢與美股新聞)
  console.log("正在抓取 Yahoo 奇摩股市 (盤後/盤前) 目標新聞...");
  let browser;
  try {
    browser = await chromium.launch({ headless: true });
    const page = await browser.newPage();
    
    const targets = [
      { name: "台股盤勢", url: "https://tw.stock.yahoo.com/tw-market/", category: "TW_Market_Pre", keywords: ["台股", "盤前", "重點", "法人"], excludeKeywords: [] },
      { name: "美股新聞", url: "https://tw.stock.yahoo.com/us-market-news", category: "US_Market_Recap", keywords: ["美股", "盤後", "收盤", "終場"], excludeKeywords: ["台股盤前", "台股週報"] }
    ];

    for (const target of targets) {
      console.log(`正在掃描 ${target.name}...`);
      await page.goto(target.url, { waitUntil: 'domcontentloaded', timeout: 30000 });
      await page.waitForSelector('a.mega-item-header-link', { timeout: 10000 });

      const articles = await page.evaluate((target) => {
        const links = Array.from(document.querySelectorAll('a.mega-item-header-link'));
        return links.map(a => ({
          title: a.innerText.trim(),
          source_url: a.href,
          publish_time: new Date().toISOString() // 抓取時的時間
        })).filter(art => {
          const hasKeyword = target.keywords.some(k => art.title.includes(k));
          const hasExclude = target.excludeKeywords && target.excludeKeywords.length > 0 && target.excludeKeywords.some(k => art.title.includes(k));
          return hasKeyword && !hasExclude;
        });
      }, target);

      // 每個類別取前 5 則最相關的
      articles.slice(0, 5).forEach(art => {
        results.push({
          ...art,
          category: target.category,
          lang: "zh"
        });
      });
    }
  } catch (error) {
    console.error("Yahoo 奇摩股市抓取失敗:", error.message);
  } finally {
    if (browser) await browser.close();
  }

  return results;
}

module.exports = { fetchAndTranslateNews };
