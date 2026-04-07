---
name: anything-to-notebooklm-multitool-zh-tw
description: 將網頁、微信文章、YouTube、PDF、Office、Markdown、圖片、音訊與搜尋結果整理後匯入 NotebookLM，並依需求產出 Podcast、簡報、心智圖、測驗、報告等成果。此版本針對 Codex、Gemini CLI、OpenCode CLI、Antigravity 等多種代理式開發工具重新設計。
user-invocable: true
homepage: https://github.com/joeseesun/anything-to-notebooklm
version: 2.0.0
language: zh-TW
---

# Anything to NotebookLM 多工具版 Skill

將多來源內容轉成 NotebookLM 可處理的來源，並進一步產出音訊、簡報、心智圖、測驗、報告等成果。

本版不是綁定單一代理或單一平台，而是以「能力導向」設計，可在下列工具中實作：

- Codex
- Gemini CLI
- OpenCode CLI
- Antigravity
- 其他具備 Shell、檔案系統、網頁抓取、MCP 或外部 CLI 能力的代理工具

## 一、改寫目標

原始版本可用，但有幾個明顯限制：

1. 過度綁定單一執行環境
- 原文大量假設執行環境是 Claude Code。
- MCP 設定、路徑、操作說明都偏向單一工具，不利於移植。

2. 實作耦合高於流程抽象
- 原文把「特定工具怎麼做」寫得很多，但「代理在不同工具下應遵守的決策流程」不夠清楚。
- 若換成 Codex、Gemini CLI 或 OpenCode CLI，代理需要自行重建流程。

3. 缺少跨工具 fallback 策略
- 原文對於無法使用 MCP、無法直接抓微信、無法 OCR、無法轉錄時，缺少一致的降級處理。

4. 指令映射偏 NotebookLM 專屬，代理推理規則不夠完整
- 有列出部分自然語言到 NotebookLM 指令的映射。
- 但沒有清楚規定代理如何拆解來源、如何命名輸出、何時詢問使用者、何時直接執行。

因此，本版改寫的核心是：

- 將工具依賴改成能力依賴
- 將流程寫成代理可執行的決策規格
- 保留 NotebookLM 為目標系統，但不把 Skill 綁死在單一代理
- 全面改為繁體中文

## 二、適用能力模型

代理在使用本 Skill 時，優先判斷自己是否具備以下能力：

1. 內容取得能力
- 可讀取本機檔案
- 可抓取公開網址
- 可呼叫 MCP 或外部抓取工具
- 可執行搜尋

2. 內容轉換能力
- 可將 PDF、DOCX、PPTX、XLSX、EPUB、圖片、音訊轉成文字或 Markdown
- 可進行 OCR 或語音轉文字

3. NotebookLM 操作能力
- 可執行 `notebooklm` CLI
- 或可透過瀏覽器/自動化方式操作 NotebookLM
- 或可將整理後內容交回使用者，由使用者手動匯入

4. 輸出管理能力
- 可建立暫存檔
- 可命名輸出檔
- 可回報輸出位置

若缺少其中某項能力，代理必須採用降級策略，而不是直接失敗。

## 三、支援的輸入來源

### 1. 微信公眾號文章
- `https://mp.weixin.qq.com/...`
- 優先使用專用 MCP 或抓取器
- 若無法抓取，要求使用者貼上內文或提供可讀副本

### 2. 一般網頁
- 新聞、部落格、文件、知識庫頁面
- 優先保留標題、作者、時間、正文、來源網址

### 3. YouTube 影片
- 優先取得字幕、標題、描述、時間長度
- 若字幕不可得，標示限制並視能力決定是否轉錄音訊

### 4. 本機文件
- PDF
- DOCX
- PPTX
- XLSX
- EPUB
- Markdown
- TXT

### 5. 圖片與掃描件
- JPG
- PNG
- WebP
- GIF
- 掃描 PDF

### 6. 音訊
- MP3
- WAV
- M4A
- 其他可轉錄格式

### 7. 結構化資料
- CSV
- JSON
- XML

### 8. 壓縮檔
- ZIP
- 解壓後遞迴處理支援格式

### 9. 搜尋查詢
- 關鍵字
- 主題詞
- 問題句

### 10. 混合來源
- 多個網址
- 多個檔案
- 網址加檔案混合

## 四、代理執行原則

### 原則 1：先辨識來源，再決定工具

不要先假設要用哪個 CLI 或哪個 MCP。先判斷輸入是：

- URL
- 本機路徑
- 純文字
- 關鍵字搜尋
- 混合輸入

再選擇最合適的處理路徑。

### 原則 2：先抽文字，再送 NotebookLM

對於 NotebookLM 而言，穩定可讀的文字來源通常比原始二進位格式更可靠。除非代理確認某格式可直接上傳且效果更好，否則優先流程是：

1. 取得內容
2. 轉成乾淨文字或 Markdown
3. 補上中繼資料
4. 輸出成可上傳檔案
5. 匯入 NotebookLM

### 原則 3：保留來源脈絡

每份輸出都應盡量保留：

- 標題
- 來源網址或來源檔名
- 作者或發布者
- 發布時間
- 擷取時間
- 內容型別

### 原則 4：先確認使用者意圖

若使用者只說「上傳到 NotebookLM」，只做匯入。

若使用者明確要求產出，才做後續生成，例如：

- Podcast
- 簡報
- 心智圖
- 測驗
- 報告
- 摘要

### 原則 5：能力不足時使用降級流程

例如：

- 抓不到微信文章時，改請使用者貼內容
- 做不了 OCR 時，明確說明目前無法抽出圖片文字
- 沒有 NotebookLM CLI 時，先整理成可匯入檔案交付使用者

## 五、自然語言意圖映射

| 使用者說法 | 標準意圖 | 建議操作 |
|---|---|---|
| 生成 Podcast / 做成音頻 / 轉成語音 | audio | 產生音訊或請 NotebookLM 生成 Audio Overview |
| 做成 PPT / 生成簡報 / 做投影片 | slide-deck | 產生簡報或簡報草稿 |
| 畫心智圖 / 生成腦圖 | mind-map | 產生心智圖 |
| 幫我出題 / 生成 Quiz / 測驗 | quiz | 產生測驗題 |
| 做成報告 / 寫摘要 / 整理成文件 | report | 產生報告或摘要 |
| 幫我整理重點 | summary | 產生摘要 |
| 只上傳到 NotebookLM | upload-only | 僅匯入來源 |

若一句話有多個意圖，例如「做成 Podcast 和簡報」，可序列執行，但要先確認使用者是否接受較長處理時間。

## 六、標準工作流程

### Step 1：解析輸入

代理需識別下列類型：

- 微信連結
- 一般網頁連結
- YouTube 連結
- 本機檔案
- 搜尋關鍵字
- 純文字內容
- 多來源混合

### Step 2：取得原始內容

依序採用下列策略：

1. 專用抓取工具或 MCP
2. 通用網頁抓取
3. 本機檔案讀取
4. OCR 或語音轉文字
5. 搜尋後彙整
6. 無法取得時請使用者補充內容

### Step 3：正規化內容

將內容整理成單一可讀格式，建議為 Markdown 或純文字，內容模板如下：

```markdown
# {標題}

- 來源類型：{source_type}
- 原始來源：{source_reference}
- 作者：{author_or_unknown}
- 發布時間：{published_at_or_unknown}
- 擷取時間：{captured_at}

## 內容

{clean_content}
```

### Step 4：命名輸出檔

建議命名規則：

```text
{slug}_{YYYYMMDD_HHMMSS}.md
{slug}_{YYYYMMDD_HHMMSS}.txt
```

若是多來源合併：

```text
multi_source_{topic}_{YYYYMMDD_HHMMSS}.md
```

### Step 5：匯入 NotebookLM

若具備 CLI 能力，可執行等價流程：

```bash
notebooklm create "{notebook_title}"
notebooklm source add "{normalized_file}" --wait
```

注意：

- 匯入後若系統需要索引時間，必須等待完成
- 多來源情境下，應逐一加入來源並確認成功

### Step 6：依意圖產生成果

若使用者要求生成內容，才進一步執行：

- audio
- slide-deck
- mind-map
- quiz
- report
- summary

代理不應把某一個 CLI 語法寫死；應改成「呼叫目前環境中可用的 NotebookLM 介面」。

### Step 7：交付結果

回覆至少應包含：

- 已處理的來源清單
- 已建立的 Notebook 或草稿名稱
- 生成成果種類
- 產出檔案位置
- 若有失敗項目，明確列出

## 七、跨工具落地建議

### Codex
- 適合用 Shell、檔案操作、程式化轉檔
- 可將流程拆為：抓取、轉換、匯入、下載成果

### Gemini CLI
- 適合搭配本機命令與 Google 生態
- 若已能操作 NotebookLM 或相關自動化，優先沿用現有 CLI

### OpenCode CLI
- 適合以 workflow 型式串接多個命令與檔案步驟
- 建議將來源抽取與整理做成中間檔

### Antigravity
- 適合當成高階代理調度器
- 建議把抓取、轉換、NotebookLM 操作視為獨立階段

### 通用原則
- 不把設定檔路徑寫死
- 不把 `~/.claude/...` 這類單一工具專用路徑寫進核心流程
- 將專用能力標註為「可選模組」

## 八、可選模組

### 模組 A：微信讀取器

用途：
- 穩定抓取微信公眾號文章

可接受的實作：
- MCP server
- Playwright 腳本
- 專用解析器

若不可用：
- 請使用者貼全文
- 或請使用者提供可公開瀏覽副本

### 模組 B：文件轉換器

用途：
- 將 PDF、DOCX、PPTX、EPUB、圖片、音訊轉為文字

可接受的實作：
- `markitdown`
- `pandoc`
- OCR 工具
- 語音轉錄工具
- 自建解析腳本

### 模組 C：搜尋彙整器

用途：
- 對主題進行搜尋並整理多來源摘要

最低要求：
- 至少整理 3 筆來源
- 每筆來源保留標題與網址
- 明確區分事實與推測

## 九、失敗與降級處理

### 1. 來源無法存取

回應原則：
- 說明無法存取的來源
- 說明可能原因
- 提供下一步方案

範例：

```text
無法擷取這個來源：可能是權限限制、內容已移除，或目前環境無法完成抓取。
你可以改貼全文、提供 PDF，或給我可公開存取的備用連結。
```

### 2. 無法轉換文字

```text
目前可取得檔案，但無法在這個環境中完成文字抽取。
我可以先保留原始檔，或改用其他轉檔工具後再繼續。
```

### 3. 無法直接操作 NotebookLM

```text
目前環境無法直接呼叫 NotebookLM。
我已經先把內容整理成可匯入的 Markdown / TXT 檔，你可以手動上傳，或提供可用的 NotebookLM CLI / 自動化方式後我再接續處理。
```

### 4. 生成失敗

```text
來源已匯入，但生成成果失敗。
可能原因包括來源內容過短、平台端處理異常，或目前配額限制。
可改為先輸出摘要或報告，再決定是否重試其他格式。
```

## 十、輸出規格

### 匯入前的中間檔
- `.md` 優先
- `.txt` 次選

### 生成後成果
- 音訊：`.mp3` 或平台實際格式
- 簡報：`.pdf`、`.pptx` 或平台實際格式
- 心智圖：`.json`、`.png`、`.svg`
- 測驗：`.md`、`.txt`
- 報告：`.md`、`.pdf`

### 回報格式

建議代理最終回報：

```text
處理完成。

來源：
1. {source_1}
2. {source_2}

整理檔：
- {normalized_file}

Notebook：
- {notebook_title_or_status}

產出：
- {artifact_type}: {artifact_path_or_status}
```

## 十一、使用範例

### 範例 1：網頁轉報告

```text
把這篇文章整理後上傳到 NotebookLM，然後生成一份報告：
https://example.com/article
```

### 範例 2：YouTube 轉心智圖

```text
把這支 YouTube 影片做成心智圖：
https://www.youtube.com/watch?v=xxxx
```

### 範例 3：PDF 轉 Podcast

```text
把這份 PDF 上傳到 NotebookLM，並生成 Podcast：
/path/to/file.pdf
```

### 範例 4：搜尋主題後做摘要

```text
搜尋「AI Agent 開發框架 2026」，整理 5 個來源，匯入 NotebookLM，最後幫我做摘要。
```

### 範例 5：多來源整合成簡報

```text
把這 3 份資料整合後做成簡報：
- https://example.com/post-1
- https://www.youtube.com/watch?v=xxxx
- /path/to/research.pdf
```

## 十二、代理提示模板

以下模板可直接給代理系統使用。

### 系統提示模板

```text
你是一個多來源內容整理代理。你的目標是把網址、檔案、搜尋結果或使用者貼上的內容，整理為 NotebookLM 可匯入的來源，並在使用者要求時產出音訊、簡報、心智圖、測驗或報告。

執行時請遵守：
1. 先辨識輸入來源類型。
2. 優先抽取乾淨文字，再做匯入。
3. 保留標題、來源、作者、時間等中繼資料。
4. 若環境缺乏特定能力，採用降級流程，不要憑空捏造結果。
5. 若使用者未要求生成內容，僅完成匯入或整理。
6. 對多來源輸入，先做結構化整理，再匯入。
7. 輸出時回報處理狀態、檔案位置與失敗項目。
```

### 使用者提示模板

```text
請用 anything-to-notebooklm 多工具流程處理以下來源：
{sources}

目標：
{upload_only_or_artifact_goal}

偏好：
{style_or_constraints}
```

## 十三、實作注意事項

1. 不要把單一平台設定寫死進 Skill 主流程。
2. 不要假設一定有 MCP。
3. 不要假設一定能連網。
4. 不要假設所有文件都能完美轉換。
5. 不要在未成功取得內容前宣稱已完成匯入或生成。
6. 若涉及版權或封閉內容，優先要求使用者提供授權或合法副本。

## 十四、建議的目錄與檔名策略

若代理可控制工作目錄，建議建立：

```text
tmp/notebooklm_sources/
tmp/notebooklm_outputs/
```

建議檔名：

```text
tmp/notebooklm_sources/{slug}_{timestamp}.md
tmp/notebooklm_outputs/{slug}_{artifact_type}_{timestamp}.{ext}
```

## 十五、總結

這份 Skill 的核心不是某個特定 CLI 指令，而是一套穩定的代理工作流：

1. 辨識來源
2. 取得內容
3. 正規化文字
4. 匯入 NotebookLM
5. 依意圖產生結果
6. 回報輸出與限制

只要執行工具具備對應能力，Codex、Gemini CLI、OpenCode CLI、Antigravity 都能實作這份 Skill。
