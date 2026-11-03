# IEventDispatcher e EventStringType

Fonte: DragonBones/src/dragonBones/event/IEventDispatcher.ts em DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e.

Interface apagada pelo TypeScript; não existe classe executável para converter. O backend fornece um objeto com os métodos abaixo, chamados com `:` em Lua.

| Método | Contrato |
| --- | --- |
| hasDBEventListener(type) | Retorna boolean indicando ouvintes para a string type |
| dispatchDBEvent(type, eventObject) | Despacha a instância recebida; retorno nil |
| addDBEventListener(type, listener, thisObject) | Registra callback e receptor; retorno nil |
| removeDBEventListener(type, listener, thisObject) | Remove a mesma combinação de callback/receptor; retorno nil |

EventStringType aceita qualquer string. Os nove nomes conhecidos permanecem em EventObject; não limitar a interface a eles. O backend preserva identidade de listener/thisObject e adapta a chamada do receptor JS à convenção Lua escolhida para o host. Nenhum dispatcher de produto ou implementação gráfica foi inventado aqui.

O teste events_differential usa probes locais de dispatcher, Armature e animatable para observar os pontos de chamada e injetar falhas. Só dispatchDBEvent é chamado pelo núcleo; os outros três métodos ainda dependem da integração real. Probes não provam implementação de Armature, backend, propagação/listeners ou áudio.
