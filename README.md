# anything-to-notebooklm

A multi-tool NotebookLM skill for Codex, Gemini CLI, OpenCode CLI, Antigravity, and similar agentic developer tools.

這是一份可跨工具使用的 NotebookLM skill，針對 Codex、Gemini CLI、OpenCode CLI、Antigravity 等代理式開發工具重新整理，目的是把多來源內容整理後匯入 NotebookLM，並依需求產出 Podcast、簡報、心智圖、測驗、報告等成果。

## Overview / 簡介

This repository contains a rewritten `SKILL.md` adapted from the original `anything-to-notebooklm` concept, but redesigned to be:

- tool-agnostic
- workflow-oriented
- fallback-friendly
- suitable for multiple CLI agents

本 repo 內的 `SKILL.md` 並非只綁定單一平台，而是改成：

- 以能力導向而非平台導向設計
- 以代理工作流程為核心
- 具備降級與 fallback 策略
- 適合多種 CLI / agent 工具共用

## Included / 內容

- `SKILL.md`: Traditional Chinese multitool skill
- `README.md`: Bilingual Traditional Chinese + English overview

## What This Skill Does / 這份 Skill 能做什麼

It helps an agent handle:

- web pages
- WeChat public articles
- YouTube videos
- PDF / DOCX / PPTX / XLSX / EPUB
- Markdown / text files
- images with OCR
- audio transcription
- search-result aggregation
- mixed multi-source ingestion

它可協助代理處理：

- 網頁
- 微信公眾號文章
- YouTube 影片
- PDF / DOCX / PPTX / XLSX / EPUB
- Markdown / 純文字
- 圖片 OCR
- 音訊轉文字
- 搜尋結果彙整
- 多來源混合匯入

## Design Principles / 設計原則

The rewritten skill focuses on a stable execution flow:

1. detect source type
2. acquire content
3. normalize to clean text or Markdown
4. import into NotebookLM
5. generate requested artifacts
6. report outputs and limitations

改寫後的核心流程是：

1. 辨識來源
2. 取得內容
3. 正規化成乾淨文字或 Markdown
4. 匯入 NotebookLM
5. 依需求產生成果
6. 回報輸出與限制

## Why This Rewrite / 為什麼要重寫

The original version was useful, but heavily coupled to a single environment and specific MCP assumptions.
This version removes hard-coded platform assumptions and reframes the skill as a portable workflow spec.

原始版本可用，但與單一執行環境及特定 MCP 設定綁得太深。
本版本將它改寫為可攜式 workflow spec，便於在不同代理工具中落地。

## Usage / 使用方式

Open `SKILL.md` and adapt it into your agent system, CLI workflow, or prompt framework.
If your environment can directly control NotebookLM, use the skill end-to-end.
If not, use the normalization steps first and hand off the generated Markdown/TXT files for manual upload.

你可以直接把 `SKILL.md` 納入自己的代理系統、CLI 工作流或 prompt framework。
若當前環境能直接操作 NotebookLM，可完整執行整套流程。
若無法直接操作，也可以先用 skill 完成內容整理，再手動上傳整理好的 Markdown / TXT 檔案。

## Source / 來源

Original inspiration:
- https://github.com/joeseesun/anything-to-notebooklm

This repository contains a rewritten and localized Traditional Chinese multitool version.

本 repo 收錄的是重新分析、改寫並繁體中文化後的多工具版本。
