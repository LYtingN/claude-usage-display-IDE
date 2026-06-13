# Usage Display Plugin

在 Claude Code 终端中显示用量信息。**专为 Pro 用户设计，无需 API key**。

## 功能

- 会话开始时显示当前用量（只调用一次）
- 读取本地 `~/.claude/stats-cache.json`（Claude Code 自动维护）
- 支持 `SessionStart` hook，每次启动显示一次

## 工作原理

Claude Code 内部已追踪所有用量数据到 `~/.claude/stats-cache.json`：
- 总消息数、会话数
- 各模型 token 用量（Sonnet、Opus、Haiku 等）
- 无需 API key，Pro 用户直接可用

## 配置状态

`~/.claude/settings.json` 已配置 `SessionStart` hook：

```json
{
  "hooks": {
    "SessionStart": [{
      "matcher": "*",
      "hooks": [{
        "type": "command",
        "command": "bash /home/phi5090ii/NYX/vibe_coding/usage-display/scripts/show-usage.sh",
        "timeout": 15
      }]
    }]
  }
}
```

## 手动测试

```bash
bash /home/phi5090ii/NYX/vibe_coding/usage-display/scripts/show-usage.sh
```

## 注意

- 显示位置由 Claude Code 决定（session start 时输出）
- Claude Code 没有"每次对话后"的 hook，所以无法做到实时刷新
- 用量数据由 Claude Code 本地缓存提供，可能有几分钟延迟
