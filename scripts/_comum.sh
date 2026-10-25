# Carregado pelos outros scripts. Nada aqui é específico de uma pessoa: tudo vem do config.env.
GA_HOME="${GERAR_ARTE_HOME:-$HOME/.gerar-arte}"
GA_CONFIG="$GA_HOME/config.env"

carregar_config() {
  [ -f "$GA_CONFIG" ] || { echo "SEM CONFIGURAÇÃO: $GA_CONFIG não existe. Rode a Parte A de entrevista.md."; exit 1; }
  set -a; . "$GA_CONFIG"; set +a
  MOTOR="${MOTOR:-codex}"; MODELO_API="${MODELO_API:-gpt-image-2}"
  [ -n "${PASTA_CLIENTES:-}" ] || { echo "PASTA_CLIENTES não definida em $GA_CONFIG"; exit 1; }
  case "$PASTA_CLIENTES" in "~"*) PASTA_CLIENTES="$HOME${PASTA_CLIENTES#\~}";; esac
}

# O cliente é o nome da pasta dele dentro de PASTA_CLIENTES. Aceita espaço e acento; recusa caminho.
validar_slug() {
  case "$1" in ""|.*|-*|*/*) echo "nome de cliente inválido: '$1' (é o nome da pasta do cliente, sem barra; ex.: padaria-sao-jorge ou \"Padaria São Jorge\")"; exit 1;; esac
}

# Caminho absoluto, resolvendo links (no macOS /tmp aponta para /private/tmp).
abs() { (cd "$(dirname "$1")" 2>/dev/null && printf '%s/%s\n' "$(pwd -P)" "$(basename "$1")"); }

e_png() { file -b "$1" 2>/dev/null | grep -q '^PNG image'; }

# Converte qualquer imagem (WebP, JPG, HEIC, PNG com extensão errada) para PNG de verdade.
para_png() {
  if command -v sips >/dev/null 2>&1 && sips -s format png "$1" --out "$2" >/dev/null 2>&1; then return 0; fi
  if python3 -c 'import sys; from PIL import Image; Image.open(sys.argv[1]).save(sys.argv[2], "PNG")' "$1" "$2" 2>/dev/null; then return 0; fi
  if command -v magick >/dev/null 2>&1 && magick "$1" "$2" 2>/dev/null; then return 0; fi
  echo "não consegui converter $1 para PNG. Instale o Pillow: python3 -m pip install --user pillow" >&2
  return 1
}

# Copia origem (arquivo local ou URL http/https) para destino em PNG.
trazer_imagem() {
  local origem="$1" destino="$2" tmp
  tmp="$(mktemp -t gerar-arte-XXXXXX)"
  case "$origem" in
    http://*|https://*) curl -fsSL "$origem" -o "$tmp" || { echo "falhou o download: $origem" >&2; rm -f "$tmp"; return 1; };;
    *) [ -f "$origem" ] || { echo "arquivo não existe: $origem" >&2; rm -f "$tmp"; return 1; }; cp "$origem" "$tmp";;
  esac
  file -b "$tmp" | grep -Eqi 'image|bitmap|ISO Media' || { echo "não é imagem: $origem" >&2; rm -f "$tmp"; return 1; }
  if e_png "$tmp"; then mv "$tmp" "$destino"; else para_png "$tmp" "$destino"; local r=$?; rm -f "$tmp"; return $r; fi
}
