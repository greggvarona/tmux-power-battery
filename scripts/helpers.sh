set_tmux_option() {
    local option="$1"
    local value="$2"
    tmux set-option -gq "$option" "$value"
}

get_tmux_option() {
    local option=$1
    local default_value=$2
    local option_value="$(tmux show-option -gqv "$option")"

    [[ -z "$option_value" ]] && echo $default_value || echo $option_value
}

get_os() {
    case "$OSTYPE" in
        linux*)   echo "linux" ;;
        darwin*)  echo "osx" ;;
        solaris*) echo "solaris" ;;
        freebsd*) echo "freebsd" ;;
        netbsd*)  echo "netbsd" ;;
        openbsd*) echo "openbsd" ;;
        bsd*)     echo "bsd" ;;
        msys*)    echo "windows" ;;
        *)        echo "unknown" ;;
    esac
}

percentage_to_bar() {
    local percentage=$1
    local length=${2:-10}
    local filled=$(( percentage * length / 100 ))
    local empty=$(( length - filled ))
    
    printf '█%.0s' $(seq 1 $filled)
    printf '░%.0s' $(seq 1 $empty)
}

format_time() {
    local minutes=$1
    local hours=$(( minutes / 60 ))
    local mins=$(( minutes % 60 ))
    
    if [ $hours -gt 0 ]; then
        printf "%dh%02dm" $hours $mins
    else
        printf "%dm" $mins
    fi
}