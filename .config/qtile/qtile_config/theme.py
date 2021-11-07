"""qtile theme."""
BLACK = "#000000"
LIGHTER_DARK = "#212121"
LIGHT_DARK = "#121212"
RED = "#F07178"
GREEN = "#C3E88D"
YELLOW = "#FFCB6B"
BLUE = "#82AAFF"
MAGENTA = "#C792EA"
CYAN = "#89DDFF"
WHITE = "#FFFFFF"
GREY = "#65737E"
DARK_GREY = "#474C4F"
ORANGE = "#F78C6C"

BG = BLACK
FG = WHITE
FOCUSED_COLOR = YELLOW
UNFOCUSED_COLOR = GREY
URGENT_COLOR = RED

DEFAULT_FONT = "FiraCode Nerd Font"

FONT = DEFAULT_FONT
BAR_SIZE: int = 30

LAYOUT_DEFAULTS = {
    "margin": 5,
    "border_focus": BLACK,
    "border_normal": DARK_GREY,
}

widget_defaults = {
    "font": DEFAULT_FONT,
    "fontsize": 20,
    "foreground": WHITE,
    "background": BG,
}
