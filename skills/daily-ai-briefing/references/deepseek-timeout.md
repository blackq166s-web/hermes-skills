# DeepSeek V4 Pro Reasoning 超时问题

## 问题

2026-05-07 08:01，定时任务「AI 科技投研每日简报」在运行 33 分钟后被 cron 强制终止。

## 完整错误

```
TimeoutError: Cron job 'AI 科技投研每日简报' idle for 912s (limit 600s)
— last activity: terminal command running (10s elapsed)
```

## 根因

DeepSeek V4 Pro 的 reasoning 模式在长任务中会 API 卡死。表现为：
- 正常搜集信息阶段（20+ 次工具调用）都成功
- 在整理输出阶段，模型进入长时间 reasoning，API 不再返回任何 token
- 912 秒无活动 → 超过 600s 空闲上限 → 任务被 kill

## 诊断命令

### 查错误原因（cronjob list 不显示具体错误）

```bash
cat ~/.hermes/cron/jobs.json | python3 -c "
import json, sys
jobs = json.load(sys.stdin)['jobs']
for j in jobs:
    if j['last_status'] == 'error':
        print(f\"name: {j['name']}\")
        print(f\"error: {j['last_error']}\")
        print(f\"last_run: {j['last_run_at']}\")
"
```

### 看完整会话记录

```bash
# session 文件名格式: session_cron_{job_id}_{YYYYMMDD_HHMMSS}.json
ls -lt ~/.hermes/sessions/session_cron_09c40acec74b_*.json | head -3
```

### 看输出快照

```bash
ls -lt ~/.hermes/cron/output/09c40acec74b/
```

## 解决方案

### 方案 A：换模型（推荐）

给 cron job 指定非 reasoning 模型：

```
帮我修改定时任务 09c40acec74b，把模型换成 claude-sonnet-4-20250514
```

或者用 GPT-4o 等不支持 reasoning 的模型。

### 方案 B：给 DeepSeek 关 reasoning

如果必须用 DeepSeek，给 cron job 加 `model_args` 关掉 reasoning：

```yaml
# 在 config.yaml 中给该 provider 加
deepseek:
  model_args:
    reasoning: false
```

## 影响范围

- 用户 cron job `09c40acec74b`（AI 科技投研每日简报）
- 任何使用 DeepSeek V4 Pro reasoning 的长时间 cron job 都可能触发
- 短任务（< 5 分钟）不容易触发
