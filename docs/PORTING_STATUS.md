# Estado da reconstrução integral

## Objetivo central

Reconstruir o Bono-Lua em Lua a partir do DragonBonesJS oficial, seguindo sua arquitetura, algoritmos e comportamentos. A meta é equivalência funcional integral demonstrada por comparação com o original executado. Não substituir o motor por uma implementação própria nem declarar 100% sem auditoria e testes de todo o escopo.

Fonte única: DragonBones/DragonBonesJS@`64b6c69ae35777c2404be68c9192e2c56906079e`.
Destino único: SrTristeSad/Bono-Lua. Trabalho atual: `port/model-display-data`, sobre `main@975b031`. Checkpoints anteriores integrados com CI aprovada; não implica completude.

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

Próxima unidade: retomar ArmatureData.ts com GeometryData real agora disponível, auditando referências remanescentes e integração de cache sem stubs de produto. Armature/backend/listeners e runtime integrado continuam pendentes.
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

## Unidade atual: DisplayData, GeometryData e WeightData

Base main 975b0312d984313e7645fcc8d0d10026e49205d7, PR #70/CI pós-merge 41651358553 aprovados; backup cd4206a8 e fonte fixada limpa confirmados. Lidos DisplayData.ts completo, Lua real do backup e dependências; intArray de DragonBonesData declarado Int16Array. Destino dragonbones/model/DisplayData.lua, com as oito classes: GeometryData, DisplayData (abstrata), ImageDisplayData, ArmatureDisplayData, MeshDisplayData, BoundingBoxDisplayData, PathDisplayData e WeightData.

Executáveis reais: BaseObject/Enums, Point/Transform e JSArray; testes usam também ActionData/UserData e TextureData reais. GeometryData não herda BaseObject nem recebe hash/pool fictício; a base DisplayData continua abstrata e herda a falha de toString do BaseObject. GeometryData.clear devolve weight somente se não compartilhado; shareFrom altera somente isShared/offset/weight, sem copiar data/inheritDeform nem reciclar o peso anterior. Display base limpa transform/nome/path/parent antes dos resets/reciclagem específicos. Preservadas identidades de geometry, pivot, transform e arrays, duplicatas e regras de referências não proprietárias.

Execuções finais locais em Lua 5.4.8/LuaJIT: **33 cenários, 1.117 operações e 10.053 colunas por VM**, sem tolerância (binary64, NaN canonicalizado). Observados todos os campos declarados, getters/readonly, identidades/aliases, flags/ordem/pools/avisos, callbacks e estado parcial quando peso/ação/boundingBox falha. Cinco sequências determinísticas de 100 operações complementam cenários de compartilhamento, ações crescentes/esparsas, comprimento lógico e valores especiais.

Falha real na linha 106: get g vertexCount em offset não inicializado devolvia erro Lua, mas o original devolvia undefined. Corrigido nil numérico para NaN nessa adição e validado índice após BinaryOffset, antes de somar 1. Experimento que removeu a validação foi rejeitado na linha 124 (offset subnormal acessava indevidamente o primeiro elemento); outro com ipairs em actions foi rejeitado na linha 254 (clear retornava quando o original falhava em undefined). Código restaurado e testes finais refeitos nas duas VMs.

Fronteiras: SkinData/ArmatureData/BoneData/DragonBonesData e BoundingBoxData ainda não são classes de produto desta unidade. Registros de teste só fornecem referências, intArray já decodificado ou contrato returnToPool de boundingBox, documentados em contracts/DisplayDataReferences.md. Não validam typed arrays genéricos, parsing binário, hit testing, deformação, renderização/GPU ou armaduras/playback. Precisão temporal automática real continua pendente. CI/PR/merge deste checkpoint devem ser confirmados no SHA publicado.
