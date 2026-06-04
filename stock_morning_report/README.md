# 每日晨報 Android APP

啟動即查詢，即時顯示股市行情與財經新聞。

## 功能

- 道瓊、S&P 500、NASDAQ、費城半導體、台積電 ADR、台指期 即時報價
- 美股盤後回顧 / 台股盤前重點 / 國內外政經 / AI 產業趨勢 四類新聞
- 英文新聞自動翻譯為繁體中文
- 點擊新聞開啟瀏覽器
- 下拉重新整理

## 環境需求

- Flutter SDK 3.x（https://docs.flutter.dev/get-started/install/windows/mobile）
- Android Studio 或 VS Code + Flutter Extension
- Android 模擬器或實體裝置（Android 5.0+ / API 21+）

## 執行步驟

```bash
cd stock_morning_report

# 安裝依賴
flutter pub get

# 執行（確保模擬器已啟動）
flutter run

# 建置 APK
flutter build apk --release
```

## 專案結構

```
lib/
├── main.dart                    # 入口
├── app.dart                     # MaterialApp + 主題
├── core/constants/              # API 端點、色彩常數
├── core/utils/                  # 數字格式化工具
├── data/datasources/            # Yahoo Finance API、RSS、翻譯
├── data/models/                 # JSON/XML 反序列化模型
├── data/repositories/           # Repository 實作
├── domain/entities/             # 純資料物件 (Stock, NewsItem)
└── presentation/
    ├── providers/               # Riverpod providers
    ├── screens/home_screen.dart # 主畫面
    └── widgets/                 # UI 元件
```
