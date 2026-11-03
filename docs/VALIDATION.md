# Validação

## Unidade inicial: preparação e inventário

Executado:

- Consulta GitHub dos dois repositórios e commit fixado.
- `git ls-remote --heads origin backup/pre-integral-rebuild-20261103`: backup no SHA registrado em PORTING_STATUS.md.
- `NODE_PATH=../tooling/node_modules node tools/inventory.js ../DragonBonesJS`: 1.203 arquivos, 182 unidades autorais, 240 classes; parser TypeScript 2.4.2 sem diagnósticos sintáticos nas unidades catalogadas.

- `NODE_PATH=../tooling/node_modules node tools/inventory.js ../DragonBonesJS --check`: comparação byte a byte aprovada, mesmas contagens.
- `git diff --check`: sem erros nos arquivos rastreados alterados.

Reprodução:

```sh
git clone https://github.com/DragonBones/DragonBonesJS.git ../DragonBonesJS
git -C ../DragonBonesJS checkout 64b6c69ae35777c2404be68c9192e2c56906079e
npm install --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
```

A verificação lê blobs Git, verifica o HEAD e compara o inventário completo byte a byte. Ela prova reprodutibilidade estrutural, não equivalência de runtime.
Na unidade inicial, Lua 5.4, LuaJIT e LÖVE não estavam instalados e testes de runtime/GPU não foram executados. Os resultados antigos ficaram exclusivamente no backup. As VMs foram compiladas localmente na unidade seguinte, descrita abaixo.
## CI confirmada do checkpoint

PR: https://github.com/SrTristeSad/Bono-Lua/pull/63 (rascunho, sem merge).
Commit da branch: `eac7d2b83f09ff572bd751616ab4e7218373ddbf`.
Execução: https://github.com/SrTristeSad/Bono-Lua/actions/runs/41575623832. Job `inventory` (125718301492): `completed/success`.
Confirmados: instalação via lockfile, comparação exata dos blobs fixados e publicação do artefato `pinned-inventory-evidence`.
`node --check tools/inventory.js` também executado localmente com saída 0.
A aprovação é exclusivamente estrutural; não cobre runtime Lua nem GPU.

## Unidade de início: três classes geométricas

Originais completos lidos: geom/Point.ts, Rectangle.ts e ColorTransform.ts, no commit fixado. Correspondências do backup `cd4206a8` lidas e comparadas; código das três classes preservado nos novos destinos dragonbones/geom/.

### Ambiente local e comandos realmente executados

VMs compiladas no workspace, sem instalar ou modificar dependências globais:

- Lua 5.4.8, fonte lua/lua@6e22fedb74cf0c9b6656e9fce8b7331db847c605. Build: `make -j4 MYCFLAGS='-std=c99 -DLUA_USE_LINUX' MYLIBS='-ldl'`.
- LuaJIT 2.1.1793383622, fonte LuaJIT/LuaJIT@ea9eb7edb5eac4a9d175d74523db34fac0fa5180. Build: `make -j4`.

A partir do checkout Bono-Lua:

```sh
NODE_PATH=../tooling/node_modules node tests/geom_differential.js ../DragonBonesJS ../lua54/lua
NODE_PATH=../tooling/node_modules node tests/geom_differential.js ../DragonBonesJS ../luajit/src/luajit
```

**Resultado de cada comando:** `operations: 1384`, `comparedFields: 8288`, `tolerance: 0`, `result: passed`.
A execução inicial do driver falhou por propagação dos dois retornos de assert para io.lines; corrigido exclusivamente no teste e reexecutado com sucesso nas duas VMs.

### Prova e limites

O oráculo lê blobs Git do SHA fixado, compila os três TS reais com TypeScript 2.4.2 e os executa num contexto VM. A mesma sequência de comandos vai para Lua; compara todas as propriedades após cada operação, retornos void e preservação da origem. Nenhuma expectativa numérica vem de algoritmo reimplementado em JS.
Valores finitos são comparados exatamente após conversão decimal de ida e volta em binary64; NaN, Infinity, -Infinity, -0 e undefined/nil têm marcadores explícitos. Nenhuma tolerância foi necessária porque este lote atribui campos, sem trigonometria.

Cenários: defaults omitidos/undefined, cada argumento posicional, finitos/extremos/subnormais, NaN/infinitos/zero negativo, autocópia, cópia esparsa, alterações de campos, resets repetidos e independência de instâncias. Não cobre Proxies/getters arbitrários nem todos os usos inválidos fora do contrato TS.

### Evidência reproduzível

O teste gera em artifacts/ (ignorado pelo Git): geom-cases.tsv, geom-original.tsv, transcrições Lua e JSON de resultado por VM. A CI publica esses arquivos em artefatos separados para Lua 5.4 e LuaJIT. Comandos de reprodução após npm ci:

```sh
node tests/geom_differential.js ../DragonBonesJS lua5.4
node tests/geom_differential.js ../DragonBonesJS luajit
```

Os resultados acima são execuções locais reais. A CI confirmada abaixo repetiu as comparações em suas próprias VMs. Testes de animação, parsers, armaduras e GPU continuam pendentes nesta branch.

### Revisão do inventário nesta unidade

A revisão encontrou dez JS de configuração, plugins de editor e carregadores fora do filtro inicial. Foram incluídos no inventário, com imports locais e efeitos de topo; o bundle Cocos distribuído foi reclassificado como arquivo gerado. Funções atribuídas a variáveis/propriedades, métodos de objetos e declarações de namespace agora aparecem no catálogo.
Contagens atuais: **1.203 arquivos, 192 unidades autorais TS/JS, 241 classes declaradas**. O número anterior de 182 unidades/240 classes foi um retrato da primeira versão do filtro, não completude funcional. São 175 TS em 17 contextos e 17 JS; cinco entradas externas ausentes registradas.
A análise não executou plugins, scripts de download nem geradores de package.json do upstream.

Verificações finais locais da unidade: `node --check` dos dois geradores e do oráculo sem erros; `git diff --check` sem erros; `node tools/inventory.js ../DragonBonesJS --check` reproduziu 1.203/192/241; `node tools/dependencies.js ../DragonBonesJS --check` reproduziu 175 TS, 17 JS, 17 contextos e cinco entradas externas ausentes. Comandos de análise executados com NODE_PATH=../tooling/node_modules para o compilador fixado, equivalente ao npm ci da CI.

### CI confirmada do primeiro lote

- Código publicado: `52ad145e74cb22f1d1bce38495e50d68bf2595a3`; [PR #63](https://github.com/SrTristeSad/Bono-Lua/pull/63), rascunho sem merge.
- [Execução 41578753235](https://github.com/SrTristeSad/Bono-Lua/actions/runs/41578753235): concluída com sucesso.
- `inventory`: job 125728353186 aprovado.
- `geometry (lua5.4)`: job 125728352982 aprovado; log confirmou Lua 5.4.6, 1.384 operações, 8.288 campos, tolerância zero e resultado passed.
- `geometry (luajit)`: job 125728352830 aprovado; log confirmou LuaJIT 2.1.1703358377 com as mesmas contagens e resultado passed.
- Artefatos publicados e não expirados na consulta: geometry-differential-lua5.4 (13205072006), geometry-differential-luajit (13204038196), pinned-inventory-evidence (13205002243), todos associados ao mesmo head_sha.

As versões da CI diferem das compiladas localmente; ambas as execuções locais e ambas as execuções CI passaram. Nenhum resultado de GPU ou equivalência integral é inferido desses jobs.

## Unidade Matrix/Transform e main

A pedido explícito do proprietário, PR #63 foi integrado na main: merge 71929d98cbb0461eab99d83e6fa7e0a3c4bf0584, confirmado pela API. Backup anterior confirmado em cd4206a8. Esse checkpoint permanece incompleto; a autorização posterior substitui a restrição anterior de não integrar checkpoints do porte.

Originais Matrix.ts/Transform.ts completos novamente lidos em DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, junto aos Lua reais de cd4206a8 e JSNumberString. Implementações preservadas, import adaptado ao mapa atual. Primeiro teste acusou diferença real de -0 em Matrix.transformRectangle. O wrapper de floor/ceil corrigiu apenas a fronteira Lua/ECMAScript; cenário mantido, sem relaxar a comparação.

### Execuções locais reais

```sh
NODE_PATH=../tooling/node_modules node tests/math_differential.js ../DragonBonesJS ../lua54/lua
NODE_PATH=../tooling/node_modules node tests/math_differential.js ../DragonBonesJS ../luajit/src/luajit
```

Cada comando final aprovou **2.463 casos, 12.231 campos numéricos, 158 strings**, com 52 diferenças de arredondamento dentro do limite previamente definido para trigonometria. A primeira execução Lua 5.4 falhou por -0; somente após a correção ambas as execuções passaram.

Oráculo: os dois TS genuínos são lidos de blobs do SHA fixado, compilados com TypeScript 2.4.2 e executados em VM. Inputs preservados do backup (22 casos Matrix, 44 Transform, 26 strings) e cenários adicionais determinísticos gerados pelo teste: construtores/defaults, todos os métodos, constantes, cópia/autocópia, concat com self, arrays/offsets/lacunas, degenerações, NaN/infinitos/-0, 128 vetores com seed fixa.
Valores especiais, sinais de zero, retornos, origem não modificada, estados do receptor das consultas, translações e strings são comparados exatamente. Só campos trigonométricos não nulos de fromMatrix/toMatrix aceitam `8 * 2^-52 * max(1, abs(esperado))`, pela fronteira V8/libm. Não se aumentou a tolerância após falha.

O driver gera math-cases.tsv, math-original.tsv, transcrição e JSON por VM em artifacts/. A CI publica-os junto à evidência do primeiro lote. Não foram executados testes de armadura/animação/GPU nesta reconstrução. Limites de coerção JS, locale e entradas dinâmicas documentados em DIFFERENCES.md.

Workflow também executa em push para main e port/**, permitindo verificar o commit efetivamente integrado.

### Checkpoint Matrix/Transform confirmado no GitHub

Código `7414985a8a9464f736a54f411b49e86cfebf035e`, [PR #64](https://github.com/SrTristeSad/Bono-Lua/pull/64). [CI 41579761219](https://github.com/SrTristeSad/Bono-Lua/actions/runs/41579761219) aprovada nos três jobs. Logs de geometry (lua5.4), job 125731580480, e geometry (luajit), job 125731580301, confirmaram regressões do primeiro lote (1.384/8.288) e novo lote (2.463/12.231/158, 52 diferenças dentro da tolerância trigonométrica predefinida). Job inventory 125731580518 também aprovado.
Artefatos geometry-differential-lua5.4, geometry-differential-luajit e pinned-inventory-evidence confirmados associados ao SHA de código acima.
O resultado da integração e a CI pós-merge devem ser conferidos pelo SHA da main no GitHub; esse resultado não é antecipado neste documento.

## Unidade BaseObject

Main/PR anterior confirmados: ab660cc, PR #64 integrado e CI pós-merge 41579955766 aprovada. Fonte lida integralmente: core/BaseObject.ts no SHA fixado, com o contrato de tipo Map de core/DragonBones.ts; Map é interface apagada na compilação, sem dependência executável adicionada ao produto. Lua real do backup cd4206a8 lido e comparado. Seu pool por identidade de tabela não foi reaproveitado como se fosse equivalente à chave string do original.

### Execuções locais reais

```sh
NODE_PATH=../tooling/node_modules node tests/baseobject_differential.js ../DragonBonesJS ../lua54/lua
NODE_PATH=../tooling/node_modules node tests/baseobject_differential.js ../DragonBonesJS ../luajit/src/luajit
```

Resultado final de cada comando: **38 cenários, 1.211 operações, 12.110 colunas comparadas, tolerância zero, passed**. Contagens incluem linhas de início de cenário e snapshots integrais por operação; não são contagem de módulos nem porcentagem de equivalência.

O oráculo compila e executa BaseObject.ts genuíno num contexto novo por cenário. As subclasses instrumentadas só fornecem _onClear, valores/filhos de teste e toString; não implementam o pool. A mesma sequência de comandos é executada pelo módulo Lua real.
Cada snapshot confere retorno/categoria de erro, hashCode/contador, limite padrão, objetos/identidades/constructor/flags, número/ordem de limpezas, valores/filhos, pools em ordem LIFO, limites por string e avisos exatos. Mapas são serializados por chave para comparar estado; efeitos parciais de erro verificam adicionalmente a ordem de enumeração JS.

Cobertura: limite padrão 3000 com 3002 objetos; colisões/alterações de strings de construtor; herança/receptor de toString; alteração de constructor de instância; devolução duplicada inclusive com pool cheio; devolução direta; clear seletivo/global; truncamento e flags de objetos descartados; limites zero, -0, negativos, NaN, infinitos e fracionários; override de classe sem pool; resize global parcialmente aplicado antes de RangeError; clear aninhado e clear que lança erro; hashCode perto de 2^53; oito sequências de 100 operações com seed fixa.

Um teste adicional acusou em LuaJIT o estado incorreto `-0:8;2:8` em vez de `-0:8;2:1.5` após erro global fracionário: a chave textual "-0" foi erroneamente tratada como índice. Corrigida a classificação para nomes canônicos, mantido o cenário e ambas as execuções finais aprovadas. Não foram alteradas as expectativas para aceitar a falha.

Evidência gerada em artifacts/: baseobject-cases.tsv, baseobject-original.tsv, saída Lua e JSON por VM. CI executa o novo teste e as duas suítes geométricas anteriores, publicando os arquivos. Resultado da CI do checkpoint confirmado abaixo; merge e CI pós-merge devem ser consultados pelo SHA efetivamente integrado.

Não validado: modelos reais/armaduras/parse/animação/GPU, protótipos arbitrários de mapas JavaScript ou construtores fora do contrato estático do runtime. Exceções comparam categoria e efeitos, não mensagens/stack traces de host idênticos.

### CI confirmada de BaseObject

Código `21cf986f7e23740f712672ce2e3f341d39b21bec`, [PR #65](https://github.com/SrTristeSad/Bono-Lua/pull/65). [CI 41581131475](https://github.com/SrTristeSad/Bono-Lua/actions/runs/41581131475) concluída com sucesso nos três jobs: inventory 125735978049, geometry (lua5.4) 125735977933 e geometry (luajit) 125735978036. Os jobs executam as regressões geométricas e o novo oráculo de BaseObject.
Três artefatos confirmados, associados ao mesmo head_sha: pinned-inventory-evidence, geometry-differential-lua5.4 e geometry-differential-luajit (estes contêm também baseobject-cases/original/actual/result).
A integração só pode ser afirmada após confirmação do merge e da main; não antecipada aqui.

## Unidade CanvasData / TextureAtlasData / TextureData

Estado inicial confirmado pela API: main 92c0105, PR #65 integrado, CI pós-merge 41581381619 aprovada; backup cd4206a8 preservado. Os dois TS completos e os dois Lua reais do backup foram lidos antes de reaproveitar código. Dependências reais BaseObject e Rectangle também consultadas; Map é tipo TS sem implementação de runtime faltante.

### Execuções locais finais reais

```sh
NODE_PATH=../tooling/node_modules node tests/models_differential.js ../DragonBonesJS ../lua54/lua
NODE_PATH=../tooling/node_modules node tests/models_differential.js ../DragonBonesJS ../luajit/src/luajit
```

**Por comando:** 18 cenários, 639 operações, 5.751 colunas de transcrição; tolerância zero; passed. Colunas contêm snapshots serializados de vários campos/mapas e resultados, não contagem de módulos ou porcentagem de cobertura.

Compilação do oráculo: namespace completo do núcleo TS fixado, com opções do tsconfig original (saída em memória, sem reescrever fonte). Só os quatro JS correspondentes a BaseObject, Rectangle, CanvasData e TextureAtlasData são executados no contexto VM. A checagem sintática e execução não são uma declaração de build integral de todos os backends. Subclasses locais dos dois modelos abstratos fornecem apenas toString/createTexture e falha controlada; não reimplementam limpeza/cópia/pool nem simulam renderização.

Números são comparados por bytes IEEE-754 binary64 em little-endian, preservando zero negativo, extremos/subnormais e infinitos; NaNs usam marcador canônico. Lua 5.4 usa string.pack, LuaJIT usa ffi apenas no transporte de teste, sem dependência ffi no produto. Strings/booleans/undefined são distinguidos por tipo. Referências JS parent ausentes/null e lookup sem resultado normalizam para nil; essa normalização não é tolerância numérica nem prova de distinção universal null/undefined.

Cobertura: construtores crus versus borrow inicializado; todos os campos de Canvas e propriedades extras preservadas; toString estático; limpeza/retorno/duplicatas/limites; região por identidade; criação/cópia/reutilização/descarte de frame; mapa por identidade; copyFrom com parent da origem; add duplicado com parent preexistente; lookup ausente/presente; descarte antes da cópia; cópia em si mesmo; ordem numérica/inserção e exclusão/reinserção por escrita pública; falha de createTexture com estado parcial e nova tentativa; quatro sequências de 80 operações determinísticas; valores numéricos especiais.

Falhas observadas e resolvidas antes da aprovação:

- O driver inicial transpila arquivos isoladamente e não resolve o namespace BaseObject. Passou a compilar o namespace genuíno junto, sem aliases globais de simulação. Também corrigido um conflito de nome de variável do driver.
- Na operação copy dest src, pairs no porte antigo reatribuía objetos de pool a chaves diferentes das do original. Adaptada a ordem do mapa mantendo algoritmo e expectativas; os testes finais passaram nas duas VMs.

Artefatos regeneráveis em artifacts/: models-cases.tsv, models-original.tsv, transcrição e JSON por VM. CI inclui esses resultados e as três suítes anteriores (geometria, matemática e BaseObject). CI do checkpoint de código confirmada abaixo; merge e CI pós-merge devem ser consultados pelo SHA efetivamente integrado.

Não comprovado: renderer/backend concreto, parsing/armaduras/animação, coerções/reflexão genérica JS ou chaves herdadas especiais de Object.prototype. As classes de dados não são um backend gráfico completo. A próxima dependência escolhida para o core é WorldClock, com auditoria explícita da origem do tempo.

### CI confirmada dos modelos

Código `eef0e925c11bb80295c539b16e23654de2522b0f`, [PR #66](https://github.com/SrTristeSad/Bono-Lua/pull/66). [CI 41583478829](https://github.com/SrTristeSad/Bono-Lua/actions/runs/41583478829) aprovada nos três jobs: inventory 125743437769, geometry (lua5.4) 125743437741 e geometry (luajit) 125743437620. As duas VMs executaram as quatro suítes, incluindo o novo teste de modelos.
Artefatos geometry-differential-lua5.4, geometry-differential-luajit e pinned-inventory-evidence confirmados com o mesmo head_sha; incluem os arquivos models-cases/original/actual/result. A integração e a CI pós-merge devem ser verificadas separadamente no GitHub.

## Unidade WorldClock / IAnimatable

Base confirmada e9ed0c9, PR #66 e CI pós-merge 41583759197 aprovados. Lidos WorldClock.ts e IAnimatable.ts completos no commit fixado, Lua real de cd4206a8 e documentos de status/dependências antes de modificar.

### Execuções locais finais reais

```sh
NODE_PATH=../tooling/node_modules node tests/worldclock_differential.js ../DragonBonesJS ../lua54/lua
NODE_PATH=../tooling/node_modules node tests/worldclock_differential.js ../DragonBonesJS ../luajit/src/luajit
```

Resultado final de cada comando: **28 cenários, 1.633 operações, 11.431 colunas, tolerância zero, passed**. A comparação serializa números por bytes binary64 (NaN canonicalizado); compara campos time/timeScale/_systemTime, proprietários, comprimento/posições da lista, chamadas e sua ordem, fonte de tempo lida, retornos/categorias de erro e estado parcial. Não é porcentagem de equivalência.

O oráculo executa WorldClock.ts genuíno em VM com Date determinístico (milissegundos); o Lua usa a mesma fonte convertida por *0.001 para segundos. Nenhuma lógica de agendamento foi reimplementada em JS. IAnimatable é contrato sem código emitido; probes só fornecem callback e clock como campo simples ou setter recíproco. Relógios aninhados são WorldClock reais nas duas linguagens.

Cobertura: defaults, NaN e zeros assinados, escala positiva/zero/negativa/não finita, tempo automático e relógio andando para trás, leitura temporal mesmo no avanço zero, add duplicado, remove/clear, contains por ancestralidade, getter/setter clock, mutação durante callbacks, compactação em duas passagens, adição tardia, callbacks que falham, origem de tempo que falha, reentrância e efeitos parciais de arrays com undefined/comprimento inválido. Oito sequências de 100 operações determinísticas complementam os cenários. Ciclos só são inspecionados em consultas finitas e quebrados antes de avançar; não foi adicionado detector de ciclos ao motor.

Falhas reais observadas antes da aprovação:

- add c b ignorava um segundo animatable porque __eq Lua dizia que dois objetos distintos eram iguais. Corrigido com rawequal onde o TS usa identidade estrita.
- Após avanço reentrante encolher a lista, clear c retornava void, mas o original lançava erro no slot undefined. Corrigidos comprimento lógico e iteração por índice. O cenário de comprimento negativo preserva RangeError lógico do próprio upstream, em vez de inventar clamp/guard de semântica diferente.

Preflight adicional do driver Lua substitui apenas os.time/love.timer por primitivas de teste e confirma que o default usa época de os.time, sem selecionar o timer monotônico de LÖVE. Não demonstra precisão real em milissegundos.

**Limitação conhecida de plataforma:** stock Lua oferece os.time em segundos. Os testes comprovam o algoritmo com fonte determinística, não equivalência da fonte automática real. _now é fronteira de host em segundos de época, configurável antes de criar relógios. Não se usa os.clock nem âncora híbrida inventada para alegar um Date equivalente.

Evidências em artifacts/: worldclock-cases.tsv, worldclock-original.tsv, saída e JSON por VM. A CI executa esta e todas as quatro suítes anteriores e publica seus artefatos. CI inicial confirmada abaixo; merge e execução pós-merge devem ser consultados no PR.
IAnimatable fica em docs/contracts/IAnimatable.md; o inventário aponta o contrato, sem contar uma classe de runtime inexistente. Armature real, eventos/core completos e GPU continuam pendentes.

Checkpoint remoto: PR #67, commit 58d31973c4678e7c8ab7eea7ce64a7740ad00fd0. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41586314646 aprovada: inventory, geometry (lua5.4) e geometry (luajit). As cinco suítes passaram; WorldClock confirmou 28 cenários/1.633 operações/11.431 colunas em cada VM. Artefatos publicados por VM e inventário. Consultar PR #67 para SHA final e CI pós-merge; este registro não antecipa merge.

## Núcleo DragonBones, EventObject, UserData/ActionData e enums

Fontes fixadas: core/DragonBones.ts, event/EventObject.ts, model/UserData.ts e contrato event/IEventDispatcher.ts no commit único. BaseObject/WorldClock genuínos também são executados. O compilador recebe o namespace original; o teste executa somente os cinco arquivos pertinentes e ativa preserveConstEnums para inspecionar os valores originais, sem reescrever algoritmos. Host Date determinístico; console.info/warn observados.

Comandos locais reais:

```sh
NODE_PATH=../tooling/node_modules node tests/events_differential.js ../DragonBonesJS ../lua54/lua
NODE_PATH=../tooling/node_modules node tests/events_differential.js ../DragonBonesJS ../luajit/src/luajit
```

Resultado final por VM: **25 cenários, 1.147 operações, 16.058 colunas e 98 valores de enums; passed**. Tolerância zero; números por bytes binary64 e NaN canonicalizado. Referências objeto JS null/undefined normalizadas nil. Cada operação observa retorno/erro, estáticos e getters, time do clock, filas, campos/aliases de objetos e arrays, pools/ordem/flags, armatures live/disposed, chamadas, hooks pendentes, mensagens e avisos. Seis sequências de 100 operações determinísticas complementam cenários direcionados.

Cobertura: deduplicação estrita, esvaziamento e crescimento de filas por callbacks, eventos de som local/global e mudança de tipo durante despacho, armature descartada, manager ausente, erros locais/globais/de clock/de retorno ao pool, reentrância, descarte no avanço seguinte e limites de pool. Modelos: new versus borrow, todos os campos/reset, payload devolvido por ActionData mas não por EventObject, getters/add de UserData com defaults/limites/índices fracionários/NaN/infinitos, arrays preservados por identidade e conversão de ações Play/Frame/Sound/desconhecida, consultas bone/slot, campos antigos e falhas parciais de lookup.

Falha observada: getInt u 5e-324 retornava binary64 -0 (primeiro elemento) em vez de undefined devido ao arredondamento index+1. Corrigida verificação de integralidade antes do deslocamento; os três getters e índices próximos de 1 mantidos no teste. Experimento temporário restaurando == nas filas falhou em bufferObject q (esperado p,q; obtido p), confirmando o teste de __eq; arquivo restaurado antes das execuções finais.

Probes de Armature/dispatcher/animatable só implementam fronteiras ainda não portadas e falhas programadas. O núcleo, pool, relógio, eventos e os dois modelos são reais nos dois lados. Não é validação de Armature, listener registry, áudio/GPU, shims de plataforma JS ou precisão temporal automática real.

Artefatos regenerados: events-cases.tsv, events-original.tsv, events-enums-original.tsv e saídas/valores de enums/JSON por VM. CI executa as seis suítes e publica evidências. CI inicial confirmada abaixo; merge e CI pós-merge devem ser consultados no PR.

Checkpoint remoto: PR #68, código 856b37a49ea10da7f4b43ba76da63c99dcb1a09a. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41634841014 aprovada: inventory, geometry (lua5.4) e geometry (luajit). Logs de ambos os jobs confirmaram seis suítes passed, incluindo 25 cenários/1.147 operações/16.058 colunas/98 enums no lote de eventos; três artefatos publicados no mesmo SHA. Consultar PR #68 para SHA final, merge e CI pós-merge; este registro não antecipa merge.

## AnimationConfig

Fonte model/AnimationConfig.ts no commit único, original integral e Lua real do backup lidos antes da implementação. tests/config_differential.js compila o namespace genuíno e executa somente BaseObject.ts/AnimationConfig.ts emitidos; const enums são resolvidos pelo compilador a partir do core original. Nenhum core/AnimationState fictício é introduzido no oráculo ou produto.

Execuções locais finais:

```sh
NODE_PATH=../tooling/node_modules node tests/config_differential.js ../DragonBonesJS ../lua54/lua
NODE_PATH=../tooling/node_modules node tests/config_differential.js ../DragonBonesJS ../luajit/src/luajit
```

**30 cenários, 1.293 operações e 10.344 colunas por VM; passed.** Tolerância zero, bytes binary64 (NaN canonicalizado). Cada operação compara retorno/categoria de erro, os 21 campos escalares de cada instância, campos extras, identidades de objeto/máscara, comprimento e entradas definidas da máscara, campos nomeados, pools/flags/LIFO/limites/avisos e sequência de leituras de getters. Colunas agregam vários campos, não representam uma porcentagem de equivalência.

Cenários: raw new versus borrow, clear repetido, defaults reais, cópia de todos os campos e de campos ainda não inicializados, alteração independente da origem/destino, cópia em si mesmo, aliases de máscara, máscaras densas/esparsas/vazias, strings vazias/repetidas/UTF-8, crescimento/truncamento, índice máximo e length 2^32-1 sem materializar bilhões de posições. Valores especiais/preservação de sinal e subnormais nos campos numéricos; limites zero/negativos/fracionários/NaN/infinitos no pool e em length; seis sequências determinísticas de 100 operações.

Getters são instalados somente em instâncias reais de origem do teste e observam a ordem de copyFrom. Dez posições (incluindo primeira, intermediárias, leitura de boneMask e elemento depois do resize) permitem sucesso ou falha deliberada; estado parcial do destino é comparado. Não emulam o algoritmo de cópia. Snapshot lê armazenamento do probe sem acionar getters/falhas fora da chamada observada.

Verificação de regressão: experimento temporário usando # em copyFrom foi rejeitado na linha 61 copy dest src, com máscara de comprimento lógico 5 e apenas o índice JS 3 definido. Produto restaurado e comandos finais refeitos nas duas VMs. A primeira execução também detectou falha no transporte Lua de delete de índice ausente; corrigida para rawset(...,nil), mantendo as expectativas originais.

Normalização explícita: holes/undefined de máscara comparados por valor e length; descritores/hasOwnProperty/proxies/Array.prototype não são equivalência declarada. Animation/AnimationState/Armature ainda não consomem essa classe no produto e não foram validados aqui. Precisão temporal automática real continua pendente.

Artefatos regeneráveis: config-cases.tsv, config-original.tsv, config-<vm>-actual.tsv e config-<vm>-result.json. CI executa as sete suítes e preserva evidências por VM. CI inicial confirmada abaixo; merge e CI pós-merge devem ser consultados no PR.

Checkpoint remoto: PR #69, código 52b1ded46b858d3bfd941c399e182bc0a3239d3d. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41645915590 aprovada nos jobs inventory, geometry (lua5.4) e geometry (luajit). Logs de ambas as VMs confirmaram sete suítes passed, incluindo AnimationConfig com 30 cenários/1.293 operações/10.344 colunas/21 campos escalares. Três artefatos conferidos no mesmo SHA. Consultar PR #69 para SHA final, merge e CI pós-merge; este registro não antecipa merge.

## AnimationData e dados de timelines

Originais completos AnimationData.ts/ArmatureData.ts e versões Lua reais do backup lidos; fonte fixada confirmada limpa. O novo oráculo compila o namespace genuíno, executando somente os JS emitidos de BaseObject e AnimationData (três classes). Const enums resolvidos pelo compilador; nenhuma classe ArmatureData ou versão reescrita dos algoritmos no oráculo. Contrato de leitura do parent exercitado por registros locais/getters de nome somente no teste.

Execuções finais reais em ambas as VMs:

```sh
NODE_PATH=../tooling/node_modules node tests/animationdata_differential.js ../DragonBonesJS ../lua54/lua
NODE_PATH=../tooling/node_modules node tests/animationdata_differential.js ../DragonBonesJS ../luajit/src/luajit
```

**39 cenários, 1.084 operações e 11.924 colunas por VM; passed.** Tolerância zero, bytes binary64 (NaN canonicalizado). Cada operação observa retornos/categorias de erro, campos escalares e referências, identidades/valores/length de mapas/listas/cache, arrays retornados e aliases, campos herdados de timelines, pools/LIFO/limites/flags/avisos, callbacks/leituras de nome e hooks pendentes. Colunas agregam campos; não são porcentagem de equivalência.

Cobertura: raw new versus borrow e defaults; herança de TimelineData/AnimationTimelineData; getters ausentes/existentes; adição única nas quatro coleções com __eq adversário; retorno de listas em ordem própria JS, nomes numéricos/canônicos/-0, exclusão/reinserção; listas que crescem durante callbacks, chaves excluídas/adicionadas durante enumeração, lista esparsa que gera erro e devolução com falha parcial/retry. Referências actionTimeline/zOrderTimeline podem repetir objetos já contidos em mapas, preservando avisos/flags.

Cache: positivo evita nova execução mesmo com parent nulo; scale/rate/duration fracionários, negativos/zero/NaN/infinitos, contagens zero/inválidas, limite 2^32-1 com parent vazio sem alocar bilhões de valores, arredondamento e número extra de frame. Apenas slot JS 0 inicializado false por cacheFrames.length=1, inclusive contagem zero que reestende cachedFrames; valores preservados/truncados ao recache e índices -1 com nomes repetidos/antigos. Leitura bones antes de slots, falha em getter de nome e hole no parent preservam efeitos parciais. Cinco sequências determinísticas de 100 operações e números extremos/subnormais/zeros assinados complementam os cenários.

Falha real adicional: raw new seguido de cache gerava erro Lua antes de o original atualizar cacheFrameRate para NaN e lançar RangeError de tamanho. Corrigida somente a interpretação numérica de campos sem inicializador e assegurada propagação NaN de Math.max. Caso mantido no lote final.
Experimentos temporários no lote anterior de 38 cenários: clamp math.min(1,cacheFrameCount) do backup rejeitado em row 155 cache d 1 (faltava false/length=1 quando count=0); == rejeitado em row 56 add d Bone same b. Produto restaurado e comandos finais de 39 cenários refeitos nas duas VMs.

Regressões após extrair representações para JSArray/JSMap: config_differential aprovou 30 cenários/1.293 operações/10.344 colunas e models_differential aprovou 18 cenários/639 operações/5.751 colunas em cada VM. Nenhuma expectativa/tolerância alterada nessas suítes.

Limites: parent é contrato, não ArmatureData/BoneData/SlotData portados; sortBones, cache de dez componentes, playback/armaduras/GPU e precisão temporal automática real não foram exercitados. Referências null/undefined normalizadas nil; holes/undefined por valor/length, sem descritores/protótipos/proxies. A aridade é a da função original; não prova reflexão/redefinição genérica de Function.length.

Artefatos regeneráveis: animationdata-cases.tsv, animationdata-original.tsv e saídas/JSON por VM. CI executa as oito suítes e preserva evidências. CI inicial confirmada abaixo; merge e CI pós-merge devem ser consultados no PR.

Checkpoint remoto: PR #70, código 2b612757c2bfee0011db97cc3abea1a7de19625d. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41650945111 aprovada nos jobs inventory, geometry (lua5.4) e geometry (luajit). Logs de ambas as VMs confirmaram oito suítes passed; novo lote 39 cenários/1.084 operações/11.924 colunas. Três artefatos conferidos no mesmo SHA. Consultar PR #70 para SHA final, merge e CI pós-merge; este registro não antecipa merge.

## DisplayData, GeometryData e WeightData

Originais DisplayData.ts completo e Lua real do backup lidos. O oráculo compila o namespace genuíno e executa os arquivos emitidos de BaseObject, Point, Rectangle, Matrix, Transform, UserData, TextureAtlasData e DisplayData. Const enums resolvidos pelo compilador. Não há versão reescrita dos algoritmos no JS, backend ou implementação fictícia de modelos externos.

Execuções finais reais:

```sh
NODE_PATH=../tooling/node_modules node tests/displaydata_differential.js ../DragonBonesJS ../lua54/lua
NODE_PATH=../tooling/node_modules node tests/displaydata_differential.js ../DragonBonesJS ../luajit/src/luajit
```

**33 cenários, 1.117 operações e 10.053 colunas por VM; passed.** Tolerância zero, bytes binary64/NaN canonicalizado. Cada operação compara retorno/categoria de erro, todos os campos declarados por classe, referências, identidades de primitivos/geometry/arrays, comprimento e valores, pools/hash/flags/LIFO/limites/avisos, callbacks/hook pendentes e efeitos parciais. Colunas agregam campos, sem porcentagem de equivalência.

Cobertura das oito classes: raw new versus borrow e defaults, base abstrata preservando type e falhando ao pedir chave de pool, construtor de GeometryData sem BaseObject; clear repetido, retorno/reuso, identidades de Point/Transform/GeometryData, herança/ordem de resets. Compartilhamento em si mesmo, peso próprio/compartilhado, shareFrom preservando data/inheritDeform e não devolvendo peso anterior; falha de retorno antes dos resets de GeometryData. Getters com dados Int16 e offsets válidos/omitidos/negativos/fracionários/subnormais/limites/NaN/infinitos, arredondamento efetivo com BinaryOffset, readonly e data/intArray ausentes.

Display: textura real não proprietária em imagem/malha, pivot/transform, skin/armature opacos não devolvidos; ações reais com UserData, duplicatas, crescimento/encolhimento de lista durante retorno e erro em posição undefined; falhas antes dos resets específicos de ArmatureDisplay, após type/flags de Mesh/Path e antes de type em BoundingBox. WeightData preserva duplicatas/holes e não devolve bones; curvas com números extremos/zeros/NaN, length 2^32-1 sem materializar bilhões de entradas, comprimentos inválidos e propriedades extras persistentes. Cinco sequências determinísticas de 100 operações complementam os cenários dirigidos.

Falha real: linha 106 get g vertexCount em offset sem inicialização devolvia erro Lua em vez de undefined. Corrigida interpretação numérica localizada e validação antes do deslocamento para base 1. Experimento removendo a validação foi rejeitado na linha 124 (subnormal virava posição 1); outro substituindo o loop de actions por ipairs foi rejeitado na linha 254 (esperado erro por undefined; obtido void). Produto restaurado e comandos finais refeitos nas duas VMs, sem alterar expectativas/tolerâncias.

Limites: registros locais só representam referências externas/Int16Array já decodificado/returnToPool de boundingBox. Não validam BoneData/SkinData/ArmatureData/DragonBonesData/BoundingBoxData reais, parser de bytes, coerções/propriedades genéricas de typed arrays, hit testing, renderização, deformação ou playback. TextureData cru é classe real usada como referência não proprietária, sem subclasse gráfica. Referências null/undefined normalizam nil; holes/undefined por valor/length, sem descritores/proxies/Array.prototype. Precisão temporal automática real permanece pendente.

Artefatos regeneráveis: displaydata-cases.tsv, displaydata-original.tsv e saídas/JSON por VM. CI executa as nove suítes e preserva evidências. CI inicial confirmada abaixo; merge e CI pós-merge devem ser consultados no PR.

Checkpoint remoto: PR #71, código ff97d497f1392f9142aab71fe57bead8e1a6e292. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41664061129 aprovada nos jobs inventory, geometry (lua5.4) e geometry (luajit). Logs de ambas as VMs confirmaram nove suítes passed; novo lote 33 cenários/1.117 operações/10.053 colunas. Três artefatos conferidos no mesmo SHA. Consultar PR #71 para SHA final, merge e CI pós-merge; este registro não antecipa merge.

## ArmatureData/BoneData/SurfaceData/SlotData e integração com AnimationData

ArmatureData.ts completo e Lua real do backup relidos; dependências de ConstraintData/SkinData/DragonBonesData auditadas no TS antes de definir fronteiras. O oráculo compila o namespace genuíno e executa os arquivos emitidos de BaseObject, Point/Rectangle/Matrix/Transform/ColorTransform, UserData, CanvasData, DisplayData, AnimationData e ArmatureData. Nenhum clone dos algoritmos no JS nem classe de produto fictícia.

Execuções finais reais:

```sh
NODE_PATH=../tooling/node_modules node tests/armaturedata_differential.js ../DragonBonesJS ../lua54/lua
NODE_PATH=../tooling/node_modules node tests/armaturedata_differential.js ../DragonBonesJS ../luajit/src/luajit
```

**34 cenários, 1.079 operações e 15.106 colunas por VM; passed.** Tolerância zero, binary64/NaN canonicalizado. Após cada operação: retorno/erro, campos declarados/refs, identidades de arrays/mapas/primitivos, defaults, poses/cores, pool/hash/flags/LIFO/limites/avisos, chamadas de cache/retorno/delegação e efeitos parciais. Colunas agregam campos, sem porcentagem de equivalência.

Cobertura das quatro classes: raw new versus borrow, clear repetido, reuso, defaults e aliases; diferença entre refs undefined do construtor e null após limpeza/atribuição; skin default por nome e seleção inicial de animação, duplicatas/getters ausentes/existentes, delegação getMesh com MeshDisplayData real por contrato de skin. Ordenação em lugar de chains pai/filho/surface e constraints target/root com __eq adversário, repetição, lista vazia e erro parcial em hole. Cinco grafos acíclicos determinísticos com ordem de inserção embaralhada e 70 operações adicionais por grafo. Não há teste que execute ciclos não terminantes do original.

Limpeza: ordem de ações default/normais, mapas de bone/slot/constraint/skin/animation, canvas/userData; chaves canônicas/não canônicas, exclusão/reinserção, callbacks que excluem entradas, ações que crescem e holes com erro. Falhas de UserData antes de resets de Bone/Surface/Slot, GeometryData/WeightData após super.clear de Surface, identidade de primitivos e cores não proprietárias; DEFAULT_COLOR compartilhado versus createColor independente.

Cache: AnimationData percorre ArmatureData/BoneData/SurfaceData/SlotData reais, produzindo índices por nome; guarda positiva, falha/ordem de animações, atualização antecipada do rate, exclusão de mapa por callback e rate raw undefined. Armazenamento de dez componentes com Matrix/Transform reais, offset base 0, resize antes das leituras, holes/valores undefined, falha deliberada de leitura após dois componentes, range inválido antes de qualquer gravação e x/y restaurados de tx/ty. Leitura com offsets negativos/fracionários/subnormais/undefined/NaN/infinitos; números extremos e sinais de zero preservados. O registro parent.cachedFrames global não é DragonBonesData real.

Experimentos reversíveis: substituir decisões estritas de null por getter ==nil falhou em row 56 add raw Skin one (skin escolhida no construtor antes da limpeza); remover validação de índice antes de +1 falhou em row 372 load a out pose 5e-324 (primeiro componente deveria ser undefined, outros seguem o arredondamento efetivo de +1 etc). Código restaurado e comandos finais refeitos nas duas VMs, sem relaxar expectativas/tolerâncias.

Limites: ConstraintData/SkinData/DragonBonesData são registros de fronteira somente no teste, definidos em contracts/ArmatureDataReferences.md. Não comprovam solver/skin ownership/typed buffers reais, runtime Armature, parsing, playback ou GPU. A normalização pública null/undefined para nil mantém decisões estritas selecionadas em estado privado, sem emulação universal de descritores/proxies/Object.prototype; holes/undefined comparam por valor/length. Timeout de subprocesso (10s) é proteção de teste, não comportamento do motor nem detector de ciclos.

Artefatos regeneráveis: armaturedata-cases.tsv, armaturedata-original.tsv e saídas/JSON por VM. CI executa as dez suítes e preserva evidências. CI inicial confirmada abaixo; merge e CI pós-merge devem ser consultados no PR.

Checkpoint remoto: PR #72, código 5e77b9bf9454c3ea3e0b52190e8025adc252cea9. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41672562343 aprovada nos jobs inventory, geometry (lua5.4) e geometry (luajit). Logs de ambas as VMs confirmaram dez suítes passed; novo lote 34 cenários/1.079 operações/15.106 colunas, incluindo cache com ArmatureData/BoneData/SurfaceData/SlotData reais. Três artefatos conferidos no mesmo SHA. Consultar PR #72 para SHA final, merge e CI pós-merge; este registro não antecipa merge.

## ConstraintData/IKConstraintData/PathConstraintData

ConstraintData.ts completo e Lua real do backup lidos. Oráculo compila namespace genuíno e executa os arquivos emitidos de BaseObject, Point/Rectangle/Matrix/Transform/ColorTransform, UserData, DisplayData, AnimationData, ArmatureData e ConstraintData. Todos os modelos instanciados na suíte são reais; nenhum registro substitui constraint, bone/slot ou path display.

Execuções finais reais:

```sh
NODE_PATH=../tooling/node_modules node tests/constraintdata_differential.js ../DragonBonesJS ../lua54/lua
NODE_PATH=../tooling/node_modules node tests/constraintdata_differential.js ../DragonBonesJS ../luajit/src/luajit
```

**23 cenários, 817 operações e 7.353 colunas por VM; passed.** Tolerância zero, binary64/NaN canonicalizado. Depois de cada operação: retorno/erro, todos os campos declarados das três classes, refs/identidades/listas/length, propriedade não índice no overflow, extras, pool/hash/flags/LIFO/limites/avisos, chamadas/hooks e estado parcial. Colunas agregam campos, não são porcentagem de equivalência.

Cobertura: base abstrata sem chave concreta, raw new versus borrow e defaults, herança e ordem de limpeza, Path.type mantendo IK como a fonte, modos/valores, AddBone exato versus addBone inexistente, duplicatas, lista esparsa, aliases e limpeza preservando identidade/propriedades extras. Números extremos, NaN/infinitos/subnormais/zeros assinados nos campos, comprimentos inválidos e limite uint32: push escreve a propriedade não índice antes de RangeError e ela permanece após clear. Cinco sequências determinísticas de 80 operações.

Propriedade: root/target/bone, pathSlot/pathDisplayData e lista de bones não são devolvidos/resetados. Referidos reais permanecem intactos e hooks que lançariam erro se fossem devolvidos continuam pendentes, inclusive GeometryData/WeightData do PathDisplayData. Integração com ArmatureData.sortBones/_onClear, root/target reais, retorno das duas classes de constraint, aviso de nome duplicado e falha de retorno com estado parcial/retry. Grafos acíclicos e timeout externo 10s só na infraestrutura.

Experimentos reversíveis: acrescentar type=ConstraintType.Path após super._onClear foi rejeitado em row 30 clear raw; remover a definição final do novo length de AddBone foi rejeitado em row 107 append p bone (esperado RangeError, obtido void). Produto restaurado e comandos finais refeitos em Lua 5.4/LuaJIT, sem relaxar expectativas.

Limites: não executa IKConstraint/PathConstraint ou qualquer solver de runtime, deformação, parsing/playback/GPU ou tempo automático real. SkinData/DragonBonesData reais seguem pendentes em outras fronteiras. Null/undefined de refs para nil; holes/undefined por valor/length, sem descritores/proxies/coerções genéricas de JS.

Artefatos regeneráveis: constraintdata-cases.tsv, constraintdata-original.tsv e saídas/JSON por VM. CI executa as onze suítes e preserva evidências. CI inicial confirmada abaixo; merge e CI pós-merge devem ser consultados no PR.

Checkpoint remoto: PR #73, código db0c8806dfb903427ff51c47cfae58733571a391. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41676866452 aprovada nos jobs inventory, geometry (lua5.4) e geometry (luajit). Logs de ambas as VMs confirmaram onze suítes passed; novo lote 23 cenários/817 operações/7.353 colunas com integração de constraints reais. Três artefatos conferidos no mesmo SHA. Consultar PR #73 para SHA final, merge e CI pós-merge; este registro não antecipa merge.

## SkinData e integração real com armadura/displays

SkinData.ts completo e Lua real do backup lidos. O oráculo compila o namespace genuíno e executa BaseObject, Point/Rectangle/Matrix/Transform/ColorTransform, UserData, DisplayData, AnimationData, ArmatureData e SkinData emitidos. Todos os modelos instanciados são reais; hooks/setters só observam instâncias, sem versão reescrita do algoritmo ou registro de skin substituto.

Execuções finais reais:

```sh
NODE_PATH=../tooling/node_modules node tests/skindata_differential.js ../DragonBonesJS ../lua54/lua
NODE_PATH=../tooling/node_modules node tests/skindata_differential.js ../DragonBonesJS ../luajit/src/luajit
```

**29 cenários, 814 operações e 8.140 colunas por VM; passed.** Tolerância zero, binary64/NaN canonicalizado. Cada operação observa retorno/erro, todos os campos de SkinData, mapa/listas/length/identidades/aliases, null distinto de undefined/hole, refs/parent e estado de displays/pesos/ações/payloads, pools/hash/flags/LIFO/limites/avisos, callbacks/setters e efeitos parciais. Hole versus undefined próprio normaliza descritores, preservando valor lido e diferença de null.

Cobertura: raw new versus borrow e defaults; ausência/presença de slots, primeiro nome/nomes alterados, null explícito e marcador, argumento omitido/undefined criando lista antes do erro; listas esparsas com lookup antes de hole ou erro ao alcançá-lo; identidade estrita contra __eq; duplicatas e um display compartilhado entre skins sem detach da lista anterior; aliases/listas retornadas após map deletion. Ordem de chaves numéricas/-0/01 e reinserção, callbacks que acrescentam à lista, excluem chave futura ou criam chave nova que permanece na próxima enumeração/reuso da skin. Cinco sequências determinísticas de 80 operações.

Parent setters em modelos reais observam erro, substituição e exclusão de lista antes do push, sem acionar setters na serialização. Overflow 2^32-1 mantém parent/propriedade não índice antes de RangeError; resize para zero preserva a propriedade não índice da lista alias. Erros de retorno preservam mapa e campos ainda não resetados, com retry original.

Integração com ArmatureData.addSkin/getMesh/_onClear e displays concretos: getMesh sem filtro adicional de tipo do cast TS, geometria compartilhada, peso real falhando na cadeia display/skin/armadura, e ArmatureDisplayData com ActionData/UserData reais. Sem skin stub. A diferença null/undefined das listas foi preservada nos modelos; backend/renderização não foram exercitados.

Experimentos reversíveis: substituir loop de limpeza por ipairs falhou em row 65 clear s (esperado erro no hole, obtido void); remover distinção do argumento omitido falhou em row 77 add s omitted omit. Produto restaurado e comandos finais refeitos nas duas VMs, sem relaxar comparação.

Limites: não comprova seleção/renderização de skins no runtime, parser/binário/typed buffers, solver/deformação/playback/GPU ou precisão temporal automática real. DragonBonesData global e BoundingBoxData reais permanecem pendentes. Fora de listas, refs null/undefined normalizam nil; mapas não emulam Object.prototype e descritores/proxies/coerções JS genéricos não são equivalência declarada. Consumidores futuros devem reconhecer o marcador truthy SkinData.NULL.

Artefatos regeneráveis: skindata-cases.tsv, skindata-original.tsv e saídas/JSON por VM. CI executa as doze suítes e preserva evidências. CI remota/PR/merge desta unidade devem ser confirmados no SHA publicado.


Checkpoint remoto: PR #74, código c5e6490abc9e67b7a9fafb94c5838944b047bbc3. CI https://github.com/SrTristeSad/Bono-Lua/actions/runs/41680927368 aprovada: inventory, geometry (lua5.4) e geometry (luajit). Logs confirmaram doze suítes passed em ambas as VMs; SkinData: 29 cenários/814 operações/8.140 colunas. Três artefatos conferidos no mesmo SHA. Consultar PR #74 para SHA final, merge e CI pós-merge; este registro não antecipa merge.


## DragonBonesData — contêiner global real

Oráculo executa o emit genuíno de DragonBonesData junto de BaseObject, Point/Rectangle/Matrix/Transform/ColorTransform, UserData, DisplayData, AnimationData, ArmatureData e SkinData do commit fixado (12 arquivos). Não usa armazenamento global fictício. Lua usa as classes de produto reais; callbacks/setters só instrumentam instâncias nos testes.

Resultado final em **Lua 5.4 e LuaJIT: 32 cenários, 851 operações, 11.063 colunas; passed**, tolerância zero, bytes binary64 com NaN canonicalizado. Cada operação compara retorno/categoria de erro, campos públicos, identidade/conteúdo/length dos três arrays e do mapa, buffers e aliases, pais/stage/userData, armaduras/skins/displays/geometria/pesos/animações reais, cache de dez componentes, pool/flags/limites/ordem, avisos e callbacks. Cinco sequências determinísticas de 80 operações complementam os casos dirigidos.

Casos: new versus borrow, defaults, reuso, clear repetido, duplicatas (sem setter de parent), parent compartilhado sem detach, nome alterado/falha no setter antes de mapa e push, mapa com chaves numéricas/reinserção/aliases, callback que deleta chave futura ou adiciona chave que sobrevive ao clear/reuso, falha em armadura/userData e cadeia de falha peso→display→skin→armadura→global seguida de retry. stage não é devolvido. Arrays esparsos com length 2^32−1 são limpos preservando identidade e propriedades extras; push no limite deixa parent/mapa/propriedade não índice antes de RangeError. Cache real com prefixo esparso, offsets públicos zero-based e leituras fracionárias/negativas, NaN/infinitos/zero assinado/subnormal. AnimationData real recebe cache através da armadura global.

Buffers: todos os oito campos são ligados por referência, incluindo alias entre views; clear remove referências sem alterar payload externo. O oráculo usa ArrayBuffer/Int16Array/Float32Array/Uint16Array genuínos. No Lua, o teste fornece valores já decodificados base 1 (fronteira, não classe de produto substituta), usados por GeometryData para contar vértices/triângulos; não testa coerção/alinhamento/endianness/mutação compartilhada de typed views ou parsing. Descritores/proxies/coerções genéricas JS e Object.prototype dos mapas ficam fora da equivalência declarada; refs null/undefined normalizam nil.

Experimentos reversíveis executados: substituir armatureNames no clear foi rejeitado na linha 7; inserir mapa antes do setter parent foi rejeitado na linha 100. Código restaurado e execuções finais repetidas nas duas VMs. Erros observados no oráculo foram auditados: setter, overflow e três falhas injetadas de retorno; nenhum comando desconhecido mascarado como erro.

Artefatos regeneráveis: dragonbonesdata-cases.tsv, dragonbonesdata-original.tsv, saídas e JSON por VM. CI executa as treze suítes e preserva evidências. Consultar PR do checkpoint para CI remota/merge no SHA publicado; testes de modelo não comprovam parser/solver/playback/GPU ou precisão temporal automática real.
