# Usage Display

一个轻量的 Claude Code 状态栏用量显示脚本，用来在终端底部显示当前模型、工作目录、上下文窗口使用率、会话成本，以及 Claude 5 小时 / 7 天用量配额。

项目只保留一个入口：

- `claude_quota.py`：作为 Claude Code `statusLine` 命令使用，读取 Claude Code 传入的会话 JSON，并通过本地 Claude OAuth 凭据查询用量。

## 功能特性

- 零 Python 第三方依赖，只使用 Python 标准库。
- 支持 Claude Code `statusLine` 实时显示。
- 支持按需选择显示内容，例如只显示配额、只显示上下文窗口、显示重置时间等。
- 自动读取 `CLAUDE_CONFIG_DIR`，兼容自定义 Claude 配置目录。
- 使用本地缓存降低接口请求频率，避免状态栏频繁刷新时反复请求。
- 网络失败、接口失败或凭据缺失时会尽量使用缓存，不会中断 Claude Code。
- 终端彩色进度条显示，上下文使用率高于 50% / 80% 时自动变色。

## 文件结构

```text
usage-display/
├── claude_quota.py          # Claude Code statusLine 主脚本
├── CLAUDE.md                # 给 Claude Code / 维护者看的项目说明
├── README.md                # 项目说明文档
└── .gitignore               # Git 忽略规则
```

## 环境要求

需要：

- Python 3.8 或更高版本
- 已登录 Claude Code
- 本地存在 Claude Code OAuth 凭据

脚本默认读取：

```text
~/.claude/.credentials.json
```

如果你设置了 `CLAUDE_CONFIG_DIR`，则会读取：

```text
$CLAUDE_CONFIG_DIR/.credentials.json
```

不需要安装任何第三方 Python 包。

## 快速开始

### 1. 克隆仓库

```bash
git clone https://github.com/<your-name>/usage-display.git
cd usage-display
```

如果你是直接把当前目录上传到 GitHub，可以先初始化仓库：

```bash
git init
git add .
git commit -m "Initial usage display script"
git branch -M main
git remote add origin https://github.com/<your-name>/usage-display.git
git push -u origin main
```

### 2. 本地测试脚本

Claude Code 的 `statusLine` 会把会话 JSON 通过标准输入传给脚本。你可以用下面的模拟数据测试本地字段：

```bash
printf '%s\n' '{"model":{"display_name":"Claude Sonnet"},"workspace":{"current_dir":"/tmp/demo"},"context_window":{"used_percentage":36},"cost":{"total_cost_usd":0.12}}' \
  | python3 claude_quota.py --model --dir --context --cost
```

预期会看到类似输出：

```text
Claude Sonnet | demo | ctx [进度条] 36% | $0.12
```

实际颜色和进度条会根据终端显示能力有所不同。

### 3. 配置 Claude Code 状态栏

打开 Claude Code 设置文件：

```bash
nano ~/.claude/settings.json
```

加入或合并下面的配置：

```json
{
  "statusLine": {
    "command": "python3 /absolute/path/to/usage-display/claude_quota.py"
  }
}
```

把 `/absolute/path/to/usage-display/claude_quota.py` 替换成你机器上的真实绝对路径，例如：

```json
{
  "statusLine": {
    "command": "python3 /home/phi5090ii/NYX/vibe_coding/usage-display/claude_quota.py"
  }
}
```

重新打开 Claude Code 后，状态栏就会开始显示用量信息。

## 用法

基础命令：

```bash
python3 claude_quota.py
```

这个脚本主要设计给 Claude Code `statusLine` 调用。`statusLine` 会把当前会话 JSON 传给脚本，所以模型、目录、上下文窗口、成本等字段才有数据。直接在普通终端运行时没有会话 JSON，通常只会显示能从本地凭据或缓存读取到的配额信息。

不传参数时，默认显示：

- 模型名称
- 当前目录名
- 上下文窗口使用率
- 5 小时用量
- 7 天用量
- 5 小时配额重置时间

默认不会显示会话成本。如果需要显示成本，请显式添加 `--cost`。

## 参数说明

| 参数 | 说明 |
| --- | --- |
| `--model` | 显示当前模型名称 |
| `--dir` | 显示当前工作目录名 |
| `--context` | 显示上下文窗口使用率 |
| `--cost` | 显示当前会话成本 |
| `--quota` | 显示 5 小时和 7 天用量 |
| `--reset` | 显示 5 小时配额重置时间，会自动启用 `--quota` |

## 常用配置

显示默认信息：

```json
{
  "statusLine": {
    "command": "python3 /absolute/path/to/usage-display/claude_quota.py"
  }
}
```

只显示配额和重置时间：

```json
{
  "statusLine": {
    "command": "python3 /absolute/path/to/usage-display/claude_quota.py --quota --reset"
  }
}
```

显示模型、目录、上下文和配额：

```json
{
  "statusLine": {
    "command": "python3 /absolute/path/to/usage-display/claude_quota.py --model --dir --context --quota --reset"
  }
}
```

显示模型、上下文、成本：

```json
{
  "statusLine": {
    "command": "python3 /absolute/path/to/usage-display/claude_quota.py --model --context --cost"
  }
}
```

## 输出字段解释

示例输出：

```text
Claude Sonnet | usage-display | ctx [进度条] 36% | 5h used: 42% | weekly used: 18% | resets 9:30pm
```

含义：

| 字段 | 含义 |
| --- | --- |
| `Claude Sonnet` | 当前 Claude Code 使用的模型显示名 |
| `usage-display` | 当前工作目录的最后一级目录名 |
| `ctx` | context window，上下文窗口 |
| `36%` | 当前上下文窗口已使用比例 |
| `5h used` | 5 小时窗口内的配额使用比例 |
| `weekly used` | 7 天窗口内的配额使用比例 |
| `resets` | 5 小时窗口预计重置时间 |

## 缓存机制

`claude_quota.py` 会把接口返回结果缓存到 Claude 配置目录中：

```text
~/.claude/usage_cache.json
```

默认缓存时间是 60 秒：

```python
CACHE_TTL_SECONDS = 60
```

这样做的原因是 Claude Code status line 可能频繁刷新。如果每次刷新都请求远程接口，会导致：

- 状态栏变慢
- 网络失败概率增加
- API 请求过于频繁

如果远程请求失败，脚本会优先使用已有缓存。如果没有缓存，则跳过配额显示。

## 故障排查

### 状态栏没有任何输出

先用模拟输入测试：

```bash
printf '%s\n' '{"model":{"display_name":"Claude Sonnet"},"workspace":{"current_dir":"/tmp/demo"},"context_window":{"used_percentage":20}}' \
  | python3 /absolute/path/to/usage-display/claude_quota.py
```

如果这个命令有输出，说明脚本本身正常，请检查 `~/.claude/settings.json` 中的路径是否是绝对路径。

### 只显示模型和目录，不显示配额

可能原因：

- Claude Code 没有登录。
- `~/.claude/.credentials.json` 不存在。
- 使用了自定义配置目录，但没有设置 `CLAUDE_CONFIG_DIR`。
- 网络请求失败。
- 接口返回结构发生变化。

可以检查凭据文件是否存在：

```bash
ls -la ~/.claude/.credentials.json
```

如果你使用自定义配置目录：

```bash
echo "$CLAUDE_CONFIG_DIR"
ls -la "$CLAUDE_CONFIG_DIR/.credentials.json"
```

### 状态栏刷新很慢

脚本设置了 60 秒缓存，一般不会每次都请求网络。如果仍然很慢，可以临时只显示本地字段：

```json
{
  "statusLine": {
    "command": "python3 /absolute/path/to/usage-display/claude_quota.py --model --dir --context"
  }
}
```

## 安全说明

- 不要提交 `~/.claude/.credentials.json`。
- 不要把任何 API token 写进仓库。
- 不要把 `.env` 文件提交到 GitHub。
- `.gitignore` 已经忽略常见 Python 缓存、本地环境文件和 Claude 本地凭据文件。
- `claude_quota.py` 只读取本地凭据并请求 Claude 用量接口，不会打印 access token。

## 开发说明

语法检查：

```bash
python3 -m py_compile claude_quota.py
```

模拟 statusLine 输入：

```bash
printf '%s\n' '{"model":{"display_name":"Claude Sonnet"},"workspace":{"current_dir":"/tmp/demo"},"context_window":{"used_percentage":36},"cost":{"total_cost_usd":0.12}}' \
  | python3 claude_quota.py --model --dir --context --cost
```

查看 Git 状态：

```bash
git status --short
```

## 许可证

如果你准备公开发布到 GitHub，建议添加一个 `LICENSE` 文件。个人工具通常可以选择 MIT License。
