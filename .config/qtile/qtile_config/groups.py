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
    is_workday = now.weekday() <= 4  # Monday to Friday
    return is_workday and now.hour >= 8 and now.hour <= 20


SCRATCHPAD_NAME = "SCRATCH"
SIDE_MONITOR_GROUP = "SIDE"

groups = [
    Group(
        SIDE_MONITOR_GROUP,
        label="聆",
        layout="max",
        matches=[
            Match("Slack"),
            Match(wm_class=["discord"]),
            Match(wm_class=["zoom"]),
            Match(wm_class=["Microsoft Teams - Preview"]),
            Match(wm_instance_class="spotify"),
        ],
        spawn="com.slack.Slack" if is_working_hours() else None,
        screen_affinity=0
    ),
    Group("WWW", label="", layout="columns", screen_affinity=1),
    Group("DEV", label="", layout="monadthreecol", screen_affinity=1),
    Group(
        "DB",
        label="",
        layout="monadthreecol",
        matches=[
            Match(wm_class="jetbrains-datagrip"),
            Match(wm_class="code", title=re.compile(r".*dbt.*")),
        ],
        screen_affinity=1,
    ),
    Group(
        "MEDIA",
        label="兀",
        layout="max",
        matches=[
            Match(wm_class="mpv"),
            Match(wm_class="vlc"),
        ],
        spawn="com.spotify.Client --force-device-scale-factor=1.2",
        screen_affinity=1,
    ),
    ScratchPad(
        SCRATCHPAD_NAME,
        [DropDown("kitty", "kitty", x=0, y=0, width=1, height=0.5, opacity=0.95)],
        single=True,
    ),
]

main_groups = [group for group in groups if group.name != SIDE_MONITOR_GROUP]
