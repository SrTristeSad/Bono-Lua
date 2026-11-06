# IEventDispatcher e EventStringType

Fonte: DragonBones/src/dragonBones/event/IEventDispatcher.ts em DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e.

Interface apagada pelo TypeScript; não existe classe executável para converter. O backend fornece um objeto com os métodos abaixo, chamados com `:` em Lua.

| Método | Contrato |
| --- | --- |
| hasDBEventListener(type) | Retorna boolean indicando ouvintes para a string type |
| dispatchDBEvent(type, eventObject) | Despacha a instância recebida; retorno nil |
| addDBEventListener(type, listener, thisObject) | Registra callback e receptor; retorno nil |
| removeDBEventListener(type, listener, thisObject) | Remove a mesma combinação de callback/receptor; retorno nil |

EventStringType aceita qualquer string. Os nove nomes conhecidos permanecem em EventObject; não limitar a interface a eles. O backend preserva identidade de listener/thisObject e adapta a chamada do receptor JS à convenção Lua escolhida para o host. A implementação real do backend LÖVE está em ArmatureDisplay.lua/EventEmitter.lua, portada/adaptada do comportamento do proxy e da dependência Pixi. O this do callback torna-se seu primeiro argumento Lua; se omitido, recebe o próprio display/manager.

O teste events_differential usa probes locais de dispatcher, Armature e animatable para observar os pontos de chamada e injetar falhas. Esses probes isolados não provam o backend. publicfactory_differential acrescenta agora o proxy/factory reais, listeners/contextos/reentrância e despacho do runtime para o manager global de som, comparados às classes originais. Ver [PublicFactory.md](PublicFactory.md). Despachar evento de som não é reproduzir áudio.
