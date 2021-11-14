"""Define qtile screens."""
import os

from libqtile import qtile, widget
from libqtile.bar import Bar
from libqtile.config import Screen

from . import theme
from .mouse import LEFT
from .widgets.cpu import ColoredCPU
from .widgets.memory import ColoredMemory


def _strip_app_name(txt: str) -> str:
    shortened = " - ".join(txt.split(" - ")[:-1])
    return shortened or txt


widgets = [
    widget.CurrentLayoutIcon(
        padding=0,
        scale=0.7,
        foreground=theme.FOCUSED_COLOR,
        custom_icon_paths=[os.path.expanduser("~/.config/qtile/icons")],
    ),
    widget.GroupBox(
        active=theme.WHITE,
        block_highlight_text_color=theme.FOCUSED_COLOR,
        disable_drag=True,
        fontsize=theme.BAR_SIZE - 5,
        highlight_color=theme.FOCUSED_COLOR,
        inactive=theme.GREY,
        margin_x=15,
        this_current_screen_border=theme.BG,
        this_screen_border=theme.MAGENTA,
        urgent_border=theme.URGENT_COLOR,
        urgent_text=theme.URGENT_COLOR,
    ),
    widget.TaskList(
        border=theme.FOCUSED_COLOR,
        borderwidth=1,
        font="FiraCode Nerd Font",
        margin=1,
        markup_normal=(
            f'<span foreground="{theme.UNFOCUSED_COLOR}" '
            + f'background="{theme.LIGHTER_DARK}">{{}}</span>'
        ),
        markup_focused=f'<span foreground="{theme.FOCUSED_COLOR}">{{}}</span>',
        max_title_width=512,
        parse_text=_strip_app_name,
        unfocused_border=theme.DARK_GREY,
        urgent_border=theme.URGENT_COLOR,
    ),
    widget.Clock(format="%B %d ~ %H:%M"),
    widget.Spacer(),
    widget.Mpris2(
        name="spotify",
        objname="org.mpris.MediaPlayer2.spotify",
        display_metadata=["xesam:artist", "xesam:title"],
        scroll_chars=None,
        stop_pause_text="",
        foreground=theme.UNFOCUSED_COLOR,
    ),
    widget.Systray(),
    widget.Sep(size_percent=60, linewidth=2, padding=10),
    widget.TextBox(text="﬙", foreground=theme.BLUE),
    ColoredCPU(
        foreground_alert=theme.URGENT_COLOR,
        format="{load_percent}%",
        mouse_callbacks={LEFT: lambda: qtile.cmd_spawn("kitty -e htop")},
        padding=0,
    ),
    widget.TextBox(text="", foreground=theme.BLUE),
    ColoredMemory(
        foreground_alert=theme.URGENT_COLOR,
        format="{MemUsed:.1f}GB",
        measure_mem="G",
        mouse_callbacks={LEFT: lambda: qtile.cmd_spawn("kitty -e htop")},
        padding=0,
    ),
]

screens = [Screen(top=Bar(widgets=widgets, size=theme.BAR_SIZE, background=theme.BG))]
