#!/usr/bin/env python3
# adapted from
# - https://github.com/albertlauncher/python/blob/master/copyq/__init__.py
# - https://github.com/cjbassi/rofi-copyq/blob/master/rofi-copyq
import json
import subprocess


def copyq_get_all():
    script = r"""
    var result=[];
    for ( var i = 0; i < size(); ++i ) {
        var obj = {};
        obj.row = i;
        obj.mimetypes = str(read("?", i)).split("\n");
        obj.mimetypes.pop();
        obj.text = str(read(i));
        result.push(obj);
    }
    JSON.stringify(result);
    """
    proc = subprocess.run(["copyq", "-"], input=script.encode(), stdout=subprocess.PIPE)
    return json.loads(proc.stdout.decode())


def main():
    items = (
        " ".join(filter(None, json_obj["text"].splitlines()))
        for json_obj in copyq_get_all()
    )
    proc = subprocess.run(
        "rofi -dmenu -i -p  -format i".split(),
        input="\n".join(x for x in items),
        encoding="utf-8",
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    if proc.returncode == 0:
        selection = proc.stdout.strip()
        subprocess.run(
            f"copyq select({selection});".split(),
            encoding="utf-8",
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
        )


if __name__ == "__main__":
    main()
