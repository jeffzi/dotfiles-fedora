"""Define qtile groups."""
import re
from datetime import datetime

from libqtile.config import DropDown, Group, Match, ScratchPad

# Type: What kind of window is it? A menu, a dialog, a tooltip, or something else?
# Command: xprop _NET_WM_WINDOW_TYPE | cut -d_ -f10

# role: What is the window's role? (Only useful for some programs. Usually blank.)
# Command: (xprop WM_WINDOW_ROLE )| cut -d\" -f2

# name: What is the window's class name?
# Command: xprop WM_CLASS | cut -d\" -f2

# class: What is the window's class?
# Command: xprop WM_CLASS | cut -d\" -f4

# title: What is written in the window's title bar?
# Command: xprop WM_NAME | cut -d\" -f2


def is_working_hours():
    """Check whether current time is in working hours."""
    now = datetime.now()
    weekday = now.weekday()
    is_workday = weekday >= 1 and weekday <= 4  # Tuesday to Friday
    return is_workday and now.hour >= 8 and now.hour <= 20


SCRATCHPAD_NAME = "SCRATCH"
groups = [
    Group("WWW", label="", layout="columns"),
    Group(
        "CHAT",
        label="聆",
        layout="columns",
        spawn="com.slack.Slack" if is_working_hours() else None,
        matches=[
            Match("Slack"),
            Match(wm_class=["zoom"]),
            Match(wm_class=["Microsoft Teams - Preview"]),
        ],
    ),
    Group("DEV", label="", layout="monadthreecol"),
    Group(
        "DB",
        label="",
        layout="monadthreecol",
        matches=[
            Match(wm_class="jetbrains-datagrip"),
            Match(wm_class="code", title=re.compile(r".*dbt.*")),
        ],
    ),
    Group(
        "MEDIA",
        label="兀",
        layout="max",
        matches=[
            Match(wm_class="mpv"),
            Match(wm_class="vlc"),
            Match(wm_instance_class="spotify"),
        ],
        spawn="com.spotify.Client --force-device-scale-factor=1.25",
    ),
    ScratchPad(
        SCRATCHPAD_NAME,
        [DropDown("kitty", "kitty", x=0, y=0, width=1, height=0.5, opacity=0.95)],
    ),
]
