# Cron Job 故障排查指南

适用所有 Hermes cron job 的排障流程。

## 1. 快速定位失败原因

```bash
# 查看 jobs.json 中的 last_error
python3 -c "
import json
j = json.load(open('$HOME/.hermes/cron/jobs.json'))
for job in j['jobs']:
    if job['last_status'] != 'ok':
        print(f\"Job: {job['name']} ({job['id']})\")
        print(f\"  Status: {job['last_status']}\")
        print(f\"  Error:  {job.get('last_error', 'N/A')}\")
        print(f\"  Run:    {job['last_run_at']}\")
        print()
"
```

## 2. 排查步骤（按优先级）

### 2.1 查会话文件
失败的 cron run 会话保存在 `~/.hermes/sessions/session_cron_{id}_*.json`：
```bash
ls -lt ~/.hermes/sessions/session_cron_{job_id}_*
```

查看最后几条消息确认卡在哪里：
```bash
python3 -c "
import json
with open('session_cron_{id}_20260507_080137.json') as f:
    session = json.load(f)
msgs = session.get('messages', [])
print(f'Total messages: {len(msgs)}')
last = msgs[-1]
print(f'Last role: {last[\"role\"]}')
if last['role'] == 'assistant':
    print(f'Reasoning: {str(last.get(\"reasoning\",\"\"))[:300]}')
    print(f'Content:   {str(last.get(\"content\",\"\"))[:300]}')
"
```

### 2.2 查输出文件
成功的 run 会保存 Markdown 输出：`~/.hermes/cron/output/{job_id}/{timestamp}.md`
失败的 run 输出文件包含 `(FAILED)` 标记和错误详情。

### 2.3 监控运行中任务
```bash
# 持续监控会话文件大小看是否仍在增长
watch -n 5 "stat -f '%z bytes %Sm' ~/.hermes/sessions/session_cron_{id}_*"
```

### 2.4 查系统错误日志
```bash
grep "{timestamp}" ~/.hermes/logs/errors.log
grep "{timestamp}" ~/.hermes/logs/gateway.error.log
```

## 3. 常见失败模式

### DeepSeek V4 Pro reasoning 超时
- **症状**：会话文件大小停止增长，最后一条是 assistant 消息（无 tool_call），持续 >5 分钟无更新
- **错误**：`TimeoutError: idle for XXXs (limit 600s) — last activity: terminal command running (Xs elapsed)`
- **根因**：DeepSeek V4 Pro 的 reasoning 模式在长任务中生成推理时 API 无响应
- **修复**：将 cron job model 切换为 Claude Sonnet 4 或其他非 reasoning 模型
  ```bash
  # 在对话中执行
  帮我把定时任务 {job_id} 的模型换成 anthropic/claude-sonnet-4-20250514，provider 用 openrouter
  ```

### 模型切换注意
- 切换模型只影响**新触发的 run**，已在运行的 run 继续用原模型
- 如果当前 run 卡住，需要等待它超时（600s idle limit），新 run 才会接管

### 手动触发 vs 自动调度
- 手动 `cronjob run` 和 cron 定时触发共享同一个槽位
- 如果已有 run 在进行中，新的触发会排队等待

## 4. 预防措施

1. **长任务用非 reasoning 模型**：DeepSeek V4 Pro / o1 等 reasoning 模型适合单轮深度推理，多轮工具调用任务用 Claude Sonnet / GPT-4o 等标准模型
2. **挂载相关 skill**：减少模型探索浪费，聚焦执行
3. **拆分超大任务**：将"搜集 + 整理 + 输出"拆成多个小型 cron job，每个 run <5 分钟
