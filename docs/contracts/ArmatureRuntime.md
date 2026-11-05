# Orquestração e consultas de Armature

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, Armature.ts. Lidos os corpos restantes: _onSortSlots, init, advanceTime, containsPoint, intersectsSegment, getBoneByDisplay/getSlotByDisplay, proxy, replacedTexture e getDisplay. Consultado o backup Lua cd4206a8; lifecycle/registro/clock/cache/invalidUpdate/_sortZOrder/dispose foram portados nas etapas anteriores.

## Fluxo original

init é guardado por _armatureData: atribui modelo, empresta Animation real, guarda proxy/display/core, chama dbInit e só depois inicializa Animation e copia os modelos de animação. dbInit vê Animation emprestada mas ainda sem armature/config. Falha não desfaz as atribuições, como no pin.

advanceTime retorna se já estiver locked. Caso contrário, trava antes de validar modelo/parent. Avisos de descarte e exceções anteriores ao final conservam o lock; não foi adicionado finally. Em sequência: Animation.advanceTime; ordenação dos slots por zIndex*1000+zOrder e eventual reassinatura de ranks; propagação de alpha; Bone/Slot.update apenas se cache mudou ou é negativo; ações Play para armadura atual, slot filho ou slots do bone; retorno dos eventos de ação ao pool; limpeza da lista; unlock; dbUpdate. Erro em dbUpdate acontece depois do unlock. Ações são percorridas com length vivo; loops de update/ranks capturam length como os loops numéricos do pin.

WorldClock e DragonBones core agora podem chamar Armature real. O clock não avança animatables em delta zero, conforme sua implementação original; eventos são despachados pelo core depois do avanço e objetos adiados são devolvidos antes do clock do frame seguinte. Armature.dispose e o descarte dos filhos por Slot continuam adiados pelo core.

## Ordenação e fronteiras

_onSortSlots original retorna -1 também nos empates. table.sort exige um comparador estrito; por isso o adaptador usa inserção com a direção do comparador original. Scores finitos distintos têm ordem determinada. Empates são comparados contra o Node/V8 em arrays de três slots, inclusive empates entre zIndex fracionário e zOrder e repetição de frames. Não há promessa de ordenação universal para arrays maiores com esse comparador não estrito ou scores NaN; o resultado JS pode depender do algoritmo/engine. Esse limite é explícito, sem alterar o comparador para corrigir o original.

Arrays usam JSArray, length lógico e armazenamento Lua base um; ranks públicos permanecem base zero. Proxy é fornecido pelo host e precisa de dbInit/dbUpdate/dbClear e métodos de dispatcher. Avisos usam stderr em vez de console.warn. Demais coerções JS, reentrância arbitrária e objetos inválidos fora dos casos do contrato não são prometidos.

## Consultas e textura

containsPoint devolve o primeiro slot que contém o ponto na ordem atual. intersectsSegment preserva escolha do ponto A mais próximo e B mais distante, outputs opcionais, retorno nil se somente B foi pedido e a peculiaridade de usar a distância em X para B mesmo em segmento vertical. O normal sozinho não força cálculo dos pontos. getSlotByDisplay busca por identidade e rejeita nil; getBoneByDisplay deriva o pai desse slot. getDisplay é o alias original, proxy é somente leitura.

replacedTexture ignora a mesma referência, devolve o atlas substituto ao pool, limpa esse atlas e invalida/atualiza imediatamente cada Slot com cache -1. Não há carregamento ou desenho da textura neste módulo.

## Validação

armatureruntime_differential compara 456 cenários/466.072 colunas por VM Lua 5.4/LuaJIT, zero aproximações. Quatro exceções esperadas: dbInit, avanço depois do init incompleto, dbUpdate e escrita readonly de proxy. Grade: quatro animações, cache 0/4, timeScale -1/.5/1, alpha .25/1, três perfis de ordenação e avanço direto/pelo clock. Alpha muda também entre frames. Inclui momentos sem dirty/cache repetido, bones, Surface, malha/slots, IK, modelos/buffers, Animation/State/timelines, clock/core reais.

144 casos de consultas cruzam oito máscaras de outputs, seis segmentos (horizontal, inverso, vertical, diagonal, interno e miss) e três perfis de ordenação. São três retângulos sem rotação; resultados e normais são exatos. Os contratos numéricos anteriores de Slot/BoundingBox/Bone/Surface/IK continuam vigentes, sem novas tolerâncias; matrizes trigonométricas não são comparadas por esta suíte de integração.

Casos adicionais cobrem init guardado, reentrada locked pelo renderer, reentrada permitida em dbUpdate, pausa via lock, alpha do parent, troca/reuso de textura inclusive false, ações com alvo atual/slot/bone/filho ausente/tipo ignorado/dados ausentes e deduplicação, ação enfileirada em dbUpdate, dispose, modelo/parent descartados, erros de proxy, mudança de clock, flips, conclusão e fade automático. Renderer é subclasse observadora dos 14 hooks de Slot; atlas vazio é subclasse de backend apenas para lifecycle, sem criar texturas fictícias. Filhos usam Armature/init/Animation/Bones reais e são descartados pelos displays do Slot.

Oito mutações rejeitadas: init sem registro de modelos, avanço de Animation omitido, ordenação invertida, alpha omitido, guard de cache removido, ações omitidas, dbUpdate antes do unlock e ponto B alterado. Regressão animationfacade nas duas VMs. CI executa todas as 53 suítes e vinte e um exemplos por VM.

## Exemplo e próximo passo

`lua5.4 examples/run.lua armature` (também LuaJIT) usa Armature.init, Animation.play e core.clock para atualizar pose/mundo 0→20→40→20, trocar display, executar IK e despachar seis eventos locais. Três frames passam pelo clock porque o primeiro delta é zero; ao final lock=false. O backend só observa callbacks, sem desenhar. playback/animation mantêm suas demonstrações anteriores.

Todos os corpos de Armature.ts estão representados no domínio declarado. A montagem de Bones/Slots/constraints/displays ainda é explícita. Factories e backends gráficos são o próximo trabalho; isso não representa paridade integral com DragonBonesJS nem um player gráfico pronto.
