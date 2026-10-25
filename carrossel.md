# Carrossel: gerar em tiras

Card gerado um a um muda pílula, painel e margem de lugar a cada geração, e prompt nenhum segura isso. Carrossel sai em **tiras de 2 cards** numa imagem 3:2 (1536x1024), pelo Codex.

## Passo a passo

1. Planejar os cards (5 a 10). Logo e @ só na capa e no fechamento.
2. Escrever um `prompt.md` por tira. Cada tira:
   - descreve os 2 cards (esquerda e direita) com o texto exato de cada um;
   - pede 5% de respiro em cima e embaixo e **nenhum texto na faixa central** (de 46% a 54% da largura);
   - repete o sistema do `estilo.md` igual em todas as tiras.
3. Da segunda tira em diante, a tira anterior entra como **última** referência, e o prompt diz: `CONTINUATION: copy the layout, label sizes, margins and type sizes of the last reference exactly.` Conta no limite de 5: logo + 3 do kit + tira anterior.
4. Gerar cada tira:
   ```bash
   bash "$S/scripts/gerar.sh" --cliente <cliente> --prompt tira1/prompt.md --out tira1 --so codex --ref ... 
   ```
   Na API, `--size 1536x1024`.
5. Cortar:
   ```bash
   bash "$S/scripts/cortar-tira.sh" tira1/codex.png <pasta-final> 1   # gera card-01.png e card-02.png
   bash "$S/scripts/cortar-tira.sh" tira2/codex.png <pasta-final> 3   # card-03 e card-04
   ```
   Corta no meio, recorta para 4:5 e amplia para 1080x1350.

## Conferir antes de mostrar

- **Texto atravessando o corte:** refazer a tira com limite explícito: "the text of card 1 must end before 42% of the total width".
- **Acento, crase, cedilha:** ler palavra por palavra.
- **Emenda do elemento contínuo** (forma ou linha que atravessa o carrossel): medir a altura do elemento na borda de cada card e, se não bater, refazer a tira do meio com as alturas obrigatórias ("enters at 45% from the top, exits at 43%").
- **Sistema rígido:** rótulo ou pílula com o mesmo tamanho e altura em todos os cards; margem e tamanho de letra iguais; a composição varia.

## Direção

- Um elemento contínuo que atravessa o carrossel inteiro e muda de posição em cada card. Marca d'água repetida no mesmo canto de cada card não serve.
- Não repetir o mesmo elemento em todos os cards.
