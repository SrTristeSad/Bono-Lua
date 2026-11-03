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
