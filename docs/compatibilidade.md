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
| Reprodução visual | Renderizador original integrado | Não implementado |
| Skins, IK, deformação e malhas | Testes comparativos | Não implementado |
| Editor original | UI reconstruída | Não implementado |
| Exportação de vídeo e PNG | Render/encoder | Não implementado |

Execuções CI: [ver workflow](../.github/workflows/dragonbones-original.yml).

**Nota:** importar metadados de animação não prova a reprodução gráfica ou o comportamento dos keyframes. Não confundir os testes de parser com equivalência completa ao DragonBones.
