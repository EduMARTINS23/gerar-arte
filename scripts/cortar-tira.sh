#!/usr/bin/env bash
# Corta uma tira de carrossel (2 cards lado a lado) em dois cards 4:5 de 1080x1350.
# Uso: bash cortar-tira.sh <tira.png> <pasta-saida> <número-do-primeiro-card>
# Ex.: bash cortar-tira.sh tira2/codex.png final 3   -> final/card-03.png e final/card-04.png
set -euo pipefail
[ $# -eq 3 ] || { sed -n '2,4p' "$0"; exit 1; }
TIRA="$1"; SAIDA="$2"; N="$3"
[ -f "$TIRA" ] || { echo "não existe: $TIRA"; exit 1; }
mkdir -p "$SAIDA"
A="$SAIDA/card-$(printf '%02d' "$N").png"; B="$SAIDA/card-$(printf '%02d' $((N+1))).png"

if python3 -c 'import PIL' 2>/dev/null; then
  python3 - "$TIRA" "$A" "$B" <<'PY'
import sys
from PIL import Image
im=Image.open(sys.argv[1]).convert("RGB"); w,h=im.size; m=w//2
for box,dest in (((0,0,m,h),sys.argv[2]),((w-m,0,w,h),sys.argv[3])):
    c=im.crop(box); cw,ch=c.size
    if cw/ch>0.8: nw=round(ch*0.8); x=(cw-nw)//2; c=c.crop((x,0,x+nw,ch))
    else: nh=round(cw/0.8); y=(ch-nh)//2; c=c.crop((0,y,cw,y+nh))
    c.resize((1080,1350),Image.LANCZOS).save(dest)
PY
elif command -v sips >/dev/null; then
  w=$(sips -g pixelWidth "$TIRA" | awk '/pixelWidth/{print $2}'); h=$(sips -g pixelHeight "$TIRA" | awk '/pixelHeight/{print $2}')
  m=$((w/2))
  if [ $((m*5)) -gt $((h*4)) ]; then cw=$((h*4/5)); ch=$h; else cw=$m; ch=$((m*5/4)); fi
  y=$(( (h-ch)/2 )); dx=$(( (m-cw)/2 ))
  for i in 0 1; do
    dest=$([ $i = 0 ] && echo "$A" || echo "$B")
    sips -s format png -c "$ch" "$cw" --cropOffset "$y" $((i*(w-m)+dx)) "$TIRA" --out "$dest" >/dev/null
    sips -z 1350 1080 "$dest" >/dev/null
  done
else
  echo "precisa de Pillow (python3 -m pip install --user pillow) ou sips (macOS)"; exit 1
fi
echo "$A"; echo "$B"
