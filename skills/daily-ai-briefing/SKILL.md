---
name: daily-ai-briefing
description: "Use when setting up a daily AI/tech/investment briefing that auto-delivers to Feishu and Notion. Covers cron job creation, Notion API integration, and output formatting."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [cron, notion, feishu, briefing, news, productivity]
---

# Daily AI Briefing → Feishu + Notion

## Overview

每天自动筛选 AI / 大模型 / Agent / 具身智能 / 硬件的关键信息，生成精炼简报，
推送到飞书并写入 Notion 数据库。

核心设计理念：**宁缺毋滥** —— 无高价值信息时输出「今日无必须关注信息」，
不凑数量、不推噪音、不做情绪判断。

## When to Use

- 你或朋友需要一个「每天早上看一眼就知道行业在发生什么」的信息筛选系统
- 需要简报同时推送到飞书聊天 + 归档到 Notion
- 想定制关注领域、筛选标准或人群

## Prerequisites

### 1. Notion 集成

1. 前往 https://notion.so/my-integrations → 新建集成，复制 API Key（`ntn_` 开头）
2. 将 API Key 配置为环境变量 `NOTION_API_KEY`
3. 在 Notion 中创建目标页面（例如「总盘 → 0日程 → 每日简报」）
4. 将该页面分享给集成：右上角 `…` → 连接 → 选择你的集成

### 2. 获取 Notion 页面 ID

向 Hermes 发送：
> 用 search_files 或 terminal 搜索我的 Notion 中名为「每日简报」的页面，返回页面 ID

或者手动用 curl（确保 NOTION_API_KEY 已配置）：

```bash
curl -s -X POST "https://api.notion.com/v1/search" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"query":"每日简报","page_size":5}' | jq '.results[0].id'
```

记下返回的页面 ID（格式：`35867d14-6818-802b-abee-c0e78671c6b5`）。

## Setup: 创建定时任务

向 Hermes 发送以下指令（替换 `{你的Notion页面ID}`）：

```
帮我创建一个每天 08:00 运行的定时任务，做 AI/科技/硬件/投研信息筛选。

关注范围：
- AI/大模型/Agent/AI 编程：OpenAI、Anthropic、DeepSeek、Google、Nvidia、Meta 等
- 具身智能/机器人/硬件：Tesla Optimus、Figure AI、Unitree、芯片、AR/VR
- 科技公司进展：产品发布、财报变化、组织调整、战略转向
- 投研变量：科技股、AI 产业链，只提炼事实不荐股
- 长内容推荐：高信息密度访谈/播客/演讲

筛选原则：宁缺毋滥，不要凑数量。每条必须说清：发生了什么、为什么重要、对我有什么影响、下一步该做什么。
拒绝价值观叙事、宏大叙事、营销号解读。
无高价值信息就输出「今日无必须关注信息」。

输出结构：
- 今日结论（1-3 句）
- 必须关注（最多 3 条）
- AI/Agent/工具更新
- 具身智能/硬件进展
- 投研变量
- 访谈/长内容推荐
- 今日最值得深挖（1-3 条）

同时写入 Notion 页面 {你的Notion页面ID}，使用以下 block 格式：
- 标题：heading_1 📰 AI 科技简报 YYYY-MM-DD
- 今日结论：callout（💡, blue_background）
- 每条新闻：heading_3 → 摘要(callout 💬) → 要点(bulleted_list_item) → 动作(callout 绿/黄/灰) → 来源(quote)
- 模块分隔用 divider
- API: POST /v1/pages, parent page_id, children ≤ 100 blocks
```

Hermes 会自动创建 cron job 并返回 job ID。

## Customization

### 调整推送时间

```
帮我修改定时任务 {job_id} 的推送时间为每天 09:00
```

### 调整关注领域

```
帮我更新定时任务 {job_id}，在关注范围里增加[你的领域]
```

### 手动触发一次

```
帮我手动运行一次定时任务 {job_id}
```

### 暂停 / 恢复

```
暂停定时任务 {job_id}
恢复定时任务 {job_id}
```

## Output Format

### 飞书消息格式（Markdown）

```markdown
【今日 AI / 科技 / 硬件 / 投研简报】
日期：2026-05-06
━━━━━━━━━━━━━━━━━━━━
## 0. 今日结论
━━━━━━━━━━━━━━━━━━━━
用 1-3 句话总结今天最重要的变化。
━━━━━━━━━━━━━━━━━━━━
## 1. 必须关注
━━━━━━━━━━━━━━━━━━━━
### 1. 标题
- **一句话总结：**
- **关键信息：**
- **为什么重要：**
- **对我的影响：**
- **建议动作：** 深挖 / 记录 / 观察 / 忽略
- **来源：**
```

### Notion 格式（结构化 Block）

```
📰 AI 科技简报 YYYY-MM-DD         [heading_1]

💡 AI 行业出现两个并行的结构变化...  [callout, blue]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ [divider]

1️⃣ 必须关注                        [heading_2]

Anthropic 发布 10 个金融 Agent 模板  [heading_3]
💬 覆盖投行研究、KYC 审查等场景...  [callout, gray]
📋 关键信息：10 个 Agent 模板...     [bulleted_list_item]
❗ 为什么重要：首家以行业 Agent...  [bulleted_list_item]
🎯 对我的影响：金融工具链在变化     [bulleted_list_item]
🔍 建议动作：深挖                 [callout, green]
📎 Anthropic 官方博客              [quote]
```

建议动作用色：🔍 深挖 = 绿，👀 观察 = 黄，📝 记录 = 灰。

## Notion API Quick Reference

### 创建子页面

```bash
# 将 NOTION_API_KEY 设为环境变量后执行
curl -s -X POST "https://api.notion.com/v1/pages" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{
    "parent": {"page_id": "你的父页面ID"},
    "properties": {
      "title": {"title": [{"text": {"content": "📰 AI 科技简报 2026-05-07"}}]}
    },
    "children": [
      {"object": "block", "type": "callout", "callout": {
        "rich_text": [{"text": {"content": "今天的结论..."}}],
        "icon": {"emoji": "💡"},
        "color": "blue_background"
      }},
      {"object": "block", "type": "bulleted_list_item", "bulleted_list_item": {
        "rich_text": [
          {"text": {"content": "关键信息："}, "annotations": {"bold": true}},
          {"text": {"content": "具体内容..."}}
        ]
      }}
    ]
  }'
```

### 更新为完整结构（PATCH 追加）

```bash
# 先创建页面（带标题和初始 children），然后追加更多块：
curl -s -X PATCH "https://api.notion.com/v1/blocks/{page_id}/children" \
  -H "Authorization: Bearer $NOTION_API_KEY" \
  -H "Notion-Version: 2025-09-03" \
  -H "Content-Type: application/json" \
  -d '{"children": [...]}'
```

## Common Pitfalls

1. **集成看不到页面** — 必须在 Notion 中把目标页面手动「连接」到集成（右上角 `…` → 连接），不是创建集成就自动可见。

2. **rich_text 超 2000 字符** — Notion 限制每个 text segment 最多 2000 字符。超长段落必须拆成多个 block 或多个 segment。

3. **children 数组超 100 个** — POST 创建页面时 children 最多 100 个 block。超出用 PATCH `/blocks/{id}/children` 追加。

4. **API 版本差异** — 使用 `Notion-Version: 2025-09-03`，该版本中数据库（database）改称 data source，查询端点不同。

5. **飞书 Markdown 限制** — 飞书支持的 Markdown 有限（粗体、斜体、代码块、链接），不支持表格和嵌套列表。

6. **简报变成空壳** — 如果某天确实没有高价值信息，简报会输出「今日无必须关注信息」。这是设计行为，不是 bug。检查来源是否受限（如 web search 工具不可用）。

## Verification Checklist

- [ ] NOTION_API_KEY 已配置为环境变量
- [ ] Notion 目标页面已分享给集成
- [ ] 用 `curl` 验证能搜到目标页面
- [ ] Cron job 已创建且 `next_run_at` 正确
- [ ] 手动 `run` 一次验证简报能正常生成并推送到飞书
- [ ] Notion 页面打开确认 block 格式正确（callout、bullet、quote 分层清晰）
