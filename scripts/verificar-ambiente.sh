#!/usr/bin/env bash
# Mostra o que está instalado e configurado para gerar arte, e o que falta.
# Uso: bash verificar-ambiente.sh [--instalar-regra-codex]
set -uo pipefail
source "$(dirname "$0")/_comum.sh"
AGENTS="$HOME/.codex/AGENTS.md"

if [ "${1:-}" = "--instalar-regra-codex" ]; then
  if grep -qs 'image_gen' "$AGENTS"; then echo "regra já existe em $AGENTS"; exit 0; fi
  mkdir -p "$(dirname "$AGENTS")"
  cat >> "$AGENTS" <<'MD'

## Arte e imagem (regra da skill gerar-arte)

Sempre que o pedido for arte, criativo, post, banner, capa, thumbnail, mockup ou qualquer imagem: gere com a ferramenta nativa `image_gen`. Nunca monte a arte em HTML, CSS, SVG, Canvas, Python/PIL ou qualquer código renderizado em print. Imagens anexadas ao pedido são referência visual e devem ser passadas ao `image_gen`. Ao terminar, copie o PNG gerado para o caminho pedido e informe o caminho.
MD
  echo "regra instalada em $AGENTS"; exit 0
fi

FALTAS=()
linha() { printf '  %-26s %s\n' "$1" "$2"; }

echo "== gerar-arte: ambiente =="

# Ferramentas básicas
command -v curl >/dev/null && linha curl ok || { linha curl "FALTA"; FALTAS+=(curl); }
command -v python3 >/dev/null && linha python3 ok || { linha python3 "FALTA (necessário para a API e o carrossel)"; FALTAS+=(python3); }
if command -v sips >/dev/null; then linha "conversor de imagem" "ok (sips)"
elif python3 -c 'import PIL' 2>/dev/null; then linha "conversor de imagem" "ok (Pillow)"
else linha "conversor de imagem" "FALTA: python3 -m pip install --user pillow"; FALTAS+=(pillow); fi

# Codex
CODEX=0
if command -v codex >/dev/null; then
  v="$(codex --version 2>/dev/null | awk '{print $NF}')"
  if codex login status >/dev/null 2>&1; then linha codex "ok ($v, logado)"; CODEX=1
  else linha codex "FALTA login: rode 'codex login' (conta do ChatGPT)"; fi
  grep -qs 'image_gen' "$AGENTS" && linha "regra image_gen do Codex" ok \
    || linha "regra image_gen do Codex" "recomendado: bash verificar-ambiente.sh --instalar-regra-codex"
else
  linha codex "não instalado: npm i -g @openai/codex@latest && codex login"
fi

# Configuração
if [ ! -f "$GA_CONFIG" ]; then
  linha config "não existe ($GA_CONFIG)"
  [ -n "${OPENAI_API_KEY:-}" ] && linha "api (OPENAI_API_KEY)" "ok (no ambiente)" || linha "api (OPENAI_API_KEY)" "não definida"
  echo "RESULTADO: SEM CONFIGURAÇÃO. Rodar a Parte A de entrevista.md."
  exit 0
fi
carregar_config
linha config "ok ($GA_CONFIG)"
[ -d "$PASTA_CLIENTES" ] && linha "pasta de clientes" "ok ($PASTA_CLIENTES)" \
  || { linha "pasta de clientes" "FALTA: $PASTA_CLIENTES não existe"; FALTAS+=(pasta); }
linha motor "$MOTOR"
[ -n "${OPENAI_API_KEY:-}" ] && linha "api (OPENAI_API_KEY)" "ok" || linha "api (OPENAI_API_KEY)" "não definida"

case "$MOTOR" in codex|ambos) [ "$CODEX" = 1 ] || FALTAS+=(codex);; esac
case "$MOTOR" in api|ambos) [ -n "${OPENAI_API_KEY:-}" ] || FALTAS+=(OPENAI_API_KEY);; esac
case "$MOTOR" in codex|api|ambos) ;; *) FALTAS+=("MOTOR inválido ($MOTOR): use codex, api ou ambos");; esac

[ -f "$GA_HOME/perfil.md" ] && linha perfil.md ok || { linha perfil.md "FALTA (rodar A4 a A6 da entrevista)"; FALTAS+=(perfil); }
if grep -qs '^[[:space:]]*OPENAI_API_KEY=' "$GA_CONFIG"; then
  case "$(ls -l "$GA_CONFIG" | cut -c1-10)" in -rw-------) ;; *) linha "chave no config" "AVISO: tem chave da API e está aberto. Rode: chmod 600 \"$GA_CONFIG\"";; esac
fi

if [ ${#FALTAS[@]} -eq 0 ]; then
  echo "RESULTADO: ok"
  [ -d "$PASTA_CLIENTES" ] && { echo "clientes:"; ls -1 "$PASTA_CLIENTES" 2>/dev/null | sed 's/^/  /'; }
else
  echo "RESULTADO: FALTA ${FALTAS[*]}"
fi
