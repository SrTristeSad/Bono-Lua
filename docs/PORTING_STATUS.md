# Estado da reconstrução integral

## Objetivo central

Reconstruir o Bono-Lua em Lua a partir do DragonBonesJS oficial, seguindo sua arquitetura, algoritmos e comportamentos. A meta é equivalência funcional integral demonstrada por comparação com o original executado. Não substituir o motor por uma implementação própria nem declarar 100% sem auditoria e testes de todo o escopo.

Fonte única: DragonBones/DragonBonesJS@`64b6c69ae35777c2404be68c9192e2c56906079e`.
Destino único: SrTristeSad/Bono-Lua. Trabalho atual: `port/animation-worldclock`, sobre `main@e9ed0c9`. Checkpoints anteriores integrados com CI aprovada; não implica completude.

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

Próxima unidade: auditar core/DragonBones.ts, seus enums e contratos/dependências de EventObject/UserData antes de portar a fila de eventos. Demais core/modelos e runtime integrado continuam pendentes.
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

## Unidade atual: WorldClock e contrato IAnimatable

Fonte: animation/WorldClock.ts e IAnimatable.ts no commit fixado; versões reais do Lua no backup cd4206a8 e estado remoto/docs consultados. Destino executável: dragonbones/animation/WorldClock.lua. Interface sem algoritmo: docs/contracts/IAnimatable.md, sem classe Lua fictícia.

Preservados time/timeScale, momento da leitura de tempo e atualização de _systemTime, tratamento de NaN/tempos negativos, ordem de callbacks, compactação em duas passagens, add/remove/contains/clear e getter/setter clock com reciprocidade. Testes usam WorldClock original executado e relógios Lua reais aninhados; animatables de prova só fornecem callback/propriedade.

Execuções finais locais por VM: **28 cenários, 1.633 operações, 11.431 colunas**, aprovadas em Lua 5.4.8 e LuaJIT, sem tolerância numérica (bytes binary64, NaN canonicalizado). Inclui escala positiva/zero/negativa/não finita, tempo automático com origem determinística, alterações durante callback, reentrância, falhas parciais, provider que falha e identidade estrita.

Duas divergências do backup foram observadas e corrigidas sem alterar expectativas: __eq Lua fazia objetos distintos parecerem iguais, e ipairs encerrava clear cedo após reentrância criar posições undefined. Usa-se rawequal para a identidade JS; array com length lógico preserva null/undefined e efeitos parciais, inclusive RangeError de comprimento negativo causado pelo próprio algoritmo original.

**Pendência de plataforma:** os.time no Lua padrão fornece segundos, enquanto Date opera em milissegundos. _now é a fronteira configurável em segundos de época; os testes determinísticos comparam o algoritmo, não comprovam o relógio automático real. Não se escolhe silenciosamente love.timer.getTime, cuja origem monotônica é diferente da época original. A precisão do host ainda não é classificada como equivalente.
Core/eventos, Armature real e runtime gráfico continuam pendentes. CI deste checkpoint deve ser confirmada antes de integrar.

Checkpoint remoto: PR #67, commit 58d31973c4678e7c8ab7eea7ce64a7740ad00fd0. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41586314646 aprovada: inventory, geometry (lua5.4) e geometry (luajit). As cinco suítes passaram; WorldClock confirmou 28 cenários/1.633 operações/11.431 colunas em cada VM. Artefatos publicados por VM e inventário. Consultar PR #67 para SHA final e CI pós-merge; este registro não antecipa merge.
