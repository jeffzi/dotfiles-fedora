#!/bin/bash
export GOOGLE_ARGS='["--count", 5]'
export ROFI_SEARCH='googler'

rofi -modi blocks -blocks-wrap rofi-search -show blocks -lines 5 -eh 4
