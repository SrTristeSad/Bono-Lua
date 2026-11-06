# Atlas rotacionados no backend LÖVE

Referência: Pixi/4.x/src/dragonBones/pixi/PixiSlot.ts e PixiTextureAtlasData.ts do commit 64b6c69ae35777c2404be68c9192e2c56906079e. A factory/parser/runtime continuam reais e separados do host gráfico.

O atlas conserva o booleano rotated no frame. O original passa rotate=true ao PIXI.Texture (normalizado pelo Pixi 4.8.9 para rotate=2), com orig/trim de largura e altura iguais às da região empacotada. O adaptador conserva essas dimensões; não as troca por conveniência. O pivô continua calculado pelo Slot original.

Sprite rotacionado desenha um Mesh estático com quatro cantos e dois triângulos: TL→TR da região, TR→BR, BR→BL, BL→TL. O recurso é compartilhado pelo frame e liberado no pooling, preservando a Image do chamador. Sprite não rotacionado continua usando Quad. Em meshes, UVs seguem literalmente u'=(x+(1-v)*width)/atlasWidth e v'=(y+u*height)/atlasHeight. Buffers, skinning, deformação, Surface e transforms não mudaram.

## Verificação

A fixture rotated_tex.json contém regiões retangulares, deslocadas e de tamanhos diferentes em uma Image de 64×32. Os diferenciais usam os blobs originais do upstream com probes de plataforma: sprites 56 cenários/11.857 colunas, meshes 82/22.352, exatos em Lua 5.4 e LuaJIT. Incluem pivô/trim, troca de textura, escala, cache, deformação e dimensões do atlas obtidas da imagem. Regressões sem rotação conservam suas entradas e critérios anteriores.

O job love-pixels renderiza dez cenas reais em LÖVE/Mesa e no Pixi 4.8.9 WebGLRenderer/Chromium. Cada região tem quadrantes assimétricos coloridos para revelar inversão, giro e troca de eixos. Casos: sprites/meshes, tempos diferentes, escala 2, flip, pivô+trim, troca de Image com cores diferentes, fallback de dimensões e atlas misto. São 819.200 canais RGBA exigidos idênticos, sem tolerância; resultado em rotation-result.json e capturas PNG/RGBA. A referência usa o PixiSlot/Atlas original compilado, não uma reimplementação das UVs no teste. LÖVE não está instalado no executor local; o teste gráfico precisa da CI real. Nenhuma captura é fabricada.

A CI mantém as oito cenas de sprites e oito de meshes anteriores e sobe para 58 suítes por VM, mais 22 exemplos de terminal.

## Uso e limites

Na raiz: `love .`. T alterna atlas normal/rotacionado; M alterna sprites/meshes; Espaço pausa, R reinicia, F espelha. As texturas assimétricas são dados de entrada do demo, não imagens de resultado predefinidas.

Prova limitada às cenas opacas determinísticas e filtros nearest descritos. Blends avançados, meshes semitransparentes, filtragem/transparência complexa de bordas, geometria degenerada e equivalência de composições aninhadas arbitrárias continuam pendentes. Não representa conclusão de todas as integrações oficiais nem validação de personagens externos.
