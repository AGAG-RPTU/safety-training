#!/bin/sh
# Turn the official floor-plan PDF into img/floorplan-48-4.png without
# people's names: every text line in the plan that is not a room number
# or a room type is redacted, then the plan is cropped out of the A0 page
# and the leftover room list above it is painted over.
#
# Usage: tools/floorplan.sh flur48-4a.pdf
# Needs mutool (MuPDF), python3, ImageMagick.

set -eu
in=$1
out=img/floorplan-48-4.png
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mutool draw -q -F stext -o "$tmp/page.stext" "$in"

python3 -I - "$tmp/page.stext" > "$tmp/rects.json" <<'PY'
import sys, re, json, xml.etree.ElementTree as ET
KEEP = {"Rechnerraum", "(FB Mathematik)", "Werkstatt (CTM)", "Teeküche", "Seminarraum",
        "Gebäude-", "reinigung", "WC", "Herren", "Damen", "Besprechungsraum",
        "(Sekretariat)", "Gäste AGAG", "Gäste SFB/TRR 195"}
PLAN_TOP = 1500  # pt; the plan lies below the room list
keep, drop = [], []
for line in ET.parse(sys.argv[1]).iter('line'):
    txt = ''.join(c.get('c') for c in line.iter('char')).strip()
    b = [float(v) for v in line.get('bbox').split()]
    if b[1] < PLAN_TOP:
        continue
    kept = txt in KEEP or re.fullmatch(r'\d{3}(/\d{3})?', txt)
    (keep if kept else drop).append(b)

# Some names overlap the room number below them; stop the redaction box
# above the number so the number survives.
def overlaps(r, k):
    return r[0] < k[2] and k[0] < r[2] and r[1] < k[3] and k[1] < r[3]
rects = []
for b in drop:
    r = [b[0] - 1, b[1] - 1, b[2] + 1, b[3] + 1]
    for k in keep:
        if overlaps(r, k):
            r[3] = k[1] - 6
    rects.append(r)
print(json.dumps(rects))
PY

cat > "$tmp/redact.js" <<'JS'
var rects = JSON.parse(readFile(scriptArgs[2]).asString());
var doc = Document.openDocument(scriptArgs[0]);
var page = doc.loadPage(0);
for (var i = 0; i < rects.length; i++)
  page.createAnnotation("Redact").setRect(rects[i]);
page.applyRedactions(false);
doc.save(scriptArgs[1], "garbage,compress");
JS
mutool run "$tmp/redact.js" "$in" "$tmp/clean.pdf" "$tmp/rects.json"

# Crop and cover-up boxes in pixels at 150 dpi (= 5 x the 30 dpi preview)
mutool draw -q -r 150 -o "$tmp/clean.png" "$tmp/clean.pdf"
magick "$tmp/clean.png" -crop 3325x2875+1050+3175 +repage \
  -fill white -draw "rectangle 0,0 2125,1600" \
  -colors 64 "$out"
