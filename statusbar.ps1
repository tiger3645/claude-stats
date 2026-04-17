[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$raw  = [Console]::In.ReadToEnd()
$json = ConvertFrom-Json $raw

$MODEL       = $json.model.display_name
$DIR         = $json.workspace.current_dir
$used_pct    = if ($null -ne $json.context_window.used_percentage) { $json.context_window.used_percentage } else { 0 }
$PCT         = [int][math]::Floor($used_pct)
$DURATION_MS = if ($json.cost.total_duration_ms) { [long]$json.cost.total_duration_ms } else { 0 }

$ESC    = [char]27
$CYAN   = "$ESC[36m"
$GREEN  = "$ESC[32m"
$YELLOW = "$ESC[33m"
$RED    = "$ESC[31m"
$RESET  = "$ESC[0m"

if     ($PCT -ge 90) { $BAR_COLOR = $RED    }
elseif ($PCT -ge 70) { $BAR_COLOR = $YELLOW }
else                 { $BAR_COLOR = $GREEN  }

$FILLED = [int]($PCT / 10)
$EMPTY  = 10 - $FILLED
$BAR    = ([string][char]0x2588 * $FILLED) + ([string][char]0x2591 * $EMPTY)

$HOURS = [int]($DURATION_MS / 3600000)
$MINS  = [int](($DURATION_MS / 60000) % 60)
$SECS  = [int](($DURATION_MS % 60000) / 1000)

function Get-LimitStr($pct) {
    $p = [int][math]::Round($pct)
    if     ($p -lt 50) { return "${GREEN}${p}%${RESET}"  }
    elseif ($p -lt 80) { return "${YELLOW}${p}%${RESET}" }
    else               { return "${RED}${p}%${RESET}"    }
}

$FIVE_H = $json.rate_limits.five_hour.used_percentage
$WEEK   = $json.rate_limits.seven_day.used_percentage

$LIMITS = ""
if ($null -ne $FIVE_H) { $LIMITS = "5h: $(Get-LimitStr $FIVE_H)" }
if ($null -ne $WEEK)   {
    if ($LIMITS) { $LIMITS += " " }
    $LIMITS += "7d: $(Get-LimitStr $WEEK)"
}

$BRANCH     = ""
$GIT_STATUS = ""
$null = git rev-parse --git-dir 2>$null
if ($LASTEXITCODE -eq 0) {
    $BRANCH_NAME = git branch --show-current 2>$null
    $BRANCH      = " | $(([char]0x1F33F)) $BRANCH_NAME"
    $STAGED      = @(git diff --cached --numstat 2>$null).Count
    $MODIFIED    = @(git diff --numstat 2>$null).Count
    if ($STAGED   -gt 0) { $GIT_STATUS += "${GREEN}+${STAGED}${RESET}"    }
    if ($MODIFIED -gt 0) { $GIT_STATUS += "${YELLOW}~${MODIFIED}${RESET}" }
}

$DIR_NAME = Split-Path $DIR -Leaf

[Console]::WriteLine("${CYAN}[$MODEL]${RESET} $(([char]0x1F4C1)) ${DIR_NAME}${BRANCH} $GIT_STATUS")
[Console]::WriteLine("${BAR_COLOR}${BAR}${RESET} ${PCT}% | $LIMITS | ${HOURS}h ${MINS}m ${SECS}s")
