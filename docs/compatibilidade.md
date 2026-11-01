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
| Seleção visual de ossos | Marcadores atualizados por matriz global do DragonBones e clique na prévia | Passou no Chromium |
| Inspeção de slots | Osso pai, ordem, índice de display e imagens por skin | Passou no Chromium |
| Edição de slots | Troca/ocultação de desenho, restauração, ordem-base, exportação e reimportação | Passou no Chromium |
| Proteção de Z-order animado | Bloquear mudança da ordem-base com timelines de sobreposição existentes | Passou em teste unitário |
| Persistência | Salvar e reimportar esqueleto editado mantendo animações originais | Passou no Chromium |
| Edição de keyframes existentes | Translação X/Y, rotação e seleção por quadro em dados DragonBones 5.x | Passou no Chromium |
| Recompilação de timeline editada | Parser e armadura originais, pose reavaliada após mudança de keyframe | Passou no Chromium |
| Exportação/reimportação da timeline | Valor modificado sobrevive ao roundtrip JSON e mantém demais dados | Passou no Chromium |
| Editor completo | Criação/remoção de ossos e keyframes, IK, skins e interpolação | Não implementado |
| Exportação de vídeo e PNG | Render/encoder | Não implementado |

Execuções CI: [ver workflow](../.github/workflows/dragonbones-original.yml). [Execução de referência com visualizador gráfico aprovado](https://github.com/SrTristeSad/Bono-Lua/actions/runs/41339211563).

**Nota:** o Chromium confirma renderização, seleção visual, inspeção dos slots, edição inicial da pose-base, download do JSON e reimportação de um exemplo real. Isso **não** significa equivalência completa ao editor DragonBones: skins alternativas, pesos de malhas, IK, deformações, Z-order animado e criação de keyframes e edição de interpolação ainda precisam ser desenvolvidos e validados.
