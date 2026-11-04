# Surface — geometria deformável do runtime

Fonte integral: Surface.ts e backup Lua, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Oito corpos portados: toString, _onClear, _getAffineTransform, _updateVertices, _updateGlobalTransformMatrix, _getGlobalTransformMatrix, init e update. O backup fornece tradução de referência, não oracle. O teste compila e executa a fonte TS fixada.

Usa Bone/TransformObject/Matrix/Transform/Point, SurfaceData/GeometryData e arrays tipados reais do parser, cache real de ArmatureData/DragonBonesData e registro real da Armature parcial. Superfície pode ter pai Bone ou Surface; o ponteiro _bone conserva o ancestral Bone ou nil. Bone filho consulta a matriz local da Surface real, inclusive nos caminhos com e sem ancestral Bone. Não há pais/constraints/slots simulados. Armature continua sem init/advanceTime/factory/player completos.

Arrays JSArray preservam length e holes; índices Lua base 1, offsets/caches do original base 0. Leituras numéricas ausentes viram NaN, não erro de soma de nil. init mantém _hullCache.length=10 e update escreve posições 10/11 JS, estendendo para 12. Mantém grafia _matrixCahce e o TODO interpolation original. Deformação é somada aos vértices antes de transformar pelo pai; não inventar aplicação de offset/animationPose na Surface onde a fonte não a faz.

Cada célula/triângulo armazena [flag,a,b,c,d,tx,ty]. Atualização dirty invalida flags antes de atualizar vértices. Consulta no centro/laterais seleciona triângulo e usa cache; regiões de fora retornam a matriz global própria. Consulta interna retorna o mesmo helper Matrix compartilhado, que será alterado por consultas posteriores, inclusive de outras instâncias. Copie seus valores se precisar conservá-los. O teste consulta duas vezes cada ponto e observa identidade, coeficientes e cache.

585 cenários/38.610 consultas/26.325 colunas por VM Lua 5.4/LuaJIT, duas falhas esperadas. Grades 1×1, 2×2 e 3×2; quatro cadeias de pais; deformações 0/10/-20; quatro flips; dois yDown; cache ligado/desligado. Pontos dentro, nas bordas ±200/±1000, laterais/quinas e fora. Inclui consulta antes do primeiro update, restauração de cache, deformação posterior, reinit, falta de armadura, geometria inválida e getter readonly. Geometria inválida pode propagar NaN como no original; não alegar recuperação/validação de todo arquivo corrompido. Identidade e limpeza de todos os arrays são observadas.

## Orçamento numérico

atan2/sqrt/sin/cos do host podem variar em binary64. Coeficientes e componentes de pose derivados de trigonometria: 32*epsilon*max(1,abs(expected)). Coordenadas derivadas de trig usam 32*epsilon*max(1000,abs(expected),magnitude máxima dos vértices/hull esperados do caso). A escala 1000 vem da projeção externa lB da fonte; evita tratar cancelamento próximo de zero como erro relativo bem condicionado.

Exemplo observado: diferença de 2,27e-16 no coeficiente c produz cerca de 9,06e-14 no hull ao multiplicar por 400. Essas diferenças podem cruzar zero em componentes calculados; são aceitas só no orçamento desses campos. Dois zeros exatos com sinais diferentes continuam falhando. Flags de cache, tamanhos/holes, deforms, parâmetros _dX/_dY/_k, índices, identidades e vértices sem pai/trig permanecem exatos. Foram 41.231 comparações aproximadas por VM, incluindo leituras repetidas do mesmo payload. Isso não relaxa as suítes anteriores de Bone/Transform. Não declara buffers ou poses Surface bit a bit idênticos entre libm e V8.

Domínio: segmentos inteiros positivos, consultas finitas e dimensões do corpus de teste; começa com objetos emprestados/limpos pelo pool. Não garante init antes de _onClear, índices/length arbitrários, coerções/reflexão/protótipos JS ou segmentos inválidos genéricos. Solvers, animação de deformação por timelines, callbacks de Slot e cleanup não vazio de Animation/Proxy continuam pendentes.

Exemplo `lua5.4 examples/run.lua surface`: grade real importada, osso filho em (50,50); ao mover o Y central da grade em +80, filho vai a (50,90). A alteração é manual, sem player/engine gráfico substituto. Próximo recorte: auditar Slot e suas interfaces abstratas/backends antes de integrar displays e solvers reais.
