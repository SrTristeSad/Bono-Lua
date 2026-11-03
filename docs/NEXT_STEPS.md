# Continuidade — Bono-Lua

## Objetivo permanente

Reconstruir em Lua DragonBonesJS@64b6c69ae35777c2404be68c9192e2c56906079e preservando arquitetura, algoritmos e comportamentos. Destino único SrTristeSad/Bono-Lua. Comparação diferencial exigida; não declarar completude com pendências.

## Base desta unidade

- main 84c9b07c761da1123f0440010a3ec0615e1709a5, PR #75 integrado, CI pós-merge 41684809994 aprovada.
- Backup remoto backup/pre-integral-rebuild-20261103 em cd4206a8ac091b1b26ad02b9ee4bc6ec7f30eeeb conferido intacto.
- Unidade port/model-bounding-box-data; consultar PR/SHA/CI/merge atuais antes de editar. Main acompanha checkpoints testados por autorização do proprietário.

## Unidade implementada

BoundingBoxData.ts e Lua integral do backup lidos. Base abstrata, retângulo/elipse/polígono, outcodes e métodos estáticos/de instância preservados em dragonbones/model/BoundingBoxData.lua. Vertices JSArray base 1/length; undefined numérico/holes→NaN. Defaults só no clear. Agrupamento pY*(widthH/heightH) segue TS, diferente da tradução antiga do backup. Peculiaridades de coordenadas/outputs/nome/perturbações/broad phase upstream preservadas, conforme contracts/BoundingBoxQueries.md.

125 cenários, 3.616 operações e 57.856 colunas por VM Lua 5.4/LuaJIT. Binary64 exato/NaN canonicalizado/sinal do zero exato; apenas normais não nulas derivadas de atan2, inclusive aliases e valores preservados, usam 8*epsilon*max(1,abs(expected)). 300 comparações aproximadas por VM, incluindo repetições. Doze sequências de 160 consultas. Dezoito falhas de escrita x/y e três falhas de retorno, todas auditadas. BoundingBoxDisplayData/SkinData/ArmatureData/DragonBonesData e Points/pool reais; sem runtime Slot ou renderização.

Experimentos de corrigir pointB.y=xB do retângulo e de contar todas as interseções do polígono sem pointB foram rejeitados nas linhas 93/809; produto restaurado e suíte final refeita nas duas VMs. CI executa quatorze suítes.

## Próxima unidade

1. Conferir main, backup, PRs/CI, estado/progresso/mapa/validação/decisões/diferenças.
2. Auditar parser/DataParser.ts inteiro e Lua real do backup. Delimitar constantes, métodos estáticos de conversão e contrato abstrato para parsers, sem fabricar classes completas de ObjectDataParser/BinaryDataParser.
3. Portar a base/contratos e comparar métodos executáveis contra TS genuíno, preparando importação JSON/DBDT com modelos reais. Buffers/views tipados precisam de auditoria/representação compartilhada próprias antes de afirmar parsing binário.
4. Atualizar inventário/documentação, publicar PR, conferir CI e integrar checkpoint autorizado.

## Pendências

- DataParser/ObjectDataParser/BinaryDataParser, ArrayBuffer/typed views reais; referências já decodificadas de teste não provam decodificação/compartilhamento binário.
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
  for suite in geom math baseobject models worldclock events config animationdata displaydata armaturedata constraintdata skindata dragonbonesdata boundingbox; do
    node tests/${suite}_differential.js ../DragonBonesJS "$vm"
  done
done
```

Upstream deve estar no commit fixado. CI preserva transcrições/JSON por VM. Consultar PR para SHA final, merge e CI pós-merge; não antecipar evidências futuras.
