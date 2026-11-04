# Slot — dados de display

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, armature/Slot.ts. Foram lidos os quatro corpos integrais no TS e no backup Lua cd4206a8. O oráculo executa o TS, sem reproduzir o algoritmo no teste. Módulo dragonbones.armature.Slot; esta unidade estende SlotFoundation, sem fornecer renderer.

## Métodos e ordem

_updateDisplayData limpa as quatro referências selecionadas e lê DisplayFrame quando o índice está no intervalo. Só recalcula pivô/origin/matriz/flags quando muda a identidade do frame, geometria ou textura. BoundingBox é atualizada fora dessa guarda. Mudança isolada de offset, transform ou payload da caixa pode deixar os demais campos anteriores, conforme o original. Flags não são resetadas pelo método; o futuro Slot.update fará isso.

Imagem sem geometria usa escala atlas.scale×armatureData.scale; dimensão vem do frame de recorte ou region, invertendo width/height quando rotated sem frame. Soma os offsets do recorte, corrige o pivô com matrizes inversas do raw e substituto e conserva o TODO original. Usa DragonBones.yDown de runtime, não a tabela estática de enums. Origin prefere raw.transform, depois displayData.transform. Peso faz getBone por nome para cada posição, incluindo null e duplicatas; JSArray conserva o comprimento mesmo em misses.

As três APIs de substituição aceitam índice base 0, omitido/-1 seleciona o atual ou zero se estiver oculto. Índice explícito alto retorna sem tocar no estado. Não há validação antecipada de índice fracionário/NaN/frame ausente: a falha ocorre na leitura original. Trocar raw limpa deformVertices antes de gravar referência, procurar fallback e marcar dirty. Nil idêntico ao atual não entra na operação e não resolve skin. SkinData.NULL representa o null real de uma lista de displays e é traduzido com if explícito (and/or não preservaria nil). replaceDisplayData mantém a guarda de igualdade com raw, inclusive quando impede limpar o substituto com nil. replaceTextureData muda apenas o override do frame; a prioridade continua sendo a de DisplayFrame.getTextureData.

## Validação

1.224 cenários/11.016 etapas/182.376 colunas por VM Lua 5.4/LuaJIT; 146 etapas com exceção do original. Nove etapas por caso com snapshots de referências, pivôs, pose/matriz, flags, lista de ossos, dados do frame e deformações, seguidas de cleanup e transcrição dos hooks, que não devem ser chamados pelos quatro métodos de dados. Todos os números observados foram exatos localmente (zero aproximações). O comparador só admite até 8 eps relativos escalados por max(1,abs(expected)) nos casos chamados trig e nos campos matriz local/pose/pivôs; zeros, flags e referências permanecem exatos. Esse budget não é aplicado aos demais cenários.

Objetos de modelo/runtime reais; a subclasse de Slot do teste implementa somente os quatro hooks chamados por init/cleanup e não avalia displays. Atlas e TextureData abstratos são instanciados/limpos diretamente para fornecer metadados; não passam pelo pool abstrato nem ganham backend fictício. Raw/substituto são liberados separadamente; fallback pertence à skin real, frames não possuem modelos. Seis probes de mutação foram rejeitados, arquivo restaurado e testes finais nas duas VMs aprovados. SlotFoundation também reexecutado nas duas VMs.

## Fronteiras

Objetos iniciados pelo pool, metadados numéricos binary64 nas configurações do teste, referências null/undefined opcionais normalizadas nil, listas de skin densas com null explícito e arrays de geometria/pesos reais. Índices de arrays Lua são base 1, índices de APIs base 0. Missing runtime bones são posições nil com comprimento lógico, não removidos da lista.

Não cobre getters reentrantes, protótipos/proxies, coerções arbitrárias, holes criados manualmente em listas da skin, alocações enormes, contextos inválidos fora dos erros listados, renderização, avaliação de animação, troca do objeto gráfico, child playback nem chamadas automáticas de Slot.update. Esses métodos de dados não atualizam _display nem chamam hooks de renderização. Polígono/pai Surface/hit testing de aliases continuam com as limitações da unidade anterior.

Regressão de arredondamento: preservado o agrupamento TS pivot*(width*scale) e pivot*(height*scale), em vez de (pivot*width)*scale do backup Lua. O caso fractionalPivot com pivot.x=0,1, width=33,3, atlas.scale=0,1 e armature.scale=0,3 revelou divergência de 1 ULP antes da correção e é comparado sem tolerância. Esse caso foi acrescentado antes de integrar esta unidade.
