# Continuidade — Bono-Lua

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura/algoritmos/comportamentos. Destino SrTristeSad/Bono-Lua; não declarar motor completo, criar renderer/player fictício nem alterar decisões autorais.

Base: main 2c505ccbe576aea7ef4c7826fc5d28b91f5610b9, PR #101; CI após merge 41872083705 aprovada (39 suítes/sete exemplos por VM). Backup backup/pre-integral-rebuild-20261103 cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb intacto. Branch desta unidade: port/slot-display-runtime; consultar PR para head/CI/merge final. Autorização do proprietário mantém main acompanhando checkpoints testados.

Slot: corpos restantes de update/_updateDisplay/replaceDisplay e acessores/aliases representados. Armature parcial tem clock/cache/getters/dispose/fila de ações reais, sem Animation/init/advanceTime. slotruntime_differential: 1.970 cenários/7.880 etapas/165.480 colunas/333 exceções esperadas, zero aproximações locais por VM; seis probes rejeitados, produto restaurado. SlotFoundation/SlotDisplayData reexecutados. CI configurada para 40 suítes/oito exemplos. Exemplo slotruntime troca espada→escudo e usa Slot.update real, com observador local, sem desenho.

Próximo recorte: auditar Constraint/IK/Path ou Animation com suas dependências reais. Completar Armature.init/advanceTime somente com Animation/proxy real, sem simular dependências. Child com inheritAnimation=false e attach por ações já validados; play/reset sem Animation são erros comparados na montagem manual, não sucesso de playback. Ampliar integração Surface/polígono/aliases e exports reais conforme os consumidores ficarem prontos.

Preservar semântica de identidade, false vs nil, ordem de callbacks, guard de raw e pivôs (inclusive agrupamento fractionalPivot), truncamento original de frames sem pooling, dirty de mesh antes do hook, prioridades do cache, unshift de ações e descarte adiado pelo core. Não avançar relógio contendo Armature incompleta; remover root antes de drenar descartes e liberar modelos por último. Não ampliar budgets antigos; SlotRuntime só herda o limite Surface de 32 eps nos derivados desse recorte, flags/refs/índices/zeros pareados exatos.

Continuam pendentes Animation/player, Armature completo, IK/Path, factories, backends LÖVE/GPU, integrações externas, locale/coerções/proxies genéricos, Big Endian e precisão automática de WorldClock (os.time em segundos). Fonte/pin/TODOs permanecem intactos.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes timelines animationparser armatureparser globalentry binaryutf8 binarytimeline binaryanimation binarygeometry binaryviews dbdt corpus transformobject bone surface displayframe slot slotdata slotruntime; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
