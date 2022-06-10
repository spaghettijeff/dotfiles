[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources 
xrandr --setprovideroutputsource NVIDIA-G0 modesetting &
xrandr --auto &
sxhkd &
slstatus &
xrdb ~/.Xresources &
picom --experimental-backends &
unclutter &
syncthing > /dev/null 2>&1 &
mconnect -d &
mpd &
mpDris2 &
nitrogen --restore &

export DESKTOP_SESSION="bspwm"
exec bspwm
#exec dwm
