# Bone regular e registro real de Armature

Fontes: Bone.ts integral e Armature.ts integral, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e; backups Lua correspondentes lidos. Bone conserva os corpos do original. Armature é deliberadamente parcial; não copiar APIs não validadas do backup como se estivessem prontas.

| Dependência/caminho | Implementação usada | Limite |
| --- | --- | --- |
| Hierarquia/poses | Bone/TransformObject/Matrix/Transform reais | Pais Bone regulares; Surface pendente |
| Registro/init de Bone | Armature real com _addBone/getBone/getBones/getSlots | Montagem manual do container, sem Armature.init |
| Cache | ArmatureData.setCacheFrame/getCacheFrame e DragonBonesData.cachedFrames reais | Índices inteiros finitos; holes em listas lógicas |
| Alpha/flips | Bone e acessores de Armature originais | Flags booleanos e campos numéricos binary64 |
| Constraints/slots | Chamadas originais preservadas no corpo | Não validadas com instâncias runtime não vazias; sem stubs |
| Animation/Proxy/clock na limpeza | Chamadas originais preservadas | Ramas não vazias ainda pendentes de integração |

Armature inclui inicializadores, toString/_onClear, _addBone/getBone/getBones/getSlots/invalidUpdate e acessores flipX/flipY/name/armatureData. Arrays têm JSArray.length, índices Lua base 1; cache mantém índices externos base 0. _addBone deduplica identidade e getter retorna o array vivo. Flip publica a nova flag antes de invalidUpdate. _onClear retorna bones ao pool antes de truncar registros, sem devolver ArmatureData (referência não proprietária). Demais métodos como init/advanceTime, animação, sorting/hit testing, cacheFrameRate/clock/display e gestão de slots/constraints estão ausentes, não simulados.

Bone.init é idempotente quando _boneData já está definido, resolve pai pelo nome antes de registrar e só então publica origin. Pai ainda não registrado permanece ausente, como no original. contains exclui o próprio osso. Não acrescenta detecção de ciclos: domínio testado é hierarquia finita/acíclica. Getters somente leitura não criam campos sombra; visible preserva a publicação antes do callback e usa getSlots vivo, testado sem slots runtime.

_updateGlobalTransformMatrix conserva modos None/Additive/Override, cálculo yDown/flipY, herança de escala/rotação/translação/reflexão e decomposição adiada quando sem cache. Ramo Surface conserva a chamada original mas não tem implementação/prova nesta unidade. update/updateByConstraint conservam flags, invalidação pelo pai e leitura/escrita de cache; _hasConstraint permanece falso no domínio integrado (updateByConstraint é chamado diretamente, não por solver fictício).

Fronteira numérica: entrada JS é binary64; fixture Lua usa números flutuantes correspondentes. Negação promove via *1.0 para preservar +0/-0 mesmo com atribuição de zero inteiro Lua 5.4; não emula inteiros arbitrários de 64 bits, coerção JS/protótipos ou manipulação irrestrita de length/índices. Referências opcionais null/undefined normalizam nil.

1.576 cenários/44.128 colunas por VM Lua 5.4/LuaJIT, seis falhas esperadas. Todas as 16 combinações de herança, pais presentes/ausentes, três modos, quatro flips, dois yDown, com/sem cache; escalas negativas/reflexão, signed zero, cache hit/restauração/miss limpo, pai dirty, repetição, init repetido/fora de ordem, getters, visibilidade, limpeza e falhas injetadas. Oracle usa Bone, Armature, modelos e matemática TS reais, sem substitutos de Armature/Constraint/Slot. Monta _armatureData manualmente nos dois lados, sem afirmar validação de Armature.init.

Tolerância: somente componentes não nulos derivados de trigonometria podem variar até 8*epsilon*max(1,abs(expected)), incluindo o mesmo payload copiado ao cache. Foram 340 comparações aproximadas por VM. Flags, índices, alpha, offset/animationPose, zeros e demais campos são exatos. Translação de raízes/Override permanece exata; translação herdada pode propagar diferença de trig. Não chamar esse limite de cache bit a bit: a cópia é real, mas seu payload trig segue a mesma tolerância.

Exemplo `lua5.4 examples/run.lua bones` carrega modelos JSON reais e monta dois Bone no container real; filho (40,20) passa a (10,50) com pai girado em 90°. Pool limpa o runtime antes dos dados. Sem playback, backend ou factory: próximo recorte deve auditar Surface e Slot/constraints e coordenador de animação para escolher dependência real, não acrescentar stubs.
