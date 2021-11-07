#!/bin/bash
killall dunst
dunst -config ~/.config/dunst/dunstrc &

notify-send -t 1000 -u critical "Test message: critical test 1"
notify-send -t 1000 -u normal "Test message: normal test 2"
notify-send -t 1000 -u low "Test message: low test 3"
notify-send -t 1000 -u critical "Test message: critical test 4"
notify-send -t 1000 -u normal "Test message: normal test 5"
notify-send -t 1000 -u low "Test message: low test 6"
notify-send -t 1000 -u critical "Test message: critical test 7"
notify-send -t 1000 -u normal "Test message: normal test 8"
notify-send -t 1000 -u low "Test message: low test 9"