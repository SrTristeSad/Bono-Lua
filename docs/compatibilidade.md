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
| Importação de arquivos locais | Esqueleto JSON, atlas JSON e PNG do Mecha 1406 | Passou no Chromium |
| Controle temporal de animação | AnimationState.currentTime + pausa/reprodução | Passou no Chromium |
| Reprodução visual | PixiJS 8 + DragonBonesJS original, Chromium headless | Passou |
| Skins, IK, deformação e malhas | Testes comparativos | Não implementado |
| Editor de pose-base | Hierarquia, seleção, X/Y/rotação, preview e exportação do _ske.json | Passou no Chromium |
| Persistência | Salvar e reimportar esqueleto editado mantendo animações originais | Passou no Chromium |
| Editor completo | Criação/remoção de ossos, IK, skins, keyframes e timeline | Não implementado |
| Exportação de vídeo e PNG | Render/encoder | Não implementado |

Execuções CI: [ver workflow](../.github/workflows/dragonbones-original.yml). [Execução de referência com visualizador gráfico aprovado](https://github.com/SrTristeSad/Bono-Lua/actions/runs/41336047352).

**Nota:** os testes no Chromium comprovam renderização, edição inicial da pose-base, download do JSON e reimportação do exemplo real. Isso **não** significa equivalência completa ao editor DragonBones: pesos de malhas, IK, deformação, animações e hierarquia em edição avançada ainda precisam de validação. Skins, IK, deformações e a edição visual completa exigem testes próprios.
