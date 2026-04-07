---
name: anything-to-notebooklm-multitool-zh-tw
description: 萬物皆可 NotebookLM。將網頁、X/Twitter、YouTube、文件、圖片與音訊正規化後匯入 NotebookLM，並驅動產出 Podcast、簡報、心智圖、報告等成果。
user-invocable: true
version: 2.2.0
language: zh-TW
update_url: https://raw.githubusercontent.com/tbdavid2019/anything-to-notebooklm/refs/heads/main/SKILL.md
---

# Anything to NotebookLM: 執行決策手冊 (Agent Executive Manual)

若你是 AI 代理，請嚴格遵守本手冊的決策邏輯。本 Skill 旨在將雜亂來源「標準化」為 NotebookLM 友善格式，並自動化生成產物。

---

## 🛑 第一階段：強制前置檢查 (Pre-flight Check)

**在執行任何來源抓取前，你必須驗證環境：**

1.  **Runtime Check**: 執行 `./check_env.py`。
    *   若環境不完整，優先執行 `./install.sh`。
    *   核心依賴：Python 3.9+, Playwright (Chromium), `notebooklm` CLI。
2.  **Auth Check**: 確認 `notebooklm login` 已完成。
    *   若未登入，引導使用者完成登入流程。
3.  **Strict Rule**: 若環境檢查失敗且無法修復，必須立即告知使用者「目前進入**降級模式**：僅能處理本機檔案與手動貼上的文字，無法自動匯入 NotebookLM」。

---

## 🔍 第二階段：來源辨識與處理決策 (Source Decision Tree)

根據輸入類型選擇處理路徑，最終目標是產出 **「正規化 Markdown/TXT」**：

| 來源類型 (Source) | 處理工具 / 策略 | Fallback 策略 |
| :--- | :--- | :--- |
| **X / Twitter** | 優先使用 `Nitter` (或類鏡像) 抓取公開串文 | 要求使用者貼上內容或提供截圖 OCR |
| **YouTube** | 優先取得「字幕 + 描述」。若無字幕則標示限制 | 使用語音轉錄工具 (若具備) |
| **一般網頁 (URL)** | 使用通用 Web Scraper，保留標題/作者/內文 | 請使用者提供可讀副本或貼上內文 |
| **受限制來源 (如微信)** | 呼叫專用 MCP (如 `wexin-read-mcp`) | 要求使用者提供轉存連結或貼上內容 |
| **文件 (PDF/DOCX/PPTX)** | 使用 `markitdown` 或 `pandoc` 轉為 Markdown | 保留原始檔手動匯入 |
| **圖片 (JPG/PNG)** | 進行 `OCR` 抽取文字 | 請使用者手動描述或提供文字版 |
| **音訊 (MP3/WAV)** | 執行語音轉文字 (Transcribe) | 僅能作為附件匯入 (若支援) |

### 📝 正規化模板 (Normalization Template)
所有非結構化來源應轉換為以下格式：
```markdown
# {標題}
- 原始來源: {source_url_or_filename}
- 擷取時間: {timestamp}
{clean_content}
```

---

## 📤 第三階段：NotebookLM 操作指令 (Ingestion & CLI)

**標準自動化流程 (CLI 模式)：**

1.  **Create**: `notebooklm create "{title}"`
2.  **Add**: `notebooklm source add "{normalized_file}" --wait`
3.  **Status**: 確認 Source 狀態為 `READY` 後再進行下一步。

---

## 🎨 第四階段：意圖映射與產物生成 (Intent & Artifacts)

根據使用者自然語言意圖，執行對應的 `notebooklm generate` 指令：

| 使用者意圖 (Intent) | CLI 指令 (Type) | 產出目標 (Artifact) |
| :--- | :--- | :--- |
| **聽重點 / 做 Podcast** | `audio` | Audio Overview (.mp3) |
| **寫摘要 / 做報告** | `report` | Markdown Report (.md) |
| **做簡報 / 投影片** | `slide-deck` | Presentation Draft |
| **畫心智圖 / 腦圖** | `mind-map` | Logical Graph (JSON/Image) |
| **幫我考試 / 出題** | `quiz` | Quiz / Flashcards |
| **結構化擷取** | `data-table` | Structured Table |

---

## ⚠️ 第五階段：降級與錯誤處理 (Fail-safe)

1.  **來源抓不到**：不要捏造內容。明確列出失敗網址，並要求使用者提供「貼上文字」或「匯出檔」。
2.  **無法操作 CLI**：若 `notebooklm` 指令失效，改為交付「已正規化的 Markdown 檔案」，並引導使用者手動上傳。
3.  **多來源失敗**：若處理 5 個來源中有 2 個失敗，應先處理成功的 3 個，並在最後報告中標註失敗項目。

---

## 🤖 代理系統提示 (System Prompt Snippet)

```text
你是一個多來源內容整理代理。請嚴格遵守 SKILL.md 流程：
1. 執行 ./check_env.py 驗證環境。
2. 解析來源並正規化為 Markdown。
3. 使用 notebooklm CLI 進行匯入與產物生成。
4. 若環境受限，自動切換至「降級模式」並交付整理好的文字檔。
```

---

**更新規則**：除非使用者要求固定版本，否則每次執行前應從 `update_url` 檢查是否有邏輯更新。
