# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

tmux-power-battery is a tmux plugin that displays battery information in the tmux status bar. It supports multiple platforms (macOS, Linux, FreeBSD, OpenBSD) and provides battery percentage, status indicators, remaining time, and visual battery bars.

## Commands

### Development
- **Run the plugin**: `bash battery.tmux` (in a tmux session)
- **Test battery script**: `bash scripts/battery-status.sh percentage|status|remain|bar`
- **No build/lint/test commands**: This is a bash script project without a build system

### Testing Changes
To test modifications:
1. Source the plugin in tmux: `run-shell /path/to/battery.tmux`
2. Check tmux options: `tmux show-options -g | grep battery`
3. Test interpolation: `tmux display-message "Battery: #{battery_percentage}"`

## Architecture

### Core Components
- **battery.tmux**: Main entry point that sets up tmux interpolations and handles configuration
- **scripts/battery-status.sh**: Platform-specific battery information retrieval
- **scripts/helpers.sh**: Utility functions for tmux options and OS detection

### Key Design Patterns
1. **Platform Abstraction**: OS detection in helpers.sh, platform-specific implementations in battery-status.sh
2. **Tmux Interpolation**: Uses #{} syntax for seamless integration with tmux status line
3. **Configuration via tmux options**: All settings stored as @battery_* tmux options

### Platform-Specific Battery Access
- **macOS**: `pmset -g batt`
- **Linux**: `/sys/class/power_supply/BAT*/` or `acpi` command
- **FreeBSD/OpenBSD**: `apm` command

### Output Modes
The battery-status.sh script supports four modes:
- `percentage`: Battery level (0-100%)
- `status`: Emoji indicator (⚡ charging, 🔋 discharging, 🔌 plugged)
- `remain`: Time remaining (e.g., "2h30m")
- `bar`: Visual representation (████░░░░░░)

## Important Implementation Details

1. **Tmux Version Compatibility**: Uses conditional logic for tmux versions (< 3.0 vs >= 3.0) in battery.tmux:50-58
2. **Battery Detection**: Linux implementation checks multiple BAT devices in /sys/class/power_supply/
3. **Time Formatting**: Custom format_time function converts minutes to human-readable format
4. **Error Handling**: Returns empty strings when battery info unavailable
5. **Printf Formatting**: All outputs support custom printf-style formatting via tmux options