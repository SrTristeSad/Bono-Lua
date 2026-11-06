# Screen no backend LÖVE

Referência: Pixi/4.x/src/dragonBones/pixi/PixiSlot.ts no pin 64b6c69ae35777c2404be68c9192e2c56906079e. _updateBlendMode só escreve blendMode quando o display é Sprite. Esse ramo agora aceita Normal, Add e Screen. Mesh continua ignorando o blend solicitado, como no original. Multiply e outros modos continuam recusados explicitamente em sprites.

O adaptador armazena o identificador de plataforma 3 para Screen, como PIXI.BLEND_MODES.SCREEN. O runtime não recebe algoritmos de renderização. A Image do chamador continua straight-alpha no LÖVE; um shader premultiplica o texel e aplica a cor premultiplicada. O shader é criado por display apenas quando usado, reutilizado e liberado por Display:destroy. O recurso não é associado ao frame do atlas nem destrói Images compartilhadas.

## Empacotamento e composição

O batcher de sprites Pixi 4.8.9 usa premultiplyTint: cada canal de tint é arredondado com floor(canal*worldAlpha+.5), mas alpha é truncado com floor(worldAlpha*255). Em Screen, setColor recebe esses quatro bytes normalizados; o shader multiplica texel premultiplicado por essa cor, sem multiplicar o RGB por alpha novamente. LÖVE usa screen/premultiplied. O par de fatores WebGL original é ONE e ONE_MINUS_SRC_COLOR. Blends Normal/Add conservam o caminho anterior e seus critérios de teste.

A cor/alpha acumulada usa o scene graph existente. Push/pop preservam o estado de blend, cor, shader e transform do chamador; o shader anterior é restaurado antes dos filhos. O contrato gráfico verifica a restauração de blend/shader após o draw. Aplicações de shaders personalizados pelo chamador junto com Screen não estão cobertas por este recorte.

Multiply foi investigado mas permanece pendente: seu par DST_COLOR/ONE_MINUS_SRC_ALPHA não equivale diretamente ao multiply do LÖVE. O arredondamento separado de RGB/alpha no batcher pode produzir RGB maior que alpha; a simples conversão para um fator multiplicativo pode saturar prematuramente. Não foi substituído por uma aproximação silenciosa.

## Validação

lovesprites_differential com argumento blends usa PixiSlot original compilado com probes numéricos: 33 cenários/6.588 colunas por VM Lua 5.4/LuaJIT, sem tolerância. Alpha, tint, escalas, flip e operações anteriores acompanham um caso de troca Screen→Add→Normal→Screen. Os demais diferenciais de sprites, meshes e rotação permanecem como regressões.

O job gráfico acrescenta 18 cenas reais LÖVE/Mesa vs Pixi 4.8.9 WebGLRenderer/Chromium: 16 sprites combinam alpha 0/.25/.5/1, tint 1/.5 e regiões normais/rotacionadas, com flip/ordem em cenas selecionadas. Texturas têm quadrantes assimétricos, fundo opaco colorido e sobreposição entre slots. Dois casos de mesh verificam que Screen continua sem efeito no ramo de mesh original. São 1.474.560 canais RGBA exigidos idênticos, sem tolerância nova. PNG/RGBA e blend-result.json ficam no artefato gráfico. A configuração não substitui uma execução aprovada. LÖVE não está instalado no executor local; a prova gráfica roda na CI real.

A CI sobe para 59 suítes e 22 exemplos por VM e mantém as 26 capturas anteriores, com seus critérios preservados.

## Usar e limites

Na raiz, `love .`: B alterna Screen; T alterna atlas; M alterna sprites/meshes. No modo mesh, a solicitação de blend continua ignorada como no original.

A prova cobre texels opacos, nearest, fundos opacos, cenas e alphas descritos. Alpha dos texels, premultiplicação durante upload/filtragem, destinos transparentes, composições arbitrárias e outros blends continuam pendentes. O suporte não declara equivalência universal de renderização nem conclusão das integrações oficiais.
