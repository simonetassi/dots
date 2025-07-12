#!/usr/bin/env bash
# credits to: https://github.com/luispabon
op=$( echo -e " Poweroff\n Reboot\n Suspend\n Lock\n Logout" | wofi --width 250 --height 210 -i --dmenu | awk '{print tolower($2)}' )

case $op in 
        poweroff)
                ;&
        reboot)
                ;&
        suspend)
                systemctl $op
                ;;
        lock)
		            loginctl lock-session
                ;;
        logout)
                swaymsg exit
                ;;
esac
