"""Qtile config."""
import asyncio
import os
import subprocess

from libqtile import hook, qtile

import qtile_config


@hook.subscribe.client_new
async def _delayed_move(client):
    """Move windows that update their class or names themselves after a slight delay."""
    await asyncio.sleep(0.01)
    for group in groups:
        if any(m for m in group.matches if m.compare(client)):
            client.togroup(group.name)
            break


@hook.subscribe.startup_once
def _autostart():
    subprocess.call(os.path.expanduser("~/.config/qtile/autostart.sh"))


def _get_group(group_name: str):
    return qtile.groups_map[group_name]


async def _group_to_screen(group_name: str) -> None:
    _get_group(group_name).cmd_toscreen(0)
    while qtile.current_group.name != group_name:
        await asyncio.sleep(0.01)


async def _spawn_in_group(cmd: str, window_name: str, group_name: str) -> None:
    group = _get_group(group_name)
    group.cmd_toscreen(0)

    subprocess.Popen(os.path.expanduser(cmd).split())

    while not any(window_name in win.name for win in group.windows):
        await asyncio.sleep(0.01)


@hook.subscribe.startup_complete
async def _start_chrome_metamoki():
    with open(os.path.expanduser("~/qtile.log"), "wt") as f:
        f.write(str("~/.config/qtile/chrome_profile.sh jeffzi".split()))
    await _spawn_in_group(
        cmd="~/.config/qtile/chrome_profile.sh jeffzi",
        group_name="WWW",
        window_name="Chrome",
    )

    if qtile_config.is_working_hours():
        await _spawn_in_group(
            cmd="~/.config/qtile/chrome_profile.sh metamoki",
            group_name="DEV",
            window_name="Chrome",
        )
        await _spawn_in_group(
            cmd="code",
            window_name="Visual Studio Code",
            group_name="DEV",
        )
        _group_to_screen("CHAT")
    else:
        _group_to_screen("WWW")


mod = qtile_config.mod
terminal = qtile_config.TERMINAL
cursor_warp = True
follow_mouse_focus = False

groups = qtile_config.groups
floating_layout = qtile_config.floating_layout
layouts = qtile_config.layouts
screens = qtile_config.screens
widget_defaults = qtile_config.widget_defaults
extension_defaults = widget_defaults.copy()
keys = qtile_config.keys
mouse = qtile_config.mouse
