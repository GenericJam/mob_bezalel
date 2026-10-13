"""Cut mob_bezalel's static fonts from the Google Fonts variable sources.

For each weight: instance the variable font, remove overlapping contours
(Android's renderer drops parts of overlapping simple-glyph contours: the left
stem of Instrument Sans "H" went missing), clear the OVERLAP_SIMPLE flags, and
set the PostScript name to the file name (the iOS font token must match it).

Usage:

    python3 -m venv /tmp/fontvenv
    /tmp/fontvenv/bin/pip install fonttools skia-pathops
    /tmp/fontvenv/bin/python scripts/cut_fonts.py /tmp/fontsrc priv/fonts

where /tmp/fontsrc holds, from https://github.com/google/fonts/tree/main/ofl:
ebgaramond/EBGaramond[wght].ttf, ebgaramond/EBGaramond-Italic[wght].ttf,
instrumentsans/InstrumentSans[wdth,wght].ttf, frankruhllibre/FrankRuhlLibre[wght].ttf
"""
import pathlib
import sys

from fontTools.ttLib import TTFont
from fontTools.ttLib.removeOverlaps import removeOverlaps
from fontTools.varLib import instancer

src = pathlib.Path(sys.argv[1])
out = pathlib.Path(sys.argv[2])

jobs = [("ebgaramond/EBGaramond[wght].ttf", {"wght": w}, f"EBGaramond-{n}")
        for w, n in [(400, "Regular"), (500, "Medium"), (600, "SemiBold")]]
jobs += [("ebgaramond/EBGaramond-Italic[wght].ttf", {"wght": 400}, "EBGaramond-Italic")]
jobs += [("instrumentsans/InstrumentSans[wdth,wght].ttf", {"wght": w, "wdth": 100}, f"InstrumentSans-{n}")
         for w, n in [(400, "Regular"), (500, "Medium"), (600, "SemiBold")]]
jobs += [("frankruhllibre/FrankRuhlLibre[wght].ttf", {"wght": w}, f"FrankRuhlLibre-{n}")
         for w, n in [(400, "Regular"), (500, "Medium")]]

for path, axes, name in jobs:
    font = instancer.instantiateVariableFont(TTFont(src / path), axes, updateFontNames=True)
    removeOverlaps(font)
    for glyph in font["glyf"].glyphs.values():
        if hasattr(glyph, "flags") and len(glyph.flags):
            glyph.flags[0] &= ~0x40  # OVERLAP_SIMPLE
    for rec in font["name"].names:
        if rec.nameID == 6:
            rec.string = name
    font.save(out / f"{name}.ttf")
    print(name, (out / f"{name}.ttf").stat().st_size // 1024, "KB")
