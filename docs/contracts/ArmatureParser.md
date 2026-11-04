# _parseArmature

Fonte integral: ObjectDataParser.ts::_parseArmature, DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. Retorna ArmatureData real a partir de objeto decodificado, usando todos os modelos/parsers já portados. Não cria runtime Armature ou registra automaticamente no DragonBonesData.

| Fase | Regra |
| --- | --- |
| Metadados | Nome/frameRate/scale/type antes de _armature; frameRate zero vira 24 |
| Canvas/aabb | Coordenadas/dimensões multiplicadas por scale; atribuições parciais preservadas |
| Bones | Pais futuros em cache, resolução por nome e ordem raw mantida |
| IK/sort | Constraints IK antes de sortBones |
| Slots/skins/path | zOrder sequencial; path após skins, sem novo sort |
| Compartilhamento | Cache raw/mesh paralelo, comprimento capturado; links antes das animações |
| Animações/ações | Registra animações; depois defaultActions e actions |
| Sucesso | Limpa três lengths/quatro mapas e solta _armature, sem trocar identidades |

CanvasData é alocado antes de consultar rawCanvas; só ligado à armadura após todos os componentes. Erro deixa canvas órfão e campos anteriores intactos. Aabb é o Rectangle real da armadura e recebe x/y/width/height nessa ordem. Scale segue argumento numérico TS, sem default inventado.

Bones guardam filhos cujo parent ainda não está no mapa e os ligam quando o bone chega. Cada bone é passado a addBone e depois _rawBones.push, inclusive duplicata que addBone rejeita. sortBones conserva algoritmo/constraints originais; ciclos ou dependências inválidas podem não terminar. Parent ausente permanece nil e seu cache é descartado apenas no sucesso. Não resolver por segunda árvore ou reparar dados automaticamente.

Skins/displays/weights/path/IK/AnimationData são reais. Shared mesh usa literalmente getMesh(skinName,"",shareName), TODO de slot vazio. Busca vazia/ausente continua sem link, mesmo que o nome exista noutro slot. Encontrado o display, GeometryData.shareFrom preserva flags/offset/peso e regras de propriedade. Primeiro parseia todas as skins e liga meshes; só então parseia animações que podem consumir essa geometria.

Cada defaultAction Play cujo nome encontra AnimationData substitui defaultAnimation; prevalece a última válida. Ações não Play e nomes ausentes não substituem. DefaultActions e actions têm listas/ownership distintos. Retornar ArmatureData não chama data.addArmature, _parseArray ou _modifyArray.

Falhas não limpam caches nem contexto: bones/skins/animações já inseridos, órfãos e arrays/poses permanecem. Nova chamada pode continuar desse estado, como no original. No sucesso apenas lengths rawBones/cacheRawMeshes/cacheMeshes viram zero; membros dos quatro mapas são removidos conservando os objetos de mapa. Outros estados seguem os métodos internos originais.

Prova: tests/armatureparser_differential.{js,lua}, 79 cenários/3.670 operações/113.770 colunas por VM Lua 5.4/LuaJIT, zero tolerância, 24 exceções esperadas e 83 chamadas genuínas. Executa 17 arquivos TS emitidos, incluindo CanvasData real. Pais futuros/ausentes, duplicatas, sort IK, slots/skins/path, ações herdadas, sharing com/sem pesos, links usados por animação, defaultAnimation, canvas/aabb parciais, erros/retry/caches, múltiplas armaduras/global real e pool/bytes. NaN Float32 normalizado só no snapshot, conforme contrato anterior.

Estado 46/47; parseDragonBonesData ainda ausente. Objetos globais e registro/finalização são semeados/chamados explicitamente no teste até o entrypoint ser portado. Não lê JSON texto/DBDT completos nem avalia animações/solvers/deformações/renderização. Limites de tipos TS/JSON-like, protótipos/reflexão/coerções/plataforma e TODOs anteriores preservados.

Unidade posterior: parseDragonBonesData já integra este método com ownership/stage/buffers em [GlobalObjectEntry.md](GlobalObjectEntry.md). Estado atual 47/47 corpos; os limites históricos de entrada semeada acima descrevem a suíte anterior. Runtime/arquivos/DBDT continuam pendentes.
