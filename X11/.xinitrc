[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources 
xrandr --setprovideroutputsource NVIDIA-G0 modesetting &
xrandr --auto &

emacs --daemon &
./.config/polybar/launch.sh &
mconnect -d &
picom &
syncthing > /dev/null 2>&1 &
mpd &
unclutter &
mpDris2 &
nitrogen --restore &
xrdb ~/.Xresources &

export DESKTOP_SESSION="bspwm"
sxhkd &
exec dbus-launch --exit-with-session bspwm
