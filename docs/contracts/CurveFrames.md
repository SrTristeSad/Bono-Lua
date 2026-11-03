# Curvas e frames genéricos

Fonte única: ObjectDataParser.ts, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Nove métodos portados, além das unidades anteriores:

| Método | Comportamento |
| --- | --- |
| _getCurvePoint | Ponto Bézier cúbico, ordem original de multiplicações/somas |
| _samplingEasingCurve | Bisseção em dois formatos de curva, último probe e flag de endpoints omitidos |
| _parseFrame | Reserva posição e retorna offset base 0 |
| _parseTweenFrame | None/Line/QuadIn/QuadOut/QuadInOut/Curve e samples inteiros |
| _parseSingleValueFrame | Um valor Step/Int/Float |
| _parseDoubleValueFrame | Dois valores Step/Int/Float |
| _parseActionFrame | Posição, contagem de ações e offsets de ações |
| _parseActionDataInFrame | Ordem EVENT, SOUND, ACTION, EVENTS, ACTIONS |
| _mergeActionFrame | Ações na armadura, frame inicial zero, inserção/reuso e índices |

Arrays de trabalho são JSArray com length lógico e índices Lua base 1. Offsets/tempos/índices públicos continuam base 0. Reserva por length mantém holes: não preencher antes da leitura. _modifyArray da unidade anterior faz a coerção final Int16/Uint16/Float32 em memória compartilhada. Os testes comparam os arrays antes e os bytes depois desse passo.

Amostragem usa t=(i+1)/(length+1), segmentos na ordem original e while higher−lower>0.0001. O ponto final é a última avaliação de _getCurvePoint; não recalcular midpoint após o while. Comprimento curve%3==1 escolhe endpoints omitidos e retorna true; o outro ramo retorna false. _parseTweenFrame guarda contagem positiva/negativa conforme essa flag. Coordenadas ausentes/undefined produzem NaN; null vira zero. Arrays/array-like/strings compatíveis com JSValue seguem o acesso indexado. Curvas patológicas podem não terminar no original; não há reparo automático no produto.

Step reserva valores em frameArray, ignora escala e não parseia tween. Int/Float parseiam tween, reservam frameIntArray/frameFloatArray e só então leem valor ou x/y. Int usa Math.round com ties para +infinito e zero negativo; Float mantém valor ×escala. Tipo desconhecido retorna zero sem ler raw. Frame start/count/type/default/scale seguem contrato numérico TS; chamadas JS arbitrárias com esses controles não são equivalência afirmada.

Falhas preservam efeitos anteriores: posição reservada antes de ler curve/easing; helpArray redimensionado antes de curva inválida; comprimento de valores reservado antes de conversão que falha; primeiro valor do par mantido se o segundo falha. Overflow/fracionamento de length lança sem percorrer bilhões de elementos. Não existe rollback extra.

_mergeActionFrame captura armature.actions.length antes de _parseActionData. Primeiro adiciona as ações reais à armadura; depois garante frame zero inicial, busca tempo igual e insere quando necessário, conservando identidade dos frames existentes. Não ordena novamente tempos NaN/infinitos. Frames armazenam offsets na lista real da armadura, não objetos ActionData. Mesmo entrada sem ações pode criar frames vazios. ActionFrame é classe comum, sem hashCode/pool. Erros no parse/adicionar ação mantêm objetos órfãos/ações já adicionadas, sem fabricar frames depois da falha.

Validação: tests/curveframes_differential.{js,lua}, 328 cenários/3.594 operações/71.880 colunas por VM Lua 5.4/LuaJIT, zero tolerância e 21 exceções esperadas. Binary64, sinal do zero e bytes tipados exatos; NaN canônico. Contadores verificam execução genuína dos nove métodos; dependências são 16 arquivos TS emitidos, modelos/payloads/pool/buffer reais. Sem mock de amostragem/serialização. Isso prepara a importação de timelines, mas não implementa frames especializados, timelines, animação, entrypoint JSON/DBDT ou playback/renderização.

Unidade posterior: oito frames especializados já constam em [SpecializedFrames.md](SpecializedFrames.md); a pendência histórica de todos os serializers acima é sucedida por esse recorte. Os dois deform, timelines, animação e entrypoint continuam ausentes.
