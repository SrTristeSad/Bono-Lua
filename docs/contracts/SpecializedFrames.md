# Frames especializados do parser

Fonte: ObjectDataParser.ts em DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Estes oito serializers consomem os frames genéricos já portados e modelos reais; não são playback/solvers.

| Método | Saída e estado |
| --- | --- |
| _parseZOrderFrame | Posição, contagem e ordem de slots, preenchimento reverso |
| _parseBoneAllFrame | Seis floats de transform/rotação e ações depois dos valores |
| _parseBoneTranslateFrame | Dois floats x/y, default zero |
| _parseBoneRotateFrame | Dois floats rotation/skew em radianos, estado de voltas |
| _parseBoneScaleFrame | Dois floats x/y, default um |
| _parseSlotDisplayFrame | Índice step, presença de value precede displayIndex; ações com slot.parent |
| _parseSlotColorFrame | Oito componentes em colorArray; offset em frameIntArray e cache default |
| _parseIKConstraintFrame | bend 0/1 e weight ×100 arredondado em frameIntArray |

Índices Lua base 1, offsets públicos base 0 e length lógico de JSArray. Reservas aumentam length antes das leituras seguintes e deixam holes nas falhas. _modifyArray converte para as views tipadas já portadas. Nenhuma reserva foi preenchida antecipadamente para esconder holes.

BoneAll reinicia helpTransform, lê transform e então ajusta rotação. BoneRotate lê rotate em graus e usa o mesmo ajuste: com clockwise anterior zero, normalizeRadian; senão, decremento/incremento de voltas conforme comparação e expressão prev+rotation−prev+PI_D*clockwise. Não simplificar essa expressão nem atualizar estado depois do tween. Falha no tween mantém prevRotation/prevClockwise já alterados. BoneAll usa tweenRotate e BoneRotate usa clockwise, como o original. FrameStart zero ignora estado anterior. Falhas em x/y/skew/weight deixam tamanho reservado e valores anteriores intactos.

ZOrder depende de sortedSlots real, lê pares slotIndex/offset e valida o comprimento dos temporários como Array.length nativo. Quantidade ímpar/excessiva pode lançar RangeError depois de reservar a posição do frame. Preenche a saída do fim para o início, consumindo unchanged em ordem reversa e aplicando fallback ||0. Índices de slot inválidos podem tornar o while não terminante, como no original; os testes usam casos terminantes. Coerção +/ToPrimitive genérica de objetos não é afirmada.

SlotColor escolhe value por presença antes de color, mesmo que seja null/undefined. O for-in original é adaptado para valores JSON-like e primitivos: objetos vazios/arrays com somente holes não têm propriedade enumerável; array com own undefined tem; string não vazia entra no parser e lança ao usar in. Propriedade desconhecida também aloca cor explícita. Protótipos/descritores/reflexão JS genéricos não são emulados.

Default branco é alocado uma vez por cache; _defaultColorOffset é definido antes da reserva que pode falhar. Cor explícita não é deduplicada. O offset só é anexado a frameInt após o registro completo. _modifyArray redefine cache para −1 e _parseArray apenas limpa arrays, conservando o cache. Todos esses estados e falhas são comparados.

Prova: tests/specialframes_differential.{js,lua}, 203 cenários/7.577 operações/159.117 colunas por VM Lua 5.4/LuaJIT, zero tolerância e 39 exceções esperadas. Oito contadores de métodos genuínos; 16 arquivos TS emitidos, Transform/Bone/Slot/ArmatureData/ActionData/UserData/pool/finalização tipada reais. Inclui sequências de rotação, nonfinite/-0, precedência/defaults/coerções, cache, erros parciais/overflow, ações e bytes finais.

O adaptador canonicaliza NaN numérico; sinal/payload arbitrários não são equivalência declarada. Infinitos podem produzir NaN negativo no host JS. Só essas células Float32 têm sinal/payload normalizado em snapshot separado de observação, em ambos os lados; memória/views originais não são modificadas pelo teste. Todos os demais bytes e valores/zero assinado são comparados exatamente. Não se estende essa normalização a dados inteiros ou finitos.

Pendentes: _parseSlotDeformFrame/_parseDeformFrame, três métodos de timelines, _parseAnimation/_parseArmature/parseDragonBonesData. Estado total: 39/47 métodos, 8 ausentes. Não importa JSON/DBDT completos nem executa deformação, blending, animação ou renderização.

Unidade posterior: os dois serializers de deformação já constam em [DeformFrames.md](DeformFrames.md), preservando inclusive o TODO ponderado do genérico. Estado atual 41/47; seis métodos ausentes. O limite histórico acima é sucedido por essa unidade, sem implementar runtime.
