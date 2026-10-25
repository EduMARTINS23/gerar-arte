# Modelo de prompt

Estrutura que funciona: contexto da peça, ordem das referências com o que cada uma mostra, o sistema da designer, a cena, o texto exato, as regras. Em inglês; o texto da arte no idioma do cliente, entre aspas, com acento.

Exemplo (marca fictícia, mesmo cliente do `estilo-modelo.md`), salvo como `prompt.md` na pasta da peça:

```text
Static Instagram feed post, vertical 4:5 (1080x1350). Brand: Ateliê Brasa, an artisanal bakery in Curitiba, Brazil. Product: panettone with Brazilian coffee, Christmas 2026. Audience: Brazilian adults 30 to 55 who buy gifts for family and clients.

This post must look like it was made by the brand's in-house designer. The attached references are her published posts. Copy her visual system closely: same layout logic, same typography, same color and light treatment. Do not invent a new style.

REFERENCE IMAGES (attached, in this order)
1. Official logo: "AB" monogram. Use it exactly; do not redraw it.
2. Designer post "Pão de fermentação natural": product photo on the top two thirds, cream band at the bottom with serif headline on the left, monogram bottom-right.
3. Designer post "Dia das Mães": same split, terracotta pill with the date above the headline, thin terracotta line between photo and band.
4. Designer post "Encomendas abertas": overhead product shot, warm side light, underlined CTA in the cream band.

THE DESIGNER'S SYSTEM (follow all of it)
- Palette only: terracotta #B4532A, cream #F3E9DC, coffee brown #3B2618, olive #6B7A3A for small details.
- Headline: high-contrast serif (Playfair Display style), sentence case, regular weight, moderate size. Support: light geometric sans (Montserrat Light style).
- Photo fills the top two thirds; cream band below; 2 px terracotta line between them.
- Natural side light, soft shadows, warm and slightly desaturated tones.
- Generous margins, about 7% of the width. Nothing crowded against the edges.

SCENE
A panettone cut open on a dark wooden table, a small cup of black coffee beside it, coffee beans scattered, soft window light from the left. No people.

TEXT (exact Portuguese, nothing else)
Terracotta pill above the headline: "Natal 2026"
Headline: "Panetone de café, feito à mão"
Support line: "Massa de fermentação natural, 72 horas."
Underlined CTA: "Encomende pelo WhatsApp"
Monogram bottom-right of the band (reference 1), "@ateliebrasa" beside it.

RULES
- Every word spelled exactly as above, with accents. No extra text, no fine print, no prices.
- No glow, neon, halo, bloom or glossy gradients. Flat, matte shapes only.
- No 3D icons, no Christmas clichés (Santa, snow, baubles), no stock-photo people.
```

**Checklist do prompt**

- Ordem das referências = ordem dos `--ref` no `gerar.sh`.
- Cada referência descrita pelo que ela ensina (layout, card, fonte, elemento), não só pelo nome.
- Cores com hex. Fonte com nome ou "estilo X".
- Texto exato, com acento, e "nothing else".
- Proibições do `estilo.md` e do `perfil.md` na seção RULES.
