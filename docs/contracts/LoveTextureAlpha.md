# Texels semitransparentes em Screen e Multiply

Referência de motor: PixiSlot.ts/PixiTextureAtlasData.ts do DragonBonesJS 64b6c69ae35777c2404be68c9192e2c56906079e. Referência de host: PixiJS 4.8.9 real, BaseTexture.fromCanvas com premultipliedAlpha e WebGLRenderer no Chromium. A fixture fornece bytes straight-alpha idênticos às duas plataformas; o browser efetua a premultiplicação real do upload. O teste não substitui o sampler ou os fatores de blend por probes.

## Mudança

Screen e Multiply recebiam anteriormente c.rgb*c.a diretamente no shader. Isso conserva um produto fracionário onde o upload RGBA8 premultiplicado da referência já armazenou bytes arredondados. Agora o shader usa floor(c.rgb*c.a*255+.5)/255 antes de aplicar os bytes de tint/alpha do batcher. Alpha do texel continua intacto. A etapa de composição de Screen e a leitura do snapshot de Multiply permanecem como nos contratos anteriores. Normal/Add e meshes não recebem esse shader novo.

O contrato é limitado a Image RGBA8 straight-alpha e nearest, como as entradas da prova. A quantização depois da amostragem não equivale a interpolar texels premultiplicados num filtro linear ou mipmap; esses casos continuam pendentes. Images já premultiplicadas pelo chamador também estão fora deste contrato.

Não há nova propriedade de textura ou recurso GPU adicional: os shaders continuam pertencendo ao Display e sendo liberados no destroy. A Image do chamador permanece compartilhada. Trocar replacedTexture reconstrói os frames pelo caminho existente; a prova inclui a troca para outra Image com alphas e cores diferentes.

## Prova gráfica

texture_alpha.json é entrada com dois conjuntos de quatro cores. O primeiro usa alpha 0/64/128/255; o segundo 255/191/127/0. RGB inclui canais intermediários, para expor o arredondamento da premultiplicação, e cores ocultas sob alpha zero. ImageData no LÖVE e ImageData→Canvas no browser usam os mesmos bytes e disposição em quadrantes de regiões retangulares do atlas de rotação.

São 32 capturas reais: modos Screen/Multiply × alpha do slot 0/.25/.5/1 × tint 1/.5 × atlas normal/rotacionado. Há flip a cada terceiro caso, reordenação a cada quarto e substituição de textura a cada quinto. As três regiões se sobrepõem sobre fundo opaco em duas cores. Compare-se cada canal RGBA dos 32×160×128 pixels: 2.621.440 canais exigidos idênticos, sem tolerância adicional. Resultados em texture-alpha-result.json e PNG/RGBA do artefato gráfico. A configuração não é prova de aprovação; LÖVE real roda na CI sob Xvfb/Mesa.

A CI mantém 60 suítes diferenciais e 22 exemplos por VM Lua 5.4/LuaJIT. Acrescenta essa prova gráfica às 62 capturas anteriores, conservando seus critérios, inclusive o orçamento histórico da cena alpha de CanvasRenderer.

## Demonstração e limites

Na raiz, `love .`. A alterna transparência da textura e seleciona sprites; B escolhe Screen, N escolhe Multiply e prepara o Canvas; T alterna o atlas. As cores são dados de entrada, não screenshots pré-fabricados. O draw verifica a restauração do destino e do blend do chamador.

Multiply conserva a exigência Canvas rgba8/MSAA0/DPI1 e a cópia integral por sprite. A prova não cobre Normal/Add em WebGL com texels semitransparentes, meshes semitransparentes, destinos transparentes, filtragem linear/mipmap, color spaces alternativos, Images premultiplicadas, outras configurações de Canvas ou outros blends. Personagens/exportações externos e equivalência universal de renderização continuam pendentes.
