"""Define qtile mouse."""
from libqtile.config import Click, Drag
from libqtile.lazy import lazy

from .keys import MOD

LEFT = BUTTON1 = "Button1"
MIDDLE = BUTTON2 = "Button2"
RIGHT = BUTTON3 = "Button3"
WHEEL_UP = BUTTON4 = "Button4"
WHEEL_DOWN = BUTTON5 = "Button5"
WHEEL_LEFT = BUTTON6 = "Button6"
WHEEL_RIGHT = BUTTON7 = "Button7"
PREVIOUS = BUTTON8 = "Button8"
NEXT = BUTTON9 = "Button9"


mouse = [
    Drag(
        [MOD],
        LEFT,
        lazy.window.set_position_floating(),
        start=lazy.window.get_position(),
    ),
    Drag(
        [MOD],
        RIGHT,
        lazy.window.set_size_floating(),
        start=lazy.window.get_size(),
    ),
    Click([MOD], MIDDLE, lazy.window.bring_to_front()),
]
