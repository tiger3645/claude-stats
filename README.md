# claude-stats

A statusbar script for Claude Code that displays context window usage, rate limits, and git information in your terminal.

## Features

- **Context Window Usage** — Visual progress bar showing how much of your context is used
- **Rate Limits** — Displays 5-hour and 7-day usage percentages with color coding:
  - 🟢 Green: under 50%
  - 🟡 Yellow: 50-80%
  - 🔴 Red: 80%+
- **Git Status** — Shows current branch and number of staged/modified files
- **Session Duration** — Total time spent in the session

## Installation

1. Copy `statusbar.sh` to your Claude Code configuration directory:
   ```bash
   cp statusbar.sh ~/.claude/
   chmod +x ~/.claude/statusbar.sh
   ```

2. Configure Claude Code to use this script via `settings.json`:
   ```json
   {
     "statuslineHook": "~/.claude/statusbar.sh"
   }
   ```

## Usage

The script is automatically called by Claude Code and displays a statusline at the bottom of the terminal. No manual invocation needed.

### Output Format

```
[Model Name] 📁 folder-name | 🌿 branch-name +staged ~modified
█████████░ 95% | 5h: 42% 7d: 65% | 2h 15m 30s
```

- **Progress Bar** — Shows context window usage percentage
- **Rate Limits** — 5-hour and 7-day usage with color coding
- **Duration** — Time spent in the current session

## Requirements

- bash
- jq (for JSON parsing)
- bc (for floating-point math)
- git (optional, for branch/status info)
