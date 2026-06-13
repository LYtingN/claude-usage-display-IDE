# Usage Display 维护说明

这个项目用于在 Claude Code 中显示状态栏用量信息。对外使用说明以 `README.md` 为准。

## 主要入口

- `claude_quota.py`：唯一运行入口，用作 Claude Code `statusLine` 命令。

## 本地验证

```bash
python3 -m py_compile claude_quota.py
printf '%s\n' '{"model":{"display_name":"Claude Sonnet"},"workspace":{"current_dir":"/tmp/demo"},"context_window":{"used_percentage":36},"cost":{"total_cost_usd":0.12}}' \
  | python3 claude_quota.py --model --dir --context --cost
```

## 维护注意事项

- 不要提交 Claude OAuth 凭据、API token、`.env` 文件或本地缓存。
- `claude_quota.py` 不依赖第三方 Python 包，保持这个约束可以降低安装成本。
- 如果修改输出字段，同步更新 `README.md` 的参数说明和示例输出。
