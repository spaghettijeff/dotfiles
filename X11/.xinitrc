[[ -f ~/.Xresources ]] && xrdb -merge -I$HOME ~/.Xresources

xrandr --setprovideroutputsource NVIDIA-G0 modesetting &
xrandr --auto &
slstatus &
sxhkd &
xrdb ~/.Xresources &
picom &
unclutter &
feh --no-fehbg --bg-fill '/home/jeff/images/wallpapers/526874.jpg' &

exec dwm > ~/.dwm.log
#exec xmonad
