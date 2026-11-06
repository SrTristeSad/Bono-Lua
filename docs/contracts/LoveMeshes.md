# Meshes e deformação no backend LÖVE

Referência: Pixi/4.x/src/dragonBones/pixi/PixiSlot.ts no pin 64b6c69ae35777c2404be68c9192e2c56906079e. Lidos os ramos mesh de _updateFrame/_updateMesh e a criação com DRAW_MODES.TRIANGLES em PixiFactory. Algoritmos originais aplicados a buffers Float32/Uint16 do SharedBinaryBuffer; o renderer usa Mesh real do LÖVE, separado do runtime.

Atualização: atlas rotacionados foram acrescentados em [LoveRotation.md](LoveRotation.md). Os limites abaixo registram o checkpoint original de meshes.

## Caminhos

_updateFrame lê geometria/triângulos, corrige offset negativo com +65536, aplica armatureData.scale, calcula UVs do atlas e recria os buffers tipados. Conserva textureScale=1, dirty/indexDirty e identidade do display para skinning/Surface. Atlas rotacionado ainda é recusado pela classe de atlas; não está coberto por este recorte.

_updateMesh conserva três ramos: vértices comuns com deform local, skinning por contribuições ponderadas das matrizes dos bones e transformação por ponto no pai Surface. inheritDeform condiciona a soma dos deforms. No ramo ponderado, os cursores de peso/deform continuam avançando apenas quando o bone não é null, como no original; o caso de bone ausente não foi corrigido por conveniência. Matrizes/poses permanecem no runtime existente. As escritas finais arredondam para Float32 como as TypedArrays originais, sem tolerância nova.

Blend de mesh conserva a limitação original: PixiSlot._updateBlendMode só trata Sprite. Tint/alpha são aplicados ao mesh pelo ramo original de cor. Transformação de mesh ponderada/Surface fica identidade, porque os vértices já estão no espaço da armadura. Mesh não ponderada recebe o transform do Slot normalmente.

Display cria o recurso gráfico sob demanda, usa índices Lua +1 para Mesh:setVertexMap, atualiza vértices/UVs/mapa quando necessário e recria Mesh quando muda o número de vértices. A textura Image continua do chamador. Destroy libera o Mesh GPU, sem destruir a Image compartilhada. Culling é desativado durante o draw e o estado do host é restaurado por push/pop. Dados sem triângulos não são desenhados.

## Testes

lovemeshes_differential executa o PixiSlot original com probes da plataforma e o backend Lua com factory/runtime reais: 82 cenários/21.368 colunas por VM Lua 5.4/LuaJIT, zero aproximações. Colunas de arrays incluem todos os componentes tipados serializados. Grade cobre escalas .5/1/2, um/dois bones ponderados, inheritDeform, tamanho de atlas explícito/fallback e timeScale -1/0/1. Extras: bone ausente, padding que força offsets Float32 acima de 32767, sem FFD, textura removida/substituída, stop/cache/reset, tint/alpha e rebind que precisa resetar o transform. Mesma fixture contém mesh comum, ponderada e Surface, todas com animações/deforms reais.

Oito mutações verificam escala, UV, peso, soma de deform, Surface, offset negativo, reset de identidade e inheritDeform. Regressão de sprites permanece exata nas duas VMs. CI sobe para 56 suítes por VM e mantém 22 exemplos de terminal.

O job gráfico mantém as oito cenas anteriores de sprites/Pixi CanvasRenderer, com seus mesmos limites. Acrescenta oito capturas LÖVE Mesh e referência Pixi WebGLRenderer real no Chromium/SwiftShader: tempos 0/.25/.5/.75, escala 2, flip, inheritDeform=false e troca de Image com cores diferentes. Usa construção TRIANGLES do PixiFactory original. RGBA da referência WebGL é convertido de bottom-up para top-down, sem alterar valores dos canais. Essas cenas são opacas, atlas sólido e posições determinísticas; exigem igualdade exata de todos os 655.360 canais, sem orçamento de rasterização novo. Resultado em mesh-result.json e PNG/RGBA da CI; não inferir sucesso sem execução. LÖVE não está instalado localmente; prova gráfica é executada na CI real sob Xvfb/Mesa.

## Usar e limites

`love .` agora inicia a demonstração de meshes. M alterna sprites/meshes, Espaço pausa, R reinicia e F espelha. Os três displays mostram geometria comum, ponderada e Surface; não são personagens ou exports externos validados. O atlas de teste é ImageData enviada a uma Image real. Backend não foi declarado completo.

Atlas rotacionados, blends avançados, cenas de mesh semitransparentes, amostragem complexa/transparência de borda, geometria degenerada/corrompida e composições aninhadas arbitrárias ficam para próximos recortes. Mantêm-se os limites de ordenação e dos contratos anteriores; não foi ampliada nenhuma tolerância matemática nem a prova de sprites.

API de host: https://love2d.org/wiki/Mesh:setVertices e https://love2d.org/wiki/Mesh:setVertexMap . A referência gráfica usa os blobs DragonBonesJS fixados; dependências gráficas de teste ficam fora do runtime Lua.
