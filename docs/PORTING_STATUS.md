# Estado da reconstrução integral

## Objetivo central

Reconstruir o Bono-Lua em Lua a partir do DragonBonesJS oficial, seguindo sua arquitetura, algoritmos e comportamentos. A meta é equivalência funcional integral demonstrada por comparação com o original executado. Não substituir o motor por uma implementação própria nem declarar 100% sem auditoria e testes de todo o escopo.

Fonte única: DragonBones/DragonBonesJS@`64b6c69ae35777c2404be68c9192e2c56906079e`.
Destino único: SrTristeSad/Bono-Lua. Trabalho atual: `port/parser-shared-binary`, sobre `main@a9e34b0`. Checkpoints anteriores integrados com CI aprovada; não implica completude.

## Etapa 00 — concluída

- Estado anterior preservado no backup remoto `backup/pre-integral-rebuild-20261103`: `cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb`.
- Backup anterior intacto; licença MIT e histórico preservados. Checkpoint inicial integrado na main pelo PR #63 (merge 71929d9) por autorização posterior do proprietário.
- Checkpoint publicado anterior confirmado: `f7f3060207b93807669f054692b29f59a79d4eb8`; CI estrutural [41575751744](https://github.com/SrTristeSad/Bono-Lua/actions/runs/41575751744) aprovada.

## Etapa 01 — catalogação e dependências estáticas disponíveis

1.203 caminhos rastreados; 192 arquivos autorais TS/JS, com classes/interfaces/enums, métodos, propriedades e correspondências propostas em UPSTREAM_INVENTORY.md.
DEPENDENCIES.md resolve referências estáticas de 175 arquivos TS em 17 contextos tsconfig isolados e registra imports de 17 arquivos JS, incluindo as responsabilidades dos sete builds JS. Evita misturar classes homônimas de versões de backend.
Cinco entradas externas solicitadas pelos tsconfigs não existem no commit: declarações Egret 4, Hilo 1, Phaser 2, Pixi 4 e @types/three. APIs, nomes não resolvidos e contratos dinâmicos ficam registrados; sua validação funcional permanece nas etapas 09/10.
A análise não afirma que o upstream inteiro compila com todas as dependências disponíveis, nem que resolveu referências dinâmicas. A classificação e o grafo são auditáveis e regeneráveis, não prova de equivalência.
As três classes iniciais não dependem de nenhum arquivo autoral externo nem API gráfica, conforme a resolução e a leitura manual. Podem ser portadas nesta ordem de dependências.

## Etapa 02 — geometria (histórico e estado)

| Fonte em DragonBones/src/dragonBones/geom/ | Destino Lua | Estado |
| --- | --- | --- |
| Point.ts | dragonbones/geom/Point.lua | Comparação diferencial isolada aprovada nos cenários descritos |
| Rectangle.ts | dragonbones/geom/Rectangle.lua | Comparação diferencial isolada aprovada nos cenários descritos |
| ColorTransform.ts | dragonbones/geom/ColorTransform.lua | Comparação diferencial isolada aprovada nos cenários descritos |
| Matrix.ts | dragonbones/geom/Matrix.lua | Comparação diferencial isolada aprovada nos cenários desta unidade |
| Transform.ts | dragonbones/geom/Transform.lua | Comparação diferencial isolada aprovada nos cenários desta unidade |

Os originais completos e os Lua do backup `cd4206a8` foram lidos e comparados antes de implementar. As três implementações existentes foram preservadas, sem trocar seus métodos por algoritmos novos; somente o caminho mudou para o mapa limpo desta reconstrução.
Métodos: construtores e copyFrom das três classes; clear de Point/Rectangle; identity de ColorTransform. Todos os campos declarados são comparados após cada operação.

## Validação do primeiro lote geométrico

`tests/geom_differential.js` lê os três blobs TS do commit fixado, transpila-os com TypeScript 2.4.2 e executa as classes originais em VM JavaScript. As mesmas operações são executadas pelo porte Lua. Não há clone manual do algoritmo no oráculo.

- Lua 5.4.8: **1.384 operações, 8.288 campos comparados; aprovado**.
- LuaJIT 2.1.1793383622: **1.384 operações, 8.288 campos comparados; aprovado**.
- Tolerância numérica: zero. NaN, infinitos e zero negativo comparados explicitamente.
- Cobertura: argumentos omitidos/undefined, cada posição de construtor, números finitos extremos/subnormais, cópia de registros inclusive esparsos, autocópia, resets repetidos, alteração pública, não mutação da origem e independência de instâncias.

São resultados isolados dessas três classes; integração de armaduras, animação, parsing e GPU não executada nesta reconstrução. Não existe motor completo ou demonstração gráfica nesta branch.

## Pendências e continuidade

Próxima unidade: continuar ObjectDataParser nas estruturas de armadura/bones/slots/skins e dependências originais; buffers/parsers completos ainda precisam de implementação/auditoria própria. Armature/backend/listeners e runtime integrado continuam pendentes.
Metatables, nil/default e ausência de distinção null/undefined estão documentadas em DIFFERENCES.md. Nenhuma equivalência irrestrita para chamadas JavaScript fora dos tipos TS foi afirmada.
Evidências e comandos em VALIDATION.md; cobertura legível por ferramenta em PORTING_PROGRESS.json; ponto de retomada em NEXT_STEPS.md.

## Histórico anterior

O backup contém o porte e os testes acumulados até a etapa antiga 61. Resultados antigos não são automaticamente atribuídos à reconstrução atual. Reaproveitar cada módulo exige ler o original, o Lua real e executar testes novamente.

## Checkpoint do primeiro lote confirmado no GitHub

Commit de código: `52ad145e74cb22f1d1bce38495e50d68bf2595a3`. PR #63 foi posteriormente integrado por solicitação explícita do proprietário (merge 71929d9).
[CI 41578753235](https://github.com/SrTristeSad/Bono-Lua/actions/runs/41578753235) aprovada: `inventory`, `geometry (lua5.4)` e `geometry (luajit)`.
Logs conferidos: Lua 5.4.6 e LuaJIT 2.1.1703358377 da CI executaram cada um 1.384 operações / 8.288 campos com tolerância zero e `result: passed`.
Artefatos confirmados: `pinned-inventory-evidence`, `geometry-differential-lua5.4`, `geometry-differential-luajit`; todos vinculados ao mesmo SHA. Somente as três classes deste lote foram validadas.

## Unidade anterior: Matrix e Transform

Fonte: geom/Matrix.ts e geom/Transform.ts no commit fixado. Portes: dragonbones/geom/Matrix.lua e Transform.lua; adaptador numérico JSNumberString.lua separado. Os códigos do backup foram comparados com os originais, preservando algoritmos e peculiaridades.

Teste `tests/math_differential.js` executa os TS originais e o porte Lua com entradas idênticas: **2.463 casos, 12.231 campos numéricos, 158 strings por VM**, aprovados em Lua 5.4.8 e LuaJIT local. Cobertura de todos os métodos declarados, construtores, constantes, aliases self, arrays/offsets, degenerações, reflexão, retângulos, valores especiais e 128 vetores determinísticos.
Diferença encontrada e corrigida: perda de -0 no arredondamento de Matrix.transformRectangle em Lua 5.4. Teste mantido com comparação exata de sinal. Trigonometria permite somente o limite explícito documentado em DIFFERENCES.md; 52 comparações não exatas dentro do limite em cada execução local. Strings e demais valores compararam exatamente.
Etapa matemática com cinco classes implementadas e validadas isoladamente nos cenários descritos. A equivalência integral e a integração não estão concluídas. CI de código confirmada: [41579761219](https://github.com/SrTristeSad/Bono-Lua/actions/runs/41579761219), três jobs aprovados em `7414985a8a9464f736a54f411b49e86cfebf035e`; logs e artefatos conferidos. PR #64 integrado em ab660cc; CI pós-merge 41579955766 confirmada aprovada.

## Unidade anterior: BaseObject

Fonte: core/BaseObject.ts no commit fixado; destino: dragonbones/core/BaseObject.lua. Original completo, versão real do backup cd4206a8, estado/docs da main e dependências consultados antes de implementar. Base confirmada ab660cc, com PR #64 e CI pós-merge 41579955766 aprovados.

O código antigo usava identidade de tabela de classe como chave de pool. O original usa String(construtor), com toString estático e compartilhamento do pool quando duas classes têm a mesma string. O porte atual preserva essa característica, herança do método, seu receptor e mudanças de construtor/string.

Preservados: hashCode monotônico em binary64, limite padrão 3000, LIFO, limpeza antes da devolução, ausência de nova limpeza ao retirar do pool, avisos condicionais de duplicata, flags de objetos descartados, limites por classe/globais, exceções de resize fracionário e efeitos parciais/ordem de for..in. Campos estáticos de estado continuam observáveis em BaseObject.

**Execuções locais reais:** 38 cenários, 1.211 operações e 12.110 colunas de transcrição comparadas por VM, Lua 5.4.8 e LuaJIT, sem tolerância. Cada linha inclui resultado/exceção, contador, limite, identidades, constructor, flags, estado/callbacks de limpeza, pools, limites específicos e avisos. O cenário de capacidade padrão cria 3.002 objetos. Subclasses instrumentadas existem somente no teste; não contam como modelos portados.

Um teste adicional revelou divergência na classificação de "-0" como nome de índice sob LuaJIT. A ordem foi corrigida para nomes canônicos de índices JS, mantendo o caso que acusa o efeito parcial de resize global fracionário. As execuções finais passaram nas duas VMs.
Integração com modelos concretos, comportamento genérico de protótipos JS e runtime completo continuam pendentes. Checkpoint de código `21cf986f7e23740f712672ce2e3f341d39b21bec`, PR #65; [CI 41581131475](https://github.com/SrTristeSad/Bono-Lua/actions/runs/41581131475) confirmada aprovada nos três jobs, com regressões e artefatos verificados. PR #65 integrado em 92c0105; CI pós-merge 41581381619 confirmada aprovada.

## Unidade anterior: CanvasData e dados de atlas/textura

Fonte fixa: model/CanvasData.ts e model/TextureAtlasData.ts; dependências executáveis BaseObject e Rectangle já portadas. Map é somente interface TS. Original completo e Lua real do backup cd4206a8 lidos antes de reaproveitar os módulos.

Destinos: dragonbones/model/CanvasData.lua e TextureAtlasData.lua (classes TextureAtlasData e TextureData). CanvasData preserva campos sem inicialização no construtor e os seis defaults em _onClear. Texturas preservam region por identidade, frame nulo/alocação/cópia/descarte e parent da origem; atlas preserva mapa por identidade, descarte antes da cópia, cópia em si mesmo, associação de parent no add e aviso de duplicata.

O teste executa os quatro originais TS correspondentes a BaseObject, Rectangle e aos dois arquivos de modelos. As classes abstratas usam subclasses mínimas somente no teste para toString/createTexture e injeção de falha; não há backend de produto inventado.
**Resultado local por VM:** 18 cenários, 639 operações e 5.751 colunas de transcrição aprovadas em Lua 5.4.8 e LuaJIT. Valores, identidades, flags, mapas, ordem de pool, avisos e estados parciais de falha comparados; referências parent ausentes/null e getTexture sem resultado são normalizadas para nil conforme a adaptação Lua explícita.

Uma divergência real do backup foi observada: pairs alterava a ordem de reciclagem/cópia e as identidades reutilizadas. O mapa público continua uma tabela; metadados privados preservam índices canônicos primeiro, demais nomes por inserção, inclusive exclusão/reinserção. Algoritmos de cópia e limpeza permanecem os originais. Nenhuma expectativa foi alterada para aceitar a falha.
CanvasData está integrado ao pool real; atlas/textura foram comparados com pool e retângulos reais. Renderização, parsers/armaduras e contratos de backends continuam pendentes, assim como chaves herdadas de Object.prototype e reflexão arbitrária. Checkpoint de código `eef0e925c11bb80295c539b16e23654de2522b0f`, PR #66; [CI 41583478829](https://github.com/SrTristeSad/Bono-Lua/actions/runs/41583478829) confirmada aprovada nos três jobs, com logs e artefatos conferidos. PR #66 integrado em e9ed0c9; CI pós-merge 41583759197 confirmada aprovada.

## Unidade anterior: WorldClock e contrato IAnimatable

Fonte: animation/WorldClock.ts e IAnimatable.ts no commit fixado; versões reais do Lua no backup cd4206a8 e estado remoto/docs consultados. Destino executável: dragonbones/animation/WorldClock.lua. Interface sem algoritmo: docs/contracts/IAnimatable.md, sem classe Lua fictícia.

Preservados time/timeScale, momento da leitura de tempo e atualização de _systemTime, tratamento de NaN/tempos negativos, ordem de callbacks, compactação em duas passagens, add/remove/contains/clear e getter/setter clock com reciprocidade. Testes usam WorldClock original executado e relógios Lua reais aninhados; animatables de prova só fornecem callback/propriedade.

Execuções finais locais por VM: **28 cenários, 1.633 operações, 11.431 colunas**, aprovadas em Lua 5.4.8 e LuaJIT, sem tolerância numérica (bytes binary64, NaN canonicalizado). Inclui escala positiva/zero/negativa/não finita, tempo automático com origem determinística, alterações durante callback, reentrância, falhas parciais, provider que falha e identidade estrita.

Duas divergências do backup foram observadas e corrigidas sem alterar expectativas: __eq Lua fazia objetos distintos parecerem iguais, e ipairs encerrava clear cedo após reentrância criar posições undefined. Usa-se rawequal para a identidade JS; array com length lógico preserva null/undefined e efeitos parciais, inclusive RangeError de comprimento negativo causado pelo próprio algoritmo original.

**Pendência de plataforma:** os.time no Lua padrão fornece segundos, enquanto Date opera em milissegundos. _now é a fronteira configurável em segundos de época; os testes determinísticos comparam o algoritmo, não comprovam o relógio automático real. Não se escolhe silenciosamente love.timer.getTime, cuja origem monotônica é diferente da época original. A precisão do host ainda não é classificada como equivalente.
Core/eventos, Armature real e runtime gráfico continuam pendentes. CI deste checkpoint deve ser confirmada antes de integrar.

Checkpoint remoto: PR #67, commit 58d31973c4678e7c8ab7eea7ce64a7740ad00fd0. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41586314646 aprovada: inventory, geometry (lua5.4) e geometry (luajit). As cinco suítes passaram; WorldClock confirmou 28 cenários/1.633 operações/11.431 colunas em cada VM. Artefatos publicados por VM e inventário. Consultar PR #67 para SHA final e CI pós-merge; este registro não antecipa merge.

## Unidade anterior: núcleo de eventos, enums e UserData/ActionData

Base confirmada: main 341df09, PR #67 integrado, CI pós-merge 41586449745 aprovada; backup cd4206a8 preservado. Lidos core/DragonBones.ts, event/EventObject.ts, model/UserData.ts e event/IEventDispatcher.ts completos e os respectivos Lua reais do backup antes de adaptar.

DragonBones.lua usa WorldClock e EventObject reais; EventObject/UserData usam BaseObject e Enums reais. Enums.lua contém os 98 valores originais, separados do core para evitar ciclo de require; o core reexporta as mesmas tabelas. Interface IEventDispatcher/EventStringType documentada sem criar dispatcher fictício. Empacotamento/shims exclusivos JS tratados como fronteira de linguagem em DIFFERENCES.md, não como runtime de plataforma implementado.

Execuções locais finais em Lua 5.4.8 e LuaJIT: **25 cenários, 1.147 operações, 16.058 colunas e 98 valores de enums por VM**, aprovados sem tolerância. Comparados fila/identidade, eventos adicionados durante despacho, reciclagem no avanço seguinte, disposição de armature, despacho local/global de som, reentrância, falhas/estados parciais, construtores/limpeza/pool, payload proprietário de ActionData e não proprietário de EventObject, conversão/consultas bone/slot e arrays/índices de UserData.

Uma falha real mostrou getInt(5e-324) retornando o primeiro elemento porque index+1 arredondava para 1 em Lua. Teste retido; índices fracionários dentro do intervalo agora produzem nil (undefined original), enquanto fora do intervalo retornam os defaults originais. Mutação controlada que restaurou == do backup nas filas falhou em bufferObject q (esperado p,q; observado p), confirmando a cobertura de identidade estrita. Código restaurado com rawequal e execuções finais refeitas.

Limites: Armature/dispatcher/animatable são probes de teste, não classes de produto portadas; três métodos de listeners e backend real pendentes. Referências objeto null/undefined viram nil; arrays públicos seguem convenção densa Lua/base 1, sem equivalência de propriedades/proxies JS arbitrários. Resolução automática do relógio continua pendente; esta unidade usa fonte determinística. CI inicial confirmada abaixo; merge e CI pós-merge devem ser consultados no PR.

Checkpoint remoto: PR #68, código 856b37a49ea10da7f4b43ba76da63c99dcb1a09a. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41634841014 aprovada: inventory, geometry (lua5.4) e geometry (luajit). Logs de ambos os jobs confirmaram seis suítes passed, incluindo 25 cenários/1.147 operações/16.058 colunas/98 enums no lote de eventos; três artefatos publicados no mesmo SHA. Consultar PR #68 para SHA final, merge e CI pós-merge; este registro não antecipa merge.

## Unidade anterior: AnimationConfig

Main inicial bc74a1a5206fe41c13717200613e81f4f65035f9, PR #68 e CI pós-merge 41635078122 aprovados; backup cd4206a8 confirmado intacto. Lidos AnimationConfig.ts completo e Lua real do backup. Dependências executáveis: BaseObject e const enums já portados; AnimationState é referência documental, não dependência executada por esta classe. Destino dragonbones/model/AnimationConfig.lua; sem carregar o runtime DragonBones só para obter enums.

Preservados construtor sem antecipar _onClear (somente boneMask inicializado), 21 campos escalares, defaults reais (timeScale=-100.0), clear, toString e a ordem de copyFrom. A máscara do destino mantém identidade durante cópia/limpeza; aliases, posições sem valor e comprimento lógico permanecem observáveis. Tabela base 1 com boneMask.length; não usar # em máscaras esparsas. Limpeza/truncamento não apagam propriedades nomeadas alheias aos índices do array.

Execuções locais finais em Lua 5.4.8 e LuaJIT: **30 cenários, 1.293 operações, 10.344 colunas por VM**, aprovados sem tolerância (binary64, NaN canonicalizado). Todos os 21 campos escalares são observados, junto com identidades, arrays, pools, avisos e ordem de leituras. Seis sequências determinísticas de 100 operações, falhas em dez posições de leitura de origem, new/borrow, autocópia, máscaras compartilhadas, índices altos e limites inválidos de length/pool.

Experimento reversível que restaurou # no comprimento de copyFrom falhou na linha 61 copy dest src, perdendo o comprimento lógico 5 da máscara esparsa. Código restaurado, testes finais refeitos. O driver inicialmente confundiu delete JS com atribuição nil em índice ausente; corrigido o transporte para rawset(mask,index,nil), que não aumenta length. Isso foi falha da infraestrutura, não nova regra do motor.

Limites: holes e undefined explícito comparados por valor/comprimento, sem equivalência de descritores/reflexão/proxies JS. Métodos nativos de Array não são API Lua; operações usam entradas base 1 e length. Consumo por Animation/AnimationState e armaduras reais não exercitado. Precisão automática de WorldClock e demais pendências do runtime continuam abertas. CI inicial confirmada abaixo; merge e CI pós-merge devem ser consultados no PR.

Checkpoint remoto: PR #69, código 52b1ded46b858d3bfd941c399e182bc0a3239d3d. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41645915590 aprovada nos jobs inventory, geometry (lua5.4) e geometry (luajit). Logs de ambas as VMs confirmaram sete suítes passed, incluindo AnimationConfig com 30 cenários/1.293 operações/10.344 colunas/21 campos escalares. Três artefatos conferidos no mesmo SHA. Consultar PR #69 para SHA final, merge e CI pós-merge; este registro não antecipa merge.

## Unidade anterior: AnimationData e dados de timelines

Base main b45b575d6a61fec17068f78f700a22b1bf9799b0; PR #69/CI pós-merge 41646190037 aprovados, backup cd4206a8 intacto, fonte fixada limpa. Lidos AnimationData.ts e ArmatureData.ts completos, Lua real dos dois arquivos no backup e relatório de dependências. ArmatureData não é instanciado nem chamado por AnimationData: cacheFrames lê parent.sortedBones/sortedSlots e name. Essa fronteira está documentada em contracts/AnimationDataParent.md; registros existem somente no teste. A classe real e seus demais algoritmos continuam pendentes.

Implementadas AnimationData, TimelineData e AnimationTimelineData em dragonbones/model/AnimationData.lua com BaseObject/Enums reais. Preservados construtores sem defaults antecipados, herança/limpeza, quatro mapas de listas de timelines, dois mapas de índices de cache, getters, deduplicação por identidade, ordem de reciclagem e estado parcial em falha. JSArray e JSMap extraídos de AnimationConfig/TextureAtlasData compartilham comprimento lógico e ordem própria JS, mantendo tabelas/identidades. Essas duas suítes de regressão passaram nas duas VMs após a extração.

Execuções finais locais por VM Lua 5.4.8/LuaJIT: **39 cenários, 1.084 operações e 11.924 colunas**, sem tolerância (binary64, NaN canonicalizado). Comparados todos os campos declarados, identidades de mapas/listas, valores/length de arrays esparsos, pools/flags/avisos, retorno/categoria de erro, callbacks de devolução, ordem/erros de leitura de parent e efeitos parciais. Cinco sequências determinísticas de 100 operações complementam os casos dirigidos.

Peculiaridade original preservada: cacheFrames usa this.cacheFrames.length, a aridade 1 da função, e escreve false apenas na posição JS 0. Mesmo se cacheFrameCount=0, essa escrita cresce cachedFrames para length=1, enquanto os índices dos bones/slots ficam vazios. Mutação temporária restaurando o clamp do backup falhou; == no lugar de rawequal também foi rejeitado. Código restaurado e testes finais refeitos. Um novo caso raw new revelou erro Lua precoce antes de o original gravar NaN e lançar RangeError; adaptados somente os números sem inicialização e a propagação de NaN de Math.max.

Limites: parent é registro de contrato no teste, não ArmatureData real; não valida sortBones, cache de transformações, animação/playback ou GPU. Mapas não emulam Object.prototype; holes/undefined normalizam por valor/length, referências null/undefined por nil; descritores, proxies e modificação da aridade da função não são equivalência declarada. Precisão temporal automática real continua pendente. CI inicial confirmada abaixo; merge e CI pós-merge devem ser consultados no PR.

Checkpoint remoto: PR #70, código 2b612757c2bfee0011db97cc3abea1a7de19625d. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41650945111 aprovada nos jobs inventory, geometry (lua5.4) e geometry (luajit). Logs de ambas as VMs confirmaram oito suítes passed; novo lote 39 cenários/1.084 operações/11.924 colunas. Três artefatos conferidos no mesmo SHA. Consultar PR #70 para SHA final, merge e CI pós-merge; este registro não antecipa merge.

## Unidade anterior: DisplayData, GeometryData e WeightData

Base main 975b0312d984313e7645fcc8d0d10026e49205d7, PR #70/CI pós-merge 41651358553 aprovados; backup cd4206a8 e fonte fixada limpa confirmados. Lidos DisplayData.ts completo, Lua real do backup e dependências; intArray de DragonBonesData declarado Int16Array. Destino dragonbones/model/DisplayData.lua, com as oito classes: GeometryData, DisplayData (abstrata), ImageDisplayData, ArmatureDisplayData, MeshDisplayData, BoundingBoxDisplayData, PathDisplayData e WeightData.

Executáveis reais: BaseObject/Enums, Point/Transform e JSArray; testes usam também ActionData/UserData e TextureData reais. GeometryData não herda BaseObject nem recebe hash/pool fictício; a base DisplayData continua abstrata e herda a falha de toString do BaseObject. GeometryData.clear devolve weight somente se não compartilhado; shareFrom altera somente isShared/offset/weight, sem copiar data/inheritDeform nem reciclar o peso anterior. Display base limpa transform/nome/path/parent antes dos resets/reciclagem específicos. Preservadas identidades de geometry, pivot, transform e arrays, duplicatas e regras de referências não proprietárias.

Execuções finais locais em Lua 5.4.8/LuaJIT: **33 cenários, 1.117 operações e 10.053 colunas por VM**, sem tolerância (binary64, NaN canonicalizado). Observados todos os campos declarados, getters/readonly, identidades/aliases, flags/ordem/pools/avisos, callbacks e estado parcial quando peso/ação/boundingBox falha. Cinco sequências determinísticas de 100 operações complementam cenários de compartilhamento, ações crescentes/esparsas, comprimento lógico e valores especiais.

Falha real na linha 106: get g vertexCount em offset não inicializado devolvia erro Lua, mas o original devolvia undefined. Corrigido nil numérico para NaN nessa adição e validado índice após BinaryOffset, antes de somar 1. Experimento que removeu a validação foi rejeitado na linha 124 (offset subnormal acessava indevidamente o primeiro elemento); outro com ipairs em actions foi rejeitado na linha 254 (clear retornava quando o original falhava em undefined). Código restaurado e testes finais refeitos nas duas VMs.

Fronteiras: SkinData/ArmatureData/BoneData/DragonBonesData e BoundingBoxData ainda não são classes de produto desta unidade. Registros de teste só fornecem referências, intArray já decodificado ou contrato returnToPool de boundingBox, documentados em contracts/DisplayDataReferences.md. Não validam typed arrays genéricos, parsing binário, hit testing, deformação, renderização/GPU ou armaduras/playback. Precisão temporal automática real continua pendente. CI inicial confirmada abaixo; merge e CI pós-merge devem ser consultados no PR.

Checkpoint remoto: PR #71, código ff97d497f1392f9142aab71fe57bead8e1a6e292. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41664061129 aprovada nos jobs inventory, geometry (lua5.4) e geometry (luajit). Logs de ambas as VMs confirmaram nove suítes passed; novo lote 33 cenários/1.117 operações/10.053 colunas. Três artefatos conferidos no mesmo SHA. Consultar PR #71 para SHA final, merge e CI pós-merge; este registro não antecipa merge.

## Unidade anterior: ArmatureData, BoneData, SurfaceData e SlotData

Base main 13ae3b1be3ed91e57a7215c01dd782d5b1df9b50, PR #71/CI pós-merge 41664512405 aprovados, backup cd4206a8 e fonte limpa/fixada conferidos. Relidos ArmatureData.ts completo e Lua real do backup; lidos também ConstraintData/SkinData/DragonBonesData TS para delimitar fronteiras. Destino dragonbones/model/ArmatureData.lua, quatro classes com BaseObject/Enums, Rectangle/Transform/ColorTransform e GeometryData reais.

Preservados construtores sem antecipar defaults, arrays/mapas por identidade, avisos/recusas de duplicatas, seleções padrão e vínculos parent. Estado privado da própria instância preserva undefined do construtor versus null após limpeza/atribuição nil em defaultSkin/defaultAnimation e BoneData.parent, embora ambos leiam nil publicamente. Ordenação mantém a varredura original por pai/alvo de constraint, identidade estrita e o comportamento parcial em erro; não introduz detector de ciclos.

Execuções finais locais Lua 5.4.8/LuaJIT: **34 cenários, 1.079 operações, 15.106 colunas por VM**, sem tolerância (binary64, NaN canonicalizado). Compara todos os campos declarados, identidades, mapas/listas, pools/flags/avisos, callbacks/leituras e falhas parciais. Cinco grafos acíclicos determinísticos têm operações adicionais de sort/cache/consulta; grafos não terminantes do original não são executados.

Integração nova: AnimationData.cacheFrames usa ArmatureData/BoneData/SurfaceData/SlotData reais, em vez do registro de parent da suíte isolada anterior. Cache de transformações usa Matrix/Transform reais, offsets públicos base 0, resize de dez posições antes das leituras e restauração x/y a partir de tx/ty. O armazenamento parent.cachedFrames ainda é contrato de DragonBonesData no teste. SurfaceData limpa GeometryData/WeightData reais; SlotData preserva DEFAULT_COLOR compartilhado e não devolve color.

Experimentos reversíveis: trocar as condições de null por leitura ==nil foi rejeitado na linha 56 add raw Skin one; remover validação antes da conversão de índice foi rejeitado na linha 372 load a out pose 5e-324. Produto restaurado e testes finais refeitos nas duas VMs. Sem relaxar expectativas/tolerâncias.

Limites: ConstraintData/SkinData/DragonBonesData reais ainda não portados; contratos remanescentes em contracts/ArmatureDataReferences.md. Cache integrado de modelos não prova runtime Armature, solver, playback, parsing/binário, GPU ou precisão temporal automática. Mapas não emulam Object.prototype; referências null/undefined normalizam nil externamente, decisões estritas específicas mantêm estado privado; holes/undefined por valor/length, sem descritores/proxies/reflexão genérica. CI inicial confirmada abaixo; merge e CI pós-merge devem ser consultados no PR.

Checkpoint remoto: PR #72, código 5e77b9bf9454c3ea3e0b52190e8025adc252cea9. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41672562343 aprovada nos jobs inventory, geometry (lua5.4) e geometry (luajit). Logs de ambas as VMs confirmaram dez suítes passed; novo lote 34 cenários/1.079 operações/15.106 colunas, incluindo cache com ArmatureData/BoneData/SurfaceData/SlotData reais. Três artefatos conferidos no mesmo SHA. Consultar PR #72 para SHA final, merge e CI pós-merge; este registro não antecipa merge.

## Unidade anterior: ConstraintData, IKConstraintData e PathConstraintData

Base main 57e7d48dc2c1e47cccc0fbd07db0b32297017c60, PR #72/CI pós-merge 41673223815 aprovados, backup cd4206a8 e fonte limpa/fixada conferidos. Lidos ConstraintData.ts completo e Lua real do backup; dependências executáveis BaseObject/Enums/JSArray disponíveis. Destino dragonbones/model/ConstraintData.lua, base abstrata e dois modelos concretos, sem criar solver de runtime.

Preservados construtores sem defaults antecipados (Path só cria bones), ordem de limpeza da base/herança e chaves toString/pool. A limpeza de Path mantém type=ConstraintType.IK definido pela base, como a fonte, sem atribuir Path. AddBone conserva a capitalização, duplicatas, comprimento lógico e referências não proprietárias; lista, root/target/bone, pathSlot e pathDisplayData não devolvem modelos referidos. Append preserva os passos de push, incluindo propriedade não índice escrita antes de RangeError ao ultrapassar 2^32-1, e sua sobrevivência à limpeza do comprimento.

Execuções finais locais em Lua 5.4.8/LuaJIT: **23 cenários, 817 operações, 7.353 colunas por VM**, sem tolerância (binary64, NaN canonicalizado). Todos os campos das três classes, defaults, aliases/identidades, length/entradas/propriedade não índice, hooks, pools/flags/avisos, erros e efeitos parciais comparados. Cinco sequências determinísticas de 80 operações complementam casos dirigidos.

Integração: ArmatureData.sortBones e _onClear usam IKConstraintData e PathConstraintData reais com BoneData/SurfaceData/SlotData/PathDisplayData reais. Não há registro de constraint substituindo classes nesta suíte. Preservados avisos de duplicata, falha de retorno e ordenação acíclica. Experimentos adicionando reset de type=Path e removendo o passo final de length de push foram rejeitados nas linhas 30/107; código restaurado e testes finais refeitos nas duas VMs.

Limites: são modelos de dados, não IKConstraint/PathConstraint executáveis ou deformação/playback. SkinData/DragonBonesData/Buffers/BoundingBoxData reais continuam pendentes, além do runtime/renderização e precisão temporal automática. Referências null/undefined normalizam nil; holes/undefined por valor/length; descritores/proxies/Array.prototype e reflexões genéricas não são equivalência declarada. CI inicial confirmada abaixo; merge e CI pós-merge devem ser consultados no PR.

Checkpoint remoto: PR #73, código db0c8806dfb903427ff51c47cfae58733571a391. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41676866452 aprovada nos jobs inventory, geometry (lua5.4) e geometry (luajit). Logs de ambas as VMs confirmaram onze suítes passed; novo lote 23 cenários/817 operações/7.353 colunas com integração de constraints reais. Três artefatos conferidos no mesmo SHA. Consultar PR #73 para SHA final, merge e CI pós-merge; este registro não antecipa merge.

## Unidade atual: SkinData e integração real de skins/displays

Base main 2e25e30c388a324aa314363038e98ceca649858e, PR #73/CI pós-merge 41677323508 aprovados, backup cd4206a8 e fonte limpa/fixada conferidos. Lidos SkinData.ts completo e Lua real do backup; dependências BaseObject/JSArray/JSMap e modelos de armadura/displays disponíveis. Destino dragonbones/model/SkinData.lua; construção só cria displays, sem antecipar name/parent.

Preservados mapa/listas por identidade, ordem própria JS, null explícito distinto de hole/undefined, atribuição parent antes do push e leitura da lista depois dessa atribuição, busca do primeiro nome, duplicatas e ownership original. SkinData.NULL é marcador único de linguagem, não classe de display. addDisplay(slot,nil) adiciona null; argumento omitido lança erro após criar a lista, como undefined original. Listas usam length e posição Lua base 1; consumidores precisam reconhecer o marcador, conforme contracts/SkinDataLists.md.

Execuções finais locais Lua 5.4.8/LuaJIT: **29 cenários, 814 operações, 8.140 colunas por VM**, sem tolerância (binary64, NaN canonicalizado). Observados todos os campos de SkinData, valores null/undefined/hole/refs, identidades/aliases, parent, pools/flags/avisos, callbacks/setters e efeitos parciais. Cinco sequências determinísticas de 80 operações complementam cenários de referência duplicada/compartilhada, chaves numéricas/reinserção, listas que crescem, exclusão de chave futura e chave nova durante enumeração.

Integração: ArmatureData.addSkin/getMesh/_onClear usa SkinData/displays/geometria/WeightData e ActionData/UserData reais. getMesh preserva o cast apagado do TS, sem novo filtro de tipo. Falha de peso atravessa display->skin->armadura mantendo o estado anterior. Chave criada por callback durante limpeza permanece para a próxima enumeração e pode sobreviver ao retorno/reuso da skin, como no original executado. Push no limite conserva parent/propriedade não índice antes de RangeError; slots nulos são ignorados, holes produzem erro e mantêm mapa/estado parcial.

Experimentos reversíveis: ipairs na limpeza de lista esparsa falhou em row 65 clear s (esperado erro, obtido void); tratar argumento omitido como null falhou em row 77 add s omitted omit. Produto restaurado e testes finais refeitos nas duas VMs, sem relaxar expectativas/tolerâncias.

Limites: esta integração não implementa seleção/renderização de skin no runtime, parser/typed buffers, deformação, solver, playback ou GPU. DragonBonesData global e BoundingBoxData reais continuam pendentes, além da precisão temporal automática. Mapas não emulam Object.prototype; refs null/undefined para nil fora das listas; hole/undefined próprios normalizam por valor/length, sem descritores/proxies genéricos. CI/PR/merge deste checkpoint devem ser confirmados no SHA publicado.


Checkpoint remoto: PR #74, código c5e6490abc9e67b7a9fafb94c5838944b047bbc3. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41680927368 aprovada: inventory, geometry (lua5.4) e geometry (luajit). Logs confirmaram doze suítes passed em ambas as VMs; SkinData: 29 cenários/814 operações/8.140 colunas. Três artefatos conferidos no mesmo SHA. Consultar PR #74 para SHA final, merge e CI pós-merge; este registro não antecipa merge.


## DragonBonesData — integração do contêiner global

Fonte TS completa e Lua do backup original/model/DragonBonesData.lua lidos. Implementação em dragonbones/model/DragonBonesData.lua usa BaseObject/JSArray/JSMap reais. Construtor não antecipa os defaults de _onClear; arrays/mapa mantêm identidade no clear/reuso. Armaduras são proprietárias, stage é só referência e userData é devolvido após o mapa de armaduras. addArmature verifica duplicata antes de parent, relê name depois do setter e grava mapa antes do push, inclusive estado parcial no overflow.

Comparação com TS genuíno em Lua 5.4 e LuaJIT: **32 cenários, 851 operações e 11.063 colunas por VM**, tolerância zero, binary64/NaN canonicalizado. Modelos reais cobrem cadeia DragonBonesData→ArmatureData→SkinData→MeshDisplayData→WeightData, falha/retry, leitura de GeometryData.intArray e cache set/get com Matrix/Transform. AnimationData real integrado. Buffers/views de JS são reais no oráculo; valores já decodificados são fornecidos à fronteira Lua pelo teste. Não é implementação de typed arrays/ArrayBuffer, parser, playback ou renderização.

Treze suítes na CI; consultar o PR deste checkpoint para SHA final, CI e merge confirmados. Próxima unidade: BoundingBoxData.ts; depois fronteiras binárias/parsers, mantendo o runtime e integrações gráficas explicitamente pendentes.


## BoundingBoxData — formas e consultas locais

Base main 84c9b07c761da1123f0440010a3ec0615e1709a5, PR #75/CI pós-merge 41684809994 aprovados e backup cd4206a8 conferido. Lidos BoundingBoxData.ts completo e Lua integral original/model/BoundingBoxData.lua do backup. Destino dragonbones/model/BoundingBoxData.lua: BoundingBoxData abstrata, RectangleBoundingBoxData, EllipseBoundingBoxData e PolygonBoundingBoxData; outcodes e todos os métodos estáticos/de instância preservados.

Resultado por VM Lua 5.4/LuaJIT: **125 cenários, 3.616 operações e 57.856 colunas**. Resultados exatos por bytes binary64/NaN canonicalizado, sinal do zero exato; somente normais não nulas derivadas de atan2 (inclusive aliases/valores preservados) admitem 8*epsilon*max(1,abs(expected)), com 300 comparações aproximadas por VM. Contagens, booleans, campos de modelos e componentes sem procedência de normal não recebem tolerância.

Preservadas peculiaridades upstream: pointB.y=xB quando endpoint A está dentro do retângulo; nome estático EllipseData; elipse escreve normais de duas interseções somente dentro das branches dos outputs correspondentes; polígonos perturbam segmentos/arestas e param na primeira interseção se pointB ausente; containsPoint compara pX/pY com width/height, enquanto broad phase usa x+width/y+height. Nenhuma correção geométrica própria. Agrupamento pY*(widthH/heightH) segue TS, corrigindo a ordem aritmética do backup.

Vertices usa JSArray lógico base 1/length; clear preserva identidade/extras e trata holes/length ímpar conforme aritmética undefined→NaN. Defaults não antecipados em new. Integração real DragonBonesData→ArmatureData→SkinData→BoundingBoxDisplayData→bounding box com falha/retry e pool. Falhas de setters dos outputs preservam escrita parcial/ordem, sem alterar receptor. Testes de mutação rejeitaram trocar a coordenada peculiar do retângulo e contar todas as interseções do polígono quando pointB está ausente; produto restaurado e testes finais refeitos.

Quatorze suítes na CI; consultar PR do checkpoint para SHA/CI/merge confirmados. Não implementa Slot/transformações de hit testing do runtime, parser, typed buffers, solver, playback ou renderização/GPU. Próxima unidade: DataParser.ts e contratos básicos de dados do parser, antes de ObjectDataParser/BinaryDataParser.


## DataParser — constantes e conversões da base abstrata

Base main da300139d0e96e5645c56483dccd327ccaa47fd6, PR #76/CI pós-merge 41687483454 aprovados e backup cd4206a8 conferido. Lidos DataParser.ts integral e Lua integral original/parser/DataParser.lua do backup. Destino dragonbones/parser/DataParser.lua, sem dependência de BaseObject/pool e sem implementar corpos abstratos de parseDragonBonesData/parseTextureAtlasData.

Resultado final nas duas VMs Lua 5.4/LuaJIT: **11.206 operações e 44.824 colunas**, tolerância zero. **132 constantes, dez conversões, duas assinaturas abstratas e 90 aplicações em modelos reais**. Oráculo enumera propriedades/métodos/cases por AST e executa TS genuíno. Cobertura inclui todas as combinações ASCII de maiúsculas/minúsculas de cada token reconhecido, palavras cruzadas entre helpers, desconhecidos, espaços sem trim, NUL, Unicode e 50 erros de tipos não string.

DATA_VERSION e DATA_VERSIONS preservam valores/ordem originais; 2.3/3.0 continuam constantes fora da lista suportada. Array de versões usa JSArray lógico, com identidade/herança estática, aliases, holes, truncamento, length 2^32−1 e extras comparados. Constantes e métodos protected/readonly de TS não ganham emulação de descritores no Lua. Grafia DRADON_BONES mantida.

Conversões aplicadas a ArmatureData/BoneData/SurfaceData, PathConstraintData, SlotData, displays/bounding boxes, AnimationData e ActionData reais, com campos antes/depois do clear/return e hash/flags do pool observados. Isso não é importação nem uma implementação de ObjectDataParser. Abstract methods permanecem ausentes, não retornam resultados fabricados.

Keyword matching baixa ASCII sem depender de locale C e reconhece K→k para darken. Auditoria de escalares Unicode do motor do oráculo encontrou Kelvin como fold não ASCII para letra ASCII; não é um lower Unicode genérico. Os três helpers com toLocaleLowerCase seguem o casing não túrquico/en-US validado; locales como tr/az podem divergir e permanecem pendência de host explícita. Experimentos de perder Kelvin e de fazer trim incorreto foram rejeitados; produto restaurado e teste final refeito nas duas VMs.

Quinze suítes na CI. Consultar PR do checkpoint para SHA/CI/merge confirmados. Próxima unidade: auditar ObjectDataParser.ts completo e Lua, começando pelos helpers de valores e parseTextureAtlasData com modelos de atlas/textura reais. Parsing de armaduras/animações JSON e binário/typed buffers, runtime e renderização continuam pendentes.


## ObjectDataParser — porte parcial de helpers e atlas

Base main 771b932f065cce3570c8073a8529a2b130ed0f1e, PR #77/CI pós-merge 41693321632 aprovados e backup cd4206a8 conferido. Auditado o recorte TS e Lua do backup de helpers, inicializadores, atlas, singleton e ActionFrame; inventário estrutural do arquivo inteiro identifica **47 métodos, 39 propriedades (38 de instância + singleton estático)**. Cinco métodos implementados; os 42 restantes não receberam stubs. Este lote não afirma auditoria semântica completa dos corpos ainda não portados.

Resultado final por VM Lua 5.4/LuaJIT: **39 cenários, 2.572 operações e 28.292 colunas**, tolerância zero por binary64/NaN canonicalizado, sinal do zero exato. Oráculo executa nove arquivos emitidos genuínos com ObjectDataParser/TextureAtlasData/TextureData/Rectangle/pool reais. As classes abstratas de atlas/textura recebem factory concreta só no teste; nenhum backend gráfico foi criado.

JSValue é adaptação de linguagem para valores já decodificados: NULL/UNDEFINED explícitos, presença separada de truthiness, arrays marcados base 1/length, Boolean/Number/String de primitivos/arrays/objetos simples. Não há JSON decoder. _getNumber mantém null ou string exata NaN como default, undefined/NaN numérico/zero como +0, e gramática JS para strings numéricas. _getBoolean mantém comparação literal de strings e truthiness JS. _getString reutiliza JSNumberString, distingue arrays vazios de objetos e rejeita toString próprio não chamável.

Atlas conserva ordem dos campos, reciprocal scale somente com argumento 1, coordenadas sem escala, frame só se ambas dimensões positivas, duplicatas rejeitadas sem devolver textura órfã e estado parcial de erros. Fila incrementa índice antes da recursão e relê o campo de fila após retorno; falha não reseta índice/fila. Console.assert de raw undefined é aviso, seguido da falha original. A fila é semeada somente no teste; parseDragonBonesData ainda não a popula no produto.

Singleton e todos os inicializadores de instância comparados; ActionFrame tem frameStart=0/actions lógico e exportação Lua no módulo. Experimentos de tratar undefined como null/default e aplicar escala às coordenadas foram rejeitados; produto restaurado e execuções finais refeitas. Dezesseis suítes na CI. Consultar PR para SHA/CI/merge confirmados.

Pendentes: 42 métodos do arquivo, parsing completo JSON/DBDT/texto, arrays tipados/buffers compartilhados, coerções/descritores/proxies/Object.prototype genéricos, locales especiais herdados de DataParser, runtime/solver/playback/renderização. Próximo recorte: modelos estruturais de armaduras, bones, slots e skins, mapeando todas as dependências de _parseArmature antes de acrescentar entrypoint de importação.


## Dependências estruturais de ObjectDataParser

Base main ff2db0ed4c5a54850354a2c5a0fbeb9a20935ed9, PR #78/CI pós-merge 41696197476 aprovados e backup cd4206a8 conferido. Lidos TS e Lua do backup dos nove métodos: transform/color/pivot, IK/Path, slot/action, bounding box/polygon. Dependências de bone/skin/display/armature identificadas como geometria/animação ainda ausentes; nenhum corpo parcial ou stub foi acrescentado a esses métodos. **14/47 métodos implementados, 33 pendentes**.

Novo lote: **55 cenários, 2.465 operações e 27.115 colunas por VM Lua 5.4/LuaJIT**, tolerância zero por binary64/NaN canonicalizado, sinal de zero exato. ArmatureData/BoneData/SlotData/SkinData/PathDisplayData/bounding boxes/constraints/ActionData/UserData e pool reais, inclusive subclasse de PathDisplayData. Coletor de alocações só observa borrowObject real e inclui órfãos/falhas depois de alocar.

UserData agora usa JSArray lógico nos três arrays para preservar length e getters com holes/undefined; suíte anterior de eventos passou localmente nas duas VMs. ArmatureData exporta adaptador interno _isNullReference para o parser conservar parent/defaultSkin undefined versus null; não é novo método upstream de armadura. IK com parent cru undefined e Path com defaultSkin cru undefined seguem ramos originais.

JSValue.iterator segue emit genuíno TS2.4 target ES5: índices e length vivo, inclusive array-like sem Symbol.iterator; strings iteram unidades UTF-16. Surrogates isolados são bytes WTF-8 em Lua, observados como UTF-16LE no transporte do teste. Fixtures JS são arrays do mesmo realm do oráculo (instanceof Array) e têm checagem positiva de modelos alcançados. Não é adoção de semântica ES2015 nova.

Cobertura: precedência rotate/skew sobre skX/skY e retenção de ângulos ausentes; escalas/extremos, cores percentuais/parciais, pivôs, tipos/defaults/erros de slots, ações gotoAndPlay com payloads esparsos e herança de refs, IK chain/parents, Path classe/subclasse/bones/ordem/duplicatas/ausentes, polígonos escalados/AABB/odd length/NaN/warning. Mutantes de colapsar undefined/null e reter máximo em vez de largura foram rejeitados; código restaurado e testes finais refeitos.

Dezessete suítes na CI; consultar PR para SHA/CI/merge confirmados. Próximo recorte: _parseGeometry e dependências completas para Surface/Mesh/Path antes de _parseBone/_parseDisplay/_parseSkin. Entry point, animação, typed buffers, runtime/solver/renderização e demais limites continuam pendentes.


## Geometria, bones, displays e skins do parser

Base main a2a3fe7216a8445351be86967db4e5c13fb59bb0, PR #79/CI pós-merge 41700176642 aprovados e backup cd4206a8 conferido. Lidos os sete corpos TS/Lua do backup e dependências: _parseGeometry/_parseArray/_parseBone/_parsePath/_parseMesh/_parseDisplay/_parseSkin. Auditados também Matrix.invert/transformPoint originais. **21/47 métodos implementados; 26 pendentes**. _parseArmature, animação, _modifyArray e parseDragonBonesData continuam ausentes.

Resultado final: **53 cenários, 2.498 operações e 34.972 colunas por VM Lua 5.4/LuaJIT**, tolerância zero por binary64/NaN canonicalizado/sinal do zero exato. Geometria/WeightData/bones/SurfaceData/meshes/paths/displays/skins/ações/armadura/DragonBonesData e matrizes reais. Contexto global/armadura/bones é semeado em teste, não importado por entrypoint fictício.

Reservas de arrays de trabalho preservam holes/length/identidade/extras. Offsets continuam base 0; armazenamento Lua base 1. Mantidas fórmula floor(length−vertexCount)/2, reserva anterior à contagem de bones, slot não preenchido no cabeçalho de peso e loop weightCount no ramo sem poses. Erros de comprimento fracionário/overflow mantêm estado anterior e alocações órfãs. Poses com matrizes gerais/singulares/incompletas usam Matrix real; nil/undefined propaga NaN em invert/transformPoint, sem trocar matriz por identidade. Regressão matemática anterior passou nas duas VMs (2.463/12.231/158; 52 diferenças trig já previstas).

Skin preserva placeholders null para raw falsy/undefined, índice de display para transferir ações, estado _skin/_slot em erro e limpeza após sucesso. Mesh share fica deferido em caches por presença da chave, inclusive null/undefined/false; resolução em _parseArmature segue pendente. Pose caches mantêm referências raw. Cadeia global→armadura→skin→mesh→weight exercitada com falha/retry no retorno.

Arrays ainda são trabalho numérico sem tipos; teste vincula referências a DragonBonesData para consultar GeometryData antes de haver _modifyArray. Não produz ArrayBuffer/Int16Array/Float32Array, arquivo JSON/DBDT ou renderização. Coeficientes de poses seguem o contrato numérico (incluindo holes); coerções JS genéricas de coeficientes não numéricos não são equivalência afirmada.

Mutantes de trocar weightCount por vertexCount e mover floor na expressão foram rejeitados (linhas 331/890); produto restaurado e execuções finais refeitas. Dezoito suítes na CI; consultar PR para SHA/CI/merge confirmados. Próximo recorte: _modifyArray e armazenamento binário compartilhado/typed views, com prova de alinhamento/coerção/bytes antes de entrypoints e animações restantes.


## Finalização binária compartilhada do parser — estado atual

Base main a9e34b08379183d4c59f4909a3d48cdd7327e33f, PR #80 e CI pós-merge 41729413783 conferidos. Auditados _modifyArray fixado e adaptador Lua do backup. **22/47 métodos; 25 pendentes.** Esta seção sucede os limites de buffers das unidades históricas acima.

SharedBinaryBuffer representa memória mutável única com sete views Int16/Uint16/Float32. Índices Lua base 1; offsets públicos de bytes base 0; representação little endian e snapshots explícitos por bytes(). DragonBonesData continua soltando referências ao retornar ao pool, sem destruir buffers retidos por outros aliases. Alinhamento mantém o teste duplicado de timelineArray e colorArray ímpar sem padding. Cópia/publicação/defaultColorOffset e efeitos parciais seguem a ordem original.

163 cenários/6.272 operações/70.166 colunas por VM Lua 5.4/LuaJIT, zero tolerância; 32 erros originais esperados. Oráculo usa _modifyArray genuíno e typed arrays nativas, sem reconstrução manual do algoritmo. Paridades, bytes exatos, Float32 ties-even/subnormais/overflow/-0/NaN, coerções, holes, aliases/snapshots, views sobrepostas, falhas de cópia e de publicação, geometria/pesos e pool reais. Dezenove suítes na CI. Consultar PR para evidência remota/SHA/merge confirmados.

Não implementa BinaryDataParser, entrypoint JSON/armaduras/animação, reflexão/proxies JS genéricos, payloads NaN arbitrários nem hosts big endian. Runtime/renderização continuam pendentes. Próximo recorte: curvas/frames e suas dependências para animações/timelines, antes de entrypoint completo.
