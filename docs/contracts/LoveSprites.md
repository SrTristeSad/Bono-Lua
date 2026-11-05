# Primeiro backend gráfico LÖVE: sprites

Atualização posterior: meshes/deformação foram acrescentadas em [LoveMeshes.md](LoveMeshes.md); os limites abaixo descrevem o recorte original de sprites.

O documento RECONSTRUCTION_SPEC.md, etapa 09, prevê LÖVE como integração Lua separada do motor. Este recorte implementa sprites com atlas não rotacionado, transformações/pivot/trim, cor multiplicativa, alpha, visibilidade, ordem e blends Normal/Add. Meshes, atlas rotacionados e outros blends são recusados explicitamente; não estão implementados nem são declarados equivalentes.

## Fonte e adaptação

Lidos Pixi/4.x/src/dragonBones/pixi/PixiSlot.ts e PixiTextureAtlasData.ts no pin 64b6c69ae35777c2404be68c9192e2c56906079e. O ramo sprite e _updateTransformV4 são a referência. Os algoritmos de animação, parsing e montagem continuam nos módulos já portados. Love Factory fornece os três hooks reais de BaseFactory, Love Slot implementa o ramo sprite dos callbacks, TextureAtlasData mantém ownership de frames sem destruir a Image do chamador, Display fornece a ponte de scene graph/draw do host. Essas adaptações não declaram a integração Pixi completa.

Slot conserva escala do atlas*armadura, pivot calculado com a matriz original, sinal de skew de V4, alpha global*cor, tint arredondado para canais de 8 bits, troca do atlas pela replacedTexture e ausência de textura. Offsets de cor não são aplicados, como nesse ramo do Pixi original. As matrizes do scene graph seguem as fórmulas Pixi rotation/skew/scale. Quads são criados ao desenhar e liberados ao devolver o frame ao pool; a Image permanece do chamador. Desenho usa push/pop all para preservar estado gráfico do host.

Image/Canvas, draw e transform são APIs LÖVE 11.x. Construção, atualizações e inspeção numérica podem ser executadas em Lua 5.4/LuaJIT sem LÖVE; só desenhar requer o host. Recursos do atlas são Images fornecidas pelo chamador, não filenames inferidos. Display.onEvent pode receber o dispatcher de eventos da armadura; som permanece no eventManager do core fornecido.

## Validação

lovesprites_differential executa o PixiSlot/PixiTextureAtlasData originais transpilos do pin com probes da plataforma, e compara com o backend Lua usando runtime/factory reais: 56 cenários/11.188 colunas exatas por VM Lua 5.4/LuaJIT. Grade cruza alpha, tint, três escalas, flip e Normal/Add; extras cobrem hide, replacedTexture, remoção de textura, displayIndex=-1, stop, ordem, trim e cache. Números binary64, sinal de zero, transformações, frames, visibilidade, cor e ordem são comparados sem tolerância. Probes não são evidência de pixels.

O job love-pixels executa LÖVE real sob Xvfb/Mesa e o PixiSlot/PixiTextureAtlasData originais com PixiJS 4.8.9 CanvasRenderer real no Chromium. Captura oito cenas em RGBA e PNG e compara os canais: tempos 0/.25/.5/.75, alpha .5, tint .5, flip e mudança de ordem. Fundo opaco e atlas sintético de três regiões sólidas tornam as diferenças rastreáveis; não há imagem gerada ou screenshot fabricado. Cenas opacas exigem igualdade exata; somente alpha .5 permite um nível de 8 bits por canal, correspondente à quantização entre rasterizadores. Nenhum orçamento das suítes matemáticas foi alterado. Resultado gráfico deve ser lido no result.json e nos PNGs da CI; não inferir sucesso apenas do código.

A execução local não possui LÖVE/Xvfb; os testes locais são os diferenciais numéricos. A CI instala e executa os hosts reais, preservando RGBA/PNG/version/resultado no artefato love-pixi-pixel-evidence. O status dos jobs e evidências está no PR desta etapa. A suíte numérica sobe para 55 por VM, mantendo 22 exemplos de terminal, além do job gráfico separado.

## Executar

Na raiz do repositório, `love .` abre o exemplo gráfico editável. Espaço pausa, R reinicia, F espelha e Esc encerra. Ele importa skeleton/atlas, monta automaticamente e usa core.clock; os pixels do atlas de teste são criados com ImageData e enviados a uma Image real. Sem instalar LÖVE, `lua5.4 examples/run.lua factory` continua disponível para testar a montagem no terminal.

Próximos recortes gráficos: meshes/deformação, atlas rotacionado e blends restantes, seguidos de personagens/exports externos e mais referência visual. Armaduras filhas usam o scene graph básico, mas a equivalência de pixels de composições aninhadas complexas ainda não foi validada. Color multipliers de tint fora de [0,1], protótipos/coerções JS e callbacks reentrantes também estão fora deste recorte.

Referências de API do host: https://love2d.org/wiki/Transform:setMatrix e https://love2d.org/wiki/love.graphics.newQuad. Dependências de referência gráfica ficam no job de testes, não no runtime Lua.
