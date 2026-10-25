# Modelo de `estilo.md`

O `estilo.md` é o sistema visual da designer, escrito. Entra no prompt de toda arte do cliente. Escrever a partir das peças do kit, não do manual da marca: o que importa é o que ela publica.

Exemplo completo (marca fictícia):

```markdown
# Estilo visual Ateliê Brasa

Curadoria em 2026-10-12, 6 peças em `kit.txt`. Este texto entra no prompt de toda arte gerada com IA.

## Sistema

- **Paleta:** terracota `#B4532A`, creme `#F3E9DC`, marrom café `#3B2618`, verde-oliva `#6B7A3A` só em detalhe. Nada de outra cor.
- **Tipografia:** título em serifa de alto contraste (estilo Playfair Display), caixa normal, peso regular. Apoio em sans geométrica leve (estilo Montserrat Light). Nunca condensada.
- **Composição:** foto ocupa 2/3 superiores; faixa creme embaixo com título à esquerda. Margem generosa (cerca de 7% da largura).
- **Foto:** produto em mesa de madeira, luz natural lateral, sombra suave, tons quentes levemente dessaturados. Sem pessoas de rosto.
- **Logo:** monograma "AB" pequeno no canto inferior direito da faixa creme. @ateliebrasa em sans pequena ao lado.
- **Elementos:** linha fina terracota de 2 px separando foto e faixa; pílula terracota com texto creme para preço ou data.
- **CTA:** texto sublinhado "Encomende pelo WhatsApp", sem botão.

## Qual referência mandar

| Tipo de peça | Referências do kit |
|---|---|
| Produto | p01, p03, p05 |
| Data comemorativa | p02, p06 |
| Depoimento | p04, p01 |
| Tráfego (oferta) | p05, p03, p02 |

## Não fazer

Fundo escuro, fonte script/cursiva, mockup 3D, foto de banco com gente sorrindo, mais de uma cor de destaque na mesma peça.
```

**Regras**

- Hex aproximado é melhor que nome de cor. Se a pessoa informou o hex oficial, usar o oficial.
- Nome de fonte real só se a pessoa confirmou; senão, "estilo X" com uma referência conhecida.
- A tabela "Qual referência mandar" cobre os tipos de peça que o cliente mais publica, com 3 peças em cada linha (a trava do `gerar.sh` exige 3).
- "Não fazer" vem do que destoa nas peças descartadas e do que a pessoa disser.
