# Matriz de compatibilidade — DragonBonesJS

Referência: `DragonBones/DragonBonesJS` no commit `64b6c69ae35777c2404be68c9192e2c56906079e`.

| Área | Teste | Resultado |
| --- | --- | --- |
| Compilação TypeScript do runtime original | CI `original:build` | Passou |
| API original | Presença de classes importantes no JS compilado | Passou |
| Matriz de transformação | Transformação, inversão e ponto | Passou |
| Importação fixture Bono-Lua | Hierarquia de ossos, slots e clips | Passou |
| Importação fixture DragonBonesJS real | 20 ossos, 19 slots, idle | Passou |
| Clock | Adição, avanço e remoção de animável | Passou |
| Troca de personagem e animação | Mecha 1002 idle, Mecha 1406 walk, pausa/retomada | Passou |
| Amostra Mecha 1406 | 17 ossos, 13 slots e oito animações disponíveis | Passou |
| Reprodução visual | PixiJS 8 + DragonBonesJS original, Chromium headless | Passou |
| Skins, IK, deformação e malhas | Testes comparativos | Não implementado |
| Editor original | UI reconstruída | Não implementado |
| Exportação de vídeo e PNG | Render/encoder | Não implementado |

Execuções CI: [ver workflow](../.github/workflows/dragonbones-original.yml). [Execução de referência com visualizador gráfico aprovado](https://github.com/SrTristeSad/Bono-Lua/actions/runs/41334992841).

**Nota:** agora o teste em Chromium comprova a integração de renderização e o avanço temporal de dois clips originais, mas isso **não** significa equivalência funcional com todo o editor DragonBones. Skins, IK, deformações e a edição visual completa exigem testes próprios.
