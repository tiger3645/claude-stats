#!/bin/bash
input=$(cat)

MODEL=$(echo "$input" | jq -r '.model.display_name')
DIR=$(echo "$input" | jq -r '.workspace.current_dir')
PCT=$(echo "$input" | jq -r '.context_window.used_percentage // 0' | cut -d. -f1)
DURATION_MS=$(echo "$input" | jq -r '.cost.total_duration_ms // 0')

CYAN='\033[36m'; GREEN='\033[32m'; YELLOW='\033[33m'; RED='\033[31m'; RESET='\033[0m'

# Pick bar color based on context usage
if [ "$PCT" -ge 90 ]; then BAR_COLOR="$RED"
elif [ "$PCT" -ge 70 ]; then BAR_COLOR="$YELLOW"
else BAR_COLOR="$GREEN"; fi

FILLED=$((PCT / 10)); EMPTY=$((10 - FILLED))
printf -v FILL "%${FILLED}s"; printf -v PAD "%${EMPTY}s"
BAR="${FILL// /█}${PAD// /░}"

# Show session time in hours, minutes, and seconds
HOURS=$((DURATION_MS / 3600000)); MINS=$((DURATION_MS / 60000 % 60)); SECS=$(((DURATION_MS % 60000) / 1000))

# "// empty" produces no output when rate_limits is absent
FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
WEEK=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')

# Color function for rate limits: green <50%, yellow <80%, red >=80%
color_limit() {
  local pct=$(printf '%.0f' "$1")
  if (( $(echo "$pct < 50" | bc -l) )); then
    echo "${GREEN}${pct}%${RESET}"
  elif (( $(echo "$pct < 80" | bc -l) )); then
    echo "${YELLOW}${pct}%${RESET}"
  else
    echo "${RED}${pct}%${RESET}"
  fi
}

LIMITS=""
[ -n "$FIVE_H" ] && LIMITS="5h: $(color_limit "$FIVE_H")"
[ -n "$WEEK" ] && LIMITS="${LIMITS:+$LIMITS }7d: $(color_limit "$WEEK")"

# GIT info
BRANCH=""
STAGED=""
MODIFIED=""

git rev-parse --git-dir > /dev/null 2>&1 && BRANCH=" | 🌿 $(git branch --show-current 2>/dev/null)"
git rev-parse --git-dir > /dev/null 2>&1 && STAGED=$(git diff --cached --numstat 2>/dev/null | wc -l | tr -d ' ')
git rev-parse --git-dir > /dev/null 2>&1 && MODIFIED=$(git diff --numstat 2>/dev/null | wc -l | tr -d ' ')
GIT_STATUS=""
    [ "$STAGED" -gt 0 ] && GIT_STATUS="${GREEN}+${STAGED}${RESET}"
    [ "$MODIFIED" -gt 0 ] && GIT_STATUS="${GIT_STATUS}${YELLOW}~${MODIFIED}${RESET}"


echo -e "${CYAN}[$MODEL]${RESET} 📁 ${DIR##*/}$BRANCH $GIT_STATUS"
echo -e "${BAR_COLOR}${BAR}${RESET} ${PCT}% | $LIMITS | ${HOURS}h ${MINS}m ${SECS}s"