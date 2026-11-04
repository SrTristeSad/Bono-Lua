# Continuidade — Bono-Lua

## PathConstraint — curva e seguidores

Portado o corpo de PathConstraint para módulo próprio, completando as três classes de Constraint.ts no domínio documentado. Parser/modelos/Bone/Slot/Armature reais; preservados loops, buffers incompletos e TODOs originais. Teste diferencial: 2.851 cenários, 8.553 etapas, 193.868 colunas e 33 erros esperados por VM Lua 5.4/LuaJIT. Precisão e limites em [PathConstraint.md](contracts/PathConstraint.md). CI passa a executar 42 suítes e dez exemplos por VM.

Teste sem dependências JS: `lua5.4 examples/run.lua path` ou `luajit examples/run.lua path`. Dois ossos seguem a curva em 25%, 50% e 75%. Montagem manual, sem player ou renderer; Animation, Armature completa, factories e backends permanecem pendentes. Esta atualização substitui as indicações históricas de Path pendente abaixo.

Base deste checkpoint: main db9a0513112a91fe812c5286ba43e181cf6b881a / PR #103; branch port/path-constraint. Consultar o novo PR para SHA/CI/merge. Backup preservado.

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura/algoritmos/comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar motor completo nem criar dependências, solver, renderer ou player fictícios.

Base desta unidade: main b829702d8b4c83dbd23b11b4d947cb9fac6dd142, PR #102, CI após merge 41882756869 aprovada (40 suítes/oito exemplos por VM). Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb preservado. Branch port/ik-constraint; consultar PR para head/CI/merge final. Autorização do proprietário mantém main acompanhando checkpoints testados.

Implementados Constraint base e IKConstraint em módulos separados; PathConstraint do mesmo TS pendente. Armature tem _addConstraint real; Bone.update chama IK pelo registro e preserva solução/cache. ik_differential: 15.404 cenários/46.212 etapas/955.048 colunas/32 exceções esperadas/25.355 aproximações locais por VM; seis mutantes rejeitados e produto restaurado. Bone diferencial também reexecutado. CI configurada para 41 suítes/nove exemplos. Comando ik: ponta (18,0)→(12,8)→(8,12), alvo manual, parser/runtime/solver reais e sem player/tela.

Preservar TODO scaleEnabled, guarda de init, _hasConstraint/localDirty, normalização e ordem das operações originais. Base._onClear NÃO limpa _constraintData; IK a limpa. Não resetar flags do osso por invenção ao limpar solver. Numeric budget novo é condicionado/limitado conforme IKConstraint.md, máximo 64 eps em derivados IK e coordenadas com escala geométrica de 8 eps; flags/ref/índices/zeros exatos. Nenhum budget anterior mudou. Reproduzir caso 14636 e caso discriminante de peso zero 8448 conforme contrato, sem ajustar o algoritmo para libm.

Próximo recorte: Animation com dependências reais, seguindo o inventário e os contratos. Armature.init/advanceTime dependem de Animation/proxy; não usar substitutos. IK com pai Surface ainda não validado. Permanecem Animation/player, factories, backends, integrações externas e auditoria final.

Preservar ainda contratos Slot/Bone/Surface: false distinto de nil, retenção baseada no display anterior, mesh dirty antes do hook, cache e unshift de ações, descarte adiado, pivôs/fractionalPivot, truncamento original de frames sem pooling. Não avançar relógio contendo Armature incompleta; remover root antes de drenar descartes e liberar modelos por último. Os limites de locales/coerções/proxies/Big Endian/WorldClock os.time continuam.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes timelines animationparser armatureparser globalentry binaryutf8 binarytimeline binaryanimation binarygeometry binaryviews dbdt corpus transformobject bone surface displayframe slot slotdata slotruntime ik path; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
