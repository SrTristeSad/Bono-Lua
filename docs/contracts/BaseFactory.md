# BaseFactory e montagem automática

Fonte: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e, factory/BaseFactory.ts. Lidos construtor, busca/pacote, montagem de bones/slots/constraints/filhos, seleção de display, parse/cache/remoção, buildArmature, substituições e getters; consultado o backup Lua cd4206a8. BuildArmaturePackage está exposto como BaseFactory.BuildArmaturePackage.

## Contrato e fluxo

BaseFactory continua abstrata: o backend implementa _buildTextureAtlasData, _buildArmature e _buildSlot. Os guards Lua dão erro explícito se forem chamados sem implementação; não há armadura, slot ou textura substitutos na base. BaseFactory.new(dataParser, classType) permite ao backend delegar o construtor e seus getters. O construtor compartilha os dois parsers estáticos como no original.

parseDragonBonesData recebe objeto JSON já decodificado ou SharedBinaryBuffer (ArrayBuffer do original). Só o buffer seleciona o parser binário estático; os demais objetos usam _dataParser. Texto/filename não é inferido. Depois do parse, drena atlas embutidos, emprestando inclusive o último candidato que é devolvido ao pool quando não há mais atlas, antes de registrar os dados. parseTextureAtlasData cria o modelo, chama o parser e só então vincula o recurso pelo backend; preserva textureAtlas || null, inclusive 0/false. updateTextureAtlases repassa os valores sem essa normalização e respeita os comprimentos lógicos.

A busca usa os caches e seus flags autoSearch, conservando ordem JS de chaves próprias. Sem nome de dados pesquisa em todos; com nome ausente só usa fallback quando factory.autoSearch e data.autoSearch permitem. Skin não encontrada pode ser resolvida pelo defaultSkin de uma armadura com aquele nome quando autoSearch está ativo. TextureAtlasName explícito é vinculado ao DisplayFrame, sem substituir a resolução/cache de textura do próprio DisplayData. Os mapas e listas retornados são as coleções reais; add deduplica identidade, mantém a entrada anterior ao colidir nome e avisa. Remoção/clear eliminam os registros imediatamente e adiam o pooling pelo core quando disposeData=true.

buildArmature chama os três hooks e o fluxo original de construção: Bone/Surface reais, merge de defaultSkin com skin escolhida, Slot/display real, constraints IK/Path reais (tipo desconhecido ainda cai em IK), invalidUpdate e advanceTime(0). Frames com null conservam a chamada original replaceDisplay(nil) sem índice na montagem. Mesh usa rawDisplay quando o backend não suporta mesh. BoundingBox não cria objeto gráfico. Display filho chama buildArmature recursivamente, aplica inheritAnimation e conserva as regras/ordem de ações explícitas/defaultActions ou play automático. O modelo de display recebe a referência à armatureData filha.

replaceDisplay conserva o fallback do índice e usa meshDisplay ao trocar a imagem de um raw mesh. replaceSlotDisplay/List mantêm os retornos e tratamento de nomes ausentes. replaceSkin preserva exclusões (inclusive lista esparsa), fallback à defaultSkin, override e frames null. replaceAnimation faz override/merge de mapas e mantém a passagem recursiva pelo snapshot de displayList para os filhos elegíveis.

## Representação e limites

JSMap preserva chaves numéricas/ordem de inserção; JSArray usa length lógico e armazenamento base um com índices públicos base zero. SkinData.NULL representa null nas listas de display; é convertido antes das chamadas de runtime. Getters clock/dragonBones são readonly. Avisos são emitidos em stderr, não console.warn. Mapas com propriedades herdadas/nomes de protótipo, coerções arbitrárias, ciclos de displays filhos e callbacks reentrantes não fazem parte deste domínio. DisplayData arrays esparsos com undefined não são equivalentes às listas contíguas com null aqui testadas.

Todos os corpos de BaseFactory estão representados, mas a cobertura não equivale a garantir todas as composições possíveis. O percurso recursivo de replaceAnimation está presente; variantes complexas com múltiplos datasets de filhos não foram comparadas nesta suíte. Buffers binários complexos continuam cobertos pelos contratos de parser; esta suíte verifica a seleção binária com um DBDT mínimo válido. Nenhuma tolerância numérica anterior foi ampliada.

## Validação

factory_differential transpila os blobs do pin e compara 252 cenários/85.217 colunas por VM Lua 5.4/LuaJIT, duas escritas readonly esperadas, zero aproximações. Integra parsers/modelos/buffers, BaseFactory, Armature/Animation, Bone/Surface, Slots, IK/Path, clock/core/pool reais. Backend independente de teste implementa somente os três hooks e os 14 callbacks abstratos de Slot, com Atlas/TextureData reais de subclasse; não desenha nem carrega imagens.

Grade: autoSearch, três nomes de dados, três skins, atlas explícito/implícito, mesh suportada/não suportada e três perfis de filho. Casos adicionais: dados/filhos ausentes, ausência de defaultSkin, ações explícitas/default/fallback, atlas embutido, DBDT, colisão/deduplicação, chaves numéricas, flags de busca, troca de display/null/lista/skin e exclusões esparsas, override/merge de animações, remoção com/sem dispose, clear sem dispose, Path e constraint desconhecida, parser explícito e escala 2. Compara ordem/identidades dos caches, pacotes, bindings de atlas, objetos montados, poses, frames/displays/texturas, callbacks, filas de descarte e pooling.

Oito mutações rejeitadas: bones omitidos, overlay de skin omitido, atlas explícito ignorado, mesh sempre ativada, ações de filho omitidas, exclusão de skin ignorada, parser binário trocado e merge de animações omitido. Regressão armatureruntime nas duas VMs. CI: 54 suítes e 22 exemplos únicos por VM.

## Exemplo e próximos passos

`lua5.4 examples/run.lua factory` (ou LuaJIT) importa skeleton/atlas, chama buildArmature, play e clock. Monta automaticamente 5 bones, 3 slots e 1 IK, reproduz 0→20→40→20 com troca de display e despacha eventos. Dispose/clear são drenados pelo core na ordem correta. Não há montagem manual desses objetos no exemplo.

`examples/ObserverFactory.lua` é backend de observação editável, separado do runtime. Ele mostra onde conectar o renderer e onde vincular a textura, sem GPU ou desenho. A integração gráfica ainda precisa de backend; não foi escolhido um motor gráfico pelo usuário. Porte da base não significa paridade integral com todas as integrações de DragonBonesJS.
