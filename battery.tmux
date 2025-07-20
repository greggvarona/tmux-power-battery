#!/usr/bin/env bash

SDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SDIR/scripts/helpers.sh"

battery_percentage_format() {
    get_tmux_option @battery_percentage_format "%%3s%%%%"
}

battery_remain_format() {
    get_tmux_option @battery_remain_format "%%5s"
}

battery_status_format() {
    get_tmux_option @battery_status_format "%%s"
}

battery_bar_format() {
    get_tmux_option @battery_bar_format "%%s"
}

battery_bar_length() {
    get_tmux_option @battery_bar_length "10"
}

battery_percentage="#($SDIR/scripts/battery-status.sh percentage '$(battery_percentage_format)')"
battery_remain="#($SDIR/scripts/battery-status.sh remain '$(battery_remain_format)')"
battery_status="#($SDIR/scripts/battery-status.sh status '$(battery_status_format)')"
battery_bar="#($SDIR/scripts/battery-status.sh bar '$(battery_bar_format)' '$(battery_bar_length)')"

battery_percentage_interpolation="\#{battery_percentage}"
battery_remain_interpolation="\#{battery_remain}"
battery_status_interpolation="\#{battery_status}"
battery_bar_interpolation="\#{battery_bar}"

do_interpolation() {
    local input=$1
    local result=""

    result=${input/$battery_percentage_interpolation/$battery_percentage}
    result=${result/$battery_remain_interpolation/$battery_remain}
    result=${result/$battery_status_interpolation/$battery_status}
    result=${result/$battery_bar_interpolation/$battery_bar}

    echo "$result"
}

update_tmux_option() {
    local option=$1
    local option_value=$(get_tmux_option "$option")
    set_tmux_option "$option" "$(do_interpolation "$option_value")"
}

main() {
    update_tmux_option "status-right"
    update_tmux_option "status-left"
}
main