#!/bin/bash



font="Hurmit Nerd Font Mono:style=medium:size=8"
icon="Hurmit Nerd Font Mono:style=medium:size=11"
height=24
sep="  "

theme="gruvbox"

case $theme in
    "dracula")
        color_bg="#282a36"
        color_fg="#f8f8f2"
        color_hl1="#6272a4"
        color_hl2="#bd93f9"
        ;;
    "gruvbox")
        color_bg="#282828"
        color_bgl="#3c3836"
        color_fg="#ebdbb2"
        color_hl1="#fabd2f"
        color_hl2="#d79921"
        color_alert="#cc241d"
        ;;
    *) # Default to Nord
        color_bg="#2e3440"
        color_fg="#eceff4"
        color_hl1="#5e81ac"
        color_hl2="#81a1c1"
        ;;
esac




function get_date() {
    date=`date +"%d %B"`
    time=`date +"%R"`
    echo "D%{A:notify-send date:}%{B$color_bgl} $date $time %{B-}%{A}"
}

function get_vol() {
    muted=$(pactl get-sink-mute @DEFAULT_SINK@ | awk '{print $2}')
    if [[ "$muted" == "yes" ]]; then
        vol="%{T2}婢%{T-} MUTE"
    else
        vol="%{T2}墳%{T-} $(pactl get-sink-volume @DEFAULT_SINK@ | awk '{print $5}')"
    fi
    echo "V%{A3:vol r:}%{A1:vol l:}$vol%{A}%{A}"
}

function get_bat() {
    ac=$(< /sys/class/power_supply/AC/online)
    bat=$(< /sys/class/power_supply/BAT0/capacity)

    if (( $ac == 1 )); then
        icon="ﮣ"
    elif (( $bat>90 )); then
        icon=""
    elif (( $bat > 80 )); then
        icon=""
    elif (( $bat > 70 )); then
        icon=""
    elif (( $bat > 60 )); then
        icon=""
    elif (( $bat > 50 )); then
        icon=""
    elif (( $bat > 40 )); then
        icon=""
    elif (( $bat > 30 )); then
        icon=""
    elif (( $bat > 20 )); then
        icon=""
    elif (( $bat > 10 )); then
        icon=""
    else
        icon=""
    fi
    echo "B%{T2}$icon%{T-} $bat%"
}

function get_net() {
    name=$(iwgetid -r)
    if [ $? -eq 0 ]; then
        echo 'N'"%{T2}直%{T-} $name"
    else
        echo 'N'"%{T2}睊%{T-}"
    fi
}

function music() {
    song=$(mpc current)
    echo "M%{T2}%{A1:mus_prev:} 玲%{A}%{A1:mus_play:} 懶 %{A}%{A1:mus_next:}怜 %{A}%{T-}  $song "
}

function get_active_win() {
    echo "W${1}$(xprop -id "$(bspc query -N -n .active -m $1)" WM_NAME | cut -d\" -f2)"
}


function get_tag() {
    desktops=$(bspc query -D --names -m $1)
    focused=$(bspc query -D -d .active -m $1 --names)
    occupied=$(bspc query -D -d .occupied -m $1 --names)
    declare -a stat
    for i in $desktops; do
        stat[$i]=""
    done
    for i in $occupied; do
        stat[$i]=""
    done
    stat[$focused]="%{F$color_hl1}%{F-}"
    out=""
    for i in ${stat[@]}; do
        out+=" $i"
    done
    echo "T${1}%{T2}%{B$color_bgl}$out %{B-}%{T-}"
}




BAR_FIFO="/tmp/bar-fifo"

rm $BAR_FIFO
mkfifo $BAR_FIFO

while true; do
    get_date
    sleep 30
done>$BAR_FIFO&

while true; do
    get_bat
    sleep 30
done>$BAR_FIFO&

while true; do
    get_net
    sleep 30
done>$BAR_FIFO&

while true; do
    get_vol
    sleep 0.1
done>$BAR_FIFO& 

for mon in $@; do
    while true; do
        get_active_win $mon
        bspc subscribe node -c 1 > /dev/null
    done>$BAR_FIFO&
    
    while true; do
        get_tag $mon
        bspc subscribe desktop -c 1 > /dev/null
    done>$BAR_FIFO& 
done


# Constantly read it, processing each line
while read -r line < $BAR_FIFO; do
    case $line in
        # Date
        D*)
            date="${line#?}";;

        # Network
        N*)
            net="${line#?}";;

        # Battery
        B*)
            bat="${line#?}";;

        # volume 
        V*)
            vol="${line#?}";;
       
       # active window title
        WeDP-1*)
            win1="${line/WeDP-1}";;
        
        WHDMI-1-0*)
            win2="${line/WHDMI-1-0}";;
        
        # Desktops
        TeDP-1*)
            tag1="${line/TeDP-1}";;

        THDMI-1-0*)
            tag2="${line/THDMI-1-0}";;

    esac

printf  "%s%s %s %s%s %s%s %s %s%s %s\n" \
        "%{S0}" \
        "%{l}$tag1" \
        "%{c}$win1"\
        "%{r}$vol$sep$bat$sep$net$sep$date" \
        "%{S1}" \
        "%{l}$tag2" \
        "%{c}$win2"\
        "%{r}$vol$sep$bat$sep$net$sep$date" \
        "%{B- F-}" 
done | \
    lemonbar \
         -f "$font" \
         -f "$icon" \
         -g ${width}x${height}+${x}+${y} \
         -n $name \
         -F $color_fg \
         -B $color_bg \
         -U $color_hl2 \
         -d
