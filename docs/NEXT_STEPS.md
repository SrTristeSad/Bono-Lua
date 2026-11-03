# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Destino único SrTristeSad/Bono-Lua. Comparação diferencial exigida; não declarar completude com pendências.

## Base desta unidade

- main da300139d0e96e5645c56483dccd327ccaa47fd6, PR #76 integrado, CI pós-merge 41687483454 aprovada.
- Backup remoto backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb conferido intacto.
- Unidade port/parser-data-base; consultar PR/SHA/CI/merge atuais antes de editar. Main acompanha checkpoints testados por autorização do proprietário.

## Unidade implementada

DataParser.ts e Lua integral do backup lidos. dragonbones/parser/DataParser.lua contém 132 constantes, DATA_VERSIONS como JSArray base 1/length e dez conversões; duas assinaturas abstratas permanecem sem corpo. Sem BaseObject/pool/construtor ou importador fabricado. Grafia DRADON_BONES e lista de versões originais mantidas.

11.206 operações/44.824 colunas por VM Lua 5.4/LuaJIT, tolerância zero. AST enumera constantes/cases/métodos, resultados vêm do TS emitido genuíno. Todas as combinações ASCII de caixa dos tokens, defaults/invalidos/espacos/NUL/Unicode, 50 erros de tipos, 1.200 operações determinísticas e 90 aplicações em modelos reais. Array de versões tem mutações/aliases/herança/esparsidade/extras/length máximo comparados. Modelos reais não significam parsing pronto.

Matching baixa ASCII sem depender do locale C, mais Kelvin→k observado no motor JS. Não é lowercase Unicode genérico. Os três helpers toLocaleLowerCase foram comparados em en-US/casing não túrquico; tr/az e outros locales do host continuam pendência explícita. Ver contracts/DataParserBase.md. Mutantes que perdem Kelvin e que fazem trim incorreto falharam nas linhas 9.511/1.050; produto restaurado e testes finais refeitos. Quinze suítes na CI.

## Próxima unidade

1. Conferir main, backup, PRs/CI, estado/progresso/mapa/validação/decisões/diferenças.
2. Auditar parser/ObjectDataParser.ts completo e Lua real do backup; mapear dependências e ordem de estado/ciclo de vida, sem misturar implementação de BinaryDataParser.
3. Começar pelos helpers _getBoolean/_getNumber/_getString e parseTextureAtlasData com TextureAtlasData/TextureData reais; comparar retornos/campos/escala/retângulos/duplicatas/falhas contra TS genuíno. Marcar métodos restantes pendentes, sem stubs de parsing de armadura/animação.
4. Antes de parsing binário, auditar e implementar fronteira compartilhada de ArrayBuffer/views tipados; referências já decodificadas não provam coerção/endianness/compartilhamento.
5. Atualizar inventário/documentação, publicar PR, conferir CI e integrar checkpoint autorizado.

## Pendências

- ObjectDataParser/BinaryDataParser, importação JSON/DBDT, ArrayBuffer/typed views e locales especiais de toLocaleLowerCase.
- Armature/Bone/Slot/Surface de runtime, hit testing de Slot/transformações mundiais, solvers IK/Path, deformação, playback/timelines/blending, factories, backend/LÖVE/GPU e contratos de engines.
- SkinData.NULL é truthy em Lua; consumidores devem reconhecer marcador por identidade.
- Mapas não emulam Object.prototype; descritores/proxies/coerções JS genéricas não são equivalência declarada. Referências null/undefined normalizam nil salvo decisões estritas documentadas.
- sortBones conserva esperas originais; testes usam grafos acíclicos, sem detector/timeout no produto. Clipping com bounds invertidos pode não terminar no original e não recebeu proteção nova.
- WorldClock._now usa os.time com resolução de segundos; testes determinísticos não provam precisão automática equivalente ao Date em ms.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Upstream deve estar no commit fixado. CI preserva transcrições/JSON por VM. Consultar PR para SHA final, merge e CI pós-merge; não antecipar evidências futuras.
