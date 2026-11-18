#!/bin/bash
# Status line: cwd, git branch, model name, effort level, git worktree, context used %, plan/rate-limit usage, session name, session id

input=$(cat)

dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // empty')
dir_display=""
if [ -n "$dir" ]; then
  case "$dir" in
    "$HOME") dir_display="~" ;;
    "$HOME"/*) dir_display="~${dir#$HOME}" ;;
    *) dir_display="$dir" ;;
  esac
fi

branch=""
if [ -n "$dir" ]; then
  branch=$(git --no-optional-locks -C "$dir" branch --show-current 2>/dev/null)
  if [ -z "$branch" ]; then
    branch=$(git --no-optional-locks -C "$dir" rev-parse --short HEAD 2>/dev/null)
  fi
fi

model=$(echo "$input" | jq -r '.model.display_name // empty')
effort=$(echo "$input" | jq -r '.effort.level // empty')
worktree=$(echo "$input" | jq -r '.worktree.name // empty')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
session=$(echo "$input" | jq -r '.session_name // empty')
session_id=$(echo "$input" | jq -r '.session_id // empty')

# Plan/account usage (rate limits); reset time formatted from epoch seconds.
fmt_reset() {
  local epoch="$1" fmt="$2"
  [ -n "$epoch" ] && [ "$epoch" != "null" ] && date -d "@$epoch" "+$fmt" 2>/dev/null
}

# Render a 10-cell progress bar meter: "<dim label> <colored bar> <pct>%[ <dim reset>]"
# Color: green <70%, yellow 70-89%, red >=90%. Clamps pct to 0-100 and rounds it.
meter_render() {
  local label="$1" pct="$2" reset="$3"
  local rounded
  rounded=$(printf '%.0f' "$pct" 2>/dev/null)
  [ -z "$rounded" ] && rounded=0
  [ "$rounded" -lt 0 ] && rounded=0
  [ "$rounded" -gt 100 ] && rounded=100
  local filled=$(( (rounded + 5) / 10 ))
  [ "$filled" -gt 10 ] && filled=10
  [ "$filled" -lt 0 ] && filled=0
  local empty=$((10 - filled))
  local bar="" i
  for ((i = 0; i < filled; i++)); do bar="${bar}▓"; done
  for ((i = 0; i < empty; i++)); do bar="${bar}░"; done
  local color=32
  if [ "$rounded" -ge 90 ]; then
    color=31
  elif [ "$rounded" -ge 70 ]; then
    color=33
  fi
  local out
  out="$(printf '\033[2m%s\033[0m ' "$label")"
  out="${out}$(printf '\033[%dm%s %d%%\033[0m' "$color" "$bar" "$rounded")"
  if [ -n "$reset" ]; then
    out="${out} $(printf '\033[2m↻%s\033[0m' "$reset")"
  fi
  printf '%s' "$out"
}

five_pct=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_reset_epoch=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
week_pct=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
week_reset_epoch=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')
spend_pct=$(echo "$input" | jq -r '.rate_limits.spend_limit.used_percentage // empty')
spend_reset_epoch=$(echo "$input" | jq -r '.rate_limits.spend_limit.resets_at // empty')

meters=()
[ -n "$used" ] && meters+=("$(meter_render "ctx" "$used" "")")
if [ -n "$five_pct" ]; then
  five_reset=$(fmt_reset "$five_reset_epoch" "%H:%M")
  meters+=("$(meter_render "5h" "$five_pct" "$five_reset")")
fi
if [ -n "$week_pct" ]; then
  week_reset=$(fmt_reset "$week_reset_epoch" "%a %H:%M")
  meters+=("$(meter_render "week" "$week_pct" "$week_reset")")
fi
if [ -n "$spend_pct" ]; then
  spend_reset=$(fmt_reset "$spend_reset_epoch" "%a %H:%M")
  meters+=("$(meter_render "spend" "$spend_pct" "$spend_reset")")
fi

ctx_part=""
for m in "${meters[@]}"; do
  if [ -z "$ctx_part" ]; then
    ctx_part="$m"
  else
    ctx_part="$ctx_part$(printf '  \033[2m\xc2\xb7\033[0m  ')$m"
  fi
done

parts=()

[ -n "$dir_display" ] && parts+=("$(printf '\033[2m%s\033[0m' "$dir_display")")
[ -n "$branch" ] && parts+=("$(printf '\033[35m%s\033[0m' "$branch")")
[ -n "$model" ] && parts+=("$(printf '\033[36m%s\033[0m' "$model")")
[ -n "$effort" ] && parts+=("$(printf '\033[33meffort:%s\033[0m' "$effort")")
[ -n "$worktree" ] && parts+=("$(printf '\033[35mwt:%s\033[0m' "$worktree")")
[ -n "$ctx_part" ] && parts+=("$ctx_part")
[ -n "$session" ] && parts+=("$(printf '\033[34m%s\033[0m' "$session")")
[ -n "$session_id" ] && parts+=("$(printf '\033[2mid:%s\033[0m' "$session_id")")

out=""
for p in "${parts[@]}"; do
  if [ -z "$out" ]; then
    out="$p"
  else
    out="$out $(printf '\033[2m|\033[0m') $p"
  fi
done

printf '%s' "$out"
