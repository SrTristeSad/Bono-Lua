# Continuidade — Bono-Lua

DisplayFrame: 2.304 cenários/32.256 colunas por VM, 192 falhas esperadas, tolerância zero; 37 suítes e cinco exemplos. Próximo recorte: classe Slot abstrata e registro real em Armature, mantendo hooks gráficos abstratos até o backend.

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar motor completo com pendências.

## Base desta unidade

main 265304b316a2987df5e57bd9078a27049f883ae6, PR #99, CI após merge 41860056636 aprovada. Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb. Branch port/display-frame; consultar PR para SHA/merge/evidência final. Autorização do proprietário mantém main acompanhando checkpoints testados.

## Unidade implementada

Surface implementado com pais Bone/Surface e filho Bone reais, sem stubs. 585 cenários/38.610 consultas/26.325 colunas por VM, duas falhas esperadas, 41.231 aproximações no orçamento específico de Surface (ver contracts/SurfaceRuntime.md). Flags/arrays/deforms/zeros pareados são exatos; cancelamento de coordenadas trig usa limite absoluto escalado pela projeção original 1000. CI com 36 suítes e quatro exemplos. Comando surface demonstra grade e osso filho passando de (50,50) a (50,90).

Preservar helpers compartilhados, cache [flag,a,b,c,d,tx,ty], invalidação antes dos vértices, _matrixCahce, hull inicial 10→12, NaN de misses e TODO upstream. Campos/flags e budgets não podem ser normalizados genericamente para esconder erros. Armature continua parcial: montagem explícita de _armatureData, sem init/player/factory fictício.

## Próximo recorte

1. Conferir main/backup/PR/CI, progresso, diferenças e contratos.
2. Auditar Slot TS/Lua e interfaces de backend, separando métodos abstratos de lógica portável. Não criar renderer/slots de produto fictícios para habilitar player.
3. Escolher o próximo recorte real de Slot/constraints/animação a partir da auditoria; manter exemplos bones/surface e montagem manual explícita até init/factory completos.
4. Atualizar inventário/docs, PR/CI e integrar checkpoint autorizado. Runtime/factories/backends permanecem etapas próprias.

## Pendências

Exportações externas ao pin e leitura externa; JSON sem promessa de profundidade ilimitada/locale alternativo; TODOs upstream, locales especiais, coerções/reflexão/proxies genéricos, contextos fora do domínio TS, Big Endian e payloads NaN arbitrários. Runtime Armature/Bone/Slot/Surface, solvers IK/Path, deformações, avaliação/playback/blending, factories, backend LÖVE/GPU e contratos de engines. WorldClock continua os.time com resolução de segundos; não relaxar tolerâncias anteriores.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes timelines animationparser armatureparser globalentry binaryutf8 binarytimeline binaryanimation binarygeometry binaryviews dbdt corpus transformobject bone surface displayframe; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
