#!/bin/bash
# 显示 MiniMax Token Plan 配额（调用官方 API）

API_KEY="${ANTHROPIC_AUTH_TOKEN}"
ENDPOINT="https://www.minimaxi.com/v1/api/openplatform/coding_plan/remains"

# 默认值（API 调用失败时显示）
DAILY_REMAIN=0
DAILY_TOTAL=0
WEEKLY_REMAIN=0
WEEKLY_TOTAL=0

response=$(curl -s -X GET "$ENDPOINT" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" 2>/dev/null)

if echo "$response" | jq -e '.base_resp.status_code == 0' > /dev/null 2>&1; then
  # 提取 MiniMax-M* 的数据
  data=$(echo "$response" | jq '.model_remains[] | select(.model_name == "MiniMax-M*")' 2>/dev/null)

  if [ -n "$data" ]; then
    DAILY_TOTAL=$(echo "$data" | jq -r '.current_interval_total_count')
    DAILY_REMAIN=$(echo "$data" | jq -r '.current_interval_usage_count')
    WEEKLY_TOTAL=$(echo "$data" | jq -r '.current_weekly_total_count')
    WEEKLY_REMAIN=$(echo "$data" | jq -r '.current_weekly_usage_count')
  fi
fi

# 计算百分比
if [ "$DAILY_TOTAL" -gt 0 ]; then
  DAILY_PCT=$(( (DAILY_REMAIN * 100) / DAILY_TOTAL ))
else
  DAILY_PCT=0
fi

if [ "$WEEKLY_TOTAL" -gt 0 ]; then
  WEEKLY_PCT=$(( (WEEKLY_REMAIN * 100) / WEEKLY_TOTAL ))
else
  WEEKLY_PCT=0
fi

echo "5h left:${DAILY_PCT}% | weekly left:${WEEKLY_PCT}%"
