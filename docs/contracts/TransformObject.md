# TransformObject — base abstrata do runtime

Fonte integral: TransformObject.ts e backup Lua, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Inicializadores, _onClear, updateGlobalTransform e getter armature portados. Não adiciona toString concreto à classe abstrata: BaseObject.borrowObject(TransformObject) continua falhando na identificação abstrata, como o JS.

| Dependência | Natureza nesta unidade | Estado |
| --- | --- | --- |
| BaseObject | Construtor/pool/limpeza | Implementado e usado realmente |
| Matrix/Transform/Point | Três helpers estáticos e vetores por instância/decomposição | Implementados e usados realmente |
| Armature | Anotação TS e referência no getter | Sem chamada de método, import Lua ou stub |
| Bone/Slot | Referências em documentação | Não são implementados por esta base |
| Backend gráfico | Nenhuma chamada | Fora desta unidade |

new(Subclass) executa somente inicializadores: matriz, global e offset distintos por instância. Campos sem inicializador permanecem undefined no JS/nil em Lua até _onClear. Pool.borrowObject chama _onClear no primeiro empréstimo. Não limpar automaticamente no construtor nem criar propriedade readonly artificial para vetores: readonly TS desses campos é só estático, e a atribuição JS continua permitida. Getter armature é somente leitura e rejeita atribuição normal. Reflexão/rawset/descritores arbitrários não são emulados.

Subclasses Lua devem delegar o lookup de instância ao __index desta base e usar seu __newindex para preservar o getter. Estática via metatable __index=TransformObject compartilha os helpers. Ver exemplos/run.lua para padrão concreto de demonstração. Não tratar a classe de exemplo/teste como implementação de Bone/Slot.

_onClear chama matrix.identity, global.identity e offset.identity nessa ordem, preservando identidade. Só depois zera origin/userData, dirty, alphas e armature. Referências opcionais null/undefined são normalizadas nil e não são devolvidas ao pool. Falhas não fazem rollback nem finalizam etapas posteriores. updateGlobalTransform consulta dirty (domínio booleano TS), limpa-o antes de fromMatrix e não repete a decomposição enquanto limpo, inclusive após erro. Não faz herança de transforms de pais, avaliação de animações ou atualização de renderização.

212 cenários/8.056 colunas por VM Lua 5.4/LuaJIT, 35 falhas esperadas. Matrizes regulares/espelhadas/degeneradas, NaN/Infinity/zeros assinados e 128 matrizes determinísticas; chamadas repetidas, clear/reuso/pool, identidade de vetores/helpers, referências opacas e setter readonly. Falhas injetadas mantêm métodos reais e interrompem identity/fromMatrix para observar ordem e estado parcial. Oracle compila/executa a classe TS com matemática e pool reais; subclasse mínima existe somente no teste para concretizar a base abstrata.

Tolerância já estabelecida em Transform.fromMatrix: somente skew/rotation/scaleX/scaleY não nulos após decomposição podem diferir até 8*epsilon*max(1,abs(expected)); translações, zeros, flags, referências, offsets e demais campos são exatos. Foram 27 comparações aproximadas por VM. Não ampliar para esconder diferenças em outros campos. Mutantes que omitem dirty=false ou substituem global durante limpeza são rejeitados.

Exemplos inspect/transform executados em ambas as VMs, incluindo importação manual de DBDT real mecha_1406 na escala 0,5. CI executa ambos com fixture mínimo incluído; não precisa de Node/npm para o uso dos exemplos. Próximo trabalho: auditar Bone e dependências reais/ciclos com Armature, Surface e constraints antes de escolher o próximo recorte.
