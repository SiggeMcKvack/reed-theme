#!/usr/bin/env python3
# Splits variable fonts into per-script woff2 files so browsers only fetch the scripts a page uses.
# Needs fonttools and brotli. Usage: tools/subset-fonts.py Font.ttf [...]
# Writes fonts/<name>-{latin,greek,cyrillic}.woff2, where <name> is the file name up to "[" or ".".
# Latin holds everything except Greek and Cyrillic, and its @font-face has no unicode-range.
import os
import re
import sys

from fontTools import subset
from fontTools.ttLib import TTFont

COMBINING = range(0x0300, 0x0370)
SCRIPTS = {
	"greek": [range(0x0370, 0x0400), range(0x1F00, 0x2000)],
	"cyrillic": [range(0x0400, 0x0530), range(0x1C80, 0x1C90), range(0x2DE0, 0x2E00), range(0xA640, 0xA6A0)],
}

out_dir = os.path.join(os.path.dirname(__file__), "..", "fonts")
for path in sys.argv[1:]:
	name = re.split(r"[\[.]", os.path.basename(path))[0]
	cmap = set(TTFont(path).getBestCmap())
	other = {c for ranges in SCRIPTS.values() for r in ranges for c in r}
	subsets = {"latin": cmap - other}
	for script, ranges in SCRIPTS.items():
		subsets[script] = cmap & ({c for r in ranges for c in r} | set(COMBINING))

	for script, unicodes in subsets.items():
		options = subset.Options()
		options.layout_features = ["*"]
		font = TTFont(path)
		subsetter = subset.Subsetter(options)
		subsetter.populate(unicodes=unicodes)
		subsetter.subset(font)
		font.flavor = "woff2"
		out = os.path.join(out_dir, f"{name}-{script}.woff2")
		font.save(out)
		print(f"{out}: {len(unicodes)} characters, {os.path.getsize(out) // 1024} KB")
