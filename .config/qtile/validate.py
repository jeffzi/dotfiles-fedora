#!/usr/bin/env python
"""Validate qtile config."""
from pathlib import Path

import typer
from libqtile.confreader import Config

app = typer.Typer(add_completion=False)


@app.command()
def _validate(
    conf_path: Path = typer.Argument(  # noqa: B008
        ...,
        file_okay=True,
        dir_okay=False,
        readable=True,
        resolve_path=True,
        exists=True,
        help="Config path",
    )
):
    """Validate qtile config."""
    config = Config(str(conf_path))
    config.load()
    config.validate()


if __name__ == "__main__":
    app()
