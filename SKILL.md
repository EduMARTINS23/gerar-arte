---
name: gerar-arte
description: Use quando o pedido for gerar uma arte estática de marca ou cliente com IA (criativo de tráfego, post de feed, carrossel, card, banner, capa) pelo Codex (image_gen) ou pela API da OpenAI (gpt-image-2), cadastrar um cliente ou marca nova para gerar arte, ou quando uma arte gerada sair feia, genérica, com cara de template ou montada em HTML.
---

# Gerar arte com IA (Codex + API)

A arte sai do modelo de imagem (GPT Image), nunca de HTML virado print. E sai no estilo da designer da marca, porque a referência que entra é o post que ela já publicou, não o site nem o manual da marca.

`S` = a pasta desta skill (o diretório onde está este arquivo, normalmente `~/.claude/skills/gerar-arte`). O shell não guarda variáveis entre comandos: começar cada comando com `S=<caminho>;` ou escrever o caminho completo.

## 0. Conferir o ambiente (toda vez)

```bash
bash "$S/scripts/verificar-ambiente.sh"
```

| O script diz | Fazer |
|---|---|
| `SEM CONFIGURAÇÃO` | Rodar a **Parte A** de `entrevista.md` (configuração da pessoa) antes de qualquer arte. |
| Motor com `FALTA` | Mostrar o que falta e como resolver (o script imprime). Não gerar com motor quebrado. |
| `FALTA perfil` | Rodar A4 a A6 de `entrevista.md` e gravar o `perfil.md`. |
| Tudo `ok` | Seguir. |

Depois ler `${GERAR_ARTE_HOME:-~/.gerar-arte}/perfil.md`: é a direção de arte e as regras desta pessoa, e vale acima dos padrões daqui.

## 1. Cliente tem kit?

`<cliente>` = nome da pasta do cliente dentro de `PASTA_CLIENTES` (entre aspas se tiver espaço). É sempre a marca da peça pedida: nunca gerar com o kit de outro cliente.

```bash
bash "$S/scripts/montar-kit.sh" status <cliente>
```

- `kit pronto` → seguir. Se listar avisos (peça citada no `estilo.md` que não existe), corrigir o `estilo.md` antes.
- Qualquer outra resposta → rodar a **Parte B** de `entrevista.md` (cadastro do cliente: marca, logo, curadoria das peças publicadas, `estilo.md`). Urgente ou cliente sem posts: ver as seções finais da Parte B. Sem kit não se gera: arte sem as peças da designer sai genérica, sempre.

## 1b. Briefing da peça

Com o kit pronto, juntar o que esta arte precisa e perguntar só o que faltar, uma pergunta por vez:

- **Formato:** feed 4:5 (padrão), quadrado 1:1, story 9:16, carrossel.
- **Objetivo e oferta:** o que anuncia, preço, prazo, condição. Não inventar número nem promessa.
- **Foto real:** tem foto do produto, do ambiente ou da equipe? Foto real do cliente vale mais que cena inventada e entra como referência (conta no limite de 5).

## 2. Copy primeiro

Segue `<cliente>/marca.md` (tom, tratamento, CTA, palavras proibidas). Pouco texto: título, linha de apoio, CTA. Se o `perfil.md` indicar uma skill ou processo de revisão de copy, passar por ele.

## 3. Prompt

Prompt = sistema do `estilo.md` + descrição de cada referência anexada, **na mesma ordem dos `--ref`**. Layout, card, fonte, cores com hex, onde fica o logo, tratamento da foto, e o texto exato entre aspas. Escrever em inglês, com o texto da arte no idioma do cliente. Modelo completo em `prompt-modelo.md`.

Referências, no máximo 5 no total: logo + 3 ou 4 peças do kit pela tabela "Qual referência mandar" do `estilo.md` (conforme o tipo da peça), ou logo + 3 do kit + 1 foto real do cliente.

## 4. Gerar

```bash
bash "$S/scripts/gerar.sh" --cliente <cliente> --prompt <pasta>/prompt.md --out <pasta> \
  --ref <clientes>/<cliente>/logo.png --ref <clientes>/<cliente>/referencias-visuais/p03-xxx.png ...
```

- Pasta da peça: `<clientes>/<cliente>/criativos/AAAA-MM-<nome-da-peca>/`.
- Motor: o do `config.env`. `--so codex` ou `--so api` força um. Sai `codex.png` e/ou `api.png`.
- **Travas do script** (não contornar): sem `--cliente`, sem `estilo.md`, com menos de 3 peças diferentes do kit (`pNN-*.png`) ou com mais de 5 referências, ele se recusa.
- Formato: `--size` vale só para a API (múltiplo de 16; 4:5 = `1088x1360`, 1:1 = `1024x1024`, 9:16 = `1088x1920`, 3:2 = `1536x1024`). O Codex escolhe o tamanho; o pedido de proporção vai no prompt.

## 5. Entregar

Abrir as imagens geradas e conferir: ortografia e acentos de cada palavra, logo redesenhado (costuma ser; avisar para trocar pelo arquivo oficial antes de publicar), fidelidade ao `estilo.md`. Se rodou os dois motores, tabela curta (texto, foto, fidelidade ao estilo, custo) e recomendar um.

Carrossel: seguir `carrossel.md` (gera em tiras de 2 cards, nunca card a card).

## Codex ou API

| | Codex (`image_gen`) | API (`gpt-image-2`) |
|---|---|---|
| Custo | plano ChatGPT, sem crédito por imagem | crédito da API (`OPENAI_API_KEY`) |
| Tempo | 2 a 3 min | cerca de 1 min |
| Tamanho | ele escolhe, perto do pedido | exato (`--size`) |
| Referências | até 5 | até 5 (mesma trava) |

## Direção de arte (padrão, o `perfil.md` pode sobrescrever)

- Logo só na capa e no fechamento do carrossel, nunca em todos os cards. O @ também.
- Fonte da marca sempre a do `estilo.md`. Nunca trocar por condensada ou "parecida" sem o cliente usar.
- Tipografia sutil: título em peso médio, tamanho moderado, com respiro. Nada gigante ou grosseiro.
- Sem neon: nada de glow, contorno luminoso, halo, bloom ou degradê brilhante. Fundo escuro se resolve com os tons escuros da paleta, em formas chapadas e foscas.
- Foto real do cliente sempre que houver. Pessoa gerada por IA tende a ficar artificial: preferir produto e ambiente. Em carrossel, foto na capa e onde ela prova algo; o resto no sistema tipográfico da marca.
- Pode propor direção nova, desde que fique na paleta, na tipografia e nos elementos da marca.

## Erros comuns

| Sintoma | Causa e correção |
|---|---|
| Arte com cara de template, painel dividido, genérica | Referência genérica (site, manual, logo sozinho). Mandar 3 a 5 posts publicados da designer, sempre, inclusive quando a peça usa foto real. |
| Codex entrega HTML, SVG ou print de código | O pedido não disse `image_gen`. O `gerar.sh` já força; para uso manual, instalar a regra: `verificar-ambiente.sh --instalar-regra-codex`. |
| "model is not supported when using Codex with a ChatGPT account" | CLI do Codex desatualizado: `npm i -g @openai/codex@latest`. |
| API devolve erro de formato de imagem | Referência WebP ou HEIC com extensão errada. O `gerar.sh` e o `montar-kit.sh` convertem para PNG; importar sempre pelo `montar-kit.sh`. |
| Codex ignora referências, qualidade cai | Mais de 5 referências fazem o `image_gen` cair no modo "últimas imagens". O script bloqueia acima de 5: logo + 3 do kit + 1 foto, ou logo + 4 do kit. |
| `codex: referência do kit NÃO enviada` | O Codex gerou sem as peças. O script descarta a imagem; rodar de novo. |
| Padronizar cards com máscara (`/images/edits` + `mask`) | Não funciona: move elementos e erra acento. Usar o método das tiras do `carrossel.md`. |
| Logo deformado ou redesenhado | Normal no modelo. Avisar e sobrepor o logo oficial na edição final. |
