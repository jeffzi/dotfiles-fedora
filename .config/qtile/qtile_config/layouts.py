"""Define qtile layouts."""
from libqtile.config import Match
from libqtile.layout import MonadThreeCol, Floating, Max

from . import theme

layouts = [
    MonadThreeCol(**theme.LAYOUT_DEFAULTS),
    Max(),
]

floating_layout = Floating(
    float_rules=Floating.default_float_rules + [Match(role="pop-up")],
    **theme.LAYOUT_DEFAULTS,
)
