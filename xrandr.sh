#!/bin/bash
xrandr --newmode "1280x720p"  74.48  1280 1352 1432 1647  720 723 728 749  +HSync +Vsync
xrandr --addmode LVDS1 1280x720p
xrandr --addmode HDMI1 1280x720p
xrandr --output HDMI1 --mode 1280x720p
xrandr --output LVDS1 --mode 1280x720p
