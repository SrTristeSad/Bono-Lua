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
