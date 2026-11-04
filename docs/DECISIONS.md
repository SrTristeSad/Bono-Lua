# Decisões rastreáveis

## 2026-11-03 — reconstrução isolada

Autorização: comando mestre anexado pelo proprietário e instrução para executá-lo.
Backup confirmado de `cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb` antes de remover qualquer arquivo antigo.
Nenhuma exclusão na main, nenhum force push, nenhum merge automático.

## Inventário reprodutível antes do porte

TypeScript 2.4.2 é dependência de desenvolvimento para leitura sintática; não integra o produto Lua. O runtime não foi reescrito em JS.
O gerador lê exclusivamente o commit `64b6c69ae35777c2404be68c9192e2c56906079e` por Git.
Dependências por identificadores são marcadas candidatas: não há afirmação de resolução de símbolos ou completude semântica.
O inventário e o backup preservam a possibilidade de auditar e reaproveitar implementações equivalentes após comprovação.

## Início efetivo do porte

O objetivo central foi explicitado no README e no status a pedido do proprietário. A meta e a fonte permanecem as do comando mestre.
A resolução de referências foi realizada por pacote/tsconfig, em vez de unir versões homônimas de backends. As cinco declarações externas ausentes são impedimentos registrados das integrações, sem impedir classes geom sem dependências externas. Validação funcional de plataformas permanece nas etapas 09/10.
Point, Rectangle e ColorTransform foram reaproveitados do SHA preservado após leitura integral e comparação com seus TS; os novos testes executam o upstream, sem algoritmos substitutos no oráculo.
A primeira execução do driver de teste revelou erro na infraestrutura: assert(arg[1], mensagem) propagava dois argumentos para io.lines. Separado o nome de arquivo numa variável, o driver passou nas duas VMs; nenhum resultado de teste foi declarado aprovado antes disso. Não foi necessário modificar as classes Lua para obter aprovação.

## Correção de abrangência do inventário

Incluídos os JS auxiliares anteriormente tratados somente como configuração/demonstração e as funções atribuídas a variáveis/propriedades. O catálogo agora tem 192 unidades autorais e 241 classes. O bundle Cocos duplicado continua classificado como distribuído, sem inflar o núcleo. Cada arquivo auxiliar permanece no escopo e tem fronteiras de host explicitadas; nenhum backend foi declarado implementado.

## Main atualizada a pedido explícito do proprietário

A instrução posterior “atualizar o main e continua” autorizou integrar o checkpoint de reconstrução em andamento, substituindo a restrição anterior de mantê-lo indefinidamente fora da main. Conferidos PR #63, CI 41578914095 aprovada e backup remoto cd4206a8. Merge confirmado: 71929d98cbb0461eab99d83e6fa7e0a3c4bf0584. Não foi usado force push nem removido o backup. A main é agora uma versão em desenvolvimento; não uma certificação de 100%.
Continuação em port/geom-matrix-transform, criada do merge confirmado. Checkpoints posteriores continuam exigindo CI aprovada antes de integrar; não alterar fonte nem objetivo.

## Matrix e Transform

Lidos novamente Matrix.ts/Transform.ts integrais no commit fixado e os Lua reais do backup cd4206a8, incluindo JSNumberString. Algoritmos preservados; imports atualizados para o mapa dragonbones/geom/.
A comparação encontrou divergência genuína em Matrix.transformRectangle: math.floor(-0) retornava inteiro 0 no Lua 5.4, enquanto o original retornava -0. Adaptação local de floor/ceil preserva zeros assinados sem alterar seleção/ordem dos cantos ou fórmulas originais. O cenário permanece no teste, sem relaxar comparação de zeros.
Tolerância definida antes da execução: oito epsilons relativos com piso absoluto de oito epsilons, somente para componentes trigonométricos não nulos de fromMatrix/toMatrix. Identidades, retornos, strings, valores especiais, sinais de zero, translações e demais operações são comparados exatamente. As 52 diferenças aceitas nas execuções locais são diferenças pequenas da fronteira V8/libm, não mudanças no algoritmo.

## BaseObject e chaves de pool

O backup de BaseObject foi lido mas não copiado automaticamente: sua chave por identidade de classe diverge de String(construtor) do original. Preservadas strings, colisões, receptor estático e ordem de enumeração necessária aos efeitos parciais antes de RangeError. Não se removeu comportamento peculiar para melhorar o motor.
Os dados de estado estáticos mantêm os nomes do TS; a lista auxiliar de ordem é apenas adaptação da estrutura de mapa, não novo algoritmo de pooling.
Teste adicional falhou em LuaJIT na chave textual "-0" por tratá-la como índice 0 antes da chave "2". Corrigida a classificação canônica, mantido o teste e reexecutadas ambas as VMs com aprovação. Não houve relaxamento de expectativas ou tolerâncias.
A próxima classe escolhida é CanvasData: o relatório de dependências aponta somente BaseObject, permitindo validar um modelo real sem inventar os módulos de eventos/animação ainda ausentes.

## CanvasData e modelos de atlas/textura

CanvasData foi seguido por TextureAtlasData/TextureData porque suas únicas dependências de execução (BaseObject e Rectangle) já existem. Map é declaração de tipos, sem módulo de runtime faltante. Foram lidos os dois TS integrais e os dois Lua do backup antes de aproveitar o código.
Preservados campos sem inicialização do construtor; nenhuma antecipação de _onClear. Preservado também o parent da origem ao copiar textura, sem corrigir esse comportamento do upstream.
A comparação acusou mudança real de identidades na cópia do atlas pelo uso de pairs. Adaptada somente a ordem de enumeração do mapa, mantendo a tabela pública e sua identidade. Testes incluem nomes numéricos, exclusão/reinserção, duplicatas, cópia em si mesmo e estado parcial quando createTexture falha.
O primeiro driver tentou compilar os arquivos isoladamente e não resolveu o namespace BaseObject; corrigida a infraestrutura para compilação conjunta do namespace genuíno, executando somente os quatro arquivos pertinentes. Um conflito de nome de variável do driver foi corrigido antes dos resultados finais. Nenhum desses erros foi declarado como teste aprovado.
Próxima dependência do core/DragonBones: WorldClock, cujo contrato IAnimatable e a fonte de tempo devem ser auditados antes de portar; não inventar um relógio de animação alternativo.

## WorldClock

Lidos o WorldClock.ts/IAnimatable.ts completos, Lua real do backup e dependências. IAnimatable documentado como interface, sem inventar um módulo de runtime. O inventário agora permite mapear esse contrato para Markdown, mantendo a rastreabilidade do original.
O oráculo acusou add c b incorreto com animatables Lua cujo __eq retorna true: preservada a identidade estrita com rawequal. Outro cenário de reentrância fez clear retornar quando o original lançava erro numa posição undefined; preservado o comprimento lógico JS e o erro do próprio upstream para resize negativo. Expectativas e cenários mantidos, sem guards que reinterpretem o algoritmo.
O tempo automático real continua com limitação conhecida de precisão em stock Lua. Mantida época de os.time e provider substituível; não criar relógio híbrido nem alegar que LÖVE monotônico equivale a Date. Teste de adaptação verifica época em os.time e que uma love.timer simulada não é escolhida.
Próxima unidade exige auditar core/DragonBones, enums e EventObject/UserData/IEventDispatcher em conjunto antes de decidir a carga de módulos Lua. Não contornar dependências com constantes ou implementações de produto fictícias.

## Núcleo de eventos e modelos de payload

WorldClock/PR #67 foi confirmado integrado em 341df09 com CI pós-merge 41586449745 aprovada. Lidos os quatro originais completos e os três arquivos Lua do backup. Separados somente os const enums em Enums.lua para interromper o ciclo core -> EventObject -> enums; os valores originais são reexportados no core e conferidos contra TS emitido. Nenhuma constante provisória/stub foi introduzida.

Preservados filas crescentes, reciclagem adiada, estado parcial em falhas e comportamento de reentrância. Um experimento reversível restaurando == do backup confirmou falha real de identidade; rawequal mantido. O teste de índice subnormal de UserData falhou com index+1 antes da verificação de integralidade; corrigida somente a representação do acesso ao array, sem defaults inventados. Os dois casos permanecem na suíte.

Dispatchers/Armature/animatable mínimos e hooks são somente infraestrutura do teste; não contam como runtime portado. IEventDispatcher e EventStringType documentados como tipos apagados, com três métodos de listeners explicitamente ainda não exercitados. Shims exclusivos JS têm fronteira documentada de módulo/linguagem. A precisão de tempo automático continua pendente e não é ocultada pelo provider determinístico.

## AnimationConfig

Conferidos main bc74a1a, PR #68, CI pós-merge 41635078122 e backup cd4206a8. Lidos TS completo, Lua real do backup e dependências. Importados enums diretamente do módulo comum, preservando defaults/ordem do algoritmo, sem carregar o core só para constantes e sem alterar timeScale=-100.0 para o valor descrito em comentário.

O uso de # no backup só representa máscaras densas. Acrescentado comprimento lógico privado da tabela boneMask, exposto como length, para preservar crescimento/truncamento, posições sem valor e identidade. Um experimento temporário restaurou # em copyFrom e foi rejeitado na cópia esparsa (linha 61); restaurado o código correto e refeitas as execuções finais. Propriedades nomeadas são preservadas pelo truncamento.

A primeira execução do driver confundiu delete JS com escrita nil além do fim e aumentou length; corrigido somente o transporte para rawset(...,nil). Expectativas do original, cenários e comparação numérica foram mantidos. Holes/undefined explícito normalizam por valor/comprimento; nenhuma afirmação de descritores/proxies ou animação integrada. Próxima unidade requer auditar AnimationData e a dependência ArmatureData antes de escolher recorte sem stubs de produto.

## AnimationData e auditoria de ArmatureData

Conferidos main b45b575, PR #69/CI pós-merge 41646190037, backup cd4206a8 e fonte limpa/fixada. Lidos integralmente os TS e os Lua reais de AnimationData/ArmatureData. O primeiro só lê arrays/nomes do parent; portar suas três classes é possível sem instanciar ArmatureData nem fornecer stub de produto. A fronteira é registro somente de teste, com integração real explicitamente pendente. O segundo exige GeometryData de DisplayData para SurfaceData e tem sort/cache/skins/dados globais a auditar em conjunto nas próximas unidades.

Extraídos JSArray/JSMap das representações já comparadas de AnimationConfig/TextureAtlasData, para reutilizar length e ordem com manutenção comum. Reexecutadas ambas as suítes nas duas VMs, sem relaxar expectativas. Preservado o erro/estado parcial de campos numéricos undefined em raw new por conversão localizada a NaN; falha real observada no novo cenário antes da correção.

Preservada a peculiaridade original cacheFrames.length=aridade 1, inclusive cacheFrameCount zero. Experimento que restaurou math.min(1,cacheFrameCount) do backup falhou na linha 155 do lote de 38 cenários; outro com == em appendUnique falhou na linha 56. Código restaurado e lote final ampliado (39 cenários) aprovado nas duas VMs. Não preencher cachedFrames inteiro, não mudar TODO do upstream e não tratar probes como ArmatureData real.

## DisplayData e propriedade das referências

Conferidos main 975b031, PR #70/CI pós-merge 41651358553, backup cd4206a8 e fonte limpa/fixada. Lidos TS completo e Lua real do backup. Portadas as oito classes com dependências executáveis já disponíveis, sem gerar GeometryData poolável ou implementação concreta fictícia da base abstrata. Referências ainda ausentes são documentadas e probes apenas de teste.

Arrays de ações/curvas/bones usam JSArray para preservar posições sem valor, append e erros de iteração. Getters de geometria receberam adaptação localizada undefined->NaN e validação do índice antes de base 1, após falha real na linha 106. Experimentos que removeram a validação ou restauraram ipairs foram rejeitados respectivamente nas linhas 124/254; produto restaurado e execuções finais refeitas. Getter-only vertexCount/triangleCount não se tornam campos graváveis.

Mantida a propriedade original: compartilhar geometria não copia data/inheritDeform nem devolve peso antigo; bones/textures/skin/armature são referências não proprietárias, ações/peso não compartilhado/boundingBox têm devolução na ordem original. Sem contagem de referência ou limpeza extra. GeometryData agora pode ser dependência real de SurfaceData na próxima unidade ArmatureData; as demais fronteiras e playback continuam pendentes.

## ArmatureData e integração de cache

Confirmados main 13ae3b1, PR #71/CI pós-merge 41664512405, backup cd4206a8 e fonte limpa/fixada. Relidos TS/Lua reais de ArmatureData e lidos os TS de ConstraintData/SkinData/DragonBonesData para delimitar contratos. Portadas as quatro classes com GeometryData real, sem stubs de produto. AnimationData passa a ser exercitado com parent/BoneData/SurfaceData/SlotData reais; contratos ainda não implementados não são reclassificados como integração completa.

A inspeção exigiu distinguir undefined/null em referências com testes estritos no código. Mantido estado privado por instância e acessores herdados em SurfaceData, sem inicializar os campos antes do ponto original. Experimento que voltou a testar somente nil selecionou skin padrão cedo demais e falhou na linha 56. O acesso ao cache preserva índices efetivos antes de base 1; experimento sem validação falhou na linha 372 com subnormal. Produto restaurado e execuções finais refeitas.

Ordenação original por espera de pai/constraint foi preservada com identidade estrita, sem detector de ciclos ou novo limite no motor. Testes usam grafos acíclicos e timeout externo só para evitar travamento da infraestrutura. Next: ler Lua real de ConstraintData antes do próximo porte; SkinData/DragonBonesData deverão substituir os contratos remanescentes com suas próprias comparações.

## Modelos de constraints

Confirmados main 57e7d48, PR #72/CI pós-merge 41673223815, backup cd4206a8 e fonte limpa/fixada. Lidos TS completo e Lua real do backup antes de portar base abstrata, IKConstraintData e PathConstraintData. Mantidos defaults reais, referências não proprietárias e capitalização AddBone; não atribuir type=Path no reset que o original deixa como IK.

Append usa comprimento lógico JSArray e preserva os dois passos de push para manter RangeError/estado parcial no limite uint32. Experimento sem esse passo foi rejeitado em row 107; um reset de tipo inventado foi rejeitado em row 30. Código restaurado e execuções finais refeitas nas duas VMs sem mudar expectativas/tolerâncias. Sem solver ou constantes/classes provisórias.

A suíte nova integra constraints concretas com modelos reais de armadura/bones/slot/path display, removendo a dependência de probes para essa fronteira. SkinData/DragonBonesData ainda exigem seus próprios portes e comparações; a próxima unidade precisa tratar null explícito em listas de displays distintamente de holes/undefined.

## SkinData

Confirmados main 2e25e30, PR #73/CI pós-merge 41677323508, backup cd4206a8 e fonte limpa/fixada. Lidos TS completo e Lua real do backup. Preservado marcador explícito de null do porte anterior, com rawequal, length lógico e ordem de JSMap; não converter hole/undefined em null nem interromper em ipairs. addDisplay diferencia nil explícito de argumento omitido por aridade de varargs, mantendo falha depois da criação da lista.

Mantidos parent antes do push e leitura tardia da lista, ownership duplicado/compartilhado e novas chaves sobrevivendo à enumeração/retorno ao pool no comportamento do original executado. Experimentos com ipairs e omissão tratada como null foram rejeitados nas linhas 65/77; produto restaurado e testes finais refeitos sem alterar expectativas/tolerâncias. Nenhuma reparação extra de referências nem filtro de tipo em getMesh.

A nova suíte substitui a fronteira de skin por modelos reais, incluindo cadeia de falha peso/display/skin/armadura e ações/UserData. Consumidores futuros precisam reconhecer SkinData.NULL explicitamente; instrução registrada para manter a representação. DragonBonesData será a próxima unidade para remover a fronteira de armazenamento global.


## Contêiner DragonBonesData

Lidos TS integral fixado e Lua integral do backup em dragonbones/original/model/DragonBonesData.lua. Mantida API original, sem introduzir setter de buffer ausente no TS. Arrays públicos usam o adaptador lógico existente; mapa usa ordenação existente, substituindo pairs do backup. A suíte executa DragonBonesData real com cadeia real de ownership e cache; referências a buffers são não proprietárias e o teste marca explicitamente a fronteira já decodificada, sem fabricar parser ou typed views. Experimentos de substituir armatureNames e antecipar inserção no mapa falharam; produto restaurado e suíte final refeita em ambas VMs. Próxima unidade: BoundingBoxData, sem alterar decisões de runtime/renderização.


## Bounding boxes locais

Lidos BoundingBoxData.ts integral fixado e Lua integral do backup. Reaproveitada a tradução dos algoritmos, com imports atuais, JSArray para length e adaptação undefined→NaN; corrigido somente agrupamento aritmético da tradução antiga para seguir pY*=widthH/heightH do TS. Peculiaridades matemáticas da fonte preservadas, não corrigidas. Política de comparação de atan2 declarada antes da primeira execução; procedência de valores preservados ajustada no comparador após diagnóstico sem ampliar tolerância. Suíte real integra bounding boxes a BoundingBoxDisplayData/SkinData/ArmatureData/DragonBonesData, incluindo falhas parciais. Mutantes que corrigem coordenada peculiar do retângulo e removem parada sem pointB foram rejeitados. Produto restaurado e testes finais repetidos. Próxima unidade: DataParser.ts; não confundir dados de formas locais com hit testing completo do runtime.


## Base DataParser

Auditoria integral TS/Lua do backup antes do porte. Reaproveitadas constantes e mapeamentos com import atual de Enums; array de versões passou a JSArray. Sem fake ObjectDataParser/BinaryDataParser nem corpos abstratos que retornem nil/false. Matching de keywords ASCII independe do locale C, inclui fold Kelvin observado no motor JS e registra separadamente a fronteira de toLocaleLowerCase en-US versus outros locales. AST extrai constantes e branches para entradas, mas retornos vêm do TS genuíno; aplicações em modelos reais não são chamadas de parsing. Mutantes de Kelvin/trim foram rejeitados; produto restaurado e lote final repetido. Próxima unidade: ObjectDataParser, helpers e atlas reais antes de declarar importação de armadura/animação ou binário.


## Primeiro recorte ObjectDataParser

Auditoria dos métodos/initializers de helpers e atlas no TS fixado e Lua do backup; AST/estrutura enumera 47 métodos/39 propriedades no arquivo todo. Não atribuir auditoria dos corpos remanescentes ao lote. Reaproveitada ordem original, corrigindo adaptações antigas de nil/NaN, arrays vazios e fila usando JSValue/JSArray em vez de heurísticas de #. Sem decoder/factory gráfico novo ou stubs de parseDragonBonesData. Atlas/texturas reais, factory concreta somente no teste e órfãos/erros preservados. Mutantes de default para undefined e escala aplicada às coordenadas foram rejeitados, produto restaurado e lote final repetido. Próximo recorte estrutural deve mapear dependências reais antes de oferecer entrypoint de importação.


## Dependências estruturais completas antes de bones/skins

Auditoria identificou geometria/surface/mesh/path e animação como dependências ainda ausentes de bone/display/skin/armature. Escolhidos nove métodos completos independentes, preservando seus modelos reais e efeitos parciais; não acrescentados stubs para cumprir chamadas pendentes. Reutilizado Lua do backup após comparar cada corpo TS, com presença null/undefined, length e ramo de classe corrigidos. UserData lógico e adaptador interno de referência são mudanças de representação necessárias para integrar os métodos. For-of validado contra emit fixado ES5; fixtures no realm da VM e transporte UTF-16 garantem observação de ramos verdadeiros e surrogates, sem trocar por semântica ES2015. Mutantes de parent e AABB foram rejeitados; produto restaurado e execuções finais repetidas.


## Geometria antes da finalização binária

Auditoria TS/Lua dos sete métodos e Matrix real. Mantidas peculiaridades de pesos (posição de floor, reserva inicial, loop weightCount, cabeçalho indefinido) mesmo quando parecem dados incompletos. Não aproveitar a adaptação antiga do backup que preenchia reservas com zero: isso altera estados observáveis antes de _modifyArray. Slots/bones/skins/displays usam modelos reais e caches/refs/estado parcial originais. Matrix ajustada somente para propagar undefined→NaN necessário a poses incompletas; regressão anterior preservada. Mutantes de loop/floor foram rejeitados, produto restaurado e testes finais refeitos. Próxima unidade: _modifyArray com buffer/views compartilhados e provas de bytes, sem declarar parser completo por este lote.


## _modifyArray antes de animações/entrypoints

Base main a9e34b0/PR #80/CI pós-merge 41729413783 e backup cd4206a8 conferidos. Adaptador do backup auditado antes do reaproveitamento: corrigidos undefined float, conversão JSValue, overflow Float32 extremo sem loop infinito, metadados/estado privado de proxies, coerção antes de rejeitar índice e validação de comprimento em bytes. Sem introduzir getter string em DragonBonesData.binary: mantém objeto Buffer mutável; snapshots explícitos por bytes(), evitando quebrar identidade compartilhada.

Um único buffer para sete views; alinhamento/cópias/publicação e reset final originais. Não corrigir a condição duplicada timeline→color do upstream. Teste nativo exato, não mock de typed arrays. Falhas de setter são instrumentação de teste em DragonBonesData real; sem hooks de produto. Adaptador não conta como classe extra do upstream. Dezenove suítes; parser 22/47, 25 ausentes. Limites de plataforma/reflexão documentados, sem claim de DBDT/runtime completo.


## Curvas e frames antes das timelines

Base main bc67313/PR #81/CI pós-merge 41735155177 e backup cd4206a8 conferidos. Lidos os nove corpos TS e Lua do backup integralmente. Reutilizada arquitetura, corrigindo diferenças do backup em reservas/holes e leitura antecipada dos valores. _parseSingleValueFrame e _parseDoubleValueFrame leem raw somente depois do frame/tween/reserva, inclusive falhas no segundo valor e tipo desconhecido. _samplingEasingCurve mantém último probe de bisseção e ambos os ramos; não normaliza curvas ou conserta algoritmos patológicos do upstream. Math.round preserva -0, ties para +infinito e inteiros grandes.

ActionFrame já exportado passa a ser consumido por merge/serializer reais, sem transformá-lo em modelo poolável. Ações ficam em ArmatureData.actions; frames guardam índices, não cópias. Mantidas ordem de chaves e efeitos parciais. Sem stubs para timelines/animação ausentes. Parser 31/47, 16 pendentes; testes com 16 arquivos genuínos emitidos, modelos e finalização binária reais, 20 suítes na CI.


## Frames especializados antes de deformações/timelines

Base main 117237f/PR #83/CI pós-merge 41738114130 e backup cd4206a8 conferidos. Oito métodos lidos integralmente em TS/Lua, reaproveitando arquitetura e corrigindo reservas/holes/ordem de leituras ausentes no backup. Rotação mantém fórmula e estado parcial, com helper privado compartilhado sem método upstream novo. Cor preserva detecção por enumerabilidade, registros explícitos versus cache default e atribuição do cache antes de erro de reserva. ZOrder mantém validação de Array.length e preenchimento reverso, sem consertar loops inválidos do upstream. Sem stubs para as duas deformações ou timelines ausentes.

Teste usa os corpos genuínos e modelos reais, incluindo ações e bytes da finalização já portados. Infinitos revelaram sinal negativo de NaN no armazenamento nativo versus NaN canônico do adaptador, já fora da equivalência binária declarada. Normalizar apenas essas células no snapshot de observação, de ambos os lados, documentando a diferença e sem mudar produto/expectativas dos demais bytes. 39/47 métodos, 8 pendentes, 21 suítes na CI; deformações exigem auditoria própria com geometrias/pesos/poses reais.


## Deformações antes das timelines

Base main 147bc53/PR #84/CI pós-merge 41740725798 e backup cd4206a8 conferidos. Dois métodos e helpers antigos lidos; preservar algoritmo, corrigir reservas com zeros/#array e null/undefined do backup. Componentes e header compartilham helpers privados sem métodos upstream adicionais. Contexto de teste usa Geometry/Weight/AnimationData/TimelineData/Matrix reais, com poses e índices vindos de _parseMesh/_parseGeometry; não simular timeline ausente.

Manter TODO do genérico ponderado, diferenças VERTICES/VALUE, delta=true, ordem reserva/cópia/header e offsets relativos. Não aplicar pesos novos nem corrigir dados inconsistentes automaticamente. Parser 41/47, seis pendentes; 22 suítes na CI. Normalização de NaN Float32 só no snapshot permanece a do contrato anterior, sem alterar produto ou outros testes.


## Timelines antes de _parseAnimation

Base main f5de26e/PR #85/CI pós-merge 41743120707 e backup cd4206a8 conferidos. Três corpos originais e Lua do backup auditados. Usar JSArray/length/holes, roundFrame correto e modelos reais, sem reservas com zeros/#array ou callback fictício de produto. Helpers privados só adaptam null e reconhecimento de ActionFrame. Preservar último frame extra, próximo tempo do cache de ações e diferença de registro imediato Bone versus adiado Slot, inclusive órfãos/contexto parcial.

Testes usam callbacks genuínos de todos os codecs aplicáveis, wrappers somente para observar argumentos/falhar após callback real, TimelineData existente e mapas/pool/frameIndices reais. Snapshot do teste foi protegido contra contexto data=null para observar a falha original, sem mudar produto/oráculo. 44/47 métodos, três pendentes e 23 suítes na CI. Não declarar playback ou importação completa de animação/armadura com esta unidade.


## _parseAnimation antes da armadura/entrypoint

Base main 0d285da/PR #86/CI pós-merge 41746583709 e backup cd4206a8 conferidos. Método completo auditado nos dois idiomas e dependências já reais. Reaproveitada arquitetura do backup, trocando #/ipairs/pairs por length/iterator ES5/JSMap.keys e conservando marcadores null/undefined. Não unificar codecs legado/genérico nem completar TODOs upstream. Preservar phase de actions antes de genéricas, última geometria entre skins/slots e órfãos de AnimationTimelineData blend.

Testes observam todos os AnimationData alocados/retornados/parciais, subtipos de timeline e quatro mapas, além de estados/bytes reais. O transcript excedeu 64 MiB no desenvolvimento; limite de transporte do teste subiu para 128 MiB/30s, sem mudar comparação/oráculo/tolerância. Parser 45/47, 24 suítes; sem entrada/armadura falsa ou playback declarado.


## _parseArmature antes do ponto de entrada global

Base main 63b9b12/PR #87/CI pós-merge 41752378133 e backup cd4206a8 conferidos. Método integral lido em TS/Lua; usar CanvasData e demais modelos/parsers já reais, com length/iterator ES5/JSMap. Não corrigir TODO do slot vazio em share, ciclos de sort ou duplicatas/órfãos. Manter defaultAnimation pela última Play válida, ordem IK/sort/skins/path/link/animações e limpeza só no sucesso.

Teste passou a executar 17 arquivos genuínos (CanvasData incluído) e recarregar CanvasData por cenário, sem stub. Fixture defaultActions corrigida de array de strings inválido para string direta, conforme formato aceito pelo original; RangeError positivo exercitado por reserva fracionária de peso real. Parser 46/47, 25 suítes na CI; parseDragonBonesData/entrada global não inventados.


## Entrada de objetos fecha os corpos de ObjectDataParser

Base main 5d16e3d/PR #88/CI pós-merge 41754763774 e backup cd4206a8 conferidos. Último método integral TS/Lua auditado. Corrigir assert bloqueante/#/ipairs do backup e manter teste de binary pela referência self._data, versão/compatibilidade, stage e atlas. Converter null da fila para nil interno, conservar undefined e não reiniciar índice. Sem reset/rollback extra no ramo sem ARMATURE ou em falhas.

Testes iniciam parser sem modelos pré-semeados e criam grafo real pelo entrypoint. Factory abstrata de textura concretizada só no teste e override de _parseArray só para provar skip com Buffer real existente (não BinaryDataParser de produto). Snapshot Lua ajustou ordem de atribuição de IDs de observação, não algoritmos. 47/47 corpos, 26 suítes, limites/TODOs e falta de runtime/BinaryDataParser explícitos; próximo recorte deve auditar fronteiras de bytes/UTF-8/JSON interno.

## Helpers binários e bytes — checkpoint atual

BinaryDataParser tem 3/8 métodos portados: `_inRange`, `_decodeUTF8` e `getInstance`. SharedBinaryBuffer agora oferece `uint8`, com aliases, metadados e coerções comparados ao Uint8Array nativo. A comparação executa o decoder original fixado: 67.083 operações e 134.166 colunas, incluindo todos os 65.536 pares de bytes, com tolerância zero. Ver [contrato](contracts/BinaryUTF8.md).

Isso ainda não carrega DBDT: faltam `_parseBinaryTimeline`, overrides `_parseAnimation`/`_parseGeometry`/`_parseArray` e a entrada binária `parseDragonBonesData`, além da dependência JSON do cabeçalho. A entrada de objetos herdada não interpreta bytes. ObjectDataParser permanece em 47/47 corpos, nos domínios documentados. Runtime, factories e backends continuam pendentes.

## Timelines binárias — checkpoint seguinte

`BinaryDataParser._parseBinaryTimeline` portado: agora 4/8 métodos. Usa views Int16/Uint16 e modelos/pool reais; acrescenta índices ao segmento existente, preserva o frame final extra e o estado parcial em erros. Comparação contra o método TS executado: 439 cenários, 448 chamadas, 6.585 colunas por VM, 12 falhas esperadas, tolerância zero. Contrato: [BinaryTimeline.md](contracts/BinaryTimeline.md).

Faltam os overrides binários `_parseAnimation`, `_parseGeometry`, `_parseArray` e a entrada `parseDragonBonesData`/cabeçalho JSON. A entrada herdada continua sendo de objetos, sem suporte DBDT. CI passa a executar 28 suítes por VM.

## Animação binária — checkpoint seguinte

`BinaryDataParser._parseAnimation` portado, total 5/8 métodos. Compara metadados/offsets, grupos ordenados, todos os tipos genéricos, subclasses de blend, pool e falhas parciais com modelos reais. São 243 cenários, 468 chamadas reais de timeline, 3.159 colunas por VM, 32 exceções esperadas e tolerância zero. Ver [BinaryAnimation.md](contracts/BinaryAnimation.md). CI ampliada para 29 suítes por VM.

Mapas de grupos decodificados exigem JSMap.new; listas raw usam JSValue.array. Não afirma reflexão/protótipos/for-in de primitivas genéricos. Preserva Action/ZOrder genéricos sem registro e órfãos upstream; não avalia animação no runtime. Restam _parseGeometry, _parseArray e parseDragonBonesData binários/JSON interno.

## Geometria binária — checkpoint seguinte

`BinaryDataParser._parseGeometry` portado, total 6/8 métodos. Preserva correção de offset abaixo de -1, ausência de peso sem limpeza, contagem de influências e referências aos bones, inclusive undefined. Peso novo só é publicado ao final; falhas preservam peso anterior e alocações parciais upstream.

Comparação com TS fixado executado: 238 cenários/4.284 colunas por VM, três exceções esperadas, tolerância zero, modelos/pool/views reais. Ver [BinaryGeometry.md](contracts/BinaryGeometry.md). CI com 30 suítes por VM. Restam _parseArray e entrada parseDragonBonesData binários/JSON interno; DBDT ainda não está disponível.

## Arrays binários — checkpoint seguinte

`BinaryDataParser._parseArray` portado, total 7/8 métodos. Cria as views sobre o mesmo Buffer, preserva o alias colorArray=intArray quando cores estão ausentes e publica campos na ordem original, incluindo referências privadas antes dos setters correspondentes. Conversão ToIndex específica trunca comprimentos fracionários e normaliza -0 para +0; Shared.view mantém contrato estrito em bytes.

189 cenários/3.402 colunas por VM, 69 exceções esperadas, tolerância zero contra typed arrays nativos do TS fixado. Ver [BinaryViews.md](contracts/BinaryViews.md). CI com 31 suítes por VM. Falta parseDragonBonesData binário/cabeçalho DBDT/JSON; não declarar carregamento DBDT pronto.

## Entrada DBDT — checkpoint seguinte

`BinaryDataParser.parseDragonBonesData` portado: agora 8/8 corpos, com comparação nos domínios documentados. Lê tag, tamanho Uint32 little endian e cabeçalho com o decoder original, adapta JSON e chama ObjectDataParser real. Recebe SharedBinaryBuffer, preservando sua identidade nas views. JSON inválido não publica novos campos binários; erros posteriores preservam o estado original.

223 cenários (184 JSON/39 DBDT), 797 colunas por VM, 45 exceções esperadas e tolerância zero. Grafo real com armadura/mesh/pesos/animação, buffers, pool, limpeza e mutação; cabeçalhos de até 65.536 bytes e JSON aninhado em 64 níveis. Ver [DBDTEntry.md](contracts/DBDTEntry.md). CI com 32 suítes por VM. Isso não declara equivalência JS irrestrita nem motor completo: corpus de exportações reais, I/O, runtime/factories/backends e limites anteriores continuam pendentes.

## Corpus esquelético upstream — validação integrada

Todos os blobs do commit fixado com extensão dbbin, ou JSON válido com propriedade armature, foram catalogados: 181 caminhos, 74 conteúdos únicos (71 JSON/3 DBDT). Cada conteúdo foi importado nas escalas 1 e 0,5: 148 importações/1.924 colunas por VM, sem erro e sem tolerância numérica. Manifesto registra SHA Git, SHA-256, tamanho e todos os caminhos.

Compara grafo selecionado, poses/cores/metadados, buffers byte a byte e classes/ordem de objetos emprestados, inclusive estado após limpeza. JSON e ArrayBuffer do oracle são criados no mesmo contexto VM do TS para evitar diferença artificial de instanceof. Ver [UpstreamCorpus.md](contracts/UpstreamCorpus.md). CI com 33 suítes por VM; nenhuma alteração no motor foi necessária neste checkpoint. Não cobre renderização/playback, exportações externas ao commit ou todo campo dinâmico.

## Primeira base do runtime — TransformObject

TransformObject portado com inicializadores, dois métodos e getter armature. Usa BaseObject/Matrix/Transform/Point reais; Armature aparece somente como tipo/referência, sem dependência executável ou stub. Mantém identidade dos vetores, dirty limpo antes de decompor e estado parcial em falhas. 212 cenários/8.056 colunas por VM, 35 exceções esperadas; 27 diferenças trigonométricas dentro da tolerância anterior de Transform, demais campos exatos. Ver [TransformObject.md](contracts/TransformObject.md).

Exemplos executáveis em Lua 5.4/LuaJIT: examples/run.lua inspect importa JSON/DBDT e lista modelos; examples/run.lua transform demonstra atualização adiada da matriz. Sem Node/npm para executar esses exemplos. Ainda não há player/renderização; classe concreta da demonstração não é Bone/Slot de produto. CI com 34 suítes por VM e execução dos dois exemplos.

## Bone regular e registro da armadura

Bone portado com uma Armature parcial real de ciclo de vida/registro. Hierarquia, modos de offset, flips/yDown, quatro flags de herança, alpha, dirty flags, cache de ArmatureData/DragonBonesData reais e getters/setters comparados contra TS executado. 1.576 cenários/44.128 colunas por VM, seis falhas esperadas e 340 aproximações trig limitadas; índices/flags/zeros/offsets exatos. Ver [BoneRuntime.md](contracts/BoneRuntime.md).

Comando executável examples/run.lua bones carrega dois modelos, monta dois Bone reais, gira o pai e move o filho de (40,20) para (10,50). Montagem manual com _armatureData, sem init/factory/player fictício. Surface, solvers, Slot runtime e Armature.init/advanceTime continuam pendentes. CI com 35 suítes e três exemplos por VM.

## Surface e integração com Bone

Surface portado com oito corpos e geometria/pool/armadura parcial reais. 585 cenários, 38.610 consultas e 26.325 colunas por VM; duas falhas esperadas. Inclui regiões central/laterais/bordas, cache hit/restauração/invalidação, deformação e cadeias de pais Bone/Surface. Não muda a tolerância da suíte Bone: a integração Surface usa orçamento próprio para trigonometria e projeção de coordenadas, registrado em [SurfaceRuntime.md](contracts/SurfaceRuntime.md).

Exemplo `examples/run.lua surface`: o filho em (50,50) vai a (50,90) ao deformar o centro da grade em +80 no eixo Y. Montagem e deformação manuais, sem player/factory falso. CI com 36 suítes e quatro exemplos por VM. Slot, constraints/solvers, Armature.init/advanceTime, animação e backend continuam pendentes.
