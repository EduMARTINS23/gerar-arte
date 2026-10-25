# Entrevista de primeiro uso

A skill não sabe nada da pessoa que está usando: onde ficam os arquivos, qual motor ela tem, quem são os clientes, como a designer de cada marca trabalha. Esta entrevista descobre isso uma vez e grava em arquivo, para nunca mais perguntar.

**Como conduzir**

- Uma pergunta por mensagem. Quando houver opções claras, usar a ferramenta de pergunta com opções (`AskUserQuestion` no Claude Code), com a recomendada primeiro.
- Nunca perguntar o que já se sabe. Antes de cada pergunta, conferir se a resposta já está no pedido da pessoa ("minha cliente X" responde a A1), no `verificar-ambiente.sh` (o que está instalado) ou nas imagens (cores, composição). Se estiver, anotar, dizer em uma linha o que foi deduzido e seguir para a próxima.
- Explicar em uma linha por que cada pergunta importa, para a pessoa responder com o detalhe certo.
- Ao fim de cada parte, mostrar o resumo do que foi gravado e perguntar se algo está errado.

`GA` nos comandos abaixo = `${GERAR_ARTE_HOME:-$HOME/.gerar-arte}`. Usar sempre essa forma, nunca `~/.gerar-arte` fixo.
- Explicar em uma linha por que cada pergunta importa, para a pessoa responder com o detalhe certo.
- Ao fim de cada parte, mostrar o resumo do que foi gravado e perguntar se algo está errado.

---

## Parte A: configuração (uma vez por pessoa)

Rodar quando o `verificar-ambiente.sh` disser `SEM CONFIGURAÇÃO`. Grava em `GA`.

Na primeira mensagem, abrir com esta frase e emendar a primeira pergunta que ainda falta: "Antes da primeira arte, preciso de 5 minutos para entender como você trabalha. Isso fica salvo e não pergunto de novo."

### A1. Para quem é a arte

> Você faz arte para a sua própria marca ou para clientes (agência, freelancer, social media)?

Muda a estrutura: marca própria vira um único "cliente"; agência tem uma pasta por cliente.

### A2. Onde guardar

> Onde quer que eu guarde os arquivos de cada cliente (logo, referências, artes geradas)?

Sugerir `~/gerar-arte-clientes` (se `GERAR_ARTE_HOME` estiver definido, sugerir `$GERAR_ARTE_HOME/clientes`). Se a pessoa já tem uma pasta por cliente (Drive sincronizado, Dropbox, pasta de projetos), usar a dela: o nome de cada pasta de cliente, exatamente como está, vira o identificador do cliente nos scripts (`"Padaria São Jorge"` funciona; usar aspas). A skill só cria as subpastas que precisa dentro de cada uma.

### A3. Motor de imagem

Conforme o `verificar-ambiente.sh`:

- **Só um motor disponível** (ex.: Codex logado e sem `OPENAI_API_KEY`): propor esse e confirmar numa linha ("Vou usar o Codex, que já está pronto aqui. A API dá para ligar depois."). Não oferecer "os dois".
- **Os dois disponíveis**: perguntar.
  > Qual motor você vai usar?
  > - **Codex com plano ChatGPT** (recomendado): sem custo por imagem, 2 a 3 min por arte.
  > - **API da OpenAI**: paga por imagem, cerca de 1 min, tamanho exato.
  > - **Os dois**: gera nas duas e compara.
- **Nenhum**: explicar as duas opções acima e guiar a instalação da escolhida.

Se faltar algo no motor escolhido, guiar a instalação antes de seguir:

- Codex: `npm i -g @openai/codex@latest` e depois `codex login` (entrar com a conta do ChatGPT). Sugerir que a pessoa rode no próprio terminal (no Claude Code: `! codex login`).
- API: pedir que a pessoa cole a chave no `config.env` ela mesma, ou exporte `OPENAI_API_KEY` no shell. Nunca pedir a chave no chat.

Codex escolhido: oferecer `bash "$S/scripts/verificar-ambiente.sh" --instalar-regra-codex`, que adiciona ao `~/.codex/AGENTS.md` a regra de sempre gerar arte com `image_gen` (sem ela, o Codex usado fora desta skill monta arte em HTML). Só instalar com o sim da pessoa.

### A4. De onde vêm as referências

> Onde ficam as artes que a designer de cada cliente já publicou?

Opções comuns: pasta local ou Drive/Dropbox sincronizado, Instagram do cliente, Canva/Figma (exportar PNG), gerenciador de conteúdo da agência. Anotar no `perfil.md`. É daqui que sai o kit de cada cliente na Parte B; a skill importa de pasta, arquivo ou URL direta de imagem.

### A5. Direção de arte

Mostrar a seção "Direção de arte" do `SKILL.md` e perguntar:

> Esses são os padrões que a skill segue. Algum não vale para você, ou tem algo que você nunca quer ver numa arte?

Gravar as exceções e os acréscimos no `perfil.md`, com as palavras da pessoa.

### A6. Revisão de copy

> Você tem algum processo ou skill para revisar texto antes de ir para a arte (tirar cara de IA, tom da marca)?

Opcional. Se tiver, anotar o nome no `perfil.md`.

### Gravar

```bash
GA="${GERAR_ARTE_HOME:-$HOME/.gerar-arte}"; mkdir -p "$GA" && chmod 700 "$GA"
```

`$GA/config.env` (lido pelos scripts):

```bash
PASTA_CLIENTES="/caminho/escolhido"
MOTOR="codex"            # codex | api | ambos
MODELO_API="gpt-image-2"
# OPENAI_API_KEY="..."   # só se a pessoa preferir guardar aqui; a pessoa cola, não o agente
```

Rodar `chmod 600 "$GA/config.env"`.

`$GA/perfil.md` (lido pelo agente):

```markdown
# Perfil
- Trabalha para: <marca própria | clientes>
- Referências vêm de: <onde>
- Revisão de copy: <skill/processo ou "nenhum">

## Direção de arte desta pessoa
- <exceções aos padrões da skill>
- <o que ela nunca quer ver>
```

Rodar o `verificar-ambiente.sh` de novo e mostrar que ficou tudo `ok`.

---

## Parte B: cadastro de cliente (uma vez por cliente)

Rodar quando o `montar-kit.sh status <cliente>` não disser `kit pronto`. `<cliente>` é o nome da pasta do cliente dentro da pasta de clientes: se a pessoa já tem a pasta, o nome exato dela, entre aspas; se for nova, minúsculas com hífen (`padaria-sao-jorge`).

### B1. A marca

Uma pergunta por vez, pulando o que a pessoa já disse:

1. O que a marca vende e para quem (público, cidade, faixa de idade)?
2. Como a marca fala com o cliente: "você" ou "tu", formal ou próximo? Alguma palavra ou promessa proibida (área regulada: saúde, finanças, jurídico)?
3. Qual o CTA padrão (WhatsApp, link na bio, site, loja)?
4. Qual a fonte da marca, se souber? E as cores (hex, se tiver)?

Se a pessoa não souber fonte ou cores, tudo bem: sai da análise das peças em B3.

### B2. Logo

> Me passa o logo oficial, de preferência PNG com fundo transparente.

```bash
bash "$S/scripts/montar-kit.sh" logo <cliente> <arquivo-ou-url>
```

Depois abrir o `logo.png` e conferir que é o logo desta marca, sozinho (não um post, não o logo de outro cliente). Se não for, pedir de novo.

### B3. Curadoria das peças publicadas

Explicar: "A arte sai no estilo da sua designer porque eu mostro ao modelo posts que ela já publicou. Me passa de 8 a 15 posts recentes de que vocês gostam, de tipos variados (produto, depoimento, data comemorativa, tráfego)."

```bash
bash "$S/scripts/montar-kit.sh" importar <cliente> <pasta|arquivo|url> [...]
```

Sai `referencias-visuais/candidatas/c01.png`, `c02.png`... Abrir cada uma (ler a imagem) e mostrar uma lista numerada com uma linha por peça: tipo, composição, o que tem de marcante. Recomendar 5 a 8 que mostram melhor o sistema visual e cobrem os tipos de peça que o cliente mais usa. Descartar o que for de outra fase da marca, peça de terceiros ou tipografia destoante.

> Quais destas entram no kit? Recomendo c02, c05, c07, c09 e c11, porque...

```bash
bash "$S/scripts/montar-kit.sh" aprovar <cliente> c02=lancamento c05=depoimento c07=dia-das-maes ...
```

Vira `p01-lancamento.png`, `p02-depoimento.png`... e o `kit.txt`.

### B4. Escrever o `estilo.md`

Ler todas as peças do kit e escrever `referencias-visuais/estilo.md` seguindo `estilo-modelo.md`: cores com hex aproximado, tipografia, composição, tratamento da foto, onde ficam logo e @, CTA, a tabela "Qual referência mandar" e o "Não fazer". Mostrar à pessoa:

> Este é o sistema visual que eu li nas peças. Está certo? Algo que a designer sempre faz e eu não vi?

Corrigir com o que ela disser. Fonte e cores informadas em B1 valem sobre o que foi estimado das imagens.

### B5. Escrever o `marca.md`

`<clientes>/<cliente>/marca.md` com as respostas de B1: o que vende, público, tom e tratamento, CTA, palavras proibidas.

### Fechar

```bash
bash "$S/scripts/montar-kit.sh" status <cliente>
```

Tem que dizer `kit pronto`. Então voltar ao passo 2 do `SKILL.md` e gerar a arte pedida.

### Versão rápida (peça urgente)

Vale quando a pessoa diz que é urgente ou dá prazo de horas. Na dúvida, perguntar o prazo.

- Pedir tudo numa mensagem só: logo + 3 ou 4 posts publicados + o que falta do B1 (tom e CTA).
- Sem galeria: importar e aprovar direto os posts recebidos, depois de abrir e conferir que são da marca certa.
- `estilo.md` curto com `> PROVISÓRIO: refazer a curadoria completa` no topo; mostrar junto com a arte, em vez de pedir aprovação antes.
- Avisar que o resultado tende a ser menos fiel.

Se a pessoa proibir perguntas, ainda assim pedir logo e posts: sem eles não se gera, e dizer isso é mais rápido que entregar uma arte errada.

### Cliente sem nenhum post publicado

A skill copia o estilo de uma designer; sem peças publicadas, não há o que copiar. Dizer isso e oferecer: (1) a pessoa ou a designer faz 3 peças-base à mão e elas viram o kit; ou (2) a pessoa traz 3 a 5 posts de marcas que ela quer como referência de direção, que entram no kit marcados como `ref-externa` no nome, com `estilo.md` PROVISÓRIO escrito a partir delas e da paleta e fonte da marca. Nunca usar peças de outro cliente.
