# News Sources & Extraction Strategies

## Tier 1: 可靠 RSS / API（优先）

### Hacker News
```bash
# 获取 top 15 ID
curl -s "https://hacker-news.firebaseio.com/v0/topstories.json" | jq '.[0:15]'
# 获取单条
curl -s "https://hacker-news.firebaseio.com/v0/item/${id}.json" | jq '{title, url, score, descendants}'
```

### Google News RSS
```bash
QUERY="nvidia+AI+chip+2026"
curl -s "https://news.google.com/rss/search?q=${QUERY}&hl=en-US&gl=US&ceid=US:en"
```
常用搜索词：`nvidia AI chip`, `Meta AI llama`, `DeepSeek China AI`, `Anthropic Claude`, `OpenAI GPT`, `Tesla Optimus robot`, `xAI Grok`

### ArXiv (cs.AI / cs.CL)
```bash
curl -s "http://export.arxiv.org/api/query?search_query=cat:cs.AI&sortBy=submittedDate&max_results=5"
```

## Tier 2: 直接 HTML 抓取（降级）

### Ars Technica AI
```bash
curl -s "https://arstechnica.com/ai/" | grep -oP '<h2[^>]*><a[^>]*>[^<]+</a></h2>' | sed 's/<[^>]*>//g' | head -10
```

### TechCrunch
```bash
# 用 JSON-LD 提取 Article body
curl -s "$URL" | python3 -c "
import sys,re,json
t=sys.stdin.read()
m=re.search(r'<script type=\"application/ld\+json\">(.*?)</script>', t, re.DOTALL)
if m:
    d=json.loads(m.group(1))
    body = d.get('articleBody','') if isinstance(d,dict) else d[0].get('articleBody','')
    print(body[:2000])
"
```

## Tier 3: 社区信号（补充）

### Reddit r/MachineLearning
```bash
curl -s -H "User-Agent: HermesAgent/1.0" "https://www.reddit.com/r/MachineLearning/hot.json?limit=10" | jq '.data.children[].data | {title, url, score, num_comments}'
```
注意：Reddit 可能封禁无 cookie 请求，此为尽力而为。

## 并行抓取模板

一条命令并行抓取所有源（30-60s 完成）：

```bash
# 并行启动所有抓取任务
curl -s "https://hacker-news.firebaseio.com/v0/topstories.json" | jq '.[0:15]' > /tmp/hn_ids.json &
curl -s "https://news.google.com/rss/search?q=AI+artificial+intelligence+2026&hl=en-US&gl=US&ceid=US:en" > /tmp/google_ai.xml &
curl -s "https://news.google.com/rss/search?q=Nvidia+chip+2026&hl=en-US&gl=US&ceid=US:en" > /tmp/google_nvda.xml &
curl -s "https://arstechnica.com/ai/" | grep -oP '<h2[^>]*><a[^>]*>[^<]+</a></h2>' | sed 's/<[^>]*>//g' > /tmp/ars_ai.txt &
wait
echo "All sources fetched"
```
