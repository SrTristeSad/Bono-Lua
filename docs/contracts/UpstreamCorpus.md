# Corpus esquelético do commit upstream

Fonte exclusiva: DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e. tests/corpus_differential.js enumera git ls-tree do pin e lê git show por SHA de blob, sem usar arquivos de trabalho editados. Seleção: todos os .dbbin e JSON válidos que têm propriedade própria armature. Atlas e JSON de configuração sem armature ficam fora deste corpus.

181 caminhos correspondem a 74 pares únicos SHA/extensão: 71 JSON e três DBDT. Duplicatas entre engines são registradas no manifesto, mas não contadas como novos testes. Cada blob é importado intacto nas escalas 1 e 0,5: 148 cenários/1.924 colunas por VM, zero erros de importação e tolerância zero. Não converte JSON para um DBDT inventado nem edita os exports para fazê-los passar.

O oracle compila o núcleo TS fixado. JSON.parse e ArrayBuffer são instanciados no mesmo contexto VM das classes; arrays de outro contexto mudam instanceof Array e produzem falsos resultados. A primeira rodada revelou essa falha do transporte do teste; corrigiu-se o oracle, sem alterar o produto para reproduzi-la. Na Lua, JSON.parse usa o adaptador existente e DBDT recebe SharedBuffer.

Observações: nome/versão/frameRate/stage, ordem das armaduras/bones/skins/displays/animações, geometrias e pesos/bones, frameIndices e mapas de timelines, tipo/offset/frameIndicesOffset/x/y, metadados de views e aliases com data.binary, poses locais/inherit flags, slots/cores, display transforms/bounding boxes escalares, metadados de animação/ZOrder, constraints escalares e defaultAnimation. Campo numérico é observado em binary64, inclusive zero assinado; strings em UTF-16. Referências opcionais null/undefined dos modelos seguem normalização nil já documentada; este corpus não é prova de reflexão/protótipos genéricos.

Compara todos os bytes dos buffers gerados ou compartilhados e preservação dos bytes de entrada. Nenhuma tolerância ou normalização de NaN foi necessária neste corpus. Captura empréstimos reais de BaseObject por classe e ordem, e estado _isInPool após returnToPool do dado global; não substitui os modelos/pool por stubs. A observação é selecionada, não uma reflexão exaustiva de todo campo do motor.

Artefatos: corpus-manifest.json (pin, SHA Git, SHA-256, tamanho, todos os caminhos), corpus-inputs-<vm>/ (blobs exatos), corpus-cases-<vm>.tsv, corpus-<vm>-original.tsv, corpus-<vm>-actual.tsv e resultados JSON. O teste conta o manifesto integral mesmo quando um SHA opcional é usado para reproduzir um caso; testedFiles/scenarios deixam o recorte explícito. CI sempre executa sem filtro, com todos os 74 arquivos.

```sh
NODE_PATH=node_modules node tests/corpus_differential.js ../DragonBonesJS lua5.4
NODE_PATH=node_modules node tests/corpus_differential.js ../DragonBonesJS luajit
# Diagnóstico opcional de um blob, sem alterar a seleção padrão da CI:
NODE_PATH=node_modules node tests/corpus_differential.js ../DragonBonesJS lua5.4 6eaddc0376fc7f09d8a5da387503cc28dd43d1d1
```

Este checkpoint amplia evidência dos parsers, sem mudar o motor. Não executa playback/renderização/GPU/backends nem valida exports fora do commit. Bounding boxes poligonais, userdata, reflexão e outros campos não listados mantêm as evidências das suítes próprias, não uma nova garantia integral pelo corpus. Próximo trabalho: dependências e primeira unidade de runtime portável.

Sensibilidade: alterações que retêm _data após a importação JSON ou rejeitam tag DBDT válida foram detectadas e restauradas. O corpus binário não provocou empréstimo de WeightData: não considerar essas três exportações como cobertura do ramo ponderado binário. Esse ramo continua sustentado pela suíte BinaryGeometry específica; o corpus JSON exercita pesos, com contagem explícita nos resultados.
