#!/usr/bin/env bash

SDIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SDIR/helpers.sh"

get_battery_osx() {
    local mode=$1
    
    if pmset -g batt &> /dev/null; then
        local battery_info=$(pmset -g batt | grep -Eo '[0-9]+%|discharging|charging|charged|AC attached|finishing charge|[0-9]+:[0-9]+')
        local percentage=$(echo "$battery_info" | grep -Eo '[0-9]+%' | head -1 | tr -d '%')
        local status=$(echo "$battery_info" | grep -Eo 'discharging|charging|charged|finishing charge' | head -1)
        local time_left=$(echo "$battery_info" | grep -Eo '[0-9]+:[0-9]+' | head -1)
        
        case "$mode" in
            percentage)
                echo "${percentage:-0}"
                ;;
            status)
                case "$status" in
                    "charging"|"finishing charge")
                        echo "⚡"
                        ;;
                    "charged")
                        echo "🔌"
                        ;;
                    "discharging")
                        echo "🔋"
                        ;;
                    *)
                        echo "?"
                        ;;
                esac
                ;;
            remain)
                if [[ -n "$time_left" ]] && [[ "$time_left" != "0:00" ]]; then
                    echo "$time_left"
                else
                    echo "---"
                fi
                ;;
        esac
    else
        case "$mode" in
            percentage) echo "0" ;;
            status) echo "?" ;;
            remain) echo "---" ;;
        esac
    fi
}

get_battery_linux() {
    local mode=$1
    local bat_path="/sys/class/power_supply/BAT0"
    
    if [[ -d "$bat_path" ]]; then
        local capacity=$(cat "$bat_path/capacity" 2>/dev/null || echo "0")
        local status=$(cat "$bat_path/status" 2>/dev/null || echo "Unknown")
        
        case "$mode" in
            percentage)
                echo "$capacity"
                ;;
            status)
                case "$status" in
                    "Charging")
                        echo "⚡"
                        ;;
                    "Full")
                        echo "🔌"
                        ;;
                    "Discharging")
                        echo "🔋"
                        ;;
                    *)
                        echo "?"
                        ;;
                esac
                ;;
            remain)
                if command -v acpi &> /dev/null; then
                    local acpi_out=$(acpi -b 2>/dev/null | head -1)
                    local time_left=$(echo "$acpi_out" | grep -Eo '[0-9]+:[0-9]+:[0-9]+' | head -1)
                    if [[ -n "$time_left" ]]; then
                        echo "${time_left%:*}"
                    else
                        echo "---"
                    fi
                else
                    echo "---"
                fi
                ;;
        esac
    elif command -v acpi &> /dev/null; then
        local acpi_out=$(acpi -b 2>/dev/null | head -1)
        local percentage=$(echo "$acpi_out" | grep -Eo '[0-9]+%' | tr -d '%')
        local status=$(echo "$acpi_out" | grep -Eo 'Charging|Full|Discharging')
        local time_left=$(echo "$acpi_out" | grep -Eo '[0-9]+:[0-9]+:[0-9]+' | head -1)
        
        case "$mode" in
            percentage)
                echo "${percentage:-0}"
                ;;
            status)
                case "$status" in
                    "Charging")
                        echo "⚡"
                        ;;
                    "Full")
                        echo "🔌"
                        ;;
                    "Discharging")
                        echo "🔋"
                        ;;
                    *)
                        echo "?"
                        ;;
                esac
                ;;
            remain)
                if [[ -n "$time_left" ]]; then
                    echo "${time_left%:*}"
                else
                    echo "---"
                fi
                ;;
        esac
    else
        case "$mode" in
            percentage) echo "0" ;;
            status) echo "?" ;;
            remain) echo "---" ;;
        esac
    fi
}

get_battery_freebsd() {
    local mode=$1
    
    if command -v apm &> /dev/null; then
        local apm_out=$(apm -l 2>/dev/null)
        local percentage="${apm_out:-0}"
        local ac_status=$(apm -a 2>/dev/null)
        
        case "$mode" in
            percentage)
                echo "$percentage"
                ;;
            status)
                if [[ "$ac_status" == "1" ]]; then
                    if [[ "$percentage" == "100" ]]; then
                        echo "🔌"
                    else
                        echo "⚡"
                    fi
                else
                    echo "🔋"
                fi
                ;;
            remain)
                local time_left=$(apm -t 2>/dev/null)
                if [[ -n "$time_left" ]] && [[ "$time_left" != "-1" ]]; then
                    format_time "$time_left"
                else
                    echo "---"
                fi
                ;;
        esac
    else
        case "$mode" in
            percentage) echo "0" ;;
            status) echo "?" ;;
            remain) echo "---" ;;
        esac
    fi
}

get_battery_openbsd() {
    local mode=$1
    
    if command -v apm &> /dev/null; then
        local apm_out=$(apm -l 2>/dev/null)
        local percentage="${apm_out:-0}"
        local ac_status=$(apm -a 2>/dev/null)
        
        case "$mode" in
            percentage)
                echo "$percentage"
                ;;
            status)
                if [[ "$ac_status" == "1" ]]; then
                    if [[ "$percentage" == "100" ]]; then
                        echo "🔌"
                    else
                        echo "⚡"
                    fi
                else
                    echo "🔋"
                fi
                ;;
            remain)
                local minutes=$(apm -m 2>/dev/null)
                if [[ -n "$minutes" ]] && [[ "$minutes" != "-1" ]]; then
                    format_time "$minutes"
                else
                    echo "---"
                fi
                ;;
        esac
    else
        case "$mode" in
            percentage) echo "0" ;;
            status) echo "?" ;;
            remain) echo "---" ;;
        esac
    fi
}

main() {
    local mode=$1
    local format=$2
    local bar_length=$3
    local os=$(get_os)
    
    if [[ "$mode" == "bar" ]]; then
        local percentage
        case "$os" in
            "osx")
                percentage=$(get_battery_osx "percentage")
                ;;
            "linux")
                percentage=$(get_battery_linux "percentage")
                ;;
            "freebsd")
                percentage=$(get_battery_freebsd "percentage")
                ;;
            "openbsd")
                percentage=$(get_battery_openbsd "percentage")
                ;;
            *)
                percentage="0"
                ;;
        esac
        value=$(percentage_to_bar "$percentage" "$bar_length")
    else
        case "$os" in
            "osx")
                value=$(get_battery_osx "$mode")
                ;;
            "linux")
                value=$(get_battery_linux "$mode")
                ;;
            "freebsd")
                value=$(get_battery_freebsd "$mode")
                ;;
            "openbsd")
                value=$(get_battery_openbsd "$mode")
                ;;
            *)
                case "$mode" in
                    percentage) value="0" ;;
                    status) value="?" ;;
                    remain) value="---" ;;
                esac
                ;;
        esac
    fi
    
    printf "$format" "$value"
}

main $@