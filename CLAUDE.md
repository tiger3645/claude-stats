# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Is

Bash statusbar hook for Claude Code. Reads JSON from stdin (provided by Claude Code via `statuslineHook`), outputs a 2-line statusbar with context window usage, rate limits, git status, and session duration.

## Installation

```bash
cp statusbar.sh ~/.claude/
chmod +x ~/.claude/statusbar.sh
```

`~/.claude/settings.json`:
```json
{ "statuslineHook": "~/.claude/statusbar.sh" }
```

## Testing the Script

Pipe mock JSON to test without Claude Code:

```bash
echo '{"model":{"display_name":"claude-opus-4"},"workspace":{"current_dir":"/home/user/project"},"context_window":{"used_percentage":72.5},"cost":{"total_duration_ms":5400000},"rate_limits":{"five_hour":{"used_percentage":45},"seven_day":{"used_percentage":81}}}' | bash statusbar.sh
```

## Architecture

Single script (`statusbar.sh`). Data flow:

1. Claude Code passes session JSON to stdin
2. `jq` extracts fields: `model.display_name`, `workspace.current_dir`, `context_window.used_percentage`, `cost.total_duration_ms`, `rate_limits.five_hour.used_percentage`, `rate_limits.seven_day.used_percentage`
3. Script computes: progress bar (10-char, █/░), colors (green/yellow/red thresholds), H:M:S duration, git branch + staged/modified counts
4. Outputs 2 lines via `echo -e`

## Color Thresholds

| Metric | Green | Yellow | Red |
|--------|-------|--------|-----|
| Context bar | <70% | 70–89% | ≥90% |
| Rate limits | <50% | 50–79% | ≥80% |

## Dependencies

- `jq` — JSON parsing
- `bc` — floating-point comparisons in `color_limit()`
- `git` — optional; branch/status silently omitted if absent
