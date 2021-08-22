"""Define qtile screens."""
from libqtile import qtile, widget
from libqtile.bar import Bar
from libqtile.config import Screen
import os
from . import theme
from .mouse import LEFT

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
        font=theme.FONT,
        icon_size=0,
        margin=1,
        markup_normal=(
            f'<span foreground="{theme.UNFOCUSED_COLOR}" '
            + f'background="{theme.LIGHTER_DARK}">{{}}</span>'
        ),
        markup_focused=f'<span foreground="{theme.FOCUSED_COLOR}">{{}}</span>',
        max_title_width=512,
        unfocused_border=theme.DARK_GREY,
        urgent_border=theme.URGENT_COLOR,
    ),
    widget.Clock(format="%B %d ~ %H:%M"),
    widget.Spacer(),
    widget.Mpris2(
        font=theme.FONT,
        name="spotify",
        objname="org.mpris.MediaPlayer2.spotify",
        display_metadata=["xesam:artist", "xesam:title"],
        scroll_chars=None,
        stop_pause_text="",
    ),
    widget.Systray(),
    widget.Pomodoro(
        color_active=theme.FOCUSED_COLOR,
        color_break=theme.URGENT_COLOR,
        color_inactive=theme.UNFOCUSED_COLOR,
        font=theme.FONT,
        prefix_active=" ",
        prefix_break=" ",
        prefix_inactive="",
        prefix_long_break="",
        prefix_paused="",
    ),
    widget.Sep(size_percent=60, linewidth=2, padding=10),
    widget.Memory(
        padding=10,
        format="{MemUsed:.1f}GB",
        measure_mem="G",
        mouse_callbacks={LEFT: lambda: qtile.cmd_spawn("kitty -e htop")},
    ),
    widget.CPU(
        format="{load_percent}%",
        mouse_callbacks={LEFT: lambda: qtile.cmd_spawn("kitty -e htop")},
    ),
    widget.NvidiaSensors(
        format="{perf}",
        mouse_callbacks={LEFT: lambda: qtile.cmd_spawn("nvidia-settings")},
    ),
]

screens = [Screen(top=Bar(widgets=widgets, size=theme.BAR_SIZE, background=theme.BG))]
