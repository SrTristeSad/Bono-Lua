# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura/algoritmos/comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar completude com pendências.

## Base desta unidade

- main a9e34b08379183d4c59f4909a3d48cdd7327e33f, PR #80, CI pós-merge 41729413783 aprovada.
- Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb conferido.
- Branch port/parser-shared-binary; conferir PR/SHA/CI/merge atuais. Main acompanha checkpoints testados por autorização do proprietário.

## Unidade implementada

_modifyArray e SharedBinaryBuffer auditados contra fonte fixada/backup. Total 22/47 métodos; 25 ausentes, incluindo _parseArmature, animações/timelines e parseDragonBonesData. Sete views tipadas compartilham um Buffer mutável por identidade; snapshots explícitos por bytes(). Índices Lua base 1, offsets públicos de bytes base 0, little endian. Sem getter string em DragonBonesData.binary.

163 cenários/6.272 operações/70.166 colunas por VM Lua 5.4/LuaJIT, zero tolerância. Oráculo executa _modifyArray genuíno com typed arrays nativas e modelos reais. 128 paridades; conversões Int16/Uint16/Float32, ties-even/subnormais/overflow/-0/NaN; holes, memória/bytes/aliases/snapshots, sobreposição, repeated finalize/reset/pool, falhas de cópia e publicação, geometrias/pesos reais. 32 erros esperados.

Mantido teste duplicado de timeline antes de color: color ímpar não recebe padding. Escritas fora dos limites ainda fazem coerção; cópia e publicação conservam efeitos parciais e só resetam defaultColorOffset no fim. Mutantes de padding color/undefined float rejeitados nas linhas 1943/4213; código restaurado e lote final refeito. Dezenove suítes na CI. Contrato contracts/SharedBinaryBuffer.md.

## Próximo recorte

1. Conferir main/backup/PR/CI e ler estado/progresso/mapa/validação/decisões/diferenças.
2. Auditar curvas/frames e dependências originais de animação/timelines; ler TS e Lua reais do backup antes de portar cada corpo. Não fornecer métodos falsos para dependências ausentes.
3. Implementar unidade coerente com testes diferenciais usando modelos reais já disponíveis; depois avançar _parseAnimation/_parseArmature/entrypoint com dependências completas.
4. Atualizar inventário/docs, publicar PR, validar CI e integrar checkpoint autorizado.

## Pendências

25 métodos de ObjectDataParser; texto JSON/importação completa de armaduras/animações/DBDT, BinaryDataParser, locales especiais de DataParser, coerções/reflexão/proxies genéricos (incluindo coeficientes de matriz fora do tipo numérico), Big Endian e payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers, deformação, playback/blending, factories, backend/LÖVE/GPU e contratos de engines. SkinData.NULL é truthy e distinto de raw JSValue.NULL. Loops ES5 indexados/UTF-16 (surrogates WTF-8 no Lua) preservados. sortBones/clipping mantêm possíveis esperas originais; WorldClock ainda usa os.time com resolução de segundos.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Upstream fixado. Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
