"""Define qtile layouts."""
from libqtile.config import Match
from libqtile.layout import Columns, Floating, Max

from . import theme
from .monadthreecol import MonadThreeCol

layouts = [
    Columns(num_columns=2, **theme.LAYOUT_DEFAULTS),
    MonadThreeCol(main_centered=True, **theme.LAYOUT_DEFAULTS),
    Max(),
]

floating_layout = Floating(
    float_rules=Floating.default_float_rules + [Match(role="pop-up")],
    **theme.LAYOUT_DEFAULTS,
)
