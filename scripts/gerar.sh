#!/usr/bin/env bash
# Gera uma arte pelo Codex (image_gen) e/ou pela API da OpenAI (gpt-image-2), a partir do kit do cliente.
# Uso: bash gerar.sh --cliente <cliente> --prompt prompt.md --out <pasta> --ref logo.png --ref p01.png [...]
#                    [--so codex|api] [--size 1088x1360]
# Travas: exige estilo.md do cliente, pelo menos 3 peças do kit nas referências e no máximo 5 referências.
set -uo pipefail
source "$(dirname "$0")/_comum.sh"
carregar_config
PROMPT=""; OUT=""; SO=""; SIZE="1088x1360"; REFS=(); CLIENTE=""
while [ $# -gt 0 ]; do
  case "$1" in
    --prompt) PROMPT="$2"; shift 2;; --out) OUT="$2"; shift 2;;
    --ref) REFS+=("$2"); shift 2;; --cliente) CLIENTE="$2"; shift 2;;
    --so) SO="$2"; shift 2;; --size) SIZE="$2"; shift 2;;
    *) echo "argumento desconhecido: $1"; exit 1;;
  esac
done
[ -f "$PROMPT" ] && [ -n "$OUT" ] && [ ${#REFS[@]} -gt 0 ] || { echo "faltam --prompt (arquivo existente), --out ou --ref"; exit 1; }

# Trava do kit: arte sem as peças publicadas da designer sai genérica.
[ -n "$CLIENTE" ] || { echo "faltou --cliente <cliente>: a arte precisa do kit de referência do cliente"; exit 1; }
validar_slug "$CLIENTE"
KITDIR="$PASTA_CLIENTES/$CLIENTE/referencias-visuais"
[ -f "$KITDIR/estilo.md" ] || { echo "BLOQUEADO: $CLIENTE sem estilo.md em $KITDIR. Rodar a Parte B de entrevista.md."; exit 1; }
KITDIR="$(cd "$KITDIR" && pwd -P)"
# Conta peças diferentes do kit aprovado: referencias-visuais/pNN-*.png (candidatas e subpastas não contam).
VISTAS=" "
for r in "${REFS[@]}"; do
  [ -f "$r" ] || { echo "referência não existe: $r"; exit 1; }
  a="$(abs "$r")"
  [ "$(dirname "$a")" = "$KITDIR" ] || continue
  case "$(basename "$a")" in p[0-9]*.png) case "$VISTAS" in *" $(basename "$a") "*) ;; *) VISTAS="$VISTAS$(basename "$a") ";; esac;; esac
done
NKIT=$(echo $VISTAS | wc -w | tr -d ' ')
[ ${#REFS[@]} -le 5 ] || { echo "BLOQUEADO: ${#REFS[@]} referências. O image_gen aceita no máximo 5 (logo + kit + foto)."; exit 1; }
[ "$NKIT" -ge 3 ] || { echo "BLOQUEADO: só $NKIT peça(s) diferente(s) do kit de $CLIENTE nas referências. Mande pelo menos 3 arquivos pNN-*.png de $KITDIR (tabela do estilo.md)."; exit 1; }
LOGO="$PASTA_CLIENTES/$CLIENTE/logo.png"
if [ -f "$LOGO" ]; then case " $(for r in "${REFS[@]}"; do abs "$r"; done | tr '\n' ' ')" in *" $(abs "$LOGO") "*) ;; *) echo "aviso: o logo.png de $CLIENTE não está nas referências";; esac; fi

case "${SO:-$MOTOR}" in codex) USA_CODEX=1; USA_API=0;; api) USA_CODEX=0; USA_API=1;; ambos) USA_CODEX=1; USA_API=1;;
  *) echo "motor inválido: ${SO:-$MOTOR} (use codex, api ou ambos)"; exit 1;; esac
if [ "$USA_API" = 1 ]; then
  echo "$SIZE" | grep -Eq '^[0-9]+x[0-9]+$' || { echo "--size inválido: $SIZE"; exit 1; }
  w=${SIZE%x*}; h=${SIZE#*x}
  [ $((w % 16)) -eq 0 ] && [ $((h % 16)) -eq 0 ] || { echo "--size precisa ser múltiplo de 16 (4:5 = 1088x1360)"; exit 1; }
  [ -n "${OPENAI_API_KEY:-}" ] || { echo "api: OPENAI_API_KEY não definida (config.env ou ambiente)"; exit 1; }
fi
[ "$USA_CODEX" = 0 ] || command -v codex >/dev/null || { echo "codex não instalado: npm i -g @openai/codex@latest && codex login"; exit 1; }

mkdir -p "$OUT"; OUT="$(cd "$OUT" && pwd -P)"
PROMPT="$(abs "$PROMPT")"

# A API rejeita WebP/HEIC com extensão errada: tudo que não for PNG de verdade vira PNG.
FIX=()
for r in "${REFS[@]}"; do
  if e_png "$r"; then FIX+=("$(abs "$r")")
  else t="$OUT/.ref-$(basename "${r%.*}").png"; para_png "$r" "$t" || exit 1; FIX+=("$t"); fi
done

roda_api() {
  local args=(); for r in "${FIX[@]}"; do args+=(-F "image[]=@$r"); done
  curl -sS https://api.openai.com/v1/images/edits -H "Authorization: Bearer $OPENAI_API_KEY" \
    -F model="$MODELO_API" -F size="$SIZE" -F quality=high -F "prompt=<$PROMPT" "${args[@]}" -o "$OUT/.api.json" \
    || { echo "api: falha de rede"; return 1; }
  python3 - "$OUT" <<'PY'
import json,base64,sys,os
o=sys.argv[1]; raw=open(f"{o}/.api.json").read(); os.remove(f"{o}/.api.json")
try: d=json.loads(raw)
except ValueError: print("api: resposta inválida:", raw[:300]); sys.exit(1)
if "error" in d: print("api: ERRO", d["error"].get("message")); sys.exit(1)
open(f"{o}/api.png","wb").write(base64.b64decode(d["data"][0]["b64_json"]))
print("api: ok", f"{o}/api.png", "| tokens de imagem:", d.get("usage",{}).get("output_tokens","?"))
PY
}

roda_codex() {
  local args=() lista=""
  for r in "${FIX[@]}"; do args+=(-i "$r"); lista="$lista\"$r\", "; done
  { printf 'Gere UMA arte com a ferramenta nativa image_gen (nunca HTML, SVG, Canvas ou código).\nOBRIGATÓRIO: chame o image_gen com referenced_image_paths contendo EXATAMENTE estes arquivos, nesta ordem (são as referências do brief): [%s]. Não use num_last_images_to_include. Não omita nenhuma referência.\nSalve o PNG final em %s/codex.png e responda só com o caminho.\n\nBRIEF:\n\n' "$lista" "$OUT"; cat "$PROMPT"; } \
    | env -u OPENAI_API_KEY codex exec --skip-git-repo-check -s workspace-write -C "$OUT" "${args[@]}" - > "$OUT/.codex.log" 2>&1
  # No Linux o sandbox do Codex pode bloquear a cópia final: resgata a imagem que ele informa no log.
  if [ ! -f "$OUT/codex.png" ]; then
    local g; g=$(grep -o '/[^ `"]*generated_images/[^ `"]*\.png' "$OUT/.codex.log" 2>/dev/null | tail -1)
    [ -n "$g" ] && [ -f "$g" ] && cp "$g" "$OUT/codex.png" && echo "codex: imagem resgatada de $g"
  fi
  [ -f "$OUT/codex.png" ] || { echo "codex: FALHOU, log em $OUT/.codex.log"; grep -m3 -i error "$OUT/.codex.log"; return 1; }
  # Confere no registro da sessão que o image_gen recebeu cada peça do kit.
  local sess; sess=$(ls -t "$HOME"/.codex/sessions/*/*/*/*.jsonl 2>/dev/null | head -5 | xargs grep -l "$OUT" 2>/dev/null | head -1)
  if [ -z "$sess" ]; then
    echo "codex: ok $OUT/codex.png (aviso: não achei o registro da sessão para confirmar as referências)"
  else
    local falta=0 i b
    for i in "${!REFS[@]}"; do case "$(abs "${REFS[$i]}")" in "$KITDIR"/*)
      b="$(basename "${FIX[$i]}")"
      grep -q "referenced_image_paths[^]]*$b" "$sess" || { echo "codex: referência do kit NÃO enviada ao image_gen: $b"; falta=1; };; esac; done
    if [ "$falta" = 1 ]; then mv "$OUT/codex.png" "$OUT/codex-sem-referencia.png"; echo "codex: DESCARTADO (kit não foi usado). Rode de novo."; return 1; fi
    echo "codex: ok $OUT/codex.png (kit confirmado no image_gen)"
  fi
  rm -f "$OUT/.codex.log"
}

PIDS=()
[ "$USA_API" = 1 ] && { roda_api & PIDS+=($!); }
[ "$USA_CODEX" = 1 ] && { echo "codex: gerando (2 a 3 min)..."; roda_codex & PIDS+=($!); }
ERRO=0; for p in "${PIDS[@]}"; do wait "$p" || ERRO=1; done
rm -f "$OUT"/.ref-*.png
exit $ERRO
