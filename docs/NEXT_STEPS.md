# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Destino SrTristeSad/Bono-Lua. Não declarar motor completo com pendências. Sem renderer/player/dependências de produto fictícios.

## Base e unidade atual

Base integrada: PR #100, main 9a78e35f834854749214ecffee01884c63f4ddc1. CI do PR 41865523528 e após merge 41868022089 aprovadas: três jobs, 38 suítes por VM, seis exemplos e três artefatos vinculados aos heads conferidos em ambas. Backup backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb, intacto. Autorização do proprietário mantém main acompanhando checkpoints testados.

Continuação: branch port/slot-display-data. _updateDisplayData e replaceRawDisplayData/replaceDisplayData/replaceTextureData implementados. Comparação: 1.220 cenários/10.980 etapas/181.780 colunas/146 exceções de etapas esperadas por VM, zero aproximações locais. Seis mutantes rejeitados; produto restaurado e testes finais nas duas VMs aprovados. SlotFoundation também reexecutado. CI configurada para 39 suítes/sete exemplos. Consultar PR desta branch para head, CI e merge final; não antecipar resultados futuros.

Exemplo slotdata: pivô (50,40)→(40,30), origin.x=5 preservado; depois repete vínculo/colisão do slot em (45,20)→(55,20). Chama métodos de baixo nível e usa observador local, sem Slot.update/renderização/player.

## Próximo recorte

1. Conferir heads/backup/CI, integrar checkpoint autorizado somente após CI pertinente aprovada.
2. Auditar _updateDisplay/replaceDisplay e Slot.update com dependências reais de Armature/animação; manter hooks abstratos, sem métodos substitutos de produto.
3. Validar pai Surface, polígono/aliases no hit testing e lifecycle de child Armature quando dependências estiverem prontas. APIs públicas de displays ainda pendentes.
4. Atualizar inventário/contratos/progresso e exemplos executáveis. Manter montagem manual explícita até init/factory completos.

## Limites a preservar

Guard de identidade frame/geometria/textura, caixa relida fora dele, prioridade de origin raw, TODO de pivô, ordem de erro/fallback e sentinel SkinData.NULL. Lista de ossos mantém miss null e duplicatas. SlotData numérico: somente casos trig em matriz/pose/pivôs admitem 8 eps; zero/flags/refs exatos, nenhuma aproximação local observada. Não ampliar budgets anteriores: Surface tem contrato próprio de 32 eps e Bone/TransformObject de 8 eps. Preservar _matrixCahce e hull 10→12.

Armature.init/advanceTime, solvers IK/Path, avaliação/playback/blending, factories e backend LÖVE/GPU continuam pendentes. WorldClock mantém resolução de segundos de os.time. Exportações externas ao pin, locale tr/az, coerções/proxies/reflexão genéricos, Big Endian e payloads NaN arbitrários não são equivalência reivindicada. Listas da skin deste recorte são densas com null explícito; holes criados manualmente não foram validados.

## Reprodução

```sh
npm ci --ignore-scripts --no-audit --no-fund
node tools/inventory.js ../DragonBonesJS --check
node tools/dependencies.js ../DragonBonesJS --check
for vm in lua5.4 luajit; do
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox dataparser objectatlas structural geometryparser binaryarrays curveframes specialframes deformframes timelines animationparser armatureparser globalentry binaryutf8 binarytimeline binaryanimation binarygeometry binaryviews dbdt corpus transformobject bone surface displayframe slot slotdata; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Consultar PR para evidência remota/SHA/merge/CI; não antecipar resultados futuros.
