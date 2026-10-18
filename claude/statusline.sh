#!/bin/bash

# Read JSON input from stdin
input=$(cat)

# Extract information from JSON
model_name=$(echo "$input" | jq -r '.model.display_name')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir')
project_dir=$(echo "$input" | jq -r '.workspace.project_dir // .workspace.current_dir')

# Tokens currently in context (input incl. cache; 0 before first API call / after /compact)
context_tokens=$(echo "$input" | jq -r '(.context_window.total_input_tokens // 0) | floor')
effort_level=$(echo "$input" | jq -r '.effort.level // empty')

# Extract cost information
session_cost=$(echo "$input" | jq -r '.cost.total_cost_usd // empty')
[ "$session_cost" != "empty" ] && session_cost=$(printf "%.4f" "$session_cost") || session_cost=""

# Get project directory name (basename of launch dir)
dir_name=$(basename "$project_dir")

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Get authenticated account email from ~/.claude.json (or CLAUDE_CONFIG_DIR)
config_dir="${CLAUDE_CONFIG_DIR:-$HOME}"
account_email=$(jq -r '.oauthAccount.emailAddress // empty' "$config_dir/.claude.json" 2>/dev/null)
account_info=""
[ -n "$account_email" ] && account_info=" ${GRAY}|${NC} ${MAGENTA}${account_email#*@}${NC}"

# Change to the current directory to get git info
cd "$current_dir" 2>/dev/null || cd /

# Get git branch
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  branch=$(git branch --show-current 2>/dev/null || echo "detached")

  # Get git status with file counts
  status_output=$(git status --porcelain 2>/dev/null)
  if [ -n "$status_output" ]; then
    total_files=$(echo "$status_output" | wc -l | xargs)
    line_stats=$(git diff --numstat HEAD 2>/dev/null | awk '{added+=$1; removed+=$2} END {print added+0, removed+0}')
    added=$(echo $line_stats | cut -d' ' -f1)
    removed=$(echo $line_stats | cut -d' ' -f2)

    git_info=" ${YELLOW}($branch${NC} ${YELLOW}|${NC} ${GRAY}${total_files} files${NC}"
    [ "$added" -gt 0 ] && git_info="${git_info} ${GREEN}+${added}${NC}"
    [ "$removed" -gt 0 ] && git_info="${git_info} ${RED}-${removed}${NC}"
    git_info="${git_info} ${YELLOW})${NC}"
  else
    git_info=" ${YELLOW}($branch)${NC}"
  fi
else
  git_info=""
fi

# Add session cost if available
cost_info=""
if [ -n "$session_cost" ] && [ "$session_cost" != "null" ] && [ "$session_cost" != "empty" ]; then
  cost_info=" ${GRAY}[\$$session_cost]${NC}"
fi

# Compact token count: 840, 1K, 12K, 384K, 1.2M
if [ "$context_tokens" -ge 1000000 ]; then
  token_label=$(awk -v t="$context_tokens" 'BEGIN{printf "%.1fM", t/1000000}')
elif [ "$context_tokens" -ge 1000 ]; then
  token_label="$(( (context_tokens + 500) / 1000 ))K"
else
  token_label="$context_tokens"
fi
context_info="${GRAY}${token_label}${NC}"

# Effort level next to the model, color-coded by intensity
effort_info=""
if [ -n "$effort_level" ]; then
  case "$effort_level" in
    low)    effort_color="$GRAY" ;;
    medium) effort_color="$GREEN" ;;
    high)   effort_color="$YELLOW" ;;
    xhigh)  effort_color="$MAGENTA" ;;
    max)    effort_color="$RED" ;;
    *)      effort_color="$GRAY" ;;
  esac
  effort_info=" ${effort_color}${effort_level}${NC}"
fi

# Session prompt-cache hit ratio (main conversation); hidden until a ratio exists.
cache_data=$(echo "$input" | jq -r '(.prompt_cache.hit_ratio // null) | if . == null then "skip" else (. * 100 | floor) end')
cache_info=""
if [ "$cache_data" != "skip" ]; then
  if [ "$cache_data" -ge 85 ]; then
    cache_color="$GREEN"
  elif [ "$cache_data" -ge 60 ]; then
    cache_color="$YELLOW"
  else
    cache_color="$RED"
  fi
  cache_info=" ${cache_color}⚡${cache_data}%${NC}"
fi

# Rate limits (5-hour / 7-day); each window hidden when absent
rate_info=""
for window in five_hour:5h; do
  pct=$(echo "$input" | jq -r ".rate_limits.${window%%:*}.used_percentage // empty | floor")
  [ -z "$pct" ] && continue
  if [ "$pct" -ge 85 ]; then
    rate_color="$RED"
  elif [ "$pct" -ge 60 ]; then
    rate_color="$YELLOW"
  else
    rate_color="$GREEN"
  fi
  rate_info="${rate_info} ${GRAY}${window##*:}${NC} ${rate_color}${pct}%${NC}"
done

# Output: left group (dir, model, context) pinned left, the rest pinned right.
# COLUMNS is set by Claude Code; RIGHT_MARGIN absorbs the UI's built-in edge spacing.
RIGHT_MARGIN=4
left="${BLUE}${dir_name}${NC} ${GRAY}|${NC} ${CYAN}${model_name}${NC}${effort_info} ${GRAY}|${NC} ${context_info}"
right="${cache_info}${rate_info}${git_info}${cost_info}${account_info}"
right="${right# }"

# Visible width: strip ANSI, count chars (UTF-8), add 1 per double-width ⚡
vis_len() {
  printf '%b' "$1" | sed $'s/\x1b\[[0-9;]*m//g' | LC_ALL=en_US.UTF-8 bash -c \
    'read -r p; b="${p//[^⚡]/}"; echo $(( ${#p} + ${#b} ))'
}

if [ -n "$right" ] && [ "${COLUMNS:-0}" -gt 0 ]; then
  gap=$((COLUMNS - RIGHT_MARGIN - $(vis_len "$left") - $(vis_len "$right")))
else
  gap=0
fi
if [ "$gap" -ge 2 ]; then
  printf -v pad '%*s' "$gap" ''
  echo -e "${left}${pad}${right}"
else
  echo -e "${left} ${right}"
fi
