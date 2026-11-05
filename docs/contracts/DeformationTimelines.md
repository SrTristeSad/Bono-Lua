# Timelines de deformação

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, animation/TimelineState.ts. Lidos os corpos completos de SurfaceTimelineState e DeformTimelineState e as versões Lua do backup cd4206a8. Módulo DeformationTimelineState, herdando MutilpleValueTimelineState. Com bones/slots, são 10/16 classes portadas do arquivo, ainda parcial.

## Contrato

init lê metadados de deformação em frameIntArray usando offsets de AnimationData/TimelineData: quantidade total, quantidade animada, início do trecho animado e início dos valores fixos. _rd tem comprimento lógico valueCount*2, mesmo sem elementos inicializados. Buffers compartilham as views tipadas reais.

blend reconstrói os trechos fixo anterior, animado e fixo posterior; só o trecho animado recebe _valueScale na base, exatamente como o original. Não aplicar uma nova escala aos valores fixos. Primeiro blend substitui; posteriores acumulam. Poses sem dados zeram o resultado apenas quando BlendState.dirty==1. init repetido com nil preserva _valueArray e os demais campos anteriores, conforme o pin; os erros posteriores de update são comparados, não corrigidos silenciosamente.

Surface escreve em Surface._deformVertices e marca _transformDirty quando necessário. Deform escreve em displayFrame.deformVertices mesmo quando outra geometria está ativa, mas só marca Slot._verticesDirty se a identidade da geometria coincidir com displayFrame.getGeometryData(). Não trocar por comparação de conteúdo nem marcar todos os slots. displayFrame é referência não proprietária; _onClear limpa a referência e os metadados, sem devolvê-lo ao pool.

Apenas Deform corrige _sameValueOffset negativo com +65536 antes de somar frameFloatOffset. Surface mantém o offset negativo original; leitura ausente participa da aritmética como NaN via JSValue.number. Não estender a correção de uma classe à outra. _rd mantém identidade e é esvaziado pela limpeza herdada.

## Evidência e domínio

1.554 cenários/1.048.950 colunas por VM Lua 5.4/LuaJIT, 26 erros de etapas esperados e zero aproximações numéricas. Grade de 1.536 combinações: duas classes, pose/dados, quatro tweens, escalas 0,5/1/2, pesos -0,5/0/0,5/1,5, quatro regiões (incluindo zero valores animados e trechos fixos antes/depois) e duas variantes. Deform usa geometria com/sem pesos e variante com outra geometria ativa. Sete tempos incluem reverso, último frame e loop; cada um compara update e duas contribuições de blend. Outros 18 casos cobrem offset negativo, cleanBlend, reset, clear, single, lastLoop, stopped, reinit e displayFrame ausente. Os 26 erros esperados vêm de reinit e uso do displayFrame ausente.

O parser importa geometria real de examples/deformation_ske.json. Modelos, Surface/Bone/Armature/Slot, DisplayFrame, BlendState, pool e views Int16/Uint16/Float32 são reais. Só os quatro hooks abstratos necessários do Slot têm observadores de teste. AnimationState continua um registro explícito de campos consumidos, sem controlador/player substituto. Valores são comparados binary64 exato; NaN por categoria; flags, referências, buracos, comprimentos e limpeza também são exatos.

Domínio: buffers completos conforme fixtures, duração/FPS/escala temporal positivos e topologias declaradas. A importação genérica de deformação ponderada mantém seu TODO original; os buffers de animação ponderada deste diferencial são montados explicitamente. Não promete geração desses buffers pelo parser genérico nem player/renderização integrados. Nenhum budget de outra suíte foi alterado.

Cinco mutações deliberadas rejeitadas: remover trecho fixo anterior, deslocar trecho fixo posterior, ignorar identidade de geometria, mudar correção de offset negativo e omitir transformDirty da Surface. Fonte restaurada antes da execução integral final.

## Reprodução

`node tests/deformationtimeline_differential.js ../DragonBonesJS lua5.4` ou luajit; quarto argumento opcional seleciona índice/operação. Artefatos preservam entrada, expected, actual e resultado. `lua5.4 examples/run.lua deformationtimeline` usa as timelines importadas pelo parser, interpola Surface Y=0/40/80/40 e malha Y=0/10/20/10, e executa Bone/Surface.update reais. Montagem e tempos manuais, sem player ou renderer.
