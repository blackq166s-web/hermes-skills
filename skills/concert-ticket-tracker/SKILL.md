---
name: concert-ticket-tracker
description: "Use when tracking concert/tour announcements and ticket sale dates for specific artists. Monitors official ticketing platforms, tour tracking sites, and social channels for presale and on-sale alerts."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [concert, ticket, monitoring, entertainment]
---

# Concert Ticket Tracker

## Overview

监控指定艺人的巡演公告、开票时间、预售信息，帮你在第一时间抢到票。

## When to Use

- 你想抢某个艺人的演唱会门票
- 需要每天自动检查是否有新场次/开票信息
- 多个艺人同时关注

## 监控来源

### 海外艺人

| 来源 | 网址 | 说明 |
|------|------|------|
| Ticketmaster | ticketmaster.com | 北美/欧洲主力售票 |
| Live Nation | livenation.com | 大型巡演主办 |
| Songkick | songkick.com | 巡演追踪 |
| Bandsintown | bandsintown.com | 演出提醒 |
| Reddit | reddit.com/r/{artist} | 粉丝社群一手消息 |
| Artist Official | 艺人官网/X(Twitter)/IG | 官方首发 |

### 国内平台

| 来源 | 网址 | 说明 |
|------|------|------|
| 大麦网 | damai.cn | 国内最大票务 |
| 猫眼 | maoyan.com | 综合票务 |
| 秀动 | showstart.com | 独立音乐/Livehouse |

## 监控逻辑

每天检查：

1. **巡演公告** — 搜索艺人名 + "tour 2026" / "巡演 2026"，看是否有新公告
2. **开票状态** — 在大麦/Ticketmaster 上检查艺人页面，确认是否有预售/开票倒计时
3. **预售码** — 关注粉丝社群和官方邮件列表的预售码发放
4. **场次变化** — 是否有新增城市/日期
5. **价格信息** — 票档和价格是否公布

## 输出格式

```
🎫 演唱会抢票日报 YYYY-MM-DD

## The Weeknd
- 巡演状态：有/无更新
- 最新公告：...
- 开票信息：...
- 建议动作：...

## Kanye West (Ye)
- 巡演状态：有/无更新
- 最新公告：...
- 开票信息：...
- 建议动作：...

## 本周重点关注
...
```

无更新时标注「今日无新消息，持续监控中」。

## Setup

向 Hermes 发送：

```
帮我创建一个每天 18:00 运行的定时任务，监控 The Weeknd 和 Kanye West 的演唱会信息。

监控来源：
- 海外：Ticketmaster、Live Nation、Songkick、Bandsintown、Reddit、艺人官网
- 国内：大麦网、猫眼

每天检查：
1. 是否有新巡演公告
2. 是否有开票/预售信息
3. 预售码发放
4. 新增城市或日期
5. 票档和价格信息

输出简报，无更新时标注「今日无新消息」。
```
