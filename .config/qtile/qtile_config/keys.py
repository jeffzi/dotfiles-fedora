"""Define qtile keys."""
import os

from libqtile.config import Key
from libqtile.lazy import lazy

from .groups import SCRATCHPAD_NAME, groups

ALT = "mod1"
HYPER = "mod3"
MOD = SUPER = "mod4"
SHIFT = "shift"
CONTROL = "control"
TAB = "Tab"
SPACE = "space"
RETURN = "Return"
BACKSPACE = "BackSpace"
LEFT = "Left"
RIGHT = "Right"
UP = "Up"
DOWN = "Down"
PAGE_UP = "Page_Up"
PAGE_DOWN = "Page_Down"

MEDIA_CMD = (
    "dbus-send --print-reply --dest=org.mpris.MediaPlayer2.spotify "
    "/org/mpris/MediaPlayer2 org.mpris.MediaPlayer2.Player."
)


def _next_prev(action):
    def _spawn(qtile):
        qtile.cmd_spawn(MEDIA_CMD + action)

    return _spawn


keys = [
    # essentials
    Key([MOD], RETURN, lazy.spawn("kitty -e fish")),
    Key([MOD], SPACE, lazy.spawn(os.path.expanduser("~/.config/rofi/rofi.sh"))),
    Key([MOD], "c", lazy.spawn(os.path.expanduser("~/.config/rofi/rofi-copyq.py"))),
    Key([MOD], "s", lazy.spawn(os.path.expanduser("~/.config/rofi/rofi-search.sh"))),
    Key([MOD], TAB, lazy.next_layout(), desc="Toggle through layouts"),
    # audio
    Key(
        [],
        "XF86AudioRaiseVolume",
        lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ +5%"),
    ),
    Key(
        [],
        "XF86AudioLowerVolume",
        lazy.spawn("pactl set-sink-volume @DEFAULT_SINK@ -5%"),
    ),
    Key([], "XF86AudioPlay", lazy.spawn(MEDIA_CMD + "PlayPause")),
    Key([], "XF86AudioNext", lazy.function(_next_prev("Next"))),
    Key([], "XF86AudioPrev", lazy.function(_next_prev("Previous"))),
    Key([MOD], "Tab", lazy.next_layout(), desc="Toggle through layouts"),
    # qtile
    Key([MOD, SHIFT], "r", lazy.restart(), desc="Restart Qtile"),
    Key([MOD, SHIFT], "q", lazy.shutdown(), desc="Shutdown Qtile"),
    # group controls
    Key([MOD], PAGE_UP, lazy.screen.prev_group(skip_managed=True)),
    Key([MOD], PAGE_DOWN, lazy.screen.next_group(skip_managed=True)),
    # window controls
    Key(
        [MOD],
        DOWN,
        lazy.layout.down(),
        desc="Move focus down in current stack pane",
    ),
    Key(
        [MOD],
        UP,
        lazy.layout.up(),
        desc="Move focus up in current stack pane",
    ),
    Key([MOD], LEFT, lazy.layout.left(), desc="Move focus to left"),
    Key([MOD], RIGHT, lazy.layout.right(), desc="Move focus to right"),
    Key([MOD], DOWN, lazy.layout.down(), desc="Move focus down"),
    Key([MOD], UP, lazy.layout.up(), desc="Move focus up"),
    Key(
        [MOD, "shift"], LEFT, lazy.layout.shuffle_left(), desc="Move window to the left"
    ),
    Key(
        [MOD, "shift"],
        RIGHT,
        lazy.layout.shuffle_right(),
        desc="Move window to the right",
    ),
    Key(
        [MOD, "shift"],
        DOWN,
        lazy.layout.shuffle_down(),
        desc="Move window down",
    ),
    Key(
        [MOD, "shift"],
        UP,
        lazy.layout.shuffle_up(),
        desc="Move window up",
    ),
    Key(
        [MOD, CONTROL],
        LEFT,
        lazy.layout.shrink_main(),
        desc="Grow window to the left",
    ),
    Key(
        [MOD, CONTROL],
        RIGHT,
        lazy.layout.grow_main(),
        desc="Grow window to the right",
    ),
    Key(
        [MOD, CONTROL],
        DOWN,
        lazy.layout.grow(),
        desc="Grow window down",
    ),
    Key(
        [MOD, CONTROL],
        UP,
        lazy.layout.shrink(),
        desc="Grow window up",
    ),
    Key([MOD], "m", lazy.layout.normalize(), desc="Maximize window"),
    Key([MOD], "n", lazy.layout.normalize(), desc="Reset all window sizes"),
    Key([MOD], BACKSPACE, lazy.window.kill()),
    Key(
        [MOD, SHIFT],
        "f",
        lazy.window.toggle_floating(),
        desc="toggle floating",
    ),
    Key([MOD], "f", lazy.window.toggle_fullscreen(), desc="toggle fullscreen"),
    # Stack controls
    Key(
        [MOD, SHIFT],
        "space",
        lazy.layout.toggle_split(),
        desc="Toggle between split and unsplit sides of stack",
    ),
]

for i, group in enumerate(groups, 1):
    keys.extend(
        [
            Key(
                [MOD],
                str(i),
                lazy.group[group.name].toscreen(),
                desc=f"Switch to group {group.name}",
            ),
            Key(
                [MOD, SHIFT],
                str(i),
                lazy.window.togroup(group.name, switch_group=True),
                desc=f"Switch to & move focused window to group {group.name}",
            ),
        ]
    )

keys.append(
    Key(
        [MOD],
        "grave",
        lazy.group[SCRATCHPAD_NAME].dropdown_toggle("kitty"),
        "Quake-style console",
    )
)

mod = MOD
