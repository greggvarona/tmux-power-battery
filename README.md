# tmux-power-battery

A tmux plugin that displays battery information in your tmux status bar. Works seamlessly with [tmux-power](https://github.com/wfxr/tmux-power) (with a bit of tweaks... not shown in this repo).

## Features

- 🔋 Battery percentage display
- ⚡ Charging/discharging status indicators
- ⏱️ Remaining time display
- 📊 Visual battery bar
- 🖥️ Multi-platform support (macOS, Linux, FreeBSD, OpenBSD)

## Installation

### With [Tmux Plugin Manager](https://github.com/tmux-plugins/tpm)

Add plugin to the list of TPM plugins in `.tmux.conf`:

```tmux
set -g @plugin 'gregg/tmux-power-battery'
```

Hit `prefix + I` to fetch the plugin and source it.

### Manual Installation

Clone the repo:

```bash
git clone https://github.com/gregg/tmux-power-battery ~/clone/path
```

Add this line to your `.tmux.conf`:

```tmux
run-shell ~/clone/path/battery.tmux
```

Reload tmux environment:

```bash
tmux source-file ~/.tmux.conf
```

## Usage

Add any of the supported interpolation strings to your `status-left` or `status-right` tmux option:

```tmux
set -g status-right '#{battery_status} #{battery_percentage} #{battery_remain}'
```

### Interpolation Strings

- `#{battery_percentage}` - Battery percentage (e.g., "85%")
- `#{battery_status}` - Battery status icon (⚡ charging, 🔋 discharging, 🔌 charged)
- `#{battery_remain}` - Remaining time (e.g., "2h30m" or "1:45")
- `#{battery_bar}` - Visual battery bar (e.g., "████████░░")

## Configuration

### Formatting Options

You can customize the output format using printf-style format strings:

```tmux
# Battery percentage format (default: "%3s%%")
set -g @battery_percentage_format "%3s%%"

# Battery remaining time format (default: "%5s")
set -g @battery_remain_format "%5s"

# Battery status format (default: "%s")
set -g @battery_status_format "%s"

# Battery bar format (default: "%s")
set -g @battery_bar_format "%s"

# Battery bar length (default: "10")
set -g @battery_bar_length "10"
```

### Example Configurations

#### Simple status line
```tmux
set -g status-right '#{battery_status} #{battery_percentage}'
```

#### Detailed status with remaining time
```tmux
set -g status-right '#{battery_status} #{battery_percentage} (#{battery_remain})'
```

#### Visual bar representation
```tmux
set -g status-right '#{battery_bar} #{battery_percentage}'
```

#### Integration with tmux-power
```tmux
# After loading tmux-power
set -g @tmux_power_show_battery true
set -g @tmux_power_battery_status '#{battery_status}'
set -g @tmux_power_battery_percentage '#{battery_percentage}'
```

## Platform Support

- **macOS**: Uses `pmset` for battery information
- **Linux**: Uses `/sys/class/power_supply/` or `acpi` command
- **FreeBSD**: Uses `apm` command
- **OpenBSD**: Uses `apm` command

## Requirements

- tmux 1.9 or higher
- Bash

### Platform-specific requirements

- **Linux**: `acpi` package (optional, for time remaining)
- **FreeBSD/OpenBSD**: `apm` utility

