#!/usr/bin/env bash
# Monta o kit de referência visual de um cliente: logo, peças candidatas, curadoria.
# Uso:
#   bash montar-kit.sh status   <cliente>
#   bash montar-kit.sh logo     <cliente> <arquivo|url>
#   bash montar-kit.sh importar <cliente> <pasta|arquivo|url> [...]   -> candidatas/c01.png, c02.png...
#   bash montar-kit.sh aprovar  <cliente> c02=lancamento c05=depoimento ...   -> p01-lancamento.png ... + kit.txt
set -uo pipefail
source "$(dirname "$0")/_comum.sh"
carregar_config
ACAO="${1:-}"; SLUG="${2:-}"
[ -n "$ACAO" ] && [ -n "$SLUG" ] || { sed -n '2,7p' "$0"; exit 1; }
validar_slug "$SLUG"; shift 2
CLI="$PASTA_CLIENTES/$SLUG"; KIT="$CLI/referencias-visuais"; CAND="$KIT/candidatas"

# Próximo número livre para um prefixo (c ou p) numa pasta.
proximo() {
  local n; n=$(ls "$1" 2>/dev/null | sed -n "s/^$2\([0-9][0-9]*\).*\.png$/\1/p" | sort -n | tail -1)
  printf '%02d' $(( 10#${n:-0} + 1 ))
}

case "$ACAO" in
status)
  echo "cliente: $SLUG ($CLI)"
  [ -d "$CLI" ] || { echo "RESULTADO: cliente não cadastrado. Rodar a Parte B de entrevista.md."; exit 0; }
  PRONTO=1
  [ -f "$CLI/marca.md" ] && echo "  marca.md   ok" || { echo "  marca.md   falta (B1/B5)"; PRONTO=0; }
  [ -f "$CLI/logo.png" ] && echo "  logo.png   ok" || echo "  logo.png   falta (B2; sem ele a arte sai com logo inventado)"
  N=$(ls "$KIT"/p[0-9]*.png 2>/dev/null | wc -l | tr -d ' ')
  NC=$(ls "$CAND"/c[0-9]*.png 2>/dev/null | wc -l | tr -d ' ')
  echo "  kit        $N peça(s) aprovada(s), $NC candidata(s)"
  [ "$N" -ge 3 ] || PRONTO=0
  if [ -f "$KIT/estilo.md" ]; then
    grep -qi 'PROVISÓRIO' "$KIT/estilo.md" && echo "  estilo.md  ok (PROVISÓRIO)" || echo "  estilo.md  ok"
  else echo "  estilo.md  falta (B4)"; PRONTO=0; fi
  if [ -f "$KIT/estilo.md" ]; then
    for c in $(grep -oE '\b[a-z][0-9]{2,3}\b' "$KIT/estilo.md" | sort -u); do
      ls "$KIT/$c"-*.png "$KIT/$c".png >/dev/null 2>&1 || echo "  aviso: estilo.md cita $c, que não existe no kit"
    done
  fi
  if [ "$PRONTO" = 1 ]; then
    echo "RESULTADO: kit pronto"
    ls "$KIT"/p[0-9]*.png | xargs -n1 basename | sed 's/^/  /'
  else
    echo "RESULTADO: kit incompleto (mínimo: marca.md, 3 peças aprovadas e estilo.md). Rodar a Parte B de entrevista.md."
  fi
  ;;
logo)
  [ $# -eq 1 ] || { echo "uso: montar-kit.sh logo <cliente> <arquivo|url>"; exit 1; }
  mkdir -p "$CLI" && trazer_imagem "$1" "$CLI/logo.png" && echo "logo salvo em $CLI/logo.png"
  ;;
importar)
  [ $# -ge 1 ] || { echo "uso: montar-kit.sh importar <cliente> <pasta|arquivo|url> [...]"; exit 1; }
  mkdir -p "$CAND"
  LISTA=()
  for o in "$@"; do
    if [ -d "$o" ]; then
      while IFS= read -r f; do LISTA+=("$f"); done < <(find "$o" -maxdepth 2 -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.heic' \) | sort)
    else LISTA+=("$o"); fi
  done
  [ ${#LISTA[@]} -gt 0 ] || { echo "nenhuma imagem encontrada"; exit 1; }
  OK=0
  for o in "${LISTA[@]}"; do
    c="c$(proximo "$CAND" c)"
    if trazer_imagem "$o" "$CAND/$c.png"; then printf '%s\t%s\n' "$c" "$o" >> "$CAND/origens.txt"; echo "$c  $o"; OK=$((OK+1)); fi
  done
  echo "$OK candidata(s) em $CAND. Abrir cada uma, descrever e recomendar as do kit."
  ;;
aprovar)
  [ $# -ge 1 ] || { echo "uso: montar-kit.sh aprovar <cliente> c02=nome c05=nome ..."; exit 1; }
  [ -f "$KIT/kit.txt" ] || printf '# Kit de referência visual de %s. Peças publicadas pela designer da marca.\n# arquivo  # origem · data da curadoria\n' "$SLUG" > "$KIT/kit.txt"
  for par in "$@"; do
    c="${par%%=*}"; nome="${par#*=}"; [ "$nome" = "$par" ] && nome="peca"
    nome=$(printf '%s' "$nome" | iconv -f utf-8 -t ascii//TRANSLIT 2>/dev/null | tr '[:upper:]' '[:lower:]' | tr ' _' '--' | tr -cd 'a-z0-9-')
    [ -n "$nome" ] || nome="peca"
    [ -f "$CAND/$c.png" ] || { echo "não existe: $CAND/$c.png"; continue; }
    p="p$(proximo "$KIT" p)-$nome.png"
    cp "$CAND/$c.png" "$KIT/$p"
    orig=$(awk -F'\t' -v c="$c" '$1==c{print $2}' "$CAND/origens.txt" 2>/dev/null | tail -1)
    printf '%s  # %s · %s\n' "$p" "${orig:-?}" "$(date +%F)" >> "$KIT/kit.txt"
    echo "$c -> $p"
  done
  echo "kit: $(ls "$KIT"/p[0-9]*.png 2>/dev/null | wc -l | tr -d ' ') peça(s). Próximo: escrever estilo.md (B4)."
  ;;
*) sed -n '2,7p' "$0"; exit 1;;
esac
