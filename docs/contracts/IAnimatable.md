# IAnimatable — contrato original

Origem: DragonBones/src/dragonBones/animation/IAnimatable.ts, commit 64b6c69ae35777c2404be68c9192e2c56906079e.

| Membro TS | Contrato Lua | Unidade/retorno |
| --- | --- | --- |
| advanceTime(passedTime: number): void | object:advanceTime(passedTime) | Segundos; retorna nil |
| clock: WorldClock \| null | object.clock | Referência de WorldClock ou nil |

É uma interface de tipos apagada na compilação TS. Não existe algoritmo próprio nem classe Lua fictícia para implementar. WorldClock satisfaz esse contrato; Armature será portado separadamente.

WorldClock implementa clock por getter/setter, com remove/add recíprocos no relógio antigo/novo. Objetos externos devem fornecer o comportamento de propriedade que lhes pertence: o original não transforma automaticamente um campo simples em setter. Testes cobrem campos simples e propriedades recíprocas para preservar o comportamento observável de ambos.

Não adicionar guards, detecção de ciclos ou métodos que não estão no original. Ciclos que o original não consegue percorrer com segurança não são apresentados como suportados. _now é adaptação de host do porte, em segundos de época; não pertence à interface IAnimatable nem altera o algoritmo de avanço.
