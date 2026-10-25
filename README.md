# gerar-arte

Skill para Claude Code que gera arte estática de marca com IA (post de feed, criativo de tráfego, carrossel, banner, capa) **no estilo da designer da marca**, pelo Codex (`image_gen`) ou pela API da OpenAI (`gpt-image-2`).

A diferença para "pedir uma imagem pra IA": a referência que entra no modelo são os posts que a designer da marca já publicou, escolhidos numa curadoria, mais um `estilo.md` com o sistema visual escrito (cores com hex, tipografia, composição, onde fica o logo). Sem isso, a arte sai com cara de template. A skill trava a geração quando falta esse kit.

## O que ela faz

- **Entrevista de primeiro uso:** na primeira vez, pergunta como você trabalha (marca própria ou clientes, onde guardar, qual motor, de onde vêm as referências, o que você nunca quer ver numa arte) e grava em `~/.gerar-arte/`.
- **Cadastro de cliente:** para cada marca nova, importa posts publicados, monta uma galeria numerada, recomenda as melhores peças, você aprova, e ela escreve o `estilo.md` a partir das imagens.
- **Geração com travas:** exige o `estilo.md` e pelo menos 3 peças do kit em cada arte, e no máximo 5 referências (limite do `image_gen`). Confere no registro do Codex se as referências chegaram de fato ao gerador.
- **Carrossel consistente:** gera em tiras de 2 cards e corta em 1080x1350, para pílula, margem e tipografia não mudarem de lugar a cada card.
- **Codex e API lado a lado:** roda um, o outro ou os dois para comparar.

## Requisitos

- [Claude Code](https://claude.com/claude-code)
- macOS ou Linux, `bash`, `curl`, `python3`
- Pelo menos um motor:
  - **Codex CLI** com conta do ChatGPT (sem custo por imagem): `npm i -g @openai/codex@latest && codex login`
  - **API da OpenAI** com crédito: variável `OPENAI_API_KEY`
- Conversão de imagem: `sips` (já vem no macOS) ou Pillow (`python3 -m pip install --user pillow`)

## Instalação

```bash
git clone https://github.com/EduMARTINS23/gerar-arte.git ~/.claude/skills/gerar-arte
```

Para um projeto só, clone em `<projeto>/.claude/skills/gerar-arte`.

## Uso

Peça ao Claude Code o que você quer:

> Gera um post de feed para a Padaria São Jorge anunciando o panetone de Natal.

Na primeira vez ele roda a entrevista; na primeira arte de cada cliente, o cadastro. Depois disso, é direto.

Os scripts também rodam à mão:

```bash
S=~/.claude/skills/gerar-arte
bash $S/scripts/verificar-ambiente.sh                     # o que está instalado e configurado
bash $S/scripts/montar-kit.sh status <cliente>            # o kit do cliente está pronto?
bash $S/scripts/montar-kit.sh importar <cliente> <pasta>  # candidatas ao kit
bash $S/scripts/montar-kit.sh aprovar <cliente> c02=lancamento c05=depoimento
bash $S/scripts/gerar.sh --cliente <cliente> --prompt prompt.md --out <pasta> --ref logo.png --ref p01.png ...
bash $S/scripts/cortar-tira.sh tira.png <pasta-final> 1   # carrossel
```

## Onde ficam os seus dados

Nada do que é seu fica dentro da pasta da skill, então atualizar com `git pull` não apaga nada.

```
~/.gerar-arte/                 configuração (mude com GERAR_ARTE_HOME)
  config.env                   pasta dos clientes, motor, chave da API (opcional, chmod 600)
  perfil.md                    sua direção de arte e suas regras
<pasta dos clientes>/<cliente>/
  marca.md                     o que vende, público, tom, CTA, palavras proibidas
  logo.png
  referencias-visuais/
    candidatas/                importadas, esperando curadoria
    p01-....png                kit aprovado
    kit.txt                    lista do kit com a origem de cada peça
    estilo.md                  sistema visual escrito
  criativos/AAAA-MM-<peça>/    prompt.md, codex.png, api.png
```

## Arquivos da skill

| Arquivo | Para quê |
|---|---|
| `SKILL.md` | O fluxo que o Claude segue |
| `entrevista.md` | Roteiro da entrevista de primeiro uso e do cadastro de cliente |
| `estilo-modelo.md` | Modelo do `estilo.md` |
| `prompt-modelo.md` | Modelo de prompt de imagem |
| `carrossel.md` | Método das tiras |
| `scripts/` | Verificação, kit, geração e corte |

## Licença

MIT. Feito pela [Altiva Assessoria](https://github.com/EduMARTINS23).
